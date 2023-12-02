use NORTHWND
--Bài tập TITV 1
select distinct p.ProductName, sup.CompanyName
from [Order Details] od join Products p on od.ProductID = p.ProductID
						join Suppliers sup on p.SupplierID = sup.SupplierID
--Bài tập TITV 2						
select cus.CompanyName, FirstName +' '+LastName
from Orders o	left join Customers cus on o.CustomerID = cus.CustomerID
				left join Employees em on o.EmployeeID = em.EmployeeID

--Bài tập TITV 3
select cus.CompanyName, FirstName +' '+LastName
from Orders o	right join Customers cus on o.CustomerID = cus.CustomerID
				join Employees em on o.EmployeeID = em.EmployeeID

--Bài tập TITV 4
select ca.CategoryName, sup.CompanyName
from Products p full join Suppliers sup on p.SupplierID = sup.SupplierID
				full join Categories ca on p.CategoryID = ca.CategoryID

--Bài tập TITV 5
select distinct cus.CompanyName, p.ProductName
from Products p join [Order Details] od on p.ProductID = od.ProductID
				join Orders o on od.OrderID = o.OrderID
				join Customers cus on o.CustomerID = cus.CustomerID

--Bài tập TITV 6
select FirstName +' '+ LastName, cus.CompanyName
from Customers cus	full join Orders o on cus.CustomerID = o.CustomerID
					full join Employees e on o.EmployeeID = e.EmployeeID