 Create database advantureworks;
 use advantureworks;
 
 
 -- firstly created csv files of the given dataset
-- hear we imported all  the created CSV Files into the table 
-- we used Table data import Wizard because it auto detects the column names and import all the data  into table 
 
 SHOW TABLES;
 
ALTER TABLE fact_internet_sales
CHANGE COLUMN `ï»¿ProductKey` ProductKey INT;

ALTER TABLE dim_customer
CHANGE COLUMN `ï»¿CustomerKey` CustomerKey INT;

ALTER TABLE dim_date
CHANGE COLUMN `ï»¿DateKey` DateKey INT;

ALTER TABLE dim_product
CHANGE COLUMN `ï»¿ProductKey` ProductKey INT;

ALTER TABLE dim_product_category
CHANGE COLUMN `ï»¿ProductCategoryKey` Productcategorykey INT;

ALTER TABLE dim_product_subcategory
CHANGE COLUMN `ï»¿ProductSubcategoryKey` Productsubcategorykey INT;

 
SELECT COUNT(*) 
FROM fact_internet_sales;

SELECT COUNT(*) 
FROM fact_internet_sales_new;

SELECT COUNT(*) 
FROM dim_product;

SELECT COUNT(*) 
FROM dim_customer;

SELECT COUNT(*) 
FROM dim_date;

#   -- QUESTION 0 Union of sales 1 and Sales2 
CREATE TABLE sales AS
SELECT * FROM fact_internet_sales
UNION ALL
SELECT * FROM fact_internet_sales_new;

select * from sales;


#  -- Question 1  product name left join to sles table
SELECT
    s.*,  p.EnglishProductName AS ProductName
FROM sales s LEFT JOIN dim_product p
ON s.ProductKey = p.ProductKey;   
    
# -- Question 2  customer full name from customer and unit price from product into sales 

SELECT
    s.*,
  CONCAT_WS(' ',             -- concate with saperator(WS) 
        c.FirstName,
        c.MiddleName,
        c.LastName
    ) AS CustomerFullName,

    p.`Unit price` AS ProductUnitPrice

FROM sales s LEFT JOIN dim_customer c
ON s.CustomerKey = c.CustomerKey

LEFT JOIN dim_product p
    ON s.ProductKey = p.ProductKey;    
    
 # -- Question 3  
 
 
SELECT
    s.SalesOrderNumber,
    s.OrderDateKey,
    d.FullDateAlternateKey AS OrderDate
    
FROM sales s LEFT JOIN dim_date d
ON s.OrderDateKey = d.DateKey;    
    
# -- 3.A  creating year
SELECT
    s.SalesOrderNumber,
    d.CalendarYear AS Year
    
FROM sales s LEFT JOIN dim_date d
    ON s.OrderDateKey = d.DateKey;
    
# -- 3.A  creating Month no.
SELECT
    s.SalesOrderNumber,
    d.MonthNumberOfYear AS MonthNo
    
FROM sales s LEFT JOIN dim_date d
    ON s.OrderDateKey = d.DateKey;
    
# -- 3.C creating month full name
SELECT
    s.SalesOrderNumber,
    d.EnglishMonthName AS MonthFullName
FROM sales s LEFT JOIN dim_date d
    ON s.OrderDateKey = d.DateKey;    
    
# -- 3.D CReating Quarter
SELECT
    s.SalesOrderNumber,
    CONCAT('Q', d.CalendarQuarter) AS Quarter
    
FROM sales s LEFT JOIN dim_date d
    ON s.OrderDateKey = d.DateKey;   
    
# -- 3.E creating year Month 
SELECT
    s.SalesOrderNumber,
    DATE_FORMAT(d.FullDateAlternateKey, '%Y-%b') AS YearMonth
    
FROM sales s LEFT JOIN dim_date d
    ON s.OrderDateKey = d.DateKey;   
    
    
# -- 3.F creating Weekday no.
SELECT
    s.SalesOrderNumber,
    d.DayNumberOfWeek AS WeekdayNo
    
FROM sales s LEFT JOIN dim_date d
    ON s.OrderDateKey = d.DateKey;    
    
 # -- 3.G creating week day name
SELECT
    s.SalesOrderNumber,
    d.EnglishDayNameOfWeek AS WeekdayName
    
FROM sales s LEFT JOIN dim_date d
    ON s.OrderDateKey = d.DateKey; 
    
# -- 3.H Creating Financial Month 
SELECT
    s.SalesOrderNumber,
    CASE
        WHEN d.MonthNumberOfYear >= 7
            THEN d.MonthNumberOfYear - 6
        ELSE d.MonthNumberOfYear + 6
    END AS FinancialMonth
    
FROM sales s LEFT JOIN dim_date d
    ON s.OrderDateKey = d.DateKey;    
    
# -- 3.I Creating financial Quarter
SELECT
    s.SalesOrderNumber,
    CONCAT('Q', d.FiscalQuarter) AS FinancialQuarter
    
FROM sales s LEFT JOIN dim_date d
    ON s.OrderDateKey = d.DateKey;    
    
# -- Question 4  Calculating sales amount
SELECT
    SalesOrderNumber,
    UnitPrice,
    OrderQuantity,
    UnitPriceDiscountPct,
    UnitPrice * OrderQuantity *
        (1 - UnitPriceDiscountPct) AS CalculatedSalesAmount
FROM sales;    

# -- Question 5 calculating Production cost 
SELECT
    Round(ProductStandardCost,2) AS UnitCost,
    OrderQuantity,
    ProductStandardCost * OrderQuantity AS ProductionCost
FROM sales;

# -- Question 6  calculating PROFIT 
SELECT
    SalesOrderNumber,SalesAmount,

    ProductStandardCost * OrderQuantity
        AS ProductionCost,

    round(SalesAmount -
    (ProductStandardCost * OrderQuantity),2)
        AS Profit

FROM sales;

# -- Question 7 Calculating month wise  sales
SELECT
    d.CalendarYear AS Year,
    d.MonthNumberOfYear AS MonthNo,
    d.EnglishMonthName AS MonthName,
    round(SUM(s.SalesAmount),2) AS TotalSales
    
FROM sales s JOIN dim_date d
    ON s.OrderDateKey = d.DateKey
WHERE d.CalendarYear = 2013
GROUP BY
    d.CalendarYear,
    d.MonthNumberOfYear,
    d.EnglishMonthName
ORDER BY
    d.MonthNumberOfYear;
    
# -- Question 8 year wise sales
SELECT
    d.CalendarYear AS Year,
    round(SUM(s.SalesAmount),2) AS TotalSales
    
FROM sales s LEFT JOIN dim_date d
    ON s.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY d.CalendarYear;    

# -- Question 9 month wise sales
SELECT
    d.MonthNumberOfYear AS MonthNo,
    d.EnglishMonthName AS MonthName,
    Round(SUM(s.SalesAmount),2) AS TotalSales
    
FROM sales s LEFT JOIN dim_date d
     ON s.OrderDateKey = d.DateKey
GROUP BY
    d.MonthNumberOfYear,
    d.EnglishMonthName
ORDER BY
    d.MonthNumberOfYear;
    
# -- Question 10 Quarter wise sales
SELECT
    d.CalendarQuarter AS Quarter,
    Round(SUM(s.SalesAmount),2) AS TotalSales
FROM sales s
LEFT JOIN dim_date d
    ON s.OrderDateKey = d.DateKey
GROUP BY d.CalendarQuarter
ORDER BY d.CalendarQuarter;   

# -- Question 11  sales amount and production cost
SELECT
    d.CalendarYear AS Year,
    d.MonthNumberOfYear AS MonthNo,
    d.EnglishMonthName AS MonthName,
    round(SUM(s.SalesAmount),2) AS TotalSales,
    round(SUM(s.TotalProductCost),2) AS TotalProductionCost
    
FROM sales s LEFT JOIN dim_date d
    ON s.OrderDateKey = d.DateKey
GROUP BY
    d.CalendarYear,
    d.MonthNumberOfYear,
    d.EnglishMonthName
ORDER BY
    d.CalendarYear,
    d.MonthNumberOfYear;

# -- Question 12 performance 
SELECT round(SUM(SalesAmount),2) AS TotalSales
FROM sales;

SELECT Round(AVG(SalesAmount),2) AS AverageSales
FROM sales;


SELECT Round(MAX(SalesAmount),2) AS MaximumSales
FROM sales;


SELECT Round(MIN(SalesAmount),2) AS MinimumSales
FROM sales;

SELECT Round(SUM(TotalProductCost),2) AS TotalProductionCost
FROM sales;


SELECT
    round(SUM(SalesAmount - TotalProductCost),2) AS TotalProfit
FROM sales;

SELECT SUM(OrderQuantity) AS TotalQuantity
FROM sales;

