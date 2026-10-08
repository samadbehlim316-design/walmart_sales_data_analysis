Walmart Sales Data Cleaning & Database Pipeline

An end-to-end data engineering project that takes raw Walmart sales data, cleans and standardises it with Python (Pandas), and loads it into both MySQL and PostgreSQL so it is ready for SQL analysis and reporting.

Author: Samad

Table of Contents
Problem Statement
Proposed Solution
Dataset Overview
Data Quality Issues & How They Were Solved
Project Workflow
Tech Stack
Project Structure
Getting Started
Results
Future Improvements
Contact
Problem Statement

Retail sales data is often exported in a raw state that cannot be analysed reliably. The Walmart dataset used in this project contains several quality problems:

Duplicate records that inflate sales and transaction counts
Missing values in unit_price and quantity, which makes revenue impossible to calculate for those rows
Wrong data types: prices stored as text (e.g. $74.69), dates stored as strings, quantity stored as a decimal
Inconsistent column naming (mixed upper and lower case), which causes errors in SQL queries
No database storage: the data lives in a flat CSV file, so it cannot be queried efficiently or shared across systems

Analysing this data directly would lead to incorrect totals, failed calculations and unreliable business insights.

Proposed Solution

I built a reproducible Python pipeline, documented in a Jupyter Notebook, that:

Loads and profiles the raw data
Removes duplicates and handles missing values
Converts every column to the correct data type
Standardises column names
Creates a new total column (unit_price × quantity) for revenue analysis
Exports a clean CSV
Loads the clean data into MySQL and PostgreSQL using SQLAlchemy

The result is a trusted, analysis-ready dataset available in a flat file and in two widely used relational databases.

Dataset Overview
Item	Detail
Source file	Walmart.csv
Raw size	10,051 rows × 11 columns
Clean size	9,969 rows × 12 columns
Column	Description
invoice_id	Unique transaction ID
branch	Walmart branch code
city	City of the branch
category	Product category
unit_price	Price per unit (USD)
quantity	Units sold
date	Transaction date
time	Transaction time
payment_method	Cash, credit card or e-wallet
rating	Customer rating
profit_margin	Profit margin of the sale
total	Derived: unit_price × quantity
Data Quality Issues & How They Were Solved
Issue	Finding	Solution
Duplicate rows	51 duplicates	drop_duplicates() → 10,000 rows
Missing values	31 nulls each in unit_price and quantity	dropna() → 9,969 rows
Price stored as text	Values like $74.69	Strip $ and cast to float
Quantity as float	7.0 instead of 7	Cast to int
Date and time as strings	Format dd/mm/yy	Parsed with pd.to_datetime(format='%d/%m/%y')
Inconsistent column names	Branch, City	Converted all to lowercase
No revenue column	Totals not available	Added total = unit_price × quantity
Flat-file storage only	No SQL access	Loaded into MySQL and PostgreSQL
Project Workflow
Walmart.csv  →  Load & Explore  →  Clean & Transform  →  Feature Engineering
                                                              │
                                      ┌───────────────────────┼───────────────────────┐
                                      ▼                       ▼                       ▼
                           walmart_clean_data.csv          MySQL                PostgreSQL
Tech Stack
Language: Python 3
Libraries: Pandas, SQLAlchemy, PyMySQL, Psycopg2
Databases: MySQL, PostgreSQL
Tools: Jupyter Notebook
Project Structure
walmart_sales_data_analysis/
├── Walmart.csv                      # Raw dataset
├── walmart_cleaning_corrected.ipynb # Cleaning & loading notebook
├── walmart_clean_data.csv           # Cleaned output
└── README.md
Getting Started
1. Clone the repository
bash
git clone https://github.com/samadbehlim316-design/walmart_sales_data_analysis.git
cd walmart_sales_data_analysis
2. Install dependencies
bash
pip install pandas sqlalchemy pymysql psycopg2-binary jupyter
3. Create the databases
sql
CREATE DATABASE walmart_db;

Run this once in both MySQL and PostgreSQL.

4. Set your database credentials as environment variables

Never hard-code passwords in the notebook.

bash
# MySQL
export MYSQL_USER=root
export MYSQL_PASS=your_password

# PostgreSQL
export PG_USER=postgres
export PG_PASS=your_password
5. Run the notebook
bash
jupyter notebook walmart_cleaning_corrected.ipynb
Results
Cleaned 10,051 raw records down to 9,969 reliable records
Removed 51 duplicates and 62 incomplete values (31 in each of two columns)
Corrected data types so calculations and date filtering work as expected
Produced a clean CSV and populated two relational databases with a verified row count
Future Improvements
Run SQL analysis: revenue by branch, city and category; peak sales hours; payment method trends
Build a dashboard in Power BI or Tableau
Automate the pipeline with a scheduled script (e.g. Airflow or cron)
Add data validation checks (for example, Great Expectations)
Contact

Samad

GitHub: github.com/samadbehlim316-design
Project Repository: walmart_sales_data_analysis
Email: samadbehlim316@gmail.com
