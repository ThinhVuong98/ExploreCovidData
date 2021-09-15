-- Query to explore data about Covid19 from https://ourworldindata.org/coronavirus

-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



-- 1.Select Data we are going to be starting with

Select location, date, total_cases, new_cases
From CovidProject..cases
Where continent is not Null
Order by location, date



-- 2.Total Cases vs Total Death
-- See how well the countries deals with infected people over time

Select location, date, total_cases, total_deaths,
	cast((total_deaths/total_cases) * 100 as decimal(16,2)) as DeathPercent
From CovidProject..cases
Where continent is not Null
Order by location, date



-- 3.Total Cases vs Total Population up to now
-- See how well countries are preventing infections

Select location, max(total_cases) as TotalInfected, population,
	cast((max(total_cases)/population) * 100 as decimal(16,2)) as InfectedPercent
From CovidProject..cases
Where continent is not Null
Group by location, population
Order by InfectedPercent desc



-- 4.Using Store Procedure see 7 days moving average new cases of a specific country
-- See how is Covid trending in each country

Drop procedure if exists CovidTrend
Create procedure CovidTrend
	@CountryName varchar(255)
As
Select location, date, total_cases, new_cases,
	cast(avg(new_cases) over (partition by (location) order by location, date rows between 7 preceding and current row) as int) as '7DaysMovingAvg'
From CovidProject..Cases
Where continent is not null
	and Location like @CountryName
Order by location, date
Go
CovidTrend 'Vietnam'



-- 5.Total Vaccination vs Total Population
-- Show percentages of population vs doses of vaccine that has been injected over time

Select cas.location, cas.date, cas.population, vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by (vac.location) order by cas.location, cas.date) as RollingVacinatedCount
From CovidProject..Cases as cas
Join CovidProject..Vaccination as vac
	On cas.location = vac.location
	And cas.date = vac.date
Where cas.continent is not null
Order by cas.location, cas.date



-- 6.Using CTE to query the newly created columns in the previous Partition By query

With PopVsVac (Location, Date, Population, NewVaccinations, RollingVaccinatedCount)
As
(
Select cas.location, cas.date, cas.population, vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by (vac.location) order by cas.location, cas.date) as RollingVaccinatedCount
From CovidProject..Cases as cas
Join CovidProject..Vaccination as vac
	On cas.location = vac.location
	And cas.date = vac.date
Where cas.continent is not null
)
Select *,
	cast((RollingVaccinatedCount/Population) * 100 as decimal ( 16, 2)) as PercentageVaccinated 
From PopVsVac



-- 7.Using Temp Table to query the newly created columns in the previous Partition By query

Drop Table if exists #PopVsVac
Create table #PopVsVac 
(
Location varchar(255),
Date datetime,
Population numeric,
NewVaccination numeric,
RollingVaccinatedCount numeric,
)

Insert into #PopVsVac
Select cas.location, cas.date, cas.population, vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by (vac.location) order by cas.location, cas.date) as RollingVaccinatedCount
From CovidProject..Cases as cas
Join CovidProject..Vaccination as vac
	On cas.location = vac.location
	And cas.date = vac.date
Where cas.continent is not null

Select *,
cast((RollingVaccinatedCount/Population) * 100 as decimal ( 16, 2)) as PercentageVaccinated 
From #PopVsVac



-- 8.Creating View to store data

Create view RollingVaccination as
Select cas.location, cas.date, cas.population, vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by (vac.location) order by cas.location, cas.date) as RollingVacinatedCount
From CovidProject..Cases as cas
Join CovidProject..Vaccination as vac
	On cas.location = vac.location
	And cas.date = vac.date
Where cas.continent is not null
