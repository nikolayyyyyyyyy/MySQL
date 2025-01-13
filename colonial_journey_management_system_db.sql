CREATE DATABASE colonial_journey_management_system_db;

CREATE TABLE planets (
    id INT PRIMARY KEY,
    `name` VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE spaceports (
    id INT PRIMARY KEY,
    `name` VARCHAR(50) UNIQUE NOT NULL,
    planet_id INT NOT NULL,
    CONSTRAINT spaceport_planet_fk FOREIGN KEY (planet_id)
        REFERENCES planets (id)
);

CREATE TABLE spaceships (
    id INT PRIMARY KEY,
    `name` VARCHAR(50) UNIQUE NOT NULL,
    manufacturer VARCHAR(50) NOT NULL,
    light_speed_rate INT
);

CREATE TABLE colonists(
	id INT PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    ucn VARCHAR(10) UNIQUE NOT NULL
    CONSTRAINT ucn_fk CHECK(LENGTH(ucn) = 10),
    birth_date DATE NOT NULL
);

CREATE TABLE journeys (
    id INT PRIMARY KEY,
    journey_start DATE NOT NULL,
    journey_end DATE NOT NULL,
    purpose VARCHAR(11) NOT NULL,
    destination_spaceport_id INT NOT NULL,
    spaceship_id INT NOT NULL,
    CONSTRAINT destination_spaceport_fk FOREIGN KEY (destination_spaceport_id)
        REFERENCES spaceports (id),
    CONSTRAINT spaceship_fk FOREIGN KEY (spaceship_id)
        REFERENCES spaceships (id),
    CONSTRAINT purpose_fk CHECK (purpose IN ('Medical' , 'Technical', 'Educational', 'Military'))
);

CREATE TABLE travel_cards (
    id INT PRIMARY KEY,
    card_number VARCHAR(10) UNIQUE NOT NULL,
    job_during_journey VARCHAR(10) NOT NULL,
    colonist_id INT NOT NULL,
    journey_id INT NOT NULL,
    CONSTRAINT ck_card_number CHECK (LENGTH(card_number) = 10),
    CONSTRAINT ck_job_during_journey CHECK (job_during_journey IN ('Pilot' , 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
    CONSTRAINT fk_colonist_id FOREIGN KEY (colonist_id)
        REFERENCES colonists (id),
    CONSTRAINT fk_journey_id FOREIGN KEY (journey_id)
        REFERENCES journeys (id)
);

START TRANSACTION;
	SET sql_safe_updates = 0;
	UPDATE journeys AS j 
SET 
    j.purpose = CASE
        WHEN j.id % 2 = 0 THEN 'Medical'
        WHEN j.id % 3 = 0 THEN 'Technical'
        WHEN j.id % 5 = 0 THEN 'Educational'
        WHEN j.id % 7 = 0 THEN 'Military'
        ELSE j.purpose
    END;
    
DELETE c FROM colonists AS c
        LEFT JOIN
    travel_cards AS t ON t.colonist_id = c.id 
WHERE
    t.colonist_id IS NULL;
    
COMMIT;
ROLLBACK;

/*Extract all travel cards*/
SELECT 
    t.card_number, t.job_during_journey
FROM
    travel_cards AS t
ORDER BY t.card_number;

/*Extract all colonists*/
SELECT 
    c.id,
    CONCAT_WS(' ', c.first_name, c.last_name) AS 'full_name',
    c.ucn
FROM
    colonists AS c
ORDER BY c.first_name , c.last_name , c.id;

/*Extract all military journeys*/
SELECT 
    j.id, j.journey_start, j.journey_end
FROM
    journeys AS j
WHERE
    j.purpose = 'Military'
ORDER BY j.journey_start;

/*Extract all pilots*/
SELECT 
    c.id,
    CONCAT_WS(' ', c.first_name, c.last_name) AS 'full_name'
FROM
    colonists AS c
        JOIN
    travel_cards AS t ON t.colonist_id = c.id
WHERE
    t.job_during_journey = 'Pilot'
ORDER BY c.id;

/*Count all colonists that are on technical journey*/
SELECT 
    COUNT(*) AS 'count'
FROM
    colonists AS c
        JOIN
    travel_cards AS t ON t.colonist_id = c.id
        JOIN
    journeys AS j ON j.id = t.journey_id
WHERE
    j.purpose = 'Technical';

/*Extract the fastest spaceship*/
SELECT 
    s.`name` AS 'spaceship_name', sp.`name` AS 'spaceport_name'
FROM
    spaceships AS s
        JOIN
    journeys AS j ON j.spaceship_id = s.id
        JOIN
    spaceports AS sp ON sp.id = j.destination_spaceport_id
ORDER BY s.light_speed_rate DESC
LIMIT 1;

/*Extract spaceships with pilots younger than 30 years*/
SELECT 
    s.`name`, s.manufacturer
FROM
    spaceships AS s
        JOIN
    journeys AS j ON j.spaceship_id = s.id
        JOIN
    travel_cards AS t ON t.journey_id = j.id
        JOIN
    colonists AS c ON c.id = t.colonist_id
WHERE
    TIMESTAMPDIFF(YEAR,
        c.birth_date,
        '2019-01-01') < 30
GROUP BY s.`name` , s.manufacturer
ORDER BY s.`name`;

/*Extract all educational mission planets and spaceports*/
SELECT 
    p.`name`, s.`name`
FROM
    journeys AS j
        JOIN
    spaceports AS s ON s.id = j.destination_spaceport_id
        JOIN
    planets AS p ON p.id = s.planet_id
WHERE
    j.purpose = 'Educational'
ORDER BY s.`name` DESC;

/*Extract all planets and their journey count*/
SELECT 
    p.`name` AS 'planet_name', COUNT(sp.id) AS 'journeys_count'
FROM
    planets AS p
        JOIN
    spaceports AS sp ON sp.planet_id = p.id
        JOIN
    journeys AS j ON j.destination_spaceport_id = sp.id
GROUP BY p.`name`
ORDER BY COUNT(sp.id) DESC , p.`name`;

/*Extract the shortest journey*/
SELECT 
    j.id AS 'id',
    p.`name` AS 'planet_name',
    sp.`name` AS 'spaceport_name',
    j.purpose AS 'journey_purpose'
FROM
    journeys AS j
        JOIN
    spaceports AS sp ON sp.id = j.destination_spaceport_id
        JOIN
    planets AS p ON p.id = sp.planet_id
ORDER BY DATEDIFF(j.journey_end, j.journey_start)
LIMIT 1;

/*Get colonists count*/
DELIMITER $$
CREATE FUNCTION udf_count_colonists_by_destination_planet(planet_name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE count INT;
	SELECT 
		COUNT(c.id)
        INTO count
    FROM travel_cards as tc
    JOIN colonists as c on c.id = tc.colonist_id
    JOIN journeys as j on j.id = tc.journey_id
    JOIN spaceports as sp on sp.id = j.destination_spaceport_id
    JOIN planets as p on p.id = sp.planet_id
    WHERE p.`name` = planet_name;    
    RETURN count;
END$$
DELIMITER ;

SELECT p.`name`, udf_count_colonists_by_destination_planet('Otroyphus') AS `count`
FROM planets AS p
WHERE p.`name` = 'Otroyphus';

/*Modify spaceship*/
DELIMITER $$
CREATE PROCEDURE udp_modify_spaceship_light_speed_rate(
    IN spaceship_name VARCHAR(50),
    IN light_speed_rate_increase INT
)
BEGIN
    DECLARE spaceship_exists INT;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Spaceship you are trying to modify does not exist.';
    END;

    START TRANSACTION;

    SELECT COUNT(*)
    INTO spaceship_exists
    FROM spaceships
    WHERE name = spaceship_name;

    IF spaceship_exists = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Spaceship you are trying to modify does not exist.';
    ELSE
        UPDATE spaceships
        SET light_speed_rate = light_speed_rate + light_speed_rate_increase
        WHERE name = spaceship_name;

        COMMIT;
    END IF;
END$$
DELIMITER ;
