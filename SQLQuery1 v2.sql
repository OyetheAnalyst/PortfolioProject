
SELECT *
FROM PortfolioProject..coviddeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..covidvaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Coviddeaths
WHERE continent is not null
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATH

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
WHERE LOCATION LIKE '%NIGERIA%'
and continent is not null
order by 1,2
 --1% LIKELIHOOD OF DYING IF YOU CONTACT COVID-19 IN NIGERIA

--TOTAL CASES VS POPULATION

Select location, date, population, total_cases, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS percentpopulationinfected
from PortfolioProject..covidDeaths
WHERE LOCATION LIKE '%NIGERIA%'
and continent is not null
order by 1,2
-- SHOWS THE PERCENTAGE OF THE POPULATION THAT HAS CONTACTED COVID-19

--CREATING VIEW FOR VISUALIZATION
CREATE VIEW percentcountrypopulationinfected AS
Select location, date, population, total_cases, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS percentpopulationinfected
from PortfolioProject..covidDeaths
WHERE LOCATION LIKE '%NIGERIA%'
and continent is not null
--order by 1,2
--COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED WITH THE POPULATION

Select location, population, MAX(total_cases) AS Highestinfectioncount, 
MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS percentpopulationinfected
from PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY location, population 
order by percentpopulationinfected DESC

--CREATING VIEWS FOR VISUALIZATION
CREATE VIEW percentpopulationinfected AS
Select location, population, MAX(total_cases) AS Highestinfectioncount, 
MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS percentpopulationinfected
from PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY location, population 
--order by percentpopulationinfected DESC



--COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

Select location, MAX(CAST(total_deaths as int)) AS TotatDeathcount
from PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY location
order by TotatDeathcount DESC

--CREATING VIEW FOR VISUALIZATION

CREATE VIEW Countriesdeathcount AS
Select location, MAX(CAST(total_deaths as int)) AS TotatDeathcount
from PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY location
--order by TotatDeathcount DESC


--SHOWING DEATH COUNT BY CONTINENTS


Select continent , MAX(CAST(total_deaths as int)) AS TotatDeathcount
from PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY continent
order by TotatDeathcount DESC

--CREATING VIEW FOR VISUALIZATION

CREATE VIEW TotalDeathcount AS
Select continent , MAX(CAST(total_deaths as int)) AS TotatDeathcount
from PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY continent
--order by TotatDeathcount DESC



--GLOBAL NUMBERS

Select SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths , 
SUM(CAST(new_deaths as int)) / NULLIF(SUM(new_cases),0)*100 AS Deathpercentage
from PortfolioProject..covidDeaths
--WHERE LOCATION LIKE '%NIGERIA%'
where continent is not null
--GROUP BY date
order by 1,2


--TOTAL POPULATION VS VACCINATION PER COUNTRY
-- USING CTE

with PopvsVac (continent,location,date,population,new_vaccinations,peoplevaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS peoplevaccinated
 --(peoplevaccinated/population)*100
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--AND vac.location LIKE '%NIGERIA%'
--ORDER BY 1,2,3
)
SELECT *, (peoplevaccinated/population)*100 AS percentageofpopulationvaccinated
FROM PopvsVac

--USING TEMP TABLE

DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
peoplevaccinated numeric
)
INSERT INTO #percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS peoplevaccinated
 --(peoplevaccinated/population)*100
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--AND vac.location LIKE '%NIGERIA%'
--ORDER BY 1,2,3
SELECT *, (peoplevaccinated/population)*100 AS percentageofpopulationvaccinated
FROM #percentpopulationvaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS peoplevaccinated
 --(peoplevaccinated/population)*100
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--AND vac.location LIKE '%NIGERIA%'
--ORDER BY 1,2,3

SELECT *
FROM percentpopulationvaccinated