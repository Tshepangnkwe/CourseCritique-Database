-- =============================================
-- CourseCritique - Data Population (PostgreSQL)
-- Author: IR Twala
-- =============================================

-- Purpose: Populate the database with test data for the Course Feedback System

-- 1. Truncate tables (PostgreSQL syntax)
DO $$
BEGIN
  EXECUTE 'TRUNCATE TABLE review_votes RESTART IDENTITY CASCADE';
  EXECUTE 'TRUNCATE TABLE reviews RESTART IDENTITY CASCADE';
  EXECUTE 'TRUNCATE TABLE course_instructors RESTART IDENTITY CASCADE';
  EXECUTE 'TRUNCATE TABLE course_statistics RESTART IDENTITY CASCADE';
  EXECUTE 'TRUNCATE TABLE courses RESTART IDENTITY CASCADE';
  EXECUTE 'TRUNCATE TABLE instructors RESTART IDENTITY CASCADE';
  EXECUTE 'TRUNCATE TABLE profiles RESTART IDENTITY CASCADE';
  EXECUTE 'TRUNCATE TABLE users RESTART IDENTITY CASCADE';
  EXECUTE 'TRUNCATE TABLE departments RESTART IDENTITY CASCADE';
END $$;

-- 2. Department Data
INSERT INTO departments (code, name, description) VALUES 
('CS', 'Computer Science', 'Department covering algorithms, programming, and systems'),
('MATH', 'Mathematics', 'Pure and applied mathematics programs'),
('PHY', 'Physics', 'Theoretical and experimental physics studies'),
('ENG', 'English', 'English language and literature'),
('ECON', 'Economics', 'Economics and finance studies');

-- 3. User Accounts (Students, Instructors, Admins)
-- Insert users and capture their UUIDs
INSERT INTO users (id, email, role, is_verified, created_at, updated_at)
VALUES
  (uuid_generate_v4(), 'student1@student.com', 'student', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'prof.smith@instructor.com', 'instructor', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'admin1@admin.com', 'admin', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'admin2@admin.com', 'admin', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 4. Profile Information
-- Insert profile using a subquery to get the user's UUID by email
INSERT INTO profiles (user_id, first_name, last_name, display_name, avatar_url, department, bio, graduation_year)
VALUES (
  (SELECT id FROM users WHERE email = 'student1@student.com'),
  'John', 'Doe', 'JohnD', NULL, 'CS', 'CS major interested in AI', 2024
);

-- 5. Course Data
-- Insert course using a subquery to get the creator's UUID by email
INSERT INTO courses (id, code, title, description, credits, is_active, created_at, updated_at, department_code, created_by)
VALUES (
  uuid_generate_v4(), 'CS101', 'Introduction to Programming', 'Basic programming concepts', 4, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'CS',
  (SELECT id FROM users WHERE email = 'prof.smith@instructor.com')
);

-- 6. Instructor Records
-- Insert instructor using a subquery to get the user's UUID by email
INSERT INTO instructors (id, user_id, name, email, department_code, office_location, website_url, is_active)
VALUES (
  uuid_generate_v4(),
  (SELECT id FROM users WHERE email = 'prof.smith@instructor.com'),
  'Jane Smith', 'prof.smith@instructor.com', 'CS', 'Room 101', 'http://smith.university.edu', TRUE
);

-- 7. Course-Instructor Relationships
-- Insert course_instructors using subqueries for course_id and instructor_id
INSERT INTO course_instructors (id, course_id, instructor_id, semester, role, created_at, updated_at)
VALUES (
  uuid_generate_v4(),
  (SELECT id FROM courses WHERE code = 'CS101'),
  (SELECT id FROM instructors WHERE email = 'prof.smith@instructor.com'),
  'Fall2023', 'Primary', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);

-- 8. Review Data
-- Insert reviews using subqueries for course_id, user_id, instructor_id
INSERT INTO reviews (id, rating, content, difficulty, workload_hours, would_take_again, is_anonymous, is_verified, status, created_at, updated_at, course_id, user_id, instructor_id)
VALUES (
  uuid_generate_v4(), 5, 'Excellent course, highly recommended!', 3, 10, TRUE, FALSE, TRUE, 'approved', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
  (SELECT id FROM courses WHERE code = 'CS101'),
  (SELECT id FROM users WHERE email = 'student1@student.com'),
  (SELECT id FROM instructors WHERE email = 'prof.smith@instructor.com')
);

-- 9. Review Votes
-- Insert review_votes using subqueries for review_id and user_id
INSERT INTO review_votes (id, review_id, user_id, vote_type, reason, created_at)
VALUES (
  uuid_generate_v4(),
  (SELECT id FROM reviews WHERE content LIKE 'Excellent course%'),
  (SELECT id FROM users WHERE email = 'student1@student.com'),
  'upvote', 'Helpful review', CURRENT_TIMESTAMP
);

-- 10. Update Course Statistics (PostgreSQL upsert)
INSERT INTO course_statistics (course_id, total_reviews, average_rating, average_difficulty, average_workload_hours, would_take_again_pct, last_updated)
SELECT 
    c.id,
    COUNT(r.id) AS total_reviews,
    AVG(r.rating)::NUMERIC(3,2) AS average_rating,
    AVG(r.difficulty)::NUMERIC(3,2) AS average_difficulty,
    AVG(r.workload_hours)::NUMERIC(5,2) AS average_workload_hours,
    100 * AVG(CASE WHEN r.would_take_again THEN 1 ELSE 0 END)::NUMERIC(5,2) AS would_take_again_pct,
    CURRENT_TIMESTAMP
FROM courses c
LEFT JOIN reviews r ON c.id = r.course_id AND r.status = 'approved'
GROUP BY c.id
ON CONFLICT (course_id) DO UPDATE SET
    total_reviews = EXCLUDED.total_reviews,
    average_rating = EXCLUDED.average_rating,
    average_difficulty = EXCLUDED.average_difficulty,
    average_workload_hours = EXCLUDED.average_workload_hours,
    would_take_again_pct = EXCLUDED.would_take_again_pct,
    last_updated = CURRENT_TIMESTAMP;

-- 11. Verification queries
SELECT 'departments' AS table_name, COUNT(*) AS record_count FROM departments
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'profiles', COUNT(*) FROM profiles
UNION ALL SELECT 'courses', COUNT(*) FROM courses
UNION ALL SELECT 'instructors', COUNT(*) FROM instructors
UNION ALL SELECT 'course_instructors', COUNT(*) FROM course_instructors
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL SELECT 'review_votes', COUNT(*) FROM review_votes
UNION ALL SELECT 'course_statistics', COUNT(*) FROM course_statistics;
