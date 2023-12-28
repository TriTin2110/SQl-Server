use NORTHWND

--Bài tập TITV 1
With TotalPrice as 
(
	select od.ProductID, sum(od.Quantity * od.UnitPrice) as Total
	from [Order Details] od
	group by od.ProductID
)

select p.ProductID, p.ProductName, tp.Total
from Products p
join TotalPrice tp on  p.ProductID = tp.ProductID
order by ProductID asc

--Bài tập TITV 2
With TotalPrice as 
(
	select od.OrderID, sum(od.Quantity * od.UnitPrice) as Total
	from [Order Details] od
	group by od.OrderID
)
select cus.CustomerID, cus.CompanyName, tp.Total
from Orders o
join TotalPrice tp on o.OrderID = tp.OrderID
join Customers cus on o.CustomerID = cus.CustomerID
order by tp.Total desc

--Bài tập TITV 3
With TotalPrice as 
(
	select od.OrderID, sum(od.Quantity * od.UnitPrice) as Total
	from [Order Details] od
	group by od.OrderID
)
select year(o.OrderDate), sum(tp.Total)
from Orders o
join TotalPrice tp on tp.OrderID = o.OrderID
group by  year(o.OrderDate)