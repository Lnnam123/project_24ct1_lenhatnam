import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../utils/icon_helper.dart';

// =========================================================================
// [LUỒNG KẾT NỐI CƠ SỞ DỮ LIỆU - BƯỚC 3]: LỚP DỊCH VỤ TRUY XUẤT DỮ LIỆU (DATA ACCESS LAYER)
// Áp dụng mô hình thiết kế Singleton: Toàn bộ ứng dụng dùng chung duy nhất một cổng kết nối
// Biến '_supabase' là cổng Client nhận lệnh truy vấn SQL (select, insert, update, delete)
// và gửi trực tiếp lên máy chủ Supabase Database.
// =========================================================================
// lớp client thực thi truy vấn
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  
  // Cổng kết nối Client trực tiếp tới cơ sở dữ liệu Supabase
  final _supabase = Supabase.instance.client;

  DatabaseService._init();

  /// [hashPassword]: Băm mật khẩu bằng thuật toán SHA-256 bảo mật cao
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ==========================================
  // NHÓM 1: XÁC THỰC & QUẢN LÝ TÀI KHOẢN (AUTH)
  // ==========================================

  // =========================================================================
  // [SƠ ĐỒ TUẦN TỰ - ĐĂNG KÝ]: BƯỚC 5 ĐẾN BƯỚC 7 (KIỂM TRA TÀI KHOẢN ĐÃ TỒN TẠI)
  // =========================================================================
  /// - Bước 5: State gọi `checkEmailExists(email)` xuống DatabaseService.
  /// - Bước 6: DatabaseService gửi truy vấn sang CSDL:
  ///   `SELECT email FROM nguoi_dung WHERE email = ?`
  /// - Bước 7: Bảng `nguoi_dung` trả về kết quả (true nếu đã tồn tại, false nếu chưa).
  Future<bool> checkEmailExists(String email) async {
    try {
      // [BƯỚC 6]: Gửi câu lệnh truy vấn tới bảng 'nguoi_dung' trên Supabase
      final response = await _supabase
          .from('nguoi_dung')
          .select('email')
          .eq('email', email) // so sánh giá trị của email (tên email) so sánh bằng 
          .maybeSingle(); // phương thức truy vấn dữ liệu (gói package supabase flutter) -> null or đôi tượng
      // [BƯỚC 7]: Trả kết quả kiểm tra về cho State
      return response != null; // trả về true (xác nhận email nằm trong bảng nguoi_dung)
    } catch (e) {
      debugPrint('Lỗi check email: $e');
      return false;
    }
  }

  // =========================================================================
  // [SƠ ĐỒ TUẦN TỰ - ĐĂNG NHẬP]: BƯỚC 5 ĐẾN BƯỚC 8 (XÁC THỰC TÀI KHOẢN TẠI BACKEND)
  // =========================================================================
  /// - Bước 5: State gọi `login(email, password)` xuống DatabaseService.
  /// - Bước 6: DatabaseService gửi truy vấn sang CSDL:
  ///   `SELECT * FROM nguoi_dung WHERE email = ? AND mat_khau = ?`
  /// - Bước 7: Bảng `nguoi_dung` trả về kết quả xác thực.
  /// - Nhánh [Tài khoản đúng]:
  ///   + Bước 8: Trả về đối tượng `NguoiDung` cho State.
  /// - Nhánh [Tài khoản sai]:
  ///   + Bước 8: Trả về `null` (thông tin không chính xác).
  Future<NguoiDung?> login(String email, String password) async {
    try {
      final hashed = hashPassword(password);
      // [BƯỚC 6]: Gửi câu lệnh truy vấn tới bảng 'nguoi_dung' trên Supabase với mật khẩu băm SHA-256
      var response = await _supabase
          .from('nguoi_dung')
          .select()
          .eq('email', email)
          .eq('mat_khau', hashed)
          .maybeSingle();

      // Dự phòng tương thích ngược: Nếu tài khoản chưa được băm (chứa mật khẩu thô)
      if (response == null) {
        response = await _supabase
            .from('nguoi_dung')
            .select()
            .eq('email', email)
            .eq('mat_khau', password)
            .maybeSingle();

        if (response != null) {
          // Tự động nâng cấp mã hóa lên SHA-256 trong CSDL
          final uId = response['ma_nguoi_dung'] ?? response['user_id'];
          await _supabase.from('nguoi_dung').update({'mat_khau': hashed}).eq('ma_nguoi_dung', uId);
        }
      }

      // [BƯỚC 7]: Tiếp nhận kết quả xác thực từ CSDL
      if (response != null) {
        final trangThai = (response['trang_thai'] ?? 'ACTIVE').toString().toUpperCase();
        if (trangThai == 'LOCKED') {
          throw Exception('Tài khoản của bạn đã bị khoá bởi Quản trị viên!');
        }
        if (trangThai == 'SUSPENDED') {
          throw Exception('Tài khoản của bạn đang tạm thời bị ngưng hoạt động!');
        }

        // [BƯỚC 8 - Nhánh: Tài khoản đúng]: Đóng gói và trả về đối tượng NguoiDung
        return NguoiDung(
          id: response['ma_nguoi_dung'] ?? response['user_id'],
          hoTen: response['ho_ten'] ?? response['full_name'],
          email: response['email'],
          soDienThoai: response['so_dien_thoai'] ?? response['phone_number'] ?? '',
          matKhau: '',
        );
      }
    } catch (e) {
      debugPrint('Lỗi login: $e');
      rethrow;
    }
    // [BƯỚC 8 - Nhánh: Tài khoản sai]: Trả về null khi không tìm thấy tài khoản khớp
    return null;
  }

  /// [checkUserStatus]: Kiểm tra trạng thái hiện tại của tài khoản người dùng theo ID.
  /// - [userId]: Mã người dùng cần kiểm tra.
  /// - Trả về: `ACTIVE` (bình thường), `LOCKED` (bị khoá), `SUSPENDED` (tạm ngưng), hoặc `DELETED` (đã xoá).
  Future<String> checkUserStatus(int userId) async {
    try {
      final response = await _supabase
          .from('nguoi_dung')
          .select('trang_thai')
          .eq('ma_nguoi_dung', userId)
          .maybeSingle();
      if (response != null) {
        return (response['trang_thai'] ?? 'ACTIVE').toString().toUpperCase();
      } else {
        return 'DELETED'; // Tài khoản không còn tồn tại hoặc đã bị xoá
      }
    } catch (e) {
      debugPrint('Lỗi checkUserStatus: $e');
    }
    return 'ACTIVE';
  }

  /// [changePassword]: Đổi mật khẩu tài khoản người dùng.
  /// - [userId]: Mã người dùng.
  /// - [oldPassword]: Mật khẩu cũ (phải trùng khớp mới được đổi).
  /// - [newPassword]: Mật khẩu mới cần cập nhật.
  /// - Trả về `true` nếu đổi thành công, `false` nếu mật khẩu cũ không đúng.
  Future<bool> changePassword(int userId, String oldPassword, String newPassword) async {
    try {
      final hashedOld = hashPassword(oldPassword);
      // Xác minh mật khẩu cũ trước khi đổi (kiểm tra cả hashed lẫn raw)
      var response = await _supabase
          .from('nguoi_dung')
          .select()
          .eq('ma_nguoi_dung', userId)
          .eq('mat_khau', hashedOld)
          .maybeSingle();

      if (response == null) {
        response = await _supabase
            .from('nguoi_dung')
            .select()
            .eq('ma_nguoi_dung', userId)
            .eq('mat_khau', oldPassword)
            .maybeSingle();
      }

      if (response == null) {
        return false; // Mật khẩu cũ không đúng
      }

      // Cập nhật mật khẩu mới đã băm SHA-256
      final hashedNew = hashPassword(newPassword);
      await _supabase
          .from('nguoi_dung')
          .update({'mat_khau': hashedNew})
          .eq('ma_nguoi_dung', userId);
      return true;
    } catch (e) {
      debugPrint('Lỗi đổi mật khẩu: $e');
      return false;
    }
  }

  /// [resetPassword]: Đặt lại mật khẩu mới cho chức năng Quên mật khẩu (sau khi xác thực OTP).
  /// - [email]: Địa chỉ email của tài khoản cần đặt lại.
  /// - [newPassword]: Mật khẩu mới.
  /// - Trả về `true` nếu thành công.
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final hashedNew = hashPassword(newPassword);
      await _supabase
          .from('nguoi_dung')
          .update({'mat_khau': hashedNew})
          .eq('email', email);
      return true;
    } catch (e) {
      debugPrint('Lỗi đặt lại mật khẩu: $e');
      return false;
    }
  }

  // =========================================================================
  // [SƠ ĐỒ TUẦN TỰ - ĐĂNG KÝ]: BƯỚC 8 ĐẾN BƯỚC 10 (KHỐI ALT - TẠO MỚI TÀI KHOẢN)
  // =========================================================================
  /// - Bước 8: State gọi `register()` -> DatabaseService gửi lệnh `INSERT INTO nguoi_dung`.
  /// - Bước 9: CSDL tạo tài khoản và ví mặc định thành công, trả về kết quả (ID người dùng).
  /// - Bước 10: Đóng gói và trả về đối tượng `NguoiDung` cho State (hoặc ném ngoại lệ nếu trùng lặp).
  Future<NguoiDung> register(String name, String email, String password) async {
    try {
      final hashed = hashPassword(password);
      // [BƯỚC 8]: Chèn bản ghi tài khoản mới vào bảng 'nguoi_dung' trên Supabase với mật khẩu băm SHA-256
      final response = await _supabase
          .from('nguoi_dung')
          .insert({
            'ho_ten': name,
            'email': email,
            'mat_khau': hashed,
          })
          .select()
          .single();

      final userId = response['ma_nguoi_dung'] ?? response['user_id'];

      // [BƯỚC 9]: Tự động tạo một "Ví Tiền Mặt" mặc định trong bảng 'vi_tien'
      await _supabase.from('vi_tien').insert({
        'ma_nguoi_dung': userId,
        'ten_vi': 'Ví Tiền Mặt',
        'loai_vi': 'CASH',
        'so_du': 0,
        'bieu_tuong': 'payments',
        'mau_sac': '#10B981',
      });

      // [BƯỚC 10]: Trả về đối tượng NguoiDung cho State
      return NguoiDung(
        id: userId,
        hoTen: name,
        email: email,
        soDienThoai: '',
        matKhau: '',
      );
    } catch (e) {
      debugPrint('Lỗi register: $e');
      // [BƯỚC 10 - Nhánh lỗi]: Bắt lỗi trùng email từ CSDL và ném ngoại lệ
      if (e.toString().contains('23505') || e.toString().contains('duplicate key')) {
        throw Exception('Email đã tồn tại');
      }
      throw Exception('Đăng ký thất bại: $e');
    }
  }

  /// [updateUser]: Cập nhật thông tin hồ sơ cá nhân của người dùng.
  /// - [user]: Đối tượng [NguoiDung] chứa họ tên, email, số điện thoại, ảnh đại diện mới.
  Future<void> updateUser(NguoiDung user) async {
    try {
      await _supabase.from('nguoi_dung').update({
        'ho_ten': user.hoTen,
        'email': user.email,
        'so_dien_thoai': user.soDienThoai,
        'anh_dai_dien': user.avatarUrl,
      }).eq('ma_nguoi_dung', user.id);
    } catch (e) {
      debugPrint('Lỗi updateUser: $e');
      throw Exception('Cập nhật thông tin thất bại: $e');
    }
  }

  // ==========================================
  // NHÓM 2: QUẢN LÝ VÍ TIỀN (WALLETS)
  // ==========================================

  /// [getWallets]: Lấy danh sách tất cả các ví tiền đang hoạt động của người dùng.
  /// - [userId]: Mã người dùng.
  /// - Trả về danh sách [ViTien] (ví tiền mặt, thẻ ngân hàng, sổ tiết kiệm...).
  Future<List<ViTien>> getWallets(int userId) async {
    try {
      final response = await _supabase
          .from('vi_tien')
          .select()
          .eq('ma_nguoi_dung', userId)
          .eq('dang_hoat_dong', true);

      return (response as List).map((m) => ViTien(
        id: m['ma_vi'] ?? m['wallet_id'],
        tenVi: m['ten_vi'] ?? m['wallet_name'],
        loaiVi: m['loai_vi'] ?? m['wallet_type'] ?? 'CASH',
        soDu: double.tryParse((m['so_du'] ?? m['balance'])?.toString() ?? '0') ?? 0.0,
        icon: _getIconFromString(m['bieu_tuong'] ?? m['icon']),
        mauSac: _getColorFromString(m['mau_sac'] ?? m['color']),
      )).toList();
    } catch (e) {
      debugPrint('Lỗi getWallets: $e');
    }
    return [];
  }

  // ==========================================
  // NHÓM 3: QUẢN LÝ DANH MỤC THU CHI (CATEGORIES)
  // ==========================================

  /// [getCategories]: Lấy danh sách danh mục thu chi (bao gồm danh mục hệ thống và của người dùng).
  /// - [userId]: Mã người dùng (nếu có sẽ lấy thêm danh mục riêng do người dùng đó tạo).
  /// - Trả về danh sách [DanhMuc].
  Future<List<DanhMuc>> getCategories([int? userId]) async {
    try {
      var query = _supabase.from('danh_muc').select();
      if (userId != null) {
        query = query.or('ma_nguoi_dung.eq.$userId,ma_nguoi_dung.is.null');
      } else {
        query = query.filter('ma_nguoi_dung', 'is', null);
      }

      final response = await query;
      
      if ((response as List).isNotEmpty) {
        return response.map((m) => DanhMuc(
          id: m['ma_danh_muc'] ?? m['category_id'],
          ten: m['ten_danh_muc'] ?? m['name'],
          loai: (m['loai_danh_muc'] ?? m['type']) == 'EXPENSE' ? LoaiGiaoDich.chiTieu : LoaiGiaoDich.thuNhap,
          icon: _getIconFromString(m['bieu_tuong'] ?? m['icon']),
          mauSac: _getColorFromString(m['mau_sac'] ?? m['color']),
        )).toList();
      }
    } catch (e) {
      debugPrint('Lỗi getCategories: $e');
    }

    return [
      DanhMuc(id: 1, ten: 'Ăn uống', loai: LoaiGiaoDich.chiTieu, icon: Icons.restaurant, mauSac: const Color(0xFFEF4444)),
      DanhMuc(id: 2, ten: 'Mua sắm', loai: LoaiGiaoDich.chiTieu, icon: Icons.shopping_cart, mauSac: const Color(0xFFF59E0B)),
      DanhMuc(id: 3, ten: 'Lương', loai: LoaiGiaoDich.thuNhap, icon: Icons.payments, mauSac: const Color(0xFF10B981)),
      DanhMuc(id: 4, ten: 'Di chuyển', loai: LoaiGiaoDich.chiTieu, icon: Icons.directions_car, mauSac: const Color(0xFF2563EB)),
      DanhMuc(id: 5, ten: 'Giải trí', loai: LoaiGiaoDich.chiTieu, icon: Icons.movie, mauSac: const Color(0xFF712AE2)),
    ];
  }

  /// [insertCategory]: Thêm danh mục thu/chi mới do người dùng tự định nghĩa.
  /// - [category]: Thông tin danh mục (tên, icon, màu sắc, loại thu/chi).
  /// - [userId]: Mã người dùng tạo danh mục.
  Future<void> insertCategory(DanhMuc category, int userId) async {
    try {
      final colorHex = '#${category.mauSac.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      await _supabase.from('danh_muc').insert({
        'ma_nguoi_dung': userId,
        'ten_danh_muc': category.ten,
        'loai_danh_muc': category.loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
        'bieu_tuong': category.iconName,
        'mau_sac': colorHex,
      });
    } catch (e) {
      debugPrint('Lỗi insertCategory: $e');
    }
  }

  /// [updateCategory]: Cập nhật thông tin danh mục thu/chi hiện có.
  /// - [category]: Đối tượng danh mục với dữ liệu mới.
  Future<void> updateCategory(DanhMuc category) async {
    try {
      final colorHex = '#${category.mauSac.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      await _supabase.from('danh_muc').update({
        'ten_danh_muc': category.ten,
        'loai_danh_muc': category.loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
        'bieu_tuong': category.iconName,
        'mau_sac': colorHex,
      }).eq('ma_danh_muc', category.id);
    } catch (e) {
      debugPrint('Lỗi updateCategory: $e');
    }
  }

  /// [deleteCategory]: Xóa một danh mục theo ID.
  /// - [categoryId]: Mã danh mục cần xóa.
  Future<void> deleteCategory(int categoryId) async {
    try {
      await _supabase.from('danh_muc').delete().eq('ma_danh_muc', categoryId);
    } catch (e) {
      debugPrint('Lỗi deleteCategory: $e');
    }
  }

  // ==========================================
  // NHÓM 4: QUẢN LÝ THÔNG BÁO (NOTIFICATIONS)
  // ==========================================

  /// [getNotifications]: Lấy danh sách thông báo của người dùng, sắp xếp mới nhất lên đầu.
  /// - [userId]: Mã người dùng.
  /// - Trả về danh sách [ThongBao].
  Future<List<ThongBao>> getNotifications(int userId) async {
    try {
      final response = await _supabase
          .from('thong_bao')
          .select()
          .eq('ma_nguoi_dung', userId)
          .order('ngay_tao', ascending: false);

      return (response as List).map((m) {
        return ThongBao(
          id: m['ma_thong_bao'] ?? m['notification_id'],
          tieuDe: m['tieu_de'] ?? m['title'],
          noiDung: m['noi_dung'] ?? m['content'],
          loai: m['loai_thong_bao'] ?? m['type'],
          daDoc: m['da_doc'] ?? m['is_read'] ?? false,
          ngayTao: m['ngay_tao'] != null ? DateTime.parse(m['ngay_tao']) : (m['created_at'] != null ? DateTime.parse(m['created_at']) : DateTime.now()),
        );
      }).toList();
    } catch (e) {
      debugPrint('Lỗi getNotifications: $e');
      return [];
    }
  }

  /// [markNotificationAsRead]: Đánh dấu một thông báo là đã đọc.
  /// - [notificationId]: Mã thông báo.
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _supabase.from('thong_bao').update({'da_doc': true}).eq('ma_thong_bao', notificationId);
    } catch (e) {
      debugPrint('Lỗi markNotificationAsRead: $e');
    }
  }

  /// [insertNotification]: Tạo mới một thông báo trong hệ thống.
  /// - [userId]: Mã người dùng nhận thông báo.
  /// - [title]: Tiêu đề thông báo.
  /// - [content]: Nội dung chi tiết.
  /// - [type]: Phân loại (`SYSTEM`, `WARNING`, `BUDGET`...).
  /// - [createdAt]: Thời gian tạo (tùy chọn, mặc định lấy thời gian hiện tại).
  Future<void> insertNotification(int userId, String title, String content, String type, {DateTime? createdAt}) async {
    try {
      final Map<String, dynamic> data = {
        'ma_nguoi_dung': userId,
        'tieu_de': title,
        'noi_dung': content,
        'loai_thong_bao': type,
      };
      if (createdAt != null) {
        data['ngay_tao'] = createdAt.toIso8601String();
      }
      await _supabase.from('thong_bao').insert(data);
    } catch (e) {
      debugPrint('Lỗi insertNotification: $e');
    }
  }

  // ==========================================
  // NHÓM 5: QUẢN LÝ GIAO DỊCH THU CHI (TRANSACTIONS)
  // ==========================================

  /// [getTransactions]: Lấy toàn bộ lịch sử giao dịch của người dùng.
  /// - [userId]: Mã người dùng.
  /// - [wallets]: Danh sách ví để liên kết tên và icon ví cho từng giao dịch.
  /// - [categories]: Danh sách danh mục để liên kết tên và icon danh mục cho giao dịch.
  /// - Trả về danh sách [GiaoDich] sắp xếp theo ngày mới nhất.
  Future<List<GiaoDich>> getTransactions(int userId, List<ViTien> wallets, List<DanhMuc> categories) async {
    try {
      final response = await _supabase
          .from('giao_dich')
          .select()
          .eq('ma_nguoi_dung', userId)
          .order('ngay_giao_dich', ascending: false)
          .order('ma_giao_dich', ascending: false);

      return (response as List).map((m) {
        final walletId = m['ma_vi'] ?? m['wallet_id'];
        final categoryId = m['ma_danh_muc'] ?? m['category_id'];
        final transType = m['loai_giao_dich'] ?? m['type'];
        final wallet = wallets.firstWhere((w) => w.id == walletId, orElse: () => wallets.first);
        final cat = categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => categories.firstWhere(
            (c) => c.loai == (transType == 'EXPENSE' ? LoaiGiaoDich.chiTieu : LoaiGiaoDich.thuNhap),
            orElse: () => categories.first,
          ),
        );
        
        final dateStr = m['ngay_giao_dich'] ?? m['transaction_date'];
        return GiaoDich(
          id: m['ma_giao_dich'] ?? m['transaction_id'],
          tieuDe: m['ghi_chu'] ?? m['note'] ?? 'Giao dịch',
          soTien: double.tryParse((m['so_tien'] ?? m['amount'])?.toString() ?? '0') ?? 0.0,
          loai: transType == 'EXPENSE' ? LoaiGiaoDich.chiTieu : LoaiGiaoDich.thuNhap,
          danhMuc: cat,
          viTien: wallet,
          ngay: dateStr != null ? DateTime.parse(dateStr) : DateTime.now(),
          ghiChu: m['ghi_chu'] ?? m['note'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Lỗi getTransactions: $e');
    }
    return [];
  }

  // ==========================================
  // NHÓM 6: QUẢN LÝ NGÂN SÁCH (BUDGETS)
  // ==========================================

  /// [getBudgets]: Lấy danh sách ngân sách và tự động tính tổng tiền đã chi ([daChi]).
  /// - [userId]: Mã người dùng.
  /// - [danhSachDanhMuc]: Danh sách danh mục để đối chiếu.
  /// - Tự động truy vấn các giao dịch `EXPENSE` trong khoảng thời gian hiệu lực để tính `daChi`.
  /// - Trả về danh sách [NganSach].
  Future<List<NganSach>> getBudgets(int userId, List<DanhMuc> danhSachDanhMuc) async {
    try {
      final response = await _supabase
          .from('ngan_sach')
          .select()
          .eq('ma_nguoi_dung', userId)
          .order('ngay_tao', ascending: false);
          
      if (response.isNotEmpty) {
        // Lấy tất cả giao dịch chi tiêu để tự động tính daChi
        final txResponse = await _supabase
            .from('giao_dich')
            .select()
            .eq('ma_nguoi_dung', userId)
            .eq('loai_giao_dich', 'EXPENSE');

        return response.map<NganSach>((m) {
          final catId = m['ma_danh_muc'] ?? m['category_id'];
          DanhMuc? category;
          if (catId != null) {
            try {
              category = danhSachDanhMuc.firstWhere((c) => c.id == catId);
            } catch (e) {
              // ignore
            }
          }
          
          final startStr = m['ngay_bat_dau'] ?? m['start_date'];
          final endStr = m['ngay_ket_thuc'] ?? m['end_date'];
          final startDate = startStr != null ? DateTime.parse(startStr) : DateTime.now();
          final endDate = endStr != null ? DateTime.parse(endStr) : DateTime.now().add(const Duration(days: 30));
          
          double totalSpent = 0;
          for (var tx in txResponse) {
             final txDateStr = tx['ngay_giao_dich'] ?? tx['transaction_date'];
             final txDate = DateTime.parse(txDateStr);
             // Bao gồm cả ngày cuối cùng bằng cách so sánh Date
             final txDay = DateTime(txDate.year, txDate.month, txDate.day);
             final startDay = DateTime(startDate.year, startDate.month, startDate.day);
             final endDay = DateTime(endDate.year, endDate.month, endDate.day);
             
             if (!txDay.isBefore(startDay) && !txDay.isAfter(endDay)) {
               final txCatId = tx['ma_danh_muc'] ?? tx['category_id'];
               if (category == null || category.id == txCatId) {
                  totalSpent += double.tryParse((tx['so_tien'] ?? tx['amount'])?.toString() ?? '0') ?? 0.0;
               }
             }
          }

          return NganSach(
            id: m['ma_ngan_sach'] ?? m['budget_id'],
            hanMuc: double.tryParse((m['so_tien'] ?? m['amount'])?.toString() ?? '0') ?? 0.0,
            daChi: totalSpent,
            ngayBatDau: startDate,
            ngayKetThuc: endDate,
            danhMuc: category,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Lỗi getBudgets: $e');
    }
    return [];
  }

  // =========================================================================
  // [SƠ ĐỒ TUẦN TỰ - HẠN MỨC NGÂN SÁCH]: BƯỚC 5 ĐẾN BƯỚC 8 (KIỂM TRA NGÂN SÁCH DANH MỤC)
  // =========================================================================
  /// - Bước 5: Controller gọi `checkBudgetExists(userId, maDanhMuc, thang)` xuống DatabaseService.
  /// - Bước 6: DatabaseService gửi truy vấn sang CSDL kiểm tra:
  ///   `SELECT ma_ngan_sach, ma_danh_muc, ngay_bat_dau FROM ngan_sach WHERE ma_nguoi_dung = ?`
  /// - Bước 7: Bảng `ngan_sach` trả về danh sách bản ghi.
  /// - Bước 8: Trả về kết quả kiểm tra (true nếu đã tồn tại trong tháng, false nếu chưa).
  Future<bool> checkBudgetExists(int userId, int? maDanhMuc, String thang, {int? excludeBudgetId}) async {
    try {
      final response = await _supabase
          .from('ngan_sach')
          .select('ma_ngan_sach, ma_danh_muc, ngay_bat_dau')
          .eq('ma_nguoi_dung', userId);

      for (var row in response) {
        final id = row['ma_ngan_sach'];
        if (excludeBudgetId != null && id == excludeBudgetId) continue;
        final catId = row['ma_danh_muc'];
        if (catId != maDanhMuc) continue;

        final startStr = row['ngay_bat_dau']?.toString();
        if (startStr != null) {
          final dt = DateTime.tryParse(startStr);
          if (dt != null) {
            final rowThang = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
            if (rowThang == thang) return true;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Lỗi checkBudgetExists: $e');
      return false;
    }
  }

  /// [updateBudget]: Thêm mới hoặc cập nhật ngân sách chi tiêu.
  /// - Tự động phát hiện nếu danh mục đã tồn tại để cập nhật (Upsert) tránh lỗi ràng buộc CSDL `unique_user_category`.
  /// - Cập nhật hạn mức ngân sách và khoảng thời gian áp dụng theo tháng.
  Future<void> updateBudget(NganSach nganSach, int userId) async {
    try {
      // 1. Kiểm tra các bản ghi ngân sách hiện tại của người dùng
      final existingRows = await _supabase
          .from('ngan_sach')
          .select('ma_ngan_sach, ma_danh_muc')
          .eq('ma_nguoi_dung', userId);

      dynamic matchedRow;
      for (var row in existingRows) {
        if (row['ma_danh_muc'] == nganSach.danhMuc?.id) {
          matchedRow = row;
          break;
        }
      }

      if (matchedRow != null) {
        // Đã có bản ghi ngân sách cho danh mục này -> Cập nhật bản ghi đó
        final targetId = matchedRow['ma_ngan_sach'];
        await _supabase.from('ngan_sach').update({
          'so_tien': nganSach.hanMuc,
          'ngay_bat_dau': nganSach.ngayBatDau.toIso8601String(),
          'ngay_ket_thuc': nganSach.ngayKetThuc.toIso8601String(),
        }).eq('ma_ngan_sach', targetId);
      } else if (nganSach.id != 0) {
        // Cập nhật bản ghi theo ID nếu chưa đổi sang danh mục đã có
        await _supabase.from('ngan_sach').update({
          'ma_danh_muc': nganSach.danhMuc?.id,
          'so_tien': nganSach.hanMuc,
          'ngay_bat_dau': nganSach.ngayBatDau.toIso8601String(),
          'ngay_ket_thuc': nganSach.ngayKetThuc.toIso8601String(),
        }).eq('ma_ngan_sach', nganSach.id);
      } else {
        // Chưa có -> Thêm mới bản ghi ngân sách
        await _supabase.from('ngan_sach').insert({
          'ma_nguoi_dung': userId,
          'ma_danh_muc': nganSach.danhMuc?.id,
          'so_tien': nganSach.hanMuc,
          'ngay_bat_dau': nganSach.ngayBatDau.toIso8601String(),
          'ngay_ket_thuc': nganSach.ngayKetThuc.toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Lỗi updateBudget: $e');
      rethrow;
    }
  }

  /// [deleteBudget]: Xóa một ngân sách theo ID.
  /// - [budgetId]: Mã ngân sách cần xóa.
  Future<void> deleteBudget(int budgetId) async {
    try {
      await _supabase.from('ngan_sach').delete().eq('ma_ngan_sach', budgetId);
    } catch (e) {
      debugPrint('Lỗi deleteBudget: $e');
      rethrow;
    }
  }

  // =========================================================================
  // [SƠ ĐỒ TUẦN TỰ - THÊM GIAO DỊCH]: BƯỚC 5 ĐẾN BƯỚC 8 (KIỂM TRA SỐ DƯ VÍ NGUỒN)
  // =========================================================================
  /// - Bước 5: Controller gọi `checkWalletBalance(maVi, soTien)` xuống DatabaseService.
  /// - Bước 6: DatabaseService gửi truy vấn sang CSDL kiểm tra số dư ví:
  ///   `SELECT so_du FROM vi_tien WHERE ma_vi = ?`
  /// - Bước 7: Bảng `vi_tien` trả về bản ghi số dư ví.
  /// - Bước 8: Trả về kết quả kiểm tra (true nếu đủ số dư chi tiêu, false nếu không đủ).
  Future<bool> checkWalletBalance(int maVi, double soTien) async {
    try {
      final response = await _supabase
          .from('vi_tien')
          .select('so_du')
          .eq('ma_vi', maVi)
          .maybeSingle();
      if (response != null) {
        final soDu = (response['so_du'] as num?)?.toDouble() ?? 0.0;
        return soDu >= soTien;
      }
      return false;
    } catch (e) {
      debugPrint('Lỗi checkWalletBalance: $e');
      return false;
    }
  }

  /// [insertTransaction]: Thêm một giao dịch thu/chi mới vào cơ sở dữ liệu.
  /// - [tx]: Đối tượng [GiaoDich] chứa số tiền, ví, danh mục, ngày, ghi chú.
  /// - [userId]: Mã người dùng thực hiện giao dịch.
  Future<void> insertTransaction(GiaoDich tx, int userId) async {
    try {
      await _supabase.from('giao_dich').insert({
        'ma_nguoi_dung': userId,
        'ma_vi': tx.viTien.id,
        'ma_danh_muc': tx.danhMuc.id,
        'so_tien': tx.soTien,
        'loai_giao_dich': tx.loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
        'ngay_giao_dich': tx.ngay.toIso8601String(),
        'ghi_chu': tx.tieuDe,
      });
    } catch (e) {
      debugPrint('Lỗi insertTransaction: $e');
    }
  }

  /// [updateTransaction]: Cập nhật thông tin của một giao dịch đã có.
  /// - [tx]: Đối tượng [GiaoDich] đã chỉnh sửa.
  Future<void> updateTransaction(GiaoDich tx) async {
    try {
      await _supabase.from('giao_dich').update({
        'ma_vi': tx.viTien.id,
        'ma_danh_muc': tx.danhMuc.id,
        'so_tien': tx.soTien,
        'loai_giao_dich': tx.loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
        'ngay_giao_dich': tx.ngay.toIso8601String(),
        'ghi_chu': tx.tieuDe,
      }).eq('ma_giao_dich', tx.id!);
    } catch (e) {
      debugPrint('Lỗi updateTransaction: $e');
    }
  }

  /// [deleteTransaction]: Xóa một giao dịch khỏi cơ sở dữ liệu.
  /// - [transactionId]: Mã giao dịch cần xóa.
  Future<void> deleteTransaction(int transactionId) async {
    try {
      await _supabase.from('giao_dich').delete().eq('ma_giao_dich', transactionId);
    } catch (e) {
      debugPrint('Lỗi deleteTransaction: $e');
    }
  }

  /// [updateTransactionCategory]: Cập nhật nhanh danh mục cho một giao dịch.
  /// - [transactionId]: Mã giao dịch.
  /// - [categoryId]: Mã danh mục mới.
  Future<void> updateTransactionCategory(int transactionId, int categoryId) async {
    try {
      await _supabase.from('giao_dich').update({
        'ma_danh_muc': categoryId,
      }).eq('ma_giao_dich', transactionId);
    } catch (e) {
      debugPrint('Lỗi updateTransactionCategory: $e');
    }
  }

  /// [insertWallet]: Thêm một ví tiền mới cho người dùng.
  /// - [wallet]: Thông tin ví (tên, loại ví CASH/BANK/SAVINGS, số dư, icon, màu sắc).
  /// - [userId]: Mã người dùng sở hữu.
  Future<void> insertWallet(ViTien wallet, int userId) async {
    try {
      String iconName = 'account_balance_wallet';
      if (wallet.icon == Icons.credit_card) iconName = 'credit_card';
      if (wallet.icon == Icons.savings) iconName = 'savings';
      
      String colorHex = '#${wallet.mauSac.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      
      await _supabase.from('vi_tien').insert({
        'ma_nguoi_dung': userId,
        'ten_vi': wallet.tenVi,
        'loai_vi': wallet.loaiVi,
        'so_du': wallet.soDu,
        'bieu_tuong': iconName,
        'mau_sac': colorHex,
      });
    } catch (e) {
      debugPrint('Lỗi insertWallet: $e');
    }
  }

  /// [updateWallet]: Cập nhật thông tin của ví tiền hiện có.
  /// - [wallet]: Đối tượng ví tiền chứa thông tin mới (tên, số dư, icon, màu).
  Future<void> updateWallet(ViTien wallet) async {
    try {
      String iconName = 'account_balance_wallet';
      if (wallet.icon == Icons.credit_card) iconName = 'credit_card';
      if (wallet.icon == Icons.savings) iconName = 'savings';
      
      String colorHex = '#${wallet.mauSac.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      
      await _supabase.from('vi_tien').update({
        'ten_vi': wallet.tenVi,
        'loai_vi': wallet.loaiVi,
        'so_du': wallet.soDu,
        'bieu_tuong': iconName,
        'mau_sac': colorHex,
      }).eq('ma_vi', wallet.id);
    } catch (e) {
      debugPrint('Lỗi updateWallet: $e');
    }
  }

  /// [deleteWallet]: Xóa mềm ví tiền (ẩn khỏi danh sách bằng cách đặt `dang_hoat_dong = false`).
  /// - [walletId]: Mã ví cần xóa.
  Future<void> deleteWallet(int walletId) async {
    try {
      await _supabase.from('vi_tien').update({'dang_hoat_dong': false}).eq('ma_vi', walletId);
    } catch (e) {
      debugPrint('Lỗi deleteWallet: $e');
    }
  }

  // ==========================================
  // NHÓM 7: TRỢ LÝ AI & LỊCH SỬ HỘI THOẠI (AI CHAT)
  // ==========================================

  /// [getAIChatMessages]: Lấy danh sách tin nhắn chat AI đơn giản của người dùng.
  /// - Ưu tiên đồng bộ từ Supabase, tự động lưu bộ nhớ đệm (cache) vào SharedPreferences.
  /// - Nếu mất mạng sẽ đọc từ bộ nhớ đệm cục bộ.
  Future<List<Map<String, dynamic>>> getAIChatMessages(int userId) async {
    // 1. Thử lấy từ Supabase
    try {
      final response = await _supabase
          .from('tin_nhan_ai')
          .select()
          .eq('ma_nguoi_dung', userId)
          .order('ngay_tao', ascending: false);

      if (response.isNotEmpty) {
        final messages = response.map((m) => Map<String, dynamic>.from(m)).toList();
        // Cập nhật bộ nhớ đệm cục bộ
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ai_chat_history_$userId', jsonEncode(messages));
        return messages;
      }
    } catch (e) {
      debugPrint('Supabase getAIChatMessages (dùng local cache): $e');
    }

    // 2. Fallback đọc từ SharedPreferences local
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('ai_chat_history_$userId');
      if (localJson != null && localJson.isNotEmpty) {
        final decoded = jsonDecode(localJson) as List;
        return decoded.map((m) => Map<String, dynamic>.from(m)).toList();
      }
    } catch (e) {
      debugPrint('Local getAIChatMessages error: $e');
    }

    return [];
  }

  /// [insertAIChatMessage]: Lưu một tin nhắn chat AI mới vào SharedPreferences và đồng bộ lên Supabase.
  /// - [userId]: Mã người dùng.
  /// - [content]: Nội dung tin nhắn câu hỏi hoặc câu trả lời.
  /// - [isUser]: `true` nếu là người dùng hỏi, `false` nếu là AI trả lời.
  /// - [createdAt]: Thời điểm gửi tin nhắn.
  Future<void> insertAIChatMessage(int userId, String content, bool isUser, DateTime createdAt) async {
    final newMsg = {
      'ma_nguoi_dung': userId,
      'noi_dung': content,
      'la_nguoi_dung': isUser,
      'ngay_tao': createdAt.toIso8601String(),
    };

    // 1. Luôn lưu ngay vào SharedPreferences (đảm bảo không mất dữ liệu)
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('ai_chat_history_$userId');
      List<dynamic> list = [];
      if (localJson != null && localJson.isNotEmpty) {
        list = jsonDecode(localJson) as List;
      }
      list.insert(0, newMsg);
      if (list.length > 100) {
        list = list.sublist(0, 100);
      }
      await prefs.setString('ai_chat_history_$userId', jsonEncode(list));
    } catch (e) {
      debugPrint('Lỗi lưu local AI chat: $e');
    }

    // 2. Đồng bộ lên Supabase nếu có bảng
    try {
      await _supabase.from('tin_nhan_ai').insert(newMsg);
    } catch (e) {
      debugPrint('Lỗi insert Supabase AI chat (đã lưu local): $e');
    }
  }

  /// [clearAIChatMessages]: Xóa sạch toàn bộ lịch sử tin nhắn chat AI của người dùng (cả local và Supabase).
  Future<void> clearAIChatMessages(int userId) async {
    // 1. Xóa local
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ai_chat_history_$userId');
    } catch (e) {
      debugPrint('Lỗi clear local AI chat: $e');
    }

    // 2. Xóa Supabase
    try {
      await _supabase.from('tin_nhan_ai').delete().eq('ma_nguoi_dung', userId);
    } catch (e) {
      debugPrint('Lỗi clear Supabase AI chat: $e');
    }
  }

  /// [getAIConversations]: Lấy danh sách các phiên hội thoại AI (Multi-session / Gemini-style).
  /// - Tải phiên trò chuyện cùng toàn bộ tin nhắn con của mỗi phiên.
  /// - Có cơ chế lưu đệm SharedPreferences dự phòng mất kết nối mạng.
  Future<List<Map<String, dynamic>>> getAIConversations(int userId) async {
    // 1. Thử lấy từ Supabase
    try {
      final convResponse = await _supabase
          .from('cuoc_tro_chuyen_ai')
          .select()
          .eq('ma_nguoi_dung', userId)
          .order('ngay_cap_nhat', ascending: false);

      if (convResponse.isNotEmpty) {
        final List<Map<String, dynamic>> sessions = [];
        for (final conv in convResponse) {
          final sId = (conv['ma_phien'] ?? conv['session_id']).toString();
          final msgResponse = await _supabase
              .from('tin_nhan_ai')
              .select()
              .eq('ma_phien', sId)
              .order('ngay_tao', ascending: true);

          final convMap = Map<String, dynamic>.from(conv);
          convMap['session_id'] = sId;
          convMap['title'] = conv['tieu_de'] ?? conv['title'] ?? 'Cuộc trò chuyện mới';
          convMap['created_at'] = conv['ngay_tao'] ?? conv['created_at'];
          convMap['updated_at'] = conv['ngay_cap_nhat'] ?? conv['updated_at'];
          convMap['messages'] = (msgResponse as List).map((m) {
            final mCopy = Map<String, dynamic>.from(m);
            mCopy['content'] = m['noi_dung'] ?? m['content'];
            mCopy['is_user'] = m['la_nguoi_dung'] ?? m['is_user'];
            mCopy['created_at'] = m['ngay_tao'] ?? m['created_at'];
            return mCopy;
          }).toList();
          sessions.add(convMap);
        }

        // Cập nhật bộ nhớ đệm cục bộ
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ai_sessions_$userId', jsonEncode(sessions));
        return sessions;
      }
    } catch (e) {
      debugPrint('Supabase getAIConversations (dùng local cache): $e');
    }

    // 2. Fallback đọc từ SharedPreferences local
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('ai_sessions_$userId');
      if (localJson != null && localJson.isNotEmpty) {
        final decoded = jsonDecode(localJson) as List;
        return decoded.map((m) => Map<String, dynamic>.from(m)).toList();
      }
    } catch (e) {
      debugPrint('Local getAIConversations error: $e');
    }

    return [];
  }

  /// [saveAIConversation]: Lưu hoặc cập nhật phiên trò chuyện AI cùng tin nhắn mới nhất.
  /// - [userId]: Mã người dùng.
  /// - [sessionData]: Dữ liệu phiên gồm mã phiên, tiêu đề, danh sách tin nhắn.
  Future<void> saveAIConversation(int userId, Map<String, dynamic> sessionData) async {
    final sessionId = (sessionData['ma_phien'] ?? sessionData['session_id']).toString();

    // 1. Lưu ngay vào local SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('ai_sessions_$userId');
      List<dynamic> list = [];
      if (localJson != null && localJson.isNotEmpty) {
        list = jsonDecode(localJson) as List;
      }
      final existingIndex = list.indexWhere((s) => (s['ma_phien'] ?? s['session_id'])?.toString() == sessionId);
      if (existingIndex >= 0) {
        list[existingIndex] = sessionData;
      } else {
        list.insert(0, sessionData);
      }
      await prefs.setString('ai_sessions_$userId', jsonEncode(list));
    } catch (e) {
      debugPrint('Lỗi lưu local AI conversation: $e');
    }

    // 2. Đồng bộ lên Supabase
    try {
      await _supabase.from('cuoc_tro_chuyen_ai').upsert({
        'ma_phien': sessionId,
        'ma_nguoi_dung': userId,
        'tieu_de': sessionData['tieu_de'] ?? sessionData['title'] ?? 'Cuộc trò chuyện mới',
        'ngay_tao': sessionData['ngay_tao'] ?? sessionData['created_at'],
        'ngay_cap_nhat': sessionData['ngay_cap_nhat'] ?? sessionData['updated_at'],
      });

      final messages = sessionData['messages'] as List?;
      if (messages != null && messages.isNotEmpty) {
        final lastMsg = messages.last;
        await _supabase.from('tin_nhan_ai').insert({
          'ma_phien': sessionId,
          'ma_nguoi_dung': userId,
          'noi_dung': lastMsg['noi_dung'] ?? lastMsg['content'],
          'la_nguoi_dung': lastMsg['la_nguoi_dung'] ?? lastMsg['is_user'] ?? true,
          'ngay_tao': lastMsg['ngay_tao'] ?? lastMsg['created_at'] ?? DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Lỗi upsert Supabase AI conversation: $e');
    }
  }

  /// [deleteAIConversation]: Xóa một phiên trò chuyện cụ thể (xóa cả tin nhắn con và bản ghi phiên).
  /// - [userId]: Mã người dùng.
  /// - [sessionId]: Mã phiên cần xóa.
  Future<void> deleteAIConversation(int userId, String sessionId) async {
    // 1. Xóa local
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('ai_sessions_$userId');
      if (localJson != null && localJson.isNotEmpty) {
        List<dynamic> list = jsonDecode(localJson) as List;
        list.removeWhere((s) => (s['ma_phien'] ?? s['session_id'])?.toString() == sessionId);
        await prefs.setString('ai_sessions_$userId', jsonEncode(list));
      }
    } catch (e) {
      debugPrint('Lỗi delete local AI conversation: $e');
    }

    // 2. Xóa Supabase: Xóa tất cả tin nhắn con trước, sau đó xóa phiên trò chuyện chính
    try {
      await _supabase.from('tin_nhan_ai').delete().eq('ma_phien', sessionId);
      await _supabase.from('cuoc_tro_chuyen_ai').delete().eq('ma_phien', sessionId);
    } catch (e) {
      debugPrint('Lỗi delete Supabase AI conversation: $e');
    }
  }

  /// [syncAIConversationMessages]: Đồng bộ danh sách tin nhắn còn lại sau khi người dùng xóa 1 hoặc nhiều tin nhắn nhỏ.
  /// - [userId]: Mã người dùng.
  /// - [sessionId]: Mã phiên hội thoại.
  /// - [remainingMessages]: Danh sách các tin nhắn còn lại cần lưu giữ.
  Future<void> syncAIConversationMessages(
    int userId,
    String sessionId,
    List<Map<String, dynamic>> remainingMessages,
  ) async {
    // 1. Cập nhật local
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('ai_sessions_$userId');
      if (localJson != null && localJson.isNotEmpty) {
        List<dynamic> list = jsonDecode(localJson) as List;
        final index = list.indexWhere((s) => (s['ma_phien'] ?? s['session_id'])?.toString() == sessionId);
        if (index >= 0) {
          final session = Map<String, dynamic>.from(list[index]);
          session['messages'] = remainingMessages;
          session['updated_at'] = DateTime.now().toIso8601String();
          list[index] = session;
          await prefs.setString('ai_sessions_$userId', jsonEncode(list));
        }
      }
    } catch (e) {
      debugPrint('Lỗi sync local AI messages: $e');
    }

    // 2. Đồng bộ lên Supabase: Xóa sạch tin nhắn cũ của session và nạp lại danh sách mới
    try {
      await _supabase.from('tin_nhan_ai').delete().eq('ma_phien', sessionId);
      if (remainingMessages.isNotEmpty) {
        final List<Map<String, dynamic>> records = remainingMessages.map((m) => {
          'ma_phien': sessionId,
          'ma_nguoi_dung': userId,
          'noi_dung': m['noi_dung'] ?? m['content'],
          'la_nguoi_dung': m['la_nguoi_dung'] == true || m['is_user'] == true || m['is_user'] == 1,
          'ngay_tao': m['ngay_tao'] ?? m['created_at'] ?? DateTime.now().toIso8601String(),
        }).toList();
        await _supabase.from('tin_nhan_ai').insert(records);
      }
      // Cập nhật updated_at cho phiên
      await _supabase.from('cuoc_tro_chuyen_ai').update({
        'ngay_cap_nhat': DateTime.now().toIso8601String(),
      }).eq('ma_phien', sessionId);
    } catch (e) {
      debugPrint('Lỗi sync Supabase AI messages: $e');
    }
  }

  /// [clearAllAIConversations]: Xóa toàn bộ các phiên trò chuyện của người dùng (cả local và Supabase).
  Future<void> clearAllAIConversations(int userId) async {
    // 1. Xóa local
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ai_sessions_$userId');
      await prefs.remove('ai_chat_history_$userId');
    } catch (e) {
      debugPrint('Lỗi clear local AI conversations: $e');
    }

    // 2. Xóa Supabase: Xóa tin nhắn con trước, sau đó xóa phiên
    try {
      await _supabase.from('tin_nhan_ai').delete().eq('ma_nguoi_dung', userId);
      await _supabase.from('cuoc_tro_chuyen_ai').delete().eq('ma_nguoi_dung', userId);
    } catch (e) {
      debugPrint('Lỗi clear Supabase AI conversations: $e');
    }
  }

  // --- Helper Methods ---
  IconData _getIconFromString(String? iconName) {
    return BieuTuongHelper.layIcon(iconName);
  }

  Color _getColorFromString(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.black;
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; 
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
