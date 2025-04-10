-- 1.	Find Book Titles
SELECT 
    b.title
FROM
    books AS b
WHERE
    substring(b.title, 1 , 3) = 'The'
ORDER BY b.id;

-- 2.	Replace Titles 
SELECT 
    REPLACE(b.title, 'The', '***')
FROM
    books AS b
WHERE
    SUBSTRING(b.title, 1, 3) = 'The'
    order by b.id;

-- 3.	Sum Cost of All Books
SELECT 
    ROUND(SUM(b.cost), 2) AS price
FROM
    books AS b;

-- 4.    Days Lived
SELECT 
    CONCAT(a.first_name, ' ', a.last_name) AS 'Full Name',
    TIMESTAMPDIFF(DAY, a.born, a.died) AS 'Days Lived'
FROM
    authors AS a;
    
-- 5.	Harry Potter Books
SELECT 
    b.title
FROM
    books AS b
WHERE
    b.title LIKE 'Harry Potter%'
ORDER BY b.id;
    
    
    
    
    
    
    
    
    
    
    
    