# Diabetes Readmission Analysis --- SQL Healthcare Analytics

## 📌 Project Overview

**Diabetes Readmission Analysis** is a SQL-based healthcare analytics
project using the **Diabetes 130-US Hospitals for Years 1999--2008**
dataset.

The project focuses on understanding **patterns and factors associated
with hospital readmission among diabetic patients**, with particular
attention to **readmission within 30 days (`<30`)**.

The analysis covers data cleaning, missing-value handling, patient-level
deduplication, mapping coded variables to meaningful descriptions,
feature engineering, exploratory analysis, and advanced SQL techniques.

------------------------------------------------------------------------

## 🎯 Problem Statement

Hospital readmissions can indicate the complexity of a patient's
condition and the challenges involved in managing diabetes after
discharge.

The objective of this project is to use historical diabetic patient data
to answer questions such as:

-   What proportion of patients are readmitted within 30 days?
-   How does readmission vary across age groups and gender?
-   Are certain admission types associated with different readmission
    rates?
-   Is medication change associated with 30-day readmission?
-   Does discharge disposition show different readmission patterns?
-   Is A1C testing/status associated with readmission?
-   Do patients with greater previous healthcare utilization show
    different readmission patterns?
-   Which primary diagnosis categories show higher observed 30-day
    readmission rates?

> **Important:** The analysis identifies patterns and associations in
> the dataset. It does not establish that any factor directly causes
> readmission.

------------------------------------------------------------------------

## 📊 Dataset

### Dataset Name

**Diabetes 130-US Hospitals for Years 1999--2008**

### Source

[Access the dataset on UCI Machine Learning
Repository](https://archive.ics.uci.edu/dataset/296/diabetes+130+us+hospitals+for+years+1999-2008)

The dataset is publicly available and can be downloaded directly by
anyone viewing this project.

### Original Research Paper

Beata Strack, Jonathan P. DeShazo, Chris Gennings, Juan L. Olmo,
Sebastian Ventura, Krzysztof J. Cios, and John N. Clore.

**"Impact of HbA1c Measurement on Hospital Readmission Rates: Analysis
of 70,000 Clinical Database Patient Records."**

*BioMed Research International*, 2014, Article ID 781670.

------------------------------------------------------------------------

## 🛠️ Tools & Technologies

-   **MySQL**
-   SQL
-   Common Table Expressions (CTEs)
-   Window Functions
-   Aggregate Functions
-   `CASE WHEN`
-   Data Cleaning & Transformation
-   Exploratory Data Analysis
-   Healthcare / Readmission Analytics

------------------------------------------------------------------------

## 🔄 Data Preparation & Cleaning

### 1. Initial Data Exploration

-   Checked total records and sample data.
-   Reviewed important variables and their values.

### 2. Missing-Value Handling

-   Converted `?` values to SQL `NULL`.
-   Analyzed missing-value percentages for relevant columns.

### 3. Patient-Level Deduplication

Patients can have multiple encounters in the original dataset. For this
project, a **one-row-per-patient dataset** was intentionally created by
retaining the encounter with the minimum `encounter_id` for each
`patient_nbr`.

This produces:

`diabetic_data_dedup`

### 4. Excluding Non-Readmittable Dispositions

Discharge dispositions associated with death, hospice, or
invalid/unknown outcomes were excluded because they do not represent
patients for whom a subsequent readmission can be meaningfully
evaluated.

### 5. Mapping Coded Variables

Mapping tables were created for: - `discharge_disposition_map` -
`admission_source_map`

These convert coded IDs into meaningful descriptions.

### 6. Age Feature Engineering

The original age variable is provided as ranges such as `[50-60)`. An
`age_midpoint` feature was created to make age easier to use in
quantitative analysis.

------------------------------------------------------------------------

## 🔎 Exploratory Analysis

The project examines:

-   Overall readmission distribution (`<30`, `>30`, `NO`)
-   Readmission by age
-   Readmission by admission type

------------------------------------------------------------------------

# 📈 Key Findings / Analyses

## Finding 1 --- Primary Diagnosis Categories and Readmission

Primary diagnosis codes (`diag_1`) are grouped into broader clinical
categories and compared with observed `<30` readmission rates.

**Purpose:** Identify diagnosis categories with different observed
readmission patterns.

## Finding 2 --- Medication Change and Readmission

The `change` field is analyzed against `<30` readmission.

**Purpose:** Examine whether medication-change status is associated with
a different observed 30-day readmission rate.

## Finding 3 --- Discharge Disposition Impact

Discharge destinations are compared with observed `<30` readmission
rates. Categories with fewer than 100 encounters are excluded from this
comparison.

**Purpose:** Examine whether different discharge destinations show
different observed readmission patterns.

## Finding 4 --- A1C Testing and Readmission

`A1Cresult` is analyzed against `<30` readmission.

**Purpose:** Examine how observed 30-day readmission varies across A1C
result/status categories.

## Finding 5 --- Readmission by Gender

Gender categories are compared based on their observed `<30` readmission
rates.

## Finding 6 --- Readmission and Previous Emergency Visits

`number_emergency` is analyzed against `<30` readmission.

**Purpose:** Examine whether different levels of previous emergency
healthcare utilization are associated with different observed
readmission rates.

## Finding 7 --- High Healthcare Utilization

Patients are examined using:

-   `number_inpatient`
-   `number_outpatient`
-   `number_emergency`
-   `readmitted`

The records are ordered by `number_inpatient` to inspect patients with
higher previous inpatient utilization.

> `number_inpatient` represents the number of inpatient visits, not a
> direct count of overnight stays.

------------------------------------------------------------------------

# 🧠 Advanced SQL Techniques Used

The project demonstrates:

-   **CTEs** for reusable intermediate queries
-   **`RANK()`** for ranking patients within groups
-   **`NTILE(4)`** for dividing patients into four approximately equal
    groups
-   **`CASE WHEN`** for creating meaningful categories
-   **Aggregate functions** such as `COUNT()`, `SUM()`, `AVG()`, and
    `ROUND()`
-   **`GROUP BY`, `HAVING`, and `ORDER BY`**
-   Boolean aggregation such as `SUM(readmitted = '<30')`

------------------------------------------------------------------------

# 👨‍💻 Project Responsibilities

-   Understanding and exploring the healthcare dataset.
-   Cleaning and transforming raw data using SQL.
-   Handling missing values.
-   Creating the intentional first-encounter-per-patient dataset.
-   Creating mapping tables for coded variables.
-   Performing feature engineering.
-   Developing readmission analyses.
-   Applying CTEs, window functions, conditional logic, and
    aggregations.
-   Interpreting patterns across demographic, clinical, treatment,
    discharge, and healthcare-utilization variables.
-   Documenting assumptions and limitations.

------------------------------------------------------------------------

# ⚠️ Important Methodological Note

This project intentionally retains the **first recorded encounter for
each patient**, creating a one-row-per-patient analysis dataset.

Therefore, the analysis focuses on information from the retained first
encounter and its recorded readmission outcome rather than modeling
every encounter for the same patient.

The results represent **observed associations**, not causal
relationships.

------------------------------------------------------------------------

# 🚀 Future Improvements

Possible extensions include:

-   Build an interactive **Power BI dashboard**.
-   Perform deeper multi-factor analysis, such as **Age + A1C** or
    **Medication Change + Age**.
-   Add statistical testing such as **chi-square tests and logistic
    regression**.
-   Develop a machine-learning model to predict `<30` readmission.
-   Add model explainability using feature importance or SHAP.

------------------------------------------------------------------------

# 📌 Project Outcome

This project demonstrates how SQL can be used to transform a real-world
healthcare dataset into meaningful readmission insights.

**Raw Data → Cleaning → Patient-Level Cohort → Feature Engineering →
Exploratory Analysis → Advanced SQL → Readmission Insights**

------------------------------------------------------------------------

# 📚 References

1.  Strack, B., DeShazo, J. P., Gennings, C., Olmo, J. L., Ventura, S.,
    Cios, K. J., & Clore, J. N. (2014). *Impact of HbA1c Measurement on
    Hospital Readmission Rates: Analysis of 70,000 Clinical Database
    Patient Records*. BioMed Research International, 2014, Article ID
    781670.

2.  [UCI Machine Learning Repository --- Diabetes 130-US Hospitals for
    Years
    1999--2008](https://archive.ics.uci.edu/dataset/296/diabetes+130+us+hospitals+for+years+1999-2008)

------------------------------------------------------------------------

## ⭐ Feel Free to Use

Feel free to use this project for **learning, reference, SQL practice,
or further development**.
