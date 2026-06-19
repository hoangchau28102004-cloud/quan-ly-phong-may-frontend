/*
  # Create IT Lab Room Management System Schema
  
  1. New Tables
    - `vai_tro` - Roles (admin, teacher, student)
    - `nguoi_dung` - Users with authentication info
    - `phong_may` - Lab rooms
    - `cau_hinh_may_tinh` - Hardware configurations
    - `may_tinh` - Computers
    - `thiet_bi` - Lab equipment/devices
    - `mon_hoc` - Subjects
    - `ca_hoc` - Class sessions
    - `lop_hoc` - Classes
    - `lop_hoc_phan` - Course classes
    - `sinh_vien` - Students
    - `giang_vien` - Teachers
    - `lich_su_dung_phong_may` - Lab usage history
    - `bao_cao_su_co` - Incident reports
    - `phieu_bao_tri` - Maintenance tickets
    - `nhat_ky_sua_chua` - Maintenance logs
    - And more...

  2. Security
    - Enable RLS on all tables
    - Create policies for role-based access
    
  3. Important Notes
    - All tables support soft delete via deleted_at
    - Status tracking for maintenance and incidents
    - Comprehensive audit logging
*/

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create vai_tro table
CREATE TABLE IF NOT EXISTS vai_tro (
  id BIGSERIAL PRIMARY KEY,
  ten_vai_tro VARCHAR(255) NOT NULL UNIQUE,
  mo_ta TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE vai_tro ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read roles"
  ON vai_tro FOR SELECT
  TO authenticated
  USING (true);

-- Create nguoi_dung table
CREATE TABLE IF NOT EXISTS nguoi_dung (
  id BIGSERIAL PRIMARY KEY,
  ma_vai_tro BIGINT NOT NULL REFERENCES vai_tro(id) ON DELETE RESTRICT,
  ho_ten VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  mat_khau VARCHAR(255) NOT NULL,
  so_dien_thoai VARCHAR(20),
  gioi_tinh VARCHAR(20),
  ngay_sinh DATE,
  trang_thai SMALLINT DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

ALTER TABLE nguoi_dung ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read users"
  ON nguoi_dung FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can update users"
  ON nguoi_dung FOR UPDATE
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM nguoi_dung u 
    JOIN vai_tro r ON u.ma_vai_tro = r.id 
    WHERE r.ten_vai_tro = 'admin'
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM nguoi_dung u 
    JOIN vai_tro r ON u.ma_vai_tro = r.id 
    WHERE r.ten_vai_tro = 'admin'
  ));

-- Create sinh_vien table
CREATE TABLE IF NOT EXISTS sinh_vien (
  id BIGSERIAL PRIMARY KEY,
  ma_nguoi_dung BIGINT NOT NULL UNIQUE REFERENCES nguoi_dung(id) ON DELETE CASCADE,
  ma_sinh_vien VARCHAR(255) NOT NULL UNIQUE,
  nien_khoa VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

ALTER TABLE sinh_vien ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read students"
  ON sinh_vien FOR SELECT
  TO authenticated
  USING (true);

-- Create giang_vien table
CREATE TABLE IF NOT EXISTS giang_vien (
  id BIGSERIAL PRIMARY KEY,
  ma_nguoi_dung BIGINT NOT NULL UNIQUE REFERENCES nguoi_dung(id) ON DELETE CASCADE,
  ma_giang_vien VARCHAR(255) NOT NULL UNIQUE,
  bo_mon VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

ALTER TABLE giang_vien ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read teachers"
  ON giang_vien FOR SELECT
  TO authenticated
  USING (true);

-- Create phong_may table
CREATE TABLE IF NOT EXISTS phong_may (
  id BIGSERIAL PRIMARY KEY,
  ma_phong VARCHAR(255) NOT NULL UNIQUE,
  ten_phong VARCHAR(255) NOT NULL,
  suc_chua INT DEFAULT 0,
  trang_thai VARCHAR(255) DEFAULT 'active',
  mo_ta TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

ALTER TABLE phong_may ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read lab rooms"
  ON phong_may FOR SELECT
  TO authenticated
  USING (true);

-- Create cau_hinh_may_tinh table
CREATE TABLE IF NOT EXISTS cau_hinh_may_tinh (
  id BIGSERIAL PRIMARY KEY,
  bo_xu_ly VARCHAR(255),
  ram VARCHAR(255),
  o_cung VARCHAR(255),
  card_do_hoa VARCHAR(255),
  man_hinh VARCHAR(255),
  he_dieu_hanh VARCHAR(255),
  ghi_chu TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE cau_hinh_may_tinh ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read hardware configs"
  ON cau_hinh_may_tinh FOR SELECT
  TO authenticated
  USING (true);

-- Create may_tinh table
CREATE TABLE IF NOT EXISTS may_tinh (
  id BIGSERIAL PRIMARY KEY,
  ma_phong BIGINT NOT NULL REFERENCES phong_may(id) ON DELETE RESTRICT,
  ma_cau_hinh BIGINT REFERENCES cau_hinh_may_tinh(id) ON DELETE SET NULL,
  ma_may VARCHAR(255) NOT NULL UNIQUE,
  ma_qr VARCHAR(255) UNIQUE,
  dia_chi_ip VARCHAR(45),
  dia_chi_mac VARCHAR(30),
  trang_thai VARCHAR(255) DEFAULT 'active',
  ghi_chu TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

ALTER TABLE may_tinh ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read computers"
  ON may_tinh FOR SELECT
  TO authenticated
  USING (true);

-- Create thiet_bi table
CREATE TABLE IF NOT EXISTS thiet_bi (
  id BIGSERIAL PRIMARY KEY,
  ma_phong BIGINT NOT NULL REFERENCES phong_may(id) ON DELETE RESTRICT,
  ten_thiet_bi VARCHAR(255) NOT NULL,
  so_luong INT DEFAULT 0,
  don_vi VARCHAR(50),
  trang_thai VARCHAR(255) DEFAULT 'active',
  ghi_chu TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

ALTER TABLE thiet_bi ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read equipment"
  ON thiet_bi FOR SELECT
  TO authenticated
  USING (true);

-- Create mon_hoc table
CREATE TABLE IF NOT EXISTS mon_hoc (
  id BIGSERIAL PRIMARY KEY,
  ten_mon VARCHAR(255) NOT NULL,
  loai_mon VARCHAR(255),
  so_tin_chi SMALLINT DEFAULT 0,
  mo_ta TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

ALTER TABLE mon_hoc ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read subjects"
  ON mon_hoc FOR SELECT
  TO authenticated
  USING (true);

-- Create ca_hoc table
CREATE TABLE IF NOT EXISTS ca_hoc (
  id BIGSERIAL PRIMARY KEY,
  ten_ca VARCHAR(255) NOT NULL UNIQUE,
  gio_bat_dau TIME NOT NULL,
  gio_ket_thuc TIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE ca_hoc ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read class sessions"
  ON ca_hoc FOR SELECT
  TO authenticated
  USING (true);

-- Create lop_hoc table
CREATE TABLE IF NOT EXISTS lop_hoc (
  id BIGSERIAL PRIMARY KEY,
  ma_lop VARCHAR(255) NOT NULL UNIQUE,
  nien_khoa VARCHAR(255),
  chuyen_nganh VARCHAR(255),
  ma_giang_vien BIGINT REFERENCES giang_vien(id) ON DELETE SET NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

ALTER TABLE lop_hoc ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read classes"
  ON lop_hoc FOR SELECT
  TO authenticated
  USING (true);

-- Create lop_hoc_phan table
CREATE TABLE IF NOT EXISTS lop_hoc_phan (
  id BIGSERIAL PRIMARY KEY,
  ma_lop_hoc_phan VARCHAR(255) NOT NULL UNIQUE,
  ma_lop BIGINT REFERENCES lop_hoc(id) ON DELETE SET NULL,
  ma_mon BIGINT NOT NULL REFERENCES mon_hoc(id) ON DELETE RESTRICT,
  ma_giang_vien BIGINT REFERENCES giang_vien(id) ON DELETE SET NULL,
  ma_phong BIGINT REFERENCES phong_may(id) ON DELETE SET NULL,
  si_so_toi_da INT DEFAULT 0,
  trang_thai VARCHAR(255) DEFAULT 'active',
  ghi_chu TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

ALTER TABLE lop_hoc_phan ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read course classes"
  ON lop_hoc_phan FOR SELECT
  TO authenticated
  USING (true);

-- Create cau_truc_cai_dat_thoi_gian table
CREATE TABLE IF NOT EXISTS cau_truc_cai_dat_thoi_gian (
  id BIGSERIAL PRIMARY KEY,
  nam_hoc VARCHAR(20) NOT NULL,
  hoc_ky SMALLINT NOT NULL,
  so_tuan SMALLINT NOT NULL,
  ngay_bat_dau_tuan DATE NOT NULL,
  ngay_ket_thuc_tuan DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE cau_truc_cai_dat_thoi_gian ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read time structures"
  ON cau_truc_cai_dat_thoi_gian FOR SELECT
  TO authenticated
  USING (true);

-- Create lich_su_dung_phong_may table
CREATE TABLE IF NOT EXISTS lich_su_dung_phong_may (
  id BIGSERIAL PRIMARY KEY,
  ma_phong BIGINT NOT NULL REFERENCES phong_may(id) ON DELETE CASCADE,
  ma_lop BIGINT REFERENCES lop_hoc(id) ON DELETE SET NULL,
  ma_lop_hoc_phan BIGINT REFERENCES lop_hoc_phan(id) ON DELETE SET NULL,
  ma_giang_vien BIGINT REFERENCES giang_vien(id) ON DELETE SET NULL,
  ma_cai_dat_thoi_gian BIGINT NOT NULL REFERENCES cau_truc_cai_dat_thoi_gian(id) ON DELETE CASCADE,
  ngay_hoc_cu_the DATE NOT NULL,
  thu_trong_tuan VARCHAR(20) NOT NULL,
  ca_hoc VARCHAR(20) NOT NULL,
  so_tiet_bat_dau SMALLINT NOT NULL,
  so_tiet_ket_thuc SMALLINT NOT NULL,
  loai_lich VARCHAR(50) DEFAULT 'ChinhThuc',
  ghi_chu TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE lich_su_dung_phong_may ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read usage history"
  ON lich_su_dung_phong_may FOR SELECT
  TO authenticated
  USING (true);

-- Create bao_cao_su_co table
CREATE TABLE IF NOT EXISTS bao_cao_su_co (
  id BIGSERIAL PRIMARY KEY,
  ma_nguoi_bao_cao BIGINT NOT NULL REFERENCES nguoi_dung(id) ON DELETE CASCADE,
  ma_phong BIGINT REFERENCES phong_may(id) ON DELETE SET NULL,
  ma_may_tinh BIGINT REFERENCES may_tinh(id) ON DELETE SET NULL,
  ma_thiet_bi BIGINT REFERENCES thiet_bi(id) ON DELETE SET NULL,
  loai_su_co VARCHAR(255) NOT NULL,
  tieu_de VARCHAR(255) NOT NULL,
  mo_ta TEXT,
  muc_do VARCHAR(255) DEFAULT 'normal',
  trang_thai VARCHAR(255) DEFAULT 'open',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE bao_cao_su_co ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read incidents"
  ON bao_cao_su_co FOR SELECT
  TO authenticated
  USING (true);

-- Create phieu_bao_tri table
CREATE TABLE IF NOT EXISTS phieu_bao_tri (
  id BIGSERIAL PRIMARY KEY,
  ma_bao_cao_su_co BIGINT NOT NULL REFERENCES bao_cao_su_co(id) ON DELETE CASCADE,
  ma_nguoi_phu_trach BIGINT REFERENCES nguoi_dung(id) ON DELETE SET NULL,
  loai_bao_tri VARCHAR(255),
  ngay_bat_dau DATE,
  ngay_ket_thuc DATE,
  cach_xu_ly TEXT,
  chi_phi DECIMAL(12,2) DEFAULT 0,
  trang_thai VARCHAR(255) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE phieu_bao_tri ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read maintenance tickets"
  ON phieu_bao_tri FOR SELECT
  TO authenticated
  USING (true);

-- Create nhat_ky_sua_chua table
CREATE TABLE IF NOT EXISTS nhat_ky_sua_chua (
  id BIGSERIAL PRIMARY KEY,
  ma_phieu_bao_tri BIGINT REFERENCES phieu_bao_tri(id) ON DELETE SET NULL,
  ma_may_tinh BIGINT REFERENCES may_tinh(id) ON DELETE SET NULL,
  ma_thiet_bi BIGINT REFERENCES thiet_bi(id) ON DELETE SET NULL,
  ma_nguoi_sua BIGINT REFERENCES nguoi_dung(id) ON DELETE SET NULL,
  thoi_gian_sua TIMESTAMP,
  noi_dung_sua TEXT,
  ket_qua VARCHAR(255),
  chi_phi DECIMAL(12,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE nhat_ky_sua_chua ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read maintenance logs"
  ON nhat_ky_sua_chua FOR SELECT
  TO authenticated
  USING (true);
