# CoinTap (appandroid)

Ứng dụng quản lý tài chính cá nhân thông minh, hỗ trợ theo dõi thu chi, phân tích biểu đồ và tự động cập nhật phần mềm (OTA). Ứng dụng được phát triển bằng framework Flutter.

## 🌟 Tính năng nổi bật

- 📊 **Quản lý thu chi**: Thêm, sửa, xóa các giao dịch hàng ngày một cách nhanh chóng.
- 📈 **Phân tích thông minh**: Biểu đồ thống kê trực quan theo tuần, tháng, năm giúp dễ dàng nắm bắt dòng tiền.
- 💼 **Ví tiền & Ngân sách**: Quản lý nhiều nguồn tiền, thiết lập hạn mức chi tiêu để không bị vung tay quá trán.
- ☁️ **Đồng bộ hóa dữ liệu**: Sử dụng cơ sở dữ liệu Supabase (PostgreSQL) đảm bảo an toàn và đồng bộ mượt mà.
- 🔄 **Cập nhật tự động (OTA)**: Tự động kiểm tra và tải xuống phiên bản ứng dụng mới nhất trực tiếp từ GitHub Releases mà không cần thông qua Google Play.
- 🎨 **Giao diện hiện đại**: Thiết kế tối giản, hỗ trợ hiệu ứng chuyển cảnh mềm mại mang lại cảm giác thân thiện cho người dùng.

## 🛠️ Yêu cầu hệ thống

- **Flutter SDK**: `^3.13.0`
- **Nền tảng mục tiêu**: Android (Tính năng OTA update và `coreLibraryDesugaring` được cấu hình riêng cho Android với `compileSdk 37`)

## 🚀 Hướng dẫn kiểm tra tính năng Cập nhật (OTA Update)

Ứng dụng lấy thông tin bản phát hành từ [Lnnam123/appandroid](https://github.com/Lnnam123/appandroid).

Để test tính năng tải bản cập nhật:
1. Đảm bảo Repo GitHub ở trạng thái **Public**.
2. Đăng một bản Release mới với file `.apk` đính kèm (Ví dụ: `v1.1.1`).
3. Dưới máy ảo/điện thoại, chỉnh file `pubspec.yaml` về một phiên bản thấp hơn (Ví dụ: `1.1.0`), thoát app và chạy lại (`flutter run`).
4. Mở app, vào mục **Cài đặt** -> **Kiểm tra cập nhật** để nhận thông báo có phiên bản mới và tự động tải về.

---

## 📂 Cấu trúc thư mục (Tree)

Dưới đây là cấu trúc mã nguồn chính của ứng dụng nằm trong thư mục `lib/`:

```text
appandroid/
├── android/                   # Native Android code và cấu hình build (SDK, Desugaring)
├── lib/                       # Mã nguồn chính của ứng dụng
│   ├── chu_de/                # Chứa các file quy định màu sắc, theme
│   │   └── mau_sac.dart
│   ├── dich_vu/               # Các dịch vụ bên ngoài (Ví dụ: kiểm tra API OTA Update)
│   │   └── update_service.dart
│   ├── du_lieu/               # Các hàm tương tác với CSDL Supabase
│   │   └── database_helper.dart
│   ├── man_hinh/              # Các giao diện màn hình chính
│   │   ├── cai_dat.dart
│   │   ├── dang_ky.dart
│   │   ├── dang_nhap.dart
│   │   ├── dang_nhap_nhanh.dart
│   │   ├── doi_mat_khau.dart
│   │   ├── phan_tich.dart
│   │   ├── quan_ly_danh_muc.dart
│   │   ├── them_danh_muc.dart
│   │   ├── thong_bao.dart
│   │   ├── thong_tin_ca_nhan.dart
│   │   ├── tong_quan.dart
│   │   └── vi_tien.dart
│   ├── mo_hinh/               # Các cấu trúc Model dữ liệu (NguoiDung, GiaoDich,...)
│   │   └── du_lieu.dart
│   ├── thanh_phan/            # Các UI Component có thể tái sử dụng (Dialog, BottomSheet)
│   │   ├── modal_doi_danh_muc.dart
│   │   ├── modal_ngan_sach.dart
│   │   ├── modal_quan_ly_vi_tien.dart
│   │   ├── modal_them_giao_dich.dart
│   │   └── skeleton_loading.dart
│   └── main.dart              # Entry point của ứng dụng, chứa khung điều hướng chính
└── pubspec.yaml               # Quản lý thư viện phụ thuộc và phiên bản ứng dụng
```
