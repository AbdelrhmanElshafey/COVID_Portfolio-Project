use PortfolioProject

Select *
From PortfolioProject..CovidDeaths
Order By 3, 4




Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1, 2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in 'Egypt'

Select Location, date, total_cases,total_deaths, ISNULL((total_deaths/total_cases)*100, 0) as [Death Percentage]
From PortfolioProject..CovidDeaths
Where location = 'Egypt'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  ISNULL((total_cases/population)*100, 0) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'Egypt'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as [Total Death Count]
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by [Total Death Count] desc


-- Let's Break Things down by continent
-- Showing contintents with the highest death count per population


Select location, Max(Cast(total_deaths as int)) as [Total Death Count]
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by [Total Death Count] desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
Group By date
order by 1,2

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


-- looking All Location to Get The Number of Cases, Number Deaths and Percentage Deaths For Each of Ther
-- Shows what percentage of population infected with Covid and Shows likelihood of dying if you contract covid Everywhere in the world

Select Location, population, Max(cast(total_cases as int)) [Total Cases], Max(cast(Total_deaths as int)) [Total Deaths], 
		ISNULL(Max(cast(Total_deaths as float)) / Max(total_cases) * 100, 0) [Deaths Percentage Based Cases], 
		ISNULL(Max(total_cases) / Max(Population) * 100, 0) [Cases Percentage Based Populations]
From PortfolioProject..CovidDeaths 
Where continent is not null 
Group By Location, population
Having Max(total_cases) is Not Null
Order By [Deaths Percentage Based Cases] Desc, [Cases Percentage Based Populations] Desc


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



