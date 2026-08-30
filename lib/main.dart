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
  NganSach? _nganSach;
  bool _isLoading = true;
  NguoiDung? _nguoiDungHienTai;

  @override
  void initState() {
    super.initState();
    _taiDuLieuTuDatabase();
  }

  Future<void> _taiDuLieuTuDatabase() async {
    setState(() => _isLoading = true);

    final db = DatabaseHelper.instance;
    // Tối ưu hóa: Tải dữ liệu song song
    final results = await Future.wait([
      db.getWallets(widget.nguoiDung.id),
      db.getCategories(widget.nguoiDung.id),
      db.getBudget(widget.nguoiDung.id),
    ]);

    final wallets = results[0] as List<ViTien>;
    final categories = results[1] as List<DanhMuc>;
    final budget = results[2] as NganSach;

    final transactions = await db.getTransactions(widget.nguoiDung.id, wallets, categories);

    // Calculate daChi (total spent this month)
    final now = DateTime.now();
    double totalSpent = 0;
    for (var tx in transactions) {
      if (tx.loai == LoaiGiaoDich.chiTieu && tx.ngay.year == now.year && tx.ngay.month == now.month) {
        totalSpent += tx.soTien;
      }
    }
    budget.daChi = totalSpent;

    if (mounted) {
      setState(() {
        _danhSachVi = wallets;
        _danhSachDanhMuc = categories;
        _danhSachGiaoDich = transactions;
        _nganSach = budget;
        _isLoading = false;
      });
    }
  }

  void _capNhatNganSach(double hanMucMoi) async {
    await DatabaseHelper.instance.updateBudget(widget.nguoiDung.id, hanMucMoi);
    await _taiDuLieuTuDatabase();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã cập nhật hạn mức ngân sách!', style: GoogleFonts.manrope()),
        backgroundColor: MauSac.success,
      ),
    );
  }

  void _themGiaoDich(GiaoDich giaoDich) async {
    await DatabaseHelper.instance.insertTransaction(giaoDich, widget.nguoiDung.id);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu giao dịch vào cơ sở dữ liệu!', style: GoogleFonts.manrope()),
        backgroundColor: MauSac.success,
      ),
    );
  }

  void _moModalThemGiaoDich() {
    if (_danhSachVi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần tạo ít nhất 1 tài khoản/ví để giao dịch')),
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

  void _doiDanhMucGiaoDich(int transactionId, DanhMuc danhMucMoi) async {
    await DatabaseHelper.instance.updateTransactionCategory(transactionId, danhMucMoi.id);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã đổi danh mục giao dịch sang "${danhMucMoi.ten}"!', style: GoogleFonts.manrope()),
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
        content: Text('Đã thêm ví tiền thành công!', style: GoogleFonts.manrope()),
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
        content: Text('Đã cập nhật ví tiền thành công!', style: GoogleFonts.manrope()),
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
        content: Text('Đã xóa ví tiền thành công!', style: GoogleFonts.manrope()),
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
    await DatabaseHelper.instance.insertCategory(danhMucMoi, widget.nguoiDung.id);
    await _taiDuLieuTuDatabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm danh mục thành công!', style: GoogleFonts.manrope()),
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
        content: Text('Đã cập nhật danh mục thành công!', style: GoogleFonts.manrope()),
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
        content: Text('Đã xóa danh mục thành công!', style: GoogleFonts.manrope()),
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
    if (_isLoading) {
      return const Scaffold(
        body: TrangTongQuanSkeleton(),
      );
    }

    final nguoiDung = _nguoiDungHienTai ?? widget.nguoiDung;

    final cacManHinh = [
      ManHinhTongQuan(
        nguoiDung: nguoiDung,
        danhSachGiaoDich: _danhSachGiaoDich,
        danhSachVi: _danhSachVi,
        danhSachDanhMuc: _danhSachDanhMuc,
        nganSach: _nganSach ?? NganSach(id: 0, hanMuc: 0, daChi: 0, ngayBatDau: DateTime.now(), ngayKetThuc: DateTime.now()),
        moThemGiaoDich: _moModalThemGiaoDich,
        xemTatCaGiaoDich: () {
          setState(() {
            _chiMucHienTai = 2; // Chuyển sang tab Ví
          });
        },
        moThongBao: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ManHinhThongBao(userId: nguoiDung.id)),
          );
        },
        onDoiDanhMucGiaoDich: _doiDanhMucGiaoDich,
        onRefresh: _taiDuLieuTuDatabase,
        onCapNhatNganSach: _capNhatNganSach,
      ),
      ManHinhPhanTich(
        danhSachGiaoDich: _danhSachGiaoDich,
        onTapThongBao: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ManHinhThongBao(userId: nguoiDung.id)),
          );
        },
      ),
      ManHinhViTien(
        danhSachVi: _danhSachVi, 
        danhSachGiaoDich: _danhSachGiaoDich, 
        moThemViTien: _moModalQuanLyViTien,
        moQuanLyViTien: _moModalQuanLyViTien,
        onTapThongBao: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ManHinhThongBao(userId: nguoiDung.id)),
          );
        },
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

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final isIncoming = (child.key as ValueKey<int>).value == _chiMucHienTai;
          
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
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_chiMucHienTai),
          child: cacManHinh[_chiMucHienTai],
        ),
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
        color: MauSac.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 20, // Tăng bóng đổ để dễ nhìn như có viền
        shadowColor: Colors.black.withValues(alpha: 0.5),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view),
              _buildNavItem(1, Icons.bar_chart_outlined, Icons.bar_chart),
              const SizedBox(width: 48), // Khoảng trống cho FAB
              _buildNavItem(2, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet),
              _buildNavItem(3, Icons.settings_outlined, Icons.settings),
            ],
          ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? solidIcon : outlineIcon,
            color: isSelected ? MauSac.primary : MauSac.onSurfaceVariant,
            size: 26,
          ),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: MauSac.primary,
                shape: BoxShape.circle,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
