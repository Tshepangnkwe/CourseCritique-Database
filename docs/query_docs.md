# Query Documentation: CourseCritique Database

This document describes the purpose, logic, and usage of key queries and analytics scripts included in the CourseCritique Database project.

---

## Table of Contents

1. [Overview](#overview)
2. [Basic Queries](#basic-queries)
3. [Advanced Analytics](#advanced-analytics)
4. [Trend & Sentiment Analysis](#trend--sentiment-analysis)
5. [Usage Examples](#usage-examples)
6. [Customizing Queries](#customizing-queries)

---

## Overview

The queries in this project are designed for:

- Reporting on courses, instructors, and departments
- Analyzing student feedback and review trends
- Supporting dashboards and academic insights

All queries are written for PostgreSQL and can be found in the `queries/` directory.

---

## Basic Queries

### 1. List All Courses

```sql
SELECT code, title, credits, department_code, is_active
FROM courses
ORDER BY department_code, code;
```

*Lists all courses with their department and status.*

### 2. Instructor Directory

```sql
SELECT i.name, i.email, d.name AS department
FROM instructors i
JOIN departments d ON i.department_code = d.code
ORDER BY d.name, i.name;
```

*Shows all instructors and their departments.*

---

## Advanced Analytics

### 3. Top-Rated Courses

```sql
SELECT c.code, c.title, cs.average_rating, cs.total_reviews
FROM course_statistics cs
JOIN courses c ON cs.course_id = c.id
WHERE cs.total_reviews >= 10
ORDER BY cs.average_rating DESC
LIMIT 10;
```

*Finds the top 10 courses with at least 10 reviews.*

### 4. Department Performance

```sql
SELECT d.name AS department, ROUND(AVG(cs.average_rating),2) AS avg_rating
FROM course_statistics cs
JOIN courses c ON cs.course_id = c.id
JOIN departments d ON c.department_code = d.code
GROUP BY d.name
ORDER BY avg_rating DESC;
```

*Shows average course ratings by department.*

---

## Trend & Sentiment Analysis

### 5. Monthly Review Trends

```sql
SELECT TO_CHAR(created_at, 'YYYY-MM') AS month,
       COUNT(*) AS review_count,
       ROUND(AVG(rating),2) AS avg_rating
FROM reviews
WHERE status = 'approved'
GROUP BY TO_CHAR(created_at, 'YYYY-MM')
ORDER BY month;
```

*Tracks review volume and average rating by month.*

### 6. Review Sentiment Breakdown

```sql
SELECT
    CASE
        WHEN LOWER(content) LIKE '%great%' OR LOWER(content) LIKE '%excellent%' THEN 'Positive'
        WHEN LOWER(content) LIKE '%bad%' OR LOWER(content) LIKE '%poor%' THEN 'Negative'
        ELSE 'Neutral'
    END AS sentiment,
    COUNT(*) AS review_count
FROM reviews
WHERE status = 'approved'
GROUP BY
    CASE
        WHEN LOWER(content) LIKE '%great%' OR LOWER(content) LIKE '%excellent%' THEN 'Positive'
        WHEN LOWER(content) LIKE '%bad%' OR LOWER(content) LIKE '%poor%' THEN 'Negative'
        ELSE 'Neutral'
    END;
```

*Classifies reviews by sentiment keywords.*

---

## Usage Examples

- Run queries in psql, SQLcl, DBeaver, or pgAdmin.
- Use parameterized queries for flexible reports.
- Integrate queries into dashboards or reporting tools.

---

## Customizing Queries

- Adjust date ranges, keywords, or thresholds as needed.
- Add joins to include more context (e.g., user profiles, instructor info).
- Use analytic functions for rolling averages or rankings.

---

For more examples, see the `queries/queries_advanced.sql` file.
