-- =============================================
-- Basic Queries
-- Author: Lehlohonolo Ntsane
-- =============================================

-- 1. Courses with specific rating criteria
-- Find courses with average rating >= 4.0 and at least 10 reviews
SELECT 
    c.code AS course_code,
    c.title AS course_title,
    ROUND(cs.average_rating, 2) AS avg_rating,
    cs.total_reviews
FROM 
    Courses c
JOIN 
    CourseStatistics cs ON c.id = cs.course_id
WHERE 
    cs.average_rating >= 4.0
    AND cs.total_reviews >= 10
ORDER BY 
    cs.average_rating DESC;

-- 2. Limited results with specific columns
-- Get top 5 highest rated courses (limited columns)
SELECT 
    c.code AS course_code,
    c.title AS course_title,
    cs.average_rating
FROM 
    Courses c
JOIN 
    CourseStatistics cs ON c.id = cs.course_id
WHERE 
    c.is_active = 1
ORDER BY 
    cs.average_rating DESC
FETCH FIRST 5 ROWS ONLY;

-- 3. Sorting by multiple criteria
-- Show courses sorted by rating then review count
SELECT 
    c.code AS course_code,
    d.name AS department,
    c.title,
    cs.average_rating,
    cs.total_reviews
FROM 
    Courses c
JOIN 
    Departments d ON c.department_code = d.code
JOIN 
    CourseStatistics cs ON c.id = cs.course_id
ORDER BY 
    cs.average_rating DESC,
    cs.total_reviews DESC;

-- 4. Content search with LIKE
-- Find reviews containing specific keywords
SELECT 
    r.id AS review_id,
    c.code AS course_code,
    SUBSTR(r.content, 1, 50) || '...' AS review_excerpt,
    r.rating
FROM 
    Reviews r
JOIN 
    Courses c ON r.course_id = c.id
WHERE 
    r.content LIKE '%excellent%'
    OR r.content LIKE '%challenging%'
ORDER BY 
    r.rating DESC;

-- 5. Combined conditions with AND/OR
-- Find difficult but rewarding courses
SELECT 
    c.code,
    c.title,
    cs.average_rating,
    cs.average_difficulty,
    cs.would_take_again_pct
FROM 
    Courses c
JOIN 
    CourseStatistics cs ON c.id = cs.course_id
WHERE 
    (cs.average_difficulty >= 3.5 AND cs.average_rating >= 3.8)
    OR (cs.average_difficulty >= 4.0 AND cs.would_take_again_pct >= 70)
ORDER BY 
    cs.average_difficulty DESC;

-- 6. Pagination example
-- Get second page of reviews (rows 11-20)
SELECT 
    r.id,
    c.code AS course_code,
    u.email AS user_email,
    r.rating,
    r.created_at
FROM 
    Reviews r
JOIN 
    Courses c ON r.course_id = c.id
JOIN 
    Users u ON r.user_id = u.id
ORDER BY 
    r.created_at DESC
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;

-- 7. Department-specific queries
-- Find CS courses with good ratings
SELECT 
    c.code,
    c.title,
    cs.average_rating,
    d.name AS department
FROM 
    Courses c
JOIN 
    CourseStatistics cs ON c.id = cs.course_id
JOIN 
    Departments d ON c.department_code = d.code
WHERE 
    d.code = 'CS'
    AND cs.average_rating > 3.5
ORDER BY 
    cs.total_reviews DESC;

-- 8. Instructor-based filtering
-- Find reviews for a specific instructor
SELECT 
    i.name AS instructor,
    c.code AS course_code,
    r.rating,
    r.content
FROM 
    Reviews r
JOIN 
    Courses c ON r.course_id = c.id
JOIN 
    Instructors i ON r.instructor_id = i.id
WHERE 
    i.name LIKE '%Smith%'
ORDER BY 
    r.rating DESC;