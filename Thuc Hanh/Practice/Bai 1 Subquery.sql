--1) Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID có trên
--100 đơn đặt hàng trong tháng 7 năm 2008
select Name, p.ProductID
from Production.Product p
join sales.SalesOrderDetail sd on sd.ProductID = p.ProductID
join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
where p.ProductID in (select p.ProductID
					from Production.Product p
					join sales.SalesOrderDetail sd on sd.ProductID = p.ProductID
					join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
					where year(OrderDate) = 2013 and month(OrderDate) = 7
					group by p.ProductID
					having count(*) > 100	--count(*) là số lượng đơn đặt hàng của 1 sản phẩm
					)
group by Name, p.ProductID

--2) Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất trong
--tháng 7/2008
select p.ProductID, Name
from Production.Product p
join Sales.SalesOrderDetail sd on sd.ProductID = p.ProductID
join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
where year(OrderDate) = 2012 and month(OrderDate) = 7
group by p.ProductID, Name
having count(*) >= all	(select count(*)
						from Production.Product p
						join Sales.SalesOrderDetail sd on sd.ProductID = p.ProductID
						join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
						where year(OrderDate) = 2012 and month(OrderDate) = 7
						group by p.ProductID)

--3) Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm:
--CustomerID, Name, CountOfOrder
--Thông tin khách hàng lấy từ 2 bản Sales.Customer và Person.Person
select cus.CustomerID, FirstName +' '+ LastName as Name, count(*) as CountOfOrder
from Sales.Customer cus
join Person.Person per on cus.CustomerID = per.BusinessEntityID
join Sales.SalesOrderHeader sh on cus.CustomerID = sh.CustomerID
group by cus.CustomerID, FirstName, LastName
having count(*) >=all	(select count(*)
						from Sales.Customer cus
						join Person.Person per on cus.CustomerID = per.BusinessEntityID
						join Sales.SalesOrderHeader sh on cus.CustomerID = sh.CustomerID
						group by cus.CustomerID)


--4) Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với
--tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng
--bảng Production.Product và Production.ProductModel)
select ProductID, p.Name
from Production.Product p
join Production.ProductModel pm on p.ProductModelID = pm.ProductModelID
where p.ProductID in	(select ProductID
						from Production.Product p
						join Production.ProductModel pm on p.ProductModelID = pm.ProductModelID
						where pm.Name like 'Long-Sleeve Logo Jersey%'
						group by ProductID)
group by ProductID, p.Name
 
select ProductID, p.Name
from Production.Product p
join Production.ProductModel pm on p.ProductModelID = pm.ProductModelID
where exists	(select p.Name
							from Production.ProductModel pm 
							where pm.Name like 'Long-Sleeve Logo Jersey%' and pm.ProductModelID = p.ProductModelID)
group by ProductID, p.Name
						
--5) Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
--đa cao hơn giá trung bình của tất cả các mô hình.
select pm.Name, ListPrice
from Production.ProductModel pm 
join Production.Product p on pm.ProductModelID = p.ProductModelID
group by pm.Name, ListPrice
having ListPrice >= all	(select AVG(ListPrice)
						from Production.Product)

--6) Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng
--đặt hàng > 5000 (dùng IN, EXISTS)
--7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao
--nhất trong bảng Sales.SalesOrderDetail
--8) Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID,
--Nam; dùng 3 cách Not in, Not exists và Left join.
--9) Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm
--EmployeeID, FirstName, LastName (dữ liệu từ 2 bảng
--HumanResources.Employees và Sales.SalesOrdersHeader)
--10)Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng
--trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008.