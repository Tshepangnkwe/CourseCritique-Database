-- =============================================
-- Enhanced Course Feedback Analytics (PostgreSQL)
-- Author: Lindisipho 
-- =============================================

-- 1. Instructor Analytics with Privacy + Formatting
-- Note: Use session variables or CTEs for masking logic in PostgreSQL
SELECT 
    i.id,
    INITCAP(i.name) AS formatted_name,
    CASE 
        WHEN TRUE THEN -- Replace with a session variable or parameter if needed
            LEFT(i.email, 3) || '***@' || SPLIT_PART(i.email, '@', 2)
        ELSE i.email
    END AS masked_email,
    d.name || ' (' || UPPER(d.code) || ')' AS department_full,
    TO_CHAR(MAX(r.created_at), 'Month YYYY') AS last_taught,
    LENGTH(i.name) AS name_length
FROM instructors i
JOIN reviews r ON i.id = r.instructor_id
JOIN departments d ON i.department_code = d.code
GROUP BY i.id, i.name, i.email, d.name, d.code;

-- 2. Time-Based Review Analysis (Hybrid)
-- Use a CTE or parameter for days_threshold if needed
WITH recent_reviews AS (
    SELECT 
        c.code,
        c.title,
        COUNT(r.id) AS recent_reviews,
        ROUND(AVG(r.rating), 1)::TEXT || ' (' || 
        ROUND(100.0 * SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) / COUNT(r.id), 0)::TEXT || '%)' AS rating_summary,
        TO_CHAR(MIN(r.created_at), 'YYYY-MM-DD') || ' to ' || 
        TO_CHAR(MAX(r.created_at), 'YYYY-MM-DD') AS review_period,
        MAX(
            CASE
                WHEN r.content ~* 'great|excellent|amazing' THEN 'Positive'
                WHEN r.content ~* 'poor|bad|terrible' THEN 'Negative'
                ELSE 'Neutral'
            END
        ) AS dominant_sentiment
    FROM courses c
    JOIN reviews r ON c.id = r.course_id
    WHERE r.created_at >= NOW() - INTERVAL '90 days'
    GROUP BY c.code, c.title
)
SELECT * FROM recent_reviews
ORDER BY recent_reviews DESC;

-- 3. Comprehensive Department Stats
SELECT 
    d.code,
    d.name,
    TO_CHAR(AVG(cs.average_rating), '0.0') AS avg_rating,
    ROUND(AVG(cs.would_take_again_pct), 0)::TEXT || '%' AS would_recommend,
    (SELECT COUNT(*) FROM reviews r 
     JOIN courses c2 ON r.course_id = c2.id 
     WHERE c2.department_code = d.code
     AND r.content ~* 'great|excellent') AS positive_keyword_count,
    (SELECT TO_CHAR(MAX(r2.created_at), 'YYYY') FROM reviews r2
     JOIN courses c3 ON r2.course_id = c3.id
     WHERE c3.department_code = d.code) AS latest_review_year
FROM departments d
JOIN courses c ON d.code = c.department_code
JOIN course_statistics cs ON c.id = cs.course_id
GROUP BY d.code, d.name
ORDER BY AVG(cs.average_rating) DESC;

-- 4. Instructor Performance Dashboard
SELECT 
    i.name,
    d.name AS department,
    CASE 
        WHEN AVG(r.rating) >= 4.5 THEN '★★★★★'
        WHEN AVG(r.rating) >= 3.8 THEN '★★★★'
        ELSE '★★★'
    END AS rating_stars,
    ROUND(AVG(r.workload_hours), 1)::TEXT || ' hrs' AS workload,
    ROUND(AVG(r.difficulty), 1)::TEXT || '/5' AS difficulty,
    COUNT(DISTINCT 
        CASE 
            WHEN r.is_anonymous THEN r.id
            ELSE u.id
        END
    ) AS unique_reviewers
FROM instructors i
JOIN reviews r ON i.id = r.instructor_id
JOIN users u ON r.user_id = u.id
JOIN departments d ON i.department_code = d.code
GROUP BY i.name, d.name
HAVING COUNT(r.id) >= 5
ORDER BY AVG(r.rating) DESC;

-- 5. Course Review Sentiment Timeline
SELECT 
    TO_CHAR(r.created_at, 'YYYY-MM') AS month,
    COUNT(r.id) AS review_count,
    TO_CHAR(AVG(r.rating), '0.00') AS avg_rating,
    ROUND(100.0 * SUM(CASE 
        WHEN r.content ~* 'great|excellent' THEN 1 ELSE 0 
    END) / COUNT(r.id), 0)::TEXT || '%' AS positive_pct,
    ROUND(
        COALESCE(
            (AVG(CASE 
                WHEN r.created_at >= NOW() - INTERVAL '3 months' THEN r.rating 
                END) -
             AVG(CASE 
                WHEN r.created_at BETWEEN (NOW() - INTERVAL '6 months') AND (NOW() - INTERVAL '3 months')
                THEN r.rating 
                END)
            ), 0
        ), 2
    ) AS quarterly_trend
FROM reviews r
WHERE r.status = 'approved'
GROUP BY TO_CHAR(r.created_at, 'YYYY-MM')
ORDER BY month;