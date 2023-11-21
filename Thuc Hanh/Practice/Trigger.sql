--1. Tạo một Instead of trigger thực hiện trên view. Thực hiện theo các bước sau:
--- Tạo mới 2 bảng M_Employees và M_Department theo cấu trúc sau:
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
go
--- Tạo một view tên EmpDepart_View bao gồm các field: EmployeeID,
--FirstName, MiddleName, LastName, DepartmentID, Name, GroupName, dựa
--trên 2 bảng M_Employees và M_Department.
create view EmpDepart_View(EmployeeID,FirstName, MiddleName, LastName, DepartmentID, Name, GroupName)
as
	select EmployeeID, Firstname, MiddleName, LastName ,md.DepartmentID, Name, GroupName from M_Department md
	join M_Employees me on md.DepartmentID = me.DepartmentID
go
select * from EmpDepart_View
--- Tạo một trigger tên InsteadOf_Trigger thực hiện trên viewEmpDepart_View,
--dùng để chèn dữ liệu vào các bảng M_Employees và M_Department khi chèn
--một record mới thông qua view EmpDepart_View.
go
create trigger InsteadOf_Trigger on EmpDepart_View
instead of insert
as
begin 
	insert into M_Department
	select DepartmentID, Name, GroupName from inserted
	insert into M_Employees
	select EmployeeID, Firstname, MiddleName, LastName, DepartmentID from inserted
end
go
insert EmpDepart_view values(1, 'Nguyen','Hoang','Huy', 11,'Marketing','Sales')
select * from M_Department
select * from M_Employees

--Dữ liệu test:
--insert EmpDepart_view values(1, 'Nguyen','Hoang','Huy', 11,'Marketing','Sales')
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
--sau: 
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
insert into MCustomer(CustomerID, CustPriority) select CustomerID, null from Sales.Customer where CustomerID>30100 and CustomerID<30118
select * from MCustomer
--- Chèn dữ liệu cho bảng MSalesOrders, lấy dữ liệu từ bảng
--Sales.SalesOrderHeader, chỉ lấy những hóa đơn của khách hàng có trong bảng
--khách hàng.
insert into MSalesOrders(SalesOrderID, OrderDate, SubTotal, CustomerID)
select SalesOrderID, OrderDate, SubTotal, sh.CustomerID from Sales.SalesOrderHeader sh
join MCustomer mcus on sh.CustomerID = mcus.CustomerID
select * from MSalesOrders
--- Viết trigger để lấy dữ liệu từ 2 bảng inserted và deleted.
go
create trigger kiemTra on MSalesOrders
for insert, update, delete
as
	with CTE as
	(
		select CustomerID from inserted
		union
		select CustomerID from deleted
	)
	update MCustomer
	set CustPriority = 
		case
			when sum(SubTotal)<10000 then 3
			when sum(SubTotal)between 10000 and 50000 then 2
			when sum(SubTotal)>50000 then 1
			when sum(SubTotal) is null then null
		end
	from MCustomer c join CTE on CTE.CustomerID = c.CustomerID
	left join	(select MSalesOrders.CustomerID, sum(SubTotal) as sumSUB
				from MSalesOrders join CTE on CTE.CustomerID = MSalesOrders.CustomerID
				group by MSalesOrders.CustomerID) t on t.CustomerID = c.CustomerID
go
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
DepartmentID int foreign key references MDepartment(DepartmentID)
)
--- Chèn dữ liệu cho bảng MDepartment, lấy dữ liệu từ bảng Department, cột
--NumOfEmployee gán giá trị NULL, bảng MEmployees lấy từ bảng
--EmployeeDepartmentHistory
drop table MDepartment
insert into MDepartment select DepartmentID, Name, 0 from HumanResources.Department
select * from MEmployees
insert into MEmployees 
select e.BusinessEntityID, FirstName, MiddleName, LastName, edh.DepartmentID 
from HumanResources.EmployeeDepartmentHistory edh 
join HumanResources.Employee e on edh.BusinessEntityID = e.BusinessEntityID
join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
select * from MEmployees
--- Viết trigger theo yêu cầu trên và viết câu lệnh hiện thực trigger
go
alter trigger chinhSuaNhanVien on MEmployees
for insert
as 
	declare @soNV int
	declare @maPB int
	
	select @maPB=DepartmentID from inserted
	select @soNV=NumOfEmployee from MDepartment where DepartmentID=@maPB

	if(@soNV<=200)
	begin
		update MDepartment
		set NumOfEmployee=@soNV+1
		where @maPB=DepartmentID
	end
	else
	begin
		print('Bộ phận đã đủ nhân viên')
		rollback transaction
	end
go
INSERT INTO MEmployees (EmployeeID, FirstName, MiddleName, LastName, DepartmentID)
VALUES (1, 'John', 'M', 'Doe', 1)
select * from MEmployees
select * from MDepartment
delete from MEmployees where EmployeeID = 391
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
--Bài tập Thực hành Hệ Quản Trị Cơ sở Dữ Liệu
---26-
--6. Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson, khi
--người dùng chèn thêm một record mới trên bảng SalesOrderHeader, theo quy định
--như sau: Nếu tổng tiền bán được của nhân viên có hóa đơn mới nhập vào bảng
--SalesOrderHeader có giá trị >10000000 thì tăng tiền thưởng lên 10% của mức
--thưởng hiện tại. Cách thực hiện:
--• Tạo hai bảng mới M_SalesPerson và M_SalesOrderHeader
--create table M_SalesPerson
--(
--SalePSID int not null primary key,
--TerritoryID int,
--BonusPS money
--)
--create table M_SalesOrderHeader
--(
--SalesOrdID int not null primary key,
--OrderDate date,
--SubTotalOrd money,
--SalePSID int foreign key references M_SalesPerson(SalePSID)
--)
--• Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn
--những field tương ứng với 2 bảng mới tạo.
--• Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger
--thực thi thì dữ liệu trong bảng M_SalesPerson được cập nhật.