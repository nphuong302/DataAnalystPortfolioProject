-- Looking at Total Cases and Total Deaths


select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_project..CovidDeaths$
order by location, date;

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Portfolio_project..CovidDeaths$
where date like '%2020%' and location = 'Vietnam'
order by location, date;

select location, date, total_cases, total_deaths, top 1 (select (total_deaths/total_cases)*100 as max_percent
from Portfolio_project..CovidDeaths$)
from Portfolio_project..CovidDeaths$
where location = 'Vietnam';
