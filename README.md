# Projects:
> (followed a FreeCodeCamp.org tutorial called 'Data Analysis Bootcamp' hosted by 'Alex the Analyst')

## Covid Analysis-Data Exploration.sql
> The data I used is located in CovidDeaths.xlsx and CovidVaccinations.xlsx

Used SQL to analyze Covid data. Looked at things like countries with the highest rates of infection per population, countries with the highest death count per population, and continents with the highest death count per population. 

**What I Learned:**

How to create temporary tables, How to create views, What common table expressions(CTEs) are and how to create them. I also dealt with an interesting additional challenge in that my dataset had an additional 2 years worth of data. When I went to create rolling totals, for example, I ran into issues with the data type not being large enough to hold the data I needed it to. Long story short, I used the cast and convert functions a lot as well as bigint.

Example of Creating a View:  

`CREATE VIEW PercentPopulationVaccinated AS`  
  `SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,`  
  `SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated`  
  `FROM CovidAnalysis..CovidDeaths dea`  
  `JOIN CovidAnalysis..CovidVaccinations vac`  
	  `ON dea.location = vac.location and`  
	  `dea.date = vac.date`  
  `WHERE dea.continent IS NOT NULL`  

## Nashville Housing-Data Cleaning.sql
> The table that I cleaned is NashvilleHousingDataDataCleaning.xlsx  

Used SQL to reformat the data in an Excel spreadsheet to make it more readable. It was a great refresher on making updates to SQL tables.

**What I Learned:** 

How to use Parsename function, how to join a table on itself and where that
might be useful. This exercise was mostly a great refresher on what I already knew of SQL
