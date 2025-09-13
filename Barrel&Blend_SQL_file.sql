
SET SESSION sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));


#selecting a particular vendor to undertand how the tables are connected to each other and understand the data storage for purchasing
SELECT *,count(*)over() as total 
 FROM purchase_prices
 where VendorNumber = '4466'
;
SELECT *,count(*)over() as total 
 FROM purchases
 where VendorNumber = '4466'
;

#grouping by brand and purchase price to know how many brand does a vendor purchases, at what price and quantity
SELECT brand,PurchasePrice,sum(Quantity) as total_quantity, round(sum(Dollars),2) as total_dollars from purchases
where VendorNumber = '4466'
GROUP BY Brand,PurchasePrice;

# checking if the POnumber(purchase order number) is unique or not
select count(PONumber) as total_POnumber from vendor_invoice
where VendorNumber = '4466';
select count(DISTINCT(PONumber)) as distinct_POnumber from vendor_invoice
where VendorNumber = '4466';

#grouping by brand and sales price to know how many brand does a vendor sell, at what price and quantity
select Brand, round(sum(SalesDollars),2) as total_sales_dollar,
round(sum(SalesPrice),2) as total_sale_price,
round(sum(SalesQuantity),2) as total_sale_quantity
from sales
where VendorNo = '4466'
GROUP BY Brand
LIMIT 10;



SELECT * from sales
;

#checking for duplicate in the sales table using two unique columns as rhe primary key
SELECT *
FROM sales
WHERE InventoryId = '1_HARDERSFIELD_1004'
  AND SalesDate = '2024-01-01'
LIMIT 10;

# Count duplicate records in the sales table using ROW_NUMBER() over key columns
with duplicate_cte as
( SELECT *,
ROW_NUMBER()over(PARTITION BY InventoryId,Store,Brand,`Description`,Size,SalesQuantity,SalesDollars,SalesPrice,SalesDate,Volume,
Classification,ExciseTax,VendorNo,VendorName) as row_num
from sales
)
select count(*) FROM duplicate_cte
where row_num>1
;

select count(*) as dupe from sales;
CREATE TABLE `sales2` (
  `InventoryId` varchar(250) DEFAULT NULL,
  `Store` int DEFAULT NULL,
  `Brand` int DEFAULT NULL,
  `Description` varchar(250) DEFAULT NULL,
  `Size` varchar(100) DEFAULT NULL,
  `SalesQuantity` int DEFAULT NULL,
  `SalesDollars` double DEFAULT NULL,
  `SalesPrice` double DEFAULT NULL,
  `SalesDate` date DEFAULT NULL,
  `Volume` int DEFAULT NULL,
  `Classification` int DEFAULT NULL,
  `ExciseTax` double DEFAULT NULL,
  `VendorNo` int DEFAULT NULL,
  `VendorName` varchar(250) DEFAULT NULL,
  `row_num` INT,
  KEY `idx_vendorno` (`VendorNo`),
  KEY `idx_inventory_salesdate` (`InventoryId`,`SalesDate`),
  KEY `idx_sales` (`InventoryId`(50),`Store`,`Brand`,`Description`(100),`Size`(50),`SalesQuantity`,`SalesDollars`,`SalesPrice`,`SalesDate`,`Volume`,`Classification`,`ExciseTax`,`VendorNo`,`VendorName`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT * from sales2;

#inserting sales data into with the row num into a new column to deal woth the duplicates
INSERT INTO sales2 (
    InventoryId, Store, Brand, `Description`, Size,
    SalesQuantity, SalesDollars, SalesPrice, SalesDate, Volume,
    Classification, ExciseTax, VendorNo, VendorName, row_num
)
SELECT 
    InventoryId, Store, Brand, `Description`, Size,
    SalesQuantity, SalesDollars, SalesPrice, SalesDate, Volume,
    Classification, ExciseTax, VendorNo, VendorName,
    ROW_NUMBER() OVER (
        PARTITION BY 
            InventoryId, Store, Brand, `Description`, Size,
            SalesQuantity, SalesDollars, SalesPrice, SalesDate, Volume,
            Classification, ExciseTax, VendorNo, VendorName
    ) AS row_num
FROM sales;


DELETE from sales2
where row_num > 1;

#grouping purchase and sales summaries for Vendor 4466, aggregated by Brand (and PurchasePrice for purchases)
SELECT brand,PurchasePrice,sum(Quantity) as total_quantity, round(sum(Dollars),2) as total_dollars from purchases
where VendorNumber = '4466'
GROUP BY Brand,PurchasePrice
order by Brand;
select Brand, round(sum(SalesQuantity),2) as salesquantity ,round(sum(SalesDollars),2)as salesDollar
,round(sum(SalesPrice),2) as salesPrice from sales2
where VendorNo = '4466'
GROUP BY Brand
LIMIT 10;

# creating invoice summarry
SELECT 
    VendorNumber,
    VendorName,
    ROUND(SUM(Freight), 2) AS frieght,
    COUNT(VendorNumber) 
FROM
    vendor_invoice
GROUP BY VendorNumber , VendorName;


# creating purchase summary 
SELECT 
    a.VendorNumber,
    a.VendorName,
    a.Brand,
    a.PurchasePrice,
    b.Price AS actual_price,
    b.Volume,
    SUM(a.Quantity) total_purchase_quantity,
    SUM(a.Dollars) total_purchase_dollar
FROM
    purchases AS a
        JOIN
    purchase_prices AS b ON a.brand = b.brand
WHERE
    a.PurchasePrice > 0
GROUP BY a.VendorNumber , a.VendorName , a.Brand
ORDER BY total_purchase_dollar;


# creating sales summarry
SELECT VendorNo,Brand,round(sum(SalesDollars),2) as total_sale_dollar, round(sum(SalesPrice),2) as total_sales_price, 
sum(SalesQuantity) as total_sales_quantity,round(sum(ExciseTax),2) as total_ExciseTax
 from sales2
 GROUP BY VendorNo, Brand
 order by round(sum(SalesDollars),2) DESC;
 
 
SELECT 
    a.VendorNumber,
    a.Brand,
    a.Price,
    a.PurchasePrice,
	ROUND(SUM(b.SalesDollars), 2) AS total_sale_dollar,
    ROUND(SUM(b.SalesPrice), 2) AS total_sales_price,
    SUM(b.SalesQuantity) AS total_sales_quantity,
    ROUND(SUM(b.ExciseTax), 2) AS total_ExciseTax,
    SUM(c.Quantity) total_purchase_quantity,
    SUM(c.Dollars) total_purchase_dollar,
    ROUND(SUM(c.Freight), 2) AS frieght
FROM
    purchase_prices AS a
        JOIN
    sales2 AS b ON a.VendorNumber = b.VendorNo
    and
    a.Brand = b.Brand
        JOIN
    vendor_invoice AS c ON a.VendorNumber = c.VendorNumber
GROUP BY a.VendorNumber , a.Brand , a.Price,a.PurchasePrice;



# creating a view with all three summary tables 
CREATE VIEW agg_table AS
SELECT
    p.VendorNumber,
    p.VendorName,
    p.Brand,
    p.`Description`,
    p.PurchasePrice,
    p.actual_price,
    p.volume,
    ROUND(p.total_purchase_quantity, 2)    AS total_purchase_quantity,
    ROUND(p.total_purchase_dollar, 2)      AS total_purchase_dollar,
    ROUND(s.total_sale_dollar, 2)          AS total_sale_dollar,
    ROUND(s.total_sales_price, 2)          AS total_sales_price,
    ROUND(s.total_sales_quantity, 2)       AS total_sales_quantity,
    ROUND(s.total_ExciseTax, 2)            AS total_ExciseTax,
    ROUND(i.total_freight, 2)              AS total_freight
FROM
    (
      -- purchase aggregates per vendor + brand
      SELECT
        a.VendorNumber,
        a.VendorName,
        a.Brand,
        a.`Description`,
        a.PurchasePrice,
        b.Price       AS actual_price,
        b.Volume,
        SUM(a.Quantity) AS total_purchase_quantity,
        SUM(a.Dollars)   AS total_purchase_dollar
      FROM purchases AS a
      JOIN purchase_prices AS b
        ON a.Brand = b.Brand
      WHERE a.PurchasePrice > 0
      GROUP BY a.VendorNumber, a.VendorName, a.Brand, a.`Description`, a.PurchasePrice, b.Price, b.Volume
    ) AS p
LEFT JOIN
    (
      -- sales aggregates per vendor + brand
      SELECT
        VendorNo     AS VendorNumber,
        Brand,
        SUM(SalesDollars)  AS total_sale_dollar,
        SUM(SalesPrice)    AS total_sales_price,
        SUM(SalesQuantity) AS total_sales_quantity,
        SUM(ExciseTax)     AS total_ExciseTax
      FROM sales2
      GROUP BY VendorNo, Brand
    ) AS s
  ON p.VendorNumber = s.VendorNumber
 AND p.Brand        = s.Brand
LEFT JOIN
    (
      -- invoice aggregates per vendor
      SELECT
        VendorNumber,
        SUM(Freight) AS total_freight
      FROM vendor_invoice
      GROUP BY VendorNumber
    ) AS i
  ON p.VendorNumber = i.VendorNumber;

SELECT
  SUM(VendorNumber IS NULL) AS VendorNumber_nulls,
  SUM(VendorName IS NULL) AS VendorName_nulls,
  SUM(Brand IS NULL) AS Brand_nulls,
  SUM(`Description` IS NULL) AS Description_nulls,
  SUM(PurchasePrice IS NULL) AS PurchasePrice_nulls,
  SUM(actual_price IS NULL) AS actual_price_nulls,
  SUM(volume IS NULL) AS volume_nulls,
  SUM(total_purchase_quantity IS NULL) AS total_purchase_quantity_nulls,
  SUM(total_purchase_dollar IS NULL) AS total_purchase_dollar_nulls,
  SUM(total_sale_dollar IS NULL) AS total_sale_dollar_nulls,
  SUM(total_sales_price IS NULL) AS total_sales_price_nulls,
  SUM(total_sales_quantity IS NULL) AS total_sales_quantity_nulls,
  SUM(total_ExciseTax IS NULL) AS total_ExciseTax_nulls,
  SUM(total_freight IS NULL) AS total_freight_nulls
FROM agg_table;

#creating a table from the view 
CREATE TABLE agg_table_temp as
SELECT * from agg_table;

SELECT DISTINCt(VendorName) FROM agg_table;

# Data cleaning
# Removing whitespace from vendors name
UPDATE agg_table_temp
set VendorName = trim(VendorName);

# Correcting name error
UPDATE agg_table_temp
set VendorName = 'VINEYARD BRANDS INC'
where VendorName = 'VINEYARD BRANDS LLC';

# Dealing with null values
update agg_table_temp
set total_sales_quantity = 0
where total_sales_quantity is null;

update agg_table_temp
set total_sale_dollar = 0
where total_sale_dollar is null;

update agg_table_temp
set total_sales_price = 0
where total_sales_price is null;

update agg_table_temp
set total_ExciseTax = 0
where total_ExciseTax is null;

# calculating and adding gross profit
ALTER TABLE agg_table_temp add COLUMN gross_profit INT;
UPDATE agg_table_temp
set gross_profit = total_sale_dollar - total_purchase_dollar;

# calculating and adding profit margin
ALTER TABLE agg_table_temp add COLUMN profit_margin double;
UPDATE agg_table_temp
SET profit_margin = CASE
    WHEN total_sale_dollar IS NULL OR total_sale_dollar = 0 THEN 0
    ELSE (gross_profit / total_sale_dollar) * 100
END;


# calculating and adding stock turnover
ALTER TABLE agg_table_temp add COLUMN stock_turnover DOUBLE;
UPDATE agg_table_temp
set stock_turnover = total_sales_quantity/total_purchase_quantity;

# calculating and adding sales purchase ratio
ALTER TABLE agg_table_temp add COLUMN sales_purchase_ratio INT;
UPDATE agg_table_temp
set sales_purchase_ratio = total_sale_dollar/total_purchase_dollar;

#setting up a primary key
ALTER TABLE agg_table_temp 
add primary key (VendorNumber, Brand);

RENAME TABLE agg_table_temp to sales_summary;
SELECT * from sales_summary;

select * from begin_inventory;