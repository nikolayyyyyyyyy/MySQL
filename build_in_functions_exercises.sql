SELECT 
    e.first_name, e.last_name
FROM
    employees AS e
WHERE
    e.first_name LIKE 'Sa%'
ORDER BY e.employee_id;
----------------------------------
SELECT 
    e.first_name, e.last_name
FROM
    employees AS e
WHERE
    e.last_name LIKE '%ei%'
ORDER BY e.employee_id;
----------------------------------
SELECT 
    e.first_name
FROM
    employees AS e
WHERE
    e.department_id IN (3 , 10)
        AND YEAR(e.hire_date) BETWEEN 1995 AND 2005
ORDER BY e.employee_id;
----------------------------------
SELECT 
    e.first_name, e.last_name
FROM
    employees AS e
WHERE
    e.job_title NOT LIKE '%engineer%'
ORDER BY e.employee_id;
----------------------------------
SELECT 
    t.`name`
FROM
    towns AS t
WHERE
    CHAR_LENGTH(t.`name`) = 5
        OR CHAR_LENGTH(t.`name`) = 6
ORDER BY t.`name`;
----------------------------------
SELECT 
    t.town_id, t.`name`
FROM
    towns AS t
WHERE
    SUBSTRING(t.`name`, 1, 1) IN ('M' , 'K', 'B', 'E')
ORDER BY t.`name`;
----------------------------------
SELECT 
    t.town_id, t.`name`
FROM
    towns AS t
WHERE
    SUBSTRING(t.`name`, 1, 1) NOT IN ('R' , 'B', 'D')
ORDER BY t.`name`;
----------------------------------
CREATE VIEW v_employees_hired_after_2000 AS
    SELECT 
        e.first_name, e.last_name
    FROM
        employees AS e
    WHERE
        YEAR(e.hire_date) > 2000;

select * from v_employees_hired_after_2000;
----------------------------------
SELECT 
    e.first_name, e.last_name
FROM
    employees AS e
WHERE
    CHAR_LENGTH(e.last_name) = 5;
----------------------------------
SELECT 
    c.country_name, c.iso_code
FROM
    countries AS c
WHERE
    c.country_name LIKE '%a%a%a%'
ORDER BY c.iso_code;
----------------------------------
SELECT 
    g.`name`, DATE_FORMAT(g.`start`, '%Y-%m-%d') AS 'start'
FROM
    games AS g
WHERE
    YEAR(g.`start`) BETWEEN 2011 AND 2012
ORDER BY g.`start` , g.`name`
LIMIT 50;
----------------------------------
SELECT 
    u.user_name,
    SUBSTRING(u.email,
        LOCATE('@', u.email) + 1) AS 'email_provider'
FROM
    users AS u
ORDER BY SUBSTRING(u.email,
    LOCATE('@', u.email) + 1) , u.user_name;
----------------------------------
SELECT 
    u.user_name, u.ip_address
FROM
    users AS u
WHERE
    u.ip_address LIKE '___.1%.%.___'
ORDER BY u.user_name;
----------------------------------
SELECT 
    g.`name`,
    CASE
        WHEN
            HOUR(g.`start`) >= 0
                AND HOUR(g.`start`) < 12
        THEN
            'Morning'
        WHEN
            HOUR(g.`start`) >= 12
                AND HOUR(g.`start`) < 18
        THEN
            'Afternoon'
        WHEN
            HOUR(g.`start`) >= 18
                AND HOUR(g.`start`) < 24
        THEN
            'Evening'
    END AS 'Part of the Day',
    CASE
        WHEN g.duration <= 3 THEN 'Extra Short'
        WHEN g.duration > 3 AND g.duration <= 6 THEN 'Short'
        WHEN g.duration > 6 AND g.duration <= 10 THEN 'Long'
        ELSE 'Extra Long'
    END AS 'Duration'
FROM
    games AS g;
----------------------------------
SELECT 
    o.product_name,
    o.order_date,
    ADDDATE(o.order_date, INTERVAL 3 DAY) AS 'pay_due',
    ADDDATE(o.order_date, INTERVAL 1 MONTH) AS 'delivery_due'
FROM
    orders AS o;