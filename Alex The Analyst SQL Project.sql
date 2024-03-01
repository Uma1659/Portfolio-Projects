select * 
from PFP..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PFP..CovidVaccinations
--order by 3,4

-- select Data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from PFP..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PFP..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PFP..CovidDeaths
--where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rated compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as 
  PercentPopulationInfected
from PFP..CovidDeaths
--where location like '%states%'
group by population, location
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count Per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
  from PFP..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
  from PFP..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

select  --date,
sum(new_cases) as totalcases,SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PFP..CovidDeaths
--where location like '%states%'
where continent is not null
-- group by date
order by 1,2

select * 
from PFP..CovidVaccinations

-- Looking at Total Population vs Vaccinations

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, --(RollingPeopleVaccinated/population)*100
from PFP..CovidDeaths dea
join PFP..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (continent, location,date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PFP..CovidDeaths dea
join PFP..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Temp Table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into  #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PFP..CovidDeaths dea
join PFP..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
drop view if exists PercentPopulationVaccinated

Create view PercentPopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PFP..CovidDeaths dea
join PFP..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated