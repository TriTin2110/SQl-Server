USE NORTHWND
--Bài tập 1 TITV
select *
FROM Orders
ORDER BY OrderDate DESC 

--Bài tập 2 TITV
select ProductName, UnitPrice, UnitsInStock
from Products
order by UnitsInStock desc

--3 câu hỏi
--- sắp xếp ngày đặt hàng theo thứ tự tăng dần
select * from Orders order by OrderDate
--- sắp xếp giá của sp theo thứ tự tăng dần
select * from Products order by UnitPrice
--- sắp xếp số lượng sp theo thứ tự giảm dần
select * from Products order by UnitsInStock desc, UnitsOnOrder desc


--Thử  thách : 
--1. Hãy  liệt  kê  tất  cả  các  sản  phẩm  trong  bảng  Products  theo  thứ  tự  tăng  dần  của  đơn  giá  và giảm  dần  
--số  lượng sản  phẩm trong kho.
select * from Products order by UnitPrice, UnitsInStock desc, UnitsOnOrder desc
--2. Hãy  liệt  kê  tất  cả  các  đơn  hàng  trong  bảng  Orders  theo  thứ tự giảm dần của ngày đặt hàng.
select * from Orders order by OrderDate desc
--3. Hãy  liệt  kê  danh  sách các nhân viên  (Employee) trong  bảng Employees có thứ tự tăng dân  của ngày sinh
select * from Employees order by BirthDate

--THỬ THÁCH: Đặt 2 câu hỏi liên quan đến câu lệnh ORDER BY để luyện tập.
--Câu 1: Viết câu lệnh SQL liệt kê các nhà cung cấp theo yêu cầu là tên quốc gia của các nhà cung cấp (bảng Suppliers) 
--theo chiều tăng A -> Z.
select * from Suppliers order by Country
--Câu 2: Viết câu lệnh SQL liệt kê họ và tên, địa chỉ của nhân viên theo tiêu chí giảm dần ngày sinh của các nhân viên trong (bảng Employees).
select FirstName+ ' ' + LastName as Name, Address from Employees order by BirthDate desc

--câu hỏi 1: Liệt kê tên công ty trong bảng Supplier theo thứ tự giảm dần của tên thành phố
select CompanyName from Suppliers order by City desc
--câu hỏi 2: Hãy liệt tên mã nhân vên, tên và của tất cả nhân viên trong bảng "Employees" theo thứ tự ngày 
--sinh nhật tăng dần
select EmployeeID, FirstName + ' ' + LastName as Name from Employees order by BirthDate