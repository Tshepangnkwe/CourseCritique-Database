-- Advanced Queries for CourseCritique Database
-- Author: Tshepang (Group Lead)
-- PostgreSQL version: uses lower-case table/column names and PostgreSQL functions

-- ========== COMPLEX JOIN QUERIES ==========

-- 1. Comprehensive Course Information with Department and Statistics
SELECT 
    c.id AS course_id,
    c.code AS course_code,
    c.title AS course_title,
    d.name AS department_name,
    cs.average_rating,
    cs.average_difficulty,
    cs.total_reviews,
    cs.would_take_again_pct AS "Would Take Again %",
    u.email AS created_by_email
FROM 
    courses c
    JOIN departments d ON c.department_code = d.code
    JOIN course_statistics cs ON c.id = cs.course_id
    JOIN users u ON c.created_by = u.id
WHERE 
    c.is_active = TRUE
ORDER BY 
    cs.average_rating DESC, cs.total_reviews DESC;

-- 2. Instructor Performance Across All Courses
SELECT 
    i.name AS instructor_name,
    d.name AS department_name,
    c.code AS course_code,
    c.title AS course_title,
    COUNT(r.id) AS review_count,
    ROUND(AVG(r.rating), 2) AS average_rating,
    ROUND(AVG(r.difficulty), 2) AS difficulty,
    ROUND(AVG(r.workload_hours), 1) AS "Avg Weekly Hours",
    ROUND(100 * SUM(CASE WHEN r.would_take_again THEN 1 ELSE 0 END)::NUMERIC / NULLIF(COUNT(r.id), 0), 0) AS "Would Take Again %"
FROM 
    instructors i
    JOIN departments d ON i.department_code = d.code
    JOIN course_instructors ci ON i.id = ci.instructor_id
    JOIN courses c ON ci.course_id = c.id
    LEFT JOIN reviews r ON c.id = r.course_id AND i.id = r.instructor_id
GROUP BY 
    i.name, d.name, c.code, c.title
HAVING 
    COUNT(r.id) >= 5
ORDER BY 
    average_rating DESC;

-- 3. Multi-level Join for Student Review Analysis
SELECT 
    p.display_name AS student_name,
    d.name AS student_department,
    c.code AS course_code,
    c.title AS course_title,
    r.rating,
    r.difficulty,
    r.workload_hours,
    r.created_at AS review_date,
    COUNT(rv.id) AS helpful_votes
FROM 
    users u
    JOIN profiles p ON u.id = p.user_id
    JOIN reviews r ON u.id = r.user_id
    JOIN courses c ON r.course_id = c.id
    JOIN departments d ON p.department = d.code
    LEFT JOIN review_votes rv ON r.id = rv.review_id AND rv.vote_type = 'upvote'
WHERE 
    u.role = 'student'
    AND r.status = 'approved'
GROUP BY 
    p.display_name, d.name, c.code, c.title, r.rating, r.difficulty, r.workload_hours, r.created_at
ORDER BY 
    helpful_votes DESC, r.created_at DESC;

-- ========== SUBQUERY EXAMPLES ==========

-- 4. Courses with Above-Average Ratings
SELECT 
    c.code,
    c.title,
    d.name AS department,
    cs.average_rating
FROM 
    courses c
    JOIN departments d ON c.department_code = d.code
    JOIN course_statistics cs ON c.id = cs.course_id
WHERE 
    cs.average_rating > (
        SELECT AVG(average_rating) 
        FROM course_statistics
    )
    AND cs.total_reviews >= 5
ORDER BY 
    cs.average_rating DESC;

-- 5. Instructors Teaching Multiple Courses
SELECT 
    i.name AS instructor_name,
    i.department_code,
    (
        SELECT COUNT(DISTINCT ci.course_id) 
        FROM course_instructors ci 
        WHERE ci.instructor_id = i.id
    ) AS courses_taught,
    (
        SELECT ROUND(AVG(r.rating), 2)
        FROM reviews r
        WHERE r.instructor_id = i.id
    ) AS average_rating
FROM 
    instructors i
WHERE 
    (
        SELECT COUNT(DISTINCT ci.course_id) 
        FROM course_instructors ci 
        WHERE ci.instructor_id = i.id
    ) > 1
ORDER BY 
    courses_taught DESC, average_rating DESC;

-- 6. Most Active Reviewers
SELECT 
    review_counts.display_name,
    review_counts.department,
    review_counts.review_count,
    review_counts.avg_rating
FROM (
    SELECT 
        p.display_name,
        p.department,
        COUNT(r.id) AS review_count,
        ROUND(AVG(r.rating), 2) AS avg_rating
    FROM 
        users u
        JOIN profiles p ON u.id = p.user_id
        JOIN reviews r ON u.id = r.user_id
    WHERE 
        u.role = 'student'
    GROUP BY 
        p.display_name, p.department
) review_counts
WHERE 
    review_counts.review_count > 5
ORDER BY 
    review_counts.review_count DESC;

-- ========== AGGREGATE AND GROUP BY QUERIES ==========

-- 7. Department Performance Analysis
SELECT 
    d.name AS department_name,
    COUNT(DISTINCT c.id) AS course_count,
    ROUND(AVG(cs.average_rating), 2) AS avg_department_rating,
    ROUND(AVG(cs.average_difficulty), 2) AS avg_difficulty,
    ROUND(AVG(cs.average_workload_hours), 1) AS avg_weekly_hours,
    ROUND(AVG(cs.would_take_again_pct), 0) AS avg_would_take_again_pct,
    COUNT(DISTINCT i.id) AS instructor_count
FROM 
    departments d
    JOIN courses c ON d.code = c.department_code
    JOIN course_statistics cs ON c.id = cs.course_id
    JOIN course_instructors ci ON c.id = ci.course_id
    JOIN instructors i ON ci.instructor_id = i.id
GROUP BY 
    d.name
HAVING 
    COUNT(DISTINCT c.id) >= 3
ORDER BY 
    avg_department_rating DESC;

-- 8. Course Review Trend Analysis by Time Period
SELECT 
    TO_CHAR(r.created_at, 'YYYY-MM') AS month,
    COUNT(r.id) AS review_count,
    ROUND(AVG(r.rating), 2) AS average_rating,
    ROUND(AVG(r.difficulty), 2) AS average_difficulty,
    ROUND(AVG(r.workload_hours), 1) AS average_workload,
    ROUND(100 * SUM(CASE WHEN r.would_take_again THEN 1 ELSE 0 END)::NUMERIC / COUNT(*), 0) AS would_take_again_pct
FROM 
    reviews r
GROUP BY 
    TO_CHAR(r.created_at, 'YYYY-MM')
ORDER BY 
    month DESC;

-- 9. Anonymous vs. Verified Review Analysis
SELECT 
    CASE WHEN r.is_anonymous THEN 'Anonymous' ELSE 'Identified' END AS review_type,
    CASE WHEN r.is_verified THEN 'Verified' ELSE 'Unverified' END AS verification_status,
    COUNT(r.id) AS review_count,
    ROUND(AVG(r.rating), 2) AS average_rating,
    ROUND(AVG(r.difficulty), 2) AS average_difficulty,
    ROUND(100 * SUM(CASE WHEN r.would_take_again THEN 1 ELSE 0 END)::NUMERIC / COUNT(*), 0) AS would_take_again_pct
FROM 
    reviews r
GROUP BY 
    r.is_anonymous, r.is_verified
ORDER BY 
    review_type, verification_status;

-- ========== INTEGRATION QUERIES ==========

-- 10. Comprehensive Dashboard Query
SELECT 
    d.name AS department,
    COUNT(DISTINCT c.id) AS courses,
    COUNT(DISTINCT i.id) AS instructors,
    COUNT(DISTINCT r.user_id) AS reviewers,
    COUNT(r.id) AS total_reviews,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    ROUND(AVG(cs.average_difficulty), 2) AS avg_difficulty,
    ROUND(AVG(cs.would_take_again_pct), 0) AS would_take_again_pct,
    (
        SELECT c_inner.title
        FROM courses c_inner
        JOIN course_statistics cs_inner ON c_inner.id = cs_inner.course_id
        WHERE c_inner.department_code = d.code
        ORDER BY cs_inner.average_rating DESC, cs_inner.total_reviews DESC
        LIMIT 1
    ) AS top_rated_course,
    (
        SELECT i_inner.name
        FROM instructors i_inner
        WHERE i_inner.department_code = d.code
        AND EXISTS (
            SELECT 1 FROM reviews r_inner
            WHERE r_inner.instructor_id = i_inner.id
            GROUP BY r_inner.instructor_id
            HAVING AVG(r_inner.rating) = (
                SELECT MAX(avg_rating)
                FROM (
                    SELECT AVG(r_sub.rating) AS avg_rating
                    FROM reviews r_sub
                    JOIN instructors i_sub ON r_sub.instructor_id = i_sub.id
                    WHERE i_sub.department_code = d.code
                    GROUP BY r_sub.instructor_id
                    HAVING COUNT(r_sub.id) >= 5
                ) AS subq
            )
        )
        LIMIT 1
    ) AS top_rated_instructor
FROM 
    departments d
    LEFT JOIN courses c ON d.code = c.department_code
    LEFT JOIN course_statistics cs ON c.id = cs.course_id
    LEFT JOIN course_instructors ci ON c.id = ci.course_id
    LEFT JOIN instructors i ON ci.instructor_id = i.id
    LEFT JOIN reviews r ON c.id = r.course_id
GROUP BY 
    d.name, d.code
ORDER BY 
    total_reviews DESC;