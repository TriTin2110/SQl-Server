--Sử dụng SSMS (Sql Server Management Studio) để thực hiện các thao tác sau:
--1) Đăng nhập vào SQL bằng SQL Server authentication, tài khoản sa. Sử dụng TSQL.
--2) Tạo hai login SQL server Authentication User2 và User3
create login User2 with password= 'user2'
create user User2 for login User2

create login User3 with password = 'user3'
create user User3 for login User3
--3) Tạo một database user User2 ứng với login User2 và một database user User3
--ứng với login User3 trên CSDL AdventureWorks2008.
create database User2
create database User3
--4) Tạo 2 kết nối đến server thông qua login User2 và User3, sau đó thực hiện các thao
--tác truy cập CSDL của 2 user tương ứng (VD: thực hiện câu Select). Có thực hiện
--được không?
alter login User2 with default_database = User2
alter login User3 with default_database = User3
--5) Gán quyền select trên Employee cho User2, kiểm tra kết quả. Xóa quyền select trên
--Employee cho User2. Ngắt 2 kết nối của User2 và User3
grant select on HumanResources.Employee to User2
revoke select on HumanResources.Employee from User2
--6) Trở lại kết nối của sa, tạo một user-defined database Role tên Employee_Role trên
--CSDL AdventureWorks2008, sau đó gán các quyền Select, Update, Delete cho
--Employee_Role.
create role Employee_Role
grant select, update, delete to Employee_Role
--7) Thêm các User2 và User3 vào Employee_Role. Tạo lại 2 kết nối đến server thông
--qua login User2 và User3 thực hiện các thao tác sau:
alter role Employee_Role add member User2
alter role Employee_Role add member User3
--a) Tại kết nối với User2, thực hiện câu lệnh Select để xem thông tin của bảng
--Employee
--b) Tại kết nối của User3, thực hiện cập nhật JobTitle=’Sale Manager’ của nhân
--viên có BusinessEntityID=1
--c) Tại kết nối User2, dùng câu lệnh Select xem lại kết quả.
--d) Xóa role Employee_Role, (quá trình xóa role ra sao?)
alter role Employee_Role drop member User2
alter role Employee_Role drop member User3
drop role Employee_Role