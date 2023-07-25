SELECT * FROM CovidDeaths 
where continent is null
ORDER BY 3,4

--SELECT * FROM CovidVaccinations ORDER BY 3,4
SELECT location,date,total_cases,new_cases,total_deaths,population 
from CovidDeaths order by 1,2
--looking  at total cases vs total deaths
-- likehood of dying with covid
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths 
where location like '%egypt%'
order by 1,2

-- looking at total cases vs population
-- percentage of population infected
select location,date,total_cases,population,(total_cases/population)*100 as populationpercentage
from CovidDeaths 
where location like '%egypt%'
order by 1,2

-- look at highest infection rate compared to population
select location,population,max(total_cases) as highestinfectionCount,max((total_cases/population))*100 as populationpercentageinfected
from CovidDeaths 
group by location,population
order by populationpercentageinfected desc
-- countries with highest death rate per population
select location, max(cast(total_deaths as int)) as total_deathcount
from CovidDeaths 
where continent is null -- to get the right locations
group by location
order by total_deathcount desc

--- group by continent

-- showing contintents with the highest death count
select continent, max(cast(total_deaths as int)) as total_deathcount
from CovidDeaths 
where continent is not null -- to get the right locations
group by continent
order by total_deathcount desc

-- global numbers

SELECT date,sum(new_cases) as totalcases ,sum(cast(new_deaths as int)) as totalDeath 
,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage  --,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths 
where continent is not null
group by date
order by 1,2
-- across the world death percentage
SELECT sum(new_cases) as totalcases ,sum(cast(new_deaths as int)) as totalDeath 
,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage  
from CovidDeaths 
where continent is not null
order by 1,2

--- joining vaccination table to death table
--using cte
with PopvsVac (continent,location,date,population,rolling_people_vaccinated,new_vaccinations)
as
(
select death.continent ,death.location,death.date,death.population,vaccinate.new_vaccinations,
sum(convert(bigint,vaccinate.new_vaccinations  )) over (partition by vaccinate.location order by vaccinate.location,vaccinate.date) as rolling_people_vaccinated
from  CovidDeaths death join CovidVaccinations vaccinate
on death.location = vaccinate.location
and death.date = vaccinate.date
where death.continent is not null
)
select *,(rolling_people_vaccinated/population)*100 as a from PopvsVac



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


----temp table

create table #populationvaccinated
(
continent nvarchar(255),
location  nvarchar(255) ,
date datetime ,
population numeric,
rolling_people_vaccinated numeric,
new_vaccinations numeric
)
 
insert into #populationvaccinated
select death.continent ,death.location,death.date,death.population,vaccinate.new_vaccinations,
sum(convert(bigint,vaccinate.new_vaccinations  )) over (partition by death.location order by death.location,death.date) as rolling_people_vaccinated
from  CovidDeaths death join CovidVaccinations vaccinate
on death.location = vaccinate.location
and death.date = vaccinate.date
where death.continent is not null

