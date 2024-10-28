-- Step 1: Display all data from the main "layoffs" table before starting the data cleaning process
SELECT * 
FROM world_layoffs.layoffs;

-- Create a staging table "layoffs_staging" for data cleaning purposes
-- This allows us to work on a copy of the data while preserving the original table
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

-- Copy all data from the main table to "layoffs_staging"
INSERT INTO world_layoffs.layoffs_staging 
SELECT * FROM world_layoffs.layoffs;

-- Step 1: Removing Duplicates

-- Check for duplicates in the staging table
-- Using ROW_NUMBER() with PARTITION BY to identify duplicates based on key columns
SELECT company, industry, total_laid_off, `date`,
       ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off, `date`
       ) AS row_num
FROM world_layoffs.layoffs_staging;

-- Display actual duplicates where "row_num" is greater than 1
SELECT *
FROM (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;

-- Create a CTE (Common Table Expression) to facilitate duplicate deletion
WITH DELETE_CTE AS (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
           ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
    FROM world_layoffs.layoffs_staging
)
-- Delete duplicates where "row_num" is greater than 1
DELETE FROM world_layoffs.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
    FROM DELETE_CTE
) AND row_num > 1;

-- Create a new table "layoffs_staging2" with an extra "row_num" column to facilitate duplicate removal
CREATE TABLE `world_layoffs`.`layoffs_staging2` (
    `company` text,
    `location` text,
    `industry` text,
    `total_laid_off` INT,
    `percentage_laid_off` text,
    `date` text,
    `stage` text,
    `country` text,
    `funds_raised_millions` INT,
    row_num INT
);

-- Insert data into the new table and assign row numbers to duplicates
INSERT INTO `world_layoffs`.`layoffs_staging2`
    (`company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`, `row_num`)
SELECT `company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`,
       ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging;

-- Delete rows with duplicates (where "row_num" >= 2)
DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;

-- Step 2: Standardizing Data

-- Display unique values in the "industry" column to identify inconsistencies
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

-- Set empty values in the "industry" column to NULL
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populate missing values in the "industry" column where there are other rows with the same company name
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Standardize different versions of "Crypto" in the "industry" column to a single value
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Remove any trailing period in country names, e.g., "United States."
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- Convert the "date" column to a standard SQL date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change the data type of the "date" column to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Step 3: Handling Null Values

-- Review NULL values in key columns, such as "total_laid_off," "percentage_laid_off," and "funds_raised_millions"
-- NULL values are kept as-is to simplify calculations during exploratory data analysis (EDA)

-- Step 4: Removing Unnecessary Data

-- Delete rows missing values in both "total_laid_off" and "percentage_laid_off" columns
DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Drop the auxiliary "row_num" column from the table after completing the data cleaning process
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final display of cleaned data
SELECT * 
FROM world_layoffs.layoffs_staging2;
