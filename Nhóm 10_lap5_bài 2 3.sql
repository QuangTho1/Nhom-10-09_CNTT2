--Nh?p v�o @Manv, xu?t th�ng tin c�c nh�n vi�n theo @Manv.
 create proc Bai2_1
  @MaNV varchar(3) 
  as
  begin
	select * 
	from NHANVIEN
	where MANV = @MaNV
  end

exec Bai2_1 '003'

--Nh?p v�o @MaDa (m� ?? �n), cho bi?t s? l??ng nh�n vi�n tham gia ?? �n ?�
create proc Bai2_2 
	@manv int
as
begin
	select COUNT(MANV) as 'So luong', MADA, TENPHG	
	from NHANVIEN inner join PHONGBAN on NHANVIEN.PHG = PHONGBAN.MAPHG
				  inner join DEAN on DEAN.PHONG = NHANVIEN.PHG
	where MADA=@manv
	GROUP BY TENPHG, MADA
end

exec Bai2_2 20

--Nh?p v�o @MaDa v� @Ddiem_DA (??a ?i?m ?? �n), cho bi?t s? l??ng nh�n vi�n tham gia ?? �n c� m� ?? �n l� @MaDa v� ??a ?i?m ?? �n l� @Ddiem_DA

alter proc Bai2_3 
	@manv int, @Ddiem_DA nvarchar(15)
as
begin 
	select COUNT(MANV) as 'So luong', MADA, TENPHG, DDIEM_DA	
	from NHANVIEN inner join PHONGBAN on NHANVIEN.PHG = PHONGBAN.MAPHG
				  inner join DEAN on DEAN.PHONG = NHANVIEN.PHG
	where MADA=@manv and DDIEM_DA = @Ddiem_DA
	GROUP BY TENPHG, MADA, DDIEM_DA
end

exec Bai2_3 '002', 'Nha Trang'

--Nh?p v�o @Trphg (m� tr??ng ph�ng), xu?t th�ng tin c�c nh�n vi�n c� tr??ng ph�ng l� @Trphg v� c�c nh�n vi�n n�y kh�ng c� th�n nh�n.
create proc Bai2_4 
	@MaTP varchar(5)
as
begin
	select HONV, TENNV, TENPHG, NHANVIEN.MANV, THANNHAN.*
	from NHANVIEN inner join PHONGBAN on PHONGBAN.MAPHG = NHANVIEN.PHG
				  left outer join THANNHAN on THANNHAN.MA_NVIEN = NHANVIEN.MANV
	where THANNHAN.MA_NVIEN is null and TRPHG = @MaTP
end

exec Bai2_4 '008'

--Nh?p v�o @Manv v� @Mapb, ki?m tra nh�n vi�n c� m� @Manv c� thu?c ph�ng ban c� m� @Mapb hay kh�ng
create proc Bai2_5
	@MaNV varchar(5), @MaPB varchar(5)
as
begin
	if exists(select * from NHANVIEN where MANV = @MaNV and PHG = @MaPB)
		print 'Nhan Vien: ' + @MaNV+' co trong phong ban: ' + @MaPB
	else
		print 'Nhan Vien: ' + @MaNV+' khong co trong phong ban ' + @MaPB
end

exec Bai2_5 '004 ','1'
--Th�m ph�ng ban c� t�n CNTT v�o csdl QLDA, c�c gi� tr? ???c th�m v�o d??i d?ng tham s? ??u v�o, ki?m tra n?u tr�ng Maphg th� th�ng b�o th�m th?t b?i.
update PHONGBAN set TENPHG = 'IT', TRPHG = '008', NG_NHANCHUC = '2020-12-12'
where MAPHG = '7'
CREATE PROC sp_InsertPB
	@MaPB int, @TenPB nvarchar(15),
	@MaTP nvarchar(9), @NgayNhanChuc date
AS
BEGIN
	if(exists(select * from PHONGBAN where MAPHG = @MaPB ))
		print 'Them that bai'
	else 
		begin
			insert into PHONGBAN(MAPHG, TENPHG, TRPHG, NG_NHANCHUC)
			values(@MaPB, @TenPB,@MaTP,@NgayNhanChuc)
			print 'Them thanh cong'
		end
END

exec sp_InsertPB '8', 'CNTT', '008', '2020-10-06'

--C?p nh?t ph�ng ban c� t�n CNTT th�nh ph�ng IT.

CREATE PROC sp_UpdatePB
	@MaPB int, @TenPB nvarchar(15),
	@MaTP nvarchar(9), @NgayNhanChuc date
AS
BEGIN
	if(exists(select * from PHONGBAN where MAPHG = @MaPB ))
		update PHONGBAN set TENPHG = @TenPB, TRPHG = @MaTP, NG_NHANCHUC = @NgayNhanChuc
		where MAPHG = @MaPB
	else 
		begin
			insert into PHONGBAN(MAPHG, TENPHG, TRPHG, NG_NHANCHUC)
			values(@MaPB, @TenPB,@MaTP,@NgayNhanChuc)
			print 'Them thanh cong'
		end
END

exec sp_UpdatePB '8', 'IT', '008', '2020-10-06'

--Th�m m?t nh�n vi�n v�o b?ng NhanVien, t?t c? gi� tr? ??u truy?n d??i d?ng tham s? ??u v�o v?i ?i?u ki?n:
--o nh�n vi�n n�y tr?c thu?c ph�ng IT
--o Nh?n @luong l�m tham s? ??u v�o cho c?t Luong, n?u @luong<25000 th� nh�n vi�n n�y do nh�n vi�n c� m� 009 qu?n l�, ng??c l?i do nh�n vi�n c� m� 005 qu?n l�
--o N?u l� nh�n vi�n nam thi nh�n vi�n ph?i n?m trong ?? tu?i 18-65, n?u l� nh�n vi�n n? th� ?? tu?i ph?i t? 18-60.

create proc sp_InsertNhanVien
	@HONV nvarchar(15), @TENLOT nvarchar(15), @TENNV nvarchar(15),
	@MANV nvarchar(6), @NGSINH date, @DCHI nvarchar(50), @PHAI nvarchar(3),
	@LUONG float, @MA_NQL nvarchar(3) = null, @PHG int
as
begin
	declare @age int 
	set @age = YEAR(GETDATE()) - YEAR (@NGSINH)
	if @PHG = (select MAPHG from PHONGBAN where TENPHG = 'IT')
		begin
			if @LUONG < 25000
				set @MA_NQL = '009'
			else set @MA_NQL = '005'

			if (@PHAI = 'Nam' and (@age >= 18 and @age <= 65))
				or (@PHAI = 'Nu' and (@age >= 18 and @age <= 60))
				begin
					insert into NHANVIEN(HONV, TENLOT, TENNV, MANV, NGSINH, DCHI, PHAI, LUONG, MA_NQL, PHG)
					values (@HONV, @TENLOT, @TENNV, @MANV, @NGSINH, @DCHI, @PHAI, @LUONG, @MA_NQL, @PHG)
				end
			else 
				print 'Khong thuoc do tuoi lao dong'
		end
	else 
		print 'Khong phai Phong Ban IT'
end

exec sp_InsertNhanVien 'Nguyen', 'Van', 'Nam', '008', '2020-06-10', 'Da Nang', 'Nam', '25000', '004', '8'
exec sp_InsertNhanVien 'Nguyen', 'Van', 'Nam', '006', '2020-06-10', 'Da Nang', 'Nam', '25000', '004', '8'
exec sp_InsertNhanVien 'Nguyen', 'Van', 'Nu', '005', '1954-06-10', 'Da Nang', 'Nam', '25000', '004', '8'