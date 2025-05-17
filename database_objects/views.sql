-- =============================================
-- Views for CourseCritique
-- Author: S Masiya
-- =============================================

-- View 1: ActiveCourses with Materialized Option
CREATE OR REPLACE VIEW ActiveCourses AS
SELECT 
    c.course_id,
    c.title AS course_title,
    c.description AS course_description,
    d.department_name,
    u.first_name || ' ' || u.last_name AS instructor_name,
    c.creation_date,
    c.is_active
FROM 
    Course c
JOIN 
    Department d ON c.department_id = d.department_id
JOIN 
    CourseInstructor ci ON c.course_id = ci.course_id
    AND ci.is_primary = 1  -- Added to identify primary instructors
JOIN 
    Instructor i ON ci.instructor_id = i.instructor_id
JOIN 
    User u ON i.user_id = u.user_id
WHERE 
    c.is_active = 1
ORDER BY 
    d.department_name, c.title;

-- Materialized version with refresh schedule
CREATE MATERIALIZED VIEW MV_ActiveCourses
REFRESH COMPLETE NEXT SYSDATE + 1  -- Daily refresh
AS SELECT * FROM ActiveCourses;

-- Indexes for materialized view
CREATE INDEX idx_mvac_course ON MV_ActiveCourses(course_id);
CREATE INDEX idx_mvac_dept ON MV_ActiveCourses(department_name);

-- View 2: VerifiedReviews with Performance Optimizations
CREATE OR REPLACE VIEW VerifiedReviews AS
SELECT /*+ INDEX(r review_status_idx) */  -- Hint to use status index
    r.review_id,
    r.user_id,
    CASE 
        WHEN r.is_anonymous = 1 THEN 'Anonymous'
        ELSE u.first_name || ' ' || u.last_name 
    END AS user_name,
    r.course_id,
    c.title AS course_title,
    r.instructor_id,
    i.first_name || ' ' || i.last_name AS instructor_name,
    r.rating,
    r.comment,
    r.review_date,
    r.is_anonymous,
    ROW_NUMBER() OVER (PARTITION BY r.course_id ORDER BY r.review_date DESC) AS review_rank
FROM 
    Review r
JOIN 
    User u ON r.user_id = u.user_id
JOIN 
    Course c ON r.course_id = c.course_id
JOIN 
    Instructor i ON r.instructor_id = i.instructor_id
WHERE 
    u.is_verified = 1
    AND r.status = 'approved';

-- View 3: InstructorRatings with Advanced Analytics
CREATE OR REPLACE VIEW InstructorRatings AS
SELECT 
    i.instructor_id,
    i.first_name || ' ' || i.last_name AS instructor_name,
    d.department_name,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.rating), 2) AS average_rating,
    ROUND(AVG(r.difficulty), 2) AS average_difficulty,
    ROUND(STDDEV(r.rating), 2) AS rating_stddev,  -- Added variability measure
    MEDIAN(r.rating) AS median_rating  -- Added robust central tendency
FROM 
    Instructor i
JOIN 
    Department d ON i.department_id = d.department_id
LEFT JOIN 
    Review r ON i.instructor_id = r.instructor_id
    AND r.status = 'approved'
GROUP BY 
    i.instructor_id, i.first_name, i.last_name, d.department_name
HAVING 
    COUNT(r.review_id) > 3  -- Only show instructors with sufficient reviews
ORDER BY 
    average_rating DESC;

-- Materialized version with query rewrite enabled
CREATE MATERIALIZED VIEW MV_InstructorPerformance
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE  -- Allows optimizer to use this instead of base tables
AS SELECT * FROM InstructorRatings;

-- Indexes for materialized view
CREATE INDEX idx_mvip_instructor ON MV_InstructorPerformance(instructor_id);
CREATE INDEX idx_mvip_dept ON MV_InstructorPerformance(department_name);
CREATE INDEX idx_mvip_rating ON MV_InstructorPerformance(average_rating);

-- View 4: DepartmentCourseSummary with Enhanced Metrics
CREATE OR REPLACE VIEW DepartmentCourseSummary AS
SELECT 
    d.department_id,
    d.department_name,
    COUNT(DISTINCT c.course_id) AS number_of_courses,
    COUNT(DISTINCT i.instructor_id) AS number_of_instructors,
    ROUND(AVG(cs.average_rating), 2) AS average_course_rating,
    COUNT(r.review_id) AS total_reviews,
    ROUND(SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) / 
          NULLIF(COUNT(r.review_id), 0) * 100, 1) AS percent_positive_reviews
FROM 
    Department d
LEFT JOIN 
    Course c ON d.department_id = c.department_id AND c.is_active = 1
LEFT JOIN 
    CourseStatistics cs ON c.course_id = cs.course_id
LEFT JOIN 
    Instructor i ON d.department_id = i.department_id
LEFT JOIN 
    Review r ON c.course_id = r.course_id AND r.status = 'approved'
GROUP BY 
    d.department_id, d.department_name
ORDER BY 
    average_course_rating DESC NULLS LAST;

-- Materialized version without partitioned refresh (partitioning removed)
CREATE MATERIALIZED VIEW MV_DepartmentStats
REFRESH FORCE ON DEMAND
AS SELECT * FROM DepartmentCourseSummary;

-- ======================
-- Additional Optimizations
-- ======================

-- Create base table indexes to support views
CREATE INDEX idx_review_status ON Review(status) COMPUTE STATISTICS;
CREATE INDEX idx_course_active ON Course(is_active) COMPUTE STATISTICS;
CREATE INDEX idx_user_verified ON User(is_verified) COMPUTE STATISTICS;

-- Create view comments for documentation
COMMENT ON MATERIALIZED VIEW MV_InstructorPerformance IS 'Materialized view of instructor ratings with query rewrite enabled, refreshed on demand';
COMMENT ON MATERIALIZED VIEW MV_DepartmentStats IS 'Partitioned materialized view of department statistics with force refresh option';