--BÀI 1*:
--Nhập vào MaNV cho biết tuổi của nhân viên này.
SELECT YEAR (GETDATE())-YEAR(NGSINH) as N'Tuổi' FROM NHANVIEN WHERE MANV = '001'
IF OBJECT_ID('fn_TuoiNV') is not null
	DROP FUNCTION fn_TuoiNV
GO
CREATE FUNCTION fn_TuoiNV (@MaNV nvarchar(9))
returns int
as
begin 
	return(SELECT YEAR (GETDATE())-YEAR(NGSINH) as N'Tuổi' FROM NHANVIEN WHERE MANV= @MaNV)
end
PRINT'Tuoi nhan vien: ' +convert(nvarchar,dbo.fn_TuoiNV('001'))
PRINT'Tuoi nhan vien: ' +convert(nvarchar,dbo.fn_TuoiNV('002'))
PRINT'Tuoi nhan vien: ' +convert(nvarchar,dbo.fn_TuoiNV('003'))

--Nhập vào Manv cho biết số lượng đề án nhân viên này đã tham gia
SELECT Ma_NVien, count (MADA) FROM PHANCONG
GROUP BY Ma_NVien

select count (MADA) FROM PHANCONG WHERE MA_NVIEN = '004'

if OBJECT_ID('fn_DemDeAnNV') is not null 
	drop function fn_DemDeAnNV
go
create function fn_DemDeAnNV(@MaNV nvarchar(9))
returns int
as
	begin
		return(select count (MADA) FROM PHANCONG WHERE MA_NVIEN =@MaNV) 
	end
print'So du an nhan vien da lam' + convert(varchar, dbo.fn_DemDeAnNV('003'))

--Truyền tham số vào phái nam hoặc nữ, xuất số lượng nhân viên theo phái
SELECT * FROM  NHANVIEN
SELECT COUNT(*) FROM NHANVIEN WHERE PHAI LIKE 'Nam'
SELECT COUNT(*) FROM NHANVIEN WHERE PHAI LIKE N'Nữ'

create function fn_DemNV_Phai(@Phai nvarchar(5)= N'%')
returns int
as
	begin
		return(SELECT COUNT(*) FROM NHANVIEN WHERE PHAI LIKE @Phai)
	end

print 'Nhan Vien Nam: '+convert(varchar,fn_DemNV_Phai('Nam'))
print N'Nhan Vien Nữ: '+convert(varchar,fn_DemNV_Phai(N'Nữ'))

/*Truyền tham số đầu vào là tên phòng, tính mức lương trung bình của phòng đó, Cho biết
họ tên nhân viên (HONV, TENLOT, TENNV) có mức lương trên mức lương trung bình
của phòng đó.*/
select PHG, TENPHG, AVG(LUONG) FROM NHANVIEN
INNER JOIN PHONGBAN ON PHONGBAN.MAPHG = NHANVIEN.PHG
GROUP BY PHG, TENPHG

select AVG(LUONG) FROM NHANVIEN
INNER JOIN PHONGBAN ON PHONGBAN.MAPHG = NHANVIEN.PHG
WHERE TENPHG = 'IT'

if OBJECT_ID('fn_Luong_NhanVien_PB') is not null
	drop function fn_Luong_NhanVien_PB

create function fn_Luong_NhanVien_PB(@TenPhongBan nvarchar(20))
returns @tbLuongNV Table (fullname nvarchar(50), LUONG FLOAT)
as
	begin 
		declare @LuongTB float
		select @LuongTB = AVG (LUONG) FROM NHANVIEN
		INNER JOIN PHONGBAN ON PHONGBAN.MAPHG=NHANVIEN.PHG
		WHERE TENPHG = @TenPhongBan
		print 'Luong trung binh'+ convert (nvarchar,@LuongTB)
		insert into @tbLuongNV
			SELECT HONV+' '+TENLOT+' '+TENNV, LUONG FROM NHANVIEN
			WHERE LUONG > @LuongTB
			return
	end

SELECT * FROM  dbo.fn_Luong_NhanVien_PB('IT')

/*Tryền tham số đầu vào là Mã Phòng, cho biết tên phòng ban, họ tên người trưởng phòng
và số lượng đề án mà phòng ban đó chủ trì.*/
select TENPHG, TRPHG ,HONV+' '+TENLOT+' '+TENNV AS 'Ten truong phong',COUNT(MADA) AS 'SoLuongDeAn' FROM PHONGBAN
INNER JOIN DEAN ON DEAN.PHONG = PHONGBAN.MAPHG
INNER JOIN NHANVIEN ON NHANVIEN.MANV = PHONGBAN.TRPHG
WHERE PHONGBAN.MAPHG = '001'
GROUP BY TENPHG,TRPHG,HONV,TENNV,TENLOT

IF OBJECT_ID('fn_SoLuongDeAnTheoPB') IS NOT NULL
	drop function fn_SoLuongDeAnTheoPB
go

create function fn_SoLuongDeAnTheoPB(@MaPB int)
returns @tbListPB table(TenPB nvarchar(20),MaTB nvarchar(10), TenTP nvarchar(50),SoLuong int)
as	
	begin
		insert into @tbListPB
		select TENPHG, TRPHG ,HONV+' '+TENLOT+' '+TENNV AS 'Ten truong phong',COUNT(MADA) AS 'SoLuongDeAn' FROM PHONGBAN
		INNER JOIN DEAN ON DEAN.PHONG = PHONGBAN.MAPHG
		INNER JOIN NHANVIEN ON NHANVIEN.MANV = PHONGBAN.TRPHG
		WHERE PHONGBAN.MAPHG = @MaPB
		GROUP BY TENPHG,TRPHG,HONV,TENNV,TENLOT
		RETURN
	end

select * from db.fn_SoLuongDeAnTheoPB(1)
select TENPHG, TRPHG ,HONV+' '+TENLOT+' '+TENNV AS 'Ten truong phong',COUNT(MADA) AS 'SoLuongDeAn' FROM PHONGBAN
INNER JOIN DEAN ON DEAN.PHONG = PHONGBAN.MAPHG
INNER JOIN NHANVIEN ON NHANVIEN.MANV = PHONGBAN.TRPHG
GROUP BY TENPHG,TRPHG,HONV,TENNV,TENLOT


--BÀI 2:
--Hiển thị thông tin HoNV,TenNV,TenPHG, DiaDiemPhg.
SELECT TENPHG FROM PHONGBAN
INNER JOIN DIADIEM_PHG ON DIADIEM_PHG.MAPHG= PHONGBAN.MAPHG
INNER JOIN NHANVIEN ON NHANVIEN.PHG = PHONGBAN.MAPHG

CREATE VIEW V_DD_PHONGBAN
AS
SELECT HONV,TENNV, TENPHG, DIADIEM_PHG FROM PHONGBAN
INNER JOIN DIADIEM_PHG ON DIADIEM_PHG.MAPHG = PHONGBAN.MAPHG
INNER JOIN NHANVIEN ON NHANVIEN.PHG =PHONGBAN,MAPHG

SELECT * FROM V_DD_PHONGBAN

--Hiển thị thông tin TenNv, Lương, Tuổi.

SELECT TENNV,LUONG,YEAR (GETDATE())-YEAR(NGSINH) AS 'TUOI' FROM NHANVIEN

CREATE VIEW V_TUOINV
AS
SELECT TENNV,LUONG,YEAR (GETDATE())-YEAR(NGSINH) AS 'TUOI' FROM NHANVIEN

SELECT * FROM V_TUOINV

--Hiển thị tên phòng ban và họ tên trưởng phòng của phòng ban có đông nhân viên nhất
SELECT TOP(1) TENPHG,TRPHG,B.HONV,+' '+B.TENLOT+' '+B.TENNV AS 'TENTP',COUNT(A.MANV) AS 'SOLUONGNV' FROM NHANVIEN A
INNER JOIN PHONGBAN ON PHONGBAN.MAPHG = A.PHG
INNER JOIN NHANVIEN B ON B.MANV = PHONGBAN.TRPHG
GROUP BY TRPHG,TENPHG,B.TENNV,B.HONV,B.TENLOT
ORDER BY SOLUONGNV DESC

CREATE VIEW V_TOPSOLUONGNV_PB
AS
SELECT TOP(1) TENPHG,TRPHG,B.HONV,+' '+B.TENLOT+' '+B.TENNV AS 'TENTP',COUNT(A.MANV) AS 'SOLUONGNV' FROM NHANVIEN A
INNER JOIN PHONGBAN ON PHONGBAN.MAPHG = A.PHG
INNER JOIN NHANVIEN B ON B.MANV = PHONGBAN.TRPHG
GROUP BY TRPHG,TENPHG,B.TENNV,B.HONV,B.TENLOT
ORDER BY SOLUONGNV DESC

SELECT * FROM V_TOPSOLUONGNV_PB

 
