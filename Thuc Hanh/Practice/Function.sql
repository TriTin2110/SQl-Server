--1) Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb, giá
--trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong phòng
--ban tương ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các phòng
--ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID], Name,
--countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
alter function CountOfEmployees(@mapb int)
returns int
as
begin
return(
	select sum(edh.BusinessEntityID)
	from HumanResources.Department d
	join HumanResources.EmployeeDepartmentHistory edh on d.DepartmentID = edh.DepartmentID
	where @mapb = d.DepartmentID
	)
end
select DepartmentID, Name,countOfEmp = dbo.CountOfEmployees(DepartmentID)
from HumanResources.Department 
order by DepartmentID

--2) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
--@ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu
--vực tương ứng với giá trị của tham số
--(Dữ liệu lấy từ bảng[Production].[ProductInventory])

create function InventoryProd (@ProductID int, @LocationID int)
returns int
as
begin 
return(
	select Quantity
	from Production.ProductInventory
	where @ProductID = ProductID and @LocationID = LocationID
)
end
select [dbo].[InventoryProd] (1, 1)

--3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của
--một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào
--@EmplID, @MonthOrder, @YearOrder
--(Thông tin lấy từ bảng [Sales].[SalesOrderHeader])

create function SubTotalOfEmp (@EmplID int, @MonthOrder int, @YearOrder int)
returns int
as
begin
return(
	select sum(SubTotal)
	from Sales.SalesOrderHeader
	where @EmplID = SalesPersonID and @MonthOrder = month(OrderDate) and @YearOrder = year(OrderDate)
)
end

select [dbo].[SubTotalOfEmp] (279, 1, 2014)

--4) Viết hàm SumOfOrder với hai tham số @thang và @nam trả về danh sách các
--hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ 2 tham số
--@thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate,
--SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).
create function SumOfOrder (@thang int, @nam int)
returns @SumOfOrder table(SalesOrderID int, OrderDate date, SubTotal int)
as
begin
	insert into @SumOfOrder
	select sd.SalesOrderID, OrderDate, SubTotal =sum(OrderQty*UnitPrice)
	from Sales.SalesOrderDetail sd 
	join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
	where Month(OrderDate) = @thang and Year(OrderDate) = @nam
	group by sd.SalesOrderID, OrderDate
	having sum(OrderQty*UnitPrice) > 70000
	return
end

select * from [dbo].[SumOfOrder] (3, 2014)
--5) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng
--mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--- SumOfSubTotal =sum(SubTotal),
--- NewBonus = Bonus+ sum(SubTotal)*0.01
create function NewBonus_1 (@salesPersonID int)
returns @NewBonus table(SalesPersonID int, NewBonus int, SumOfSubTotal int)
as
begin 
	insert into @NewBonus
	select sh.SalesPersonID, NewBonus = Bonus+ sum(SubTotal)*0.01, SumOfSubTotal =sum(SubTotal)
	from Sales.SalesOrderHeader sh
	join Sales.SalesPerson sp on sh.SalesPersonID = sp.BusinessEntityID
	where @salesPersonID = sh.SalesPersonID
	group by sh.SalesPersonID, Bonus
	return
end

select * from [dbo].[NewBonus_1] (274)
--6) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID), hàm
--dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal) của các
--sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm ProductID,
--SumOfProduct, SumOfSubTotal
alter function SumOfProduct(@MaNCC int)
returns table
as
return(
	select pod.ProductID, sum(pod.ProductID) as SumOfProduct, sum(SubTotal) as SumOfSubTotal
	from Purchasing.PurchaseOrderDetail pod 
	join Purchasing.PurchaseOrderHeader poh on pod.PurchaseOrderID = poh.PurchaseOrderID
	join Purchasing.Vendor v on poh.VendorID = v.BusinessEntityID
	where @MaNCC = VendorID
	group by pod.ProductID
)
select * from [dbo].[SumOfProduct](1496)
--7) Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn(SalesOrderID),
--thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính
--như sau:
--Nếu [SubTotal]<1000 thì Discount=0
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal]
--Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
--Gợi ý: Sử dụng Case.. When … Then …
--(Sử dụng dữ liệu từ bảng [Sales].[SalesOrderHeader])
create function Discount_Func()
returns @Discount_Func table(SalesOrderID int, SubTotal money, Discount money)
as
begin
	insert into @Discount_Func
	select SalesOrderID, SubTotal, Discount=
	case 
	when SubTotal<1000 then 0
	when SubTotal between 1000 and 5000 then SubTotal * 0.05
	when SubTotal between 5000 and 10000 then SubTotal * 0.1
	else SubTotal * 0.15
	end
	from Sales.SalesOrderHeader
	return
end
select * from [dbo].[Discount_Func]()
--8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng
--doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được
--truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với
--Total=Sum([SubTotal])
--- Multi-statement Table Valued Functions:
--9) Viết lại các câu 5,6,7,8 bằng Multi-statement table valued function
--10)Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên, với tham
--số vào là @MaNV (giá trị của [BusinessEntityID]), thông tin gồm
--BusinessEntityID, FName, LName, Salary (giá trị của cột Rate).