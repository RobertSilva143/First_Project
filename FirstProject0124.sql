
--Arranging products by their category
Select ProductName,CategoryID
From [FirstProject0124].[dbo].[Products]
Group by CategoryID,ProductName

--Selecting products by it category 
Select ProductName
From [FirstProject0124].[dbo].[Products]
Where CategoryID = 105


--Employees who joined the company on the same year and month
Select FirstName, LastName, Position
From [FirstProject0124].[dbo].[RegisteredEmployee]
Where JoinDateYear = 2019 and JoinDateMonth = 'April'


--total number of customers in a specific city
Select FirstName, LastName, City, COUNT(City) OVER(Partition by City) as TotalCustomer
From [FirstProject0124].[dbo].[Customer]
Where City = 'Quezon'
Group by City, FirstName, LastName,City

Select City, COUNT(City)
From [FirstProject0124].[dbo].[Customer]
--Where City = 'Quezon'
Group by City


--Number of Returning Customer in the store
  Select Distinct CustomerID, COUNT(CustomerID) as Number_of_Returns
  FROM [FirstProject0124].[dbo].[TransactionsOrders]
  Group by CustomerID
  HAVING COUNT(CustomerID) <> 1 
  Order by Number_of_Returns Desc

--Total sales for a specific product:
Select ProductID, SUM(Total) as ProductTotalSales
From [FirstProject0124].[dbo].[Sales]
--Where ProductID = 11010068
Group by ProductID
Order by ProductTotalSales Desc

--Top 5 products with the highest stock quantity:

SELECT TOP 5 ProductName, StockQuantity
FROM [FirstProject0124].[dbo].[Products]
ORDER BY StockQuantity DESC

--TOP 5 Customer with the highest total spending:
SELECT TOP 5 TransactionsOrders.CustomerID, Customer.FirstName, Customer.LastName,Customer.City,Customer.MembershipCard,Customer.MembershipID
,SUM(TotalAmount) As CustomerTotalSpent
FROM [FirstProject0124].[dbo].[TransactionsOrders]
Left Outer Join [FirstProject0124].[dbo].[Customer]
ON  TransactionsOrders.CustomerID = Customer.CustomerID
Group by TransactionsOrders.CustomerID ,Customer.FirstName, Customer.LastName, Customer.City,Customer.MembershipCard,Customer.MembershipID
Order by CustomerTotalSpent Desc


--Overview of Products based on stocks (total, sold and remaining stocks)
Select Sales.ProductID,Products.ProductName, SUM(QuantitySold) as TotalNoProductSold,Products.StockQuantity, StockQuantity - SUM(QuantitySold) as RemainingStock
From [FirstProject0124].[dbo].[Sales]
Left Outer Join [FirstProject0124].[dbo].[Products]
ON  Sales.ProductID = Products.ProductID
Group by Sales.ProductID,Products.StockQuantity,Products.ProductName
Order by TotalNoProductSold Desc

--All customers who have a valid membership and their total points earned
SELECT PT.MembershipID, MB.StartingPoints + SUM(PointsEarned) AS TotalPoints
FROM [FirstProject0124].[dbo].[PointTransactions] as PT 
Left Outer Join [FirstProject0124].[dbo].[MembershipID] as MB
	ON  PT.MembershipID = MB.MembershipID
Left Outer Join [FirstProject0124].[dbo].[Customer] as CT
	ON MB.MembershipID = CT.MembershipID
Where PT.MembershipID is NOT NULL AND CT.MembershipCard = 'Valid'
Group by PT.MembershipID, MB.StartingPoints
Order by PT.MembershipID

--Months with the highest and lowest total revenue:
Select  top 10 YEAR(DatePurchased) AS year, MONTH(DatePurchased) AS month,  SUM(TotalAmount) as MonthlyRevenue
From [FirstProject0124].[dbo].[TransactionsOrders]
Group by YEAR(DatePurchased),MONTH(DatePurchased)
order by MonthlyRevenue Desc --Asc(for lowest)

--Monthly growth rate of total revenue
WITH MonthlyRevenue AS (
    SELECT
        YEAR(DatePurchased) AS Year,
        MONTH(DatePurchased) AS Month,
        SUM(TotalAmount) AS TotalRevenue
    FROM
		[FirstProject0124].[dbo].[TransactionsOrders]
    GROUP BY
        YEAR(DatePurchased),
        MONTH(DatePurchased)
)

SELECT
    Year,
    Month,
    TotalRevenue,
    ((TotalRevenue - LAG(TotalRevenue) OVER (ORDER BY Year)) / LAG(TotalRevenue) OVER (ORDER BY Year)) * 100 AS MonthlyGrowthRate
FROM
    MonthlyRevenue
ORDER BY
    Year, Month;


--Average time between consecutive transactions for each customer
WITH CustomerDayInterval AS (
Select CustomerID, DatePurchased
				,DATEDIFF(DAY,LAG(DatePurchased) OVER (Partition by CustomerID ORDER BY DatePurchased),DatePurchased) as TimeInterval			
From [FirstProject0124].[dbo].[TransactionsOrders]
Group by CustomerID,DatePurchased
)

Select CustomerID, AVG(TimeInterval)
From CustomerDayInterval
Group by CustomerID
HAVING AVG(TimeInterval) IS NOT NULL --THERE ARE NULL VALUES SINCE THERE ARE CUSTOMER WHO DIDN'T COMEBACK TO BUY AGAIN FROM THE STORE
Order by CustomerID