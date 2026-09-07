# CoinTap - Hệ Thống Quản Lý Tài Chính Cá Nhân Thông Minh & Cổng Quản Trị AI

> **Phiên bản hiện tại**: `v1.5.3` (Build `+11`)  
> **Nền tảng**: Ứng dụng Di động Flutter (Android / iOS) & Cổng Quản trị Web Admin (React + Vite)  
> **Cơ sở dữ liệu**: Supabase (PostgreSQL) với bảo mật cấp hàng (RLS)  
> **Trí tuệ nhân tạo**: Trợ lý tài chính tích hợp Google Gemini AI  

---

## 🌟 Giới Thiệu Dự Án

**CoinTap** là giải pháp toàn diện hỗ trợ người dùng theo dõi dòng tiền, quản lý ngân sách và tư vấn chi tiêu thông minh. Hệ thống bao gồm 2 thành phần cốt lõi:
1. **Ứng dụng Di động CoinTap Mobile (Flutter)**: Dành cho người dùng cá nhân quản lý thu chi hàng ngày, biểu đồ phân tích, ví tiền, trò chuyện với Trợ lý AI và tự động nhận bản cập nhật mới trực tiếp qua OTA.
2. **Cổng Quản trị CoinTap Web Admin (React + Vite)**: Dành cho Quản trị viên giám sát tình trạng hệ thống, quản lý người dùng & quản trị viên, theo dõi lưu lượng truy vấn AI (KeyStream Metrics), quản lý kho biểu tượng danh mục chuẩn Google Material Icons và phát thông báo toàn ứng dụng.

---

## 🚀 Tính Năng Nổi Bật

### 1. Ứng dụng Di động (CoinTap Mobile)
- **Quản lý thu chi & Giao dịch**: Thêm, sửa, xóa các khoản chi tiêu/thu nhập nhanh chóng kèm phân loại danh mục, ví nguồn và ghi chú.
- **Trợ lý Tài chính AI (Gemini AI)**: Tích hợp nút chat nổi (floating chatbot), phân tích thói quen tiêu dùng, đưa ra lời khuyên tối ưu ngân sách theo thời gian thực.
- **Phân tích & Báo cáo trực quan**: Biểu đồ phân bổ chi tiêu, thống kê dòng tiền theo tuần, tháng, năm.
- **Ví tiền & Hạn mức Ngân sách**: Quản lý nhiều tài khoản/ví, cảnh báo khi chi tiêu chạm ngưỡng ngân sách đặt ra.
- **Đồng bộ Thư viện Biểu tượng**: Tự động nhận diện và hiển thị các biểu tượng danh mục phong phú do Admin thêm vào từ Web.
- **Cập nhật tự động (OTA Update)**: Kiểm tra và tải bản cập nhật `.apk` mới nhất trực tiếp từ GitHub Releases mà không cần thông qua Google Play Store.
- **Bảo mật & Đăng nhập nhanh**: Hỗ trợ đăng nhập nhanh bằng mã PIN, xác thực OTP qua Email, khôi phục mật khẩu an toàn.

### 2. Cổng Quản trị (CoinTap Web Admin)
- **Bảng Điều khiển Tổng quan**: Theo dõi thời gian thực số lượng tài khoản, số phiên AI, tổng tokens tiêu thụ và giám sát tình trạng hạ tầng/dịch vụ (Supabase, Gemini AI, Push Service, Client App).
- **Quản lý Người dùng & Trạng thái**: Tra cứu người dùng, kiểm soát trạng thái tài khoản (*Hoạt động*, *Tạm ngưng*, *Khóa*, *Xóa*) và đồng bộ thông báo tức thì về thiết bị di động.
- **Quản lý Danh mục & Biểu tượng**: Quản lý danh mục thu/chi toàn hệ thống, tích hợp bộ sưu tập biểu tượng Google Material Symbols đa dạng và tự động đồng bộ sang ứng dụng di động.
- **Giám sát & Nhật ký Trí tuệ Nhân tạo (Gemini AI)**: Giám sát lưu lượng KeyStream, lịch sử truy vấn 7 ngày qua, phân bổ model (`gemini-flash-latest`, `gemini-2.5-flash`), chi phí ước tính (USD/VND) và chi tiết từng phiên hội thoại.
- **Phát Thông báo Toàn ứng dụng**: Soạn thảo và gửi thông báo bảo trì, cập nhật phiên bản hoặc tin tức quan trọng tới toàn bộ người dùng.
- **Chính sách Quyền riêng tư Zero-Knowledge**: Kiến trúc hệ thống cam kết tôn trọng quyền riêng tư, không thu thập dữ liệu giao dịch nhạy cảm của người dùng.

---

## 📂 Cấu Trúc Cây Thư Mục (Project Directory Tree)

```text
project_24ct_lenhatnam/
├── android/                             # Mã nguồn Native Android & cấu hình build Gradle
├── database/                            # Kịch bản cơ sở dữ liệu Supabase (PostgreSQL)
│   ├── database_tieng_viet.sql          # Schema CSDL chuẩn hóa tiếng Việt toàn hệ thống
│   ├── schema.sql                       # Schema ban đầu
│   ├── schema_admins.sql                # Bảng quản trị viên và phân quyền
│   ├── schema_ai_chat.sql               # Bảng lưu trữ cuộc trò chuyện và tin nhắn AI
│   └── supabase_database_export.sql     # Bản xuất dữ liệu mẫu
├── lib/                                 # MÃ NGUỒN CHÍNH ỨNG DỤNG FLUTTER MOBILE
│   ├── chu_de/                          # Cấu hình chủ đề, bảng màu giao diện
│   │   └── mau_sac.dart
│   ├── dich_vu/                         # Các dịch vụ kết nối ngoại vi
│   │   ├── email_service.dart           # Dịch vụ gửi email xác thực / OTP
│   │   ├── notification_service.dart    # Dịch vụ thông báo nội bộ
│   │   ├── time_service.dart            # Định dạng và xử lý thời gian
│   │   └── update_service.dart          # Kiểm tra và tải bản cập nhật OTA (GitHub Releases)
│   ├── du_lieu/                         # Tầng kết nối & truy vấn CSDL Supabase
│   │   └── database_helper.dart
│   ├── man_hinh/                        # Các màn hình giao diện người dùng (Screens)
│   │   ├── bao_cao.dart                 # Màn hình báo cáo & biểu đồ tài chính
│   │   ├── cai_dat.dart                 # Màn hình cài đặt & kiểm tra phiên bản
│   │   ├── chi_tiet_giao_dich.dart      # Xem & chỉnh sửa giao dịch
│   │   ├── chi_tiet_phan_tich.dart      # Phân tích sâu từng khoản mục chi tiêu
│   │   ├── chi_tiet_thu_chi.dart        # Danh sách lịch sử thu chi
│   │   ├── chi_tiet_vi.dart             # Quản lý số dư và giao dịch theo từng ví
│   │   ├── dang_ky.dart                 # Đăng ký tài khoản mới
│   │   ├── dang_nhap.dart               # Đăng nhập bằng Email/Mật khẩu
│   │   ├── dang_nhap_nhanh.dart         # Đăng nhập nhanh bằng mã PIN cá nhân
│   │   ├── dat_lai_mat_khau.dart        # Thiết lập lại mật khẩu sau OTP
│   │   ├── dieu_khoan.dart              # Điều khoản sử dụng & chính sách bảo mật
│   │   ├── doi_mat_khau.dart            # Đổi mật khẩu trong cài đặt
│   │   ├── quan_ly_danh_muc.dart        # Danh sách danh mục thu chi
│   │   ├── quan_ly_ngan_sach.dart       # Quản lý hạn mức chi tiêu theo tháng
│   │   ├── quen_mat_khau.dart           # Gửi mã xác nhận quên mật khẩu
│   │   ├── them_danh_muc.dart           # Tạo mới danh mục kèm chọn icon phong phú
│   │   ├── thong_bao.dart               # Hộp thư thông báo hệ thống
│   │   ├── thong_tin_ca_nhan.dart       # Xem và chỉnh sửa hồ sơ người dùng
│   │   ├── tong_quan.dart               # Màn hình chính Dashboard tổng quan
│   │   ├── tro_ly_ai.dart               # Giao diện hội thoại tương tác với Gemini AI
│   │   ├── vi_tien.dart                 # Danh sách các tài khoản / ví thanh toán
│   │   └── xac_thuc_otp.dart            # Màn hình nhập mã xác thực OTP 6 số
│   ├── mo_hinh/                         # Các mô hình dữ liệu (Models)
│   │   └── du_lieu.dart                 # NguoiDung, GiaoDich, DanhMuc, ViTien, NganSach...
│   ├── thanh_phan/                      # Các thành phần giao diện tái sử dụng (Components)
│   │   ├── modal_doi_danh_muc.dart      # Bottom sheet chuyển đổi danh mục
│   │   ├── modal_ngan_sach.dart         # Hộp thoại tạo/sửa ngân sách
│   │   ├── modal_quan_ly_vi_tien.dart   # Hộp thoại tạo/sửa ví tiền
│   │   ├── modal_them_giao_dich.dart    # Giao diện ghi nhanh giao dịch thu/chi
│   │   ├── nut_ai_chat_floating.dart    # Nút nổi AI Chatbot tương tác nhanh
│   │   └── skeleton_loading.dart        # Hiệu ứng mờ chuyển động khi tải dữ liệu
│   ├── tien_ich/                        # Tiện ích bổ trợ (Utilities)
│   │   └── bieu_tuong_helper.dart       # Bảng ánh xạ icon Google Material Symbols
│   └── main.dart                        # Điểm khởi chạy ứng dụng Flutter & định tuyến
├── web_admin/                           # MÃ NGUỒN CỔNG QUẢN TRỊ COINTAP WEB ADMIN (REACT)
│   ├── public/                          # Tài nguyên tĩnh
│   ├── src/
│   │   ├── assets/                      # Hình ảnh, SVG, logo
│   │   ├── dich_vu/                     # Tầng giao tiếp API & Supabase
│   │   │   ├── api.js                   # API nghiệp vụ người dùng, danh mục, AI, thống kê
│   │   │   └── supabase.js              # Khởi tạo kết nối Supabase Client
│   │   ├── man_hinh/                    # Các trang chức năng chính của Quản trị viên
│   │   │   ├── DangNhap.jsx             # Đăng nhập bảo mật trang Quản trị
│   │   │   ├── DanhMuc.jsx              # Quản lý danh mục & kho biểu tượng Google Icons
│   │   │   ├── NguoiDung.jsx            # Quản lý người dùng, trạng thái tài khoản
│   │   │   ├── NhatKyAI.jsx             # Giám sát hội thoại AI, KeyStream, biểu đồ 7 ngày
│   │   │   ├── QuanTriVien.jsx          # Quản lý danh sách tài khoản Admin
│   │   │   ├── ThongBao.jsx             # Phát thông báo toàn hệ thống
│   │   │   └── TongQuan.jsx             # Dashboard tổng quan chỉ số & giám sát hạ tầng
│   │   ├── thanh_phan/                  # Các component giao diện dùng chung
│   │   │   ├── HopThoai.jsx             # Modal dialog tùy biến
│   │   │   ├── HopThoaiXacNhan.jsx      # Hộp thoại xác nhận thao tác quan trọng
│   │   │   ├── ThanhBen.jsx             # Sidebar điều hướng trang
│   │   │   ├── ThanhTren.jsx            # Header hiển thị thông tin admin, chế độ sáng/tối
│   │   │   └── TheThongKe.jsx           # Card hiển thị chỉ số thống kê
│   │   ├── App.css                      # Phong cách thiết kế chính
│   │   ├── App.jsx                      # Định tuyến và khung ứng dụng Admin
│   │   ├── index.css                    # Design system tokens và biến giao diện
│   │   └── main.jsx                     # Điểm khởi chạy React (Entry point)
│   ├── index.html                       # HTML gốc cho Web Admin
│   ├── package.json                     # Quản lý phụ thuộc Node.js (v1.5.3)
│   └── vite.config.js                   # Cấu hình đóng gói Vite
├── pubspec.yaml                         # Quản lý cấu hình & phiên bản Flutter (1.5.3+11)
└── README.md                            # Tài liệu hướng dẫn toàn diện dự án
```

---

## 🛠️ Hướng Dẫn Cài Đặt & Khởi Chạy

### 1. Yêu Cầu Môi Trường
- **Flutter SDK**: `>= 3.13.0`
- **Node.js**: `>= 18.0.0`
- **Android SDK**: `compileSdk 37` (hỗ trợ Java 8 `coreLibraryDesugaring`)

---

### 2. Cài Đặt & Chạy Ứng Dụng Flutter Mobile

```bash
# 1. Cài đặt các thư viện Dart phụ thuộc
flutter pub get

# 2. Kiểm tra thiết bị kết nối (máy ảo hoặc thiết bị thật)
flutter devices

# 3. Khởi chạy ứng dụng ở chế độ Debug
flutter run
```

---

### 3. Cài Đặt & Chạy Cổng Quản Trị Web Admin

```bash
# 1. Di chuyển vào thư mục web_admin
cd web_admin

# 2. Cài đặt các gói phụ thuộc
npm install

# 3. Chạy máy chủ phát triển (Dev Server)
npm run dev

# 4. Kiểm tra mã nguồn (Linter)
npm run lint

# 5. Đóng gói bản phát hành sản phẩm (Production Build)
npm run build
```

---

## 🔄 Hướng Dẫn Phát Hành Bản Cập Nhật Tự Động (OTA Update)

Hệ thống cập nhật OTA cho phép người dùng nhận phiên bản mới trực tiếp từ **GitHub Releases**:

1. Tăng số phiên bản trong [pubspec.yaml](file:///d:/DaiHoc/Nam3/congnghephanmem/project_24ct_lenhatnam/pubspec.yaml) (ví dụ: `1.5.3+11`).
2. Đóng gói file APK ứng dụng:
   ```bash
   flutter build apk --release
   ```
3. Tạo một **Release** mới trên kho lưu trữ GitHub (ví dụ: Tag `v1.5.3`).
4. Đính kèm file `app-release.apk` (nằm trong `build/app/outputs/flutter-apk/app-release.apk`) vào bản Release đó.
5. Khi người dùng mở ứng dụng và vào mục **Cài đặt ➜ Kiểm tra cập nhật**, CoinTap sẽ tự động đối chiếu số phiên bản, hiển thị hộp thoại cập nhật và tải về cài đặt tự động.

---

## 📄 Bản Quyền & Giấy Phép

Dự án được xây dựng và phát triển phục vụ mục đích học tập, nghiên cứu môn **Công Nghệ Phần Mềm**. Mọi quyền được bảo lưu.
