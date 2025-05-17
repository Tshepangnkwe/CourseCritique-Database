-- ================================
-- Indexes for CourseCritique
-- Author: Carol Moukangwe
-- Purpose: Improve performance of frequent queries
-- ================================

-- ===== USERS TABLE =====
-- Index for user login using email
CREATE INDEX idx_users_email ON users(email);
-- Purpose: Speeds up login queries by quickly finding users via email.

-- ===== PROFILES TABLE =====
-- Index for quick access by department
CREATE INDEX idx_profiles_department ON profiles(department);
-- Purpose: Helps filter users by department in reporting and user listings.

-- ===== INSTRUCTORS TABLE =====
-- Index to find instructors by department
CREATE INDEX idx_instructors_department ON instructors(department_code);
-- Purpose: Improves instructor filtering/search by department.

-- Index to look up instructor by user ID
CREATE INDEX idx_instructors_user_id ON instructors(user_id);
-- Purpose: Supports joins between users and instructors efficiently.

-- ===== COURSES TABLE =====
-- Index for searching/filtering courses by title
CREATE INDEX idx_courses_title ON courses(title);
-- Purpose: Improves performance of course title search queries.

-- Index for filtering by department
CREATE INDEX idx_courses_department ON courses(department_code);
-- Purpose: Speeds up course filtering by department.

-- Composite index for course code + department (already declared elsewhere)
-- Purpose: Supports unique course identification per department.
CREATE UNIQUE INDEX idx_course_code_dept ON courses(code, department_code);

-- ===== COURSE_INSTRUCTORS TABLE =====
-- Index for looking up all instructors of a course
CREATE INDEX idx_ci_course_id ON course_instructors(course_id);
-- Purpose: Enables efficient querying of course instructors.

-- Index for finding all courses taught by a specific instructor
CREATE INDEX idx_ci_instructor_id ON course_instructors(instructor_id);
-- Purpose: Useful in retrieving instructor teaching history.

-- Composite unique index already declared:
-- CREATE UNIQUE INDEX idx_course_instructor_semester ON course_instructors (course_id, instructor_id, semester);

-- ===== REVIEWS TABLE =====
-- Index to get all reviews for a specific course
CREATE INDEX idx_reviews_course_id ON reviews(course_id);
-- Purpose: Speeds up queries that load reviews for a course.

-- Index to get all reviews by a specific user
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
-- Purpose: Enables user review history retrieval.

-- Index to get reviews for an instructor
CREATE INDEX idx_reviews_instructor ON reviews(instructor_id);
-- Purpose: Improves instructor-based review filtering.

-- Index to sort/filter reviews by creation date
CREATE INDEX idx_reviews_created_at ON reviews(created_at);
-- Purpose: Supports chronological review listing (e.g., newest first).

-- ===== REVIEW_VOTES TABLE =====
-- Composite index already declared:
-- CREATE UNIQUE INDEX idx_review_vote ON review_votes (review_id, user_id);

-- Index to retrieve all votes cast by a user
CREATE INDEX idx_review_votes_user_id ON review_votes(user_id);
-- Purpose: Enables showing voting activity per user.

-- ===== ADMINS TABLE =====
-- Index to look up admin by staff ID
CREATE INDEX idx_admins_staff_id ON admins(staff_id);
-- Purpose: Facilitates quick admin account lookups.

-- ===== COURSE_STATISTICS TABLE =====
-- No additional indexes necessary; primary key already on course_id
-- This table is summarised per course and read-heavy, minimal writes.
