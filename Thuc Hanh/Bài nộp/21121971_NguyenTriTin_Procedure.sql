--1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một tháng
--bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím, thông
--tin gồm: CustomerID, SumOfTotalDue =Sum(TotalDue)
alter procedure TotalDue @thang int, @nam int
as
	select cus.CustomerID, Sum(TotalDue) as SumOfTotalDue, month(orderdate) as Thang, year(orderdate) as Nam
	from Sales.Customer cus 
	join Sales.SalesOrderHeader sh on cus.CustomerID = sh.CustomerID
	where cus.CustomerID = sh.CustomerID and year(OrderDate) = @nam and month(OrderDate) = @thang
	group by cus.CustomerID, month(orderdate), year(orderdate)

exec TotalDue '7', '2012'
--2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của một
--nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số
-- @SalesYTD được sử dụng để chứa giá trị trả về của thủ tục.

go
alter proc DoanhThu @salesperson int
as
	select sp.BusinessEntityID, sum(UnitPrice)
	from Sales.SalesPerson sp 
	join Sales.SalesOrderHeader sh on sh.SalesPersonID = sp.BusinessEntityID
	join Sales.SalesOrderDetail sd on sd.SalesOrderID = sh.SalesOrderID
	where @salesperson = sp.BusinessEntityID
	group by sp.BusinessEntityID
go
exec DoanhThu 284
--3) Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có
--giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice).
go
create proc TraVeGiaBan @maxprice money
as
	select ProductID, ListPrice from Production.Product
	group by ProductID, ListPrice
	having ListPrice<@maxprice
go
exec TraVeGiaBan 120
--4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán
--hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên đó. Mức thưởng mới
--bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--SumOfSubTotal =sum(SubTotal)
--NewBonus = Bonus+ sum(SubTotal)*0.01

go
alter proc NewBonus @manv char(10)
as
	update Sales.SalesPerson
	set Bonus = Bonus + (select sum(SubTotal) from Sales.SalesOrderHeader where sp.BusinessEntityID = SalesPersonID)*0.01
	from Sales.SalesPerson sp
	where @manv = BusinessEntityID
go
exec NewBonus '274'
--5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) có
--tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số input),
--thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
--(Lưu ý: dùng Sub Query)
go
create proc ProductCategory @nam int
as
	select pc.ProductCategoryID, p.Name, sum(OrderQty) from Production.Product p
	join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
	join Production.ProductCategory pc on psc.ProductCategoryID = pc.ProductCategoryID
	join Sales.SalesOrderDetail sd on p.ProductID = sd.ProductID
	join Sales.SalesOrderHeader sh on sh.SalesOrderID = sd.SalesOrderID
	where year(OrderDate) = @nam
	group by pc.ProductCategoryID, p.Name
	having sum(OrderQty) >= all (	select sum(OrderQty) from Production.Product p
									join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
									join Production.ProductCategory pc on psc.ProductCategoryID = pc.ProductCategoryID
									join Sales.SalesOrderDetail sd on p.ProductID = sd.ProductID
									join Sales.SalesOrderHeader sh on sh.SalesOrderID = sd.SalesOrderID
									where year(OrderDate) = @nam
									group by pc.ProductCategoryID, p.Name)
go
exec ProductCategory '2014'
--6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả
--về trạng thái thành công hay thất bại của thủ tục.
go
alter proc TongThu @manv char(10)
as
	if @manv not in (select BusinessEntityID from Sales.SalesPerson)
		begin
			print (N'Nhân viên không tồn tại')
			return 0
		end
	else
		begin
			select	sp.BusinessEntityID	,sum(SalesOrderID) as TongThu from Sales.SalesOrderHeader sh
			join Sales.SalesPerson sp on sh.SalesPersonID = sp.BusinessEntityID
			where sh.SalesPersonID = sp.BusinessEntityID and sp.BusinessEntityID = @manv
			group by sp.BusinessEntityID
		end
go
exec TongThu '1'
--7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo
--năm đã cho.
go
alter proc CuaHangMuaNhieuHangNhat @nam int
as
	select Name, sum(UnitPrice) as TongTienMuaNhieuNhat from Sales.Store sto
	join Sales.Customer cus on sto.BusinessEntityID = cus.StoreID
	join Sales.SalesOrderHeader sh on sh.CustomerID = cus.CustomerID
	join Sales.SalesOrderDetail sd on sd.SalesOrderID = sh.SalesOrderID
	where year(OrderDate) = @nam
	group by Name
	having sum(unitprice) >= all	(select sum(UnitPrice) from Sales.Store sto
									join Sales.Customer cus on sto.BusinessEntityID = cus.StoreID
									join Sales.SalesOrderHeader sh on sh.CustomerID = cus.CustomerID
									join Sales.SalesOrderDetail sd on sd.SalesOrderID = sh.SalesOrderID
									where year(OrderDate) = @nam
									group by Name)

go
exec CuaHangMuaNhieuHangNhat '2013'
--8) Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin
--vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not null
--và các field là khóa ngoại.
go--
create proc sp_insertproduct @masp int, @name nvarchar(50), @number nvarchar(25), @safetystocklevel smallint, @reorderpoint smallint, @standardcost money, @listprice money, @sizeunitmeasurecode nchar(3), @weightunitmeasurecode nchar(3), @daystomanufacture int, @productsubcateforyid int, @productmodeiid int, @sellstartdate datetime, @rowguid uniqueidentifier, @modifieddate datetime
as
	insert into Production.Product(ProductID,Name, ProductNumber, SafetyStockLevel, 
									ReorderPoint, StandardCost, ListPrice, SizeUnitMeasureCode, WeightUnitMeasureCode,
									DaysToManufacture, ProductSubcategoryID, ProductModelID, SellStartDate, rowguid, 
									ModifiedDate)
	values (@masp, @name, @number, @safetystocklevel, @reorderpoint, @standardcost, @listprice, @sizeunitmeasurecode, @weightunitmeasurecode, @daystomanufacture, @productsubcateforyid, @productmodeiid, @sellstartdate, @rowguid, @modifieddate)
go
--9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader
--khi biết SalesOrderID. Lưu ý : trước khi xóa mẫu tin trong
--Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong
--Sales.SalesOrderDetail.

Create proc XoaHD @salesorderID int
as
	delete from Sales.SalesOrderHeader
	where @salesorderID = SalesOrderID
exec XoaHD 43859
--10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice lên
--10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm này.
create proc Sp_Update_Product @productid int
as
	if @productid not in (select ProductID from Production.Product)
		begin
			print(N'Mặt hàng này không tồn tại')
			return 0
		end
	else
		begin
			select ProductID, ListPrice*0.1 as ListPrice
			from Production.Product
			where @productid = ProductID
		end
exec Sp_Update_Product 5