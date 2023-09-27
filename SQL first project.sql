SELECT * 
From PortfolioProject..covidDeath
order by 3,4

SELECT * 
From PortfolioProject..covidVacinations
order by 3,4


-- Select Data that are going to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covidDeath
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths,(CONVERT(float,total_deaths)/(CONVERT(float,total_cases)))*100 as DeathPercentage
From PortfolioProject..covidDeath
WHERE location = 'Australia'
order by 1,2


-- Looking at total cases vs population
SELECT location, date, total_cases, population,(CONVERT(float,total_cases)/(CONVERT(float,population)))*100 as PercentPopulationInfected
From PortfolioProject..covidDeath
WHERE location = 'Australia'
order by 1,2


-- Looking at countries with highest infection rate compared to population
SELECT location, population ,MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float,total_cases)/(CONVERT(float,population)))*100 as PercentPopulationInfected
From PortfolioProject..covidDeath
WHERE continent is not null
Group by location, population
order by PercentPopulationInfected desc


-- Showing countries with highest death count per population
SELECT location, MAX(CONVERT(int,total_deaths)) as HighestDeathCount, MAX(CONVERT(float,total_deaths)/(CONVERT(float,population)))*100 as DeathPercentage
From PortfolioProject..covidDeath
WHERE continent is not null
Group by location
order by HighestDeathCount desc


-- Break things down by Continent
-- Showing continents with the highest death count per population
SELECT continent, MAX(CONVERT(int,total_deaths)) as HighestDeathCount, MAX(CONVERT(float,total_deaths)/(CONVERT(float,population)))*100 as DeathPercentage
From PortfolioProject..covidDeath
WHERE continent is not null
Group by continent
order by HighestDeathCount desc


-- Global numbers
SELECT SUM(new_cases) as total_cases, SUM(new_deaths)as total_deaths, (SUM(CONVERT(float,new_deaths))/NULLIF(SUM(CONVERT(float, new_cases)), 0)) *100 as DeathPercentage
From PortfolioProject..covidDeath
where continent is not null 
order by 1,2 


-- Looking at total population vs vacinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)as PeopleVaccinated
-- order by location and date will make it increment 
From PortfolioProject..covidDeath dea
Join PortfolioProject..covidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--Use CTE
With PopvsVac(Continent, Location, Date, Population,New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)as PeopleVaccinated
-- order by location and date will make it increment 
From PortfolioProject..covidDeath dea
Join PortfolioProject..covidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)

Select *, (PeopleVaccinated/Population) as VaccinatedPercentage
From PopvsVac


--Temp table
Drop Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)as PeopleVaccinated
-- order by location and date will make it increment 
From PortfolioProject..covidDeath dea
Join PortfolioProject..covidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3


--Creating View
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)as PeopleVaccinated
-- order by location and date will make it increment 
From PortfolioProject..covidDeath dea
Join PortfolioProject..covidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated