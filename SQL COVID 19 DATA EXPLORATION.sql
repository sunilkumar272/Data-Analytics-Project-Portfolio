/* SQL COVID 19 DATASET EXPLORARION */


/*Selecting all the data from Covid Deaths dataset*/

SELECT *
FROM CovidDeathData;


/*Selecting all the data from Covid Vaccinations dataset*/

SELECT *
FROM CovidVaccData;


/*Selecting Top 10 countries list with highest number of Covid cases */

SELECT TOP(10) Location, MAX(total_cases)  as TotalCaseCount
FROM CovidDeathData
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalCaseCount Desc;


/*Selecting Top 10 countries list with highest number of Covid Deaths */

SELECT TOP(10) Location, MAX(cast(total_deaths as INT))  as TotalDeathCount
FROM CovidDeathData
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount Desc;



/*Query to get the infected percentage of the population in the Country India based on date*/

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 as InfectionPercentage
FROM CovidDeathData
WHERE location='India'
ORDER BY date;



/*Query to get the death percentage out of total cases of the population in the Country India based on date*/

SELECT Location, date, Population, total_cases,  (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeathData
WHERE location='India'
ORDER BY date;



/*Query to get total vaccinations count across all the countries according to date*/

SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations AS BIGINT)) OVER (Partition by death.Location Order by death.location, death.Date) AS CurrentVaccinationCount
FROM CovidDeathData AS death
Join CovidVaccData  AS vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent is not null 
ORDER BY 2,3;



/*Querying to get total vaccinations count across Asia according to date*/

SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations AS BIGINT)) OVER (Partition by death.Location Order by death.location, death.Date) AS CurrentVaccinationCount
FROM CovidDeathData AS death
JOIN CovidVaccData  AS vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent = 'Asia'
ORDER BY 2,3;



/* Creating a view to get total vaccinations count across all locations */

CREATE VIEW VaccinationCount AS
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations AS BIGINT)) OVER (Partition by death.Location Order by death.location, death.Date) AS CurrentVaccinationCount
FROM CovidDeathData AS death
JOIN CovidVaccData  AS vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL;




/*Query to get hospitalized percentage of people affected by COVID across all the locations using CTE*/


WITH hospercent (Location,date, total_cases, hosp_patients,CurrentHospitalizedCount, CurrentCaseCount)
AS
(SELECT Location, date, total_cases, hosp_patients, 
SUM(CAST(hosp_patients AS BIGINT)) OVER (Partition by Location Order by location, Date) AS CurrentHospitalizedCount,
SUM(total_cases) OVER (Partition by Location Order by location, Date) AS CurrentCaseCount
FROM CovidVaccData
WHERE continent IS NOT NULL)
SELECT *,(CurrentHospitalizedCount/CurrentCaseCount)*100 AS HospitalizedPercentage
FROM hospercent;




/*Query to get hospitalized percentage of people affected by COVID in UnitedStates using CTE*/


WITH hospercent (Location,date, total_cases, hosp_patients,CurrentHospitalizedCount, CurrentCaseCount)
AS
(SELECT Location, date, total_cases, hosp_patients, 
SUM(CAST(hosp_patients AS BIGINT)) OVER (Partition by Location Order by location, Date) AS CurrentHospitalizedCount,
SUM(total_cases) OVER (Partition by Location Order by location, Date) AS CurrentCaseCount
FROM CovidVaccData
WHERE Location = 'United States')
SELECT *,(CurrentHospitalizedCount/CurrentCaseCount)*100 AS HospitalizedPercentage
FROM hospercent;






