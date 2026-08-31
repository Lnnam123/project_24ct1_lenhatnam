import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mo_hinh/du_lieu.dart';
import 'man_hinh/tong_quan.dart';
import 'man_hinh/phan_tich.dart';
import 'man_hinh/vi_tien.dart';
import 'man_hinh/cai_dat.dart';
import 'man_hinh/dang_nhap.dart';
import 'man_hinh/thong_bao.dart';
import 'chu_de/mau_sac.dart';
import 'thanh_phan/modal_them_giao_dich.dart';
import 'thanh_phan/skeleton_loading.dart';
import 'thanh_phan/modal_quan_ly_vi_tien.dart';
import 'du_lieu/database_helper.dart';
import 'dich_vu/update_service.dart';
import 'dich_vu/notification_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'man_hinh/dang_nhap_nhanh.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yribnkvfvpysievnhmwr.supabase.co',
    anonKey: 'sb_publishable_DOQ8uECFBcqcIG85PTBMWg_EvE19RAl',
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

  @override
  void initState() {
    super.initState();
    _taiDuLieuTuDatabase();

    // Tự động kiểm tra cập nhật khi mở app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.kiemTraCapNhat(context);
      NotificationService.dongBoThongBao(widget.nguoiDung.id);
    });
  }

  Future<void> _taiDuLieuTuDatabase() async {
    setState(() => _isLoading = true);

    final db = DatabaseHelper.instance;
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

    // Tính tổng chi tiêu cho từng ngân sách trong danh sách
    for (var budget in budgets) {
      double totalSpent = 0;
      for (var tx in transactions) {
        if (tx.loai == LoaiGiaoDich.chiTieu &&
            (tx.ngay.isAfter(budget.ngayBatDau) ||
                tx.ngay.isAtSameMomentAs(budget.ngayBatDau)) &&
            (tx.ngay.isBefore(budget.ngayKetThuc) ||
                tx.ngay.isAtSameMomentAs(budget.ngayKetThuc))) {
          // Nếu ngân sách có giới hạn danh mục, kiểm tra danh mục
          if (budget.danhMuc == null || budget.danhMuc!.id == tx.danhMuc.id) {
            totalSpent += tx.soTien;
          }
        }
      }
      budget.daChi = totalSpent;
    }

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

  void _capNhatNganSach(NganSach nganSach) async {
    try {
      await DatabaseHelper.instance.updateBudget(nganSach, widget.nguoiDung.id);
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
            'Lỗi khi lưu ngân sách: $e',
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

  void _xoaNganSach(int budgetId) async {
    await DatabaseHelper.instance.deleteBudget(budgetId);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa ngân sách!', style: GoogleFonts.manrope()),
        backgroundColor: MauSac.success,
      ),
    );
  }

  void _themGiaoDich(GiaoDich giaoDich) async {
    await DatabaseHelper.instance.insertTransaction(
      giaoDich,
      widget.nguoiDung.id,
    );
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã lưu giao dịch vào cơ sở dữ liệu!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
      ),
    );
  }

  void _suaGiaoDich(GiaoDich giaoDich) async {
    await DatabaseHelper.instance.updateTransaction(giaoDich);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã cập nhật giao dịch thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
      ),
    );
  }

  void _xoaGiaoDich(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa giao dịch!', style: GoogleFonts.manrope()),
        backgroundColor: MauSac.success,
      ),
    );
  }

  void _moModalThemGiaoDich() {
    if (_danhSachVi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần tạo ít nhất 1 tài khoản/ví để giao dịch'),
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
    await DatabaseHelper.instance.updateTransactionCategory(
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
      ),
    );
  }

  void _themViTien(ViTien viMoi) async {
    await DatabaseHelper.instance.insertWallet(viMoi, widget.nguoiDung.id);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm ví tiền thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
      ),
    );
  }

  void _capNhatViTien(ViTien viSua) async {
    await DatabaseHelper.instance.updateWallet(viSua);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã cập nhật ví tiền thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
      ),
    );
  }

  void _xoaViTien(int id) async {
    await DatabaseHelper.instance.deleteWallet(id);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã xóa ví tiền thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
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
    await DatabaseHelper.instance.insertCategory(
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
      ),
    );
  }

  void _capNhatDanhMuc(DanhMuc danhMucSua) async {
    await DatabaseHelper.instance.updateCategory(danhMucSua);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã cập nhật danh mục thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
      ),
    );
  }

  void _xoaDanhMuc(int danhMucId) async {
    await DatabaseHelper.instance.deleteCategory(danhMucId);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã xóa danh mục thành công!',
          style: GoogleFonts.manrope(),
        ),
        backgroundColor: MauSac.success,
      ),
    );
  }

  void _capNhatNguoiDung(NguoiDung userMoi) async {
    await DatabaseHelper.instance.updateUser(userMoi);
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
      ManHinhPhanTich(
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
      body: bodyContent,
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
        color: MauSac.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 20, // Tăng bóng đổ để dễ nhìn như có viền
        shadowColor: Colors.black.withValues(alpha: 0.5),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view),
              _buildNavItem(1, Icons.bar_chart_outlined, Icons.bar_chart),
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
