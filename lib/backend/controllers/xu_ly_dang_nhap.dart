import '../database/database_service.dart';
import '../models/models.dart';

// =========================================================================
// [FILE XỬ LÝ RIÊNG (CONTROLLER) - TƯƠNG TỰ NHƯ WEB]: XỬ LÝ ĐĂNG NHẬP
// Tách biệt hoàn toàn phần xử lý nghiệp vụ ra khỏi file giao diện (dang_nhap.dart)
// Đường dẫn: lib/backend/controllers/xu_ly_dang_nhap.dart
// =========================================================================
class XuLyDangNhap {
  static final XuLyDangNhap instance = XuLyDangNhap._init();
  XuLyDangNhap._init();

  /// [xuLyDangNhap]: Thực hiện quy trình nghiệp vụ xác thực đăng nhập
  /// Gửi email và mật khẩu xuống DatabaseService để kiểm tra trong CSDL
  Future<NguoiDung?> xuLyDangNhap({
    required String email,
    required String password,
  }) async {
    // [BƯỚC 5 -> 8]: Xác thực tài khoản với CSDL Supabase
    return await DatabaseService.instance.login(email, password);
  }
}

