use NORTHWND
--Bài tập TITV
select * from Orders where ShippedDate is null and ShipRegion is not null

--Thử  thách :
--1. Liệt  kê  tất  cả  các  đơn  hàng  có  ShipName  không bị null
select * from Orders where ShipName is not null
--2. Đếm số  lượng   các  khách  hàng  có  Phone  bị  null
select count(*) from Customers where Phone is null

--Câu 1: Lấy ra tất cả các loại mà tên loại từ bảng (Categorys) được để không được trống, 
--nghĩa là tên loại phải không được rỗng.
select * from Products where CategoryID is not null

--Câu 2: Lấy ra tất cả những nhân viên mà không có phần báo cáo (ReportsTo) từ bảng (Employees), 
--nghĩa là ở phần báo cáo của từng nhân viên phải rỗng.
select * from Employees where ReportsTo is null

-- lấy tất cả sản phẩm có tên và có ở trong kho
select * from Products where ProductName is not null

--lấy ra nhân viên ko đăng kí sinh nhật
select * from Employees where BirthDate is null

--Câu hỏi thử thách dành cho mọi người:
--1.Viết câu lệnh sql lấy ra tất cả nhân viên có PostalCode là not null
select * from Employees where PostalCode is not null
--2.Viết câu lệnh sql lấy ra 5 người đầu tiên có ngày sinh là null
select top (5) * from Employees where BirthDate is null

-- Hãy lấy ra toàn bộ danh sách nhân viên là nữ và Region không bị Null
select * from Employees where TitleOfCourtesy in ('Mrs.', 'Ms.') and Region is not null
-- Lấy danh sách các khách hàng số fax bị Null
select * from Customers where Fax is null