-- Задание 3 Есть таблица пользователей user (user_id — id пользователя, installed_at — дата установки приложения) 
-- и таблица платежей payment (user_id, payment_at — дата оплаты, amount — сумма платежа).
-- Необходимо написать SQL-запрос, который считает накопительный ARPU с группировкой по месяцу оплаты. 
-- Считать только оплаты пользователей, установивших приложение в январе 2023 года.

-- Создаем таблички users и payments согласно заданию
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    installed_at DATE
);

CREATE TABLE payments (
    user_id INTEGER,
    payment_at DATE,
    amount DECIMAL(10, 2)
);

-- Генерируем случайные даты установки приложения в диапазоне декабрь 2022 - февраль 2023
INSERT INTO users (installed_at)
SELECT
    '2022-12-01'::DATE + (RANDOM() * ('2023-02-28'::DATE - '2022-12-01'::DATE)::INTEGER) * '1 day'::INTERVAL
FROM
    generate_series(1, 150);

-- Выбираем случайные 80% пользователей, которые сделали покупки    
WITH selected_users AS (
    SELECT user_id, installed_at
    FROM users
    ORDER BY RANDOM()
    LIMIT (SELECT COUNT(*) * 0.8 FROM users)
)
-- Создаем от 1 до 5 покупок для этих 80% пользователей чтобы распределение было более реалистично
INSERT INTO payments (user_id, payment_at, amount)
SELECT
    su.user_id,
    su.installed_at + ((RANDOM() * 30)::INTEGER || ' days')::INTERVAL,
    ROUND((RANDOM() * 5)::numeric, 2) + 1
FROM
    selected_users su
JOIN
    generate_series(1, 5) s ON TRUE;


-- решение в лоб 

-- январская когорта 56 юзеров
with january_users AS (
    SELECT user_id 
    FROM users
    WHERE installed_at >= '2023-01-01' AND installed_at < '2023-02-01'
),      
-- платежи январской когорты в январе (39 платящих)
jan_payers as (    
select ju.user_id, sum(p.amount) as total_payment_jan
    from january_users ju
    left join payments p using(user_id)
    where p.payment_at >= '2023-01-01' AND p.payment_at < '2023-02-01'
    group by 1
    order by 1
),   
-- платежи январской когорты в феврале (34 платящих)
feb_payers as (
    select ju.user_id, sum(p.amount) as total_payment_feb
    from january_users ju
    left join payments p using(user_id)
    where p.payment_at >= '2023-02-01' AND p.payment_at < '2023-02-28'
    group by 1
    order by 1
)

select count(ju.user_id) as cohort_size, sum(jp.total_payment_jan) as jan_amount, sum(fp.total_payment_feb) as feb_amount,
        round(sum(jp.total_payment_jan)/count(ju.user_id), 2) as ARPU_jan, 
        round((sum(jp.total_payment_jan) + sum(fp.total_payment_feb)) /count(ju.user_id), 2) as ARPU_feb
from january_users ju
left join jan_payers jp using(user_id)
left join feb_payers fp using(user_id)



-- решение замудреное 


-- Выбираем пользователей, установивших приложение в январе 2023 года
WITH january_users AS (
    SELECT user_id 
    FROM users
    WHERE installed_at >= '2023-01-01' AND installed_at < '2023-02-01'
), 

-- Суммируем платежи этих пользователей по месяцам
user_payments AS (
    SELECT 
        ju.user_id, 
        DATE_TRUNC('month', p.payment_at)::date AS payment_month, 
        SUM(p.amount) AS monthly_amount
    FROM 
        january_users ju
    JOIN 
        payments p ON ju.user_id = p.user_id
    GROUP BY 
        ju.user_id, DATE_TRUNC('month', p.payment_at)
), 

-- Определяем месяцы, за которые будем считать кумулятивный ARPU (январь и февраль 2023)
all_months AS (
    SELECT DATE '2023-01-01' AS payment_month
    UNION
    SELECT DATE '2023-02-01' AS payment_month
), 

-- Создаем все возможные комбинации пользователей из когорты и месяцев
user_months AS (
    SELECT 
        ju.user_id, 
        am.payment_month
    FROM 
        january_users ju
    CROSS JOIN 
        all_months am
), 

-- Вычисляем кумулятивную сумму платежей для каждого пользователя по месяцам
cumulative_payments AS (
    SELECT 
        um.user_id, 
        um.payment_month, 
        COALESCE(SUM(up.monthly_amount) OVER (PARTITION BY um.user_id ORDER BY um.payment_month), 0) AS cumulative_amount -- обрабатываем null
    FROM 
        user_months um
    LEFT JOIN 
        user_payments up ON um.user_id = up.user_id AND um.payment_month = up.payment_month
)

-- В итоге считаем количество пользователей в когорте, общую кумулятивную сумму платежей и кумулятивный ARPU
SELECT 
    cp.payment_month, 
    COUNT(DISTINCT ju.user_id) AS cohort_size,
    SUM(cp.cumulative_amount) AS total_cumulative_amount,
    ROUND(SUM(cp.cumulative_amount) / COUNT(DISTINCT ju.user_id), 2) AS cumulative_arpu
FROM 
    cumulative_payments cp
JOIN 
    january_users ju ON cp.user_id = ju.user_id
GROUP BY 
    1
ORDER BY 
    1;

    

   
