use Portfolio_Project

select * 
from Portfolio_Project..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from Portfolio_Project..CovidVaccinations$
--order by 3,4

-- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
order by 1,2

--Looking at total_cases vs total_deaths

Select location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
where location like '%states%'
order by 1,2

-- looking at the total cases vs population
-- what percentage of population got covid 

Select location, date, total_cases, population,(total_cases/population)*100 as populationPercentage
From Portfolio_Project..CovidDeaths
--where location like '%states%'
order by 1,2

-- looking at countries with Highest infection rate compared to population

Select location,population,max(total_cases) as highest_infection_count,max(total_cases/population)*100 as percentpopulationInfected
From Portfolio_Project..CovidDeaths
--where location like '%states%'
Group by location,population
order by percentpopulationInfected desc

-- showing countries with highest death count population

Select location,max(cast(total_deaths as int)) as total_death_count
From Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by total_death_count desc

-- Let's break things down by continent

Select continent,max(cast(total_deaths as int)) as total_death_count
From Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by total_death_count desc

Select location,max(cast(total_deaths as int)) as total_death_count
From Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent is null
Group by location
order by total_death_count desc

-- showing the continents with the highest death count per population


Select continent,max(cast(total_deaths as int)) as total_death_count
From Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by total_death_count desc

-- Global numbers 

Select date,sum(new_cases) --total_cases, total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
From Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

Select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- total cases VS total deaths
Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2



Select * from Portfolio_Project..CovidVaccinations

Select * 
from Portfolio_Project..Coviddeaths dea 
join Portfolio_Project..Covidvaccinations vac 
    on dea.location = vac.location
   and dea.date = vac.date

-- Looking at total population vs vaccinations

Select dea.continent,dea.location,dea.date,dea.population,dea.new_vaccinations
from Portfolio_Project..Coviddeaths dea 
join Portfolio_Project..Covidvaccinations vac 
    on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
 order by 2,3

Select dea.continent,dea.location,dea.date,dea.population,dea.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location)
from Portfolio_Project..Coviddeaths dea 
join Portfolio_Project..Covidvaccinations vac 
    on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
 order by 2,3

 or

Select dea.continent,dea.location,dea.date,dea.population,dea.new_vaccinations,
sum(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingvaccinations
from Portfolio_Project..Coviddeaths dea 
join Portfolio_Project..Covidvaccinations vac 
    on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
 order by 2,3

 Select dea.continent,dea.location,dea.date,dea.population,dea.new_vaccinations,
sum(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingvaccinations,
--(rollingvaccinations/population)*100
from Portfolio_Project..Coviddeaths dea 
join Portfolio_Project..Covidvaccinations vac 
    on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
 order by 2,3


 -- use CTE

 with PopvsVac (Continent, Location, date,Population, new_vaccinations,rollingvaccinations) as
 (
 Select dea.continent,dea.location,dea.date,dea.population,dea.new_vaccinations,
sum(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingvaccinations
--(rollingvaccinations/population)*100
from Portfolio_Project..Coviddeaths dea 
join Portfolio_Project..Covidvaccinations vac 
    on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
 )
 Select *, (rollingvaccinations/population)*100
 from PopvsVac

 -- Temp table

 Create table #percentpopulationvaccinated
 (
 continent nvarchar(255),
 Location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingvaccinations numeric
  )
 Insert into #percentpopulationvaccinated
 Select dea.continent,dea.location,dea.date,dea.population,dea.new_vaccinations,
sum(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingvaccinations
--(rollingvaccinations/population)*100
from Portfolio_Project..Coviddeaths dea 
join Portfolio_Project..Covidvaccinations vac 
    on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
 
 Select *, (rollingvaccinations/population)*100
 from #percentpopulationvaccinated

 or

 Drop table if exists #percentpopulationvaccinated
 Create table #percentpopulationvaccinated
 (
 continent nvarchar(255),
 Location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingvaccinations numeric
  )
 Insert into #percentpopulationvaccinated
 Select dea.continent,dea.location,dea.date,dea.population,dea.new_vaccinations,
sum(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingvaccinations
--(rollingvaccinations/population)*100
from Portfolio_Project..Coviddeaths dea 
join Portfolio_Project..Covidvaccinations vac 
    on dea.location = vac.location
   and dea.date = vac.date
   --where dea.continent is not null
 
 Select *, (rollingvaccinations/population)*100
 from #percentpopulationvaccinated

 --To create a view to store data for later visualizations

 Create view percentpopulationvaccinated as
 Select dea.continent,dea.location,dea.date,dea.population,dea.new_vaccinations,
sum(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingvaccinations
--(rollingvaccinations/population)*100
from Portfolio_Project..Coviddeaths dea 
join Portfolio_Project..Covidvaccinations vac 
    on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3


select * from percentpopulationvaccinated