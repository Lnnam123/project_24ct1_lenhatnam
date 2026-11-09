import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../backend/models/models.dart';
import '../chu_de/mau_sac.dart';
import '../thanh_phan/modal_ngan_sach.dart';
import '../../backend/database/database_service.dart';

class ManHinhQuanLyNganSach extends StatefulWidget {
  final int userId;
  final List<NganSach> danhSachNganSachKhoiTao;
  final List<DanhMuc> danhSachDanhMuc;
  final Future<void> Function(NganSach) onCapNhatNganSach;
  final Future<void> Function(int) onXoaNganSach;

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
  DateTime _thangHienTai = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _locTheoThang = true;
  bool _dangTai = false;

  @override
  void initState() {
    super.initState();
    _danhSachNganSach = widget.danhSachNganSachKhoiTao;
    
    // Nếu tháng hiện tại chưa có ngân sách nào nhưng các tháng khác có, mặc định hiển thị "Tất cả các tháng" để người dùng thấy ngân sách hiện có
    final now = DateTime.now();
    final coNganSachThangNay = _danhSachNganSach.any((ns) =>
        ns.ngayBatDau.year == now.year && ns.ngayBatDau.month == now.month);
    if (!coNganSachThangNay && _danhSachNganSach.isNotEmpty) {
      _locTheoThang = false;
    }
  }

  Future<void> _taiLaiNganSach() async {
    if (!mounted) return;
    setState(() => _dangTai = true);
    try {
      final danhSachMoi = await DatabaseService.instance.getBudgets(
        widget.userId,
        widget.danhSachDanhMuc,
      );
      if (mounted) {
        setState(() {
          _danhSachNganSach = danhSachMoi;
          _dangTai = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _dangTai = false);
      }
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
          thangMacDinh: _thangHienTai,
          danhSachDanhMuc: widget.danhSachDanhMuc,
          onCapNhatNganSach: (ns) async {
            await widget.onCapNhatNganSach(ns);
            await _taiLaiNganSach();
          },
          onXoaNganSach: (id) async {
            await widget.onXoaNganSach(id);
            await _taiLaiNganSach();
          },
        ),
      ),
    );
    await _taiLaiNganSach();
  }

  void _chuyenThang(int delta) {
    setState(() {
      _thangHienTai = DateTime(_thangHienTai.year, _thangHienTai.month + delta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách ngân sách theo tháng hoặc xem tất cả
    final danhSachHienThi = _locTheoThang
        ? _danhSachNganSach.where((ns) {
            return ns.ngayBatDau.year == _thangHienTai.year &&
                ns.ngayBatDau.month == _thangHienTai.month;
          }).toList()
        : _danhSachNganSach;

    final tongHanMuc = danhSachHienThi.fold<double>(0, (sum, ns) => sum + ns.hanMuc);
    final tongDaChi = danhSachHienThi.fold<double>(0, (sum, ns) => sum + ns.daChi);
    final tongTyLe = tongHanMuc > 0 ? (tongDaChi / tongHanMuc).clamp(0.0, 1.0) : 0.0;
    final tongConLai = tongHanMuc > 0 ? tongHanMuc - tongDaChi : 0.0;

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
            tooltip: 'Thêm ngân sách',
            onPressed: () => _moModalThemSuaNganSach(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _taiLaiNganSach,
        child: Column(
          children: [
            // Thanh chuyển tháng & chế độ lọc
            Container(
              color: MauSac.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: MauSac.primary),
                        onPressed: () => _chuyenThang(-1),
                        tooltip: 'Tháng trước',
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 20, color: MauSac.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Tháng ${_thangHienTai.month}/${_thangHienTai.year}',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: MauSac.onSurface,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: MauSac.primary),
                        onPressed: () => _chuyenThang(1),
                        tooltip: 'Tháng sau',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text('Tháng ${_thangHienTai.month}/${_thangHienTai.year}'),
                        selected: _locTheoThang,
                        onSelected: (selected) {
                          if (selected) setState(() => _locTheoThang = true);
                        },
                        selectedColor: MauSac.primary.withValues(alpha: 0.2),
                        labelStyle: GoogleFonts.manrope(
                          color: _locTheoThang ? MauSac.primary : MauSac.onSurfaceVariant,
                          fontWeight: _locTheoThang ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Tất cả các tháng'),
                        selected: !_locTheoThang,
                        onSelected: (selected) {
                          if (selected) setState(() => _locTheoThang = false);
                        },
                        selectedColor: MauSac.primary.withValues(alpha: 0.2),
                        labelStyle: GoogleFonts.manrope(
                          color: !_locTheoThang ? MauSac.primary : MauSac.onSurfaceVariant,
                          fontWeight: !_locTheoThang ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Card Tổng quan ngân sách tháng đã chọn
            if (danhSachHienThi.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MauSac.primary,
                      MauSac.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: MauSac.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _locTheoThang
                              ? 'Tổng ngân sách Tháng ${_thangHienTai.month}/${_thangHienTai.year}'
                              : 'Tổng ngân sách toàn bộ',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        Text(
                          '${(tongTyLe * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đã chi tiêu',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              _dinhDangTien(tongDaChi),
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              tongConLai >= 0 ? 'Còn lại' : 'Vượt quá',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              _dinhDangTien(tongConLai.abs()),
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: tongConLai >= 0 ? Colors.white : Colors.amberAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: tongTyLe,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          tongTyLe >= 1.0 ? Colors.redAccent : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Danh sách các ngân sách chi tiết
            Expanded(
              child: _dangTai
                  ? const Center(child: CircularProgressIndicator())
                  : danhSachHienThi.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pie_chart_outline, size: 64, color: MauSac.outline),
                                const SizedBox(height: 16),
                                Text(
                                  _locTheoThang
                                      ? 'Chưa có ngân sách cho Tháng ${_thangHienTai.month}/${_thangHienTai.year}'
                                      : 'Bạn chưa có ngân sách nào.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    color: MauSac.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () => _moModalThemSuaNganSach(context),
                                  icon: const Icon(Icons.add, color: Colors.white),
                                  label: Text(
                                    'Thiết lập ngân sách tháng này',
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MauSac.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: danhSachHienThi.length,
                          itemBuilder: (context, index) {
                            final ns = danhSachHienThi[index];
                            final tyLe = ns.phanTram;
                            final mauThanhTienDo = tyLe > 90
                                ? MauSac.error
                                : (tyLe > 70 ? const Color(0xFFF59E0B) : MauSac.primary);

                            return InkWell(
                              onTap: () => _moModalThemSuaNganSach(context, nganSachCu: ns),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
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
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      ns.danhMuc != null
                                                          ? ns.danhMuc!.ten
                                                          : 'Ngân sách chung',
                                                      style: GoogleFonts.manrope(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                        color: MauSac.onSurface,
                                                      ),
                                                    ),
                                                  ),
                                                  // Badge Tháng áp dụng
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: MauSac.surfaceContainerHighest.withValues(alpha: 0.5),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'T${ns.ngayBatDau.month}/${ns.ngayBatDau.year}',
                                                      style: GoogleFonts.manrope(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: MauSac.primary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
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
                                        const SizedBox(width: 12),
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
                                    const SizedBox(height: 12),
                                    LinearProgressIndicator(
                                      value: (ns.phanTram / 100).clamp(0.0, 1.0),
                                      minHeight: 8,
                                      borderRadius: BorderRadius.circular(8),
                                      backgroundColor: mauThanhTienDo.withValues(alpha: 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(mauThanhTienDo),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          ns.daChi <= ns.hanMuc
                                              ? 'Còn lại: ${_dinhDangTien(ns.hanMuc - ns.daChi)}'
                                              : 'Vượt hạn mức: ${_dinhDangTien(ns.daChi - ns.hanMuc)}',
                                          style: GoogleFonts.manrope(
                                            fontSize: 12,
                                            color: ns.daChi <= ns.hanMuc
                                                ? MauSac.onSurfaceVariant
                                                : MauSac.error,
                                            fontWeight: ns.daChi > ns.hanMuc
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                          color: MauSac.outline,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
