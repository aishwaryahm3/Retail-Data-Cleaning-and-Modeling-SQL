--Creating the Database and using it
Create database SuperStoreDB
use SuperStoreDB

--1.
--Data imported successfully
--Checking that
select top 10 * from Superstore_Original

-- Creating Staging table first
Select top 0 * into SuperStore
from Superstore_Original

-- Inserting the data
Insert into SuperStore 
select * from Superstore_Original

-- Checking if the data has been transferred
Select * from SuperStore

--2.
-- Checking for duplicates
select *,
ROW_NUMBER() over 
		(
			partition by  Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, 
			Customer_Name, Segment, Country, City, Current_State, Postal_Code, Region, Product_ID, 
			Category, Sub_Category, Product_Name, Sales, Quantity, Discount, Profit
			order by (select null)
		) as row_num
from SuperStore

-- Let's put this in a CTE and check for duplicates
With duplicates_CTE1 as
(
	select *,
	ROW_NUMBER() over 
			(
				partition by Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, 
				Customer_Name, Segment, Country, City, Current_State, Postal_Code, Region, Product_ID, 
				Category, Sub_Category, Product_Name, Sales, Quantity, Discount, Profit
				order by (select null)
			) as row_num
	from SuperStore
)
select * from duplicates_CTE1
where row_num > 1

-- Only 1 exact duplicate found
-- Let's dig deeper using fewer columns

With duplicates_CTE2 as
(
	select * ,
	ROW_NUMBER() 
	over
		(
			partition by Order_ID,Customer_ID,Product_ID,Order_Date
			order by (select Null)
		) as row_num
	from SuperStore 
)
select * from duplicates_CTE2
where row_num > 1

-- 8 potential duplicates found
-- Let's verify if these are actual duplicates or just similar records
select * from SuperStore
where Order_ID in
(
'CA-2016-137043',
'CA-2016-140571',
'CA-2017-118017',
'CA-2017-152912',
'US-2014-150119',
'US-2016-123750'
)
order by Order_ID

-- Out of these, only records with Order_ID = 'US-2014-150119' are exact duplicates
-- Let's drop that row

-- CTE for deletion
With del_duplicates_CTE1 as
(
	select *,
	ROW_NUMBER() over 
			(
				partition by Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, 
				Customer_Name, Segment, Country, City, Current_State, Postal_Code, Region, Product_ID, 
				Category, Sub_Category, Product_Name, Sales, Quantity, Discount, Profit
				order by (select null)
			) as row_num
	from SuperStore
)
delete from del_duplicates_CTE1
where row_num > 1

-- Verifying again to confirm deletion
With duplicates_CTE1 as
(
	select *,
	ROW_NUMBER() over 
			(
				partition by Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, 
				Customer_Name, Segment, Country, City, Current_State, Postal_Code, Region, Product_ID, 
				Category, Sub_Category, Product_Name, Sales, Quantity, Discount, Profit
				order by (select null)
			) as row_num
	from SuperStore
)
Select * from duplicates_CTE1
where row_num > 1

-- All duplicates have been successfully removed

-- Date Standardization
-- Previewing the table to review the data
Select * from SuperStore

-- Let's start by checking Order_ID
Select distinct Order_ID from Superstore
order by 1

-- Looks clean. Format seems consistent. No transformation needed.

-- Checking all the dates
Select Order_Date,Ship_Date from Superstore
order by 1

-- Looks clean. Date format seems consistent. No transformation needed.

-- Checking for NULLs in each column
Select
sum(case when Row_ID is NULL then 1 else 0 end) as Row_ID_null_count,
sum(case when Order_ID is NULL then 1 else 0 end) as Order_ID_null_count,
sum(case when Order_Date is NULL then 1 else 0 end) as Order_Date_null_count,
sum(case when Ship_Date is NULL then 1 else 0 end) as Ship_Date_null_count,
sum(case when Ship_Mode is NULL then 1 else 0 end) as Ship_Mode_null_count,
sum(case when Customer_ID is NULL then 1 else 0 end) as Customer_ID_null_count,
sum(case when Customer_Name is NULL then 1 else 0 end) as Customer_Name_null_count,
sum(case when Segment is NULL then 1 else 0 end) as Segment_null_count,
sum(case when Country is NULL then 1 else 0 end) as Country_null_count,
sum(case when City is NULL then 1 else 0 end) as City_null_count,
sum(case when Current_State is NULL then 1 else 0 end) as Current_State_null_count,
sum(case when Postal_Code is NULL then 1 else 0 end) as Postal_Code_null_count,
sum(case when Region is NULL then 1 else 0 end) as Region_null_count,
sum(case when Product_ID is NULL then 1 else 0 end) as Product_ID_null_count,
sum(case when Category is NULL then 1 else 0 end) as Category_null_count,
sum(case when Sub_Category is NULL then 1 else 0 end) as Sub_Category_null_count,
sum(case when Product_Name is NULL then 1 else 0 end) as Product_Name_null_count,
sum(case when Sales is NULL then 1 else 0 end) as Sales_null_count,
sum(case when Quantity is NULL then 1 else 0 end) as Quantity_null_count,
sum(case when Discount is NULL then 1 else 0 end) as Discount_null_count,
sum(case when Profit is NULL then 1 else 0 end) as Profit_null_count
from Superstore

-- We can see that 'Profit' has 1 NULL value
-- Verifying that record
Select * from Superstore
where Profit is null

-- Confirmed. Replacing NULL with 0
Update Superstore
set Profit = 0
where Profit is NULL

-- Completed successfully
-- Final check to confirm
Select * from Superstore
where Profit is null

-- Done

-- Standardizing string values
Select Ship_Mode,Customer_Name,Segment,Country,City,Current_State,Region,Category,Sub_Category,Product_Name from Superstore

-- For better readability, let's trim all these columns
Update Superstore
set Ship_Mode = Trim(Ship_Mode),
Customer_Name = Trim(Customer_Name),
Segment = Trim(Segment), 
Country = Trim(Country),
City = Trim(City),
Current_State = Trim(Current_State),
Region = Trim(Region),
Category = Trim(Category),
Sub_Category = Trim(Sub_Category),
Product_Name = Trim(Product_Name)

-- Done

-- Standardizing the numbers
select top 10 * from SuperStore

Update SuperStore
set Sales = cast(round(Sales, 2) as decimal(10, 2)),
	Discount = cast(round(Discount, 2) as decimal(10, 2)),
	Profit = cast(round(Profit, 2) as decimal(10, 2))

-- Checking if the changes were applied
Select top 10 Sales,Discount,Profit from SuperStore

-- 3.
-- Let's normalize the data
-- Customers table
Create Table Customers
(
	Customer_ID Varchar(50) Primary key,
	Customer_Name Varchar(50),
	Segment Varchar(50)
)

-- Inserting the records
Insert into Customers (Customer_ID,Customer_Name,Segment)
Select Distinct Customer_ID,Customer_Name,Segment from SuperStore

-- Products table
-- Creating the table
Create Table Products
(
	Product_ID Varchar(50) Primary key,
	Category Varchar(50),
	Sub_Category Varchar(50),
	Product_Name Varchar(500)
)
-- Inserting the data
Insert into Products(Product_ID,Category,Sub_Category,Product_Name)
Select distinct Product_ID,Category,Sub_Category,Product_Name from SuperStore

-- Seems like we can't use Product_ID as PK
-- Let's check for duplicate Product_ID + Product_Name
Select distinct Product_ID,Product_Name,COUNT(*) from SuperStore
group by Product_ID , Product_Name
having COUNT(*) > 1

-- Some values have count > 1
-- So better to create a new PK as Product_Key
Drop table Products

Create Table Products
(
	Product_Key Int identity(1,1) Primary key,
	Product_ID Varchar(50),
	Category Varchar(50),
	Sub_Category Varchar(50),
	Product_Name Varchar(500)
)

Insert into Products(Product_ID,Category,Sub_Category,Product_Name)
Select distinct Product_ID,Category,Sub_Category,Product_Name from SuperStore

select * from Products

-- Creating Regions table
Create table Regions 
(
  Region Varchar (50),
  Country Varchar (50),
  Current_State Varchar (50),
  City Varchar (50),
  Postal_Code Varchar (50)
)

Select Region,COUNT(*) from SuperStore
group by Region
having count(*)>1

-- Let’s create Region_ID as a new column with unique values
Drop table Regions

Create table Regions 
(
	Region_ID Int Identity(1,1) Primary Key,
	Region Varchar (50),
	Country Varchar (50),
	Current_State Varchar (50),
	City Varchar (50),
	Postal_Code Varchar (50)
)

Insert into Regions(Region,Country,Current_State,City,Postal_Code)
Select distinct Region,Country,Current_State,City,Postal_Code from SuperStore

-- Creating the Orders table

Create Table Orders 
(
    Order_Item_ID Int Identity(1,1) Primary key,
    Order_ID Varchar(50),
    Order_Date Date,
    Ship_Date Date,
    Ship_Mode Varchar(50),
    Customer_ID Varchar(50),
    Product_Key Int,
    Region_ID Int,
    Sales Decimal(10,2),
    Quantity Int,
    Discount Decimal(10,2),
    Profit Decimal(10,2),

    Foreign Key (Customer_ID) References Customers(Customer_ID),
    Foreign Key (Product_Key) References Products(Product_Key),
    Foreign Key (Region_ID) References Regions(Region_ID)
);
-- Checking Orders table
Select * from Orders

-- Inserting data into Orders table
Insert Into Orders (
    Order_ID, Order_Date, Ship_Date, Ship_Mode,
    Customer_ID, Product_Key, Region_ID,
    Sales, Quantity, Discount, Profit
)
Select 
    s.Order_ID, s.Order_Date, s.Ship_Date, s.Ship_Mode,
    s.Customer_ID,
    p.Product_Key,
    r.Region_ID,
    s.Sales, s.Quantity, s.Discount, s.Profit
from SuperStore s
join Products p 
    on s.Product_ID = p.Product_ID and s.Product_Name = p.Product_Name
join Regions r 
    on s.Region = r.Region 
    and s.Country = r.Country 
    and s.Current_State = r.Current_State 
    and s.City = r.City 
    and s.Postal_Code = r.Postal_Code;


-- Final sanity check
-- Final row counts
SELECT COUNT(*) as Cnt_SuperStore FROM SuperStore;
SELECT COUNT(*)as Cnt_Orders FROM Orders;

-- Check NULLs in final Orders table
SELECT 
    SUM(CASE WHEN Product_Key IS NULL THEN 1 ELSE 0 END) AS Null_Products,
    SUM(CASE WHEN Region_ID IS NULL THEN 1 ELSE 0 END) AS Null_Regions
FROM Orders;

