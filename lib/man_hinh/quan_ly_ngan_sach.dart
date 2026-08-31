import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';
import '../thanh_phan/modal_ngan_sach.dart';
import '../du_lieu/database_helper.dart';

class ManHinhQuanLyNganSach extends StatefulWidget {
  final int userId;
  final List<NganSach> danhSachNganSachKhoiTao;
  final List<DanhMuc> danhSachDanhMuc;
  final Function(NganSach) onCapNhatNganSach;
  final Function(int) onXoaNganSach;

  const ManHinhQuanLyNganSach({
    super.key,
    required this.userId,
    required this.danhSachNganSachKhoiTao,
    required this.danhSachDanhMuc,
    required this.onCapNhatNganSach,
    required this.onXoaNganSach,
  });

  @override
  State<ManHinhQuanLyNganSach> createState() => _ManHinhQuanLyNganSachState();
}

class _ManHinhQuanLyNganSachState extends State<ManHinhQuanLyNganSach> {
  late List<NganSach> _danhSachNganSach;

  @override
  void initState() {
    super.initState();
    _danhSachNganSach = widget.danhSachNganSachKhoiTao;
  }

  Future<void> _taiLaiNganSach() async {
    // Tải lại từ DB
    final danhSachMoi = await DatabaseHelper.instance.getBudgets(widget.userId, widget.danhSachDanhMuc);
    if (mounted) {
      setState(() {
        _danhSachNganSach = danhSachMoi;
      });
    }
  }

  String _dinhDangTien(double soTien) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(soTien);
  }

  void _moModalThemSuaNganSach(BuildContext context, {NganSach? nganSachCu}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ModalNganSach(
          nganSachCu: nganSachCu,
          danhSachDanhMuc: widget.danhSachDanhMuc,
          onCapNhatNganSach: widget.onCapNhatNganSach,
          onXoaNganSach: widget.onXoaNganSach,
        ),
      ),
    );
    
    // Đợi 1 chút để main.dart kịp lưu vào DB rồi tải lại
    await Future.delayed(const Duration(milliseconds: 300));
    _taiLaiNganSach();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MauSac.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Quản lý Ngân Sách',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: MauSac.primary),
            onPressed: () => _moModalThemSuaNganSach(context),
          ),
        ],
      ),
      body: _danhSachNganSach.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, size: 64, color: MauSac.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Bạn chưa có ngân sách nào.',
                    style: GoogleFonts.manrope(color: MauSac.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _danhSachNganSach.length,
              itemBuilder: (context, index) {
                final ns = _danhSachNganSach[index];
                final tyLe = ns.phanTram;
                final mauThanhTienDo = tyLe > 90
                    ? MauSac.error
                    : (tyLe > 70 ? const Color(0xFFF59E0B) : MauSac.primary);

                return InkWell(
                  onTap: () => _moModalThemSuaNganSach(context, nganSachCu: ns),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MauSac.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MauSac.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: ns.danhMuc != null
                                  ? ns.danhMuc!.mauSac.withValues(alpha: 0.15)
                                  : MauSac.primary.withValues(alpha: 0.15),
                              radius: 20,
                              child: Icon(
                                ns.danhMuc?.icon ?? Icons.category,
                                color: ns.danhMuc?.mauSac ?? MauSac.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ns.danhMuc != null ? 'Ngân sách: ${ns.danhMuc!.ten}' : 'Ngân sách chung',
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: MauSac.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_dinhDangTien(ns.daChi)} / ${_dinhDangTien(ns.hanMuc)}',
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      color: MauSac.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${ns.phanTram.toStringAsFixed(0)}%',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: mauThanhTienDo,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: ns.phanTram / 100,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(8),
                          backgroundColor: mauThanhTienDo.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(mauThanhTienDo),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
