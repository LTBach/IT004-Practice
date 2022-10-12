﻿CREATE DATABASE QuanLyBanHang;
USE QuanLyBanHang;

CREATE TABLE KHACHHANG
(
	MAKH char(4),
	HOTEN varchar(40),
	DCHI varchar(50),
	SODT char(20),
	NGSINH smalldatetime,
	DOANHSO money,
	NGDK smalldatetime,
	CONSTRAINT PK_KHACHHANG PRIMARY KEY (MAKH),
);

CREATE TABLE　NHANVIEN 
(
	MANV char(4),
	HOTEN varchar(40),
	SODT char(20),
	NGVL smalldatetime,
	CONSTRAINT PK_NHANVIEN PRIMARY KEY (MANV),
);

CREATE TABLE SANPHAM
(
	MASP char(4),
	TENSP varchar(40),
	DVT varchar(20),
	NUOCSX varchar(40),
	GIA money,
	CONSTRAINT PK_SANPHAM PRIMARY KEY (MASP)
);

CREATE TABLE HOADON
(
	SOHD int,
	NGHD smalldatetime,
	MAKH char(4),
	MANV char(4) FOREIGN KEY REFERENCES NHANVIEN(MANV),
	TRIGIA money,
	CONSTRAINT FK_HOADON_KHACHHANG FOREIGN KEY HOADON(MAKH) REFERENCES KHACHHANG(MAKH),
	CONSTRAINT PK_HOADON PRIMARY KEY (SOHD),
);

CREATE TABLE CTHD
(
	SOHD int FOREIGN KEY REFERENCES HOADON(SOHD),
	MASP char(4) FOREIGN KEY REFERENCES SANPHAM(MASP),
	SL int,
	CONTRAINT PK_CTHD PRIMARY KEY (SOHD,MASP)
);

--2
ALTER TABLE SANPHAM
ADD GHICHU varchar(20);
--3
ALTER TABLE KHACHHANG
ADD LOAIKH tinyint;
--4
ALTER TABLE SANPHAM
ALTER COLUMN GHICHU varchar(100);
--5
ALTER TABLE SANPHAM
DROP COLUMN GHICHU
--6
ALTER TABLE KHACHHANG
ALTER COLUMN LOAIKH varchar(50);
--7
ALTER TABLE SANPHAM
ADD CONSTRAINT DVT_CONSTRAINT CHECK (DVT = 'cay' OR DVT = 'hop' OR DVT = 'cai' OR DVT = 'quyen' OR DVT = 'chuc');
--8
ALTER TABLE SANPHAM
ADD CONSTRAINT GIA_CONSTRAINT CHECK (GIA >= 500);
--10
ALTER TABLE KHACHHANG
ADD CONSTRAINT VILID_CONSTRAINT CHECK (NGDK > NGSINH);

USE master;
DROP DATABASE QuanLyBanHang;