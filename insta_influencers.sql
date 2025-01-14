CREATE DATABASE insta_influencers;

CREATE TABLE users (
    id INT PRIMARY KEY,
    username VARCHAR(30) UNIQUE NOT NULL,
    `password` VARCHAR(30) NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    gender CHAR(1) NOT NULL,
    age INT NOT NULL,
    job_title VARCHAR(40) NOT NULL,
    ip VARCHAR(30) NOT NULL,
    CONSTRAINT gender_ck CHECK (gender IN ('M' , 'F'))
);

CREATE TABLE addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    address VARCHAR(30) NOT NULL,
    town VARCHAR(30) NOT NULL,
    country VARCHAR(30) NOT NULL,
    user_id INT NOT NULL,
    CONSTRAINT user_address_fk FOREIGN KEY (user_id)
        REFERENCES users (id)
);

CREATE TABLE photos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `description` TEXT NOT NULL,
    `date` DATETIME NOT NULL,
    views INT NOT NULL
);

CREATE TABLE comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `comment` VARCHAR(255) NOT NULL,
    `date` DATETIME NOT NULL,
    photo_id INT NOT NULL,
    CONSTRAINT photo_comment_fk FOREIGN KEY (photo_id)
        REFERENCES photos (id)
);

CREATE TABLE users_photos (
    user_id INT NOT NULL,
    photo_id INT NOT NULL,
    CONSTRAINT user_photos_fk FOREIGN KEY (user_id)
        REFERENCES users (id),
    CONSTRAINT photo_user_fk FOREIGN KEY (photo_id)
        REFERENCES photos (id)
);

CREATE TABLE likes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    photo_id INT NOT NULL,
    user_id INT NOT NULL,
    CONSTRAINT photo_like_fk FOREIGN KEY (photo_id)
        REFERENCES photos (id),
    CONSTRAINT user_like_fk FOREIGN KEY (user_id)
        REFERENCES users (id)
);

START TRANSACTION;
SET sql_safe_updates = 0;
UPDATE addresses AS a 
SET 
    a.country = CASE
        WHEN LEFT(a.country, 1) = 'B' THEN 'Blocked'
        WHEN LEFT(a.country, 1) = 'T' THEN 'Test'
        WHEN LEFT(a.country, 1) = 'P' THEN 'In Progress'
        ELSE a.country
    END;
    
	
    DELETE FROM addresses as a WHERE a.id % 3 = 0;
ROLLBACK;
COMMIT;

/*All users*/
SELECT 
    u.username, u.gender, u.age
FROM
    users AS u
ORDER BY u.age DESC , u.username;

/*Extract 5 Most Commented Photos*/
SELECT 
    p.id,
    p.`date` AS 'date_and_time',
    p.`description`,
    COUNT(c.id) AS 'commentsCount'
FROM
    photos AS p
        JOIN
    comments AS c ON c.photo_id = p.id
GROUP BY p.id , p.`date` , p.`description`
ORDER BY COUNT(c.id) DESC , p.id
LIMIT 5;

/*Lucky users*/
SELECT 
    CONCAT_WS(' ', u.id, u.username) AS 'id_username', u.email
FROM
    users AS u
        JOIN
    users_photos AS up ON up.user_id = u.id
        JOIN
    photos AS p ON p.id = up.photo_id
WHERE
    u.id = p.id
ORDER BY u.id;

/*Count likes and comments*/
SELECT 
    p.id,
    COUNT(DISTINCT (l.id)) AS 'likes_count',
    COUNT(DISTINCT (c.id)) AS 'comments_count'
FROM
    photos AS p
        LEFT JOIN
    likes AS l ON l.photo_id = p.id
        LEFT JOIN
    comments AS c ON c.photo_id = p.id
GROUP BY p.id
ORDER BY COUNT(DISTINCT (l.id)) DESC , COUNT(DISTINCT (c.id)) DESC , p.id;

/*The photo on the tenth day of the month*/
SELECT 
    CONCAT(LEFT(p.`description`, 30), '...') AS 'summary',
    p.`date`
FROM
    photos AS p
WHERE
    DAY(p.`date`) = 10
ORDER BY p.`date` DESC;

/*Get User's Photos Count*/
DELIMITER $$
CREATE FUNCTION udf_users_photos_count(username VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT
				COUNT(*) AS "photosCount"
			FROM users AS u
            JOIN users_photos AS up ON up.user_id = u.id
            JOIN photos AS p ON p.id = up.photo_id
            WHERE u.username = username);
END$$
DELIMITER ;

SELECT udf_users_photos_count('ssantryd') AS photosCount;
