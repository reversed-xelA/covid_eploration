--Select *
--From covid_deaths

-- Select Data that we are going to be using

Select 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
From covid_deaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select 
	location, 
	date, 
	total_cases, 
	total_deaths,  
	(CAST (total_deaths AS FLOAT)/total_cases)*100 AS death_percentage
From covid_deaths
Where location = 'Australia'
order by 1,2

-- Looking at the total cases vs population 
-- Shows what percentage of the population got covid
Select 
	location, 
	date, 
	total_cases, 
	population,  
	(CAST (total_cases AS FLOAT)/population)*100 AS case_percentage
From covid_deaths
Where location = 'Australia'
order by 1,2


-- Looking at countries with highest infection rate compared to their population

Select 
	location, 
	population,
	date,
	MAX(total_cases) as highest_infection_count, 
	(MAX(CAST (total_cases AS FLOAT))/population)*100 AS population_infected_percent
From covid_deaths
Group by location, population, date
order by population_infected_percent desc


-- Showing the countries with the highest death toll per population
Select 
	location, 
	MAX(total_deaths) as total_death_count
From covid_deaths
Where continent is not null
Group by location
order by total_death_count desc

-- What about continents with highest death toll per pipulation?
--Select 
--	continent, 
--	MAX(total_deaths) as total_death_count
--From covid_deaths
----Where continent is not null
--Group by continent
--order by total_death_count desc

Select 
	location, 
	MAX(total_deaths) as total_death_count
From covid_deaths
Where continent is null
Group by location
order by total_death_count desc


-- Showing continents with the highest death count
Select 
	continent, 
	MAX(total_deaths) as total_death_count
From covid_deaths
Where continent is not null
Group by continent
order by total_death_count desc


-- GLOBAL NUMBERS

SELECT 
	date, 
	SUM(new_cases) as total_cases,
	SUM(new_deaths) as total_deaths,
	CASE 
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases))*100
    END AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT 
	SUM(new_cases) as total_cases,
	SUM(new_deaths) as total_deaths,
	CASE 
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases))*100
    END AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Getting a death count by continent and exluding those continents labeled as World, international and European Union (Europe exists as a label)

SELECT location, SUM(new_deaths) as total_deaths
FROM covid_deaths
WHERE continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY total_deaths desc


-- Looking at total population vs vaccinations

WITH popVSvax (continent, location, date, population, new_vaccinations, cumulative_vax)
AS
(
SELECT 
	covid_deaths.continent, 
	covid_deaths.location, 
	covid_deaths.date, 
	covid_deaths.population, 
	covid_vax.new_vaccinations,
	SUM(CAST(covid_vax.new_vaccinations AS BIGINT)) OVER (PARTITION BY covid_deaths.location ORDER BY covid_deaths.location, covid_deaths.date) AS cumulative_vax
FROM covid_deaths
JOIN covid_vax
	ON covid_deaths.location = covid_vax.location
	AND covid_deaths.date = covid_vax.date
WHERE covid_deaths.continent is not null
	--AND covid_deaths.location = 'Canada'
--ORDER BY 2,3
)
SELECT *, (CAST(cumulative_vax AS FLOAT)/population)*100 AS percent_pop_vaxed
FROM popVSvax
ORDER BY 2,3