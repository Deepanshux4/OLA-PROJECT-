drop table if exists bookings;

CREATE TABLE bookings (
    date DATE,
    time TIME,
    booking_id VARCHAR(50) PRIMARY KEY,
    booking_status VARCHAR(50),
    customer_id VARCHAR(50),
    vehicle_type VARCHAR(50),
    pickup_location TEXT,
    drop_location TEXT,
    v_tat VARCHAR(50),
    c_tat VARCHAR(50),
    canceled_rides_by_customer VARCHAR(100),
    canceled_rides_by_driver VARCHAR(100),
    incomplete_rides VARCHAR(20),
    incomplete_rides_reason TEXT,
    booking_value NUMERIC(10,2),
    payment_method VARCHAR(50),
    ride_distance NUMERIC(10,2),
    driver_ratings NUMERIC(3,2),
    customer_rating NUMERIC(3,2),
    vehicle_images TEXT
);

select * from bookings;

--Q1. Find the top 10 customers who completed the highest number of successful rides.

SELECT
	CUSTOMER_ID,
	COUNT(BOOKING_ID) AS TOTAL_BOOKING
FROM
	BOOKINGS
WHERE
	BOOKING_STATUS = 'Success'
GROUP BY
	CUSTOMER_ID
ORDER BY
	TOTAL_BOOKING DESC
LIMIT
	10;
	
--Q2. Find the average booking value for each payment method.

SELECT
	PAYMENT_METHOD,
	ROUND(AVG(BOOKING_VALUE), 1)
FROM
	BOOKINGS
WHERE
	PAYMENT_METHOD IS NOT NULL
GROUP BY
	PAYMENT_METHOD;

--Q3. Calculate the average ride distance for each vehicle type.

SELECT
	VEHICLE_TYPE,
	ROUND(AVG(RIDE_DISTANCE), 2)
FROM
	BOOKINGS
GROUP BY
	VEHICLE_TYPE;

--Q4. Identify customers who have never completed a successful ride.

SELECT
	CUSTOMER_ID
FROM
	BOOKINGS
WHERE
	BOOKING_STATUS = 'Canceled by Customer'
GROUP BY
	CUSTOMER_ID;
	
--Q5. Find the most common driver cancellation reason and its frequency.

SELECT
    canceled_rides_by_driver AS driver_cancel_reason,
    COUNT(*) AS frequency
FROM bookings
WHERE canceled_rides_by_driver IS NOT NULL
GROUP BY canceled_rides_by_driver
ORDER BY frequency DESC;


--Q6. Compare the average booking value of successful rides versus cancelled rides.

SELECT
	BOOKING_STATUS,
	ROUND(AVG(BOOKING_VALUE), 2)
FROM
	BOOKINGS
WHERE
	BOOKING_STATUS IN (
		'Success',
		'Canceled by Customer',
		'Canceled by Driver'
	)
GROUP BY
	BOOKING_STATUS;

--Q7. Retrieve the latest booking made by every customer using ROW_NUMBER().


SELECT
	CUSTOMER_ID,
	DATE,
	RN
FROM
	(
		SELECT
			CUSTOMER_ID,
			DATE,
			ROW_NUMBER() OVER (
				PARTITION BY
					DATE
				ORDER BY
					DATE DESC
			) AS RN
		FROM
			BOOKINGS
	)
WHERE
	RN = 1;

--Q8 Find the top 3 highest-value bookings within each vehicle type.

SELECT
	VEHICLE_TYPE,
	BOOKING_VALUE,
	RN
FROM
	(
		SELECT
			VEHICLE_TYPE,
			BOOKING_VALUE,
			ROW_NUMBER() OVER (
				PARTITION BY
					VEHICLE_TYPE
				ORDER BY
					BOOKING_VALUE DESC
			) AS RN
		FROM
			BOOKINGS
	)
WHERE
	RN <= 3;

--Q9.Find the top 5 pickup-drop location pairs that generated the highest revenue.

SELECT
	DROP_LOCATION,
	ROUND(SUM(BOOKING_VALUE), 1) AS REVENUE
FROM
	BOOKINGS
GROUP BY
	DROP_LOCATION
ORDER BY
	REVENUE
LIMIT
	5;

--Q10 IN which hours has the highest booking in 2024.

SELECT
	EXTRACT(
		HOUR
		FROM
			TIME
	) AS HOURS,
	COUNT(BOOKING_ID) AS TOTALBOOKING
FROM
	BOOKINGS
WHERE
	DATE >= '2024-01-01'
	AND DATE <= '2024-12-31'
GROUP BY
	EXTRACT(
		HOUR
		FROM
			TIME
	)
ORDER BY
	TOTALBOOKING DESC;

--Q11.Which pickup locations have the highest cancellation rate?

SELECT
	PICKUP_LOCATION,
	COUNT(BOOKING_STATUS) AS BOOKING
FROM
	BOOKINGS
WHERE
	BOOKING_STATUS != 'Success'
GROUP BY
	PICKUP_LOCATION;


--Q12 Calculate the average Vehicle TAT (V_TAT) and Customer TAT (C_TAT) by vehicle type.

SELECT
	VEHICLE_TYPE,
	ROUND(AVG(V_TAT), 1) AS VTAT,
	ROUND(AVG(C_TAT), 1) AS CTAT
FROM
	BOOKINGS
WHERE
	V_TAT IS NOT NULL
	AND C_TAT IS NOT NULL
GROUP BY
	VEHICLE_TYPE;

select distinct c_tat from bookings;
select distinct v_tat from bookings;

ALTER TABLE BOOKINGS
ALTER COLUMN V_TAT TYPE INTEGER USING V_TAT::INTEGER;


ALTER TABLE BOOKINGS
ALTER COLUMN C_TAT TYPE INTEGER USING C_TAT::INTEGER;


--Q13. Divide customers into spending segments (Low, Medium, High) using CASE.
SELECT
	CUSTOMER_ID,
	BOOKING_VALUE,
	CASE
		WHEN BOOKING_VALUE <= 300 THEN 'low'
		WHEN BOOKING_VALUE BETWEEN 301 AND 1000  THEN 'medium'
		ELSE 'high'
	END AS SPENDING_SEGMENTS
FROM
	BOOKINGS
ORDER BY
	BOOKING_VALUE ASC;


--Q14. Calculate the cancellation number by vehicle type.

select vehicle_type,count(booking_status)as total_cancellation
from bookings
where booking_status  != 'Success'
group by vehicle_type;


--Q15. Retrive longest 20 rides

SELECT
	VEHICLE_TYPE,
	RIDE_DISTANCE
FROM
	BOOKINGS
ORDER BY
	RIDE_DISTANCE DESC;

--Q16 What is average driver rating per vehicle type ?

SELECT
	VEHICLE_TYPE,
	ROUND(AVG(DRIVER_RATINGS), 2) AS AVG_RATING
FROM
	BOOKINGS
GROUP BY
	VEHICLE_TYPE
ORDER BY
	AVG(DRIVER_RATINGS) DESC;

--Q17.Find the top 10 pickup-drop location  that has highest number of booking?

SELECT
	PICKUP_LOCATION,
	COUNT(BOOKING_ID)AS TOTAL BOOKING
FROM
	BOOKINGS
GROUP BY
	PICKUP_LOCATION
ORDER BY
	COUNT(BOOKING_ID) DESC
LIMIT
	10;


--Q18.Find the  number of rides per customer.

SELECT
	CUSTOMER_ID,
	COUNT(BOOKING_ID) AS AVG_BOOKING
FROM
	BOOKINGS
GROUP BY
	CUSTOMER_ID
ORDER BY
	CUSTOMER_ID,
	COUNT(BOOKING_ID) DESC;

--Q19.Find the first ride taken by every customer.

SELECT
	CUSTOMER_ID,
	DATE,
	RN
FROM
	(
		SELECT
			CUSTOMER_ID,
			DATE,
			ROW_NUMBER() OVER (
				PARTITION BY
					DATE
				ORDER BY
					DATE 
			) AS RN
		FROM
			BOOKINGS
	)
WHERE
	RN = 1;


--20. Find customer whose  rating is above 4.5 and payent method is cash .

SELECT
	CUSTOMER_ID,
	CUSTOMER_RATING,
	PAYMENT_METHOD
FROM
	BOOKINGS
WHERE
	CUSTOMER_RATING > 4.5
	AND PAYMENT_METHOD = 'Cash';
