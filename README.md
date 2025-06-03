# Retail Data Cleaning & Data Modeling Project (Superstore Dataset)

## Objective

To clean and transform raw retail sales data from the Superstore dataset and create a well-structured relational database model suitable for analytics and reporting.

---

## Dataset

- **Superstore.csv**: Contains raw data related to orders, customers, products, and regions.
- **archive.zip**: Zipped copy of the original Superstore dataset.

---

## Problem Statement

Refer to the detailed problem statement in `Problem Statement.docx`.

---

## Files Included

| File Name             | Description                                      |
|----------------------|--------------------------------------------------|
| `Superstore.csv`      | Raw dataset                                      |
| `archive.zip`         | Zipped dataset backup                            |
| `Problem Statement.docx` | Documentation of problem scope and objective  |
| `Solution.sql`        | All SQL queries for data cleaning and modeling   |
| `Data Model.png`      | Visual representation of the final data model    |

---

## Steps Performed

### 1. **Import and Explore Raw Data**
- Loaded `Superstore.csv` into SQL environment.

### 2. **Data Cleaning**
- Checked and removed exact duplicate rows.
- Standardized date formats.
- Trimmed white spaces from text fields.
- Replaced NULL values with meaningful defaults or removed invalid records.
- Formatted numeric values (Sales, Profit, etc.) consistently.

### 3. **Data Modeling**
Created normalized tables from raw data:

#### a. `Customers`
- Extracted unique Customer IDs with names and segments.

#### b. `Products`
- Extracted unique Product IDs and names.
- Created surrogate key `Product_Key` due to non-uniqueness in Product_ID.

#### c. `Regions`
- Extracted unique combinations of Region, Country, State, City, and Postal Code.
- Added `Region_ID` as primary key.

#### d. `Orders`
- Created a fact table with foreign keys linking to `Customers`, `Products`, and `Regions`.

### 4. **Relational Schema**
- Defined appropriate primary and foreign key relationships.
- Ensured referential integrity.

### 5. **Generated Entity Relationship Diagram**
- Created `Data Model.png` using `dbdiagram.io` to visualize the schema.

---

## Outcome

The raw data has been cleaned, normalized, and structured into a relational model that can be used for further analysis or business intelligence dashboards.

---

## Tools Used

- Microsoft SQL Server (SQL)
- dbdiagram.io (for ER diagram)
- MS Word (for documentation)

---

