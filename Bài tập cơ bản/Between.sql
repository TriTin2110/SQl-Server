use NORTHWND
select* from Orders where (OrderDate Between '1997-1-1' and '1997-12-31') and ShipVia = 3
--Thử  thách :
--1. Tính  giá  trung  bình  của  các  sản  phẩm có  ngày  đặt  hàng trong khoảng từ ngày  1/1/1996 đến  ngày  31/7/1997
select AVG(UnitPrice) from [Order Details] od join Orders o on od.OrderID = o.OrderID 
where o.OrderDate between '1996-1-1' and '1997-7-31'
--2. Liệt  kê  tất  cả  các  sản phẩm có đơn giá trong  khoảng từ 50 đến  100 và  Category=1
select * from Products where (UnitPrice between 50 and 100) and CategoryID = 1

--Lấy ra danh sách nhân viên có last name từ "A-M"
select * from Employees where LastName between 'A' and 'M'
-- Lấy danh danh sách nhân viên có quốc tịch Pháp và có tên First Name từ "L-Z"
select * from Employees where Country like 'UK' and (FirstName between 'L' and 'Z')

--Câu 1: Lấy ra tất cả các sản phẩm có số lượng hàng tồn kho từ 50 đến 100 sản phẩm.
select * from Products where UnitsInStock between 50 and 100
--Câu 2: Lấy ra danh sách các quốc gia của các nhân viên có sinh nhật nằm trong khoảng 
--từ ngày 1/8/1996 cho đến ngày 31/8/1996.
select Country from Employees where BirthDate between '1996-8-1' and '1996-8-31'

--câu hỏi thử thách dành cho mọi người:
--1.viết câu lệnh sql lấy ra sản phẩm có giá từ 200 tới 400
select * from Products where UnitPrice between 200 and 400
--2. viết câu lệnh sql lấy ra sản phẩm có giá từ 100 tới 200 và còn hàng trong kho
select * from Products where (UnitPrice between 100 and 200) and UnitsInStock+UnitsOnOrder>1