-- Rossmann Sales Project

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE "D:/Rossmann Sales Forecasting Project/Rossmann_CleanedwithFeatures.csv"
INTO TABLE rossmann_cleanedwithfeatures
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

create table rossmann
like rossmann_cleanedwithfeatures;

insert rossmann
select * from rossmann_cleanedwithfeatures;

select * from rossmann limit 10;


update rossmann
set SalesPerCustomer = round(SalesPerCustomer, 2);

update rossmann
set AvgStoreSales = round(AvgStoreSales, 2);

update rossmann
set AvgStoreCustomers = round(AvgStoreCustomers, 2);



-- TOP PERFORMING STORES

-- Stores with most Revenue

select Store, sum(Sales) TotalRevenue from rossmann
group by Store
order by TotalRevenue desc limit 10;


select Store, sum(Sales) TotalRevenue, StoreType from rossmann
where StoreType = 'a'
group by Store
order by TotalRevenue desc limit 10;


select Store, sum(Sales) TotalRevenue, Assortment from rossmann
where Assortment = 'c'
group by Store
order by TotalRevenue desc limit 10;


select Store, sum(Sales) TotalRevenue, StateHoliday from rossmann
where StateHoliday = 0
group by Store 
order by TotalRevenue desc;

select Store, sum(Sales) TotalRevenue, SchoolHoliday from rossmann
where SchoolHoliday = 1
group by Store 
order by TotalRevenue desc;


-- Stores with highest Average Revenue

select Store, avg(Sales) AvgRevenue from rossmann
group by Store
order by AvgRevenue desc limit 10;


select Store, sum(Sales) Revenue, Month, Year from rossmann
where Month = 6 and Year = 2014
group by Store
order by Revenue desc;

select * from rossmann;


-- TIME SERIES TREND ANALYSIS

-- Monthly Revenue

SELECT
    YEAR(Date) AS year,
    MONTH(Date) AS month,
    SUM(Sales) AS total_sales,
    LAG(SUM(Sales)) over(order by YEAR(Date), MONTH(Date))
FROM rossmann
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY YEAR(Date), MONTH(Date);


-- Yearly Revenue

SELECT
    YEAR(Date) AS year,
    SUM(Sales) AS total_sales
FROM rossmann
GROUP BY YEAR(Date)
ORDER BY YEAR(Date);


SELECT
    WEEK(Date) AS week_no,
    AVG(Sales) AS avg_weekly_sales
FROM rossmann
GROUP BY week_no
ORDER BY week_no;

-- DAY OF THE WEEK AND MONTH

select DayOfWeek, sum(Customers) TotalCustomers, sum(Sales) Revenue from rossmann
group by DayOfWeek
order by TotalCustomers desc;

select Day, sum(Customers) TotalCustomers, sum(Sales) Revenue from rossmann
group by Day
order by TotalCustomers desc;


-- PROMOTION ANALYSIS

select Promo, sum(Customers) TotalCustomers, sum(Sales) Revenue from rossmann
group by Promo
order by TotalCustomers desc;


-- Promo Impact Percentage

SELECT
    (
        AVG(CASE WHEN Promo = 1 THEN Sales END)
        -
        AVG(CASE WHEN Promo = 0 THEN Sales END)
    )
    /
    AVG(CASE WHEN Promo = 0 THEN Sales END)
    * 100 AS promo_impact_percent
FROM rossmann;



-- COMPETITION ANALYSIS

SELECT
    CASE
        WHEN CompetitionDistance < 1000 THEN 'Near'
        WHEN CompetitionDistance < 5000 THEN 'Medium'
        ELSE 'Far'
    END AS competition_range,
    AVG(Sales) AS avg_sales,
    SUM(Sales) Revenue,
    AVG(Customers) AvgCustomers,
    COUNT(DISTINCT Store) Stores
FROM rossmann
GROUP BY competition_range;


-- Rolling Total of Sales by each Date

SELECT
    Date,
    SUM(Sales) AS daily_sales,
    SUM(SUM(Sales)) OVER (ORDER BY Date) AS running_sales
FROM rossmann
GROUP BY Date
ORDER BY Date;


-- Ranking Stores based on Revenue
SELECT
    Store,
    SUM(Sales) AS total_revenue,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS rrank
FROM rossmann
GROUP BY Store;



SELECT
    Store,
    SUM(Customers) AS total_customers,
    RANK() OVER (ORDER BY SUM(Customers) DESC) AS rrank
FROM rossmann
GROUP BY Store;


-- Store performances with and without Promotion

SELECT
    StoreType,
    AVG(Sales) AS avg_sales
FROM rossmann
WHERE Promo = 1
GROUP BY StoreType
ORDER BY avg_sales DESC;


SELECT
    StoreType,
    AVG(Sales) AS avg_sales
FROM rossmann
WHERE Promo2 = 0
GROUP BY StoreType
ORDER BY avg_sales DESC;


-- Daily growth of Sales (CTE)

WITH monthly_sales AS (
    SELECT
        YEAR(Date) AS year,
        MONTH(Date) AS month,
        SUM(Sales) AS total_sales
    FROM rossmann
    GROUP BY YEAR(Date),  MONTH(Date)
)

SELECT
    year,
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY year, month) AS previous_month_sales,
    
    (
        (total_sales - LAG(total_sales) OVER (ORDER BY year, month))
        /
        LAG(total_sales) OVER (ORDER BY year, month)
    ) * 100 AS growth_percent

FROM monthly_sales;



select Promo, sum(Sales), count(Promo), avg(Sales) from rossmann
group by Promo;

select Quarter, sum(Sales), sum(Customers) from rossmann
where year != 2015
group by Quarter
order by Quarter;

select Quarter, sum(Sales), sum(Customers) from rossmann
where Promo = 1
group by Quarter
order by Quarter;


select StoreType, sum(Sales), sum(Customers) from rossmann
group by StoreType
order by StoreType;

select Month, sum(Sales), sum(Customers) from rossmann
where Year != 2015
group by Month
order by Month;


select StoreType, avg(Customers) from rossmann
group by StoreType
order by avg(Customers) desc;

select CompetitionDistance, count(Store) from rossmann
group by CompetitionDistance;

create view one as
select Store, sum(Sales) Revenue, sum(Customers) Customers from rossmann
where CompetitionDistance < 1000
group by Store
order by Revenue desc;


select Store, sum(Sales) Revenue, sum(Customers) Customers from rossmann
where Promo = 0 and CompetitionDistance < 1000
group by Store 
order by Revenue desc;



select Store, sum(Sales) TotalRevenue from rossmann
Where IsMonthStart = 1
group by Store
order by TotalRevenue desc;













