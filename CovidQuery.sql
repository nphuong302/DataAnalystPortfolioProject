SELECT @@VERSION

select * 
from DataAnalystPortfolioProject..CovidDeaths_v02$
where continent is not null
order by location, date;

select * 
from DataAnalystPortfolioProject..CovidDeaths_v02$
where continent is null and location like '%income%'
order by location, date;



-- Looking at Total Cases and Total Deaths

select location, date, total_cases, new_cases, total_deaths, population
from DataAnalystPortfolioProject..CovidDeaths_v02$
where continent is not null
order by location, date;



-- Looking at Total Cases and Total Deaths in Vietnam

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from DataAnalystPortfolioProject..CovidDeaths_v02$
where location = 'Vietnam'
order by death_percentage desc;


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from DataAnalystPortfolioProject..CovidDeaths_v02$
where location = 'Vietnam'
order by location, date;



-- Looking at Population and Total Cases in Vietnam in 2020

select location, date, population, total_cases, (total_cases/population)*100 as infection_percentage
from DataAnalystPortfolioProject..CovidDeaths_v02$
where location = 'Vietnam' and date like '%2020%'
order by location, date;



-- Looking at Population and Total Cases in Vietnam in 2021

select location, date, population, total_cases, (total_cases/population)*100 as infection_percentage
from DataAnalystPortfolioProject..CovidDeaths_v02$
where location = 'Vietnam' and date like '%2021%'
order by location, date;



-- Looking at Total Cases vs Population
-- Show what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as infection_percentage
from DataAnalystPortfolioProject..CovidDeaths_v02$
where continent is not null
order by location, date;



-- Looking at Countries with highest Infection rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as HighestInfectionPercentage
from DataAnalystPortfolioProject..CovidDeaths_v02$
where continent is not null
group by location, population
order by HighestInfectionPercentage desc;



-- Show countries with highest death count per population

select location, max(cast(total_deaths as int)) as HighestDeathCount
from DataAnalystPortfolioProject..CovidDeaths_v02$
where continent is not null
group by location
order by HighestDeathCount desc;



-- Looking at each continent

select continent, location, max(cast(total_deaths as int)) as HighestDeathCount
from DataAnalystPortfolioProject..CovidDeaths_v02$
where continent is not null
group by continent, location
order by HighestDeathCount desc;



-- Showing contintents with the highest death count per population

select location, max(cast(total_deaths as int)) as HighestDeathCount
from DataAnalystPortfolioProject..CovidDeaths_v02$
where continent is null and location not like '%income%'
group by location
order by HighestDeathCount desc;

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from DataAnalystPortfolioProject..CovidDeaths_v02$
where continent is not null
group by continent
order by HighestDeathCount desc;



-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From DataAnalystPortfolioProject..CovidDeaths_v02$
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- Global numbers

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From DataAnalystPortfolioProject..CovidDeaths_v02$
Where continent is not null 
Group by date
order by date;


Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From DataAnalystPortfolioProject..CovidDeaths_v02$
Where continent is not null;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, dea.total_deaths, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as PeopleVaccinated
from DataAnalystPortfolioProject..CovidDeaths_v02$ dea
join DataAnalystPortfolioProject..CovidVaccinations_v02$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by location, date;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
from DataAnalystPortfolioProject..CovidDeaths_v02$ dea
join DataAnalystPortfolioProject..CovidVaccinations_v02$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (PeopleVaccinated/Population)*100 as VaccinatedPerPopulation
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query


Drop Table #PercentPopulationVaccinated; -- This is use for SQL Server < 2016

-- This is applicable SQL Server 2016
-- DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
from DataAnalystPortfolioProject..CovidDeaths_v02$ dea
join DataAnalystPortfolioProject..CovidVaccinations_v02$ vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 

Select *, (PeopleVaccinated/Population)*100 as VaccinatedPerPopulation
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
From DataAnalystPortfolioProject..CovidDeaths_v02$ dea
Join DataAnalystPortfolioProject..CovidVaccinations_v02$ vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 

Select * 
From PercentPopulationVaccinated