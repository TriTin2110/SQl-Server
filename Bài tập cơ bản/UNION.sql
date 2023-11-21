use NORTHWND
--UNION lấy kết quả và loại những kết quả trùng lặp
--UNION ALL lấy kết quả và KHÔNG loại những kết quả trùng lặp
--Kết hợp tất cả những kết quả (gom những kết quả trùng) truy vấn được bằng câu lệnh UNION
--Lấy city và country trong bảng Customers điều kiện là Country trùng với những quốc gia có tên bắt đầu = U
select City, Country
from Customers
where Country like 'U%'
Union
-- Lấy city và country trong bảng Suppliers điều kiện là city = london
select City, Country
from Suppliers
where City = 'London'
Union
-- Lấy city và country trong bảng Orders điều kiện là ShipCountry = USA
select ShipCity, ShipCountry
from Orders
where ShipCountry = 'USA'

