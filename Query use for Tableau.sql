--Queries used for Tableau Project

-- 1.Global Cases and Deaths

Select sum(cast(new_cases as decimal)) as GlobalCase, sum(cast(new_deaths as decimal)) as GlobalDeath,
	cast(sum(cast(new_deaths as decimal))/sum(cast(new_cases as decimal)) * 100 as decimal(16,2)) as GlobalDeathPercent
From CovidProject..cases
Where continent is not Null



-- 2.Cases and Deaths by Continent

Select location ,sum(cast(new_cases as numeric)) as Cases, sum(cast(new_deaths as numeric)) as Deaths,
	cast(sum(cast(new_deaths as numeric))/sum(cast(new_cases as numeric)) * 100 as decimal(16,2)) as DeathPercent
From CovidProject..cases
Where continent is Null
	and location not in ('World', 'European Union', 'International')
Group by location
Order by Cases desc


-- 3.Percent population infected by country

Select location, population, max(total_cases) as TotalCases, 
	cast((max(total_cases)/population) * 100 as decimal(16,2)) as InfectedPercent
From CovidProject..cases
Where continent is not Null
Group by location, population
Order by InfectedPercent desc



-- 4.Percent population infected over time by country

Select location, date, population, max(cast(total_cases as numeric)) as TotalCases,
	cast(max(cast(total_cases as decimal))/population* 100 as decimal(16,2)) as InfectedPercent
From CovidProject..cases
Where continent is not Null
Group by location, date, population
Order by location, date



-- 5.Total population and cases in Vietnam

Select location, population, max(total_cases) as TotalCases, 
	cast((max(total_cases)/population) * 100 as decimal(16,2)) as InfectedPercent
From CovidProject..cases
Where continent is not Null
	and location like 'Vietnam'
Group by location, population



-- 6.Vaccination and Population in Vietnam

Select cas.location, cas.population, max(vac.total_vaccinations) as TotalVaccination, 
	cast(max(vac.total_vaccinations)/population as decimal(16,2)) as VaccinatedPercent, 
	cast(1-max(vac.total_vaccinations)/population as decimal(16,2)) as UnvaccinatedPercent
From CovidProject..cases as cas
Join CovidProject..vaccination as vac
	on cas.location = vac.location
	and cas.date = vac.date
Where cas.continent is not Null
	and cas.location like 'Vietnam'
Group by cas.location, cas.population	



-- 7.7 days moving average of infection case in Viet Nam
Select location, date, total_cases, new_cases,
	cast(avg(new_cases) over (partition by (location) order by location, date rows between 7 preceding and current row) as int) as '7DaysMovingAvg'
From CovidProject..Cases
Where continent is not null
	and Location like 'Vietnam'
Order by date



