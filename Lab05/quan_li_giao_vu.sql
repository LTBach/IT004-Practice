use master
drop database if exists quan_li_giao_vu
create database quan_li_giao_vu

use quan_li_giao_vu



drop table if exists HOCVIEN 
create table HOCVIEN (
	MAHV CHAR(5) not null,
	-- HO VA TEN LOT
	HO VARCHAR(40) not null,
	TEN VARCHAR(10) not null,
	NGSINH SMALLDATETIME not null,
	GIOITINH VARCHAR(3) not null,
	NOISINH VARCHAR(40) not null,
	MALOP CHAR(3) not null,
	PRIMARY KEY(MAHV),
)

drop table if exists LOP 
create table LOP (
	MALOP CHAR(3) not null,
	TENLOP VARCHAR(40) not null,
	TRGLOP CHAR(5) not null,
	SISO TINYINT not null,
	MAGVCN CHAR(4) not null,
	PRIMARY KEY(MALOP),
)

drop table if exists KHOA
create table KHOA (
	MAKHOA VARCHAR(4) not null,
	TENKHOA VARCHAR(40) not null,
	NGTLAP SMALLDATETIME not null,
	TRGKHOA CHAR(4),
	PRIMARY KEY(MAKHOA),
)

drop table if exists MONHOC 
create table MONHOC (
	MAMH VARCHAR(10) not null,
	TENMH VARCHAR(40) not null,
	-- Tin chi li thuyet
	TCLT TINYINT not null,
	-- Tin chi thuc hanh
	TCTH TINYINT not null,
	MAKHOA VARCHAR(4) not null,
	PRIMARY KEY(MAMH),
	-- FOREIGN KEY(MAKHOA) references KHOA(MAKHOA),
)

drop table if exists DIEUKIEN 
create table DIEUKIEN (
	MAMH VARCHAR(10) not null,
	MAMH_TRUOC VARCHAR(10) not null,
	PRIMARY KEY(MAMH, MAMH_TRUOC),
	-- FOREIGN KEY (MAMH) references MONHOC(MAMH) ,
	-- FOREIGN KEY (MAMH_TRUOC) references MONHOC(MAMH),
)

drop table if exists GIAOVIEN 
create table GIAOVIEN (
	MAGV CHAR(4) not null,
	HOTEN VARCHAR(40) not null,
	HOCVI VARCHAR(10) not null,
	HOCHAM VARCHAR(10) not null,
	GIOITINH VARCHAR(3) not null,
	NGSINH SMALLDATETIME not null,
	NGVL SMALLDATETIME not null,
	HESO NUMERIC(4,2) not null,
	MUCLUONG MONEY not null,
	MAKHOA VARCHAR(4) not null,
	PRIMARY KEY(MAGV),
)

drop table if exists GIANGDAY 
create table GIANGDAY (
	MALOP CHAR(3) not null,
	MAMH VARCHAR(10) not null,
	MAGV CHAR(4) not null,
	HOCKY TINYINT not null,
	NAM SMALLINT not null,
	TUNGAY SMALLDATETIME not null,
	DENNGAY SMALLDATETIME not null,
	PRIMARY KEY(MALOP, MAMH),
)

drop table if exists KETQUATHI 
create table KETQUATHI (
	MAHV CHAR(5) not null,
	MAMH VARCHAR(10) not null,
	LANTHI TINYINT not null,
	NGTHI SMALLDATETIME not null,
	DIEM NUMERIC(4,2) not null,
	KQUA VARCHAR(10) not null,
	PRIMARY KEY(MAHV, MAMH, LANTHI),
)


-- Add Foreign key

ALTER TABLE HOCVIEN
ADD CONSTRAINT fk_hocvien 
foreign key(MALOP) references LOP(MALOP)

ALTER TABLE LOP
ADD CONSTRAINT fk_lop_gv
foreign key(MAGVCN) references GIAOVIEN(MAGV),
CONSTRAINT fk_lop_hv
foreign key(TRGLOP) references HOCVIEN(MAHV)

ALTER TABLE KHOA
ADD CONSTRAINT fk_khoa
foreign key(TRGKHOA) references GIAOVIEN(MAGV)

ALTER TABLE MONHOC
ADD CONSTRAINT fk_monhoc
foreign key(MAKHOA) references KHOA(MAKHOA)

ALTER TABLE DIEUKIEN
ADD CONSTRAINT fk_dieukien_mh
foreign key(MAMH) references MONHOC(MAMH),
CONSTRAINT fk_dieukien_mht
foreign key(MAMH_TRUOC) references MONHOC(MAMH)

ALTER TABLE GIAOVIEN
ADD CONSTRAINT fk_giaovien
foreign key(MAKHOA) references KHOA(MAKHOA)

ALTER TABLE GIANGDAY
ADD CONSTRAINT fk_giangday_lop
foreign key(MALOP) references LOP(MALOP),
CONSTRAINT fk_giangday_mh
foreign key(MAMH) references MONHOC(MAMH),
CONSTRAINT fk_giangday_gv
foreign key(MAGV) references GIAOVIEN(MAGV)

ALTER TABLE KETQUATHI 
ADD CONSTRAINT fk_ketquathi_hv
foreign key(MAHV) references HOCVIEN(MAHV),
CONSTRAINT fk_ketquathi_mh
foreign key(MAMH) references MONHOC(MAMH)


-- 1. Tao quan he va khai bao tat ca cac rang buoc khoa chinh, khoa ngoai.
-- Them vao 3 thuoc tinh GHICHU, DIEMTB, XEPLOAI cho quan he HOCVIEN.
ALTER TABLE HOCVIEN
ADD 
GHICHU VARCHAR(100),
DIEMTB NUMERIC(4,2),
XEPLOAI VARCHAR(10)

-- 2. Ma hoc vien la mot chuoi 5 ky tu 3 ky tu dau la ma lop, 2 ky tu cuoi cung la so thu tu hoc vien trong lop. VD: “K1101”
--ALTER TABLE HOCVIEN
--ADD CONSTRAINT check_hocvien_mahv 
--CHECK(LEN(MAHV) = 5 AND LEFT(MAHV, 3) = MALOP)

-- 3. Thuoc tinh gioi tinh chi co the la Nam hoac Nu
ALTER TABLE GIAOVIEN
ADD CONSTRAINT check_giaovien_gioitinh
CHECK (GIOITINH in ('Nam', 'Nu'))

ALTER TABLE HOCVIEN
ADD CONSTRAINT check_hocvien_gioitinh
CHECK (GIOITINH in ('Nam', 'Nu'))

-- 4. Diem thi phai tu 0 den 10 va can luu den 2 chu so le
ALTER TABLE KETQUATHI
ADD CONSTRAINT check_ketquathi_diem
CHECK (DIEM <= 10 AND DIEM >= 0 AND LEFT(RIGHT(CAST(DIEM as VARCHAR),3),1)='.')

-- 5. Ket qua thi la Dat neu tu 5 den 10, nguoc lai la khong dat
-- * Hoc vien thi tu lan 2 thi diem tren 6 moi co ket qua la Dat
ALTER TABLE KETQUATHI
ADD CONSTRAINT check_ketquathi_kqua
CHECK ((KQUA = 'Dat' AND DIEM >= 5) OR (KQUA = 'Khong dat' AND DIEM < 5))
--CHECK ((KQUA = 'Dat' AND ((LANTHI = 1 AND DIEM >= 5) OR DIEM > 6))
--		OR 
--	   (KQUA = 'Khong dat' AND ((LANTHI > 1 AND DIEM <= 6) OR (DIEM < 5)) ) )

-- 6. Hoc vien thi mot mon toi da 3 lan
ALTER TABLE KETQUATHI
ADD CONSTRAINT check_ketquathi_lanthi
CHECK (LANTHI <= 3)

-- 7. Hoc ky chi co gia tri tu 1 den 3
ALTER TABLE GIANGDAY
ADD CONSTRAINT check_giangday_hocky
CHECK (HOCKY <= 3 AND HOCKY >= 1)

-- 8. Hoc vi cua giao vien chi co the la 'CN', 'KS', 'Ths', 'TS', 'PTS'
ALTER TABLE GIAOVIEN
ADD CONSTRAINT check_giaovien_hocvi
CHECK (HOCVI in ('CN', 'KS', 'Ths', 'TS', 'PTS'))

-- 9. Lop truong phai la hoc vien cua lop do
CREATE TRIGGER TRG_LOPTRUONG_LOP
ON LOP
AFTER INSERT, UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED 
			WHERE INSERTED.TRGLOP IS NOT NULL AND INSERTED.TRGLOP NOT IN (
				SELECT MAHV 
				FROM HOCVIEN 
				WHERE HOCVIEN.MALOP = INSERTED.MALOP
			)
		)
	)
	BEGIN
		PRINT 'ERROR: TRUONG LOP KHONG THUOC LOP'
		ROLLBACK TRAN
	END
END

CREATE TRIGGER TRG_LOPTRUONG_HOCVIEN
ON HOCVIEN
AFTER UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED 
			WHERE INSERTED.MAHV IN (
				SELECT TRGLOP 
				FROM LOP
				WHERE INSERTED.MALOP != LOP.MALOP
			)
		)
	)
	BEGIN
		PRINT 'ERROR: TRUONG LOP KHONG THUOC LOP'
		ROLLBACK TRAN
	END
END

-- 10. Truong khoa phai la giao vien thuoc khoa co hoc vi 'TS' hoac 'PGS'
CREATE TRIGGER TRG_TRUONGKHOA_HOCVI
ON KHOA
AFTER INSERT, UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED
			JOIN GIAOVIEN ON INSERTED.TRGKHOA = GIAOVIEN.MAGV
			WHERE (GIAOVIEN.HOCVI != 'TS' AND GIAOVIEN.HOCHAM != 'PGS') OR
				INSERTED.TRGKHOA NOT IN (
					SELECT GIAOVIEN.MAGV FROM GIAOVIEN AS GV2 WHERE GV2.MAKHOA = INSERTED.MAKHOA
				)
		)
	)
	BEGIN
		PRINT 'ERROR: TRUONG KHOA PHAI NAM TRONG KHOA VA LA TS HOAC PGS'
		ROLLBACK TRAN
	END
END

CREATE TRIGGER TRG_TRUONGKHOA_GIAOVIEN
ON GIAOVIEN
AFTER UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED
			WHERE INSERTED.MAGV IN (
				SELECT KHOA.TRGKHOA
				FROM KHOA
				JOIN GIAOVIEN ON KHOA.TRGKHOA = GIAOVIEN.MAGV
				WHERE (GIAOVIEN.HOCHAM != 'PGS' AND GIAOVIEN.HOCVI != 'TS') OR KHOA.MAKHOA != INSERTED.MAKHOA
			)
		)
	)
	BEGIN
		PRINT 'ERROR: TRUONG KHOA PHAI NAM TRONG KHOA VA LA TS HOAC PGS'
		ROLLBACK TRAN
	END
END


-- 11. Hoc vien it nhat phai 18 tuoi
ALTER TABLE HOCVIEN 
ADD CONSTRAINT check_tuoi
CHECK (DATEDIFF(DAY, NGSINH, GETDATE()) / 365.25 >= 18)

-- 12. Giang day mot mon hoc ngay bat dau (TUNGAY) phai nho hon ngay ket thuc (DENNGAY).
ALTER TABLE GIANGDAY 
ADD CONSTRAINT check_ngayday
CHECK (TUNGAY < DENNGAY)

-- 13. Giao kvien khi vao lam it nhat la 22 tuoi
ALTER TABLE GIAOVIEN 
ADD CONSTRAINT check_tuoi_gv
CHECK (DATEDIFF(DAY, NGSINH, NGVL) /365.25 >= 22)

-- 14. Tat ca cac mon hoc deu co so tin chi ly thuyet va tin chi thuc hanh chenh lech nhau khong qua 3.
ALTER TABLE MONHOC 
ADD CONSTRAINT check_tin_chi 
CHECK (ABS(TCLT - TCTH) <= 3)

-- 15. Hoc vien chi duoc thi mot mon hoc nao do khi lop cua hoc vien da hoc xong mon hoc nay.
create trigger TRG_NGAYTHI_KQTHI 
on KETQUATHI
after insert, update
as begin
	if (
		exists (
			select * 
			from INSERTED 
			JOIN HOCVIEN ON INSERTED.MAHV = HOCVIEN.MAHV
			where NGTHI < (
					select DENNGAY 
					from GIANGDAY 
					where GIANGDAY.MAMH = INSERTED.MAMH and GIANGDAY.MALOP = HOCVIEN.MALOP
				)
		)
	)
	begin
		print 'ERROR: NGAY THI KHONG HOP LE'
		rollback tran
	end	
end
create trigger TRG_NGAYTHI_GIANGDAY
ON GIANGDAY
after update
as 
begin
	if (
		exists (
			select * 
			from INSERTED
				where exists (
					select * from KETQUATHI
					where MAMH = INSERTED.MAMH 
						AND INSERTED.MALOP = (SELECT MALOP FROM HOCVIEN WHERE HOCVIEN.MAHV = KETQUATHI.MAHV)
						AND NGTHI < INSERTED.DENNGAY
				)
		)
	)
	begin
		print 'NGAY THI KHONG HOP LE'
		rollback tran
	end
end
create trigger TRG_NGAYTHI_HOCVIEN
on HOCVIEN
after update
as 
begin
	if (
		exists(
			select * from INSERTED
			where exists (
				select * from KETQUATHI
				where KETQUATHI.MAHV = INSERTED.MAHV 
					and KETQUATHI.NGTHI < (
							select DENNGAY from GIANGDAY
							where GIANGDAY.MALOP = INSERTED.MALOP 
								and GIANGDAY.MAMH = KETQUATHI.MAMH)
					)
			)
	)
	begin
		print 'ERROR: LOP CHUA HOAN THANH MON HOC'
		rollback tran
	end
end
-- 16. Moi hoc ky cua mot nam hoc, mot lop chi duoc hoc toi da 3 mon.
CREATE TRIGGER TRG_MONHOCTOIDA
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * 
			FROM INSERTED
			WHERE MALOP IN (
				SELECT MALOP
				FROM GIANGDAY
				WHERE GIANGDAY.MALOP = INSERTED.MALOP
				GROUP BY MALOP, NAM
				HAVING COUNT(*) > 3
			)
		)
	)
	BEGIN
		PRINT 'ERROR: MOT NAM CHI CO TOI DA 3 LOP'
		ROLLBACK TRAN
	END
END

-- 17. Si so cua mot lop bang voi so luong hoc vien thuoc lop do.
CREATE TRIGGER TRG_SISI_LOP_INSERT
ON LOP
AFTER INSERT
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED
			WHERE SISO > 0
		)
	)
	BEGIN
		PRINT 'LOP VUA THEM PHAI CO 0 SINH VIEN'
		ROLLBACK TRAN
	END
END
CREATE TRIGGER TRG_SISO_LOP_UPDATE
ON LOP
AFTER UPDATE
AS
BEGIN
	IF (UPDATE(SISO))
	BEGIN
		PRINT 'KHONG DUOC UPDATE SISO'
		ROLLBACK TRAN
	END
END

CREATE TRIGGER TRG_SISO_HOCVIEN
ON HOCVIEN
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	UPDATE LOP
	SET SISO = SISO + TEMP.SLHOCVIEN
	FROM LOP 
	JOIN (
		SELECT LOP.MALOP, COUNT(*) AS SLHOCVIEN
		FROM INSERTED 
		JOIN LOP ON LOP.MALOP = INSERTED.MALOP
		GROUP BY LOP.MALOP
	) AS TEMP ON TEMP.MALOP = LOP.MALOP

	UPDATE LOP
	SET SISO = SISO + TEMP.SLHOCVIEN
	FROM LOP 
	JOIN (
		SELECT LOP.MALOP, COUNT(*) AS SLHOCVIEN
		FROM INSERTED 
		JOIN LOP ON LOP.MALOP = INSERTED.MALOP
		GROUP BY LOP.MALOP
	) AS TEMP ON TEMP.MALOP = LOP.MALOP
END
-- 18. Trong quan he DIEUKIEN gia tri cua thuoc tinh MAMH va MAMH_TRUOC trong cung mot bo khong duoc giong nhau (“A”,”A”) va cung khong ton tai hai bo (“A”,”B”) va (“B”,”A”).
CREATE TRIGGER TRG_DIEUKIEN
ON DIEUKIEN
AFTER INSERT, UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED
			WHERE MAMH = MAMH_TRUOC OR EXISTS (
				SELECT * FROM DIEUKIEN
				WHERE DIEUKIEN.MAMH = INSERTED.MAMH_TRUOC AND DIEUKIEN.MAMH_TRUOC = INSERTED.MAMH
			)
		)
	)
	BEGIN
		PRINT 'LOI KHI THEM DIEU KIEN'
		ROLLBACK TRAN
	END
END

-- 19. Cac giao vien co cung hoc vi, hoc ham, he so luong thi muc luong bang nhau.
CREATE TRIGGER TRG_HOCVIHOCHAM_MUCLUONG
ON GIAOVIEN
AFTER INSERT, UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED
			WHERE EXISTS (
				SELECT * FROM GIAOVIEN
				WHERE GIAOVIEN.MAGV != INSERTED.MAGV
					AND GIAOVIEN.HOCHAM = INSERTED.HOCHAM
					AND GIAOVIEN.HOCVI = INSERTED.HOCVI
					AND GIAOVIEN.HESO = INSERTED.HESO
					AND GIAOVIEN.MUCLUONG != INSERTED.MUCLUONG
			)
		)
	)
	BEGIN
		PRINT 'ERROR: CO 2 GV CO CUNG HOCHAM, HOCVI, HESO NHUNG MUCLUONG KHAC NHAU'
		ROLLBACK TRAN
	END
END
-- 20. Hoc vien chi duoc thi lai (lan thi >1) khi diem cua lan thi truoc do duoi 5.
CREATE TRIGGER TRG_THILAI_KQTHI
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED
			WHERE INSERTED.LANTHI > 1 AND EXISTS (
				SELECT * FROM KETQUATHI
				WHERE KETQUATHI.MAHV = INSERTED.MAHV
					AND KETQUATHI.MAMH = INSERTED.MAMH
					AND KETQUATHI.LANTHI = INSERTED.LANTHI - 1
					AND KETQUATHI.DIEM >= 5
			)
		)
	)
	BEGIN
		PRINT 'LAN THI TRUOC PHAI CO DIEM < 5'
		ROLLBACK TRAN
	END
END

-- 21. Ngay thi cua lan thi sau phai lon hon ngay thi cua lan thi truoc (cung hoc vien, cung mon hoc).
CREATE TRIGGER TRG_NGAYTHI
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED 
			WHERE EXISTS (
				SELECT * FROM KETQUATHI
				WHERE
					KETQUATHI.MAHV = INSERTED.MAHV AND
					KETQUATHI.MAMH = INSERTED.MAMH AND
					((KETQUATHI.LANTHI < INSERTED.LANTHI AND
					KETQUATHI.NGTHI > INSERTED.NGTHI) OR
					(KETQUATHI.LANTHI > INSERTED.LANTHI AND
					KETQUATHI.NGTHI < INSERTED.NGTHI))
			)
		)
	)
	BEGIN
		PRINT 'LAN THI SAU PHAI THI SAU LAN THI TRUOC'
		ROLLBACK TRAN
	END
END

-- 22. Hoc vien chi duoc thi nhung mon ma lop cua hoc vien do da hoc xong.

-- 23. Khi phan cong giang day mot mon hoc, phai xet den thu tu truoc sau giua cac mon hoc 
-- (sau khi hoc xong nhung mon hoc phai hoc truoc moi duoc hoc nhung mon lien sau).
CREATE TRIGGER TRG_PCGIANGDAY_GIANGDAY_INSUPD
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED
			WHERE EXISTS (
				SELECT * FROM GIANGDAY
				WHERE GIANGDAY.MALOP = INSERTED.MALOP AND GIANGDAY.TUNGAY < INSERTED.DENNGAY AND EXISTS (
					SELECT * FROM DIEUKIEN
						WHERE GIANGDAY.MAMH = DIEUKIEN.MAMH AND INSERTED.MAMH = DIEUKIEN.MAMH_TRUOC
				)
			)
			OR EXISTS (
				SELECT * FROM GIANGDAY
				WHERE GIANGDAY.MALOP = INSERTED.MALOP AND GIANGDAY.DENNGAY > INSERTED.TUNGAY AND EXISTS (
					SELECT * FROM DIEUKIEN
						WHERE INSERTED.MAMH = DIEUKIEN.MAMH AND GIANGDAY.MAMH = DIEUKIEN.MAMH_TRUOC
				)
			)
		)
	)
	BEGIN
		PRINT 'MON HOC TRUOC PHAI DUOC HOAN THANH TRUOC'
		ROLLBACK TRAN
	END
END
CREATE TRIGGER TRG_PCGIANGDAY_GIANGDAY_DEL 
ON GIANGDAY
AFTER DELETE
AS
BEGIN
	IF exists(
		SELECT * FROM DELETED
		where exists(
			select * from DIEUKIEN 
			where DIEUKIEN.MAMH_TRUOC = DELETED.MAMH AND EXISTS (
				SELECT * FROM GIANGDAY
				WHERE MALOP = DELETED.MALOP AND GIANGDAY.MAMH = DIEUKIEN.MAMH AND NOT EXISTS (
					SELECT * FROM GIANGDAY AS GD2
						WHERE GD2.MALOP = DELETED.MALOP
							AND GD2.MAMH = DIEUKIEN.MAMH_TRUOC
							AND GD2.DENNGAY < GIANGDAY.TUNGAY
				)
			)
		)
	)
	begin
		print 'ERROR: MON HOC TRUOC PHAI HOC TRUOC MON HOC SAU'
		rollback tran
	end
end
CREATE TRIGGER TRG_PCGIANGDAY_DIEUKIEN
ON DIEUKIEN
AFTER INSERT, UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED
			WHERE EXISTS (
				SELECT * FROM GIANGDAY
				WHERE GIANGDAY.MAMH = INSERTED.MAMH AND NOT EXISTS (
					SELECT * FROM GIANGDAY AS GD2
					WHERE GIANGDAY.MALOP = GD2.MALOP AND GD2.MAMH = INSERTED.MAMH_TRUOC
						AND GIANGDAY.TUNGAY > GD2.DENNGAY
				)
			)
		)
	)
	BEGIN
		PRINT 'ERROR: MON HOC TRUOC PHAI HOC TRUOC MON HOC SAU'
		ROLLBACK TRAN
	END
END
-- 24. Giao vien chi duoc phan cong day nhung mon thuoc khoa giao vien do phu trach.
CREATE TRIGGER TRG_MONHOCKHOA_GIANGDAY
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
	IF exists(
		SELECT * FROM INSERTED 
		WHERE (SELECT MAKHOA FROM GIAOVIEN WHERE GIAOVIEN.MAGV = INSERTED.MAGV) !=
				(SELECT MAKHOA FROM MONHOC WHERE MONHOC.MAMH = INSERTED.MAMH)
	)
	BEGIN
		PRINT 'ERROR: MON HOC KHONG THUOC KHOA GV PHU TRACH'
		ROLLBACK TRAN
	END
END
CREATE TRIGGER TRG_MONHOCKHOA_GIAOVIEN
ON GIAOVIEN
AFTER UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED
			WHERE EXISTS (
				SELECT * FROM GIANGDAY
				WHERE GIANGDAY.MAGV = INSERTED.MAGV 
					AND (SELECT MAKHOA FROM MONHOC WHERE MONHOC.MAMH = GIANGDAY.MAMH) != INSERTED.MAKHOA
			)
		)
	)
	BEGIN
		PRINT 'ERROR: MON HOC KHONG THUOC KHOA GV PHU TRACH'
		ROLLBACK TRAN
	END
END
CREATE TRIGGER TRG_MONHOCKHOA_MONHOC
ON MONHOC
AFTER INSERT, UPDATE
AS
BEGIN
	IF (
		EXISTS (
			SELECT * FROM INSERTED
			WHERE EXISTS (
				SELECT * FROM GIANGDAY
				WHERE GIANGDAY.MAMH = INSERTED.MAMH AND
					(SELECT MAKHOA FROM GIAOVIEN WHERE GIANGDAY.MAGV = GIAOVIEN.MAGV) != INSERTED.MAKHOA
			)
		)
	)
	BEGIN
		PRINT 'ERROR: MON HOC KHONG THUOC KHOA GV PHU TRACH'
		ROLLBACK TRAN
	END
END
-- II
SET DATEFORMAT DMY

ALTER TABLE KHOA NOCHECK CONSTRAINT fk_khoa
INSERT INTO KHOA
(MAKHOA, TENKHOA, NGTLAP, TRGKHOA)
VALUES 
('KHMT','Khoa hoc may tinh','7/6/2005','GV01'),
('HTTT','He thong thong tin','7/6/2005','GV02'),
('CNPM','Cong nghe phan mem','7/6/2005','GV04'),
('MTT','Mang va truyen thong','20/10/2005','GV03'),
('KTMT','Ky thuat may tinh','20/12/2005',Null)
ALTER TABLE KHOA CHECK CONSTRAINT fk_khoa

INSERT INTO MONHOC
(MAMH, TENMH, TCLT, TCTH, MAKHOA)
VALUES
('THDC','Tin hoc dai cuong','4','1','KHMT'),
('CTRR','Cau truc roi rac','4','1','KHMT'),
('CSDL','Co so du lieu','3','1','HTTT'),
('CTDLGT','Cau truc du lieu va giai thuat','3','1','KHMT'),
('PTTKTT','Phan tich thiet ke thuat toan','3','0','KHMT'),
('DHMT','Do hoa may tinh','3','1','KHMT'),
('KTMT','Kien truc may tinh','3','0','KTMT'),
('TKCSDL','Thiet ke co so du lieu','3','1','HTTT'),
('PTTKHTTT','Phan tich thiet ke he thong thong tin','4','1','HTTT'),
('HDH','He dieu hanh','4','1','KTMT'),
('NMCNPM','Nhap mon cong nghe phan mem','3','0','CNPM'),
('LTCFW','Lap trinh C for win','3','1','CNPM'),
('LTHDT','Lap trinh huong doi tuong','3','1','CNPM')

INSERT INTO GIAOVIEN
(MAGV, HOTEN, HOCVI, HOCHAM, GIOITINH, NGSINH, NGVL, HESO, MUCLUONG, MAKHOA)
VALUES
('GV01','Ho Thanh Son','PTS','GS','Nam','2/5/1950','11/1/2004','5.00','2,250,000','KHMT'),
('GV02','Tran Tam Thanh','TS','PGS','Nam','17/12/1965','20/4/2004','4.50','2,025,000','HTTT'),
('GV03','Do Nghiem Phung','TS','GS','Nu','1/8/1950','23/9/2004','4.00','1,800,000','CNPM'),
('GV04','Tran Nam Son','TS','PGS','Nam','22/2/1961','12/1/2005','4.50','2,025,000','KTMT'),
('GV05','Mai Thanh Danh','ThS','GV','Nam','12/3/1958','12/1/2005','3.00','1,350,000','HTTT'),
('GV06','Tran Doan Hung','TS','GV','Nam','11/3/1953','12/1/2005','4.50','2,025,000','KHMT'),
('GV07','Nguyen Minh Tien','ThS','GV','Nam','23/11/1971','1/3/2005','4.00','1,800,000','KHMT'),
('GV08','Le Thi Tran','KS','Null','Nu','26/3/1974','1/3/2005','1.69','760,500','KHMT'),
('GV09','Nguyen To Lan','ThS','GV','Nu','31/12/1966','1/3/2005','4.00','1,800,000','HTTT'),
('GV10','Le Tran Anh Loan','KS','Null','Nu','17/7/1972','1/3/2005','1.86','837,000','CNPM'),
('GV11','Ho Thanh Tung','CN','GV','Nam','12/1/1980','15/5/2005','2.67','1,201,500','MTT'),
('GV12','Tran Van Anh','CN','Null','Nu','29/3/1981','15/5/2005','1.69','760,500','CNPM'),
('GV13','Nguyen Linh Dan','CN','Null','Nu','23/5/1980','15/5/2005','1.69','760,500','KTMT'),
('GV14','Truong Minh Chau','ThS','GV','Nu','30/11/1976','15/5/2005','3.00','1,350,000','MTT'),
('GV15','Le Ha Thanh','ThS','GV','Nam','4/5/1978','15/5/2005','3.00','1,350,000','KHMT')

ALTER TABLE LOP NOCHECK CONSTRAINT fk_lop_hv
INSERT INTO LOP 
(MALOP, TENLOP, TRGLOP, SISO, MAGVCN)
VALUES
('K11','Lop 1 khoa 1','K1108','11','GV07'),
('K12','Lop 2 khoa 1','K1205','12','GV09'),
('K13','Lop 3 khoa 1','K1305','12','GV14')
ALTER TABLE LOP CHECK CONSTRAINT fk_lop_hv

INSERT INTO HOCVIEN
(MAHV, HO, TEN, NGSINH, GIOITINH, NOISINH, MALOP)
VALUES
('K1101','Nguyen Van','A','27/1/1986','Nam','TpHCM','K11'),
('K1102','Tran Ngoc','Han','14/3/1986','Nu','Kien Giang','K11'),
('K1103','Ha Duy','Lap','18/4/1986','Nam','Nghe An','K11'),
('K1104','Tran Ngoc','Linh','30/3/1986','Nu','Tay Ninh','K11'),
('K1105','Tran Minh','Long','27/2/1986','Nam','TpHCM','K11'),
('K1106','Le Nhat','Minh','24/1/1986','Nam','TpHCM','K11'),
('K1107','Nguyen Nhu','Nhut','27/1/1986','Nam','Ha Noi','K11'),
('K1108','Nguyen Manh','Tam','27/2/1986','Nam','Kien Giang','K11'),
('K1109','Phan Thi Thanh','Tam','27/1/1986','Nu','Vinh Long','K11'),
('K1110','Le Hoai','Thuong','5/2/1986','Nu','Can Tho','K11'),
('K1111','Le Ha','Vinh','25/12/1986','Nam','Vinh Long','K11'),
('K1201','Nguyen Van','B','11/2/1986','Nam','TpHCM','K12'),
('K1202','Nguyen Thi Kim','Duyen','18/1/1986','Nu','TpHCM','K12'),
('K1203','Tran Thi Kim','Duyen','17/9/1986','Nu','TpHCM','K12'),
('K1204','Truong My','Hanh','19/5/1986','Nu','Dong Nai','K12'),
('K1205','Nguyen Thanh','Nam','17/4/1986','Nam','TpHCM','K12'),
('K1206','Nguyen Thi Truc','Thanh','4/3/1986','Nu','Kien Giang','K12'),
('K1207','Tran Thi Bich','Thuy','8/2/1986','Nu','Nghe An','K12'),
('K1208','Huynh Thi Kim','Trieu','8/4/1986','Nu','Tay Ninh','K12'),
('K1209','Pham Thanh','Trieu','23/2/1986','Nam','TpHCM','K12'),
('K1210','Ngo Thanh','Tuan','14/2/1986','Nam','TpHCM','K12'),
('K1211','Do Thi','Xuan','9/3/1986','Nu','Ha Noi','K12'),
('K1212','Le Thi Phi','Yen','12/3/1986','Nu','TpHCM','K12'),
('K1301','Nguyen Thi Kim','Cuc','9/6/1986','Nu','Kien Giang','K13'),
('K1302','Truong Thi My','Hien','18/3/1986','Nu','Nghe An','K13'),
('K1303','Le Duc','Hien','21/3/1986','Nam','Tay Ninh','K13'),
('K1304','Le Quang','Hien','18/4/1986','Nam','TpHCM','K13'),
('K1305','Le Thi','Huong','27/3/1986','Nu','TpHCM','K13'),
('K1306','Nguyen Thai','Huu','30/3/1986','Nam','Ha Noi','K13'),
('K1307','Tran Minh','Man','28/5/1986','Nam','TpHCM','K13'),
('K1308','Nguyen Hieu','Nghia','8/4/1986','Nam','Kien Giang','K13'),
('K1309','Nguyen Trung','Nghia','18/1/1987','Nam','Nghe An','K13'),
('K1310','Tran Thi Hong','Tham','22/4/1986','Nu','Tay Ninh','K13'),
('K1311','Tran Minh','Thuc','4/4/1986','Nam','TpHCM','K13'),
('K1312','Nguyen Thi Kim','Yen','7/9/1986','Nu','TpHCM','K13')

INSERT INTO GIANGDAY
(MALOP, MAMH, MAGV, HOCKY, NAM, TUNGAY, DENNGAY)
VALUES
('K11','THDC','GV07','1','2006','2/1/2006','12/5/2006'),
('K12','THDC','GV06','1','2006','2/1/2006','12/5/2006'),
('K13','THDC','GV15','1','2006','2/1/2006','12/5/2006'),
('K11','CTRR','GV02','1','2006','9/1/2006','17/5/2006'),
('K12','CTRR','GV02','1','2006','9/1/2006','17/5/2006'),
('K13','CTRR','GV08','1','2006','9/1/2006','17/5/2006'),
('K11','CSDL','GV05','2','2006','1/6/2006','15/7/2006'),
('K12','CSDL','GV09','2','2006','1/6/2006','15/7/2006'),
('K13','CTDLGT','GV15','2','2006','1/6/2006','15/7/2006'),
('K13','CSDL','GV05','3','2006','1/8/2006','15/12/2006'),
('K13','DHMT','GV07','3','2006','1/8/2006','15/12/2006'),
('K11','CTDLGT','GV15','3','2006','1/8/2006','15/12/2006'),
('K12','CTDLGT','GV15','3','2006','1/8/2006','15/12/2006'),
('K11','HDH','GV04','1','2007','2/1/2007','18/2/2007'),
('K12','HDH','GV04','1','2007','2/1/2007','20/3/2007'),
('K11','DHMT','GV07','1','2007','18/2/2007','20/3/2007')

INSERT INTO DIEUKIEN
(MAMH, MAMH_TRUOC)
VALUES
('CSDL','CTRR'),
('CSDL','CTDLGT'),
('CTDLGT','THDC'),
('PTTKTT','THDC'),
('PTTKTT','CTDLGT'),
('DHMT','THDC'),
('LTHDT','THDC'),
('PTTKHTTT','CSDL')

INSERT INTO KETQUATHI
(MAHV, MAMH, LANTHI, NGTHI, DIEM, KQUA)
VALUES
('K1101','CSDL','1','20/7/2006','10.00','Dat'),
('K1101','CTDLGT','1','28/12/2006','9.00','Dat'),
('K1101','THDC','1','20/5/2006','9.00','Dat'),
('K1101','CTRR','1','13/5/2006','9.50','Dat'),
('K1102','CSDL','1','20/7/2006','4.00','Khong Dat'),
('K1102','CSDL','2','27/7/2006','4.25','Khong Dat'),
('K1102','CSDL','3','10/8/2006','4.50','Khong Dat'),
('K1102','CTDLGT','1','28/12/2006','4.50','Khong Dat'),
('K1102','CTDLGT','2','5/1/2007','4.00','Khong Dat'),
('K1102','CTDLGT','3','15/1/2007','6.00','Dat'),
('K1102','THDC','1','20/5/2006','5.00','Dat'),
('K1102','CTRR','1','13/5/2006','7.00','Dat'),
('K1103','CSDL','1','20/7/2006','3.50','Khong Dat'),
('K1103','CSDL','2','27/7/2006','8.25','Dat'),
('K1103','CTDLGT','1','28/12/2006','7.00','Dat'),
('K1103','THDC','1','20/5/2006','8.00','Dat'),
('K1103','CTRR','1','13/5/2006','6.50','Dat'),
('K1104','CSDL','1','20/7/2006','3.75','Khong Dat'),
('K1104','CTDLGT','1','28/12/2006','4.00','Khong Dat'),
('K1104','THDC','1','20/5/2006','4.00','Khong Dat'),
('K1104','CTRR','1','13/5/2006','4.00','Khong Dat'),
('K1104','CTRR','2','20/5/2006','3.50','Khong Dat'),
('K1104','CTRR','3','30/6/2006','4.00','Khong Dat'),
('K1201','CSDL','1','20/7/2006','6.00','Dat'),
('K1201','CTDLGT','1','28/12/2006','5.00','Dat'),
('K1201','THDC','1','20/5/2006','8.50','Dat'),
('K1201','CTRR','1','13/5/2006','9.00','Dat'),
('K1202','CSDL','1','20/7/2006','8.00','Dat'),
('K1202','CTDLGT','1','28/12/2006','4.00','Khong Dat'),
('K1202','CTDLGT','2','5/1/2007','5.00','Dat'),
('K1202','THDC','1','20/5/2006','4.00','Khong Dat'),
('K1202','THDC','2','27/5/2006','4.00','Khong Dat'),
('K1202','CTRR','1','13/5/2006','3.00','Khong Dat'),
('K1202','CTRR','2','20/5/2006','4.00','Khong Dat'),
('K1202','CTRR','3','30/6/2006','6.25','Dat'),
('K1203','CSDL','1','20/7/2006','9.25','Dat'),
('K1203','CTDLGT','1','28/12/2006','9.50','Dat'),
('K1203','THDC','1','20/5/2006','10.00','Dat'),
('K1203','CTRR','1','13/5/2006','10.00','Dat'),
('K1204','CSDL','1','20/7/2006','8.50','Dat'),
('K1204','CTDLGT','1','28/12/2006','6.75','Dat'),
('K1204','THDC','1','20/5/2006','4.00','Khong Dat'),
('K1204','CTRR','1','13/5/2006','6.00','Dat'),
('K1301','CSDL','1','20/12/2006','4.25','Khong Dat'),
('K1301','CTDLGT','1','25/7/2006','8.00','Dat'),
('K1301','THDC','1','20/5/2006','7.75','Dat'),
('K1301','CTRR','1','13/5/2006','8.00','Dat'),
('K1302','CSDL','1','20/12/2006','6.75','Dat'),
('K1302','CTDLGT','1','25/7/2006','5.00','Dat'),
('K1302','THDC','1','20/5/2006','8.00','Dat'),
('K1302','CTRR','1','13/5/2006','8.50','Dat'),
('K1303','CSDL','1','20/12/2006','4.00','Khong Dat'),
('K1303','CTDLGT','1','25/7/2006','4.50','Khong Dat'),
('K1303','CTDLGT','2','7/8/2006','4.00','Khong Dat'),
('K1303','CTDLGT','3','15/8/2006','4.25','Khong Dat'),
('K1303','THDC','1','20/5/2006','4.50','Khong Dat'),
('K1303','CTRR','1','13/5/2006','3.25','Khong Dat'),
('K1303','CTRR','2','20/5/2006','5.00','Dat'),
('K1304','CSDL','1','20/12/2006','7.75','Dat'),
('K1304','CTDLGT','1','25/7/2006','9.75','Dat'),
('K1304','THDC','1','20/5/2006','5.50','Dat'),
('K1304','CTRR','1','13/5/2006','5.00','Dat'),
('K1305','CSDL','1','20/12/2006','9.25','Dat'),
('K1305','CTDLGT','1','25/7/2006','10.00','Dat'),
('K1305','THDC','1','20/5/2006','8.00','Dat'),
('K1305','CTRR','1','13/5/2006','10.00','Dat')

-- 1. Tang he so luong them 0.2 cho nhung giao vien la truong khoa.
UPDATE GIAOVIEN
SET HESO = HESO + 0.2
WHERE EXISTS (SELECT * FROM KHOA WHERE KHOA.TRGKHOA = GIAOVIEN.MAGV)

-- 2.	Cap nhat gia tri diem trung binh tat ca cac mon hoc  (DIEMTB) cua moi hoc vien 
-- (tat ca cac mon hoc deu co he so 1 va neu hoc vien thi mot mon nhieu lan, chi lay diem cua lan thi sau cung).
UPDATE HOCVIEN 
SET DIEMTB = (
	SELECT AVG(DIEM) 
	FROM KETQUATHI 
	WHERE KETQUATHI.MAHV = HOCVIEN.MAHV AND KETQUATHI.LANTHI = (
		SELECT MAX(KQ2.LANTHI) 
		FROM KETQUATHI KQ2
		WHERE KQ2.MAHV = HOCVIEN.MAHV AND KETQUATHI.MAMH = KQ2.MAMH
	)
)

-- 3. Cap nhat gia tri cho cot GHICHU la “Cam thi” doi voi truong hop: hoc vien co mot mon bat ky thi lan thu 3 duoi 5 diem.
UPDATE HOCVIEN
SET GHICHU = 'Cam thi'
WHERE EXISTS (SELECT * FROM KETQUATHI WHERE KETQUATHI.MAHV = HOCVIEN.MAHV AND KETQUATHI.LANTHI = 3 AND KETQUATHI.DIEM < 5)

-- 4. Cap nhat gia tri cho cot XEPLOAI trong quan he HOCVIEN nhu sau:
-- Neu DIEMTB >= 9 thi XEPLOAI =”XS”
-- Neu  8 <= DIEMTB < 9 thi XEPLOAI = “G”
-- Neu  6.5 <= DIEMTB < 8 thi XEPLOAI = “K”
-- Neu  5  <=  DIEMTB < 6.5 thi XEPLOAI = “TB”
-- Neu  DIEMTB < 5 thi XEPLOAI = ”Y”

UPDATE HOCVIEN 
SET XEPLOAI = (
	CASE 
		WHEN DIEMTB >= 9 THEN 'XS'
		WHEN DIEMTB < 9 AND DIEMTB >= 8 THEN 'G'
		WHEN DIEMTB < 8 AND DIEMTB >= 6.5 THEN 'K'
		WHEN DIEMTB < 6.5 AND DIEMTB >= 5 THEN 'TB'
		WHEN DIEMTB < 5 THEN 'Y'
	END
)
WHERE HOCVIEN.DIEMTB IS NOT NULL

-- III Ngon ngu truy van du lieu
-- 1. In ra danh sach (ma hoc vien, ho ten, ngay sinh, ma lop) 
-- lop truong cua cac lop
SELECT HOCVIEN.MAHV AS 'MA HOC VIEN', (HOCVIEN.HO + ' ' + HOCVIEN.TEN) AS 'HO TEN', 
		HOCVIEN.NGSINH AS 'NGAY SINH', LOP.MALOP AS 'MA LOP'
FROM LOP JOIN HOCVIEN ON LOP.TRGLOP = HOCVIEN.MAHV

-- 2. In ra bang diem khi thi (ma hoc vien, ho ten , lan thi, diem so) mon CTRR cua lop “K12”, 
-- sap xep theo ten, ho hoc vien.
SELECT KETQUATHI.MAHV AS 'MA HOC VIEN', (HOCVIEN.HO + ' ' + HOCVIEN.TEN) AS 'HO TEN',
		KETQUATHI.LANTHI AS 'LAN THI', KETQUATHI.DIEM AS 'DIEM SO'
FROM KETQUATHI 
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV 
WHERE KETQUATHI.MAMH = 'CTRR' AND HOCVIEN.MALOP = 'K12'
ORDER BY HOCVIEN.TEN, HOCVIEN.HO

-- 3. In ra danh sach nhung hoc vien (ma hoc vien, ho ten) va nhung mon hoc ma hoc vien do thi lan thu nhat da dat.
SELECT HOCVIEN.MAHV AS 'MA HOC VIEN', (HOCVIEN.HO + ' ' + HOCVIEN.TEN) AS 'HO TEN',
		MONHOC.TENMH AS 'MON HOC THI LAN 1 DA DAT'
FROM 
KETQUATHI 
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
JOIN MONHOC ON KETQUATHI.MAMH = MONHOC.MAMH
WHERE KETQUATHI.LANTHI = 1 AND KETQUATHI.KQUA = 'Dat'
ORDER BY HOCVIEN.MAHV

-- 4. In ra danh sach hoc vien (ma hoc vien, ho ten) cua lop “K11” thi mon CTRR khong dat (o lan thi 1).
SELECT HOCVIEN.MAHV, HOCVIEN.HO + ' ' + HOCVIEN.TEN AS 'Ho va ten'
FROM KETQUATHI
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV 
WHERE KETQUATHI.LANTHI = 1 AND KETQUATHI.MAMH = 'CTRR' AND HOCVIEN.MALOP = 'K11' AND KETQUATHI.KQUA = 'Khong dat'

-- 5. * Danh sach hoc vien (ma hoc vien, ho ten) cua lop “K” thi mon CTRR khong dat (o tat ca cac lan thi).
SELECT HOCVIEN.MAHV AS 'Ma hoc vien', HOCVIEN.HO + ' ' + HOCVIEN.TEN AS 'Ho va ten'
FROM KETQUATHI
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV 
JOIN LOP ON HOCVIEN.MALOP = LOP.MALOP
WHERE LEFT(LOP.MALOP,1) = 'K' AND KETQUATHI.MAMH = 'CTRR'
AND HOCVIEN.MAHV NOT IN (SELECT MAHV FROM KETQUATHI WHERE KETQUATHI.KQUA = 'Dat')
GROUP BY HOCVIEN.MAHV, HOCVIEN.HO + ' ' + HOCVIEN.TEN

-- 6. Tim ten nhung mon hoc ma giao vien co ten “Tran Tam Thanh” day trong hoc ky 1 nam 2006.
SELECT DISTINCT MONHOC.TENMH
FROM GIANGDAY 
JOIN GIAOVIEN ON GIANGDAY.MAGV = GIAOVIEN.MAGV
JOIN MONHOC ON GIANGDAY.MAMH = MONHOC.MAMH
WHERE GIANGDAY.HOCKY = '1' AND GIANGDAY.NAM = '2006' AND GIAOVIEN.HOTEN = 'Tran Tam Thanh'

-- 7. Tim nhung mon hoc (ma mon hoc, ten mon hoc) ma giao vien chu nhiem lop “K11” day trong hoc ky 1 nam 2006.
SELECT DISTINCT MONHOC.MAMH AS 'MA MON HOC', MONHOC.TENMH AS 'TEN MON HOC'
FROM GIANGDAY
JOIN LOP ON GIANGDAY.MAGV = LOP.MAGVCN
JOIN MONHOC ON GIANGDAY.MAMH = MONHOC.MAMH
WHERE LOP.MALOP = 'K11' AND GIANGDAY.HOCKY = '1' AND GIANGDAY.NAM = '2006'

-- 8. Tim ho ten lop truong cua cac lop ma giao vien co ten “Nguyen To Lan” day mon “Co So Du Lieu”.
SELECT (HOCVIEN.HO + ' ' + HOCVIEN.ten) AS 'HO VA TEN'
FROM GIANGDAY 
JOIN GIAOVIEN ON GIAOVIEN.MAGV = GIANGDAY.MAGV
JOIN LOP ON LOP.MALOP = GIANGDAY.MALOP
JOIN HOCVIEN ON HOCVIEN.MAHV = LOP.TRGLOP
JOIN MONHOC ON MONHOC.MAMH = GIANGDAY.MAMH
WHERE GIAOVIEN.HOTEN = 'Nguyen To Lan' AND MONHOC.TENMH = 'Co So Du Lieu'

-- 9. In ra danh sach nhung mon hoc (ma mon hoc, ten mon hoc) phai hoc lien truoc mon “Co So Du Lieu”.
SELECT MHT.MAMH AS 'MA MON HOC', MHT.TENMH AS 'TEN MON HOC'
FROM DIEUKIEN
JOIN MONHOC AS MHT ON DIEUKIEN.MAMH_TRUOC = MHT.MAMH 
JOIN MONHOC AS MHS ON DIEUKIEN.MAMH = MHS.MAMH
WHERE MHS.TENMH = 'Co So Du Lieu'

-- 10. Mon “Cau Truc Roi Rac” la mon bat buoc phai hoc lien truoc nhung mon hoc (ma mon hoc, ten mon hoc) nao.
SELECT MHS.MAMH AS 'MA MON HOC', MHS.TENMH AS 'TEN MON HOC'
FROM DIEUKIEN
JOIN MONHOC AS MHT ON DIEUKIEN.MAMH_TRUOC = MHT.MAMH 
JOIN MONHOC AS MHS ON DIEUKIEN.MAMH = MHS.MAMH
WHERE MHT.TENMH = 'Cau Truc Roi Rac'

-- 11. Tim ho ten giao vien day mon CTRR cho ca hai lop “K11” va “K12” trong cung hoc ky 1 nam 2006.
SELECT GIAOVIEN.HOTEN
FROM GIANGDAY
JOIN GIAOVIEN ON GIAOVIEN.MAGV = GIANGDAY.MAGV
WHERE GIANGDAY.MALOP = 'K11' AND GIANGDAY.MAMH = 'CTRR' 
	AND GIANGDAY.HOCKY = '1' AND GIANGDAY.NAM = '2006' AND EXISTS (
	SELECT * 
	FROM GIANGDAY AS GD2 
	WHERE GD2.MALOP = 'K12' AND GIANGDAY.MAMH = 'CTRR' AND GIANGDAY.HOCKY = '1' AND GIANGDAY.NAM = '2006'
)

-- 12. Tim nhung hoc vien (ma hoc vien, ho ten) thi khong dat mon CSDL o lan thi thu 1 nhung chua thi lai mon nay.
SELECT HOCVIEN.MAHV AS 'MA HOC VIEN', (HOCVIEN.HO + ' ' + HOCVIEN.TEN) AS 'HO TEN'
FROM KETQUATHI
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE KETQUATHI.MAMH = 'CSDL' AND LANTHI = '1' AND KETQUATHI.KQUA = 'Khong Dat' 
	AND NOT EXISTS (
	SELECT * 
	FROM KETQUATHI AS KQ2
	WHERE KQ2.MAMH = 'CSDL' AND KQ2.MAHV = HOCVIEN.MAHV AND KQ2.LANTHI > '1'
)

-- 13. Tim giao vien (ma giao vien, ho ten) khong duoc phan cong giang day bat ky mon hoc nao.
SELECT GIAOVIEN.MAGV AS 'MA GIAO VIEN', GIAOVIEN.HOTEN AS 'HO TEN'
FROM GIAOVIEN
WHERE NOT EXISTS (
	SELECT * 
	FROM GIANGDAY
	WHERE GIANGDAY.MAGV = GIAOVIEN.MAGV
)

-- 14. Tim giao vien (ma giao vien, ho ten) khong duoc phan cong giang day bat ky mon hoc nao thuoc khoa giao vien do phu trach.
SELECT GIAOVIEN.MAGV AS 'MA GIAO VIEN', GIAOVIEN.HOTEN AS 'HO TEN'
FROM GIAOVIEN
WHERE NOT EXISTS (
	SELECT * 
	FROM GIANGDAY
	JOIN MONHOC ON MONHOC.MAMH = GIANGDAY.MAMH
	WHERE MONHOC.MAKHOA = GIAOVIEN.MAKHOA AND GIAOVIEN.MAGV = GIANGDAY.MAGV
)

-- 15. Tim ho ten cac hoc vien thuoc lop “K11” thi mot mon bat ky qua 3 lan van “Khong dat” hoac thi lan thu 2 mon CTRR duoc 5 diem.
SELECT DISTINCT (HOCVIEN.HO + ' ' + HOCVIEN.TEN) AS 'HO TEN'
FROM KETQUATHI 
JOIN HOCVIEN ON HOCVIEN.MAHV = KETQUATHI.MAHV
WHERE HOCVIEN.MALOP = 'K11' AND ((KETQUATHI.MAMH = 'CTRR' AND KETQUATHI.DIEM = '5' AND KETQUATHI.LANTHI = '2') 
	OR EXISTS (
	SELECT TEMP.SOLANTRUOT
	FROM (
		SELECT COUNT(*) AS SOLANTRUOT
		FROM KETQUATHI AS KQ2
		WHERE KQ2.KQUA = 'Khong Dat' AND HOCVIEN.MAHV = KQ2.MAHV
		GROUP BY KQ2.MAHV, KQ2.MAMH
	) AS TEMP
	WHERE TEMP.SOLANTRUOT = '3'
))

-- 16. Tim ho ten giao vien day mon CTRR cho it nhat hai lop trong cung mot hoc ky cua mot nam hoc.
SELECT GIAOVIEN.HOTEN
FROM GIANGDAY
JOIN GIAOVIEN ON GIAOVIEN.MAGV = GIANGDAY.MAGV
WHERE GIANGDAY.MAMH = 'CTRR'
GROUP BY GIAOVIEN.MAGV, GIAOVIEN.HOTEN, GIANGDAY.HOCKY, GIANGDAY.NAM
HAVING COUNT(*) >= 2

 -- 17. Danh sach hoc vien va diem thi mon CSDL (chi lay diem cua lan thi sau cung).
SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN, KETQUATHI.DIEM
FROM KETQUATHI
JOIN HOCVIEN ON HOCVIEN.MAHV = KETQUATHI.MAHV
WHERE KETQUATHI.MAMH = 'CSDL' AND KETQUATHI.LANTHI = (
	SELECT MAX(KQ2.LANTHI)
	FROM KETQUATHI AS KQ2
	WHERE KQ2.MAMH = 'CSDL' AND KQ2.MAHV = KETQUATHI.MAHV
)

-- 18. Danh sach hoc vien va diem thi mon “Co So Du Lieu” (chi lay diem cao nhat cua cac lan thi).
SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN, KETQUATHI.DIEM
FROM KETQUATHI
JOIN HOCVIEN ON HOCVIEN.MAHV = KETQUATHI.MAHV
JOIN MONHOC ON MONHOC.MAMH = KETQUATHI.MAMH
	WHERE MONHOC.TENMH = 'Co So Du Lieu' AND KETQUATHI.DIEM = (
	SELECT MAX(KQ2.DIEM)
	FROM KETQUATHI AS KQ2
	WHERE KQ2.MAMH = KETQUATHI.MAMH AND KQ2.MAHV = KETQUATHI.MAHV
)
--19. Khoa nao (ma khoa, ten khoa) duoc thanh lap som nhat.
SELECT TOP 1 WITH TIES KHOA.MAKHOA, KHOA.TENKHOA
FROM KHOA
ORDER BY KHOA.NGTLAP

--20. Co bao nhieu giao vien co hoc ham la “GS” hoac “PGS”.
SELECT COUNT(*) FROM GIAOVIEN
WHERE GIAOVIEN.HOCHAM = 'GS' OR GIAOVIEN.HOCHAM = 'PGS'

--21. Thong ke co bao nhieu giao vien co hoc vi la “CN”, “KS”, “Ths”, “TS”, “PTS” trong moi khoa.
SELECT KHOA.TENKHOA, COUNT(*)
FROM GIAOVIEN
JOIN KHOA ON GIAOVIEN.MAKHOA = KHOA.MAKHOA
GROUP BY KHOA.MAKHOA, KHOA.TENKHOA

--22. Moi mon hoc thong ke so luong hoc vien theo ket qua (dat va khong dat).
SELECT KETQUATHI.MAMH, COUNT(CASE WHEN KETQUATHI.KQUA = 'Dat' THEN 1 END), 
	COUNT(CASE WHEN KETQUATHI.KQUA = 'Khong Dat' THEN 1 END)
FROM KETQUATHI
GROUP BY KETQUATHI.MAMH

--23. Tim giao vien (ma giao vien, ho ten) la giao vien chu nhiem cua mot lop, dong thoi day cho lop do it nhat mot mon hoc.
SELECT GIAOVIEN.MAGV, GIAOVIEN.HOTEN
FROM LOP
JOIN GIAOVIEN ON LOP.MAGVCN = GIAOVIEN.MAGV
WHERE EXISTS (
	SELECT * 
	FROM GIANGDAY 
	WHERE LOP.MALOP = GIANGDAY.MALOP AND GIANGDAY.MAGV = GIAOVIEN.MAGV
)

--24. Tim ho ten lop truong cua lop co si so cao nhat.
SELECT TOP 1 WITH TIES (HOCVIEN.HO + ' ' + HOCVIEN.TEN) AS 'Ho va ten'
FROM LOP
JOIN HOCVIEN ON LOP.TRGLOP = HOCVIEN.MAHV
ORDER BY LOP.SISO DESC

--25. * Tim ho ten nhung LOPTRG thi khong dat qua 3 mon (moi mon deu thi khong dat o tat ca cac lan thi).
SELECT *
FROM ( 
	SELECT * 
	FROM HOCVIEN 
	WHERE EXISTS (
		SELECT * 
		FROM LOP 
		WHERE LOP.TRGLOP = HOCVIEN.MAHV
	)
) LPTRG
WHERE (
	SELECT COUNT(*)
	FROM (
		SELECT COUNT(CASE WHEN KETQUATHI.KQUA = 'Dat' THEN 1 END) AS 'SoLanDau'
		FROM KETQUATHI
		WHERE KETQUATHI.MAHV = LPTRG.MAHV
		GROUP BY KETQUATHI.MAMH
	) KQOFLTRG
	WHERE KQOFLTRG.SoLanDau = 0
) > 3

--26. Tim hoc vien (ma hoc vien, ho ten) co so mon dat diem 9,10 nhieu nhat.
SELECT TOP 1 WITH TIES HOCVIEN.MAHV, (HOCVIEN.HO + ' ' + HOCVIEN.TEN) AS 'Ho va ten'
FROM KETQUATHI
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE KETQUATHI.DIEM >= 9
GROUP BY HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
ORDER BY COUNT(*) DESC

--27. Trong tung lop, tim hoc vien (ma hoc vien, ho ten) co so mon dat diem 9,10 nhieu nhat.
SELECT DISTINCT HOCVIEN.MAHV, HO + ' ' + TEN
FROM KETQUATHI
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE HOCVIEN.MAHV IN (
	SELECT TOP 1 HV.MAHV
	FROM KETQUATHI AS KQ
	JOIN HOCVIEN AS HV ON KQ.MAHV = HV.MAHV
	WHERE HV.MALOP = HOCVIEN.MALOP AND KQ.DIEM >= 9
	GROUP BY HV.MAHV
	ORDER BY COUNT(*)
)

--28. Trong tung hoc ky cua tung nam, moi giao vien phan cong day bao nhieu mon hoc, bao nhieu lop.
SELECT GIANGDAY.NAM, GIANGDAY.HOCKY, GIANGDAY.MAGV, COUNT(DISTINCT MALOP) AS 'So Lop', COUNT(DISTINCT MAMH) AS 'So mon hoc'
FROM GIANGDAY
GROUP BY GIANGDAY.NAM, GIANGDAY.HOCKY, GIANGDAY.MAGV
ORDER BY GIANGDAY.NAM, GIANGDAY.HOCKY, GIANGDAY.MAGV

--29. Trong tung hoc ky cua tung nam, tim giao vien (ma giao vien, ho ten) giang day nhieu nhat.
SELECT DISTINCT GIANGDAY.NAM, GIANGDAY.HOCKY, GIAOVIEN.MAGV, GIAOVIEN.HOTEN
FROM GIANGDAY 
JOIN GIAOVIEN ON GIANGDAY.MAGV = GIAOVIEN.MAGV
WHERE GIAOVIEN.MAGV IN (
	SELECT TOP 1 GD.MAGV
	FROM GIANGDAY AS GD
	WHERE GIANGDAY.NAM = GD.NAM AND GIANGDAY.HOCKY = GD.HOCKY
	GROUP BY GD.MAGV
	ORDER BY COUNT(*)
)

--30. Tim mon hoc (ma mon hoc, ten mon hoc) co nhieu hoc vien thi khong dat (o lan thi thu 1) nhat.
SELECT TOP 1 WITH TIES MONHOC.MAMH, MONHOC.TENMH
FROM KETQUATHI
JOIN MONHOC ON KETQUATHI.MAMH = MONHOC.MAMH
WHERE KETQUATHI.LANTHI = '1' AND KETQUATHI.KQUA = 'Khong Dat'
GROUP BY MONHOC.MAMH, MONHOC.TENMH
ORDER BY COUNT(*) DESC

--31. Tim hoc vien (ma hoc vien, ho ten) thi mon nao cung dat (chi xet lan thi thu 1).
SELECT DISTINCT HOCVIEN.MAHV, (HOCVIEN.HO + ' ' + HOCVIEN.TEN) AS 'Ho Ten'
FROM KETQUATHI
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE NOT EXISTS (
	SELECT * 
	FROM KETQUATHI AS KQ
	WHERE KQ.MAHV = HOCVIEN.MAHV AND KQ.LANTHI = '1' AND KQ.KQUA = 'Khong Dat'
)

--32.* Tim hoc vien (ma hoc vien, ho ten) thi mon nao cung dat (chi xet lan thi sau cung).
SELECT DISTINCT HOCVIEN.MAHV, (HOCVIEN.HO + ' ' + HOCVIEN.TEN) AS 'Ho Ten'
FROM KETQUATHI
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE NOT EXISTS (
	SELECT * 
	FROM KETQUATHI AS KQ
	WHERE KQ.MAHV = HOCVIEN.MAHV AND KQ.KQUA = 'Khong Dat' AND NOT EXISTS (
		SELECT *
		FROM KETQUATHI AS KQ2
		WHERE KQ2.MAHV = KQ.MAHV AND KQ.MAMH = KQ2.MAMH AND KQ2.KQUA = 'Dat'
	)
)

--33.* Tim hoc vien (ma hoc vien, ho ten) da thi tat ca cac mon deu dat (chi xet lan thi thu 1).
SELECT DISTINCT HOCVIEN.MAHV, (HOCVIEN.HO + ' ' + HOCVIEN.TEN) AS 'Ho Ten'
FROM KETQUATHI
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE (
	SELECT COUNT(DISTINCT KQ2.MAMH)
	FROM KETQUATHI KQ2
	WHERE KQ2.MAHV = HOCVIEN.MAHV
) = (SELECT COUNT(*) FROM MONHOC) AND NOT EXISTS (
	SELECT * 
	FROM KETQUATHI AS KQ
	WHERE KQ.MAHV = HOCVIEN.MAHV AND KQ.LANTHI = '1' AND KQ.KQUA = 'Khong Dat'
)

--34.* Tim hoc vien (ma hoc vien, ho ten) da thi tat ca cac mon deu dat  (chi xet lan thi sau cung).
SELECT DISTINCT HOCVIEN.MAHV, (HOCVIEN.HO + ' ' + HOCVIEN.TEN) AS 'Ho Ten'
FROM KETQUATHI
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE (
	SELECT COUNT(DISTINCT KQ3.MAMH)
	FROM KETQUATHI KQ3
	WHERE KQ3.MAHV = HOCVIEN.MAHV
) = (SELECT COUNT(*) FROM MONHOC) AND NOT EXISTS (
	SELECT * 
	FROM KETQUATHI AS KQ
	WHERE KQ.MAHV = HOCVIEN.MAHV AND KQ.KQUA = 'Khong Dat' AND NOT EXISTS (
		SELECT *
		FROM KETQUATHI AS KQ2
		WHERE KQ2.MAHV = KQ.MAHV AND KQ.MAMH = KQ2.MAMH AND KQ2.KQUA = 'Dat'
	)
)
--35.** Tim hoc vien (ma hoc vien, ho ten) co diem thi cao nhat trong tung mon (lay diem o lan thi sau cung).
SELECT DISTINCT KETQUATHI.MAMH, HOCVIEN.MAHV, (HOCVIEN.HO + ' ' + HOCVIEN.TEN) AS 'Ho Ten', KETQUATHI.DIEM
FROM KETQUATHI
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE KETQUATHI.DIEM = (
	SELECT MAX(KQ.DIEM)
	FROM KETQUATHI AS KQ
	WHERE KQ.MAMH = KETQUATHI.MAMH
) AND NOT EXISTS (
	SELECT * 
	FROM KETQUATHI AS KQ2
	WHERE KETQUATHI.MAHV = KQ2.MAHV AND KQ2.LANTHI > KETQUATHI.LANTHI AND KETQUATHI.MAMH = KQ2.MAMH
)
ORDER BY MAMH

