SELECT * FROM ProjectDA..['CovidDeaths'] 
where continent is not null order by 3,4

SELECT * FROM ProjectDA..CovidVaccinations order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
FROM ProjectDA..['CovidDeaths'] 
where location like '%India%'
order by 1,2

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercent
FROM ProjectDA..['CovidDeaths'] 
where location like '%India%'
order by 1,2

select Location,date,population,total_cases ,(total_cases/population)*100 as InfectedPercent
FROM ProjectDA..['CovidDeaths'] 
where location like '%India%'
order by 1,2

select Location,population,MAX(total_cases) as HighestInfectionCount ,MAX((total_cases/population))*100 as HighestInfectionPercent
FROM ProjectDA..['CovidDeaths'] 
group by Location , population
order by HighestInfectionPercent desc

select Location , MAX(cast(total_deaths as int)) as HighestDeathCount 
FROM ProjectDA..['CovidDeaths'] 
where continent is null
group by Location 
order by HighestDeathCount desc

--global numbers

select date,SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
FROM ProjectDA..['CovidDeaths'] 
where continent is not null
group by date 


select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
FROM ProjectDA..['CovidDeaths'] 
where continent is not null


with PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT d.continent , d.location, d.date,d.population,v.new_vaccinations ,
SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location order by d.location , d.date)
as RollingPeopleVaccinated
FROM ProjectDA..['CovidDeaths']  d
 JOIN ProjectDA..['CovidVaccinations']  v
 on d.date=v.date 
 and d.location=v.location
where d.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/Population)*100 as VaccinatedPercent
from PopvsVac

--TEMP Table

Drop table if exists #PeopleVaccinated
CREATE TABLE #PeopleVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

 INSERT INTO #PeopleVaccinated
 SELECT d.continent , d.location, d.date,d.population,v.new_vaccinations ,
SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location order by d.location , d.date)
as RollingPeopleVaccinated
FROM ProjectDA..['CovidDeaths']  d
 JOIN [ProjectDA].[dbo].[CovidVaccinations]  v
 on d.date=v.date 
 and d.location=v.location
--where d.continent is not null
select * ,(RollingPeopleVaccinated/Population)*100 as VaccinatedPercent
from #PeopleVaccinated

--VIEW

CREATE VIEW PeopleVaccinated 
AS 
SELECT d.continent , d.location, d.date,d.population,v.new_vaccinations ,
SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location order by d.location , d.date)
as RollingPeopleVaccinated
FROM ProjectDA..['CovidDeaths']  d
 JOIN [ProjectDA].[dbo].[CovidVaccinations]  v
 on d.date=v.date 
 and d.location=v.location
 where d.continent is not null

 SELECT * FROM PeopleVaccinated
