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
--Liệt kê đơn hàng có ngày đặt hàng gần nhất
select OrderID
from Orders where OrderDate =	(select max(OrderDate)
								from Orders)

--Liệt kê sản phẩm không có đơn đặt hàng
select *
from Products 
where ProductID not in	(select distinct od.ProductID
					from [Order Details] od)

--Lấy thông tin về đơn hàng và tên sản phẩm thuộc đơn hàng chưa được giao					
select o.*, p.ProductName
from Orders o	join [Order Details] od on o.OrderID = od.OrderID
				join Products p on od.ProductID = p.ProductID
where o.OrderID  in	(select distinct OrderID
							from Orders
							where ShippedDate is null)

--Lấy số thông tin các sản phẩm có số lượng tồn kho ít hơn số lượng tồn kho trung bình của các sản phẩm
select distinct *
from  Products p 
where p.UnitsInStock <	(select Avg(UnitsInStock)
						from Products) 

--Lấy thông tin khách hàng có tổng giá trị đơn hàng cao nhất
select cus.*
from Customers cus	join Orders o on cus.CustomerID = o.CustomerID
					join [Order Details] od on o.OrderID = od.OrderID
where (od.Quantity * od.UnitPrice- od.Discount) = (select max(Quantity * UnitPrice- Discount) 
									from [Order Details] 
									)
select cus.*
from Customers cus join Orders o on cus.CustomerID = o.CustomerID 
where Freight =		(select max(Freight)
					from Orders)