CREATE CUSTOMERS TABLE


CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

CREATE ORDERS TABLE

CREATE TABLE orders (
    order_id VARCHAR(20),
    customer_id VARCHAR(20),
    order_date DATE,
    product_name VARCHAR(100),
    category VARCHAR(100),
    quantity INT,
    unit_price NUMERIC(10,2),
    line_item_total NUMERIC(10,2),

    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);

 CREATE PAYMENTS TABLE

CREATE TABLE payments (
    payment_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20),
    payment_date DATE,
    payment_method VARCHAR(50),
    amount_paid NUMERIC(10,2),
    status VARCHAR(20)
);

CHECK IMPORTED DATA

SELECT * FROM customers
LIMIT 5;

SELECT * FROM orders
LIMIT 5;

SELECT * FROM payments
LIMIT 5;

TOTAL REVENUE ANALYSIS

SELECT
    SUM(line_item_total) AS total_revenue
FROM orders;

STEP 6 — TOP SELLING PRODUCTS

SELECT
    product_name,
    SUM(line_item_total) AS revenue
FROM orders
GROUP BY product_name
ORDER BY revenue DESC;

CATEGORY-WISE REVENUE

SELECT
    category,
    SUM(line_item_total) AS revenue
FROM orders
GROUP BY category
ORDER BY revenue DESC;

 CUSTOMER PURCHASE FREQUENCY

SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS purchase_frequency
FROM orders
GROUP BY customer_id
ORDER BY purchase_frequency DESC;

CITY-WISE CUSTOMER COUNT

SELECT
    city,
    COUNT(customer_id) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;

PAYMENT METHOD ANALYSIS

SELECT
    payment_method,
    SUM(amount_paid) AS total_payment
FROM payments
GROUP BY payment_method
ORDER BY total_payment DESC;

RECENCY ANALYSIS

SELECT
    customer_id,
    CURRENT_DATE - MAX(order_date) AS recency
FROM orders
GROUP BY customer_id
ORDER BY recency;


RFM ANALYSIS

WITH rfm AS (
    SELECT
        customer_id,
        CURRENT_DATE - MAX(order_date) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(line_item_total) AS monetary
    FROM orders
    GROUP BY customer_id
),

rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM rfm
)

SELECT *,
       CONCAT(r_score, f_score, m_score) AS rfm_segment
FROM rfm_scores;


CUSTOMER SEGMENTATION

WITH rfm AS (
    SELECT
        customer_id,
        CURRENT_DATE - MAX(order_date) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(line_item_total) AS monetary
    FROM orders
    GROUP BY customer_id
),

rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM rfm
)

SELECT *,
CASE
    WHEN r_score >=4 AND f_score >=4 AND m_score >=4
        THEN 'Champions'

    WHEN f_score >=4
        THEN 'Loyal Customers'

    WHEN r_score <=2
        THEN 'At Risk Customers'

    ELSE 'Regular Customers'
END AS customer_segment

FROM rfm_scores;


CUSTOMER LIFETIME VALUE (CLV)

SELECT
    customer_id,
    ROUND(
        AVG(line_item_total) * COUNT(DISTINCT order_id),
        2
    ) AS customer_lifetime_value
FROM orders
GROUP BY customer_id
ORDER BY customer_lifetime_value DESC;


TOP 10 HIGH VALUE CUSTOMERS

SELECT
    customer_id,
    ROUND(SUM(line_item_total),2) AS total_spending
FROM orders
GROUP BY customer_id
ORDER BY total_spending DESC
LIMIT 10;


MONTHLY SALES TREND

SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(line_item_total) AS monthly_revenue
FROM orders
GROUP BY month
ORDER BY month;


AVERAGE ORDER VALUE

SELECT
    ROUND(AVG(line_item_total),2) AS average_order_value
FROM orders;


SUCCESSFUL PAYMENTS

SELECT
    status,
    COUNT(*) AS payment_count
FROM payments
GROUP BY status;


TOP CITIES BY REVENUE

SELECT
    c.city,
    SUM(o.line_item_total) AS city_revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY city_revenue DESC;


FINAL BUSINESS INSIGHTS QUERY

SELECT
    category,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(line_item_total) AS total_revenue,
    ROUND(AVG(line_item_total),2) AS avg_order_value
FROM orders
GROUP BY category
ORDER BY total_revenue DESC;

SELECT current_user;
SELECT current_database();
SHOW listen_addresses;
SHOW port;
SELECT current_user;
SHOW server;

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'customers';

SELECT
    tc.table_name,
    kcu.column_name,
    tc.constraint_type
FROM
    information_schema.table_constraints tc
JOIN
    information_schema.key_column_usage kcu
ON
    tc.constraint_name = kcu.constraint_name
WHERE
    tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY')
ORDER BY
    tc.table_name;