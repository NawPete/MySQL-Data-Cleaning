# SQL Data Cleaning Project: Layoffs 2022 Dataset

## Table of Contents
- [Project Overview](#project-overview)
- [Dataset](#dataset)
- [Objectives](#objectives)
- [Data Cleaning Steps](#data-cleaning-steps)
  - [Step 1: Removing Duplicates](#step-1-removing-duplicates)
  - [Step 2: Standardizing Data](#step-2-standardizing-data)
  - [Step 3: Handling Null Values](#step-3-handling-null-values)
  - [Step 4: Removing Unnecessary Data](#step-4-removing-unnecessary-data)
- [Results](#results)
- [Conclusion](#conclusion)

---

## Project Overview

This project demonstrates the process of cleaning data in SQL using the Layoffs 2022 dataset, which details layoff events in various industries. Data cleaning is a critical step to ensure data quality, accuracy, and consistency, which prepares data for meaningful analysis and insights.

## Dataset

The dataset used in this project can be found on [Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022). It includes the following columns:
- **company**
- **location**
- **industry**
- **total_laid_off**
- **percentage_laid_off**
- **date**
- **stage**
- **country**
- **funds_raised_millions**

The data contains entries for layoffs from multiple companies across industries.

## Objectives

The main objectives of this project were:
1. Identifying and removing duplicate entries.
2. Standardizing inconsistent data values.
3. Handling null values appropriately for further analysis.
4. Removing unnecessary data to improve data quality and usability.

---

## Data Cleaning Steps

### Step 1: Removing Duplicates
1. **Creating a Staging Table** – A copy of the main table (`layoffs_staging`) was created to preserve the original data.
2. **Identifying Duplicates** – Using `ROW_NUMBER()` with `PARTITION BY` to detect duplicate entries based on key columns such as `company`, `industry`, `location`, and `date`.
3. **Removing Duplicates** – Rows with duplicate values (where `row_num > 1`) were deleted, keeping only unique entries for accurate analysis.

### Step 2: Standardizing Data
1. **Cleaning `industry` Column** – Standardized entries in the `industry` column by setting blank values to `NULL` and merging variations of similar values, like unifying different "Crypto" entries.
2. **Cleaning `country` Column** – Removed trailing punctuation in country names for consistency.
3. **Converting Date Format** – Used `STR_TO_DATE()` to convert date strings to a standard SQL `DATE` format, allowing for easier date-based queries and analysis.

### Step 3: Handling Null Values
- Retained `NULL` values in essential columns like `total_laid_off`, `percentage_laid_off`, and `funds_raised_millions`, as these may represent missing data that should be accounted for during further analysis.

### Step 4: Removing Unnecessary Data
1. **Deleting Irrelevant Rows** – Removed rows with null values in both `total_laid_off` and `percentage_laid_off`, as they provided no useful data.
2. **Dropping Auxiliary Columns** – Removed the `row_num` column after it was no longer needed for duplicate identification.

---

## Results

The data cleaning process resulted in a refined dataset that:
- Contains only unique entries without duplicates.
- Has consistent values across key columns, such as `industry` and `country`.
- Uses a standardized date format for ease of analysis.
- Contains null values where appropriate for meaningful analysis.

## Conclusion

This project showcases essential data cleaning techniques in SQL, which are critical for preparing data for analysis. The clean dataset is now ready for exploratory data analysis (EDA) and further insights.

