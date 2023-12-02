use NORTHWND
--Bài tập TITV 1
select cus.ContactName, e.FirstName +' '+ e.LastName
from Orders o	join Customers cus on o.CustomerID = cus.CustomerID
				join Employees e on o.EmployeeID = e.EmployeeID

--Bài tập TITV 2
select p.ProductName, s.ContactName
from Products p left join Suppliers s on p.SupplierID = s.SupplierID

--Bài tập TITV 3
select cus.ContactName, o.ShipName
from Orders o right join Customers cus on o.CustomerID = cus.CustomerID

--Bài tập TITV 4
select s.ContactName, ca.CategoryName
from Products p		full join Suppliers s on p.SupplierID = s.SupplierID
					full join Categories ca on p.CategoryID = ca.CategoryID 

-- Thử thách 
-- 1. In ra tên nhân viên , tổng số đơn nhân viên đó bán được  (Bảng Employees , Bảng Orders)
-- Dùng LEFT JOIN 
-- Bao gồm nhân viên chưa bán được hàng (Mới thêm vào)
select e.FirstName +' '+ e.LastName , Count(o.OrderID)
from Employees e left join Orders o on e.EmployeeID = o.EmployeeID
group by e.FirstName, e.LastName