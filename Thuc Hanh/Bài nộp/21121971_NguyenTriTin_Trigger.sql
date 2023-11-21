--Câu 1
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
Create view EmpDepart_View
as
	select EmployeeID, Firstname, MiddleName, LastName ,md.DepartmentID, Name, GroupName from M_Department md
	join M_Employees me on me.DepartmentID = md.DepartmentID
go

go
create trigger InsteadOf_Trigger on EmpDepart_View
instead of insert
as
begin
insert into M_Department (DepartmentID, Name, GroupName)
select DepartmentID, Name, GroupName from inserted
insert into M_Employees (EmployeeID, Firstname, MiddleName, LastName, DepartmentID)
select EmployeeID, Firstname, MiddleName, LastName, DepartmentID from inserted
end
insert EmpDepart_view values(1, 'Nguyen','Hoang','Huy', 11,'Marketing','Sales')
select *from M_Department

--Câu 2
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
CustomerID int foreign key references MCustomer(CustomerID) 
)

insert MCustomer(CustomerID, CustPriority)
(select CustomerID, null
from Sales.Customer
where CustomerID>30100 and CustomerID<30118)

insert MSalesOrders(SalesOrderID, OrderDate, SubTotal, CustomerID)
select SalesOrderID, OrderDate, SubTotal, CustomerID
from Sales.SalesOrderHeader 
where CustomerID>30100 and CustomerID<30118 and YEAR(OrderDate) = 2012
select * from MSalesOrders

go
create trigger Proprity on MSalesOrders
for insert, update, delete
as 
	With CTE as
	(	
		select CustomerID from inserted
		union
		select CustomerID from deleted
	)
	update MCustomer
	set
	custpriority =
		case
			when sum(subtotal) < 10000 then 3
			when sum(subtotal) between 1000 and 50000 then 2
			when sum(subtotal) >50000 then 1
			when sum(subtotal) is null then null
		end
	from Mcustomer c inner join CTE on CTE.customerID = c.customerID
		left join(	select MsalesOrders.customerID, sum(subtotal)
					from MsaleOrders inner join CTE on CTE.customerID = MsalesOrder.CustomerID
					group by MsalesOrders.customerID) t on t.customerID= c.customerID
go

--Câu 3
--3. Viết một trigger thực hiện trên bảng MEmployees sao cho khi người dùng thực hiện
--chèn thêm một nhân viên mới vào bảng MEmployees thì chương trình cập nhật số
--nhân viên trong cột NumOfEmployee của bảng MDepartment. Nếu tổng số nhân
--viên của phòng tương ứng <=200 thì cho phép chèn thêm, ngược lại thì hiển thị
--thông báo “Bộ phận đã đủ nhân viên” và hủy giao tác. Các bước thực hiện:
--Chèn dữ liệu cho bảng MDepartment, lấy dữ liệu từ bảng Department, cột
--NumOfEmployee gán giá trị NULL, bảng MEmployees lấy từ bảng
--EmployeeDepartmentHistory
--- Viết trigger theo yêu cầu trên và viết câu lệnh hiện thực trigger
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
insert into MDepartment
select DepartmentID, Name, null from HumanResources.Department
select * from MDepartment

insert into MEmployees
select edh.BusinessEntityID, FirstName, MiddleName, LastName, DepartmentID  from HumanResources.EmployeeDepartmentHistory edh
join HumanResources.Employee e on e.BusinessEntityID = edh.BusinessEntityID
join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
select * from MEmployees

go
create trigger NumOfEm on MEmployees
for insert
as
	
go
--insert into M_Department (DepartmentID, Name, GroupName)
--select DepartmentID, Name, GroupName from inserted
--insert into M_Employees (EmployeeID, Firstname, MiddleName, LastName, DepartmentID)
--select EmployeeID, Firstname, MiddleName, LastName, DepartmentID from inserted
--end

--Câu 4
create trigger Rating on [Purchasing].[PurchaseOrderHeader]
for insert
as
	if(select CreditRating from inserted i
		join Purchasing.Vendor v on v.BusinessEntityID = i.VendorID)=5
		begin
			print(N'Không cho phép chèn')
			rollback transaction
		end

INSERT INTO Purchasing.PurchaseOrderHeader (RevisionNumber, Status,
EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt,
Freight) VALUES ( 2 ,3, 261, 1652, 4 ,GETDATE() ,GETDATE() , 44594.55
,3567.564 ,1114.8638 );

--Câu 5

go
create trigger saveQuantity on [Production].[ProductInventory]
for update
as
	update [Production].[ProductInventory]
	set Quantity = 
		case
			when Quantity>OrderQty then Quantity - OrderQty
			when Quantity = 0 then N'Kho hết hàng'
			end
	from Sales.SalesOrderDetail
go

--Câu 6
--Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson, khi
--người dùng chèn thêm một record mới trên bảng SalesOrderHeader, theo quy định
--như sau: Nếu tổng tiền bán được của nhân viên có hóa đơn mới nhập vào bảng
--SalesOrderHeader có giá trị >10000000 thì tăng tiền thưởng lên 10% của mức
--thưởng hiện tại. Cách thực hiện:
--Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn
--những field tương ứng với 2 bảng mới tạo.
--• Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger
--thực thi thì dữ liệu trong bảng M_SalesPerson được cập nhật.

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
insert into M_SalesPerson
select BusinessEntityID, TerritoryID, Bonus from Sales.SalesPerson
select * from M_SalesPerson

insert into M_SalesOrderHeader
select SalesOrderID, OrderDate, SubTotal, SalesPersonID from Sales.SalesOrderHeader
select * from M_SalesOrderHeader
go
create trigger Bonus on Sales.SalesPerson
for update, insert
as
	insert into M_SalesOrderHeader
	select  from inserted
go

