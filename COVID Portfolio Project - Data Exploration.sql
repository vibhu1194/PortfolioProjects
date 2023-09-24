

Select * from [dbo].[CovidDeaths]
where continent is not null
order by 3,4


--Select * from [dbo].CovidVaccinations$	
--order by 3,4

-- Select Data that we are going to be using


Select location, date, total_cases, new_cases, total_deaths,population
from [dbo].[CovidDeaths]
order by 1,2


-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contact covid in your country

Alter Table [dbo].[CovidDeaths]
Alter column [total_cases] float

Alter Table [dbo].[CovidDeaths]
Alter column [total_deaths] float

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths]
Where location like '%India%'
order by 1,2

--Looking at total cases vs population
-- shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentageInfected
from [dbo].[CovidDeaths]
--Where location like '%states%'
order by 1,2

-- Looking at countries with Highest infection rate compared to population


Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationPercentageInfected
from [dbo].[CovidDeaths]
--Where location like '%states%'
Group by Location, Population
order by PopulationPercentageInfected desc

-- Shows countries with highest death count per population

--Select Location, Max(cast(total_deaths as int)) as TotalDeathCount

Select Location, Max(total_Deaths) as TotalDeathCount
from [dbo].[CovidDeaths]
--Where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


-- lets break things down by continent


-- Showing the continents with the highes death count population

Select continent, Max(total_Deaths) as TotalDeathCount
from [dbo].[CovidDeaths]
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers

Select Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, Sum(new_deaths)/ Sum(new_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths]
--Where location like '%India%'
where continent is not null
--Group By date
order by 1,2



--Looking at total population vs vaccinations

Alter table [dbo].[CovidVaccinations]
alter column [new_vaccinations] float

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE to store the RollingPeopleVaccinated into a temp file

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac




-- Temp Table


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for later visulaization

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



Select *
From PercentPopulationVaccinated