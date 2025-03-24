CREATE DATABASE ecommerce;
USE ecommerce;

CREATE TABLE customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(255),
    City VARCHAR(50),
    ZipCode INT,
    SignupDate DATE
);

CREATE TABLE products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    StockQuantity INT
);


CREATE TABLE orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    OrderDate DATE,
    Quantity INT,
    OrderStatus VARCHAR(20),
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES products(ProductID)
);

ALTER TABLE orders 
ADD COLUMN PaymentMethod VARCHAR(50);


/* List Customers from Marrakech (Sorted Alphabetically by Last Name) */
SELECT * FROM customers WHERE City = 'Marrakech' ORDER BY LastName ASC;

/* Count How Many Customers Signed Up Per Year */
CREATE VIEW signupperyear AS
SELECT YEAR(SignupDate) AS Year, COUNT(*) AS TotalCustomers
FROM customers
GROUP BY Year
ORDER BY Year ASC;

/* Total Order Received */
CREATE VIEW Totalorders AS
SELECT 
    COUNT(OrderID) AS Total_Orders
FROM orders;

/* Total Lost Revenue */
CREATE VIEW Lost_Revenue AS
SELECT 
    YEAR(OrderDate) AS Year,
    QUARTER(OrderDate) AS Quarter,
    MONTH(OrderDate) AS Month,
    SUM(TotalAmount) AS Lost_Revenue
FROM orders
WHERE OrderStatus = 'Canceled'
GROUP BY YEAR(OrderDate), QUARTER(OrderDate), MONTH(OrderDate)
ORDER BY Year DESC, Quarter DESC, Month DESC;

/* Total Order Yearly */
CREATE VIEW Yearly_Order_Trend AS
SELECT 
    YEAR(OrderDate) AS Year,
    COUNT(OrderID) AS Total_Orders,
    SUM(TotalAmount) AS Total_Revenue
FROM orders
WHERE OrderStatus <> 'Canceled'
GROUP BY YEAR(OrderDate)
ORDER BY Year DESC;

/* Average Order Value */
CREATE VIEW Average_Order_Value AS
SELECT 
    SUM(TotalAmount) / COUNT(OrderID) AS Avg_Order_Value
FROM orders
WHERE OrderStatus <> 'Canceled';

/* Order status Percent */
CREATE VIEW Orderstatuspercent AS
SELECT OrderStatus, COUNT(OrderID) AS OrderCount
FROM orders
GROUP BY OrderStatus;


CREATE VIEW Avg_Order_Frequency AS
SELECT 
    COUNT(o.OrderID) / COUNT(DISTINCT o.CustomerID) AS Avg_Orders_Per_Customer
FROM orders o
WHERE o.OrderStatus <> 'Canceled';

CREATE VIEW Product_Highest_Returns AS
SELECT 
    p.ProductID,
    p.ProductName,
    COUNT(o.OrderID) AS Total_Orders,
    SUM(CASE WHEN o.OrderStatus = 'Canceled' THEN 1 ELSE 0 END) AS Canceled_Orders
FROM orders o
JOIN products p ON o.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY Canceled_Orders DESC
LIMIT 1;

CREATE VIEW Best_Selling_Product AS
SELECT 
    p.ProductID,
    p.ProductName,
    SUM(o.Quantity) AS Total_Units_Sold,
    SUM(o.TotalAmount) AS Total_Revenue
FROM orders o
JOIN products p ON o.ProductID = p.ProductID
WHERE o.OrderStatus <> 'Canceled'
GROUP BY p.ProductID, p.ProductName
ORDER BY Total_Units_Sold DESC, Total_Revenue DESC
LIMIT 1;

CREATE VIEW Revenue_By_Location AS
SELECT 
    c.City,
    c.ZipCode,
    SUM(o.TotalAmount) AS Total_Revenue
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderStatus <> 'Canceled'
GROUP BY c.City, c.ZipCode
ORDER BY Total_Revenue DESC;



















