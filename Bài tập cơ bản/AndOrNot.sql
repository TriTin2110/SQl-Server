use NORTHWND
--Bài tập 1 TITV 
select * from Orders where Freight >=50 and Freight <= 100
--Bài tập 2 TITV 
select * from Products where UnitsInStock > 20 and UnitsOnOrder < 20

--Thử  thách:
--1. Liệt kê  tất cả các nhân viên  có địa chỉ  ở USA
select * from Employees where Country like 'USA'
--2. Liệt  kê  tất  cả đơn  hàng  có  mã  đơn  hàng  khác  1
select * from Orders where OrderID <> 1

--Câu hỏi:
--1. Hãy liệt kê tất cả hàng hóa có giá lớn 50 và được giả giá lớn hơn 10 % trong bảng oder details
select * from [Order Details] where UnitPrice > 50  and Discount > 0.1
select * from [Order Details]
--2. Hãy liệt kê tất cả nhân viên là  nữ ở "London"
select * from Employees where TitleOfCourtesy like 'Ms.' and City like 'London'