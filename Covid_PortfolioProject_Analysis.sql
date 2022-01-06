
Select *
From PortfolioProject..covidDeaths
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..covidVaccinations
--Order by 3,4

--Selecting the key data

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covidDeaths
where continent is not null
Order by 1,2

--Total number of Cases Vs Total Number of Death

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..covidDeaths
Where location like '%states%'
where continent is not null
Order By 1,2

--Total cases Vs population

Select location, date, population, total_cases, (population/total_cases)*100 AS PercentPopulationInfected
From PortfolioProject..covidDeaths
--Where location like '%states%'
where continent is not null
Order By 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

Select location, population, max(total_cases) As HighestInfectionCount, max((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..covidDeaths
--Where location like '%states%'
where continent is not null
Group By location, population
Order By PercentPopulationInfected desc

--Showing Countries with Highest Death Count

Select location, population, Max(CAST(total_deaths AS int)) as HighestDeathCount
From PortfolioProject..covidDeaths
--Where location like '%states%'
where continent is not null
Group By location, population
Order By HighestDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT

Select continent, Max(CAST(total_deaths AS int)) as HighestDeathCount
From PortfolioProject..covidDeaths
--Where location like '%states%'
where continent is not null
Group By continent
Order By HighestDeathCount desc

--Global Numbers

Select date, Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/ Sum(new_cases)*100 As
DeathPercentage
From PortfolioProject..covidDeaths
Where continent is not null
Group by date
Order by 1,2

--Looking at Total Population Vs Vaccination

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
Sum(cast(vaccine.new_vaccinations as int)) Over (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..covidDeaths death
Join PortfolioProject..covidVaccinations vaccine
	On death.location = vaccine.location
	And death.date = vaccine.date
Where death.continent is not null
Order by 2,3
-- The Above Couldn't run because I need a Temporary Table. We can resolve this by using CTE or Temp Table.

--Using CTE

with PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
Sum(cast(vaccine.new_vaccinations as int)) Over (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..covidDeaths death
Join PortfolioProject..covidVaccinations vaccine
	On death.location = vaccine.location
	And death.date = vaccine.date
Where death.continent is not null
--Order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From PopVsVac


--Using Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated  numeric
)

Insert Into #PercentPopulationVaccinated

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
Sum(Convert(int,vaccine.new_vaccinations/100)) Over (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..covidDeaths death
Join PortfolioProject..covidVaccinations vaccine
	On death.location = vaccine.location
	And death.date = vaccine.date
Where death.continent is not null
--Order by 2,3

Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating View for Visualization

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
Sum(cast(vaccine.new_vaccinations as int)) Over (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..covidDeaths death
Join PortfolioProject..covidVaccinations vaccine
	On death.location = vaccine.location
	And death.date = vaccine.date
Where death.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated
