--1) Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có
--tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó
--SubTotal =SUM(OrderQty*UnitPrice).

select sd.SalesOrderID, OrderDate, sum(OrderQty*UnitPrice) as Subtotal
from Sales.SalesOrderDetail sd
join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
where month(OrderDate) = 6 and YEAR(OrderDate) = 2012 
group by sd.SalesOrderID, OrderDate
having sum(OrderQty*UnitPrice)>70000

--2) Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia
--có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory,
--Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin
--bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền (SubTotal)
--với SubTotal = SUM(OrderQty*UnitPrice)
select st.TerritoryID, count(*) as CountOfCust, sum(OrderQty*UnitPrice) as SubToTal, st.CountryRegionCode
from Sales.SalesOrderHeader sh
join Sales.SalesOrderDetail sd on sd.SalesOrderID = sh.SalesOrderID
join Sales.SalesTerritory st on st.TerritoryID = sh.TerritoryID
where st.CountryRegionCode = 'US'
group by st.TerritoryID

--3) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
--(CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm
--SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
select SalesOrderID, CarrierTrackingNumber, sum(OrderQty*Unitprice) as SubTotal
from Sales.SalesOrderDetail
where CarrierTrackingNumber like '4BD%'
group by SalesOrderID, CarrierTrackingNumber

--4) Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán trung
--bình >5, thông tin gồm ProductID, Name, AverageOfQty.
select p.ProductID, Name, count(*)
from Production.Product p
join Sales.SalesOrderDetail sd on p.ProductID = sd.ProductID
where p.ProductID = sd.ProductID
group by p.ProductID, Name, UnitPrice
having count(*)>5 and UnitPrice<25
--5) Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm
--JobTitle,CountOfPerson=Count(*)
select JobTitle, count(*) as CountOfPerson
from HumanResources.Employee
group by JobTitle
having count(*) >20
--6) Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên
--kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm
--BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal
--(sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và
--[Purchasing].[PurchaseOrderDetail])
select pv.BusinessEntityID, Name, ProductID, sum(OrderQty), sum(OrderQty*unitprice) as Subtotal
from Purchasing.Vendor pv
join Purchasing.PurchaseOrderHeader poh on poh.VendorID = pv.BusinessEntityID
join Purchasing.PurchaseOrderDetail pod on pod.PurchaseOrderID = poh.PurchaseOrderID
where Name like '%Bicycles'
group by pv.BusinessEntityID, Name, ProductID
having sum(OrderQty*UnitPrice) > 800000
--7) Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng
--trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và
--SubTotal
select p.ProductID, Name, count(*)
from Production.Product p
join Sales.SalesOrderDetail sd on p.ProductID = sd.ProductID
join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
where YEAR(OrderDate) = 2013 and DATEPART(quarter, OrderDate) = 2
group by p.ProductID, Name, UnitPrice
having sum(unitprice) > 10000 and count(*) > 500

--8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
--as FullName), Số hóa đơn (CountOfOrders).
select cus.CustomerID
from Sales.Customer cus
join Sales.SalesOrderHeader sh on sh.CustomerID = cus.CustomerID

--9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
--bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
--CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader,
--Sales.SalesOrderDetail và Production.Product)
select p.ProductID, Name, count(*) as CountOfOrderQty, year(orderdate)
from Sales.SalesOrderHeader sh
join Sales.SalesOrderDetail sd on sh.SalesOrderID = sd.SalesOrderID
join Production.Product p on p.ProductID = sd.ProductID
where name like 'Bike%' or name like 'Sport%'
group by p.ProductID, Name, year(OrderDate)
having count(*) > 500
--10)Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
--tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
--bình (AvgofRate). Dữ liệu từ các bảng
--[HumanResources].[Department],
--[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory]
select d.DepartmentID, Name, AVG(Rate) as AvgofRate
from HumanResources.Department d
join HumanResources.EmployeeDepartmentHistory edh on d.DepartmentID = edh.DepartmentID
join HumanResources.Employee e on e.BusinessEntityID = edh.BusinessEntityID
join HumanResources.EmployeePayHistory eph on e.BusinessEntityID = eph.BusinessEntityID
group by d.DepartmentID, Name, Rate
having AVG(Rate)>30