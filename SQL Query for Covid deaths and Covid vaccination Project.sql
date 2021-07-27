--MY COVID PROJECT

SELECT * FROM
PortfolioProject..CovidDeaths
where continent is not null

--SELECT *
--FROM PortfolioProject..CovidVaccination

SELECT location, date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
Order by 1,2

--Total Cases vs Total Deaths
--shows likelihood of dying in India

SELECT location, date,new_cases,total_cases,total_deaths,round((total_deaths/total_cases)*100,2) As DeathPercentage
from CovidDeaths
where location='India' AND continent is not null
Order by 1,2


--Total Cases vs Population
--shows what percentage of population got Covid in INDIA or world

SELECT location, date,population,total_cases,round((total_cases/population)*100,2) As PercentPopulationInfected
from CovidDeaths
--where location='India'
where continent is not null
Order by 1,2


--Country with highest infection rate

SELECT location,population,max(total_cases)as HighestInfectionCount,round(max((total_cases/population)*100),2) As PercentPopulationInfected
from CovidDeaths
--where location='India'
where continent is not null
Group by location,population
Order by PercentPopulationInfected desc

--Continent with highest Death Count per population

SELECT location,population,max(cast(total_deaths as int))as TotalDeathCount
from CovidDeaths
--where location='India'
where continent is null
Group by location,population
Order by TotalDeathCount desc


-- PATTERN LOOKING AT CONTINENT

SELECT continent,max(cast(total_deaths as int))as TotalDeathCount
from CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global Numbers

--new cases vs new deaths per day

SELECT date,sum(new_cases)AS TotalCases,SUM(cast(new_deaths AS int)) AS TotalDeaths,(SUM(CAST(new_deaths as int))/SUM(new_cases)*100)As DeathPercentage
from CovidDeaths
--where location='India' AND 
where continent is not null
GROUP BY date
Order by 1,2

--Total Cases vs Total Deaths And Death Percentage

SELECT sum(new_cases)AS TotalCases,SUM(cast(new_deaths AS int)) AS TotalDeaths,(SUM(CAST(new_deaths as int))/SUM(new_cases)*100)As DeathPercentage
from CovidDeaths
where continent is not null
--GROUP BY date
Order by 1,2



--USING CTE

--Total population vs Total vaccination

With PopvsVac (continent,location,date,population,new_vaccinations,TotalVaccinatedPeople)
AS
(
Select Dea.continent,Dea.location,Dea.date,population,new_vaccinations, SUM(Convert(int,vac.new_vaccinations))
OVER (PARTITION BY Dea.location Order by Dea.location,Dea.date) TotalVaccinatedPeople
from CovidDeaths AS Dea
Join CovidVaccination AS Vac
On Dea.location=Vac.location
AND Dea.date=Vac.date
where Dea.continent is Not NUll
--ORDER by 2,3
)
select *,(TotalVaccinatedPeople/Population)*100 from PopvsVac


--USING TEMP TABLE

create table #PercentPopulationVaccinated
(continent varchar(90),
location varchar(90),
date date,
population numeric,
new_vaccination numeric,
TotalVaccinatedPeople numeric)

insert into #PercentPopulationVaccinated
Select Dea.continent,Dea.location,Dea.date,population,new_vaccinations, SUM(Convert(int,vac.new_vaccinations))
OVER (PARTITION BY Dea.location Order by Dea.location,Dea.date) TotalVaccinatedPeople
from CovidDeaths AS Dea
Join CovidVaccination AS Vac
On Dea.location=Vac.location
AND Dea.date=Vac.date
where Dea.continent is Not NUll
--ORDER by 2,3


select *,(TotalVaccinatedPeople/Population)*100 from #PercentPopulationVaccinated


--creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
Select Dea.continent,Dea.location,Dea.date,population,new_vaccinations, SUM(Convert(int,vac.new_vaccinations))
OVER (PARTITION BY Dea.location Order by Dea.location,Dea.date) TotalVaccinatedPeople
from CovidDeaths AS Dea
Join CovidVaccination AS Vac
On Dea.location=Vac.location
AND Dea.date=Vac.date
where Dea.continent is Not NUll
--ORDER by 2,3

select * from PercentPopulationVaccinated



