--1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một tháng
--bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím, thông
--tin gồm: CustomerID, SumOfTotalDue =Sum(TotalDue)

go
alter procedure sp_TotalDue @thang int, @nam int
as
	select cus.CustomerID, sum(totalDue) as SumOfTotalDue
	from Sales.Customer cus
	join Sales.SalesOrderHeader sh on cus.CustomerID = sh.CustomerID
	where month(OrderDate) = @thang and year(OrderDate) = @nam
	group by cus.CustomerID
 exec sp_TotalDue '7', '2012'
go

--2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của một
--nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số
-- @SalesYTD được sử dụng để chứa giá trị trả về của thủ tục.

alter procedure sp_doanhThu @salePerson int
as
	select SalesYTD
	from Sales.SalesOrderHeader sh
	join Sales.SalesPerson sp on sh.SalesPersonID = sp.BusinessEntityID
	where sh.SalesPersonID = @salePerson
	group by SalesYTD

exec sp_doanhThu 290

--3) Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có
--giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice).

go
create procedure sp_limitPrice @MaxPrice money
as
	select p.ProductID, ListPrice
	from Production.Product p
	join Sales.SalesOrderDetail sd on p.ProductID = sd.ProductID
	group by p.ProductID, ListPrice
	having ListPrice < @MaxPrice
go

exec sp_limitPrice 30

--4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán
--hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên đó. Mức thưởng mới
--bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--SumOfSubTotal =sum(SubTotal)
--NewBonus = Bonus+ sum(SubTotal)*0.01

go
alter procedure NewBonus @SalesPerson int
as
	select sh.SalesPersonID, NewBonus = Bonus+ sum(SubTotal)*0.01, SumOfSubTotal =sum(SubTotal)
	from Sales.SalesOrderHeader sh join
	Sales.SalesPerson sp on sh.SalesPersonID = sp.BusinessEntityID	
	where sh.SalesPersonID = @SalesPerson
	group by sh.SalesPersonID, Bonus

exec NewBonus 274

go
Create procedure sp_NewBonus @SalesPerson int
as
	update Sales.SalesPerson 
	set Bonus =  Bonus+ (select sum(Subtotal) from Sales.SalesOrderHeader where Sales.SalesOrderHeader.SalesPersonID = @SalesPerson  )*0.01
	where Sales.SalesPerson.BusinessEntityID = @SalesPerson

exec sp_NewBonus 274

--5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) có
--tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số input),
--thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
--(Lưu ý: dùng Sub Query)
go
alter procedure sp_InfoPro @nam int
as 
	select pc.ProductCategoryID, p.Name, sum(OrderQty)
	from Production.Product p
	join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
	join Production.ProductCategory pc on pc.ProductCategoryID = psc.ProductCategoryID
	join Sales.SalesOrderDetail sd on p.ProductID = sd.ProductID
	join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
	where year(OrderDate) = @nam
	group by pc.ProductCategoryID, p.Name
	having sum(OrderQty) >= all	(select sum(OrderQty)
								from Production.Product p
								join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
								join Production.ProductCategory pc on pc.ProductCategoryID = psc.ProductCategoryID
								join Sales.SalesOrderDetail sd on p.ProductID = sd.ProductID
								join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
								where year(OrderDate) = @nam
								group by p.ProductID)
 

go

exec sp_InfoPro 2011
--6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả
--về trạng thái thành công hay thất bại của thủ tục.

go
create procedure TongThu @salesPersonID int
as
	if(@salesPersonID not in (select BusinessEntityID from Sales.SalesPerson))
	begin
		print N'Nhan vien nay khong ton tai'
	end
	else
	begin
		select TotalSale = SalesLastYear + SalesYTD
		from Sales.SalesPerson
		where BusinessEntityID = @salesPersonID
	end
go

exec TongThu 275

--7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo
--năm đã cho.
alter procedure sp_KhachHang @nam int
as
	select Name, sum(unitPrice) 
	from Sales.SalesOrderHeader sh
	join Sales.Customer cus on sh.CustomerID = cus.CustomerID
	join Sales.SalesOrderDetail sd on sh.SalesOrderID = sd.SalesOrderID
	join Sales.Store sto on cus.StoreID = sto.BusinessEntityID
	where year(OrderDate) = @nam
	group by Name
	having sum(OrderQty) >= all	(select sum(OrderQty)
						from Sales.SalesOrderHeader sh
						join Sales.Customer cus on sh.CustomerID = cus.CustomerID
						join Sales.SalesOrderDetail sd on sh.SalesOrderID = sd.SalesOrderID
						join Sales.Store sto on cus.StoreID = sto.BusinessEntityID
						where year(OrderDate) = @nam
						group by name)

exec sp_KhachHang 2013
--8) Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin
--vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not null
--và các field là khóa ngoại.
--9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader
--khi biết SalesOrderID. Lưu ý : trước khi xóa mẫu tin trong
--Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong
--Sales.SalesOrderDetail.
--10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice lên
--10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm này.