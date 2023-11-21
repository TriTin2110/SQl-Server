--1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng
--Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
create view dbo.vw_Products (ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate)
as
select p.ProductID, Name, Color, Size, Style, pch.StandardCost, EndDate, StartDate
from Production.Product p join Production.ProductCostHistory pch
on p.ProductID = pch.ProductID
group by p.ProductID, Name, Color, Size, Style, pch.StandardCost, EndDate, StartDate
--2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt
--hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID,
--Product_Name, CountOfOrderID và SubTotal.
create view List_Product_View(ProductID, Product_Name, CountOfOrderID, SubTotal)
as
select p.ProductID, name, count(*) as CountOfOrderID, sum(unitprice * OrderQty) as SubTotal
from Production.Product p
join Sales.SalesOrderDetail sd on p.ProductID = sd.ProductID
join Sales.SalesOrderHeader h on sd.SalesOrderID = h.SalesOrderID
where p.ProductID = sd.ProductID and DATEPART(quarter, OrderDate) = 1 and YEAR(OrderDate) = 2012
group by p.ProductID, name
having sum(unitprice * OrderQty) >10000

--3) Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm
--CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS
--OrderMonth, SUM(TotalDue).
create view dbo.vw_CustomerTotals (CustomerID, OrderYear, OrderMonth,TotalDue)
as
select CustomerID, YEAR(OrderDate), MONTH(OrderDate), SUM(TotalDue) 
from Sales.SalesOrderHeader 
group by CustomerID, OrderDate

--4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân
--viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty
go
create view dbo.vv_ToTalQuantity (SalesPersonID, OrderYear, sumOfOrderQty)
as
select SalesPersonID, YEAR(OrderDate),sum(OrderQty)
from Sales.SalesOrderHeader h join
Sales.SalesPerson sp on sp.BusinessEntityID = h.SalesPersonID
join Sales.SalesOrderDetail sd on sd.SalesOrderID = h.SalesOrderID
group by SalesPersonID, year(OrderDate)
go

select * from Sales.Customer
select * from Sales.vIndividualCustomer
--5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn
--đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên
--(FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).
go
create view ListCustomer_view(PersonID, FullName, CountOfOrders)
as
select PersonID, FirstName+' '+LastName, count(*)
from Sales.Customer cus
join Sales.SalesOrderHeader he on he.CustomerID = cus.CustomerID
join Sales.vIndividualCustomer ic on cus.CustomerID = ic.BusinessEntityID
join Sales.SalesOrderDetail sd on sd.SalesOrderID = he.SalesOrderID
where sd.SalesOrderID = he.SalesOrderID and year(OrderDate) between 2012 and 2013
group by PersonID,FirstName,LastName, year(OrderDate)
having count(*)>25
go
select * from ListCustomer_view

--6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông tin
--gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng
--Sales.SalesOrderHeader, Sales.SalesOrderDetail, và
--Production.Product)
create view ListProduct_view (ProductID, Name, SumOfOrderQty, Year)
as
select p.ProductID, name, sum(OrderQty), year(OrderDate)
from Production.Product p 
join sales.SalesOrderDetail sd on sd.ProductID = p.ProductID
join Sales.SalesOrderHeader h on h.SalesOrderID = sd.SalesOrderID
where Name like'Bike%' or Name like 'Sport%'
group by p.ProductID, Name, year(OrderDate)
having sum(OrderQty)>50

--7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate:
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID),
--tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng
--[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory].
go
create view List_department_View(DepartmentID, Name, AvgOfRate)
as
select edh.DepartmentID, Name, AVG(rate)
from HumanResources.EmployeeDepartmentHistory edh
join HumanResources.Employee e on e.BusinessEntityID = edh.BusinessEntityID
join HumanResources.EmployeePayHistory eph on e.BusinessEntityID = eph.BusinessEntityID
join HumanResources.Department d on edh.DepartmentID = d.DepartmentID
group by edh.DepartmentID, Name
having avg(rate)>30
go

--8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm
--OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
create view Sales.vw_OrderSummary ( OrderYear, OrderMonth, OrderTotal) with encryption
as
select year(OrderDate), month(OrderDate), sum(unitprice) as OrderTotal
from Sales.SalesOrderHeader h 
join Sales.SalesOrderDetail sd on sd.SalesOrderID = h.SalesOrderID
group by year(OrderDate), month(OrderDate)

--9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING
--gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng
--ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng
--Product. Có xóa được không? Vì sao?
go
create view Production.vwProducts (ProductID, Name, StartDate,EndDate,ListPrice) with schemabinding
as
select p.ProductID, Name, StartDate, EndDate, ListPrice
from Production.Product p 
join Production.ProductCostHistory pch on p.ProductID = pch.ProductID
group by p.ProductID, Name, StartDate, EndDate, ListPrice
go
--khong the xoa duoc vi cau lenh schemabinding khong duoc hieu chinh cac bang

--10)Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các
--phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality
--Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
--a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
--chèn được không? Giải thích.
--b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một
--phòng thuộc nhóm “Quality Assurance”.
--c. Dùng câu lệnh Select xem kết quả trong bảng Department.

create view view_Department
as
select DepartmentID, Name, GroupName
from HumanResources.Department
where GroupName like 'Manufacturing' or GroupName like 'Quality Assurance'
with check option;
go
--a)
insert into view_Department values ('Compuer', 'Technology')
--Không thể chèn thêm một phòng ban mới khi GroupName = 'Technology'. Vì GroupName = 'Technology' không thỏa mãn điều kiện 
--b)
insert into view_Department values('Computer', 'Manufacturing')
insert into view_Department values('Administrators', 'Quality Assurance')
--Có thể chèn 2 phòng ban Computer và Administrators vì chúng thỏa mãn điều kiện rằng GroupName = 'Manufacturing' hoặc 'Quality Assurance'
--c)
select * from view_Department
