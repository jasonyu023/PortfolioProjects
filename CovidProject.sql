-- Looking at Data

Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Where continent is not null and total_cases is not null
Order by 1,2

-- Total Cases vs Total Deaths in US

Select location, date, ISNULL(CAST(total_cases as bigint),0) as TotalCases, ISNULL(CAST(total_deaths as bigint),0) as TotalDeaths, (ISNULL(CAST(total_deaths as float),0)/(CAST(total_cases as float)))*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location = 'United States'
Order by 1,2

-- Total Cases vs Population in US

Select location, date, population, ISNULL(CAST(total_cases as bigint),0) as TotalCases, (ISNULL(CAST(total_cases as float),0)/CAST(population as float))*100 as PercentInfected
From CovidProject..CovidDeaths
Where location = 'United States'
Order by 1,2

-- Countries with Highest Infection Rate per Population

Select location, population, MAX(CAST(total_cases as bigint)) as HighestInfectionCount, MAX(CAST(total_cases as float)/(population))*100 as PercentInfected
From CovidProject..CovidDeaths
Where continent is not null
Group By location, Population
Order by 4 desc

-- Countries with Highest Death Count Count

Select location, MAX(CAST(total_deaths as bigint)) as TotalDeaths
From CovidProject..CovidDeaths
Where continent is not null
Group By location
Order by TotalDeaths desc

-- Total Cases by Continent

Select continent, SUM(MaxCases) as TotalCases
From (Select continent, MAX(CAST(total_cases as bigint)) as MaxCases
	From CovidProject..CovidDeaths
	Where continent is not null
	Group By continent, location) CStat
Group By continent
Order By TotalCases desc

-- Total Deaths by Continent
	--Used subquery to find the maximum total deaths for each country in each continent, then summed them together to get the total deaths per continent
Select continent, SUM(MaxDeaths) as TotalDeaths
From (Select continent, MAX(CAST(total_deaths as bigint)) as MaxDeaths
	From CovidProject..CovidDeaths
	Where continent is not null
	Group By continent, location) CStat
Group By continent
Order By TotalDeaths desc

--Global Numbers

Select date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as bigint)) as TotalDeaths, (SUM(CAST(new_deaths as bigint))/(SUM(new_cases))*100) as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null AND new_cases > 2
Group by date
Order by 1,2

--Total Population vs Vaccinations

Drop Table if exists #VaccinationRate
Create Table #VaccinationRate
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccinations numeric, RollingVaccinationCount numeric)

Insert into #VaccinationRate
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVacinationCount
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null

Select *, (RollingVaccinationCount/Population)*100 as VaccinationRate
From #VaccinationRate

--Create View VaccinationRate as
--Select dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated, (vac.people_vaccinated/dea.population)*100 as VaccinationRate
--From CovidProject..CovidDeaths dea
--Join CovidProject..CovidVaccinations vac
--	On dea.location = vac.location and dea.date = vac.date
--Where dea.continent is not null and vac.people_vaccinated is not null