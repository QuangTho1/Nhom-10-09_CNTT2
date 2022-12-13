--CAU 1---
--tao bang vat tu
Create table  VatTu
(
 MaVT nvarchar(10) not null primary key,
 TenVT nvarchar(50),
 DVTinh char(10),
 SLCon int 
 )
 ---TAO BANG HOA DON
Create table HDBan
(
 MaHD nvarchar(10) not null primary key,
 HoTenKhach nvarchar(20),
 Ngayxuat date,
 )
 --TAO BANG HANG XUAT
Create table Hangxuat
(
 MaHD nvarchar(10)FOREIGN KEY references HDBan(MaHD),
 MaVT nvarchar(10)FOREIGN KEY references VatTu(MaVT),
 DonGia float,
 SLBan int
 )

-- Câu 2
use QLHANG
go
select top 1 MaHD, sum(DonGia)
as TongTien
from HangXuat
group by MaHD, DonGia
order by DonGia desc
go

select * from HangXuat

 --CAU 3--
Create function cau 3(MaHD nvarchar(10))
returns @infoHD table (MaHD nvarchar(10), NgayXuat date, MaVT nvarchar(10),Dongla float ,SLBan int, NgayThu date)
as 
begin 
   insert into @infoHD
     SELECT MaHD, NgayXuat, MaVT 
	 from HDBan
	 inner join HangXuat on HangXuat.MaHD