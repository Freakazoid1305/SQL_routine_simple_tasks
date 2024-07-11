-- Задание 2 Есть таблица опредленного вида. Напишите SQL-запрос, который считает, 
-- сколько уникальных имен (Name) имеется по каждому ID для Label, содержащих “bot” в названии (независимо от регистра букв).


-- создаем таблицу и заполняем согласно указанным данным из задания
CREATE TABLE names (
    ID INTEGER,
    Name VARCHAR(100),
    Label VARCHAR(100)
);

INSERT INTO names (ID, Name, Label) VALUES
(1, 'A', 'bot_vk'),
(1, 'B', 'bot_tg'),
(2, 'B', 'website'),
(2, 'C', 'bot_vk'),
(3, 'A', 'website'),
(3, 'C', 'website'),
(4, 'B', 'bot_tg'),
(4, 'A', 'Bot_tg'),
(5, 'C', 'Bot_vk'),
(5, 'A', 'website'),
(5, 'A', 'botvk');



-- выполняем запрос 
SELECT id, count(distinct name) as unique_names
FROM names 
WHERE lower(label) like '%bot%'
GROUP BY id
ORDER BY 1;
