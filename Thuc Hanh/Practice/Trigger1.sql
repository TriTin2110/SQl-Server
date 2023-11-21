--1. Tạo một Instead of trigger thực hiện trên view. Thực hiện theo các bước sau:
--- Tạo mới 2 bảng M_Employees và M_Department theo cấu trúc sau:
drop table M_Department
create table M_Department
(
DepartmentID int not null primary key,
Name nvarchar(50),
GroupName nvarchar(50)
)
create table M_Employees
(
EmployeeID int not null primary key,
Firstname nvarchar(50),
MiddleName nvarchar(50),
LastName nvarchar(50),
DepartmentID int foreign key references M_Department(DepartmentID)
)
--- Tạo một view tên EmpDepart_View bao gồm các field: EmployeeID,
--FirstName, MiddleName, LastName, DepartmentID, Name, GroupName, dựa
--trên 2 bảng M_Employees và M_Department.
go
create view EmpDepart_View
as
	select EmployeeID, FirstName, MiddleName, LastName, md.DepartmentID, Name, GroupName
	from M_Department md 
	join M_Employees me on md.DepartmentID = me.DepartmentID
go
--- Tạo một trigger tên InsteadOf_Trigger thực hiện trên viewEmpDepart_View,
--dùng để chèn dữ liệu vào các bảng M_Employees và M_Department khi chèn
--một record mới thông qua view EmpDepart_View.
create trigger InsteadOf_Trigger on EmpDepart_View
instead of insert
as
	insert into M_Department
	select DepartmentID, Name, GroupName from inserted
	insert into M_Employees
	select EmployeeID, FirstName, MiddleName, LastName, DepartmentID from inserted
--Dữ liệu test:
insert EmpDepart_view values(1, 'Nguyen','Hoang','Huy', 11,'Marketing','Sales')
select * from M_Department, M_Employees
--Kết quả:
--2. Tạo một trigger thực hiện trên bảng MSalesOrders có chức năng thiết lập độ ưu
--tiên của khách hàng (CustPriority) khi người dùng thực hiện các thao tác Insert,
--Update và Delete trên bảng MSalesOrders theo điều kiện như sau:
--- Nếu tổng tiền Sum(SubTotal) của khách hàng dưới 10,000 $ thì độ ưu tiên của
--khách hàng (CustPriority) là 3
--- Nếu tổng tiền Sum(SubTotal) của khách hàng từ 10,000 $ đến dưới 50000 $ thì
--độ ưu tiên của khách hàng (CustPriority) là 2
--- Nếu tổng tiền Sum(SubTotal) của khách hàng từ 50000 $ trở lên thì độ ưu tiên
--của khách hàng (CustPriority) là 1
--Các bước thực hiện:
--- Tạo bảng MCustomers và MSalesOrders theo cấu trúc



create table MCustomer
(
CustomerID int not null primary key,
CustPriority int
)
create table MSalesOrders
(
SalesOrderID int not null primary key,
OrderDate date,
SubTotal money,
CustomerID int foreign key references MCustomer(CustomerID) )
--- Chèn dữ liệu cho bảng MCustomers, lấy dữ liệu từ bảng Sales.Customer,
--nhưng chỉ lấy CustomerID>30100 và CustomerID<30118, cột CustPriority cho
--giá trị null.
insert into MCustomer
select CustomerID, null from Sales.Customer 
where CustomerID>30100 and CustomerID<30118
--- Chèn dữ liệu cho bảng MSalesOrders, lấy dữ liệu từ bảng
--Sales.SalesOrderHeader, chỉ lấy những hóa đơn của khách hàng có trong bảng
--khách hàng.
insert into MSalesOrders
select SalesOrderID, OrderDate, SubTotal, mc.CustomerID 
from Sales.SalesOrderHeader sh
join MCustomer mc on mc.CustomerID = sh.CustomerID

--- Viết trigger để lấy dữ liệu từ 2 bảng inserted và deleted.
go
create trigger cau2 on MSalesOrders
for insert, update, delete
as 
	update MCustomer
	set CustPriority =
	case
		when (select sum(Subtotal) from MSalesOrders where CustomerID = inserted.CustomerID) < 10000 then 3
		when (select sum(Subtotal) from MSalesOrders where CustomerID = inserted.CustomerID) between 10000 and 50000 then 2
		when (select sum(Subtotal) from MSalesOrders where CustomerID = inserted.CustomerID) > 50000 then 1
		when (select sum(Subtotal) from MSalesOrders where CustomerID = inserted.CustomerID) = null then null
	end
	from MCustomer 
	join inserted on MCustomer.CustomerID = inserted.CustomerID
	where MCustomer.CustomerID = inserted.CustomerID 
go
delete from MSalesOrders where SalesOrderID = 1
INSERT INTO MSalesOrders (SalesOrderID, CustomerID, SubTotal, OrderDate)
VALUES (1, 30101, 5000, '2023-05-01');
select * from MSalesOrders, MCustomer
--- Viết câu lệnh kiểm tra việc thực thi của trigger vừa tạo bằng cách chèn thêm hoặc
--xóa hoặc update một record trên bảng MSalesOrders

--3. Viết một trigger thực hiện trên bảng MEmployees sao cho khi người dùng thực hiện
--chèn thêm một nhân viên mới vào bảng MEmployees thì chương trình cập nhật số
--nhân viên trong cột NumOfEmployee của bảng MDepartment. Nếu tổng số nhân
--viên của phòng tương ứng <=200 thì cho phép chèn thêm, ngược lại thì hiển thị
--thông báo “Bộ phận đã đủ nhân viên” và hủy giao tác. Các bước thực hiện:
--- Tạo mới 2 bảng MEmployees và MDepartment theo cấu trúc sau:
create table MDepartment
(
DepartmentID int not null primary key,
Name nvarchar(50),
NumOfEmployee int
)
create table MEmployees
(
EmployeeID int not null,
FirstName nvarchar(50),
MiddleName nvarchar(50),
LastName nvarchar(50),
DepartmentID int foreign key references MDepartment(DepartmentID),
constraint pk_emp_depart primary key(EmployeeID, DepartmentID)
)
select * from MEmployees, MDepartment
--- Chèn dữ liệu cho bảng MDepartment, lấy dữ liệu từ bảng Department, cột
--NumOfEmployee gán giá trị NULL, bảng MEmployees lấy từ bảng
--EmployeeDepartmentHistory
insert into MDepartment 
select DepartmentID, Name, 0 from HumanResources.Department
insert into MEmployees
select edh.BusinessEntityID, FirstName, MiddleName, LastName, md.DepartmentID
from HumanResources.EmployeeDepartmentHistory edh
join MDepartment md on edh.DepartmentID = md.DepartmentID
join HumanResources.Employee e on edh.BusinessEntityID = e.BusinessEntityID
join Person.Person p on p.BusinessEntityID = e.BusinessEntityID
--- Viết trigger theo yêu cầu trên và viết câu lệnh hiện thực trigger
go
create trigger cau3 on MEmployees
for insert
as
	declare @mapb int
	declare @sonv int

	set @mapb = (select DepartmentID from inserted)
	set @sonv = (select NumOfEmployee from MDepartment where @mapb = DepartmentID)

	if(@sonv<200)
	begin
		update MDepartment
		set NumOfEmployee = NumOfEmployee + 1
		where DepartmentID = @mapb
	end
	else
	begin
		print N'Phong ban nay da du nhan vien'
		rollback transaction
	end
go
INSERT INTO MEmployees (EmployeeID, FirstName, MiddleName, LastName, DepartmentID)
VALUES (7, 'John', 'M', 'Doe', 1)
select * from MEmployees
select * from MDepartment
--4. Bảng [Purchasing].[Vendor], chứa thông tin của nhà cung cấp, thuộc tính
--CreditRating hiển thị thông tin đánh giá mức tín dụng, có các giá trị:
--1 = Superior
--2 = Excellent
--3 = Above average
--4 = Average
--5 = Below average
--Viết một trigger nhằm đảm bảo khi chèn thêm một record mới vào bảng
--[Purchasing].[PurchaseOrderHeader], nếu Vender có CreditRating=5 thì hiển thị thông
--báo không cho phép chèn và đồng thời hủy giao tác.
--Dữ liệu test
--INSERT INTO Purchasing.PurchaseOrderHeader (RevisionNumber, Status,
--EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt,
--Freight) VALUES ( 2 ,3, 261, 1652, 4 ,GETDATE() ,GETDATE() , 44594.55,
--,3567.564, ,1114.8638 );
select * from Purchasing.PurchaseOrderHeader poh on pv.BusinessEntityID = poh.PurchaseOrderID
go
create trigger cau4 on [Purchasing].[PurchaseOrderHeader]
for insert
as
	declare @rating int
	set @rating = (select CreditRating from Purchasing.Vendor pv join inserted on pv.BusinessEntityID = inserted.PurchaseOrderID) 
	if(@rating = 5)
	begin
		print N'Khong cho phep chen'
		rollback transaction
	end
go
select * from Purchasing.Vendor pv
join Purchasing.PurchaseOrderHeader poh on pv.BusinessEntityID = poh.PurchaseOrderID
where VendorID = 1652

select * from Purchasing.PurchaseOrderHeader poh
join Purchasing.Vendor pv on poh.PurchaseOrderID = pv.BusinessEntityID
where VendorID = 1652
INSERT INTO Purchasing.PurchaseOrderHeader (RevisionNumber, Status,
EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt,
Freight) VALUES ( 2 ,3, 261, 1652, 4 ,GETDATE() ,GETDATE() , 44594.55
,3567.564, 1114.8638 );
--5. Viết một trigger thực hiện trên bảng ProductInventory (lưu thông tin số lượngsản
--phẩm trong kho). Khi chèn thêm một đơn đặt hàng vào bảng SalesOrderDetail với
--số lượng xác định trong field
--OrderQty, nếu số lượng trong kho
--Quantity> OrderQty thì cập nhật
--lại số lượng trong kho Quantity=
--Quantity- OrderQty, ngược lại
--nếu Quantity=0 thì xuất thông báo
--“Kho hết hàng” và đồng thời hủy
--giao tác.
--Sơ đồ của các bảng liên quan.
go
create trigger cau5 on [Production].[ProductInventory]
for insert 
as
	declare @soLuongKho int
	declare @soLuongField int

	set @soLuongField = (select OrderQty from Sales.SalesOrderDetail)
	set @soLuongKho = (select Quantity from inserted)

	if(@soLuongKho>@soLuongField)
		begin
			update [Production].[ProductInventory]
			set Quantity = @soLuongKho - @soLuongField
		end
	else
		begin
			print N'Kho het hang!'
		end
go

--• Tạo hai bảng mới M_SalesPerson và M_SalesOrderHeader
create table M_SalesPerson
(
SalePSID int not null primary key,
TerritoryID int,
BonusPS money
)
create table M_SalesOrderHeader
(
SalesOrdID int not null primary key,
OrderDate date,
SubTotalOrd money,
SalePSID int foreign key references M_SalesPerson(SalePSID)
)
select * from M_SalesPerson
--• Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn
--những field tương ứng với 2 bảng mới tạo.
insert into M_SalesPerson
select BusinessEntityID, TerritoryID, Bonus from Sales.SalesPerson
insert into M_SalesOrderHeader
select SalesOrderID, OrderDate, SubTotal, SalesPersonID from Sales.SalesOrderHeader
--• Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger
--thực thi thì dữ liệu trong bảng M_SalesPerson được cập nhật.
go
--6. Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson, khi
--người dùng chèn thêm một record mới trên bảng SalesOrderHeader, theo quy định
--như sau: Nếu tổng tiền bán được của nhân viên có hóa đơn mới nhập vào bảng
--SalesOrderHeader có giá trị >10000000 thì tăng tiền thưởng lên 10% của mức
--thưởng hiện tại. Cách thực hiện:
alter trigger cau6 on M_SalesOrderHeader
for update
as
	declare @sumSUB int
	declare @manv int
	set @manv = (select SalePSID from inserted)
	set @sumSUB = (select sum(SubTotalOrd) from inserted
					join M_SalesPerson ms on ms.SalePSID = inserted.SalePSID)

	if(@sumSUB>10000000)
	begin
		update M_SalesPerson
		set BonusPS = BonusPS + ((BonusPS * 10)/100)
		where SalePSID = @manv
	end
go
select sum(SubTotalOrd) from M_SalesOrderHeader
group by
insert into M_SalesOrderHeader values (75124, '2023-07-31', 20000000, null)
