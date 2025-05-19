-- =============================================
-- Views for CourseCritique (PostgreSQL)
-- Author: S Masiya
-- =============================================

-- View 1: ActiveCourses
CREATE OR REPLACE VIEW active_courses AS
SELECT 
    c.id AS course_id,
    c.title AS course_title,
    c.description AS course_description,
    d.name AS department_name,
    i.name AS instructor_name,
    c.created_at AS creation_date,
    c.is_active
FROM 
    courses c
JOIN 
    departments d ON c.department_code = d.code
JOIN 
    course_instructors ci ON c.id = ci.course_id AND ci.role = 'Primary'
JOIN 
    instructors i ON ci.instructor_id = i.id
WHERE 
    c.is_active = TRUE
ORDER BY 
    d.name, c.title;

-- Materialized version (PostgreSQL syntax)
CREATE MATERIALIZED VIEW mv_active_courses
AS
SELECT * FROM active_courses
WITH NO DATA;

-- To refresh: REFRESH MATERIALIZED VIEW mv_active_courses;

-- Indexes for materialized view
CREATE INDEX idx_mvac_course ON mv_active_courses(course_id);
CREATE INDEX idx_mvac_dept ON mv_active_courses(department_name);

-- View 2: VerifiedReviews
CREATE OR REPLACE VIEW verified_reviews AS
SELECT
    r.id AS review_id,
    r.user_id,
    CASE 
        WHEN r.is_anonymous THEN 'Anonymous'
        ELSE u.email
    END AS user_name,
    r.course_id,
    c.title AS course_title,
    r.instructor_id,
    i.name AS instructor_name,
    r.rating,
    r.content AS comment,
    r.created_at AS review_date,
    r.is_anonymous,
    ROW_NUMBER() OVER (PARTITION BY r.course_id ORDER BY r.created_at DESC) AS review_rank
FROM 
    reviews r
JOIN 
    users u ON r.user_id = u.id
JOIN 
    courses c ON r.course_id = c.id
JOIN 
    instructors i ON r.instructor_id = i.id
WHERE 
    u.is_verified = TRUE
    AND r.status = 'approved';

-- View 3: InstructorRatings
CREATE OR REPLACE VIEW instructor_ratings AS
SELECT 
    i.id AS instructor_id,
    i.name AS instructor_name,
    d.name AS department_name,
    COUNT(r.id) AS review_count,
    ROUND(AVG(r.rating)::NUMERIC, 2) AS average_rating,
    ROUND(AVG(r.difficulty)::NUMERIC, 2) AS average_difficulty,
    ROUND(STDDEV_POP(r.rating)::NUMERIC, 2) AS rating_stddev,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY r.rating) AS median_rating
FROM 
    instructors i
JOIN 
    departments d ON i.department_code = d.code
LEFT JOIN 
    reviews r ON i.id = r.instructor_id AND r.status = 'approved'
GROUP BY 
    i.id, i.name, d.name
HAVING 
    COUNT(r.id) > 3
ORDER BY 
    average_rating DESC;

-- Materialized version
CREATE MATERIALIZED VIEW mv_instructor_performance
AS
SELECT * FROM instructor_ratings
WITH NO DATA;

-- To refresh: REFRESH MATERIALIZED VIEW mv_instructor_performance;

-- Indexes for materialized view
CREATE INDEX idx_mvip_instructor ON mv_instructor_performance(instructor_id);
CREATE INDEX idx_mvip_dept ON mv_instructor_performance(department_name);
CREATE INDEX idx_mvip_rating ON mv_instructor_performance(average_rating);

-- View 4: DepartmentCourseSummary
CREATE OR REPLACE VIEW department_course_summary AS
SELECT 
    d.code AS department_code,
    d.name AS department_name,
    COUNT(DISTINCT c.id) AS number_of_courses,
    COUNT(DISTINCT i.id) AS number_of_instructors,
    ROUND(AVG(cs.average_rating)::NUMERIC, 2) AS average_course_rating,
    COUNT(r.id) AS total_reviews,
    ROUND(
        SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END)::NUMERIC / NULLIF(COUNT(r.id), 0) * 100, 1
    ) AS percent_positive_reviews
FROM 
    departments d
LEFT JOIN 
    courses c ON d.code = c.department_code AND c.is_active = TRUE
LEFT JOIN 
    course_statistics cs ON c.id = cs.course_id
LEFT JOIN 
    course_instructors ci ON c.id = ci.course_id
LEFT JOIN 
    instructors i ON ci.instructor_id = i.id
LEFT JOIN 
    reviews r ON c.id = r.course_id AND r.status = 'approved'
GROUP BY 
    d.code, d.name
ORDER BY 
    average_course_rating DESC NULLS LAST;

-- Materialized version
CREATE MATERIALIZED VIEW mv_department_stats
AS
SELECT * FROM department_course_summary
WITH NO DATA;

-- To refresh: REFRESH MATERIALIZED VIEW mv_department_stats;

-- ======================
-- Additional Optimizations
-- ======================

-- Create base table indexes to support views
CREATE INDEX idx_review_status ON reviews(status);
CREATE INDEX idx_course_active ON courses(is_active);
CREATE INDEX idx_user_verified ON users(is_verified);

-- Create view comments for documentation
COMMENT ON MATERIALIZED VIEW mv_instructor_performance IS 'Materialized view of instructor ratings, refreshed manually for analytics.';
COMMENT ON MATERIALIZED VIEW mv_department_stats IS 'Materialized view of department statistics, refreshed manually for analytics.';