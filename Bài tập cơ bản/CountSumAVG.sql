use NORTHWND
--Bài tập 1 TITV
select count(*) from Orders
select count(OrderID) from Orders

--Bài tập 2 
select	AVG(UnitPrice) as "AVG UnitPrice",
		Sum(quantity) as "Sum Quantity"
from [Order Details]

--Thử thách : Dựa vào bảng products 
-- Hãy đếm số lượng đơn hàng 
-- tính tổng giá tiền của đơn hàng 
-- tính trung bình cho cột unitprice

select	count(*) as "Số lượng hàng",
		Sum(UnitPrice) as "Sum UnitPrice",
		AVG(UnitPrice) as "AVG UnitPrice"
from Products

--Thử  thách : 
--1. Đếm  số lượng nhà cung cấp trong bảng Suppliers 
select count(*)
from Suppliers
--2. Tính  trung bình số  tiền của các đơn hàng trong bảng Order Details 
select AVG(UnitPrice) as "Tiền trung bình"
from [Order Details]
--3. Tính  tổng  số  tiền  của  các  đơn hàng trong bảng Order Details
select sum(UnitPrice) as "Tổng tiền đơn hàng"
from [Order Details]

--3.tính tổng các CategoryID và tổng các CategoryID khác nhau từ bảng Products
select	Sum(CategoryID) as "Tổng các CategoryID",
		Sum(Distinct(CategoryID)) as "Tổng các CategoryID khác nhau"
from Products

--4. tính tổng mã số  EmployeeID khác nhau với điều kiện TitleOfCourtesy là 'Mr.' hoặc 'Ms.' hoặc 'Dr.'  và Null
select Sum(distinct(EmployeeID)) as "Tổng số EmployeeID khác nhau"
from Employees where TitleOfCourtesy = 'MR.' or TitleOfCourtesy = 'Dr.' or TitleOfCourtesy is null