use NORTHWND
--Lấy 5 mã khách hàng không trùng lặp
select distinct top 5 CustomerID from Orders

--Lấy 3 mã category trong product không trùng lặp
select distinct top 3 CategoryID from Products

--Câu 1: Truy vấn 20% không trùng lặp ShipName và ShipAddress trong bảng Orders.
select distinct top 20 percent ShipName, ShipAddress from Orders

--Câu 2: Truy vấn 120 dòng đầu trong bảng Orders.
select top 120 * from Orders

-- Viet cau lenh SQL lay ra 50% cac ngay dat hang khac nhau tu bang don hang
select distinct top 50 percent OrderDate from Orders

-- Viet cau lenh SQL lay ra 10 dong ten cong ty khac nhau tu nguoi cung cap
select distinct top 10 CompanyName from Suppliers

--Viết câu lệnh SQL lấy ra TOP 5 Country khác nhau của Nhân viên
select distinct top 5 Country from Employees

--Viết câu lệnh SQL lấy ra 30% Sđt khác nhau của các nhà nhà đầu tư.
select distinct top 30 percent Phone from Suppliers

--viết câu lệnh sql lấy ra phần Notes của Employees và chỉ có thể lấy ra 7 dòng
select top 7 Notes from Employees

--viết câu lệnh sql lấy ra phần ShipAddress của Orders và chỉ có thể lấy ra 4 dòng
select top 4 ShipAddress from Orders