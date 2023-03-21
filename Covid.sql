SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject1..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states%'
order by 1,2


-- Looking at the Total Cases vs Population
--Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
order by TotalDeathCount desc

--Showing the Continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
order by 1,2

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
order by 1,2


-- Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
  order by 2,3

  --USE CTE
  
  With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
  as
(
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
  )
  SELECT *, (RollingPeopleVaccinated/population)*100 as RollingPercent
  FROM PopvsVac


  --Creat View to store data for later visualizations

  Create View