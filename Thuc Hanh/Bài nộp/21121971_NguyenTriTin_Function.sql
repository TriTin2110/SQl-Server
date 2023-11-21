--1) Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb, giá
--trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong phòng
--ban tương ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các phòng
--ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID], Name,
--countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
--(Dữ liệu lấy từ bảng
--[HumanResources].[EmployeeDepartmentHistory] và
--[HumanResources].[Department])
go
create function CountOfEmployees (@mapb char(10))
returns int 
as
begin
return(
	select count(deh.BusinessEntityID) as CountOfEmployees
	from HumanResources.Department de 
	join HumanResources.EmployeeDepartmentHistory deh on deh.DepartmentID = de.DepartmentID
	where @mapb = de.DepartmentID
	)
end
go
select de.DepartmentID, Name,countOfEmp = dbo.CountOfEmployees(de.DepartmentID)
from HumanResources.EmployeeDepartmentHistory deh
join HumanResources.Department de on de.DepartmentID = deh.DepartmentID
group by de.DepartmentID, name
--2) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
--@ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu
--vực tương ứng với giá trị của tham số
--(Dữ liệu lấy từ bảng[Production].[ProductInventory])
go
Create function InventoryProd (@ProductID int, @LocationID smallint)
returns int 
as
begin
return(
	select Quantity 
	from Production.ProductInventory
	where @ProductID = ProductID and @LocationID = LocationID
	)
end
go
select [dbo].[InventoryProd] (3, 6) as Quantity
--3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của
--một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào
--@EmplID, @MonthOrder, @YearOrder
--(Thông tin lấy từ bảng [Sales].[SalesOrderHeader])
go
alter function SubTotalOfEmp (@EmplID int , @month int, @year int)
returns money
as
begin
return(
	select sum(SubTotal)
	from Sales.SalesOrderHeader
	where @EmplID = SalesPersonID and @month = month(OrderDate) and @year = year(OrderDate)
)
end
go
select [dbo].[SubTotalOfEmp] (279, 6, 2012) as SubTotalOfEmp

--4) Viết hàm SumOfOrder với hai tham số @thang và @nam trả về danh sách các
--hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ 2 tham số
--@thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate,
--SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).
go
create function SumOfOrder(@thang int, @nam int)
returns table
as
return(
	select sh.SalesOrderID, OrderDate, sum(OrderQty*UnitPrice) as SubTotal
	from Sales.SalesOrderHeader sh
	join Sales.SalesOrderDetail sd on sh.SalesOrderID = sd.SalesOrderID
	where MONTH(OrderDate) = @thang and YEAR(OrderDate) = @nam
	group by sh.SalesOrderID, OrderDate
	having sum(OrderQty*UnitPrice) > 70000
	)
go
select * from SumOfOrder(12, 2012)

--5) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng
--mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--- SumOfSubTotal =sum(SubTotal),
--- NewBonus = Bonus+ sum(SubTotal)*0.01
go
create function NewBonus()
returns table
as
return(
		select sh.SalesPersonID, Bonus + sum(Subtotal)*0.01 as NewBonus, sum(SubTotal) as SumOfSubTotal
		from Sales.SalesOrderHeader sh
		join Sales.SalesPerson sp on sh.SalesPersonID = sp.BusinessEntityID
		group by sh.SalesPersonID, Bonus
		)
go
select * from dbo.NewBonus()
--6) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID), hàm
--dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal) của các
--sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm ProductID,
--SumOfProduct, SumOfSubTotal
go
Create function SumOfProduct (@MaNCC int)
returns table
as
return(
	select pod.ProductID, sum(pod.ProductID) as SumOfProduct, sum(Subtotal) as SumOfSubTotal
	from Purchasing.PurchaseOrderHeader poh
	join Purchasing.PurchaseOrderDetail pod on poh.PurchaseOrderID = pod.PurchaseOrderID
	join Purchasing.Vendor pv on pv.BusinessEntityID = poh.VendorID
	where poh.VendorID = 1496
	group by pod.ProductID
	)
go
select * from SumOfProduct(1496)
--7) Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn(SalesOrderID),
--thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính
--như sau:
--Nếu [SubTotal]<1000 thì Discount=0
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal]
--Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
go
Create function Discount_Func()
returns table
as
return(
select SalesOrderID, SubTotal, Discount=
	Case
	When SubTotal < 1000 then 0
	When SubTotal between 1000 and 5000 then SubTotal * 0.05
	When SubTotal between 5000 and 10000 then SubTotal * 0.1
	else
		Subtotal * 0.15
	end
from Sales.SalesOrderHeader
group by SalesOrderID, SubTotal
)
go
select * from Discount_Func()

--8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng
--doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được
--truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với
--Total=Sum([SubTotal])
go
create function TotalOfEmp (@MonthOrder int, @YearOrder int)
returns table
as
return(
	select SalesPersonID, Total = sum(SubTotal)
	from Sales.SalesOrderHeader
	where year(OrderDate) = @YearOrder and month(OrderDate) = @MonthOrder
	group by SalesPersonID
)
go
select * from TotalOfEmp(7, 2012)

--9) Viết lại các câu 5,6,7,8 bằng Multi-statement table valued function

--5.2) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng
--mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--- SumOfSubTotal =sum(SubTotal),
--- NewBonus = Bonus+ sum(SubTotal)*0.01
go
Alter function NewBonus_Multi()
returns @multi table (MaNV int, NewBonus money, SumOfSubTotal money)
as
begin
	insert into @multi
	select sh.SalesPersonID, Bonus + sum(Subtotal)*0.01 as NewBonus, sum(SubTotal) as SumOfSubTotal
	from Sales.SalesOrderHeader sh
	join Sales.SalesPerson sp on sh.SalesPersonID = sp.BusinessEntityID
	group by sh.SalesPersonID, Bonus
	return 
end
go
select * from NewBonus_Multi()

--6.2) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID), hàm
--dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal) của các
--sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm ProductID,
--SumOfProduct, SumOfSubTotal
go
create function SumOfProduct_Multi(@MaNCC int)
returns @SumOfProduct_Multi table(ProductID smallint, SumOfProduct int, SumOfSubTotal int)
as
begin
	insert into @SumOfProduct_Multi
	select ProductID, sum(ProductID), sum(SubTotal)
	from Purchasing.PurchaseOrderHeader poh
	join Purchasing.PurchaseOrderDetail pod on poh.PurchaseOrderID = pod.PurchaseOrderID
	where @MaNCC = VendorID
	group by ProductID
	return
end
go
select * from SumOfProduct_Multi(1496)

--7.2) Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn(SalesOrderID),
--thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính
--như sau:
--Nếu [SubTotal]<1000 thì Discount=0
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal]
--Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
go
alter function Discount_Func_Multi()
returns @Discount_Func_Multi table(SalesOrderID int, SubTotal money, Discount money)
as
begin
	insert into @Discount_Func_Multi
	select SalesOrderID, SubTotal, Discount = 
	Case
		When SubTotal<1000 then 0
		When SubTotal between 1000 and 5000 then SubTotal * 0.05
		When SubTotal between 5000 and 10000 then SubTotal * 0.1
	else
		SubTotal*0.15	
	end
	from Sales.SalesOrderHeader
	group by SalesOrderID, SubTotal
	return
end
go
select * from Discount_Func_Multi()

--8.2) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng
--doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được
--truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với
--Total=Sum([SubTotal])
go
create function TotalOfEmp_Multi (@MonthOrder int, @YearOrder int)
returns @TotalOfEmp_Multi table(SalesPersonID int, Total money)
as
begin
	insert into @TotalOfEmp_Multi
	select SalesPersonID, sum(Subtotal)
	from Sales.SalesOrderHeader
	where @MonthOrder = MONTH(OrderDate) and @YearOrder = YEAR(OrderDate)
	group by SalesPersonID
	return
end
go
select * from TotalOfEmp_Multi(7, 2012)

--10)Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên, với tham
--số vào là @MaNV (giá trị của [BusinessEntityID]), thông tin gồm
--BusinessEntityID, FName, LName, Salary (giá trị của cột Rate).
go
alter function SalaryOfEmp(@MaNV int)
returns @SalaryOfEmp table(BusinessEntityID int, FName nvarchar(30), LName nvarchar(30), Salary money)
as
begin
	if(@MaNV is null)
		begin
		insert into @SalaryOfEmp
				select p.BusinessEntityID, FirstName, LastName, Rate
				from Person.Person p
				join HumanResources.EmployeePayHistory eph on p.BusinessEntityID = eph.BusinessEntityID
				group by p.BusinessEntityID, FirstName, LastName, Rate 
		end
	else
		insert into @SalaryOfEmp
		select p.BusinessEntityID, FirstName, LastName, Rate
		from Person.Person p
		join HumanResources.EmployeePayHistory eph on p.BusinessEntityID = eph.BusinessEntityID
		where @MaNV = p.BusinessEntityID
		group by p.BusinessEntityID, FirstName, LastName, Rate
		return
end
go
select * from SalaryOfEmp (null)