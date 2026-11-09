import '../database/database_service.dart';
import '../models/models.dart';

// =========================================================================
// [FILE XỬ LÝ RIÊNG (CONTROLLER) - TƯƠNG TỰ NHƯ WEB]: XỬ LÝ HẠN MỨC NGÂN SÁCH
// Tách biệt hoàn toàn phần xử lý nghiệp vụ ra khỏi file giao diện (modal_ngan_sach.dart)
// Đường dẫn: lib/backend/controllers/xu_ly_ngan_sach.dart
// =========================================================================
class XuLyNganSach {
  static final XuLyNganSach instance = XuLyNganSach._init();
  XuLyNganSach._init();

  /// [xuLyLuuNganSach]: Thực hiện quy trình nghiệp vụ thiết lập hạn mức ngân sách
  /// - Bước 5: Gọi DatabaseService kiểm tra ngân sách danh mục đã tồn tại trong tháng chưa
  /// - Bước 8-9: Phản hồi kết quả check nếu danh mục đã được thiết lập ngân sách
  /// - Bước 11-14: Nếu hạn mức hợp lệ, thực hiện lưu / cập nhật ngân sách
  Future<void> xuLyLuuNganSach({
    required NganSach nganSach,
    required int userId,
  }) async {
    // Kiểm tra tính hợp lệ cơ bản
    if (nganSach.hanMuc <= 0) {
      throw Exception('Hạn mức ngân sách phải lớn hơn 0');
    }

    // [BƯỚC 5 ĐẾN 8]: Kiểm tra danh mục đã tồn tại trong tháng chưa (loại trừ ID hiện tại nếu đang sửa)
    final thang = '${nganSach.ngayBatDau.year}-${nganSach.ngayBatDau.month.toString().padLeft(2, '0')}';
    final daTonTai = await DatabaseService.instance.checkBudgetExists(
      userId,
      nganSach.danhMuc?.id,
      thang,
      excludeBudgetId: nganSach.id != 0 ? nganSach.id : null,
    );
    if (daTonTai) {
      // [BƯỚC 9 & 11 (ELSE)]: Báo lỗi ngoại lệ ngân sách danh mục đã tồn tại
      final tenDanhMuc = nganSach.danhMuc != null ? '"${nganSach.danhMuc!.ten}"' : 'chung';
      throw Exception('Ngân sách $tenDanhMuc đã được thiết lập cho tháng ${nganSach.ngayBatDau.month}/${nganSach.ngayBatDau.year}!');
    }

    // [BƯỚC 11 (ALT)]: Nhánh hạn mức hợp lệ -> Lưu / cập nhật ngân sách
    await DatabaseService.instance.updateBudget(nganSach, userId);
  }
}
