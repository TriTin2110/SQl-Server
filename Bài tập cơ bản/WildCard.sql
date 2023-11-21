use NORTHWND
--Bài tập TITV
select * from Suppliers where CompanyName like 'A%[^b]'

--Thử  thách  :
--1. Lọc  ra  tất  cả  các  khách  hàng  có  địa  chỉ  bắt  đầu  bằng  chữ  H , chữ  thứ 2 là  bất  kì  ký  tự  nào.
select * from Customers where Address like 'H_%'
--2. Lọc  rả  tất  cả  các  đơn  hàng  có  địa chỉ giao hàng với chữ cái đầu không  bắt đầu bằng A hoặc H, chữ  cái  
-- thứ  2 là   S  hoặc  G
select * from Orders where ShipAddress like '[^a,h][s,g]%'

--THỬ THÁCH: Đặt ra 2 câu hỏi liên quan đến WILDCARD
--Câu 1: Lấy ra tất cả những khách hàng với tên liên hệ bắt đầu bằng ‘A’ đến ‘D’.
select * from Customers where ContactName like '[A-D]%'
--Câu 2: Lấy ra tất cả những đơn hàng có đất nước được vận chuyển bắt đầu bằng ‘U’ và ký tự thứ 2 không rỗng.
select * from Orders where ShipCountry like 'U_'

--câu hỏi thử thách dành cho mọi người :
--1.viết câu lệnh lấy ra tên nhân viên chứa chứ B đầu tên và chữ g cuối tên
select FirstName + ' ' + LastName from Employees where FirstName like 'B%g'
--2.viết câu lệnh lấy ra tên sản phẩm không chứa chữ c
select * from Products where ProductName not like '%c%' 
