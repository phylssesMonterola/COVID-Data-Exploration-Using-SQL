/*
Skills used on this project:
-Joins
-CTE
-Temp Tables
-Creating Views
*/


/*Every column of COVID_Deaths_Data arranged by location (alphabetical) and date (chronological). Rows that have null values for their 'continent' are excluded and therefore not shown*/
Select *
From COVID_Data_Exploration_Project.dbo.COVID_Deaths_Data	--Select all the rows of our COVID_Deaths_Data import
Where continent is not null	--rows that don't have a null value under 'continent' are returned
order by 3,4 --columns 'location' and 'date' are addressed according to their column order number and the output is arranged according to it


/*This time, only location, date, total_cases, new_cases, total_deaths, & population will be shown.*/
Select Location, date, total_cases, new_cases, total_deaths, population
From COVID_Data_Exploration_Project.dbo.COVID_Deaths_Data --Returns the columns location, date, total_cases, new_cases, total_deaths, population of COVID_Deaths_Data import 
Where continent is not null  --rows that don't have a null value under 'continent' are returned
order by 1,2 --arranges the results according to location and date. They are addressed by their column order in the select statement


/*This section explores PERCENTAGE OF DEATH TO COVID IN THE PHILIPPINES using total_deaths over total_cases*/
alter table [Covid_Deaths_Data] alter column [total_cases] float --during our import process. Data type assignation was not properly implemented which causes the formula used later to return an unwanted result. Using this script resolves that issue. Basically, we changed the data type from whatever it was initally into a 'float'
alter table [Covid_Deaths_Data] alter column [total_deaths] float
Select Location, date, total_cases,total_deaths, --returns the columns Location, date, total_cases, total_deaths from COVID_Deaths_Data import (Total Cases vs Total Deaths)
	   round((total_deaths/total_cases)*100, 2) as DeathPercentage --this is a 'customized' column that follows a formula, we give this column an alias DeathPercentage, this too is returned as an output (Shows likelihood of dying if you contract covid in your country). round() basically rounds off our decimal places into 2, hence a 2 right there.
From COVID_Data_Exploration_Project.dbo.COVID_Deaths_Data
Where location like '%pines%' -- we used '%' wildcard symbol to help us find and return rows that have Location with 'pines' as their value
  and continent is not null --rows that don't have a null value under 'continent' are returned
order by 1,2 --arranges the results according to location and date. They are addressed by their column order in the select statement


/*This section explores TOTAL COVID CASES OVER A COUNTRY'S POPULATION IN PERCENTAGE*/
Select Location, date,
       Population, total_cases,  --(total cases vs population)
	   round((total_cases/population)*100, 2) as PercentPopulationInfected --another 'custom column'. Helps us see the percentage of the population that got infected by COVID
From COVID_Data_Exploration_Project.dbo.COVID_Deaths_Data
Where location like '%pines%'
order by 1,2


/*Returns the ranking of Countries which have the highest percentage of infected based on population ever recorded. Each country will only have one entry*/
Select Location, Population, 
       MAX(total_cases) as HighestInfectionCount,  --returns the highest number of infected ever recorded in a certain country
	   round(Max((total_cases/population))*100, 2) as PercentPopulationInfected --returns the percentage of total cases infected over the population
From COVID_Data_Exploration_Project.dbo.COVID_Deaths_Data
--Where location like '%pines%'
Group by Location, Population
order by PercentPopulationInfected desc --arranges the result based on which country got the highest infected at the top
--order by HighestInfectionCount desc


/*This section explores which country has a HIGHER DEATH COUNT BASED ON POPULATION*/
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount --is it converted because there are values that are quite big, they're  bigint?
From COVID_Data_Exploration_Project.dbo.COVID_Deaths_Data
--Where location like '%pines%'
Where continent is not null 
Group by Location --[I have an aggregate function as one of my columns, does it mean I should use a GROUP BY?]
order by TotalDeathCount desc


/*This section shows the highest death count of each continent*/
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From COVID_Data_Exploration_Project.dbo.COVID_Deaths_Data
Where continent is not null 
Group by continent
order by TotalDeathCount desc


/*Shows the overall total_cases, overall total_deaths, and the total_deaths over total_cases ratio (shown as percentage of course)*/
Select SUM(new_cases) as total_cases, 
       SUM(cast(new_deaths as int)) as total_deaths, 
	   round(SUM(cast(new_deaths as int))/SUM(New_Cases)*100, 2) as DeathPercentage
From COVID_Data_Exploration_Project.dbo.COVID_Deaths_Data
where continent is not null 
order by 1,2


/*Joining COVID_Deaths_Data & COVID_Vaccinations_Data. Applying Aliasing to specify which columns to take from which table*/
Select dea.continent, 
	   dea.location, 
	   dea.date,
	   dea.population, --dea is our alias for COVID_Deaths_Data
       vac.new_vaccinations,  --vac is our alias for COVID_Vaccination_Data
	   SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location 
	                                                    Order by dea.location, 
  														         dea.Date) as RollingPeopleVaccinated --rolling sum. Takes the previous new_vaccinations data then adding it to the recent, sum is assigned to RollingPeopleVaccinated
From COVID_Data_Exploration_Project.dbo.COVID_Deaths_Data dea
Join COVID_Data_Exploration_Project.dbo.COVID_Vaccination_Data vac
	On dea.location = vac.location --remember that both COVID_Deaths_Data and COVID_Vaccinations_Data have the same values in their location and date columns
   and dea.date = vac.date
where dea.continent is not null 
order by 2,3


/*Turning the previous query into a CTE */
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, 
       dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From COVID_Data_Exploration_Project.dbo.COVID_Deaths_Data dea
Join COVID_Data_Exploration_Project.dbo.COVID_Vaccination_Data vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, round(cast((RollingPeopleVaccinated/Population)*100 as float), 2) --returns all the columns in PopvsVac and Rolling People Vaccinated over Population percentage. This does not have a column name/alias
From PopvsVac --referencing PopvsVac CTE
/*Remember that in CTE's, you have to run the CTE code and not just the select statement only*/


/*We did CTEs previously, this time we do it using Temp Tables*/
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, 
	   dea.location, 
	   dea.date, dea.population, 
	   vac.new_vaccinations, 
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From COVID_Data_Exploration_Project.dbo.COVID_Deaths_Data dea
Join COVID_Data_Exploration_Project.dbo.COVID_Vaccination_Data vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, round(cast((RollingPeopleVaccinated/Population)*100 as float), 2)
From #PercentPopulationVaccinated