select * from 
PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * from 
--PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--total cases vs total deaths
select location,date,total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--max cases with max deaths
select location, max(cast(total_cases as int)) as casecount, max(cast(total_deaths as int)) as deathcount
from PortfolioProject..CovidDeaths
where continent is not null 
group by location 
order by 3 DESC

--total cases vs population
select location,date,population,total_cases,(total_cases/population)*100 as Covidpopulation
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--countries with highest infection rate compared to population

select location,population,max(total_cases) as Highestinfectioncount,max((total_cases/population))*100 as Infectedpopulation
from PortfolioProject..CovidDeaths
group by location,population
--where location like '%states%'
order by 4 DESC

--by continent

--count looks abrupt as NA not include canada values in it
--select continent,max(total_cases) as Highestinfectioncount,max((total_cases/population))*100 as Infectedpopulation
--from PortfolioProject..CovidDeaths
--group by continent
----where location like '%states%'
--order by 3 DESC

--continent with highest deaths
select location, max(cast(total_deaths as int)) as Highestdeathcount
from PortfolioProject..CovidDeaths
where continent is null
group by location
--where location like '%states%'
order by 2 desc

--countries with highest deaths compared to population
select location, max(cast(total_deaths as int)) as Highestdeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
--where location like '%states%'
order by 2 desc

--drill through continent and location for Maximum Infected cases
select continent, location, max(cast(total_cases as int)) as Infectedcasescount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent,location
--where location like '%states%'
order by 1,2

--Global count of death due to covid
--casting is used on new_deaths due to its nvarchar datetype which cant be aggregated

select year(date) as Year, sum(new_cases) as CasesGlobally ,sum(cast(new_deaths as int)) as DeathsGlobally,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by year(date)
order by 1,2

--Covid Vaccination
--total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from 
PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location 
	AND dea.date=vac.date
where dea.continent is not null
order by 2,3

--CTE (number of columns should be same as that of inner query)

with popvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from 
PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location 
	AND dea.date=vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 as Percentage
from
popvsVac

--Temptable

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
Rollingpeoplevaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from 
PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location 
	AND dea.date=vac.date
where dea.continent is not null

select *, (Rollingpeoplevaccinated/Population)*100 as Percentage
from #PercentPopulationVaccinated

--Create view to store data for later data visualizations

create view Globaldeathrates as
select year(date) as Year, sum(new_cases) as CasesGlobally ,sum(cast(new_deaths as int)) as DeathsGlobally,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by year(date)
--order by 1,2

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from 
PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location 
	AND dea.date=vac.date
where dea.continent is not null



