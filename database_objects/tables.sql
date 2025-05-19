-- Author: Mawela Tshamano Faith

-- Enable UUID extension for PostgreSQL
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Core Tables
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  role VARCHAR(50) NOT NULL,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ
);

CREATE TABLE profiles (
  user_id UUID PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  display_name VARCHAR(100),
  avatar_url VARCHAR(255),
  department VARCHAR(50),
  bio TEXT,
  graduation_year INTEGER,
  CONSTRAINT fk_profile_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE departments (
  code VARCHAR(20) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT
);

-- Academic Structure
CREATE TABLE instructors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  department_code VARCHAR(20),
  office_location VARCHAR(100),
  website_url VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  CONSTRAINT fk_instructor_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_instructor_dept FOREIGN KEY (department_code) REFERENCES departments(code)
);

CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(20) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  credits INTEGER,
  department_code VARCHAR(20) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ,
  CONSTRAINT fk_course_dept FOREIGN KEY (department_code) REFERENCES departments(code),
  CONSTRAINT fk_course_creator FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE course_instructors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  course_id UUID NOT NULL,
  instructor_id UUID NOT NULL,
  semester VARCHAR(20) NOT NULL,
  role VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ,
  CONSTRAINT fk_ci_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  CONSTRAINT fk_ci_instructor FOREIGN KEY (instructor_id) REFERENCES instructors(id) ON DELETE CASCADE
);

-- Review System
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  course_id UUID NOT NULL,
  user_id UUID NOT NULL,
  instructor_id UUID NOT NULL,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  content TEXT,
  difficulty INTEGER CHECK (difficulty BETWEEN 1 AND 5),
  workload_hours INTEGER,
  would_take_again BOOLEAN,
  is_anonymous BOOLEAN DEFAULT FALSE,
  is_verified BOOLEAN DEFAULT FALSE,
  status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ,
  CONSTRAINT fk_review_course FOREIGN KEY (course_id) REFERENCES courses(id),
  CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_review_instructor FOREIGN KEY (instructor_id) REFERENCES instructors(id)
);

CREATE TABLE review_votes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  review_id UUID NOT NULL,
  user_id UUID NOT NULL,
  vote_type VARCHAR(10) NOT NULL CHECK (vote_type IN ('upvote', 'downvote')),
  reason VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_vote_review FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE,
  CONSTRAINT fk_vote_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Admin Functionality
CREATE TABLE admins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL,
  staff_id VARCHAR(50) UNIQUE,
  title VARCHAR(100),
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_admin_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Statistics
CREATE TABLE course_statistics (
  course_id UUID PRIMARY KEY,
  total_reviews INTEGER DEFAULT 0,
  average_rating NUMERIC(3,2),
  average_difficulty NUMERIC(3,2),
  average_workload_hours NUMERIC(5,2),
  would_take_again_pct NUMERIC(5,2) DEFAULT 0,
  last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_stats_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);