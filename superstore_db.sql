/* viewing first 50 rows of data */
SELECT *
FROM superstore
Limit 50; 

/* Replace null or blank product names */
SELECT *,
       CASE 
         WHEN "Product.Name" IS NULL OR TRIM("Product.Name") = '' 
         THEN 'Unknown.Product'
         ELSE "Product.Name"
       END AS cleaned_product_name
FROM superstore;

/* Normalize by breaking into separate tables */
-- Customers Table
CREATE TABLE customers AS
SELECT DISTINCT "Customer.ID", "Customer.Name", "Segment"
FROM superstore;

-- Products Table
CREATE TABLE products AS
SELECT DISTINCT "Product.ID", "Product.Name", "Category", "Sub.Category"
FROM superstore;

-- Orders Table
CREATE TABLE orders AS
SELECT "Order.ID", "Order.Date", "Ship.Date", "Customer.ID", "Product.ID", "Sales", "Quantity", "Discount", "Profit"
FROM superstore;

/* customers who placed orders in 2024 */
SELECT DISTINCT "Customer.Name" as Customer_Name, "Order.Date" AS Order_Date
FROM superstore
WHERE "Order_Date" >= '2024-01-01'
ORDER BY "Order_Date" ASC;

/* customers who never ordered before 2024 */
SELECT "Customer.Name" AS Customer_Name, "Order.Date" AS Order_Date
FROM superstore
WHERE "Customer.Name" IN (
    SELECT "Customer.Name"
    FROM superstore
    GROUP BY "Customer.Name"
    HAVING MIN("Order.Date") >= '2024-01-01'
)
ORDER BY "Order.Date";

/* Total Sales and Profit by Region */
SELECT "Region", 
       SUM("Sales") AS Total_Sales, 
       SUM("Profit") AS Total_Profit
FROM superstore
GROUP BY "Region"
ORDER BY Total_Sales DESC;

/* Querying top 5 sub-categories by total sales */
SELECT "Sub.Category" AS Sub_Category, SUM("Sales") AS total_sales
FROM superstore
GROUP BY Sub_Category
ORDER BY total_sales DESC
LIMIT 5;

/* Top 10 customers by total sales */
SELECT "Customer.Name" AS Customer_Name, SUM("Sales") AS Total_Sales
FROM superstore
GROUP BY Customer_Name
ORDER BY Total_Sales DESC
LIMIT 10;
  
/* Average shipping day delays per region */
SELECT "Region",
       AVG(JULIANDAY("Ship.Date") - JULIANDAY("Order.Date")) AS Avg_Ship_Delay
FROM superstore
GROUP BY "Region"
ORDER BY Avg_Ship_Delay DESC;

/* Does discount correlate with loss? */
SELECT *
FROM superstore
WHERE "Profit" < 0 AND "Discount" > 0.2
ORDER BY "Discount" DESC;

/* Which products were ordered by customers totaling more than $100? */
SELECT o."Order.ID", c."Customer.Name", p."Product.Name", o."Sales"
FROM Orders o
JOIN Customers c ON o."Customer.ID" = c."Customer.ID"
JOIN Products p ON o."Product.ID" = p."Product.ID"
WHERE o."Sales" > 100;

