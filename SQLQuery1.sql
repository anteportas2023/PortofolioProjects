select *
from PortofolioProject..CovidDeaths
where continent is not null
order by 3, 4

--select *
--from PortofolioProject..CovidVaccinations
--order by 3, 4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from PortofolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1, 2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases / population) * 100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
--where location like '%states%'
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestIfectionCount, max((total_cases / population)) * 100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select location, max(cast(Total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing continents with the highest death count per population

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

select  date, SUM(new_cases) as total_cases, sum(new_deaths) as total_deaths,  
       sum(new_deaths) / sum(new_cases) * 100 as DeathPercentage
from PortofolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
and date > '2020-01-20'
and date < '2023-04-05'
group by date
order by 1, 2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  sum(convert(int, vac.new_vaccinations )) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
  on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- USE CTE
with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  sum(convert(int, vac.new_vaccinations )) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
  on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated / population) * 100
from popvsvac
order by 2, 3


-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  sum(convert(int, vac.new_vaccinations )) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
  on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated / population) * 100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated