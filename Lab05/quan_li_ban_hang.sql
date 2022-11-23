
use master
drop database if exists quan_li_ban_hang
create database quan_li_ban_hang

use quan_li_ban_hang
drop table if exists KHACHHANG
create table KHACHHANG (
	MAKH CHAR(4) not null,
	HOTEN VARCHAR(40) not null,
	DCHI VARCHAR(50) not null,
	SODT VARCHAR(20) not null,
	NGSINH SMALLDATETIME not null,
	DOANHSO MONEY not null,
	NGDK SMALLDATETIME not null,
	PRIMARY KEY(MAKH),
)

drop table if exists NHANVIEN
create table NHANVIEN (
	MANV CHAR(4) not null,
	HOTEN VARCHAR(40) not null,
	SODT VARCHAR(20) not null,
	NGVL SMALLDATETIME not null,
	PRIMARY KEY(MANV),
)

drop table if exists SANPHAM
create table SANPHAM (
	MASP CHAR(4) not null,
	TENSP VARCHAR(40) not null,
	DVT VARCHAR(20) not null,
	NUOCSX VARCHAR(40) not null,
	GIA MONEY not null,
	PRIMARY KEY(MASP),
)

drop table if exists HOADON
create table HOADON (
	SOHD INT not null,
	NGHD SMALLDATETIME not null,
	MAKH CHAR(4),
	MANV CHAR(4) not null,
	TRIGIA MONEY not null,
	PRIMARY KEY(SOHD),
	FOREIGN KEY(MAKH) references KHACHHANG(MAKH),
	FOREIGN KEY(MANV) references NHANVIEN(MANV),
)

drop table if exists CTHD
create table CTHD (
	SOHD INT not null,
	MASP CHAR(4) not null,
	SL INT not null,
	PRIMARY KEY(SOHD, MASP),
	FOREIGN KEY(SOHD) references HOADON(SOHD),
	FOREIGN KEY(MASP) references SANPHAM(MASP),
)

-- 2. Them thuoc tinh GHICHU
ALTER TABLE SANPHAM
ADD GHICHU varchar(20) not null

-- 3. Them thuoc tinh LOAIKH 
ALTER TABLE KHACHHANG
ADD LOAIKH tinyint not null

-- 4. Sua kieu du lieu cua GHICHU thanh varchar(100)
ALTER TABLE SANPHAM
ALTER COLUMN GHICHU varchar(100)  not null

-- 5. Xoa thuoc tinh GHICHU
ALTER TABLE SANPHAM
DROP COLUMN if exists GHICHU

-- 6. Doi kieu du lieu de luu dc "Vang lai", "Thuong xuyen", "Vip",...
ALTER TABLE KHACHHANG
ALTER COLUMN LOAIKH varchar(40) 

-- 7. Don vi chi co the la "cay", "hop", "cai", "quyen", "chuc"
ALTER TABLE SANPHAM
ADD CONSTRAINT check_sp_dvt CHECK(DVT IN ('cay', 'hop', 'cai', 'quyen', 'chuc'))

-- 8. Gia ban san pham tu 500d tro len
ALTER TABLE SANPHAM
ADD CONSTRAINT check_sp_gia CHECK(GIA >= 500)

-- 9. Moi khach hang phai mua it nhat 1 san pham moi lan
--ALTER TABLE CTHD
--ADD CONSTRAINT check_cthd_sl CHECK(SL > 0)

-- 10. Ngay khach hang dang ki thanh vien phai lon hon ngay sinh cua nguoi do
ALTER TABLE KHACHHANG
ADD CONSTRAINT check_kh_ngdk CHECK(NGDK > NGSINH)

-- 11. Ngay mua hang (NGHD) cua mot khach hang thanh vien se lon hon hoac bang ngay khach hang do dang ky thanh vien (NGDK).
CREATE TRIGGER KH_NGHD_NGDK ON KHACHHANG
AFTER UPDATE, INSERT 
AS
BEGIN
	IF (
		EXISTS (
			SELECT * 
			FROM INSERTED
			JOIN HOADON ON INSERTED.MAKH = HOADON.MAKH
			WHERE INSERTED.NGDK > HOADON.NGHD
		)
	)
	BEGIN
		print 'ERROR: NGHD phai lon hon hoac bang NGDK'
		rollback tran 
	END
	ELSE BEGIN
		PRINT 'THANH CONG'
	END
END

CREATE TRIGGER HD_NGHD_NGDK ON HOADON
AFTER UPDATE, INSERT 
AS
BEGIN
	IF (
		EXISTS (
			SELECT * 
			FROM INSERTED
			JOIN KHACHHANG ON INSERTED.MAKH = KHACHHANG.MAKH
			WHERE INSERTED.NGHD < KHACHHANG.NGDK
		)
	)
	BEGIN
		print 'ERROR: NGHD phai lon hon hoac bang NGDK'
		rollback tran 
	END
	ELSE BEGIN
		PRINT 'THANH CONG'
	END
END

-- 12. Ngay ban hang (NGHD) cua mot nhan vien phai lon hon hoac bang ngay nhan vien do vao lam
CREATE TRIGGER NV_NGHD_NGVL ON NHANVIEN
AFTER UPDATE, INSERT
AS
BEGIN
	IF (
		EXISTS (
			SELECT * 
			FROM INSERTED
			JOIN HOADON ON INSERTED.MANV = HOADON.MANV
			WHERE INSERTED.NGVL > HOADON.NGHD
		)
	)
	BEGIN
		PRINT 'ERROR: NGHD phai lon hon hoac bang NGVL'
		ROLLBACK TRAN
	END
	ELSE BEGIN
		PRINT 'THANH CONG'
	END
END
CREATE TRIGGER HD_NGHD_NGVL ON HOADON
AFTER UPDATE, INSERT
AS
BEGIN
	IF (
		EXISTS (
			SELECT * 
			FROM INSERTED
			JOIN NHANVIEN ON INSERTED.MANV = NHANVIEN.MANV
			WHERE INSERTED.NGHD < NHANVIEN.NGVL
		)
	)
	BEGIN
		PRINT 'ERROR: NGHD phai lon hon hoac bang NGVL'
		ROLLBACK TRAN
	END
	ELSE BEGIN
		PRINT 'THANH CONG'
	END
END

-- 13. Moi mot hoa don phai co it nhat mot chi tiet hoa don.


-- 14. Tri gia cua mot hoa don la tong thanh tien (so luong*don gia) cua cac chi tiet thuoc hoa don do.
CREATE TRIGGER TRG_CTHD_TRIGIA
ON CTHD 
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
	UPDATE HOADON
	SET TRIGIA = TRIGIA + TEMP.TONGGIATRI
	FROM HOADON JOIN (
		SELECT SOHD, SUM(SL * GIA) AS TONGGIATRI 
		FROM INSERTED
		JOIN SANPHAM ON INSERTED.MASP = SANPHAM.MASP
		GROUP BY SOHD
	) AS TEMP ON HOADON.SOHD = TEMP.SOHD

	UPDATE HOADON
	SET TRIGIA = TRIGIA - TEMP.TONGGIATRI
	FROM HOADON JOIN (
		SELECT SOHD, SUM(SL * GIA) AS TONGGIATRI 
		FROM DELETED
		JOIN SANPHAM ON DELETED.MASP = SANPHAM.MASP
		GROUP BY SOHD
	) AS TEMP ON HOADON.SOHD = TEMP.SOHD
END

CREATE TRIGGER TRG_HOADON_TRIGIA
ON HOADON
AFTER UPDATE
AS
BEGIN
	IF UPDATE(TRIGIA)
	BEGIN
		PRINT 'Khong Update TRIGIA'
		ROLLBACK TRAN
	END
END
-- 15. Doanh so cua mot khach hang la tong tri gia cac hoa don ma khach hang thanh vien do da mua.

CREATE TRIGGER TRG_KHACHHANG_DOANHSO
ON HOADON
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
	UPDATE KHACHHANG
	SET DOANHSO = DOANHSO + TEMP.TONGGIATRI
	FROM KHACHHANG JOIN (
		SELECT INSERTED.MAKH, SUM(TRIGIA) AS TONGGIATRI
		FROM INSERTED 
		JOIN KHACHHANG ON INSERTED.MAKH = KHACHHANG.MAKH
		GROUP BY INSERTED.MAKH
	) AS TEMP ON TEMP.MAKH = KHACHHANG.MAKH

	UPDATE KHACHHANG
	SET DOANHSO = DOANHSO - TEMP.TONGGIATRI
	FROM KHACHHANG JOIN (
		SELECT DELETED.MAKH, SUM(TRIGIA) AS TONGGIATRI
		FROM DELETED 
		JOIN KHACHHANG ON DELETED.MAKH = KHACHHANG.MAKH
		GROUP BY DELETED.MAKH
	) AS TEMP ON TEMP.MAKH = KHACHHANG.MAKH

END

CREATE TRIGGER TRG_KHACHHANG_DS
ON KHACHHANG
AFTER UPDATE
AS
BEGIN
	IF UPDATE(DOANHSO)
	BEGIN
		PRINT 'Khong Update DOANHSO'
		ROLLBACK TRAN
	END
END
-- II
-- 1. Nhap du lieu
SET DATEFORMAT DMY
INSERT INTO NHANVIEN
(MANV, HOTEN, SODT, NGVL)
values
('NV01','Nguyen Nhu Nhut','0927345678','13/4/2006'),
('NV02','Le Thi Phi Yen','0987567390','21/4/2006'),
('NV03','Nguyen Van B','0997047382','27/4/2006'),
('NV04','Ngo Thanh Tuan','0913758498','24/6/2006'),
('NV05','Nguyen Thi Truc Thanh','0918590387','20/7/2006')

INSERT INTO KHACHHANG
(MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO, NGDK)
VALUES
('KH01','Nguyen Van A','731 Tran Hung Dao, Q5, TpHCM','08823451','22/10/1960','13,060,000','22/07/2006'),
('KH02','Tran Ngoc Han','23/5 Nguyen Trai, Q5, TpHCM','0908256478','3/4/1974','280,000','30/07/2006'),
('KH03','Tran Ngoc Linh','45 Nguyen Canh Chan, Q1, TpHCM','0938776266','12/6/1980','3,860,000','05/08/2006'),
('KH04','Tran Minh Long','50/34 Le Dai Hanh, Q10, TpHCM','0917325476','9/3/1965','250,000','02/10/2006'),
('KH05','Le Nhat Minh','34 Truong Dinh, Q3, TpHCM','08246108','10/3/1950','21,000','28/10/2006'),
('KH06','Le Hoai Thuong','227 Nguyen Van Cu, Q5, TpHCM','08631738','31/12/1981','915,000','24/11/2006'),
('KH07','Nguyen Van Tam','32/3 Tran Binh Trong, Q5, TpHCM','0916783565','6/4/1971','12,500','01/12/2006'),
('KH08','Phan Thi Thanh','45/2 An Duong Vuong, Q5, TpHCM','0938435756','10/1/1971','365,000','13/12/2006'),
('KH09','Le Ha Vinh','873 Le Hong Phong, Q5, TpHCM','08654763','3/9/1979','70,000','14/01/2007'),
('KH10','Ha Duy Lap','34/34B Nguyen Trai, Q1, TpHCM','08768904','2/5/1983','67,500','16/01/2007')

INSERT INTO SANPHAM
(MASP, TENSP, DVT, NUOCSX, GIA)
VALUES
('BC01','But chi','cay','Singapore','3,000'),
('BC02','But chi','cay','Singapore','5,000'),
('BC03','But chi','cay','Viet Nam','3,500'),
('BC04','But chi','hop','Viet Nam','30,000'),
('BB01','But bi','cay','Viet Nam','5,000'),
('BB02','But bi','cay','Trung Quoc','7,000'),
('BB03','But bi','hop','Thai Lan','100,000'),
('TV01','Tap 100 giay mong','quyen','Trung Quoc','2,500'),
('TV02','Tap 200 giay mong','quyen','Trung Quoc','4,500'),
('TV03','Tap 100 giay tot','quyen','Viet Nam','3,000'),
('TV04','Tap 200 giay tot','quyen','Viet Nam','5,500'),
('TV05','Tap 100 trang','chuc','Viet Nam','23,000'),
('TV06','Tap 200 trang','chuc','Viet Nam','53,000'),
('TV07','Tap 100 trang','chuc','Trung Quoc','34,000'),
('ST01','So tay 500 trang','quyen','Trung Quoc','40,000'),
('ST02','So tay loai 1','quyen','Viet Nam','55,000'),
('ST03','So tay loai 2','quyen','Viet Nam','51,000'),
('ST04','So tay','quyen','Thai Lan','55,000'),
('ST05','So tay mong','quyen','Thai Lan','20,000'),
('ST06','Phan viet bang','hop','Viet Nam','5,000'),
('ST07','Phan khong bui','hop','Viet Nam','7,000'),
('ST08','Bong bang','cai','Viet Nam','1,000'),
('ST09','But long','cay','Viet Nam','5,000'),
('ST10','But long','cay','Trung Quoc','7,000')

SELECT * FROM NHANVIEN

INSERT INTO	HOADON
(SOHD, NGHD, MAKH, MANV, TRIGIA)
VALUES
('1001','23/07/2006','KH01','NV01','320,000'),
('1002','12/08/2006','KH01','NV02','840,000'),
('1003','23/08/2006','KH02','NV01','100,000'),
('1004','01/09/2006','KH02','NV01','180,000'),
('1005','20/10/2006','KH01','NV02','3,800,000'),
('1006','16/10/2006','KH01','NV03','2,430,000'),
('1007','28/10/2006','KH03','NV03','510,000'),
('1008','28/10/2006','KH01','NV03','440,000'),
('1009','28/10/2006','KH03','NV04','200,000'),
('1010','01/11/2006','KH01','NV01','5,200,000'),
('1011','04/11/2006','KH04','NV03','250,000'),
('1012','30/11/2006','KH05','NV03','21,000'),
('1013','12/12/2006','KH06','NV01','5,000'),
('1014','31/12/2006','KH03','NV02','3,150,000'),
('1015','01/01/2007','KH06','NV01','910,000'),
('1016','01/01/2007','KH07','NV02','12,500'),
('1017','02/01/2007','KH08','NV03','35,000'),
('1018','13/01/2007','KH08','NV03','330,000'),
('1019','13/01/2007','KH01','NV03','30,000'),
('1020','14/01/2007','KH09','NV04','70,000'),
('1021','16/01/2007','KH10','NV03','67,500'),
('1022','16/01/2007', NULL,'NV03','7,000'),
('1023','17/01/2007', NULL,'NV01','330,000')

INSERT INTO CTHD
(SOHD, MASP, SL)
VALUES
('1001','TV02','10'),
('1001','ST01','5'),
('1001','BC01','5'),
('1001','BC02','10'),
('1001','ST08','10'),
('1002','BC04','20'),
('1002','BB01','20'),
('1002','BB02','20'),
('1003','BB03','10'),
('1004','TV01','20'),
('1004','TV02','10'),
('1004','TV03','10'),
('1004','TV04','10'),
('1005','TV05','50'),
('1005','TV06','50'),
('1006','TV07','20'),
('1006','ST01','30'),
('1006','ST02','10'),
('1007','ST03','10'),
('1008','ST04','8'),
('1009','ST05','10'),
('1010','TV07','50'),
('1010','ST07','50'),
('1010','ST08','100'),
('1010','ST04','50'),
('1010','TV03','100'),
('1011','ST06','50'),
('1012','ST07','3'),
('1013','ST08','5'),
('1014','BC02','80'),
('1014','BB02','100'),
('1014','BC04','60'),
('1014','BB01','50'),
('1015','BB02','30'),
('1015','BB03','7'),
('1016','TV01','5'),
('1017','TV02','1'),
('1017','TV03','1'),
('1017','TV04','5'),
('1018','ST04','6'),
('1019','ST05','1'),
('1019','ST06','2'),
('1020','ST07','10'),
('1021','ST08','5'),
('1021','TV01','7'),
('1021','TV02','10'),
('1022','ST07','1'),
('1023','ST04','6')

-- 2. Tao quan he SANPHAM1 chua toan bo du lieu cua quan he SANPHAM. 
-- Tao quan he KHACHHANG1 chua toan bo du lieu cua quan he KHACHHANG.

DROP TABLE IF EXISTS SANPHAM1
SELECT * INTO SANPHAM1 FROM SANPHAM
SELECT * FROM SANPHAM1

DROP TABLE IF EXISTS KHACHHANG1
SELECT * INTO KHACHHANG1 FROM KHACHHANG
SELECT * FROM KHACHHANG1

-- 3. Cap nhat gia tang 5% doi voi nhung san pham do “Thai Lan” san xuat (cho quan he SANPHAM1)

SELECT * FROM SANPHAM1 
WHERE NUOCSX = 'Thai Lan'

UPDATE SANPHAM1
SET GIA = GIA*1.05
WHERE SANPHAM1.NUOCSX = 'Thai Lan'

SELECT * FROM SANPHAM1 
WHERE NUOCSX = 'Thai Lan'

-- 4. Cap nhat gia giam 5% doi voi nhung san pham do “Trung Quoc” san xuat 
-- co gia tu 10.000 tro xuong (cho quan he SANPHAM1).

SELECT * FROM SANPHAM1
WHERE NUOCSX = 'Trung Quoc' AND GIA <= 10000

UPDATE SANPHAM1
SET GIA = GIA * 0.95
WHERE NUOCSX = 'Trung Quoc'

SELECT * FROM SANPHAM1
WHERE NUOCSX = 'Trung Quoc' AND GIA <= 10000

-- 5. Cap nhat gia tri LOAIKH la “Vip” doi voi nhung khach hang 
-- dang ky thanh vien truoc ngay 1/1/2007 co doanh so tu 10.000.000 tro len hoac 
-- khach hang dang ky thanh vien tu 1/1/2007 tro ve sau co doanh so tu 2.000.000 tro len (cho quan he KHACHHANG1).

SELECT * FROM KHACHHANG1
WHERE (NGDK < CONVERT(DATE, '1/1/2007') AND DOANHSO >= 10000000) 
	OR (NGDK >= CONVERT(DATE, '1/1/2007') AND DOANHSO >= 2000000)

UPDATE KHACHHANG1 
SET LOAIKH = 'Vip'
WHERE (NGDK < CONVERT(DATE, '1/1/2007') AND DOANHSO >= 10000000) 
	OR (NGDK >= CONVERT(DATE, '1/1/2007') AND DOANHSO >= 2000000)
	
SELECT * FROM KHACHHANG1
WHERE (NGDK < CONVERT(DATE, '1/1/2007') AND DOANHSO >= 10000000) 
	OR (NGDK >= CONVERT(DATE, '1/1/2007') AND DOANHSO >= 2000000)

-- NGON NGU TRUY VAN DU LIEU
-- 1. In ra danh sach cac san pham (MASP,TENSP) do “Trung Quoc” san xuat.
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc'

-- 2. In ra danh sach cac san pham (MASP, TENSP) co don vi tinh la “cay”, ”quyen”.
SELECT MASP, TENSP
FROM SANPHAM
WHERE DVT = 'cay' OR DVT = 'quyen'

-- 3. In ra danh sach cac san pham (MASP,TENSP) co ma san pham bat dau la “B” va ket thuc la “01”.
SELECT MASP, TENSP
FROM SANPHAM 
WHERE LEFT(MASP, 1) = 'B' AND RIGHT(MASP, 2) = '01'

-- 4.In ra danh sach cac san pham (MASP,TENSP) do “Trung Quoc” san xuat co gia tu 30.000 den 40.000.
SELECT MASP, TENSP
FROM SANPHAM 
WHERE NUOCSX = 'Trung Quoc' AND GIA <= 40000 AND GIA >= 30000

-- 5.In ra danh sach cac san pham (MASP,TENSP) do “Trung Quoc” hoac 'Thai Lan' san xuat co gia tu 30.000 den 40.000.
SELECT MASP, TENSP
FROM SANPHAM 
WHERE (NUOCSX = 'Trung Quoc' OR NUOCSX = 'Thai Lan') AND GIA <= 40000 AND GIA >= 30000

-- 6. In ra cac so hoa don, tri gia hoa đon ban ra trong ngay 1/1/2007 và ngay 2/1/2007.

SELECT HOADON.SOHD, HOADON.TRIGIA FROM HOADON 
WHERE HOADON.NGHD = '1/1/2007' OR HOADON.NGHD = '2/1/2007'

-- 7. In ra cac so hoa don, tri gia hoa don trong thang 1/2007, sap xep theo ngay (tang dan) va 
-- tri gia cua hoa don (giam dan).

SELECT SOHD, TRIGIA 
FROM HOADON
WHERE MONTH(NGHD) = 1 AND YEAR(NGHD) = 2007
ORDER BY NGHD ASC, TRIGIA DESC

-- 8. In ra danh sach cac khach hang (MAKH, HOTEN) da mua hang trong ngay 1/1/2007.
SELECT DISTINCT KHACHHANG.MAKH, KHACHHANG.HOTEN
FROM HOADON JOIN KHACHHANG ON HOADON.MAKH = KHACHHANG.MAKH
WHERE NGHD = '1/1/2007'

-- 9. In ra so hoa don, tri gia cac hoa don do nhan vien co ten “Nguyen Van B” lap trong ngay 28/10/2006.
SELECT DISTINCT HOADON.SOHD, HOADON.TRIGIA
FROM HOADON JOIN NHANVIEN ON HOADON.MANV = NHANVIEN.MANV
WHERE NHANVIEN.HOTEN = 'Nguyen Van B' AND HOADON.NGHD = '28/10/2006'

-- 10. In ra danh sach cac san pham (MASP,TENSP) duoc khach hang co ten “Nguyen Van A” mua trong thang 10/2006.
SELECT DISTINCT SANPHAM.MASP, SANPHAM.TENSP
FROM CTHD JOIN HOADON ON CTHD.SOHD = HOADON.SOHD 
JOIN KHACHHANG ON HOADON.MAKH = KHACHHANG.MAKH 
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE KHACHHANG.HOTEN = 'Nguyen Van A' AND MONTH(HOADON.NGHD) = 10

-- 11. Tim cac so hoa don da mua san pham co ma so “BB01” hoac “BB02”.
SELECT DISTINCT CTHD.SOHD
FROM CTHD 
WHERE CTHD.MASP = 'BB01' OR CTHD.MASP = 'BB02'

-- 12. Tim cac so hoa don da mua san pham co ma so “BB01” hoac “BB02”, moi san pham mua voi so luong tu 10 den 20
SELECT DISTINCT CTHD.SOHD
FROM CTHD 
WHERE (CTHD.MASP = 'BB01' OR CTHD.MASP = 'BB02') AND (CTHD.SL BETWEEN 10 AND 20)  

-- 13. Tim cac so hoa don mua cung luc 2 san pham co ma so “BB01” va “BB02”, moi san pham mua voi so luong tu 10 den 20.
SELECT DISTINCT CTHD.SOHD
FROM CTHD
WHERE CTHD.MASP = 'BB01' AND CTHD.SL BETWEEN 10 AND 20
AND EXISTS (
	SELECT * 
	FROM CTHD CTHD2
	WHERE CTHD.SOHD = CTHD2.SOHD AND CTHD2.MASP = 'BB02' AND CTHD2.SL BETWEEN 10 AND 20
	)

-- 14. In ra danh sach cac san pham (MASP,TENSP) do “Trung Quoc” san xuat hoac cac san pham duoc ban ra trong ngay 1/1/2007.
SELECT DISTINCT SANPHAM.MASP, SANPHAM.TENSP
FROM CTHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
WHERE SANPHAM.NUOCSX = 'Trung Quoc' OR HOADON.NGHD = CONVERT(DATE, '1/1/2007')

-- 15. In ra danh sach cac san pham (MASP,TENSP) khong ban duoc.
SELECT MASP, TENSP
FROM SANPHAM 
WHERE NOT EXISTS (SELECT MASP FROM CTHD WHERE CTHD.MASP = SANPHAM.MASP) 

-- 16. In ra danh sach cac san pham (MASP,TENSP) khong ban duoc trong nam 2006.
SELECT MASP, TENSP
FROM SANPHAM
WHERE NOT EXISTS (
	SELECT MASP 
	FROM CTHD 
	JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
	WHERE CTHD.MASP = SANPHAM.MASP AND YEAR(HOADON.NGHD) = 2006
	)

-- 17. In ra danh sach cac san pham (MASP,TENSP) do “Trung Quoc” san xuat khong ban duoc trong nam 2006.
SELECT MASP, TENSP
FROM SANPHAM
WHERE SANPHAM.NUOCSX = 'Trung Quoc' AND NOT EXISTS (
	SELECT MASP 
	FROM CTHD 
	JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
	WHERE CTHD.MASP = SANPHAM.MASP AND YEAR(HOADON.NGHD) = 2006
	)

-- 18. Tim so hoa don da mua tat ca cac san pham do Singapore san xuat.
SELECT HOADON.SOHD
FROM HOADON
WHERE NOT EXISTS (
	SELECT * 
	FROM SANPHAM
	WHERE NUOCSX = 'Singapore' AND NOT EXISTS (
		SELECT * 
		FROM CTHD
		WHERE CTHD.MASP = SANPHAM.MASP AND CTHD.SOHD = HOADON.SOHD
	)
)

-- 19. Tim so hoa don trong nam 2006 da mua it nhat tat ca cac san pham do Singapore san xuat.
-- 20. Co bao nhieu hoa don khong phai cua khach hang dang ky thanh vien mua?
SELECT COUNT(*)
FROM HOADON
WHERE HOADON.MAKH IS NULL

-- 21. Co bao nhieu san pham khac nhau duoc ban ra trong nam 2006.

SELECT COUNT(DISTINCT CTHD.MASP)
FROM CTHD 
JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
WHERE YEAR(HOADON.NGHD) = 2006

-- 22. Cho biet tri gia hoa don cao nhat, thap nhat la bao nhieu ?
SELECT MAX(TRIGIA) AS 'Gia tri cao nhat', MIN(TRIGIA) AS 'Gia tri thap nhat'
FROM HOADON

-- 23. Tri gia trung binh cua tat ca cac hoa don duoc ban ra trong nam 2006 la bao nhieu?
SELECT AVG(TRIGIA) AS 'Tri gia trung binh'
FROM HOADON
WHERE YEAR(HOADON.NGHD) = '2006'

-- 24. Tinh doanh thu ban hang trong nam 2006.
SELECT SUM(TRIGIA) AS 'Doanh thu trong nam 2006' 
FROM HOADON
WHERE YEAR(HOADON.NGHD) = '2006'

-- 25. Tim so hoa don co tri gia cao nhat trong nam 2006.
SELECT TOP 1 WITH TIES HOADON.SOHD
FROM HOADON
WHERE YEAR(HOADON.NGHD) = '2006'
ORDER BY HOADON.TRIGIA DESC

-- 26. Tim ho ten khach hang da mua hoa don co tri gia cao nhat trong nam 2006.
SELECT TOP 1 WITH TIES KHACHHANG.HOTEN
FROM HOADON
JOIN KHACHHANG ON HOADON.MAKH = KHACHHANG.MAKH
WHERE YEAR(HOADON.NGHD) = '2006'
ORDER BY HOADON.TRIGIA DESC

-- 27. In ra danh sach 3 khach hang dau tien (MAKH, HOTEN) sap xep theo doanh so giam dan.
SELECT TOP 3 WITH TIES KHACHHANG.MAKH, KHACHHANG.HOTEN
FROM KHACHHANG 
ORDER BY KHACHHANG.DOANHSO DESC

-- 28. In ra danh sach cac san pham (MASP, TENSP) co gia ban bang 1 trong 3 muc gia cao nhat.
SELECT SANPHAM.MASP, SANPHAM.TENSP
FROM SANPHAM
WHERE SANPHAM.GIA IN (
	SELECT DISTINCT TOP 3 SP2.GIA
	FROM SANPHAM AS SP2
	ORDER BY GIA DESC
)

-- 29. In ra danh sach cac san pham (MASP, TENSP) do “Thai Lan” san xuat co gia bang 1 trong 3 muc gia cao nhat (cua tat ca cac san pham).
SELECT SANPHAM.MASP, SANPHAM.TENSP
FROM SANPHAM
WHERE SANPHAM.NUOCSX = 'Thai Lan' AND SANPHAM.GIA IN (
	SELECT DISTINCT TOP 3 SP2.GIA
	FROM SANPHAM AS SP2
	ORDER BY GIA DESC
)

-- 30. In ra danh sach cac san pham (MASP, TENSP) do “Trung Quoc” san xuat co gia bang 1 trong 3 muc gia cao nhat (cua san pham do “Trung Quoc” san xuat).
SELECT SANPHAM.MASP, SANPHAM.TENSP
FROM SANPHAM
WHERE SANPHAM.NUOCSX = 'Trung Quoc' AND SANPHAM.GIA IN (
	SELECT DISTINCT TOP 3 SP2.GIA
	FROM SANPHAM AS SP2
	WHERE SP2.NUOCSX = 'Trung Quoc'
	ORDER BY GIA DESC
)

-- 31. * In ra danh sach khach hang nam trong 3 hang cao nhat (xep hang theo doanh so).
SELECT TOP 3 WITH TIES *
FROM KHACHHANG
ORDER BY KHACHHANG.DOANHSO DESC

-- 32. Tinh tong so san pham do “Trung Quoc” san xuat.
SELECT COUNT(*)
FROM SANPHAM
WHERE SANPHAM.NUOCSX = 'Trung Quoc'

-- 33. Tinh tong so san pham cua tung nuoc san xuat.
SELECT SANPHAM.NUOCSX, COUNT(*)
FROM SANPHAM
GROUP BY SANPHAM.NUOCSX

-- 34. Voi tung nuoc san xuat, tim gia ban cao nhat, thap nhat, trung binh cua cac san pham.
SELECT SANPHAM.NUOCSX, MAX(GIA) AS 'Max gia', MIN(GIA) AS 'Min gia', AVG(GIA) AS 'Trung binh gia'
FROM SANPHAM
GROUP BY SANPHAM.NUOCSX

-- 35. Tinh doanh thu ban hang moi ngay.
SELECT HOADON.NGHD, SUM(HOADON.TRIGIA)
FROM HOADON
GROUP BY HOADON.NGHD

-- 36. Tinh tong so luong cua tung san pham ban ra trong thang 10/2006.
SELECT SANPHAM.MASP, SANPHAM.TENSP, SUM(SL)
FROM CTHD
JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE YEAR(HOADON.NGHD) = '2006' AND MONTH(HOADON.NGHD) = '10'
GROUP BY SANPHAM.MASP, SANPHAM.TENSP

-- 37. Tinh doanh thu ban hang cua tung thang trong nam 2006.
SELECT MONTH(HOADON.NGHD), SUM(HOADON.TRIGIA)
FROM HOADON
WHERE YEAR(HOADON.NGHD) = '2006'
GROUP BY MONTH(HOADON.NGHD)

-- 38. Tim hoa don co mua it nhat 4 san pham khac nhau.
SELECT *
FROM (SELECT CTHD.SOHD, COUNT(*) AS SOLUONGSP
	FROM CTHD
	GROUP BY CTHD.SOHD) A
WHERE A.SOLUONGSP >= 4

-- 39. Tim hoa don co mua 3 san pham do “Viet Nam” san xuat (3 san pham khac nhau).
SELECT *
FROM (SELECT
	CTHD.SOHD, COUNT(*) AS SOLUONGSPVN
	FROM CTHD
	JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
	WHERE SANPHAM.NUOCSX = 'Viet Nam'
	GROUP BY CTHD.SOHD) A 
WHERE A.SOLUONGSPVN >= 3

-- 40. Tim khach hang (MAKH, HOTEN) co so lan mua hang nhieu nhat. 
SELECT TOP 1 WITH TIES HOADON.MAKH, COUNT(*)
FROM HOADON
JOIN KHACHHANG ON HOADON.MAKH = KHACHHANG.MAKH
GROUP BY HOADON.MAKH
ORDER BY COUNT(*) DESC

-- 41. Thang may trong nam 2006, doanh so ban hang cao nhat ?
SELECT TOP 1 WITH TIES MONTH(HOADON.NGHD), SUM(HOADON.TRIGIA)
FROM HOADON
WHERE YEAR(HOADON.NGHD) = '2006'
GROUP BY MONTH(HOADON.NGHD)
ORDER BY SUM(HOADON.TRIGIA) DESC

-- 42. Tim san pham (MASP, TENSP) co tong so luong ban ra thap nhat trong nam 2006.
SELECT TOP 1 WITH TIES SANPHAM.MASP, SANPHAM.TENSP
FROM CTHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
WHERE YEAR(HOADON.NGHD) = '2006'
GROUP BY SANPHAM.MASP, SANPHAM.TENSP
ORDER BY SUM(CTHD.SL)


-- 43. *Moi nuoc san xuat, tim san pham (MASP,TENSP) co gia ban cao nhat.
SELECT SANPHAM.MASP, SANPHAM.TENSP, SANPHAM.NUOCSX
FROM SANPHAM
WHERE SANPHAM.GIA = (SELECT MAX(SP2.GIA)
	FROM SANPHAM SP2 
	WHERE SP2.NUOCSX = SANPHAM.NUOCSX
)

-- 44. Tim nuoc san xuat san xuat it nhat 3 san pham co gia ban khac nhau.
SELECT DISTINCT SANPHAM.NUOCSX
FROM SANPHAM
WHERE 3 <= (SELECT COUNT(DISTINCT GIA) 
	FROM SANPHAM SP2
	WHERE SP2.NUOCSX = SANPHAM.NUOCSX
)

-- 45. *Trong 10 khach hang co doanh so cao nhat, tim khach hang co so lan mua hang nhieu nhat.
SELECT TOP 1 WITH TIES KHACHHANG.MAKH, COUNT(HOADON.SOHD)
FROM HOADON 
JOIN KHACHHANG ON HOADON.MAKH = KHACHHANG.MAKH
WHERE KHACHHANG.MAKH IN (SELECT TOP 10 KH.MAKH FROM KHACHHANG AS KH ORDER BY DOANHSO DESC)
GROUP BY KHACHHANG.MAKH
ORDER BY COUNT(HOADON.SOHD) DESC