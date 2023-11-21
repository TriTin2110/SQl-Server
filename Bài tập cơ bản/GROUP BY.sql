use NORTHWND
--Bài tập TITV
select Country, Count(EmployeeID) from Employees group by Country

-- Thử thách 1: Hãy cho biết số lượng thành phố, và quốc gia theo từng khách hàng
select  CustomerID,Count(City), Count(Country) from Customers group by CustomerID
select Country, City, count(CustomerID) from Customers group by Country, City
-- Thử thách 2: Hãy cho biết tổng giá hàng từ đơn đặt hàng và productid
select  ProductID, sum(UnitPrice) from Products group by ProductID

--Bài 1.     Liệt kê danh sách các nhóm hàng (category) có tổng số mặt hàng (product) nhỏ hơn 10.  
--Thông tin kết quả bao gồm CategoryID, CategoryName, CountOfProducts.  
--Được sắp xếp theo CategoryName, cùng CategoryName thì sắp theo CountOfProducts giảm dần.
select ca.CategoryID, CategoryName, sum(ProductID) 
from Categories ca join Products p on ca.CategoryID = p.CategoryID
group by ca.CategoryID, CategoryName
having sum(ProductID) < 10
order by CategoryName, sum(ProductID) desc

--Đặt câu hỏi:
--+ Hãy cho biết tổng số khách hàng theo từng quốc gia và thành phố, và lọc theo quốc gia từ a-z ( 69 rows)
select Country, City, count(CustomerID) from Customers group by Country, City order by Country
--+ Hãy cho biết 'số lượng sản phẩm tồn kho' theo nhà cung cấp. (29 rows)
select SupplierID, count(UnitsInStock) from Products group by SupplierID

--Hãy liệt kê số lượng khách hàng ở mỗi đất nước khác nhau.
select Country, count(CustomerID) from Customers group by Country
--Hãy cho biết tổng đơn giá(UnitPrice) của  mỗi đơn hàng trong bảng (OrderDetail).
select OrderID, sum(UnitPrice) from [Order Details] group by OrderID

--Thống kê số nhân viên theo từng thành phố và quốc gia (Bảng Employees)
select Country, City, count(EmployeeID) from Employees group by Country, City
--2. Thống kê sản phẩm có [UnitPrice] nhỏ nhất , [Quantity] trung bình , [Discount] lớn nhất (Bảng Order Details).
select ProductID, Min(UnitPrice), AVG(Quantity), Max(Discount) from [Order Details] group by ProductID



