import '../database/database_service.dart';
import '../models/models.dart';

// =========================================================================
// [FILE XỬ LÝ RIÊNG (CONTROLLER) - TƯƠNG TỰ NHƯ WEB]: XỬ LÝ GIAO DỊCH
// Tách biệt hoàn toàn phần xử lý nghiệp vụ ra khỏi file giao diện (modal_them_giao_dich.dart)
// Đường dẫn: lib/backend/controllers/xu_ly_giao_dich.dart
// =========================================================================
class XuLyGiaoDich {
  static final XuLyGiaoDich instance = XuLyGiaoDich._init();
  XuLyGiaoDich._init();

  /// [xuLyThemGiaoDich]: Thực hiện quy trình nghiệp vụ ghi nhận giao dịch thu / chi
  /// - Bước 5: Gọi DatabaseService kiểm tra số dư ví nguồn
  /// - Bước 8-9: Phản hồi kết quả check nếu số dư ví không đủ chi tiêu
  /// - Bước 11-14: Nếu số dư hợp lệ, ghi bản ghi giao dịch mới
  Future<void> xuLyThemGiaoDich({
    required GiaoDich tx,
    required int userId,
  }) async {
    // Kiểm tra tính hợp lệ cơ bản
    if (tx.soTien <= 0) {
      throw Exception('Số tiền giao dịch phải lớn hơn 0');
    }

    // [BƯỚC 5 ĐẾN 8]: Kiểm tra số dư ví đối với giao dịch chi tiêu
    if (tx.loai == LoaiGiaoDich.chiTieu) {
      final duSoDu = await DatabaseService.instance.checkWalletBalance(tx.viTien.id, tx.soTien);
      if (!duSoDu) {
        // [BƯỚC 9 & 11 (ELSE)]: Báo lỗi ngoại lệ số dư ví không khả dụng
        throw Exception('Số dư trong ví không đủ để chi tiêu!');
      }
    }

    // [BƯỚC 11 (ALT)]: Nhánh số dư hợp lệ -> Lưu giao dịch mới
    await DatabaseService.instance.insertTransaction(tx, userId);
  }
}
