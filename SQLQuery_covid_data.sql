--select data that we are going to use
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

---totalcases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percent
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--total cases vs population
select location,date,total_cases,population,(total_cases/population)*100 as case_percent
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--loooking at countries with highest infection rate compared to population
select location,population,max(total_cases) as hih,max((total_cases/population))*100 as highest_infection
from PortfolioProject..CovidDeaths
group by location,population
order by highest_infection desc

--highest death rates 
select location,max(cast (total_deaths as int)) as highestdeath_rates
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc

--highest deathrates by continent
select continent,max(cast (total_deaths as int)) as highestdeath_rates
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc

--showing continents with highest death count per population
select continent,max(cast (total_deaths as int)) as highest,max(total_deaths/population) as per
from PortfolioProject..CovidDeaths
where continent is not null
group by continent

--GLOBAL Numbers
select sum(new_cases) as totalcases,sum(cast (new_deaths as int)) as totaldeaths,sum(cast (new_deaths as int))/sum(new_cases) as death_percent
from PortfolioProject..CovidDeaths
where continent is not null

--looking total population vs vaccinations
select s.continent,s.location,s.date,s.population,s.new_vaccinations,s.rolling_vaccines,(s.rolling_vaccines/s.population)*100  as people_vaccinated
from(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rolling_vaccines
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)s
order by 2,3

--to create view
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

--to view view table
select * from PercentPopulationVaccinated
