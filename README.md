# CourseCritique Database

A comprehensive PostgreSQL database for managing and analyzing university course feedback, reviews, and academic data. This project is designed for academic analytics, reporting, and as a foundation for course review web applications.

---

## Features

- **Department Management:** Store and manage academic departments with codes and descriptions.
- **User & Profile System:** Support for students, instructors, and admins, with detailed profile information.
- **Course Catalog:** Store detailed course data, including department, credits, and status.
- **Instructor Records:** Track instructor details and department affiliations.
- **Course-Instructor Assignments:** Model teaching assignments and roles per semester.
- **Review System:** Collect and analyze student reviews, ratings, and feedback.
- **Review Voting:** Allow users to upvote/downvote reviews for quality control.
- **Course Statistics:** Automatically calculate and update course averages and trends.
- **Advanced Analytics:** Includes queries for trends, sentiment, and department/course/instructor analytics.

---

## Database Structure

### Main Tables

- **departments**: Department code, name, description.
- **users**: User account info (student, instructor, admin).
- **profiles**: User profile details (name, department, bio, graduation year).
- **courses**: Course catalog with department, credits, and creator.
- **instructors**: Instructor details and department.
- **course_instructors**: Assignment of instructors to courses per semester.
- **reviews**: Student reviews with ratings, comments, and metadata.
- **review_votes**: Upvotes/downvotes on reviews.
- **course_statistics**: Aggregated statistics for each course.

---

## Data Population

- **Sample Data:** The `database_objects/insert_data.sql` script populates the database with:
  - 5+ departments
  - 50+ users (students, instructors, admins)
  - 40+ user profiles
  - 30+ courses across all departments
  - 15 instructors
  - 50+ course-instructor assignments
  - 200+ realistic reviews (bell curve ratings, natural comments)
  - 100+ review votes
  - Course statistics auto-calculated from reviews

---

## Advanced Queries

- **Character Functions:** Masked emails, formatted names, sentiment extraction.
- **Date/Time Functions:** Monthly/quarterly review trends, recent activity.
- **Variables:** Parameterized queries for flexible analytics.
- **Rounding/Formatting:** Formatted averages, percentages, and workload hours.

See [`queries/advanced_sql.sql`](queries/advanced_sql.sql) for examples.

---

## Usage

1. **Setup Database:**
   - Create a PostgreSQL database.
   - Run all table creation scripts in `database_objects/`.
   - Run `insert_data.sql` to populate with test data.

2. **Run Analytics:**
   - Use queries in `queries/` for reporting, dashboards, and insights.

3. **Customization:**
   - Modify or extend the schema and queries for your institution’s needs.

---

## Example Analytics

- Top-rated courses and instructors
- Review trends by month/semester
- Sentiment analysis of review comments
- Departmental performance summaries
- Workload and difficulty distributions

---

## Requirements

- PostgreSQL Database
- psql, SQLcl, DBeaver, pgAdmin, or any PostgreSQL-compatible SQL IDE

---

## Contributing

Pull requests and suggestions are welcome! Please open an issue for major changes.

---

## License

MIT License

---
