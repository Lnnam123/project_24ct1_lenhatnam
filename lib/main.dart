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
import 'thanh_phan/modal_them_vi_tien.dart';
import 'du_lieu/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CointapApp());
}

class CointapApp extends StatelessWidget {
  const CointapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cointap - Quản lý Chi tiêu',
      debugShowCheckedModeBanner: false,
      theme: MauSac.lightTheme,
      home: const ManHinhDangNhap(), // Start with Login
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

  List<ViTien> _danhSachVi = [];
  List<DanhMuc> _danhSachDanhMuc = [];
  List<GiaoDich> _danhSachGiaoDich = [];
  NganSach? _nganSach;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _taiDuLieuTuDatabase();
  }

  Future<void> _taiDuLieuTuDatabase() async {
    setState(() => _isLoading = true);

    final db = DatabaseHelper.instance;
    final wallets = await db.getWallets(widget.nguoiDung.id);
    final categories = await db.getCategories();
    final transactions = await db.getTransactions(widget.nguoiDung.id, wallets, categories);
    final budget = await db.getBudget(widget.nguoiDung.id);

    setState(() {
      _danhSachVi = wallets;
      _danhSachDanhMuc = categories;
      _danhSachGiaoDich = transactions;
      _nganSach = budget;
      _isLoading = false;
    });
  }

  void _themGiaoDich(GiaoDich giaoDich) async {
    // Luu vao SQLite
    await DatabaseHelper.instance.insertTransaction(giaoDich, widget.nguoiDung.id);
    
    // Refresh the UI by fetching latest data from DB
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: MauSac.background,
        body: const Center(child: CircularProgressIndicator(color: MauSac.primary)),
      );
    }

    // Override the app bar action in ManHinhTongQuan for Notifications
    final tongQuanScreen = ManHinhTongQuan(
      nguoiDung: widget.nguoiDung,
      danhSachGiaoDich: _danhSachGiaoDich,
      danhSachVi: _danhSachVi,
      nganSach: _nganSach ?? NganSach(id: 0, hanMuc: 0, daChi: 0, ngayBatDau: DateTime.now(), ngayKetThuc: DateTime.now()),
      moThemGiaoDich: _moModalThemGiaoDich,
      xemTatCaGiaoDich: () {
        setState(() {
          _chiMucHienTai = 2; // Switch to Wallets / History tab
        });
      },
      moThongBao: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ManHinhThongBao(userId: widget.nguoiDung.id)),
        );
      },
    );

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

    void _moModalThemViTien() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => ModalThemViTien(
          onThemViTien: _themViTien,
        ),
      );
    }

    final cacManHinh = [
      tongQuanScreen,
      ManHinhPhanTich(danhSachGiaoDich: _danhSachGiaoDich),
      ManHinhViTien(danhSachVi: _danhSachVi, danhSachGiaoDich: _danhSachGiaoDich, moThemViTien: _moModalThemViTien),
      ManHinhCaiDat(nguoiDung: widget.nguoiDung),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _chiMucHienTai,
        children: cacManHinh,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MauSac.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _moModalThemGiaoDich,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: MauSac.surface,
          border: Border(top: BorderSide(color: MauSac.borderSubtle, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _chiMucHienTai,
          onTap: (index) => setState(() => _chiMucHienTai = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: MauSac.surface,
          selectedItemColor: MauSac.primary,
          unselectedItemColor: MauSac.onSurfaceVariant,
          selectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.normal, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Phân tích',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Ví',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }
}
