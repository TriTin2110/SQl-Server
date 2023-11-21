--1) Tạo hai bảng mới trong cơ sở dữ liệu AdventureWorks2008 theo cấu trúc sau:
create table MyDepartment(
	DepID smallint not null primary key,
	DeName nvarchar(50),
	GropName nvarchar
)
create table MyEmployee(
	EmpID int not null primary key,
	FrstName nvarchar(50),
	MidName nvarchar(50),
	LstName nvarchar(50),
	DepID smallint not null foreign key references MyDepartment(DepID)
	)
--2) Dùng lệnh insert <TableName1> select <fieldList> from
--<TableName2> chèn dữ liệu cho bảng MyDepartment, lấy dữ liệu từ bảng
--[HumanResources].[Department].
go
insert MyDepartment select DepartmentID, Name, GroupName from HumanResources.Department
go
--3)Tương tự câu 2, chèn 20 dòng dữ liệu cho bảng MyEmployee lấy dữ liệu
--từ 2 bảng
--[Person].[Person] và
--[HumanResources].[EmployeeDepartmentHistory]select * from Person.Person 
insert MyEmployee select top 20 p.BusinessEntityID, p.FirstName, p.MiddleName, p.LastName, edh.DepartmentID from 
HumanResources.EmployeeDepartmentHistory edh
join Person.Person p on p.BusinessEntityID = edh.BusinessEntityID

--4) Dùng lệnh delete xóa 1 record trong bảng MyDepartment với DepID=1,
--có thực hiện được không? Vì sao?
delete from MyDepartment where DepID=1 
--Lệnh delete xóa được 1 record trong bảng MyDepartment vì dữ liệu trong MyDepartment được cấp từ [HumanResources].[Department] nên việc xóa 
--record trong MyDepartment sẽ không ảnh hưởng đến table gốc của nó cho nên việc xóa record này được cho phép.

--5) Thêm một default constraint vào field DepID trong bảng MyEmployee,
--với giá trị mặc định là 1.
alter table Myemployee
add constraint DepID_constraint Default(1) for DepID

--6) Nhập thêm một record mới trong bảng MyEmployee, theo cú pháp sau:
--insert into MyEmployee (EmpID, FrstName, MidName,
--LstName) values(1, 'Nguyen','Nhat','Nam'). Quan sát giá trị
--trong field depID của record mới thêm.
insert into MyEmployee (EmpID, FrstName, MidName, LstName) values(1, 'Nguyen','Nhat','Nam')
select * from MyEmployee
--7) Xóa foreign key constraint trong bảng MyEmployee, thiết lập lại khóa ngoại
--DepID tham chiếu đến DepID của bảng MyDepartment với thuộc tính on
--delete set default.
alter table myemployee
drop constraint FK__MyEmploye__DepID__442B18F2
alter table myemployee
add constraint DepID_constraints foreign key (DepID) references MyDepartment(DepID) on delete set default
--8) Xóa một record trong bảng MyDepartment có DepID=7, quan sát kết quả
--trong hai bảng MyEmployee và MyDepartment
delete from MyDepartment where DepID=7
--9) Xóa foreign key trong bảng MyEmployee. Hiệu chỉnh ràng buộc khóa ngoại
--DepID trong bảng MyEmployee, thiết lập thuộc tính on delete cascade và
--on update cascade
alter table myemployee
drop constraint DepID_constraints
alter table myemployee 
add constraint DepID_constraintss foreign key (DepID) references MyDepartment(DepID) on delete cascade
alter table myemployee 
add constraint DepID_constraintsss foreign key (DepID) references MyDepartment(DepID) on update cascade
--10)Thực hiện xóa một record trong bảng MyDepartment với DepID =3, có thực
--hiện được không?
delete from MyDepartment where DepID = 3
--Thực hiện được việc xóa record trong bảng MyDepartment với DepID =3
select * from MyDepartment
--11)Thêm ràng buộc check vào bảng MyDepartment tại field GrpName, chỉ cho
--phép nhận thêm những Department thuộc group Manufacturing
go
alter table mydepartment with nocheck
add constraint CHK_GroupName check(GroupName like 'Manufacturing')
go
--12)Thêm ràng buộc check vào bảng [HumanResources].[Employee], tại cột
--BirthDate, chỉ cho phép nhập thêm nhân viên mới có tuổi từ 18 đến 60
go
alter table HumanResources.Employee with nocheck
add constraint CHK_BirthDay check(year(getdate())-year(BirthDate) between 18 and 60)
