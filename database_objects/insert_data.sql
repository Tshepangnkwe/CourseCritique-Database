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
INSERT INTO users (id, email, role, is_verified, created_at, updated_at) VALUES
-- Use gen_random_uuid() or uuid_generate_v4() for id if using UUIDs, or use SERIAL for integer PKs
-- For demonstration, assuming SERIAL/integer PKs for simplicity
(DEFAULT, 'student1@student.com', 'student', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(DEFAULT, 'prof.smith@instructor.com', 'instructor', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(DEFAULT, 'admin1@admin.com', 'admin', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
-- ...continue for all users...
(DEFAULT, 'admin2@admin.com', 'admin', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 4. Profile Information
INSERT INTO profiles (user_id, first_name, last_name, display_name, avatar_url, department, bio, graduation_year) VALUES
(1, 'John', 'Doe', 'JohnD', NULL, 'CS', 'CS major interested in AI', 2024),
-- ...continue for all profiles...

-- 5. Course Data
INSERT INTO courses (id, code, title, description, credits, is_active, created_at, updated_at, department_code, created_by) VALUES
(DEFAULT, 'CS101', 'Introduction to Programming', 'Basic programming concepts', 4, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'CS', 2),
-- ...continue for all courses...

-- 6. Instructor Records
INSERT INTO instructors (id, user_id, name, email, department_code, office_location, website_url, is_active) VALUES
(DEFAULT, 2, 'Jane Smith', 'prof.smith@instructor.com', 'CS', 'Room 101', 'http://smith.university.edu', TRUE),
-- ...continue for all instructors...

-- 7. Course-Instructor Relationships
INSERT INTO course_instructors (id, course_id, instructor_id, semester, role, created_at, updated_at) VALUES
(DEFAULT, 1, 1, 'Fall2023', 'Primary', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
-- ...continue for all relationships...

-- 8. Review Data
INSERT INTO reviews (id, rating, content, difficulty, workload_hours, would_take_again, is_anonymous, is_verified, status, created_at, updated_at, course_id, user_id, instructor_id) VALUES
(DEFAULT, 5, 'Excellent course, highly recommended!', 3, 10, TRUE, FALSE, TRUE, 'approved', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1, 1),
-- ...continue for all reviews...

-- 9. Review Votes
INSERT INTO review_votes (id, review_id, user_id, vote_type, reason, created_at) VALUES
(DEFAULT, 1, 1, 'upvote', 'Helpful review', CURRENT_TIMESTAMP),
-- ...continue for all votes...

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
