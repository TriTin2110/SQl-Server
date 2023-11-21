use NORTHWND
--Bài tập TITI1
select c.CategoryID, c.CategoryName, p.ProductID, s.SupplierID
from Products p, Categories c, Suppliers s
where p.CategoryID = c.CategoryID and p.SupplierID = s.SupplierID and c.CategoryName = 'Seafood'

--Bài tập TITV2
select s.SupplierID, s.Country, p.ProductID, p.ProductName
from Products p, Suppliers s
where p.SupplierID = s.SupplierID and s.Country = 'Germany'

--Bài tập TITV3
select o.OrderID, cus.ContactName, sh.CompanyName 
from Orders o, Customers cus, Shippers sh
where o.CustomerID = cus.CustomerID and o.ShipVia = sh.ShipperID and o.ShipCity = 'London'

--Bài tập TITV4
select o.OrderID, cus.ContactName, s.CompanyName, o.RequiredDate, o.ShippedDate
from Orders o, Customers cus, Shippers s
where o.CustomerID = cus.CustomerID and o.ShipVia = s.ShipperID and o.ShippedDate > o.RequiredDate

--Bài tập TITV5
select o.ShipCountry, count(OrderID)
from Orders o, Shippers s, Customers cus
where o.ShipVia = s.ShipperID and o.CustomerID = cus.CustomerID
group by o.ShipCountry
having count(OrderID) > 100