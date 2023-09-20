
select * from PortfolioProjectCovid..Covid_Death

select * from PortfolioProjectCovid..Covid_Death
--where continent is not null
order by 2,3

--select * PortfolioProjectCovid.dbo.from Covid_Vaccine
--order by 3,4

select continent, location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProjectCovid..Covid_Death
where continent is not null
order by 1,2,3

-- Looking at total cases vs total deaths
-- shows the likelihood of dying if you get infected in your country
select continent, location, date, total_cases, total_deaths, (total_deaths/cast(total_cases as float))*100 as lethality_percentage
from PortfolioProjectCovid..Covid_Death 
where continent is not null
and location = 'United States'
order by 1,2,3

-- looking at countries with highest lethality percentage
select continent, location, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as lethality_percentage
from PortfolioProjectCovid..Covid_Death 
--where location = 'United States'
where continent is not null
and total_cases is not null
group by continent, location
order by 5 desc


-- Looking at total_cases vs population
-- shows the percentage of population that got infected (consider this number doesnt reflect people that recover or people that got infected multiple times)
select Location, date, population, total_cases, (total_cases/population)*100 as infected_percentage
from PortfolioProjectCovid..Covid_Death 
--where location = 'Chile'
order by 1,2


-- Looking at countries with highest infection rate compared to population
select Location, population, max(total_cases) as Total_Cases, (max(total_cases)/population)*100 as infected_percentage
from PortfolioProjectCovid..Covid_Death 
group by Location, population
order by 4 desc


-- Showing countries with highest death count per population
select Location, population, max(cast(total_deaths as int)) as death_count, max((total_deaths/population))*100 as death_vs_population
from PortfolioProjectCovid..Covid_Death 
where continent is not null
group by Location, population
order by death_vs_population desc


-- By Continent
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectCovid..Covid_Death
where continent is null
and location <> 'Upper middle income' and location <> 'Lower middle income' and location <> 'High income' and location <> 'Low income'
group by location
order by TotalDeathCount desc


-- Global numbers by date
-- numbers normalize as long as the days pass!
select date, sum(new_cases) as CasesThatDay, sum(cast(total_cases as int)) as TotalCases, sum(new_deaths) as DeathsThatDay, sum(cast(total_deaths as int)) as TotalDeaths,
(sum(cast(total_deaths as float))/sum(cast(total_cases as float)))*100 as LethalityPercentage
from PortfolioProjectCovid..Covid_Death
where continent is not null
group by date
order by 1



-- Total Global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  (sum(cast(new_deaths as int))/sum(new_cases))*100 as LethalityPercentage
from PortfolioProjectCovid..Covid_Death
where continent is not null



-- looking at total population vs Vaccination
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, sum(CONVERT(float,Vac.new_vaccinations)) over (partition by Dea.location order by Dea.location, Dea.date ROWS UNBOUNDED PRECEDING) as total_vaccination
from PortfolioProjectCovid..Covid_Death as Dea
join PortfolioProjectCovid..Covid_Vaccine as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
--and Dea.location = 'Chile'
order by 2,3


-- Looking at the countries with highest number of vaccination per population
-- a 300% value means at least 3 doses per person

-- CTE 
with PopulationVsVaccination (continent, location, population, total_vaccination)
as
(
select Dea.continent, Dea.location, Dea.population
, sum(CONVERT(float,Vac.new_vaccinations)) as total_vaccination
from PortfolioProjectCovid..Covid_Death as Dea
join PortfolioProjectCovid..Covid_Vaccine as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
group by Dea.continent, Dea.location, Dea.population
--order by 2,3
)
select continent, location, population, total_vaccination, (total_vaccination/population)*100 as vaccination_percentage
from PopulationVsVaccination
order by vaccination_percentage desc


-- same as above, but without CTE
select Dea.continent, Dea.location, Dea.population
, sum(CONVERT(float,Vac.new_vaccinations)) as total_vaccination, (sum(CONVERT(float,Vac.new_vaccinations))/Dea.population)*100 as vacc_percentage
from PortfolioProjectCovid..Covid_Death as Dea
join PortfolioProjectCovid..Covid_Vaccine as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
group by Dea.continent, Dea.location, Dea.population
order by vacc_percentage desc



--TEMP TABLE (same as above but now we are storing the information in a temporal table)
drop table if exists #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Population int,
total_vaccinations float,
vaccination_percentage float
)

insert into #PercentagePopulationVaccinated
select Dea.continent, Dea.location, Dea.population
, sum(CONVERT(float,Vac.new_vaccinations)) as total_vaccination, (sum(CONVERT(float,Vac.new_vaccinations))/Dea.population)*100 as vacc_percentage
from PortfolioProjectCovid..Covid_Death as Dea
join PortfolioProjectCovid..Covid_Vaccine as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
group by Dea.continent, Dea.location, Dea.population

select *
from #PercentagePopulationVaccinated
order by vaccination_percentage desc



--Views
--Creating Views to store data for later visualizations

Create View PercentPopulationVaccinated as
select Dea.continent, Dea.location, Dea.population
, sum(CONVERT(float,Vac.new_vaccinations)) as total_vaccination, (sum(CONVERT(float,Vac.new_vaccinations))/Dea.population)*100 as vacc_percentage
from PortfolioProjectCovid..Covid_Death as Dea
join PortfolioProjectCovid..Covid_Vaccine as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
group by Dea.continent, Dea.location, Dea.population
--order by vacc_percentage desc

select * from PercentPopulationVaccinated
order by 5 desc

