--Nh?p vào @Manv, xu?t thông tin các nhân viên theo @Manv.
 create proc Bai2_1
  @MaNV varchar(3) 
  as
  begin
	select * 
	from NHANVIEN
	where MANV = @MaNV
  end

exec Bai2_1 '003'

--Nh?p vào @MaDa (mã ?? án), cho bi?t s? l??ng nhân viên tham gia ?? án ?ó
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

--Nh?p vào @MaDa và @Ddiem_DA (??a ?i?m ?? án), cho bi?t s? l??ng nhân viên tham gia ?? án có mã ?? án là @MaDa và ??a ?i?m ?? án là @Ddiem_DA

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

--Nh?p vào @Trphg (mã tr??ng phòng), xu?t thông tin các nhân viên có tr??ng phòng là @Trphg và các nhân viên này không có thân nhân.
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

--Nh?p vào @Manv và @Mapb, ki?m tra nhân viên có mã @Manv có thu?c phòng ban có mã @Mapb hay không
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
--Thêm phòng ban có tên CNTT vào csdl QLDA, các giá tr? ???c thêm vào d??i d?ng tham s? ??u vào, ki?m tra n?u trùng Maphg thì thông báo thêm th?t b?i.
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

--C?p nh?t phòng ban có tên CNTT thành phòng IT.

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

--Thêm m?t nhân viên vào b?ng NhanVien, t?t c? giá tr? ??u truy?n d??i d?ng tham s? ??u vào v?i ?i?u ki?n:
--o nhân viên này tr?c thu?c phòng IT
--o Nh?n @luong làm tham s? ??u vào cho c?t Luong, n?u @luong<25000 thì nhân viên này do nhân viên có mã 009 qu?n lý, ng??c l?i do nhân viên có mã 005 qu?n lý
--o N?u là nhân viên nam thi nhân viên ph?i n?m trong ?? tu?i 18-65, n?u là nhân viên n? thì ?? tu?i ph?i t? 18-60.

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