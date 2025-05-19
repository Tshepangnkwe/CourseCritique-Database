-- =============================================
-- Test Queries for CourseCritique Database (PostgreSQL)
-- Author: Project Team
-- =============================================

-- 1. Test: Count all departments
SELECT COUNT(*) AS department_count FROM departments;

-- 2. Test: List all active courses
SELECT code, title, department_code
FROM courses
WHERE is_active = TRUE
ORDER BY code;

-- 3. Test: Find instructors with more than 2 assigned courses
SELECT i.name, COUNT(ci.course_id) AS courses_taught
FROM instructors i
JOIN course_instructors ci ON i.id = ci.instructor_id
GROUP BY i.name
HAVING COUNT(ci.course_id) > 2
ORDER BY courses_taught DESC;

-- 4. Test: Get reviews with rating 5
SELECT r.id, c.code AS course_code, r.rating, r.content
FROM reviews r
JOIN courses c ON r.course_id = c.id
WHERE r.rating = 5
ORDER BY r.created_at DESC;

-- 5. Test: Verify course statistics are populated
SELECT c.code, cs.total_reviews, cs.average_rating
FROM courses c
JOIN course_statistics cs ON c.id = cs.course_id
ORDER BY cs.total_reviews DESC;

-- 6. Test: Check for duplicate review votes (should return 0)
SELECT review_id, user_id, COUNT(*) AS vote_count
FROM review_votes
GROUP BY review_id, user_id
HAVING COUNT(*) > 1;

-- 7. Test: List all departments with their number of courses
SELECT d.name AS department, COUNT(c.id) AS course_count
FROM departments d
LEFT JOIN courses c ON d.code = c.department_code
GROUP BY d.name
ORDER BY course_count DESC;