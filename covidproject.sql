-- Covid Analysis from Jan 2020 to April 2021 majorly focused on India
-- used Joins, subqueries, CTEs, Ranks, StoredProcedures, Group by's, Running total and other query commands   

create database sql_project;

use sql_project;
set sql_safe_updates =0;

-- Necessary modifications to the tables   

select * from coviddeaths;
update coviddeaths set total_deaths = null where total_deaths = '';
alter table coviddeaths rename column ï»¿iso_code to iso_code;
alter table coviddeaths drop new_tests,
						drop total_tests,
						drop total_tests_per_thousand,
						drop new_tests_smoothed,
						drop new_tests_smoothed_per_thousand,
                        drop positive_rate,
                        drop tests_per_case,
                        drop tests_units,
                        drop total_vaccinations,
                        drop people_vaccinated,
                        drop new_vaccinations,
                        drop new_vaccinations_smoothed,
                        drop total_vaccinations_per_hundred,
                        drop people_vaccinated_per_hundred,
                        drop people_fully_vaccinated_per_hundred,
                        drop new_vaccinations_smoothed_per_million;
                        
select * from covidvaccinations;
alter table covidvaccinations rename column ï»¿iso_code to iso_code;

alter table coviddeaths modify date date;
select year(date) from covidvaccinations;

-- fetching total cases VS total deaths and death percentage -month wise 

select location, concat(monthname(date),' ', year(date)) as date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as 'death%' 
from coviddeaths where location = 'India' order by 1;

-- Covid% month wise   

select location, concat(monthname(date),' ', year(date)) as date, total_cases, population, round((total_cases/population)*100,2) as 'covid%'
from coviddeaths where location = 'india';

-- highest covid wrt population country wise

select location, max(total_cases) as highestinfectction, population, round(max(total_cases/population)*100,2) as covid 
from coviddeaths group by location, population order by covid desc;

-- highest deathcount per population country wise

select location, max(convert(total_deaths,unsigned)) deathcount from coviddeaths 
group by location order by deathcount desc;

-- continent wise

select continent, max(cast(total_deaths as unsigned)) deathcount from coviddeaths
group by continent
order by deathcount desc;

-- new cases and new deaths day wise in india
 
 select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths from coviddeaths 
 group by date 
 order by date asc;
 
 --  count of people vaccinated
 
 select d.location,d.date, cast(new_vaccinations as signed) as vaccinated , 
 sum(cast(new_vaccinations as signed)) over (PARTITION BY d.location order by d.location, d.date) runningtotal
 from coviddeaths d join covidvaccinations v 
 on d.location = v.location and d.date = v.date 
 where d.location = 'india'
order by 1,2;

-- percentage of people vaccinated using CTE method

with vac (location,date,population,vaccinated,runningtotal)
as
(
select d.location, d.date, population, cast(new_vaccinations as signed) vaccinated, 
sum(cast(new_vaccinations as signed)) over (partition by d.location order by d.location, d.date) as runningtotal
from coviddeaths as d join covidvaccinations as v 
on d.location = v.location and d.date = v.date
)
select *, runningtotal/population *100 from vac;

-- ranking countrys based on vaccinations

with ranks 
as (
select location, max(cast(total_vaccinations as signed))as vaccinations from covidvaccinations group by location
)
select *,ROW_NUMBER () over (order by vaccinations desc) as rankings from ranks;


-- Fetching every details of a specified given country as a parameter using Stored Procedures
 
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `country`(par_country varchar(40))
-- BEGIN
-- select d.iso_code, d.location, year(d.date), monthname(d.date), sum(cast(new_cases as signed)) cases, sum(cast(new_deaths as signed)) deaths, 
-- sum(cast(new_tests as signed))tests,sum(cast(new_vaccinations as signed)) vaccinations, d.population
-- from coviddeaths  d join covidvaccinations v
-- on d.date= v.date and d.location = v.location
-- where d.location = par_country 
-- group by d.location, d.iso_code, d.population, year(d.date), monthname(d.date);

-- END

call country('india');