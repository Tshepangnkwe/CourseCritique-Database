-- ================================
-- Indexes for CourseCritique (PostgreSQL)
-- Author: Carol Moukangwe
-- Purpose: Improve performance of frequent queries
-- ================================

-- ===== USERS TABLE =====
-- Index for user login using email
CREATE INDEX idx_users_email ON users(email);

-- ===== PROFILES TABLE =====
-- Index for quick access by department
CREATE INDEX idx_profiles_department ON profiles(department);

-- ===== INSTRUCTORS TABLE =====
-- Index to find instructors by department
CREATE INDEX idx_instructors_department ON instructors(department_code);

-- Index to look up instructor by user ID
CREATE INDEX idx_instructors_user_id ON instructors(user_id);

-- ===== COURSES TABLE =====
-- Index for searching/filtering courses by title
CREATE INDEX idx_courses_title ON courses(title);

-- Index for filtering by department
CREATE INDEX idx_courses_department ON courses(department_code);

-- Composite unique index for course code + department
CREATE UNIQUE INDEX idx_course_code_dept ON courses(code, department_code);

-- ===== COURSE_INSTRUCTORS TABLE =====
-- Index for looking up all instructors of a course
CREATE INDEX idx_ci_course_id ON course_instructors(course_id);

-- Index for finding all courses taught by a specific instructor
CREATE INDEX idx_ci_instructor_id ON course_instructors(instructor_id);

-- Composite unique index for course, instructor, and semester
CREATE UNIQUE INDEX idx_course_instructor_semester ON course_instructors (course_id, instructor_id, semester);

-- ===== REVIEWS TABLE =====
-- Index to get all reviews for a specific course
CREATE INDEX idx_reviews_course_id ON reviews(course_id);

-- Index to get all reviews by a specific user
CREATE INDEX idx_reviews_user_id ON reviews(user_id);

-- Index to get reviews for an instructor
CREATE INDEX idx_reviews_instructor ON reviews(instructor_id);

-- Index to sort/filter reviews by creation date
CREATE INDEX idx_reviews_created_at ON reviews(created_at);

-- ===== REVIEW_VOTES TABLE =====
-- Composite unique index for one vote per user per review
CREATE UNIQUE INDEX idx_review_vote ON review_votes (review_id, user_id);

-- Index to retrieve all votes cast by a user
CREATE INDEX idx_review_votes_user_id ON review_votes(user_id);

-- ===== ADMINS TABLE =====
-- Index to look up admin by staff ID
CREATE INDEX idx_admins_staff_id ON admins(staff_id);

-- ===== COURSE_STATISTICS TABLE =====
-- No additional indexes necessary; primary key already on course_id
-- This table is summarised per course and read-heavy, minimal writes.
