-- Author: Mawela Tshamano Faith

-- Enable UUID generation if needed
CREATE OR REPLACE FUNCTION generate_uuid RETURN RAW IS
BEGIN
  RETURN SYS_GUID();
END;
/

-- Core Tables
CREATE TABLE users (
  id RAW(16) PRIMARY KEY DEFAULT generate_uuid(),
  email VARCHAR2(255) UNIQUE NOT NULL,
  role VARCHAR2(50) NOT NULL,
  is_verified NUMBER(1) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE profiles (
  user_id RAW(16) PRIMARY KEY,
  first_name VARCHAR2(100),
  last_name VARCHAR2(100),
  display_name VARCHAR2(100),
  avatar_url VARCHAR2(255),
  department VARCHAR2(50),
  bio CLOB,
  graduation_year NUMBER(4),
  CONSTRAINT fk_profile_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE departments (
  code VARCHAR2(20) PRIMARY KEY,
  name VARCHAR2(100) NOT NULL,
  description CLOB
);

-- Academic Structure
CREATE TABLE instructors (
  id RAW(16) PRIMARY KEY DEFAULT generate_uuid(),
  user_id RAW(16),
  name VARCHAR2(100) NOT NULL,
  email VARCHAR2(255) UNIQUE NOT NULL,
  department_code VARCHAR2(20),
  office_location VARCHAR2(100),
  website_url VARCHAR2(255),
  is_active NUMBER(1) DEFAULT 1,
  CONSTRAINT fk_instructor_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_instructor_dept FOREIGN KEY (department_code) REFERENCES departments(code)
);

CREATE TABLE courses (
  id RAW(16) PRIMARY KEY DEFAULT generate_uuid(),
  code VARCHAR2(20) NOT NULL,
  title VARCHAR2(255) NOT NULL,
  description CLOB,
  credits NUMBER(2),
  department_code VARCHAR2(20) NOT NULL,
  is_active NUMBER(1) DEFAULT 1,
  created_by RAW(16) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE,
  CONSTRAINT fk_course_dept FOREIGN KEY (department_code) REFERENCES departments(code),
  CONSTRAINT fk_course_creator FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE course_instructors (
  id RAW(16) PRIMARY KEY DEFAULT generate_uuid(),
  course_id RAW(16) NOT NULL,
  instructor_id RAW(16) NOT NULL,
  semester VARCHAR2(20) NOT NULL,
  role VARCHAR2(50),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE,
  CONSTRAINT fk_ci_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  CONSTRAINT fk_ci_instructor FOREIGN KEY (instructor_id) REFERENCES instructors(id) ON DELETE CASCADE
);

-- Review System
CREATE TABLE reviews (
  id RAW(16) PRIMARY KEY DEFAULT generate_uuid(),
  course_id RAW(16) NOT NULL,
  user_id RAW(16) NOT NULL,
  instructor_id RAW(16) NOT NULL,
  rating NUMBER(1) NOT NULL,
  content CLOB,
  difficulty NUMBER(1),
  workload_hours NUMBER(2),
  would_take_again NUMBER(1),
  is_anonymous NUMBER(1) DEFAULT 0,
  is_verified NUMBER(1) DEFAULT 0,
  status VARCHAR2(20) DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE,
  CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT chk_difficulty CHECK (difficulty BETWEEN 1 AND 5),
  CONSTRAINT fk_review_course FOREIGN KEY (course_id) REFERENCES courses(id),
  CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_review_instructor FOREIGN KEY (instructor_id) REFERENCES instructors(id)
);

CREATE TABLE review_votes (
  id RAW(16) PRIMARY KEY DEFAULT generate_uuid(),
  review_id RAW(16) NOT NULL,
  user_id RAW(16) NOT NULL,
  vote_type VARCHAR2(10) NOT NULL,
  reason VARCHAR2(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
  CONSTRAINT chk_vote_type CHECK (vote_type IN ('upvote', 'downvote')),
  CONSTRAINT fk_vote_review FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE,
  CONSTRAINT fk_vote_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Admin Functionality
CREATE TABLE admins (
  id RAW(16) PRIMARY KEY DEFAULT generate_uuid(),
  user_id RAW(16) UNIQUE NOT NULL,
  staff_id VARCHAR2(50) UNIQUE,
  title VARCHAR2(100),
  last_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
  CONSTRAINT fk_admin_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Statistics
CREATE TABLE course_statistics (
  course_id RAW(16) PRIMARY KEY,
  total_reviews NUMBER DEFAULT 0,
  average_rating NUMBER(3,2),
  average_difficulty NUMBER(3,2),
  average_workload_hours NUMBER(5,2),
  would_take_again_pct NUMBER(5,2) DEFAULT 0,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
  CONSTRAINT fk_stats_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- Indexes
CREATE UNIQUE INDEX idx_course_code_dept ON courses (code, department_code);
CREATE UNIQUE INDEX idx_course_instructor_semester ON course_instructors (course_id, instructor_id, semester);
CREATE UNIQUE INDEX idx_review_vote ON review_votes (review_id, user_id);

-- Additional indexes for performance
CREATE INDEX idx_reviews_course ON reviews (course_id);
CREATE INDEX idx_reviews_instructor ON reviews (instructor_id);
CREATE INDEX idx_reviews_user ON reviews (user_id);
CREATE INDEX idx_course_instructors_course ON course_instructors (course_id);
CREATE INDEX idx_course_instructors_instructor ON course_instructors (instructor_id);