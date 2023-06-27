--Covid DataSet Project

--Selecting the data to be used

select location, date, total_cases,new_cases,total_deaths,population
from  Portfolio_Porject..CovidDeaths
where continent is not null
order by 1,2

--Total cases Vs total deaths in Iraq (percentage of deaths )

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
from  Portfolio_Porject..CovidDeaths
where location like '%iraq%'
order by 1,2

--Total cases Vs population in Iraq (presentage of population that got infected)
select location, date,population, total_cases, (total_cases/population)*100 as 'New cases Percentage'
from  Portfolio_Porject..CovidDeaths
where location like '%iraq%'
order by 1,2

--countries with Highest infection rate compared to the population
select location, max(total_cases)highestInfectionCount, max((total_cases/population))*100 as 'NewCasesPercentage'
from  Portfolio_Porject..CovidDeaths
where continent is not null
group by population,location
order by NewCasesPercentage desc

--countries with highest death percentage compared to the population	
select location, Max(cast(total_deaths as int)) as 'highest Death Count', Max((total_deaths/population)*100) as 'Death percentage'
from CovidDeaths
where continent is not null
GROUP BY location
order by [Death percentage] desc

--countries with highest death count 
/*I used CAST because total deaths column type is nvarchar, which creates problems when used without
casting (the code will execute, but the results will be faulty)
*/
select location, Max(cast(total_deaths as int)) as 'highest Death Count'
from CovidDeaths
where continent is not null
GROUP BY location
order by [highest Death Count] desc

--continents with the highest death count
select location, Max(cast(total_deaths as int)) as 'Highest Death Count'
from CovidDeaths
where continent is null
GROUP BY location
order by [highest Death Count] desc

--Global total cases,total deaths, and death percentage (all grouped by date)
select date,sum(new_cases) Total_Cases, sum(cast(new_deaths as int)) Total_Deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

--Global total cases, total deaths, and death percentage
select sum(new_cases) Total_Cases, sum(cast(new_deaths as int)) Total_Deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from CovidDeaths
where continent is not null
order by 1,2


--joining CovidDeaths table with CovidVaccinations table 
select *
from CovidDeaths death
join CovidVaccinations vacc
on death.location=vacc.location 
and death.date=vacc.date
order by 3
 
 --Total population per country Vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) 
over(partition by dea.location order by dea.date) VaccinationsSUM
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
order by 2,3

-- the percentage of population that got vaccination(Using CTE)
with vacPercentage as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) 
over(partition by dea.location order by dea.date) VaccitationsSUM
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
)

select *,(VaccitationsSUM/population)*100 as Vaccpercentage
from vacPercentage
order by 2,3

-- Max no. of people that got vaccinatied per country (using Temp Table)
Drop table  if exists #MAXVAC
Create table #MAXVAC 
(
continent varchar(100),
location varchar(100),
population float,
MAXVaccinations float
)

insert into #MAXVAC 
select dea.continent,dea.location,dea.population,
Max(vac.new_vaccinations)
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
where dea.continent is not null 
group by dea.continent,dea.location,dea.population


select *,(MAXVaccinations/population)*100
from #MAXVAC
--where MAXVaccinations is not null
order by 4 desc


--Creating a View for visualizations
create view VvacPercentage as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) 
over(partition by dea.location order by dea.date) VaccitationsSUM
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 

select *
from VvacPercentage

