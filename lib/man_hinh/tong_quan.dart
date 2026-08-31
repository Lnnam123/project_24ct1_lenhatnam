import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';
//import '../thanh_phan/modal_ngan_sach.dart';
import '../man_hinh/quan_ly_ngan_sach.dart';

class ManHinhTongQuan extends StatefulWidget {
  final NguoiDung nguoiDung;
  final List<GiaoDich> danhSachGiaoDich;
  final List<ViTien> danhSachVi;
  final List<DanhMuc> danhSachDanhMuc;
  final List<NganSach> danhSachNganSach;
  final VoidCallback moThemGiaoDich;
  final Function(GiaoDich) moSuaGiaoDich;
  final VoidCallback xemTatCaGiaoDich;
  final VoidCallback moThongBao;
  final Function(int, DanhMuc) onDoiDanhMucGiaoDich;
  final Future<void> Function() onRefresh;
  final Function(NganSach) onCapNhatNganSach;
  final Function(int) onXoaNganSach;
  final bool coThongBaoChuaDoc;

  const ManHinhTongQuan({
    super.key,
    required this.nguoiDung,
    required this.danhSachGiaoDich,
    required this.danhSachVi,
    required this.danhSachDanhMuc,
    required this.danhSachNganSach,
    required this.moThemGiaoDich,
    required this.moSuaGiaoDich,
    required this.xemTatCaGiaoDich,
    required this.moThongBao,
    required this.onDoiDanhMucGiaoDich,
    required this.onRefresh,
    required this.onCapNhatNganSach,
    required this.onXoaNganSach,
    this.coThongBaoChuaDoc = false,
  });

  @override
  State<ManHinhTongQuan> createState() => _ManHinhTongQuanState();
}

class _ManHinhTongQuanState extends State<ManHinhTongQuan> {
  bool _anSoDu = true;
  
  double get tongSoDu => widget.danhSachVi.fold(0, (sum, v) => sum + v.soDu);

  String _dinhDangTien(double soTien) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(soTien);
  }

  void _moManHinhNganSach() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManHinhQuanLyNganSach(
          userId: widget.nguoiDung.id,
          danhSachNganSachKhoiTao: widget.danhSachNganSach,
          danhSachDanhMuc: widget.danhSachDanhMuc,
          onCapNhatNganSach: widget.onCapNhatNganSach,
          onXoaNganSach: widget.onXoaNganSach,
        ),
      ),
    );
  }

  void _xemChiTietVuotNganSach() {
    final overBudgets = widget.danhSachNganSach.where((b) => b.hanMuc > 0 && b.daChi > b.hanMuc).toList();
    if (overBudgets.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: MauSac.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ngân sách vượt hạn mức',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MauSac.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: MauSac.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...overBudgets.map((b) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MauSac.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MauSac.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (b.danhMuc?.mauSac ?? MauSac.primary).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        b.danhMuc?.icon ?? Icons.category,
                        color: b.danhMuc?.mauSac ?? MauSac.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.danhMuc?.ten ?? 'Tổng quát',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: MauSac.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Đã chi: ${_dinhDangTien(b.daChi)} / ${_dinhDangTien(b.hanMuc)}',
                            style: GoogleFonts.manrope(
                              color: MauSac.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vượt quá: ${_dinhDangTien(b.daChi - b.hanMuc)}',
                            style: GoogleFonts.manrope(
                              color: MauSac.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final giaoDichGanDay = widget.danhSachGiaoDich.take(5).toList();

    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Trang chủ',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: MauSac.onSurface,
                ),
                if (widget.coThongBaoChuaDoc)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: MauSac.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: widget.moThongBao,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Xin chào, ${widget.nguoiDung.hoTen}!',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: MauSac.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Balance Card (Exact Cointap Styling)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [MauSac.primary, Color(0xFF003EA8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MauSac.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
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
                          'TỔNG SỐ DƯ',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white70,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _anSoDu = !_anSoDu;
                            });
                          },
                          child: Icon(
                            _anSoDu ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _anSoDu ? '****** đ' : _dinhDangTien(tongSoDu),
                      style: GoogleFonts.manrope(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Builder(
                      builder: (context) {
                        final tongNganSach = widget.danhSachNganSach
                            .fold<double>(0, (sum, ns) => sum + ns.hanMuc);
                        final tongDaChi = widget.danhSachNganSach.fold<double>(
                          0,
                          (sum, ns) => sum + ns.daChi,
                        );
                        final phanTram = tongNganSach > 0
                            ? (tongDaChi / tongNganSach * 100).clamp(0, 100)
                            : 0.0;

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tongNganSach > 0
                                      ? 'Đã chi: ${_dinhDangTien(tongDaChi)} / ${_dinhDangTien(tongNganSach)}'
                                      : 'Chưa có ngân sách',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: const Color(0xE6FFFFFF),
                                  ),
                                ),
                                if (tongNganSach > 0)
                                  Text(
                                    '${phanTram.toStringAsFixed(0)}%',
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (tongNganSach > 0)
                              LinearProgressIndicator(
                                value: phanTram / 100,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(10),
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Actions Bar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MauSac.surface,
                        foregroundColor: MauSac.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: MauSac.borderSubtle),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tính năng đang phát triển', style: GoogleFonts.manrope()),
                            backgroundColor: MauSac.primary,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.document_scanner_outlined, size: 20),
                      label: Text(
                        'Quét hoá đơn',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MauSac.surface,
                        foregroundColor: MauSac.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: MauSac.borderSubtle),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _moManHinhNganSach,
                      icon: const Icon(Icons.pie_chart_outline, size: 20),
                      label: Text(
                        'Ngân sách',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Cảnh báo vượt ngân sách
              if (widget.danhSachNganSach.any((b) => b.hanMuc > 0 && b.daChi > b.hanMuc))
                GestureDetector(
                  onTap: _xemChiTietVuotNganSach,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MauSac.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MauSac.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: MauSac.error, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cảnh báo vượt ngân sách!',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  color: MauSac.error,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bạn đã chi tiêu vượt quá hạn mức của ${widget.danhSachNganSach.where((b) => b.hanMuc > 0 && b.daChi > b.hanMuc).length} ngân sách. Nhấn để xem chi tiết.',
                                style: GoogleFonts.manrope(
                                  color: MauSac.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Giao dịch gần đây',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MauSac.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.xemTatCaGiaoDich,
                    child: Text(
                      'Xem tất cả',
                      style: GoogleFonts.manrope(
                        color: MauSac.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Transactions List
              giaoDichGanDay.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'Chưa có giao dịch nào',
                          style: GoogleFonts.manrope(),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: giaoDichGanDay.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                      itemBuilder: (ctx, index) {
                        final item = giaoDichGanDay[index];
                        final isExpense = item.loai == LoaiGiaoDich.chiTieu;
                        return InkWell(
                          onTap: () => widget.moSuaGiaoDich(item),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MauSac.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: MauSac.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: item.danhMuc.mauSac
                                      .withValues(alpha: 0.15),
                                  child: Icon(
                                    item.danhMuc.icon,
                                    color: item.danhMuc.mauSac,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.tieuDe,
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: MauSac.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${DateFormat('HH:mm - dd/MM').format(item.ngay)} • ${item.viTien.tenVi}',
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          color: MauSac.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${isExpense ? '-' : '+'}${_dinhDangTien(item.soTien)}',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isExpense
                                        ? MauSac.error
                                        : MauSac.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 80), // bottom padding for FAB & Nav
            ],
          ),
        ),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Add commas
    String formattedText = '';
    int count = 0;
    for (int i = newText.length - 1; i >= 0; i--) {
      formattedText = newText[i] + formattedText;
      count++;
      if (count % 3 == 0 && i != 0) {
        formattedText = ',' + formattedText;
      }
    }

    int selectionIndexFromTheRight =
        newValue.text.length - newValue.selection.end;
    int offset = formattedText.length - selectionIndexFromTheRight;
    if (offset < 0) offset = 0;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
