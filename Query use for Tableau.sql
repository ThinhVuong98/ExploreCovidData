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


