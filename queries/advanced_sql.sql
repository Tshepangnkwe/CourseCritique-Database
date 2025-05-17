-- =============================================
-- Enhanced Course Feedback Analytics (Oracle)
-- Author: Lindisipho 
-- =============================================

-- 1. Instructor Analytics with Privacy + Formatting
VARIABLE mask_email CHAR := 'YES';
SELECT 
    i.id,
    INITCAP(i.name) AS formatted_name,
    CASE 
        WHEN :mask_email = 'YES' THEN 
            SUBSTR(i.email, 1, 3) || '***@' || SUBSTR(i.email, INSTR(i.email, '@') + 1)
        ELSE i.email
    END AS masked_email,
    d.name || ' (' || UPPER(d.code) || ')' AS department_full,
    TO_CHAR(MAX(r.review_date), 'Month YYYY') AS last_taught,
    -- Lindisipho's length analysis
    LENGTH(i.name) AS name_length
FROM Instructors i
JOIN Reviews r ON i.id = r.instructor_id
JOIN Departments d ON i.department_code = d.code
GROUP BY i.id, i.name, i.email, d.name, d.code;

-- 2. Time-Based Review Analysis (Hybrid)
VARIABLE days_threshold NUMBER;
EXEC :days_threshold := 90;

SELECT 
    c.code,
    c.title,
    COUNT(r.id) AS recent_reviews,
    -- Your ROUND + Lindisipho's percentage format
    ROUND(AVG(r.rating), 1) || ' (' || 
    ROUND(100 * SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) / COUNT(r.id), 0) || '%)' AS rating_summary,
    -- Combined date formatting
    TO_CHAR(MIN(r.review_date), 'YYYY-MM-DD') || ' to ' || 
    TO_CHAR(MAX(r.review_date), 'YYYY-MM-DD') AS review_period,
    -- Lindisipho's sentiment analysis adapted for Oracle
    CASE
        WHEN REGEXP_LIKE(r.content, 'great|excellent|amazing') THEN 'Positive'
        WHEN REGEXP_LIKE(r.content, 'poor|bad|terrible') THEN 'Negative'
        ELSE 'Neutral'
    END AS dominant_sentiment
FROM Courses c
JOIN Reviews r ON c.id = r.course_id
WHERE r.review_date >= SYSDATE - :days_threshold
GROUP BY c.code, c.title, 
    CASE
        WHEN REGEXP_LIKE(r.content, 'great|excellent|amazing') THEN 'Positive'
        WHEN REGEXP_LIKE(r.content, 'poor|bad|terrible') THEN 'Negative'
        ELSE 'Neutral'
    END
ORDER BY recent_reviews DESC;

-- 3. Comprehensive Department Stats (Combined Features)
SELECT 
    d.code,
    d.name,
    -- Your formatted numbers
    TO_CHAR(AVG(cs.average_rating), '0.0') AS avg_rating,
    -- Lindisipho's would_recommend_pct with Oracle concat
    ROUND(AVG(cs.would_take_again_pct), 0) || '%' AS would_recommend,
    -- Hybrid text analysis
    (SELECT COUNT(*) FROM Reviews r 
     JOIN Courses c ON r.course_id = c.id 
     WHERE c.department_code = d.code
     AND REGEXP_LIKE(r.content, 'great|excellent')) AS positive_keyword_count,
    -- Your time-based subquery
    (SELECT TO_CHAR(MAX(review_date), 'YYYY') FROM Reviews r
     JOIN Courses c ON r.course_id = c.id
     WHERE c.department_code = d.code) AS latest_review_year
FROM Departments d
JOIN Courses c ON d.code = c.department_code
JOIN CourseStatistics cs ON c.id = cs.course_id
GROUP BY d.code, d.name
ORDER BY avg_rating DESC;

-- 4. Instructor Performance Dashboard
VARIABLE min_reviews NUMBER;
EXEC :min_reviews := 5;

SELECT 
    i.name,
    d.name AS department,
    -- Your rating categories
    CASE 
        WHEN AVG(r.rating) >= 4.5 THEN '★★★★★'
        WHEN AVG(r.rating) >= 3.8 THEN '★★★★'
        ELSE '★★★'
    END AS rating_stars,
    -- Combined workload/difficulty analysis
    ROUND(AVG(r.workload_hours), 1) || ' hrs' AS workload,
    ROUND(AVG(r.difficulty), 1) || '/5' AS difficulty,
    -- Lindisipho's anonymized reviewer count
    COUNT(DISTINCT CASE 
        WHEN r.is_anonymous = 1 THEN 'Anon_' || DBMS_RANDOM.STRING('A', 8)
        ELSE u.id
    END) AS unique_reviewers
FROM Instructors i
JOIN Reviews r ON i.id = r.instructor_id
JOIN Users u ON r.user_id = u.id
JOIN Departments d ON i.department_code = d.code
GROUP BY i.name, d.name
HAVING COUNT(r.id) >= :min_reviews
ORDER BY AVG(r.rating) DESC;

-- 5. Course Review Sentiment Timeline (Advanced Hybrid)
SELECT 
    TO_CHAR(r.review_date, 'YYYY-MM') AS month,
    COUNT(r.id) AS review_count,
    -- Your formatted aggregates
    TO_CHAR(AVG(r.rating), '0.00') AS avg_rating,
    -- Lindisipho's sentiment breakdown
    ROUND(100 * SUM(CASE 
        WHEN REGEXP_LIKE(r.content, 'great|excellent') THEN 1 ELSE 0 
    END) / COUNT(r.id), 0) || '%' AS positive_pct,
    -- Your time-trend calculation
    ROUND(
        (AVG(CASE WHEN r.review_date >= ADD_MONTHS(SYSDATE, -3) THEN r.rating END) -
        AVG(CASE WHEN r.review_date BETWEEN ADD_MONTHS(SYSDATE, -6) AND ADD_MONTHS(SYSDATE, -3) 
            THEN r.rating END), 
    2) AS quarterly_trend
FROM Reviews r
WHERE r.status = 'approved'
GROUP BY TO_CHAR(r.review_date, 'YYYY-MM')
ORDER BY month;