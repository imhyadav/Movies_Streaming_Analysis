CREATE DATABASE IF NOT EXISTS movie_streaming_db;
USE movie_streaming_db;
CREATE TABLE movie_streaming_data (
    user_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    country VARCHAR(20),
    subscription_type VARCHAR(10),
    movie_genre VARCHAR(20),
    watch_time_minutes INT,
    rating DECIMAL(2,1),
    device VARCHAR(20),
    watch_date DATE
);
SELECT COUNT(*) FROM movie_streaming_data;
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    country VARCHAR(20)
);
INSERT INTO users (user_id, age, gender, country)
SELECT user_id, age, gender, country
FROM movie_streaming_data;
CREATE TABLE subscriptions (
    user_id INT PRIMARY KEY,
    subscription_type VARCHAR(10),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
INSERT INTO subscriptions (user_id, subscription_type)
SELECT user_id, subscription_type
FROM movie_streaming_data;
CREATE TABLE watch_history (
    watch_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    movie_genre VARCHAR(20),
    watch_time_minutes INT,
    rating DECIMAL(2,1),
    device VARCHAR(20),
    watch_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
INSERT INTO watch_history (
    user_id,
    movie_genre,
    watch_time_minutes,
    rating,
    device,
    watch_date
)
SELECT
    user_id,
    movie_genre,
    watch_time_minutes,
    rating,
    device,
    watch_date
FROM movie_streaming_data;

SELECT subscription_type, COUNT(*) AS total_users
FROM subscriptions
GROUP BY subscription_type;

SELECT country, COUNT(*) AS total_users
FROM users
GROUP BY country
ORDER BY total_users DESC;

SELECT s.subscription_type, AVG(u.age) AS avg_age
FROM users u
JOIN subscriptions s ON u.user_id = s.user_id
GROUP BY s.subscription_type;

SELECT country, gender, COUNT(*) AS total_users
FROM users
GROUP BY country, gender;

SELECT s.subscription_type, SUM(w.watch_time_minutes) AS total_watch_time
FROM watch_history w
JOIN subscriptions s ON w.user_id = s.user_id
GROUP BY s.subscription_type;

SELECT u.country, COUNT(*) AS premium_users
FROM users u
JOIN subscriptions s ON u.user_id = s.user_id
WHERE s.subscription_type = 'Premium'
GROUP BY u.country
ORDER BY premium_users DESC
LIMIT 5;

SELECT u.country, COUNT(*) AS free_users
FROM users u
JOIN subscriptions s ON u.user_id = s.user_id
WHERE s.subscription_type = 'Free'
GROUP BY u.country
ORDER BY free_users DESC
LIMIT 1;

SELECT s.subscription_type, COUNT(*) AS smart_tv_sessions
FROM watch_history w
JOIN subscriptions s ON w.user_id = s.user_id
WHERE w.device = 'Smart TV'
GROUP BY s.subscription_type
ORDER BY smart_tv_sessions DESC;

SELECT *
FROM (
    SELECT s.subscription_type,
           w.movie_genre,
           SUM(w.watch_time_minutes) AS watch_time,
           RANK() OVER (
             PARTITION BY s.subscription_type
             ORDER BY SUM(w.watch_time_minutes) DESC
           ) AS rnk
    FROM watch_history w
    JOIN subscriptions s ON w.user_id = s.user_id
    GROUP BY s.subscription_type, w.movie_genre
) t
WHERE rnk = 1;

SELECT *
FROM (
    SELECT u.country,
           w.movie_genre,
           SUM(w.watch_time_minutes) AS watch_time,
           RANK() OVER (
             PARTITION BY u.country
             ORDER BY SUM(w.watch_time_minutes) DESC
           ) AS rnk
    FROM watch_history w
    JOIN users u ON w.user_id = u.user_id
    GROUP BY u.country, w.movie_genre
) t
WHERE rnk = 1;

SELECT MONTH(watch_date) AS month,
       SUM(watch_time_minutes) AS total_watch_time
FROM watch_history
GROUP BY MONTH(watch_date)
ORDER BY month;

SELECT s.subscription_type,
       MONTH(w.watch_date) AS month,
       SUM(w.watch_time_minutes) AS total_watch
FROM watch_history w
JOIN subscriptions s ON w.user_id = s.user_id
GROUP BY s.subscription_type, MONTH(w.watch_date);

SELECT 
  CASE 
    WHEN DAYOFWEEK(watch_date) IN (1,7) THEN 'Weekend'
    ELSE 'Weekday'
  END AS day_type,
  SUM(watch_time_minutes) AS total_watch
FROM watch_history
GROUP BY day_type;

SELECT *
FROM (
    SELECT u.country,
           w.device,
           COUNT(*) AS sessions,
           RANK() OVER (
             PARTITION BY u.country
             ORDER BY COUNT(*) DESC
           ) AS rnk
    FROM watch_history w
    JOIN users u ON w.user_id = u.user_id
    GROUP BY u.country, w.device
) t
WHERE rnk = 1;

SELECT w.movie_genre,
       SUM(w.watch_time_minutes) AS total_watch
FROM watch_history w
JOIN subscriptions s ON w.user_id = s.user_id
WHERE s.subscription_type = 'Free'
GROUP BY w.movie_genre
ORDER BY total_watch DESC
LIMIT 1;













