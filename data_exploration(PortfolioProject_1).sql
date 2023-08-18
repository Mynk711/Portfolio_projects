select * 
from Portfolio_Project..CovidDeaths
order by 3,4

--select * 
--from Portfolio_Project..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
order by 1,2

--Total cases vs total deaths
-- Likelihood of dying if you live in India
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from Portfolio_Project..CovidDeaths
where Location = 'India'
order by 1,2

-- Total cases vs Population
-- Shows percentage of population that got covid in India
select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPopulation
from Portfolio_Project..CovidDeaths
where Location = 'India'
order by 1,2

-- Looking at the most affected countries
-- Highest infection rate with respect to the population
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestInfectedPercentage
from Portfolio_Project..CovidDeaths
--where Location = 'India'
group by Location, population
order by HighestInfectedPercentage desc


-- Highest deaths in a country with respect to the population
select Location,  population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population))*100 as HighestDeathPercentage
from Portfolio_Project..CovidDeaths
--where Location = 'India'
where continent is not null
group by Location, population
order by HighestDeathPercentage desc

-- Highest death count per country
select Location,  MAX(cast(total_deaths as int)) as DeathCount
from Portfolio_Project..CovidDeaths
--where Location = 'India'
where continent is not NULL
group by Location
order by DeathCount desc

-- Highest death count per continent
select location,  MAX(cast(total_deaths as int)) as DeathCount
from Portfolio_Project..CovidDeaths
--where Location = 'India'
where continent is  NULL
group by location
order by DeathCount desc

-- Highest death count per continent
select continent,  MAX(cast(total_deaths as int)) as DeathCount
from Portfolio_Project..CovidDeaths
--where Location = 'India'
where continent is not NULL
group by continent
order by DeathCount desc


--GLOBAL
-- Death percentage globally
select  date, SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
from Portfolio_Project..CovidDeaths
where continent is not NULL
group by date
order by date

--Total death percentage in the world as a whole
select  SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
from Portfolio_Project..CovidDeaths
where continent is not NULL
--group by date
--order by date


-- Introducing the table: CovidVaccinations 
-- Total population vs Total vaccinations

with PopvsVac(continent, location, date, population, new_vaccinations, sum_of_total_vaccinations)
as
(
select death.continent, death.location, death.date, population, vaccine.new_vaccinations, 
Sum(cast(vaccine.new_vaccinations as int)) OVER ( partition by death.location order by  death.location, 
death.date) as sum_of_total_vaccinations
from Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vaccine
	on death.location = vaccine.location
	and death. date = vaccine.date
where death.continent is not NULL
--order by 2,3
)
select *, (sum_of_total_vaccinations/population)*100
from PopvsVac

-- Temp Table
drop table if exists #PopvsVac
create table #PopvsVac(
continent nvarchar(55),
location nvarchar(55),
date datetime,
population numeric,
new_vaccinations numeric,
sum_of_total_vaccinations numeric)

insert into #PopvsVac
select death.continent, death.location, death.date, population, vaccine.new_vaccinations, 
Sum(cast(vaccine.new_vaccinations as int)) OVER ( partition by death.location order by  death.location, 
death.date) as sum_of_total_vaccinations
from Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vaccine
	on death.location = vaccine.location
	and death. date = vaccine.date
where death.continent is not NULL
--order by 2,3

select *, (sum_of_total_vaccinations/population)*100
from #PopvsVac


-- Creating view to stor data for visualizations

create view Percentage_of_population_vaccinated as

select death.continent, death.location, death.date, population, vaccine.new_vaccinations, 
Sum(cast(vaccine.new_vaccinations as int)) OVER ( partition by death.location order by  death.location, 
death.date) as sum_of_total_vaccinations
from Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vaccine
	on death.location = vaccine.location
	and death. date = vaccine.date
where death.continent is not NULL
--order by 2,3

select *
from Percentage_of_population_vaccinated