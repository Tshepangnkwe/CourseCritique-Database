# Physical Design: CourseCritique Database

## Overview

The physical design of the CourseCritique Database translates the logical data model into an efficient, scalable, and secure implementation on Oracle Database. This document outlines table structures, indexing strategies, storage considerations, and performance optimizations.

---

## Table Structures

### Core Tables

- **Department**  
  Stores department codes, names, and descriptions.

- **User**  
  Manages authentication, roles (student, instructor, admin), and verification status.

- **Profile**  
  Contains user details: names, display names, bios, graduation years, and department affiliations.

- **Course**  
  Catalog of courses, including department, credits, and creator.

- **Instructor**  
  Instructor records, linked to users and departments.

- **CourseInstructor**  
  Many-to-many mapping of instructors to courses per semester, with roles and primary/secondary flags.

- **Review**  
  Stores student feedback, ratings, difficulty, workload, anonymity, and verification.

- **ReviewVote**  
  Tracks upvotes/downvotes for reviews, enforcing one vote per user per review.

- **CourseStatistics**  
  Aggregated metrics: average rating, difficulty, workload, and would-take-again percentage.

---

## Indexing & Performance

- **Primary Keys:**  
  All tables use numeric or GUID-based primary keys for fast access.

- **Foreign Keys:**  
  Enforced for referential integrity (e.g., course_id, user_id, department_code).

- **Indexes:**  
  - Composite indexes on frequently queried columns (e.g., (course_id, instructor_id) in CourseInstructor).
  - Indexes on review status, created_at, and rating for analytics queries.
  - Unique constraints on emails and department codes.

- **Partitioning (optional):**  
  Large tables like Review and ReviewVote can be partitioned by semester or year for scalability.

---

## Storage & Data Types

- **Data Types:**  
  - `VARCHAR` for text fields (names, emails, descriptions)
  - `UUID` for IDs (primary/foreign keys)
  - `INTEGER` or `NUMERIC` for ratings, flags, and workload
  - `TIMESTAMPTZ` for all date/time fields
  - `TEXT` for long review content

- **Nullability:**  
  - Required fields are marked as `NOT NULL`.
  - Optional fields (e.g., bio, avatar_url) allow `NULL`.

- **Default Values:**  
  - Timestamps default to `CURRENT_TIMESTAMP`.
  - Boolean flags (`is_verified`, `is_active`) default to `TRUE`.

---

## Example: Table Definition (PostgreSQL Syntax)

```sql
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    content TEXT,
    difficulty INTEGER CHECK (difficulty BETWEEN 1 AND 5),
    workload_hours INTEGER,
    would_take_again BOOLEAN,
    is_anonymous BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT TRUE,
    status VARCHAR(20) CHECK (status IN ('approved','pending','rejected')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    course_id UUID REFERENCES courses(id),
    user_id UUID REFERENCES users(id),
    instructor_id UUID REFERENCES instructors(id)
);
```

---

## Security & Integrity

- **User Roles:**  
  Role column in User table restricts access (student, instructor, admin).

- **Data Validation:**  
  - Triggers and constraints enforce valid ratings (1-5), workload ranges, and unique votes.
  - Check constraints on enumerated fields (e.g., review status).

- **Audit Columns:**  
  - All tables include created_at and updated_at for tracking changes.

---

## Maintenance & Growth

- **Archiving:**  
  Old reviews and votes can be archived to separate tables or partitions.

- **Backup:**  
  Regular database backups recommended, especially before bulk data loads.

- **Monitoring:**  
  Use PostgreSQL tools to monitor index usage, query performance, and table growth.

---

## Physical Design Highlights

- **Optimized for analytics:** Indexes and partitioning support fast reporting.
- **Data integrity:** Constraints and triggers prevent invalid or duplicate data.
- **Scalability:** Designed to handle thousands of courses, users, and reviews.
- **Security:** Role-based access and audit columns for accountability.

---

For further details, see the `create_tables.sql`, `create_indexes.sql`, and `create_constraints.sql` scripts in the `database_objects` folder.
