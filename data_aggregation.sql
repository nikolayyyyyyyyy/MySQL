SELECT 
    COUNT(*) AS 'count'
FROM
    wizzard_deposits;
--------------------------- 
SELECT 
    MAX(magic_wand_size) AS 'longest_magic_wand'
FROM
    wizzard_deposits;
--------------------------- 
SELECT 
    w.deposit_group,
    MAX(w.magic_wand_size) AS 'longest_magic_wand'
FROM
    wizzard_deposits AS w
GROUP BY w.deposit_group
ORDER BY MAX(w.magic_wand_size) , w.deposit_group;
---------------------------
SELECT 
    w.deposit_group
FROM
    wizzard_deposits AS w
GROUP BY w.deposit_group
ORDER BY AVG(w.magic_wand_size) ASC
LIMIT 1;
---------------------------
SELECT 
    w.deposit_group, SUM(w.deposit_amount) AS total_sum
FROM
    wizzard_deposits AS w
GROUP BY w.deposit_group
ORDER BY total_sum ASC;
---------------------------
SELECT 
    w.deposit_group, SUM(w.deposit_amount) AS total_sum
FROM
    wizzard_deposits AS w
WHERE
    w.magic_wand_creator = 'Ollivander family'
GROUP BY w.deposit_group
ORDER BY w.deposit_group;
---------------------------
SELECT 
    w.deposit_group, SUM(w.deposit_amount) AS total_sum
FROM
    wizzard_deposits AS w
WHERE
    w.magic_wand_creator = 'Ollivander family'
GROUP BY w.deposit_group
HAVING total_sum < 150000
ORDER BY total_sum DESC;
---------------------------
SELECT 
    w.deposit_group,
    w.magic_wand_creator AS magic_wand_creator,
    MIN(w.deposit_charge) AS min_deposit_charge
FROM
    wizzard_deposits AS w
GROUP BY w.deposit_group , w.magic_wand_creator
ORDER BY w.magic_wand_creator , w.deposit_group;
---------------------------
SELECT 
    CASE
        WHEN w.age <= 10 THEN '[0-10]'
        WHEN w.age <= 20 THEN '[11-20]'
        WHEN w.age <= 30 THEN '[21-30]'
        WHEN w.age <= 40 THEN '[31-40]'
        WHEN w.age <= 50 THEN '[41-50]'
        WHEN w.age <= 60 THEN '[51-60]'
        ELSE '[61+]'
    END AS age_group,
    COUNT(w.age) AS wizard_count
FROM
    wizzard_deposits AS w
GROUP BY age_group
ORDER BY COUNT(w.age) ASC;
---------------------------
SELECT 
    SUBSTRING(w.first_name, 1, 1) AS first_letter
FROM
    wizzard_deposits AS w
WHERE
    w.deposit_group = 'Troll Chest'
GROUP BY first_letter
ORDER BY first_letter ASC;
---------------------------
SELECT 
    w.deposit_group,
    w.is_deposit_expired,
    AVG(w.deposit_interest) AS average_interest
FROM
    wizzard_deposits AS w
WHERE
    w.deposit_start_date > '1985-01-01'
GROUP BY w.deposit_group , w.is_deposit_expired
ORDER BY w.deposit_group DESC , w.is_deposit_expired ASC;
---------------------------
SELECT 
    e.department_id, MIN(e.salary) AS minimum_salaty
FROM
    employees AS e
WHERE
    e.hire_date > '2000-01-01'
        AND e.department_id IN (2 , 5, 7)
GROUP BY e.department_id;
---------------------------
CREATE TABLE new_table SELECT * FROM
    employees AS e
WHERE
    e.salary > 30000;

delete from new_table as n
where n.manager_id = 42;

UPDATE new_table AS n 
SET 
    n.salary = n.salary + 5000
WHERE
    n.department_id = 1;

SELECT 
    n.department_id, AVG(n.salary) AS avg_salary
FROM
    new_table AS n
GROUP BY n.department_id
ORDER BY n.department_id ASC;
---------------------------
SELECT 
    e.department_id, MAX(e.salary) AS max_salary
FROM
    employees AS e
GROUP BY e.department_id
HAVING max_salary < 30000 OR max_salary > 70000
ORDER BY e.department_id ASC;
---------------------------
SELECT 
    COUNT(e.employee_id)
FROM
    employees AS e
WHERE
    e.manager_id IS NULL;
---------------------------
SELECT 
    e.department_id, ROUND(SUM(e.salary), 2) AS total_salary
FROM
    employees AS e
GROUP BY e.department_id
ORDER BY e.department_id ASC;