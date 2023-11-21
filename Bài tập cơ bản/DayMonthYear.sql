use NORTHWND
--Bài tập TITV
select OrderID, MONTH(ShippedDate) as 'Month', YEAR(ShippedDate) as 'Year' 
from Orders where MONTH(ShippedDate) = 5 
order by year

--Đếm  số  lượng  nhân  viên  theo  City  và  có  ngày thuê là 1992
select City, Count(*) from Employees where YEAR(HireDate) = 1992 group by City

--* Thử thách 1: Hãy lọc ra các đơn đặt hàng đã được giao vào tháng 7, và sắp xếp giảm dần theo năm.
select OrderID, MONTH(ShippedDate) as 'Month', year(ShippedDate) 'Year' 
from Orders where MONTH(ShippedDate) = 7 order by year(ShippedDate) desc
--* Thử thách 2: Lấy danh sách các đơn hàng được giao vào ngày 3 tháng 10 năm 1996. Từ bảng Orders
select * from Orders where ShippedDate = '1996-10-03'

--TT1: Lấy ra danh sách nhân viên sinh nhật vào tháng 12 năm 1948 
select * from Employees where Month(BirthDate) = 12 and Year(BirthDate) = 1948
-- TT2: Lấy ra danh sách khách hàng đặt hàng bao nhiêu đơn trong tháng 9 năm 1996 sắp xếp năm tăng
select CustomerID, Count(*) as 'CountOfOrder', MONTH(OrderDate) as 'Month', Year(OrderDate)  as 'Year'
from Orders where MONTH(OrderDate) = 9 and Year(OrderDate) = 1997
group by CustomerID, OrderDate
order by Year(OrderDate)