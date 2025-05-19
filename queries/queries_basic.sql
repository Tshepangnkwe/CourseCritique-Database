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
    courses c
JOIN 
    course_statistics cs ON c.id = cs.course_id
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
    courses c
JOIN 
    course_statistics cs ON c.id = cs.course_id
WHERE 
    c.is_active = TRUE
ORDER BY 
    cs.average_rating DESC
LIMIT 5;

-- 3. Sorting by multiple criteria
-- Show courses sorted by rating then review count
SELECT 
    c.code AS course_code,
    d.name AS department,
    c.title,
    cs.average_rating,
    cs.total_reviews
FROM 
    courses c
JOIN 
    departments d ON c.department_code = d.code
JOIN 
    course_statistics cs ON c.id = cs.course_id
ORDER BY 
    cs.average_rating DESC,
    cs.total_reviews DESC;

-- 4. Content search with LIKE
-- Find reviews containing specific keywords
SELECT 
    r.id AS review_id,
    c.code AS course_code,
    SUBSTRING(r.content, 1, 50) || '...' AS review_excerpt,
    r.rating
FROM 
    reviews r
JOIN 
    courses c ON r.course_id = c.id
WHERE 
    r.content ILIKE '%excellent%'
    OR r.content ILIKE '%challenging%'
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
    courses c
JOIN 
    course_statistics cs ON c.id = cs.course_id
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
    reviews r
JOIN 
    courses c ON r.course_id = c.id
JOIN 
    users u ON r.user_id = u.id
ORDER BY 
    r.created_at DESC
OFFSET 10 LIMIT 10;

-- 7. Department-specific queries
-- Find CS courses with good ratings
SELECT 
    c.code,
    c.title,
    cs.average_rating,
    d.name AS department
FROM 
    courses c
JOIN 
    course_statistics cs ON c.id = cs.course_id
JOIN 
    departments d ON c.department_code = d.code
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
    reviews r
JOIN 
    courses c ON r.course_id = c.id
JOIN 
    instructors i ON r.instructor_id = i.id
WHERE 
    i.name ILIKE '%Smith%'
ORDER BY 
    r.rating DESC;