/*
  # Insert initial roles and sample data
  
  1. Add default roles: admin, teacher, student
  2. Add sample time structure for academic year
*/

INSERT INTO vai_tro (ten_vai_tro, mo_ta) VALUES
('admin', 'Quản trị viên hệ thống'),
('teacher', 'Giảng viên'),
('student', 'Sinh viên')
ON CONFLICT (ten_vai_tro) DO NOTHING;

INSERT INTO ca_hoc (ten_ca, gio_bat_dau, gio_ket_thuc) VALUES
('Ca sáng', '06:30:00', '11:25:00'),
('Ca chiều', '12:30:00', '17:30:00')
ON CONFLICT (ten_ca) DO NOTHING;
