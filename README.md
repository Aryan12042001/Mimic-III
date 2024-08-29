# MIMIC-III Database Analysis and Classification

## Overview

This project focuses on setting up and analyzing a PostgreSQL database derived from the MIMIC-III dataset, which includes extensive clinical data from ICU patients. The primary aim is to leverage this dataset for predictive modeling and gain insights into patient outcomes, specifically predicting the likelihood of hospital expiration.

## Project Components

### 1. Database Setup

**Defining Tables**: The first step involved creating PostgreSQL tables that reflect the structure of the MIMIC-III dataset. This ensures that the database schema accurately mirrors the dataset’s structure, which is crucial for maintaining data integrity and facilitating efficient queries.

**Importing Data**: Data was imported into PostgreSQL using the `COPY` command, a method known for its efficiency in handling large volumes of data. This step populated the database tables with the MIMIC-III dataset, which contains over 500 million rows.

**Creating Indexes**: To improve query performance, indexes were established on columns frequently used in queries, such as `subject_id` and `hadm_id`. Indexes help speed up data retrieval processes, especially when dealing with large datasets.

**Applying Constraints**: Constraints were implemented to enforce data integrity. This included `NOT NULL` constraints on essential columns (e.g., primary keys) and `UNIQUE` constraints to prevent duplicate entries, thus maintaining the quality and consistency of the data.

**Establishing Foreign Keys**: Foreign keys were used to link related tables within the database. For example, `subject_id` in the patients table was linked to `subject_id` in the admissions and diagnoses tables. This relational integrity ensures that data across tables is consistent and accurate.

**Reasoning**: These steps were essential to ensure the database's robustness, enhance performance, and comply with best practices in database design. They also lay the groundwork for effective data analysis and modeling.

### 2. Data Processing and Analysis

Given the massive scale of the dataset, processing and analysis required meticulous handling:

**Handling Missing Values**: The dataset presented challenges with missing values. A systematic approach was used to address these gaps, including imputing missing values with median values or removing columns with excessive missing data.

**Feature Selection**: Feature importance was evaluated using statistical methods and dimensionality reduction techniques like Principal Component Analysis (PCA). This process involved identifying and selecting the most relevant features that contribute significantly to predicting patient outcomes.

**Data Cleaning**: To prepare the dataset for analysis, columns with high proportions of missing data and irrelevant date columns were removed. This cleaning process ensured that the dataset was streamlined and focused on features relevant for predictive modeling.

### 3. Machine Learning Models

The project employed machine learning techniques to build predictive models for patient outcomes:

**Gradient Boosting Classifier**: A Gradient Boosting Classifier was developed to predict the likelihood of hospital expiration (`hospital_expire_flag`). The model was trained and evaluated to assess its performance using metrics such as accuracy, precision, recall, and F1-score.

**PCA Analysis**: The impact of dimensionality reduction on model performance was examined by applying PCA. This technique helps reduce the feature space while preserving the variance in the data, allowing for potentially improved model performance and reduced computational complexity.

### 4. Feature Importance

An analysis of feature importance was conducted to understand which features most significantly influence the model’s predictions. This step included visualizing feature importance to highlight key predictors, providing insights into which clinical metrics are most critical for predicting patient outcomes.

## References

- **Feature Explanations in Recurrent Neural Networks for Predicting Risk of Mortality in Intensive Care Patients**: This article provided valuable insights into the relevance of various features in predicting patient outcomes. [Read the article](https://example.com/article)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

