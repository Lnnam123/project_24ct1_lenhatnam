# 🌟 CoinTap Admin Portal (React + Vite + Supabase)

Ứng dụng web quản trị dành cho hệ thống **CoinTap (Quản lý chi tiêu & Trợ lý tài chính AI)**, được xây dựng bằng **React + Vite** trên nền tảng **Node.js** phục vụ đồ án môn học Công nghệ phần mềm.

---

## 🎨 Điểm Nổi Bật Của Bản React
- **React 19 / 18 + Vite**: Tốc độ phản hồi và biên dịch tức thì, kiến trúc Component hóa chuẩn mực (`Sidebar`, `Topbar`, `StatCard`, `Modal`,...).
- **Icon sắc nét**: Tích hợp thư viện vector icon hiện đại `lucide-react`.
- **Biểu đồ động**: Sử dụng `chart.js` và `react-chartjs-2` hiển thị dòng tiền Thu - Chi và tỷ trọng danh mục.
- **Kết nối đám mây Supabase**: Đọc và ghi dữ liệu thời gian thực từ cơ sở dữ liệu Supabase PostgreSQL.
- **Phong cách đồng bộ 100% với Mobile App**: Tông màu tím hoàng gia (`#7C4DFF` đến `#9C27B0`), hiệu ứng kính mờ Glassmorphism, font chữ Manrope.

---

## 🚀 7 Module Quản Trị Nghiệp Vụ
1. 📊 **Dashboard Tổng Quan**: 4 Thẻ KPI thống kê thời gian thực + 2 Biểu đồ tương tác + Live feed 5 giao dịch gần nhất.
2. 👥 **Quản Lý Người Dùng**: Danh sách người dùng di động, tìm kiếm tức thì, modal xem chi tiết các ví tiền & lịch sử giao dịch, quyền xóa tài khoản.
3. 🛡️ **Quản Lý Quản Trị Viên**: Tách riêng biệt bảng `admins`, phân quyền (Super Admin / Administrator), cấp tài khoản cho thành viên quản trị mới.
4. 💸 **Giám Sát Giao Dịch**: Xem toàn bộ dòng tiền với bộ lọc linh hoạt: *Tất cả*, *Chỉ khoản chi*, *Chỉ khoản thu*, *Chuyển khoản*.
5. 🗂️ **Danh Mục Mẫu**: Thêm, chỉnh sửa, xóa các danh mục chi tiêu mặc định dùng chung toàn hệ thống.
6. 🤖 **Nhật Ký Trợ Lý AI**: Xem danh sách các phiên trò chuyện của người dùng với Gemini AI và mở modal xem lại toàn bộ chuỗi hỏi đáp.
7. 🔔 **Phát Thông Báo**: Bắn thông báo đẩy toàn hệ thống trực tiếp đến điện thoại của tất cả người dùng ứng dụng.

---

## 🔐 Tài Khoản Đăng Nhập Quản Trị (Bảng Riêng `admins`)
Hệ thống sử dụng bảng riêng biệt `admins` để quản lý tài khoản quản trị:
- **Tài khoản quản trị viên mặc định:**
  - **Tên đăng nhập:** `admin`
  - **Mật khẩu:** `admin`
- **File SQL tạo bảng Supabase:** [database/schema_admins.sql](file:///d:/DaiHoc/Nam3/congnghephanmem/project_24ct_lenhatnam/database/schema_admins.sql)
  *(Có nút sao chép 1-click ngay trong màn hình Quản trị viên để dán vào Supabase SQL Editor)*.
- **Tính năng thêm Quản trị viên:** Cho phép tạo thêm nhiều tài khoản quản trị viên mới với vai trò `Super Admin` hoặc `Administrator`.
- **Đăng xuất:** Nút Đăng xuất được bố trí cả ở góc dưới thanh Sidebar và thanh Topbar.



---

## 💻 Hướng Dẫn Khởi Chạy Web Admin

Mở terminal tại thư mục `web_admin` và chạy các lệnh sau:

### 1. Cài đặt thư viện (nếu clone máy mới):
```bash
npm install
```

### 2. Khởi chạy môi trường phát triển (Dev Server):
```bash
npm run dev
```
Sau đó mở trình duyệt truy cập vào địa chỉ hiển thị trên terminal (thường là: **`http://localhost:5173`**).

### 3. Đóng gói cho môi trường Production (nếu cần):
```bash
npm run build
```
Thư mục `dist/` sau khi build có thể triển khai lên Vercel, Netlify hoặc bất kỳ hosting nào chỉ trong vài cú click!

