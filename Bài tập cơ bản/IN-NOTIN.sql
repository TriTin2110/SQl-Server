use NORTHWND
--Bài tập 1 TiTV 
select * from Customers where City in ('Berlin', 'London', 'Warszawa')

-- Hãy liệt kê tất cả đơn hàng có Ship Via là 3, 4 (bảng Orders)
select * from Orders where ShipVia in(3,4)
-- Hãy liệt kê toàn bộ khách hàng không ở thành phố Berlin, London và Madrid
select * from Customers where City not in ('Berlin', 'London','Madrid')

--Thử  thách :
--1. Liệt kê tất cả các  sản  phẩm có đơn gía  là 10, 50, 100
select * from Products where UnitPrice in (10,50,100)
--2. Liệt  kê  tất  cả  các  đơn  hàng  không gửi  đến thành  phố   Berlin, London, Warszawa
select * from Orders where ShipCity not in ('Berlin', 'London', 'Warszawa')

--question:
--1. put out the Products have other ProductName with chai,chang
select * from Products where ProductName not in ('Chai', 'Chang')
--2. please list the Employees is Nancy,Steven,Anne on  FirstName board
select * from Employees where FirstName in ('Nancy', 'Steven', 'Anne')

--- câu hỏi thử thách dành cho mọi người :
--1.viết câu lệnh sql lấy ra tên của nhân viên có họ là Leverling,Peacock,Suyama
select FirstName  from Employees where LastName in ('Leverling', 'Peacock', 'Suyama')
--2.viết câu lệnh sql lấy ra quốc gia của khách hàng là Mexico,UK,Brazil
select Country from Customers where Country in ('Mexico', 'UK', 'Brazil')