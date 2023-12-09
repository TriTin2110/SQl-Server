use NORTHWND
--Bài tập TITV 3
select ProductName, 
		(
			select count(od.OrderID)
			from [Order Details] od 
			where od.ProductID = p.ProductID
		) as Total
from Products p

--Bài tập TITV 4
select o.OrderID,  
		(select sum(od.UnitPrice * od.Quantity)
		from [Order Details] od
		--Lấy tổng giá trị dựa trên từng sản phẩm
		where od.OrderID = o.OrderID) as Total
from Orders o
