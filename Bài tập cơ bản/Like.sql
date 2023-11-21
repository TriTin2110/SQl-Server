use NORTHWND
--Bài tập TITV
select * from Suppliers
where CompanyName like '%b%'

--câu hỏi 1: Lấy ra tất cả 'lastname' nhân viên có ký tự là chữ "a"
select * from Employees where LastName like '%a%'
--câu hỏi 2: Lấy ra tất cả tên khách hàng có có thành phố chứa chữ "o"
select ContactName from Customers where City like '%o%'

--Thử  thách  :
--1. Liệt  kê  tất  cả  các  khách  hàng có tên bắt đầu bằng chữ  A  và kết thúc là chữ M 
select * from Customers where ContactName like 'A%M' 
--2. Liệt  kê  tất  cả  các  nhân  viên  có  họ  chứa chữ H
select * from Employees where LastName like '%h%'

--THỬ THÁCH: Đặt ra 2 câu hỏi liên quan tới LIKE để luyện tập.
--Câu 1: Lấy ra tất cả nhân viên mà trong tên có chữ ‘D’ trong tên của họ.
select * from Employees where FirstName + LastName like '%d%'
--Câu 2: Lấy ra tất cả các sản phẩm mà tên sản phẩm có chữ cái ‘x’.
select * from Products where ProductName like '%x%'

-- Thử thách 
-- 1. Liệt kê tên sản phẩm có ký tự 'C' ở đầu và ký tự 'e ở cuối' (Bảng Products).
select * from Products where ProductName like 'c%e'
-- 2. Liệt kệ danh sách các Suppliers có số điện thoại :có chứa số 4 và có đuôi 22 (Bảng Suppliers).
select * from Suppliers where Phone like '%4%22'

---câu hỏi thử thách dành cho mọi người :
--1.viết câu lệnh sql lấy ra tên của nhân viên có chữ a
select FirstName +' '+ LastName as FullName from Employees where FirstName +' '+ LastName like '%a%'
--2.viết câu lệnh sql lấy ra tên thành phố bắt đầu bằng chữ L và kết thúc bằng chữ n
select City from Customers where City like 'l%n'