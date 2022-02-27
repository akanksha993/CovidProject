SELECT *
From PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

/*SELECT *
From PortfolioProject..CovidVaccinations
ORDER BY 3,4
*/

--The chances of dying if you contract Covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where Location like '%states%' and continent is not null
order by 1,2


--Total cases vs Population
Select Location, date, Population, total_cases, (total_cases/Population)*100 AS PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where Location like '%states%'
where continent is not null
order by 1,2


--Highest Infection rates of countries compared to populations
Select Location, Population, MAX(total_cases) AS HighestInfectionCount , MAX((total_cases/Population))*100 AS PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where Location like '%states%'
Group by Location, Population
order by  PercentagePopulationInfected desc


--Countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where Location like '%states%'
where continent is not null
Group by Location
order by  TotalDeathCount desc

-- Breaking into Continent wise
--Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where Location like '%states%'
where continent is not null
Group by continent
order by  TotalDeathCount desc

--Global Numbers
-- Casting coz original in float 
Select date, Sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2
--Total number
Select Sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Total population vs Vaccination
--bigint because SUm too big to fit in int
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint , vac.new_vaccinations)) 
over (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--As we have to use RollingPeopleVaccinated from prev query - a new column hence
--using CTE - make sure the columns are same in both CTE and the query
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint , vac.new_vaccinations)) 
over (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 throws error
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac
--where Location like 'Albania';

--Temp Table
--Drop table so you can re-run the whole code
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
-- specify data type as well- it's like creating a table
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint , vac.new_vaccinations)) 
over (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 throws error
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated
--where Location like 'Albania';






-- Creating View to store data for later visualizations
-- Drop View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint , vac.new_vaccinations)) 
over (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 -- throws error
--Refresh - Control shift R

Select * 
from PercentPopulationVaccinated


