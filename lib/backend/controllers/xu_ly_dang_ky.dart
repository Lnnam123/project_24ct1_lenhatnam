import '../database/database_service.dart';
import '../models/models.dart';

// =========================================================================
// [FILE XỬ LÝ RIÊNG (CONTROLLER) - TƯƠNG TỰ NHƯ WEB]: XỬ LÝ ĐĂNG KÝ
// Tách biệt hoàn toàn phần xử lý nghiệp vụ ra khỏi file giao diện (dang_ky.dart)
// Đường dẫn: lib/backend/controllers/xu_ly_dang_ky.dart
// =========================================================================
class XuLyDangKy {
  static final XuLyDangKy instance = XuLyDangKy._init();
  XuLyDangKy._init();

  /// [xuLyDangKy]: Thực hiện quy trình nghiệp vụ đăng ký tài khoản
  /// 1. Kiểm tra tài khoản đã tồn tại qua checkEmailExists (Bước 5 - 7)
  /// 2. Nếu chưa có -> Tạo mới tài khoản qua register (Bước 8 - 10)
  /// 3. Nếu đã có -> Ném lỗi ngoại lệ
  Future<NguoiDung> xuLyDangKy({
    required String name,
    required String email,
    required String password,
  }) async {
    // [BƯỚC 5 -> 8]: Kiểm tra xem email đã được đăng ký trước đó chưa (checkEmailExists)
    final daTonTai = await DatabaseService.instance.checkEmailExists(email);
    if (daTonTai) {
      // [BƯỚC 9 - Nhánh: Tài khoản đã tồn tại]: Báo trùng lặp
      throw Exception('Email đã tồn tại trong hệ thống');
    }

    // [BƯỚC 9 -> 12 - Nhánh: Tài khoản chưa tồn tại]: Ghi bản ghi mới vào CSDL (register)
    return await DatabaseService.instance.register(name, email, password);
  }
}

