--1. Trong SQL Server, tạo thiết bị backup có tên adv2008back lưu trong thư mục
--T:\backup\adv2008back.bak
use master
backup database [AdventureWorks2012]
to disk = 'D:\back\adv2012back.bak'

--2. Attach CSDL AdventureWorks2008, chọn mode recovery cho CSDL này là full, rồi
--thực hiện full backup vào thiết bị backup vừa tạo
backup database [AdventureWorks2012]
to disk = 'D:\back\adv2012fullback.bak'
with description = 'Full backup cau 2'
--3. Mở CSDL AdventureWorks2008, tạo một transaction giảm giá tất cả mặt hàng xe
--đạp trong bảng Product xuống $15 nếu tổng trị giá các mặt hàng xe đạp không thấp
--hơn 60%.
use AdventureWorks2012
select * from Production.Product
use AdventureWorks2012
begin tran
	update Production.Product
	set ListPrice = 15
	where ProductSubcategoryID in (select * from Production.Product p 
						join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
						join Production.ProductCategory pc on psc.ProductCategoryID = pc.ProductCategoryID
						where pc.Name = 'Bikes'
						group by p.ProductSubcategoryID
						having sum(ListPrice) > (select ((sum(ListPrice)*60)/100) from Production.Product p 
						join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
						join Production.ProductCategory pc on psc.ProductCategoryID = pc.ProductCategoryID
						where pc.Name = 'Components' or pc.Name = 'Clothing' or pc.Name = 'Accessories'))
commit tran
--4. Thực hiện các backup sau cho CSDL AdventureWorks2008, tất cả backup đều lưu
--vào thiết bị backup vừa tạo
--a. Tạo 1 differential backup
backup database [AdventureWorks2012]
to disk = 'D:\back\adv2012diffbackcau4.bak'
with differential

--b. Tạo 1 transaction log backup
backup log [AdventureWorks2012]
to disk = 'D:\back\adv2012logbackcau4.bak'

--5. (Lưu ý ở bước 7 thì CSDL AdventureWorks2008 sẽ bị xóa. Hãy lên kế hoạch phục
--hồi cơ sở dữ liệu cho các hoạt động trong câu 5, 6).
--Xóa mọi bản ghi trong bảng Person.EmailAddress, tạo 1 transaction log backup
select * from Person.EmailAddress
backup log [AdventureWorks2012]
to disk = 'D:\back\adv2012logbackcau5.bak'

--6. Thực hiện lệnh:
--a. Bổ sung thêm 1 số phone mới cho nhân viên có mã số business là 10000 như
--sau:
INSERT INTO Person.PersonPhone VALUES (10000,'123-456-
7890',1,GETDATE())
--b. Sau đó tạo 1 differential backup cho AdventureWorks2008 và lưu vào thiết bị
--backup vừa tạo.
backup database [AdventureWorks2012]
to disk = 'D:\back\adv2012diffbackcau6.bak'
with differential
--c. Chú ý giờ hệ thống của máy.
--Đợi 1 phút sau, xóa bảng Sales.ShoppingCartItem
drop table Sales.ShoppingCartItem
--7. Xóa CSDL AdventureWorks2008
use master
drop database AdventureWorks2012
--8. Để khôi phục lại CSDL:
--a. Như lúc ban đầu (trước câu 3) thì phải restore thế nào?
restore database AdventureWorks2012
from disk = 'D:\back\adv2012fullback.bak' with norecovery
--b. Ở tình trạng giá xe đạp đã được cập nhật và bảng Person.EmailAddress vẫn
--còn nguyên chưa bị xóa (trước câu 5) thì cần phải restore thế nào?
use AdventureWorks2012
restore database AdventureWorks2012
from disk ='D:\back\adv2012diffbackcau4.bak' with recovery
--c. Đến thời điểm đã được chú ý trong câu 6c thì thực hiện việc restore lại CSDL
--AdventureWorks2008 ra sao?
--9. Thực hiện đoạn lệnh sau:
--CREATE DATABASE Plan2Recover;
--USE Plan2Recover;
--CREATE TABLE T1 (
--Mục tiêu:
--Backup và Recovery cơ sở dữ liệu
--Module 8. Bảo trì cơ sở dữ liệu
--Bài tập Thực hành Hệ Quản Trị Cơ sở Dữ Liệu
---33-
--PK INT Identity PRIMARY KEY,
--Name VARCHAR(15)
-- );
--GO
--INSERT T1 VALUES ('Full');
--GO
--BACKUP DATABASE Plan2Recover
--TO DISK = 'T:\P2R.bak'
--WITH NAME = 'P2R_Full',
--INIT;
--Tiếp tục thực hiện các lệnh sau:
--INSERT T1 VALUES ('Log 1');
--GO
--BACKUP Log Plan2Recover
--TO DISK ='T:\P2R.bak'
--WITH NAME = 'P2R_Log';
--Tiếp tục thực hiện các lệnh sau:
--INSERT T1 VALUES ('Log 2');
--GO
--BACKUP Log Plan2Recover
--TO DISK ='T:\P2R.bak'
--WITH NAME = 'P2R_Log';
--Xóa CSDL vừa tạo, rồi thực hiện quá trình khôi phục như sau:
--Use Master;
--RESTORE DATABASE Plan2Recover
--FROM DISK = 'T:\P2R.bak'
--With FILE = 1, NORECOVERY;
--RESTORE LOG Plan2Recover
--FROM DISK ='T:\P2R.bak'
--With FILE = 2, NORECOVERY;
--RESTORE LOG Plan2Recover
--FROM DISK ='T:\P2R.bak'
--With FILE = 3, RECOVERY;