--1) Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID có trên
--100 đơn đặt hàng trong tháng 7 năm 2008
select Name, ProductID
from Production.Product p
where exists (select ProductID, year(OrderDate), count(sd.SalesOrderID) as SL
					  from Sales.SalesOrderDetail sd join Sales.SalesOrderHeader sh 
					  on sd.SalesOrderID = sh.SalesOrderID
					  where MONTH(OrderDate) = 7 and year(OrderDate) = 2013 and sd.ProductID = p.ProductID
					  group by ProductID, year(OrderDate)
					  having COUNT(*)>100
					  )

--2) Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất trong
--tháng 7/2008
select ProductID, Name
from Production.Product p
where exists (select ProductID
				from Sales.SalesOrderDetail sd join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
				where MONTH(OrderDate) = 7 and YEAR(OrderDate) = 2013 and p.ProductID = sd.ProductID
				group by ProductID
				having count(sd.SalesOrderID) >= all(select count (sod.SalesOrderID)
													from Sales.SalesOrderDetail sod join Sales.SalesOrderHeader shd on sod.SalesOrderID = shd.SalesOrderID
													where MONTH(OrderDate) = 7 and YEAR(OrderDate) = 2013
													group by sod.SalesOrderID
													)
			)

--3) Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm:
--CustomerID, Name, CountOfOrder
select cus.CustomerID, count(sd.SalesOrderID) as CountOfOrder
from Sales.SalesOrderDetail sd
join Sales.SalesOrderHeader h on h.SalesOrderID = sd.SalesOrderID
join Sales.Customer cus on h.CustomerID = cus.CustomerID
group by cus.CustomerID
having count(sd.SalesOrderID)>= all(select count(sd.SalesOrderID)
									from Sales.SalesOrderDetail sd
									join Sales.SalesOrderHeader h on h.SalesOrderID = sd.SalesOrderID
									join Sales.Customer cus on h.CustomerID = cus.CustomerID
									group by cus.CustomerID)

--4) Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với
--tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng
--bảng Production.Product và Production.ProductModel)
select ProductID, p.Name
from Production.Product p
where Name in (select p.Name
				from Production.Product p
				join Production.ProductModel pm on p.ProductModelID = pm.ProductModelID
				where pm.name like 'Long-Sleeve Logo Jersey'
				group by p.name
				)

select ProductID, p.Name
from Production.Product p
where exists (select Name
				from Production.ProductModel pm
				where pm.name like 'Long-Sleeve Logo Jersey' and pm.ProductModelID = p.ProductModelID
				)
--Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
--đa cao hơn giá trung bình của tất cả các mô hình.
select p.ProductModelID, ListPrice
from Production.Product p
join Production.ProductModel pm on p.ProductModelID = pm.ProductModelID
group by p.ProductModelID, ListPrice
having ListPrice >(select avg(ListPrice)
					from Production.Product)

--Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng
--đặt hàng > 5000 (dùng IN, EXISTS)
select p.ProductID, Name
from Production.Product p
join Sales.SalesOrderDetail sd on p.ProductID = sd.ProductID
group by p.ProductID, Name
having p.ProductID in (select p.ProductID
						from Production.Product p
						join Sales.SalesOrderDetail sd on p.ProductID = sd.ProductID 
						group by p.ProductID
						having count(sd.SalesOrderID) >=4000
						)

select p.ProductID, Name
from Production.Product p
where exists (select ProductID
				from Sales.SalesOrderDetail sd
				where p.ProductID = sd.ProductID
				group by ProductID
				having count(sd.SalesOrderID) >=4000)

--7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao
--nhất trong bảng Sales.SalesOrderDetail
select p.ProductID, UnitPrice
from Production.Product p
join Sales.SalesOrderDetail sd on sd.ProductID = p.ProductID
group by p.ProductID, UnitPrice
having UnitPrice >=all(select UnitPrice
						from Sales.SalesOrderDetail sd
						join Production.Product p on sd.ProductID = p.ProductID
						)

--8) Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID,
--Nam; dùng 3 cách Not in, Not exists và Left join.
--Not in
select ProductID, Name
from Production.Product where ProductID not in (select ProductID from Sales.SalesOrderDetail)

--Not exists
select ProductID, Name
from Production.Product p where not exists(select ProductID from Sales.SalesOrderDetail s where s.ProductID = p.ProductID)

--Left join
select p.ProductID, Name, SalesOrderID 
from Production.Product p 
left join Sales.SalesOrderDetail s on p.ProductID = s.ProductID
where s.SalesOrderID is null



--9) Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/4/2014, thông tin gồm
--EmployeeID, FirstName, LastName (dữ liệu từ 2 bảng
--HumanResources.Employees và Sales.SalesOrdersHeader)
select ve.BusinessEntityID, ve.FirstName, ve.LastName
from HumanResources.Employee e
join Sales.SalesPerson sp on sp.BusinessEntityID = e.BusinessEntityID
join Sales.SalesOrderHeader sh on sh.SalesPersonID = sp.BusinessEntityID
join HumanResources.vEmployee ve on e.BusinessEntityID = ve.BusinessEntityID
where ve.BusinessEntityID not in(select ve.BusinessEntityID
								from HumanResources.Employee e
								join Sales.SalesPerson sp on sp.BusinessEntityID = e.BusinessEntityID
								join Sales.SalesOrderHeader sh on sh.SalesPersonID = sp.BusinessEntityID
								join HumanResources.vEmployee ve on e.BusinessEntityID = ve.BusinessEntityID
								where ve.BusinessEntityID = sh.SalesPersonID and OrderDate >'2014-04-01'
								group by ve.BusinessEntityID
								)
group by ve.BusinessEntityID, ve.FirstName, ve.LastName
 
-- 10)Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặ
--trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008.
select CustomerID, 
from Sales.Customer cus
join Sales.SalesOrderHeader sh on sh.CustomerID = cus.CustomerID
join Sales.vIndividualCustomer vic on vic.BusinessEntityID = cus.CustomerID
