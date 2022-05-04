select *
from Portfolio.dbo.coviddeaths
where continent is not null
order by 3,4



select location, date, total_cases, new_cases, total_deaths, population
from Portfolio..coviddeaths
order by 1,2

-- Looking total cases vs total deaths
-- likelihood of dying if you get infection "Algeria as an example"
select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as death_rate
from Portfolio..coviddeaths
where location = 'Algeria'
AND continent is not null
order by 1,2

-- Looking at total cases vs population 
-- show percentage of population got covid
select location, date, total_cases, population, (total_cases/population) * 100 as cases_rate
from Portfolio..coviddeaths
where location = 'Algeria'
AND  continent is not null
order by 1,2

-- Looking at Countries with highest infection rate compared to population
select location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population)) * 100 as highest_infection_rate
from Portfolio..coviddeaths
where continent is not null
group by location, population
order by highest_infection_rate desc

-- Looking countries with the highest death count per population
select location, MAX(cast(total_deaths as int)) as highest_deaths_count
from Portfolio..coviddeaths
where continent is not null
group by location
order by highest_deaths_count desc


-- Let's try to see death right by continent
select continent, MAX(cast(total_deaths as int)) as highest_deaths_count
from Portfolio..coviddeaths
where continent is not null
group by continent
order by highest_deaths_count desc

-- global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as death_rate
from Portfolio..coviddeaths
where continent is not null
order by 1,2


-- Looking at total population vs vaccinations
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location  Order by dea.location, CONVERT(date,dea.date)) as total_people_vaccinated
from Portfolio..covidvaccinations vac
Join Portfolio..coviddeaths dea
     on vac.location = dea.location
	 and vac.date = dea.date
where dea.continent is not null   
order by 2,3


-- use cte 
with popvsvac(continent, location, date, population, new_vaccinations, total_people_vaccinated)
as
(
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location  Order by dea.location, CONVERT(date,dea.date)) as total_people_vaccinated
from Portfolio..covidvaccinations vac
Join Portfolio..coviddeaths dea
     on vac.location = dea.location
	 and vac.date = dea.date
where dea.continent is not null   
--order by 2,3
)
select *, (total_people_vaccinated/population)*100
from popvsvac

-- temp table
drop table if exists #people_vac_per
create table #people_vac_per
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_people_vaccinated numeric
)


insert into #people_vac_per
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location  Order by dea.location, CONVERT(date,dea.date)) as total_people_vaccinated
from Portfolio..covidvaccinations vac
Join Portfolio..coviddeaths dea
     on vac.location = dea.location
	 and vac.date = dea.date
--where dea.continent is not null   
--order by 2,3
select *, (total_people_vaccinated/population)*100
from #people_vac_per



-- craeting view to store data for later visualizations 

create view people_vac_per as

select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location  Order by dea.location, CONVERT(date,dea.date)) as total_people_vaccinated
from Portfolio..covidvaccinations vac
Join Portfolio..coviddeaths dea
     on vac.location = dea.location
	 and vac.date = dea.date
where dea.continent is not null   
--order by 2,3


select *
from people_vac_per
