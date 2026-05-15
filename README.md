# AutoTrader Car Price Scraper & Analyzer
Course: STAT 260, Spring 2024

## Overview
This repository contains an R script (`proj1c.R`) designed to scrape car listings from AutoTrader.ca and perform exploratory data analysis. The project extracts vehicle data (brand, year, odometer, price, and location) from search results based on self-specified filters and visualizes the relationship between vehicle depreciation, mileage, and age.

## Features
* **Automated Web Scraping:** Iterates through pagination on AutoTrader.ca to extract multiple pages of car listings using `rvest`.
* **Data Cleaning & Transformation:** Parses raw HTML data to isolate numerical values for price, year, and odometer readings using string manipulation in `tidyverse`.
* **Data Export:** Saves the cleaned and aggregated dataset to a local CSV file (`carprice.csv`) for future use or external analysis.
* **Exploratory Data Visualization:** Uses `ggplot2` and `gridExtra` to generate comparative plots, specifically focusing on:
  * Selling price versus mileage (odometer).
  * Selling price versus the age/manufacturing year of the vehicle.
  * Depreciation trend comparisons across self-specified brands (MINI, Nissan, Toyota, Hyundai, Honda).
 
<img width="60%" alt="image" src="https://github.com/user-attachments/assets/f57c2963-5eaa-4b57-8306-c8a5accdb06b" />

<img width="75%" alt="image" src="https://github.com/user-attachments/assets/00cb8247-c874-43ad-a498-8398cf59b323" />
