/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Invoice_Item_Number]
      ,[sale_date]
      ,[Store_Number]
      ,[Store_Name]
      ,[Address]
      ,[City]
      ,[Zip_Code]
      ,[Store_Location]
      ,[County_Number]
      ,[County]
      ,[Category]
      ,[Category_Name]
      ,[Vendor_Number]
      ,[Vendor_Name]
      ,[Item_Number]
      ,[Item_Description]
      ,[Pack]
      ,[Bottle_Volume_ml]
      ,[State_Bottle_Cost]
      ,[State_Bottle_Retail]
      ,[Bottles_Sold]
      ,[Sale_Dollars]
      ,[Volume_Sold_Liters]
      ,[Volume_Sold_Gallons]
  FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales]
  order by sale_date desc

  -- Find top 10 most popular Categories by sales
  SELECT TOP (10) Category_Name, sum (sale_dollars) as total_sales
  FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales]
  GROUP BY Category_Name
  ORDER BY total_sales desc

  --Lets find the top 10 items by sales
  SELECT TOP (10) Item_Description, sum (sale_dollars) as total_sales
  FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales]
  GROUP BY Item_Description
  ORDER BY total_sales desc

--Lets find the top 10 items by volume
  SELECT TOP (10) Item_Description, sum (Volume_Sold_Liters) as total_volume
  FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales]
  GROUP BY Item_Description
  ORDER BY total_volume desc


-- Find top 20 most popular Categories by Iowa State and UofIowa 
  SELECT TOP (20) Category_Name, city, sum (sale_dollars) as total_sales
  FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales]
  WHERE city = 'ames' or city = 'iowa city'
  GROUP BY city, Category_Name 
  ORDER BY total_sales desc

-- Find top 20 most popular Items by Iowa State and UofIowa 
  SELECT TOP (20) Item_Description, city, sum (sale_dollars) as total_sales
  FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales]
  WHERE city = 'ames' or city = 'iowa city'
  GROUP BY city, Item_Description 
  ORDER BY total_sales desc


  --Lets find the top 10 bourbon by volume
  SELECT TOP (10) Item_Description, sum (Volume_Sold_Liters) as total_volume
  FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales]
  WHERE Category_Name like '%bourbon%'
  GROUP BY Item_Description
  ORDER BY total_volume desc;

  --Lets find the top 20 bourbon by sales
  SELECT TOP (20) Item_Description, sum (sale_dollars) as total_sales
  FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales]
  WHERE Category_Name like '%bourbon%'
  GROUP BY Item_Description
  ORDER BY total_sales desc;


--finding Top 10 by sales dollars by county
  SELECT CN.*
	FROM (SELECT ia.county, ia.Item_Description, sum (ia.sale_dollars) as total_sales,
	 RANK() over(partition by county order by sum (ia.sale_dollars)desc) as rnk
	 FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales] IA
	 where county is not null
	 group by ia.county, ia.Item_Description) CN

  where rnk <= 10;

--finding counties where Black Velvet is #1
  SELECT CN.*
	FROM (SELECT ia.county, ia.Item_Description, sum (ia.sale_dollars) as total_sales,
	 RANK() over(partition by county order by sum (ia.sale_dollars)desc) as rnk
	 FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales] IA
	 where county is not null
	 group by ia.county, ia.Item_Description) CN

  where item_description = 'black velvet' and rnk = 1;


--finding top 10 of each bourbon category
  SELECT CN.*
	FROM (SELECT ia.Category_Name, ia.Item_Description, sum (ia.sale_dollars) as total_sales,
	 RANK() over(partition by Category_Name order by sum (ia.sale_dollars)desc) as rnk
	 FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales] IA
	 where Category_name like '%bourbon%'
	 group by ia.Category_Name, ia.Item_Description) CN

  where rnk <= 10;


--fact checking Cedar Ridge article https://cedarridgewhiskey.com/cedar-ridge-becomes-1-selling-bourbon-in-iowa/
  SELECT CN.*
	FROM (SELECT ia.Category_Name, ia.Item_Description, sum (ia.sale_dollars) as total_sales,
	 RANK() over(partition by Category_Name order by sum (ia.sale_dollars)desc) as rnk
	 FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales] IA
	 where '2019-11-01' < sale_date and sale_date < '2020-11-01' and Category_name = 'Straight Bourbon Whiskies' and Bottle_Volume_ml = 750
	 group by ia.Category_Name, ia.Item_Description) CN

  where rnk <= 10;

  --Finding quarterly bourbon sales
SELECT Category_Name, DATEPART (quarter, sale_date) as sales_quarter, DATEPART (year, sale_date) as sales_year, SUM(sale_dollars) as total_sales
  FROM [iowa_alc].[dbo].[201920201_Iowa_Liquor_Sales]
  WHERE '2019-01-02' < sale_date and sale_date < '2021-12-31' and Category_Name like '%bourbon%'
  group by DATEPART (year, sale_date), DATEPART (quarter, sale_date), Category_Name
  order by DATEPART (year, sale_date), DATEPART (quarter, sale_date);