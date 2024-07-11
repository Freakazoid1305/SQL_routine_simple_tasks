-- Задание 1 Имеется таблица city_population с населением городов: city (наименование города), population (численность населения).
Необходимо написать запрос, который выводит город с минимальным и максимальным населением.

-- создаем таблицу и заполняем рандомными значениями
CREATE TABLE city_population (
    city VARCHAR(100),
    population INTEGER
);

INSERT INTO city_population (city, population) VALUES
('New York', 8500000),
('Los Angeles', 4000000),
('Chicago', 2700000),
('Houston', 2300000),
('Phoenix', 1600000),
('Philadelphia', 1600000),
('San Antonio', 1500000),
('San Diego', 1400000),
('Dallas', 1300000),
('San Jose', 1030000),
('Austin', 950000),
('Jacksonville', 900000),
('Fort Worth', 900000),
('Columbus', 900000),
('San Francisco', 880000),
('Charlotte', 870000),
('Indianapolis', 860000),
('Seattle', 840000),
('Denver', 830000),
('Washington', 830000);


-- выполняем запрос на вывод строчек с наменьшим населением в лексиграфическом порядке
SELECT city
FROM city_population
WHERE population = (SELECT MIN(population) FROM city_population)
ORDER BY 1;

-- таким запросом выводим табличку со строками о городах с минимальным и максимальном населением
-- одинаковые значения популяции выводятся в лексиграфическом порядке названий городов
SELECT 'Minimum Population' AS population_type, city
FROM city_population
WHERE population = (SELECT MIN(population) FROM city_population)
UNION 
SELECT 'Maximum Population' AS population_type, city
FROM city_population
WHERE population = (SELECT MAX(population) FROM city_population)
ORDER BY 2;  

