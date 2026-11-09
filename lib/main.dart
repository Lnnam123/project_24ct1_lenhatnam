import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'backend/models/models.dart';
import 'frontend/man_hinh/tong_quan.dart';
import 'frontend/man_hinh/bao_cao.dart';
import 'frontend/man_hinh/vi_tien.dart';
import 'frontend/man_hinh/cai_dat.dart';
import 'frontend/man_hinh/dang_nhap.dart';
import 'frontend/man_hinh/thong_bao.dart';
import 'frontend/chu_de/mau_sac.dart';
import 'frontend/thanh_phan/modal_them_giao_dich.dart';
import 'frontend/thanh_phan/skeleton_loading.dart';
import 'frontend/thanh_phan/modal_quan_ly_vi_tien.dart';
import 'backend/database/database_service.dart';
import 'backend/controllers/xu_ly_ngan_sach.dart';
import 'backend/controllers/xu_ly_giao_dich.dart';
import 'backend/services/update_service.dart';
import 'backend/services/notification_service.dart';
import 'frontend/thanh_phan/nut_ai_chat_floating.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'frontend/man_hinh/dang_nhap_nhanh.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =========================================================================
  // [LUỒNG KẾT NỐI CƠ SỞ DỮ LIỆU - BƯỚC 1]: NẠP CẤU HÌNH BẢO MẬT TỪ FILE .ENV
  // Đọc địa chỉ URL máy chủ (SUPABASE_URL) và khóa xác thực công khai (SUPABASE_ANON_KEY)
  // =========================================================================
  await dotenv.load(fileName: ".env");

  // =========================================================================
  // [LUỒNG KẾT NỐI CƠ SỞ DỮ LIỆU - BƯỚC 2]: KHỞI TẠO KẾT NỐI TOÀN CỤC SUPABASE
  // Thiết lập đường truyền WebSocket và REST API kết nối app với máy chủ PostgreSQL
  // Toàn bộ các Service trong ứng dụng sẽ dùng phiên kết nối này thông qua Supabase.instance.client
  // =========================================================================
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  final prefs = await SharedPreferences.getInstance();
  final savedUserId = prefs.getInt('saved_user_id');
  final savedUserName = prefs.getString('saved_user_name');
  final savedUserEmail = prefs.getString('saved_user_email');

  Widget startScreen = const ManHinhDangNhap();

  if (savedUserId != null && savedUserName != null && savedUserEmail != null) {
    startScreen = ManHinhDangNhapNhanh(
      savedUserId: savedUserId,
      savedUserName: savedUserName,
      savedUserEmail: savedUserEmail,
    );
  }

  runApp(CointapApp(startScreen: startScreen));
}

class CointapApp extends StatelessWidget {
  final Widget startScreen;
  const CointapApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoinTap',
      debugShowCheckedModeBanner: false,
      theme: MauSac.lightTheme,
      locale: const Locale('vi', 'VN'),
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: startScreen,
    );
  }
}

class ManHinhChinh extends StatefulWidget {
  final NguoiDung nguoiDung;
  const ManHinhChinh({super.key, required this.nguoiDung});

  @override
  State<ManHinhChinh> createState() => _ManHinhChinhState();
}

class _ManHinhChinhState extends State<ManHinhChinh> {
  int _chiMucHienTai = 0;
  bool _truotSangTrai = true;

  List<ViTien> _danhSachVi = [];
  List<DanhMuc> _danhSachDanhMuc = [];
  List<GiaoDich> _danhSachGiaoDich = [];
  List<NganSach> _danhSachNganSach = [];
  bool _isLoading = true;
  bool _coThongBaoChuaDoc = false;
  NguoiDung? _nguoiDungHienTai;

  RealtimeChannel? _userStatusRealtimeChannel;
  Timer? _heartbeatTimer;
  bool _isShowingBlockDialog = false;

  @override
  void initState() {
    super.initState();
    _taiDuLieuTuDatabase();
    _langNgheTrangThaiTaiKhoanRealtime();

    // Tự động kiểm tra cập nhật khi mở app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.kiemTraCapNhat(context);
      NotificationService.dongBoThongBao(widget.nguoiDung.id);
    });
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    if (_userStatusRealtimeChannel != null) {
      Supabase.instance.client.removeChannel(_userStatusRealtimeChannel!);
    }
    super.dispose();
  }

  /// [Lắng nghe trạng thái tài khoản thời gian thực]:
  /// 1. Dùng Supabase Realtime WebSocket lắng nghe tức thì khi admin cập nhật trạng thái (`LOCKED`, `SUSPENDED`, `DELETED`).
  /// 2. Kèm Heartbeat polling 3 giây dự phòng khi mất kết nối mạng / ngắt WebSocket.
  void _langNgheTrangThaiTaiKhoanRealtime() {
    // 1. Lắng nghe tức thì qua Supabase Realtime WebSocket
    _userStatusRealtimeChannel = Supabase.instance.client
        .channel('user_status_realtime_${widget.nguoiDung.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'nguoi_dung',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'ma_nguoi_dung',
            value: widget.nguoiDung.id,
          ),
          callback: (payload) {
            debugPrint('Realtime User Status Change: ${payload.eventType}');
            if (_isShowingBlockDialog || !mounted) return;

            if (payload.eventType == PostgresChangeEvent.delete) {
              _hienThiDialogKhoaTaiKhoan('DELETED');
            } else if (payload.eventType == PostgresChangeEvent.update) {
              final newRecord = payload.newRecord;
              final newStatus = (newRecord['trang_thai'] ?? 'ACTIVE').toString().toUpperCase();
              if (newStatus != 'ACTIVE') {
                _hienThiDialogKhoaTaiKhoan(newStatus);
              }
            }
          },
        )
        .subscribe();

    // 2. Heartbeat polling 3 giây song song dự phòng mất kết nối socket
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_isShowingBlockDialog || !mounted) return;
      final status = await DatabaseService.instance.checkUserStatus(widget.nguoiDung.id);
      if (status != 'ACTIVE' && mounted && !_isShowingBlockDialog) {
        _hienThiDialogKhoaTaiKhoan(status);
      }
    });
  }

  /// [Tải toàn bộ dữ liệu ứng dụng]:
  /// Tải song song danh sách ví, danh mục, ngân sách, giao dịch và thông báo từ DatabaseService.
  Future<void> _taiDuLieuTuDatabase() async {
    setState(() => _isLoading = true);

    final db = DatabaseService.instance;

    // Kiểm tra trạng thái tài khoản người dùng
    final userStatus = await db.checkUserStatus(widget.nguoiDung.id);
    if (userStatus != 'ACTIVE') {
      if (mounted) {
        setState(() => _isLoading = false);
        _hienThiDialogKhoaTaiKhoan(userStatus);
      }
      return;
    }

    // Tối ưu hóa: Tải dữ liệu song song
    final results = await Future.wait([
      db.getWallets(widget.nguoiDung.id),
      db.getCategories(widget.nguoiDung.id),
    ]);

    final wallets = results[0] as List<ViTien>;
    final categories = results[1] as List<DanhMuc>;

    // Tải danh sách ngân sách (truyền danh mục để link)
    final budgets = await db.getBudgets(widget.nguoiDung.id, categories);

    final transactions = await db.getTransactions(
      widget.nguoiDung.id,
      wallets,
      categories,
    );

    final notifications = await db.getNotifications(widget.nguoiDung.id);
    final hasUnread = notifications.any((n) => !n.daDoc);


    if (mounted) {
      setState(() {
        _danhSachVi = wallets;
        _danhSachDanhMuc = categories;
        _danhSachGiaoDich = transactions;
        _danhSachNganSach = budgets;
        _coThongBaoChuaDoc = hasUnread;
        _isLoading = false;
      });
    }
  }

  void _hienThiDialogKhoaTaiKhoan(String status) {
    if (_isShowingBlockDialog || !mounted) return;
    _isShowingBlockDialog = true;
    _heartbeatTimer?.cancel();

    String title = 'Tài khoản không khả dụng';
    String message = 'Bạn không thể tiếp tục sử dụng ứng dụng với tài khoản này.';
    IconData icon = Icons.info_outline;
    Color iconColor = Colors.red;

    if (status == 'LOCKED') {
      title = 'Tài khoản đã bị khoá';
      message = 'Tài khoản của bạn đã bị Quản trị viên khoá quyền truy cập. Phiên đăng nhập hiện tại đã kết thúc. Vui lòng liên hệ bộ phận hỗ trợ nếu cần giải đáp.';
      icon = Icons.lock_outline_rounded;
      iconColor = Colors.red.shade700;
    } else if (status == 'SUSPENDED') {
      title = 'Tài khoản tạm ngưng';
      message = 'Tài khoản của bạn đang trong trạng thái tạm ngưng hoạt động. Bạn tạm thời không thể thao tác trên hệ thống cho đến khi được kích hoạt lại.';
      icon = Icons.pause_circle_outline_rounded;
      iconColor = Colors.orange.shade800;
    } else if (status == 'DELETED') {
      title = 'Tài khoản đã bị xoá';
      message = 'Tài khoản của bạn đã bị xoá khỏi hệ thống CoinTap.';
      icon = Icons.delete_outline_rounded;
      iconColor = Colors.red.shade700;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: iconColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MauSac.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  color: MauSac.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const ManHinhDangNhap(allowRedirect: false)),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Đăng xuất ngay',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [Tự động kiểm tra và cảnh báo ngân sách]:
  /// Đối chiếu chi tiêu thực tế với hạn mức từng danh mục; nếu vượt sẽ tự động tạo thông báo cảnh báo trong hệ thống.
  Future<void> _kiemTraVaCanhBaoNganSach() async {
    final notifications = await DatabaseService.instance.getNotifications(widget.nguoiDung.id);
    final now = DateTime.now();
    bool hasNewNotification = false;

    for (var budget in _danhSachNganSach) {
      if (budget.hanMuc > 0 && budget.daChi > budget.hanMuc) {
        final title = 'Vượt ngân sách: ${budget.danhMuc?.ten ?? "Tổng quát"}';
        
        // Kiểm tra xem đã có thông báo nào cùng tiêu đề trong vòng 1 tháng gần đây chưa
        final hasNotified = notifications.any((n) {
          return n.tieuDe == title && 
                 n.ngayTao.year == now.year && 
                 n.ngayTao.month == now.month;
        });

        if (!hasNotified) {
          await DatabaseService.instance.insertNotification(
            widget.nguoiDung.id,
            title,
            'Bạn đã chi tiêu vượt quá hạn mức ngân sách ${budget.danhMuc?.ten ?? "tổng quát"} trong tháng này.',
            'WARNING',
          );
          hasNewNotification = true;
        }
      }
    }

    if (hasNewNotification) {
      final updatedNotifs = await DatabaseService.instance.getNotifications(widget.nguoiDung.id);
      if (mounted) {
        setState(() {
          _coThongBaoChuaDoc = updatedNotifs.any((n) => !n.daDoc);
        });
      }
    }
  }

  /// [Cập nhật hạn mức ngân sách]:
  /// Lưu thay đổi ngân sách vào database và tải lại dữ liệu hiển thị.
  Future<void> _capNhatNganSach(NganSach nganSach) async {
    try {
      await XuLyNganSach.instance.xuLyLuuNganSach(
        nganSach: nganSach,
        userId: widget.nguoiDung.id,
      );
      await _taiDuLieuTuDatabase();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã cập nhật ngân sách thành công!',
            style: GoogleFonts.manrope(),
          ),
          backgroundColor: MauSac.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi khi lưu ngân sách: ${e.toString().replaceAll('Exception: ', '')}',
            style: GoogleFonts.manrope(),
          ),
          backgroundColor: MauSac.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      rethrow;
    }
  }

  /// [Xóa ngân sách]:
  /// Xóa hạn mức ngân sách theo ID và làm mới danh sách.
  Future<void> _xoaNganSach(int budgetId) async {
    try {
      await DatabaseService.instance.deleteBudget(budgetId);
      await _taiDuLieuTuDatabase();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa ngân sách!', style: GoogleFonts.manrope()),
          backgroundColor: MauSac.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xóa ngân sách: $e', style: GoogleFonts.manrope()),
          backgroundColor: MauSac.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      rethrow;
    }
  }

  /// [Thêm giao dịch mới]:
  /// Gọi Controller xử lý kiểm tra số dư và ghi bản ghi giao dịch thu/chi vào Database, tự động tính lại số dư ví và cảnh báo ngân sách.
  void _themGiaoDich(GiaoDich giaoDich) async {
    try {
      await XuLyGiaoDich.instance.xuLyThemGiaoDich(
        tx: giaoDich,
        userId: widget.nguoiDung.id,
      );
      await _taiDuLieuTuDatabase();
      await _kiemTraVaCanhBaoNganSach();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã lưu giao dịch vào cơ sở dữ liệu!',
            style: GoogleFonts.manrope(),
          ),
          backgroundColor: MauSac.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi khi thêm giao dịch: ${e.toString().replaceAll('Exception: ', '')}',
            style: GoogleFonts.manrope(),
          ),
          backgroundColor: MauSac.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// [Sửa giao dịch]:
  /// Cập nhật thông tin giao dịch, hoàn tác và tính toán lại số dư ví tương ứng.
  void _suaGiaoDich(GiaoDich giaoDich) async {
    await DatabaseService.instance.updateTransaction(giaoDich);
    await _taiDuLieuTuDatabase();
    await _kiemTraVaCanhBaoNganSach();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã cập nhật giao dịch thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _xoaGiaoDich(int id) async {
    await DatabaseService.instance.deleteTransaction(id);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa giao dịch!', style: GoogleFonts.manrope()),
        backgroundColor: MauSac.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _moModalThemGiaoDich() {
    if (_danhSachVi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bạn cần tạo ít nhất 1 tài khoản/ví để giao dịch', style: GoogleFonts.manrope()),
          backgroundColor: MauSac.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ModalThemGiaoDich(
          danhSachVi: _danhSachVi,
          danhSachDanhMuc: _danhSachDanhMuc,
          onThemGiaoDich: _themGiaoDich,
        ),
      ),
    );
  }

  void _moModalSuaGiaoDich(GiaoDich giaoDichCu) {
    if (_danhSachVi.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ModalThemGiaoDich(
          danhSachVi: _danhSachVi,
          danhSachDanhMuc: _danhSachDanhMuc,
          onThemGiaoDich: _themGiaoDich,
          onSuaGiaoDich: _suaGiaoDich,
          onXoaGiaoDich: _xoaGiaoDich,
          giaoDichCu: giaoDichCu,
        ),
      ),
    );
  }

  void _doiDanhMucGiaoDich(int transactionId, DanhMuc danhMucMoi) async {
    await DatabaseService.instance.updateTransactionCategory(
      transactionId,
      danhMucMoi.id,
    );
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã đổi danh mục giao dịch sang "${danhMucMoi.ten}"!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _themViTien(ViTien viMoi) async {
    await DatabaseService.instance.insertWallet(viMoi, widget.nguoiDung.id);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm ví tiền thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _capNhatViTien(ViTien viSua) async {
    await DatabaseService.instance.updateWallet(viSua);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã cập nhật ví tiền thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _xoaViTien(int id) async {
    await DatabaseService.instance.deleteWallet(id);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã xóa ví tiền thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _moModalQuanLyViTien([ViTien? viTienCu]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ModalQuanLyViTien(
          viTienCu: viTienCu,
          onThemViTien: _themViTien,
          onCapNhatViTien: _capNhatViTien,
          onXoaViTien: _xoaViTien,
        ),
      ),
    );
  }

  void _themDanhMuc(DanhMuc danhMucMoi) async {
    await DatabaseService.instance.insertCategory(
      danhMucMoi,
      widget.nguoiDung.id,
    );
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm danh mục thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _capNhatDanhMuc(DanhMuc danhMucSua) async {
    await DatabaseService.instance.updateCategory(danhMucSua);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã cập nhật danh mục thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _xoaDanhMuc(int danhMucId) async {
    await DatabaseService.instance.deleteCategory(danhMucId);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã xóa danh mục thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _capNhatNguoiDung(NguoiDung userMoi) async {
    await DatabaseService.instance.updateUser(userMoi);
    if (!mounted) return;
    setState(() {
      _nguoiDungHienTai = userMoi;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nguoiDung = _nguoiDungHienTai ?? widget.nguoiDung;

    final cacManHinh = [
      ManHinhTongQuan(
        nguoiDung: nguoiDung,
        danhSachGiaoDich: _danhSachGiaoDich,
        danhSachVi: _danhSachVi,
        danhSachDanhMuc: _danhSachDanhMuc,
        danhSachNganSach: _danhSachNganSach,
        moThemGiaoDich: _moModalThemGiaoDich,
        moSuaGiaoDich: _moModalSuaGiaoDich,
        xemTatCaGiaoDich: () {
          setState(() {
            _chiMucHienTai = 2; // Chuyển sang tab Ví
          });
        },
        coThongBaoChuaDoc: _coThongBaoChuaDoc,
        moThongBao: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ManHinhThongBao(userId: nguoiDung.id),
            ),
          );
          _taiDuLieuTuDatabase();
        },
        onDoiDanhMucGiaoDich: _doiDanhMucGiaoDich,
        onRefresh: _taiDuLieuTuDatabase,
        onCapNhatNganSach: _capNhatNganSach,
        onXoaNganSach: _xoaNganSach,
      ),
      ManHinhBaoCao(
        nguoiDung: nguoiDung,
        danhSachGiaoDich: _danhSachGiaoDich,
        moSuaGiaoDich: _moModalSuaGiaoDich,
        coThongBaoChuaDoc: _coThongBaoChuaDoc,
        onTapThongBao: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ManHinhThongBao(userId: nguoiDung.id),
            ),
          );
          _taiDuLieuTuDatabase();
        },
        onRefresh: _taiDuLieuTuDatabase,
      ),
      ManHinhViTien(
        nguoiDung: nguoiDung,
        danhSachVi: _danhSachVi,
        danhSachGiaoDich: _danhSachGiaoDich,
        moThemViTien: _moModalQuanLyViTien,
        moQuanLyViTien: _moModalQuanLyViTien,
        moSuaGiaoDich: _moModalSuaGiaoDich,
        coThongBaoChuaDoc: _coThongBaoChuaDoc,
        onTapThongBao: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ManHinhThongBao(userId: nguoiDung.id),
            ),
          );
          _taiDuLieuTuDatabase();
        },
        onRefresh: _taiDuLieuTuDatabase,
      ),
      ManHinhCaiDat(
        nguoiDung: nguoiDung,
        danhSachDanhMuc: _danhSachDanhMuc,
        onThemDanhMuc: _themDanhMuc,
        onCapNhatDanhMuc: _capNhatDanhMuc,
        onXoaDanhMuc: _xoaDanhMuc,
        onCapNhatNguoiDung: _capNhatNguoiDung,
      ),
    ];

    Widget bodyContent;
    if (_isLoading) {
      switch (_chiMucHienTai) {
        case 1:
          bodyContent = const PhanTichSkeleton();
          break;
        case 2:
          bodyContent = const ViTienSkeleton();
          break;
        case 3:
          bodyContent = const CaiDatSkeleton();
          break;
        case 0:
        default:
          bodyContent = const TrangTongQuanSkeleton();
      }
    } else {
      bodyContent = AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final isIncoming =
              (child.key as ValueKey<int>).value == _chiMucHienTai;

          final slideDirection = _truotSangTrai ? 1.0 : -1.0;
          final offsetBegin = isIncoming
              ? Offset(slideDirection, 0.0)
              : Offset(-slideDirection, 0.0);

          final slideAnimation = Tween<Offset>(
            begin: offsetBegin,
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        child: Container(
          key: ValueKey<int>(_chiMucHienTai),
          child: cacManHinh[_chiMucHienTai],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          bodyContent,
          if (_chiMucHienTai != 3)
            NutAiChatFloating(
              nguoiDung: nguoiDung,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MauSac.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: _moModalThemGiaoDich,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: MauSac.surfaceContainerHighest,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view),
              _buildNavItem(1, Icons.pie_chart_outline, Icons.pie_chart),
              const SizedBox(width: 48), // Khoảng trống cho FAB
              _buildNavItem(
                2,
                Icons.account_balance_wallet_outlined,
                Icons.account_balance_wallet,
              ),
              _buildNavItem(3, Icons.settings_outlined, Icons.settings),
            ],
          ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData solidIcon) {
    final isSelected = _chiMucHienTai == index;
    return GestureDetector(
      onTap: () {
        if (_chiMucHienTai != index) {
          setState(() {
            _truotSangTrai = index > _chiMucHienTai;
            _chiMucHienTai = index;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? solidIcon : outlineIcon,
              color: isSelected ? MauSac.primary : MauSac.onSurfaceVariant,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

