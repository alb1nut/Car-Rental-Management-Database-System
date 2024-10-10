SET search_path TO rent;


--1 
SELECT COUNT(*) AS number_of_cars
FROM car
WHERE car_status = 'available';


--2 
SELECT
    c.brand,
    c.model,
    c.license_plate,
    COUNT(b.booking_id) AS booking_count
FROM
    car c
LEFT JOIN
    booking b ON c.car_id = b.car_id
WHERE
    EXTRACT(MONTH FROM lower(b.booking_duration)) = 7
    AND EXTRACT(YEAR FROM lower(b.booking_duration)) = 2023
GROUP BY
    c.brand,
    c.model,
    c.license_plate;


--3
SELECT c.brand, c.model, c.license_plate
FROM car c
WHERE c.car_id NOT IN (SELECT DISTINCT car_id FROM car_damage);

--4

SELECT u.name
FROM user_info u
WHERE u.user_id IN (
    SELECT DISTINCT b.user_id
    FROM booking b
    WHERE lower(b.booking_duration) >= CURRENT_DATE - INTERVAL '45 days'
);

--5

CREATE OR REPLACE FUNCTION insert_booking_data(
    user_name VARCHAR(255),
    car_license_plate VARCHAR(10),
    booking_start TIMESTAMP,
    booking_end TIMESTAMP
)
RETURNS VOID AS
$$
DECLARE
    user_id_val INT;
    car_id_val INT;
BEGIN
    -- Get user_id based on user_name
    SELECT user_id INTO user_id_val FROM user_info WHERE name = user_name;

    -- Get car_id based on car_license_plate
    SELECT car_id INTO car_id_val FROM car WHERE license_plate = car_license_plate;

    -- Insert data into the booking table
    INSERT INTO booking (user_id, car_id, booking_duration, booking_status)
    VALUES (user_id_val, car_id_val, tsrange(booking_start, booking_end), 'completed');
END;
$$
LANGUAGE plpgsql;



SELECT insert_booking_data('Anna Ivanova', 'g878xt', '2023-12-21 02:00:00', '2023-12-21 03:00:00');


--6
CREATE VIEW last_month_damages AS
SELECT 
    c.license_plate,
    c.brand,
    cd.description,
    cd.repair_cost,
    cd.damage_status
FROM 
    car_damage cd
JOIN 
    car c ON cd.car_id = c.car_id
WHERE 
    cd.damage_date_time >= CURRENT_DATE - INTERVAL '1 month';

--7
SELECT 
    car_category,
    AVG(EXTRACT(EPOCH FROM upper(bd.booking_duration) - lower(bd.booking_duration))) / 3600 AS avg_duration_hours
FROM 
    booking bd
JOIN 
    car c ON bd.car_id = c.car_id
WHERE 
    bd.booking_status = 'completed'
    AND c.car_category IN ('business', 'economy')
GROUP BY 
    car_category;


