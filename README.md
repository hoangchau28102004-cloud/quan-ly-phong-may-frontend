# Ứng dụng Di động Quản lý Phòng máy - CKCITLAB 🏢💻

Dự án Đồ án Tốt nghiệp: **Hệ thống Quản lý Phòng máy Khoa Công nghệ Thông tin (CKCITLAB)** dành cho Trường Cao đẳng Kỹ thuật Cao Thắng. 
Hệ thống số hóa toàn diện quy trình vận hành phòng thực hành, bao gồm xếp lịch học, điểm danh thông minh qua mã QR, quản lý tài sản phần cứng, mượn trả thiết bị và báo cáo sự cố trực tuyến.

🔗 **Frontend Repository:**  [https://github.com/hoangchau28102004-cloud/quan-ly-phong-may-frontend.git]
🔗 **Backend Repository:**  [https://github.com/hoangchau28102004-cloud/quan-ly-phong-may-backend.git]

---

## 🚀 Công nghệ sử dụng (Tech Stack)
Hệ thống được phát triển đa nền tảng với codebase tối ưu, áp dụng nghiêm ngặt các tiêu chuẩn kiến trúc phần mềm:
*   **Frontend (Mobile):** Flutter (Dart).
*   **Kiến trúc Frontend:** Clean Architecture (Domain, Data, Presentation Layers).
*   **Backend & API:** Node.js (Express framework).
*   **Cơ sở dữ liệu:** MySQL (Quản lý qua Connection Pool).
*   **Bảo mật & Tiện ích:** JSON Web Token (JWT), mã hóa mật khẩu bcryptjs, thư viện `mobile_scanner` (Quét QR), `Freezed` (Data class).

---

## 🌟 Các tính năng chính (Key Features)

### 1. Phân hệ Quản trị viên (Admin)
*   **Quản lý Tài sản:** Nhập máy tính mới (tự động tạo mã QR), xem hồ sơ cấu hình chi tiết (CPU, RAM, SSD), điều chuyển máy giữa các phòng/kho.
*   **Quản lý Lịch & Đặt phòng:** Trực tiếp xếp lịch thực hành, duyệt yêu cầu mượn phòng bổ sung từ giảng viên, phát hiện xung đột lịch.
*   **Quản lý Mượn/Trả:** Tạo phiếu mượn/trả thiết bị, theo dõi lịch sử và số lượng vật tư.
*   **Quản lý Bảo trì:** Tiếp nhận báo cáo hỏng hóc, phân loại sự cố (phần cứng/phần mềm), lập phiếu bảo trì và lưu nhật ký sửa chữa.

### 2. Phân hệ Giảng viên (Lecturer)
*   **Điểm danh thông minh:** Quét mã QR để điểm danh lớp học tự động, kiểm tra tình trạng thiết bị tại bàn.
*   **Nghiệp vụ học vụ:** Xem lịch dạy theo tuần, gửi yêu cầu đăng ký mượn phòng máy cho các ca dạy bù/đồ án.
*   **Quản lý thiết bị:** Tra cứu danh sách phòng máy, cấu hình thiết bị và báo cáo sự cố trực tiếp.

### 3. Phân hệ Sinh viên (Student)
*   **Điểm danh cá nhân:** Sinh viên tự quét mã QR dán trên máy tính để ghi nhận điểm danh và vị trí ngồi.
*   **Hỗ trợ học tập:** Xem tổng quan học phần, tra cứu lịch thực hành chi tiết.
*   **Báo cáo sự cố:** Báo cáo hỏng hóc máy tính nhanh chóng đến ban quản trị ngay trong ca học.

---

## 👥 Đội ngũ Phát triển & Phân công công việc (Contributors)
Dự án được thực hiện dưới sự hướng dẫn của **ThS. Lê Viết Hoàng Nguyên**, với sự phân chia nghiệp vụ chuyên sâu từ Frontend đến Backend:

### 1. Lâm Vũ Hoàng Châu - 0306231094 (Lead Developer)
*   **Phân hệ Admin (Full-stack):** Đảm nhiệm toàn bộ việc thiết kế cơ sở dữ liệu, viết API (Node.js) và lập trình giao diện (Flutter) cho tất cả các nghiệp vụ của Quản trị viên (Quản lý phòng máy, điều chuyển, bảo trì, lịch học, mượn trả thiết bị).
*   **Nền tảng Quét QR & Điểm danh (Full-stack):** Nghiên cứu và hiện thực hóa logic quét mã QR. Phụ trách luồng API và giao diện Điểm danh hộ lớp học (dành cho Giảng viên) và luồng Tự động điểm danh tại máy (dành cho Sinh viên).
*   **Phân hệ Sinh viên:** Cùng phối hợp xây dựng giao diện và ghép nối API cho tài khoản Sinh viên.
*   **Tài liệu:** Tổng hợp sơ đồ ERD, Activity Diagram, Class Diagram và thiết kế luồng xử lý.

### 2. Hà Hoàng Phúc - 0306231140 (Full-stack Developer)
*   **Phân hệ Giảng viên (Full-stack):** Đảm nhiệm viết API và giao diện Flutter cho các tính năng nghiệp vụ của Giảng viên (ngoại trừ tính năng Quét QR và Điểm danh), bao gồm: Xem lịch dạy, đăng ký mượn phòng, tra cứu danh sách phòng và thông tin cá nhân.
*   **Phân hệ Sinh viên:** Cùng phối hợp xây dựng cấu trúc, thiết kế giao diện (Dashboard, Lịch học) và kết nối Backend cho tài khoản Sinh viên.
*   **Triển khai & Kiểm thử:** Phụ trách thiết lập cấu hình Database ban đầu, hỗ trợ deploy hệ thống lên server và kiểm thử luồng Use Case thực tế.

---

## 📷 Hình ảnh Demo (Screenshots)
*   [Admin: Nhập máy & Quản lý thiết bị]  (https://drive.google.com/file/d/1IdaSeyHzI_6C39qj3q9wjkXX3o3ULNwl/view?usp=drive_link)
*   [Admin: Quản lý & Xếp lịch dạy phòng máy]  (https://drive.google.com/file/d/1Zg2Qq8fM0sLPoks643D6W3iESU8ErGF2/view?usp=drive_link)
*   [Giảng viên: Xem lịch & Điểm danh lớp học]  (https://drive.google.com/file/d/1hD394TSgE_cx9HSWR0lFwbVNHvqEp2I4/view?usp=drive_link)

## ⚙️ Hướng dẫn cài đặt (Installation)
**1. Khởi chạy Backend (Node.js)**
```bash
cd backend
npm install
npm run start
