--Ràng buộc khi thêm mới nhân viên thì mức lương phải lớn hơn 15000, nếu vi phạm thì
--xuất thông báo “luong phải >15000’
create trigger trg_insert_NHANVIEN on NHANVIEN
for insert 
as
	if(select luong from inserted)<15000
	begin
	print 'luong lon hon 15000'
	rollback transaction
	end

insert into NHANVIEN values ('a','b','c','019','01-09-1910','275BD','nam',14000,'005',1)
select * from NHANVIEN

--Ràng buộc khi thêm mới nhân viên thì độ tuổi phải nằm trong khoảng 18 <= tuổi <=65.
create trigger trg_insert_NHANVIEN2 on NHANVIEN
for insert
as
	declare @tuoi int
	set @tuoi = year(getdate())-(select year(NGSINH) FROM INSERTED)
	IF(@tuoi < 18 or @tuoi >65)
	begin
	print 'khong hop le'
	rollback transaction
	end


--Ràng buộc khi cập nhật nhân viên thì không được cập nhật những nhân viên ở TP HCM
create trigger trg_update_NHANVIEN on NHANVIEN
for update
as
	if(select dchi from inserted) like '%TP HCM'
	begin 
	print ' dia chi cap nhật không hợp lệ'
	rollback transaction
end

update NHANVIEN set  HONV= 'nguyen'
where MANV ='018'
select * from NHANVIEN

--Hiển thị tổng số lượng nhân viên nữ, tổng số lượng nhân viên nam mỗi khi có hành động
--thêm mới nhân viên.
create trigger trg_insert_NHANVIEN2a on NHANVIEN
after insert
as
	begin 
	select count(case when upper (PHAI)=N'NAM' then 1 end) Nam,
	count(case when upper(PHAI)=N'Nữ' then 1 end)Nữ
	from NHANVIEN
end

insert into NHANVIEN values ('a','b','c','021','01-09-1975','275BD','nam',16000,'005',1)
select * from NHANVIEN

--Hiển thị tổng số lượng đề án mà mỗi nhân viên đã làm khi có hành động xóa trên bảng
--DEAN
create trigger trg_insert_DEAN on DEAN
after delete
as
	begin 
	select ma_nvien, count (MADA) as ' so luong du an' from PHANCONG group by MA_NVIEN
	end

	select * from PHANCONG
	select * from DEAN
	insert into DEAN values ('SQL Server', 40,'BD',4)
	delete from DEAN where MADA=40

--Xóa các thân nhân trong bảng thân nhân có liên quan khi thực hiện hành động xóa nhân
--viên trong bảng nhân viên.
create trigger trg_delete_thanhnhan_NV on NHANVIEN
instead of delete
as
	begin
		delete from THANNHAN where MA_NVIEN in(select MANV from deleted)
		delete from NHANVIEN where MANV in (select MANV from deleted)
	end
select * from NHANVIEN
select * from THANNHAN
select * from PHANCONG
insert into THANNHAN values ('020','tien','nam','03-23-2009','con')
delete from NHANVIEN where MANV ='020'

--Khi thêm một nhân viên mới thì tự động phân công cho nhân viên làm đề án có MADA
--là 1.
create trigger trg_insert_NHANVIEN3b on NHANVIEN
after insert 
as
	begin
	insert into PHANCONG values ((select MANV from inderted),1,1,30)


	end
	insert into NHANVIEN values ('a','b','c','022','01-09-1975','275BD','nam',16000,'005',1)
select * from NHANVIEN
select * from PHANCONG

--VIẾT TRIGGER ĐẾM SỐ LƯỢNG NHÂN VIÊN BỊ XÓA KHI THỰC HIỆN XÓA CÁC NHÂN VIÊN Ở TPHCM.
--XÓA NHÂN THÂN LIÊN QUAN ĐẾN NHÂN VIÊN , NHÂN VIÊN BỊ XÓA THEO
