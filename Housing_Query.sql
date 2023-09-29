select * from
PortfolioProjectCovid.dbo.NashvilleHousing

-- Standardized Date format

select SaleDate, CONVERT(Date,SaleDate)
from PortfolioProjectCovid.dbo.NashvilleHousing

Update PortfolioProjectCovid.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--for some reason the above query doesnt work so I have to create a new column in which I'll store the converted value. later I'll delete the old SaleDate column
Alter Table PortfolioProjectCovid.dbo.NashvilleHousing
add SaleDateII Date;

Update PortfolioProjectCovid.dbo.NashvilleHousing
SET SaleDateII = CONVERT(Date,SaleDate)

select SaleDate, SaleDateII from PortfolioProjectCovid..NashvilleHousing


-- Populate property address data
-- self join to compare addresses with null values
select * from PortfolioProjectCovid.dbo.NashvilleHousing
where PropertyAddress is null

--here we can see all the property address that are in blank and that share an id with other one that has info in that column
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjectCovid.dbo.NashvilleHousing as a
join PortfolioProjectCovid.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- so now we populate the null values with the addresses that match both parcelID's
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectCovid.dbo.NashvilleHousing as a
join PortfolioProjectCovid.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress from PortfolioProjectCovid..NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address --charindex allows me to splip the string in the specific character that I want
from PortfolioProjectCovid..NashvilleHousing

select SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from PortfolioProjectCovid..NashvilleHousing

-- now we have to create the new columns to insert the split data and populate them
Alter Table PortfolioProjectCovid.dbo.NashvilleHousing
add PropertyAddressSplit nvarchar(255);

Update PortfolioProjectCovid.dbo.NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table PortfolioProjectCovid.dbo.NashvilleHousing
add PropertyCity nvarchar(255);

Update PortfolioProjectCovid.dbo.NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,len(PropertyAddress))


select PropertyAddressSplit, PropertyCity from PortfolioProjectCovid.dbo.NashvilleHousing

-- Owner Address
select OwnerAddress from PortfolioProjectCovid.dbo.NashvilleHousing

select PARSENAME(replace(OwnerAddress,',','.'),1) --replacing ',' with '.' so we can use parsename to split the string
from PortfolioProjectCovid.dbo.NashvilleHousing

select PARSENAME(replace(OwnerAddress,',','.'),3) as OwnersAddress,
PARSENAME(replace(OwnerAddress,',','.'),2) as OwnersCity,
PARSENAME(replace(OwnerAddress,',','.'),1) as OwnersState
from PortfolioProjectCovid.dbo.NashvilleHousing

--now we create the columns where we'll insert this data
Alter Table PortfolioProjectCovid.dbo.NashvilleHousing
add OwnersAddress nvarchar(255);

Update PortfolioProjectCovid.dbo.NashvilleHousing
SET OwnersAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

Alter Table PortfolioProjectCovid.dbo.NashvilleHousing
add OwnersCity nvarchar(255);

Update PortfolioProjectCovid.dbo.NashvilleHousing
SET OwnersCity = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter Table PortfolioProjectCovid.dbo.NashvilleHousing
add OwnersState nvarchar(255);

Update PortfolioProjectCovid.dbo.NashvilleHousing
SET OwnersState = PARSENAME(replace(OwnerAddress,',','.'),1)


select OwnersAddress,OwnersCity,OwnersState from PortfolioProjectCovid.dbo.NashvilleHousing -- it works!



-- Change Y and N to Yes and No in 'Sold as Vacant' field

select SoldAsVacant from PortfolioProjectCovid.dbo.NashvilleHousing

select distinct(SoldAsVacant), count(SoldAsVacant) --distinct allows me to see if there are diferent values
from PortfolioProjectCovid.dbo.NashvilleHousing
group by SoldAsVacant


select SoldAsVacant, --now we set all the N and Y values to No and Yes respectively
case
  when SoldAsVacant = 'N' then 'No'
  when SoldAsVacant = 'Y' then 'Yes'
  else SoldAsVacant
  end
from PortfolioProjectCovid.dbo.NashvilleHousing


update PortfolioProjectCovid.dbo.NashvilleHousing --finally we update the table with the new values
set SoldAsVacant = case
  when SoldAsVacant = 'N' then 'No'
  when SoldAsVacant = 'Y' then 'Yes'
  else SoldAsVacant
  end


-- Removing Duplicated Values


with RowNumCTE as (
select *, row_number() over (partition by ParcelID,
                                          PropertyAddress,
										  LegalReference,
										  OwnerName,
										  OwnerAddress
										  order by UniqueID
										  ) as row_num

from PortfolioProjectCovid.dbo.NashvilleHousing
)

DELETE
from RowNumCTE
where row_num > 1
--order by row_num desc



--Delete Unused Columns

alter table PortfolioProjectCovid.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
