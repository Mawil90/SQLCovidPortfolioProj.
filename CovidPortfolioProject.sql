/*OUR WORLD HEALTH COVID 19 DATA EXPOLORATION PROJECT

Skills used: Joins, CTE's, Window's Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From SQLPORTFOLIO..CovidDeaths
Where continent is not null
Order by 3,4



--Select the data we are going to begin with
Select location, date, total_cases, new_cases, total_deaths, population
From SQLPORTFOLIO..CovidDeaths
Where continent is not null
order by 1,2

--Total Cases vs Total Death
--Likelihood of death if Covid is contracted in your country 
Select location, date, total_cases,total_deaths, (total_deaths/ total_cases) *100 as death_percentage
From SQLPORTFOLIO..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Total Cases vs Population
--Percentage of infected population
Select location, date, total_cases,population, (total_cases/population) *100 as infected_population_percentage
From SQLPORTFOLIO..CovidDeaths
where location like '%states%'
and continent is not null
Order by 1,2

--Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infected_population_percentage
From SQLPORTFOLIO..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by location, population
order by infected_population_percentage desc

--Countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as highest_death_count
From SQLPORTFOLIO..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by location
order by highest_death_count desc

--Highest death count per continent
Select continent, MAX(cast(total_deaths as int)) as highest_death_count
From SQLPORTFOLIO..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
order by highest_death_count desc

--Global numbers 
Select SUM(new_cases) as global_cases, SUM(cast(new_deaths as int)) as global_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as global_death_percentage
From SQLPORTFOLIO..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Looking at Total population vs new vaccinations per day
--Shows percentage of population that has received at least one Covid Vaccine
Select dea.continent, dea.location,dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER ( partition by dea.location order by dea.location, dea.date) as
rolling_vaccination_count
From SQLPORTFOLIO..CovidDeaths dea
Join SQLPORTFOLIO..CovidVaccinations vac
On dea.location = vac.location 
and dea.date =vac.date
where dea.continent is not null
order by 2,3

--Using CTE to perform calculation on Partition By in previous query 
With PopulationvsVacinated(continent, lcoation,date,population,new_vaccinations,rolling_vaccination_count)
as 
(
Select dea.continent, dea.location,dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER ( partition by dea.location order by dea.location, dea.date) as
rolling_vaccination_count
From SQLPORTFOLIO..CovidDeaths dea
Join SQLPORTFOLIO..CovidVaccinations vac
On dea.location = vac.location 
and dea.date =vac.date
where dea.continent is not null
)
Select *, (rolling_vaccination_count/population)*100
From PopulationvsVacinated
order by 2,3


--Create view to store data for promising visualizations 

Create view PopulationvsVaccinated as
Select dea.continent, dea.location,dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER ( partition by dea.location order by dea.location, dea.date) as
rolling_vaccination_count
From SQLPORTFOLIO..CovidDeaths dea
Join SQLPORTFOLIO..CovidVaccinations vac
On dea.location = vac.location 
and dea.date =vac.date
where dea.continent is not null

Select *
From PopulationvsVaccinated
