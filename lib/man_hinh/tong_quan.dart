import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

class ManHinhTongQuan extends StatefulWidget {
  final NguoiDung nguoiDung;
  final List<GiaoDich> danhSachGiaoDich;
  final List<ViTien> danhSachVi;
  final NganSach nganSach;
  final VoidCallback moThemGiaoDich;
  final VoidCallback xemTatCaGiaoDich;
  final VoidCallback moThongBao;

  const ManHinhTongQuan({
    super.key,
    required this.nguoiDung,
    required this.danhSachGiaoDich,
    required this.danhSachVi,
    required this.nganSach,
    required this.moThemGiaoDich,
    required this.xemTatCaGiaoDich,
    required this.moThongBao,
  });

  @override
  State<ManHinhTongQuan> createState() => _ManHinhTongQuanState();
}

class _ManHinhTongQuanState extends State<ManHinhTongQuan> {
  bool _coThongBaoMoi = true;

  double get tongSoDu => widget.danhSachVi.fold(0, (sum, v) => sum + v.soDu);

  String _dinhDangTien(double soTien) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(soTien);
  }

  @override
  Widget build(BuildContext context) {
    final giaoDichGanDay = widget.danhSachGiaoDich.take(5).toList();

    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: MauSac.surfaceContainerHigh,
              child: Icon(Icons.person, color: MauSac.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Trang chủ',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MauSac.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: MauSac.onSurface),
                if (_coThongBaoMoi)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: MauSac.error,
                    ),
                  ),
              ],
            ),
            onPressed: () {
              setState(() => _coThongBaoMoi = false);
              widget.moThongBao();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  Text(
                    'TỔNG SỐ DƯ',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _dinhDangTien(tongSoDu),
                    style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ngân sách: ${_dinhDangTien(widget.nganSach.hanMuc)}',
                        style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xE6FFFFFF)),
                      ),
                      Text(
                        '${widget.nganSach.phanTram.toStringAsFixed(0)}%',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: widget.nganSach.phanTram / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
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
                    onPressed: widget.moThemGiaoDich,
                    icon: const Icon(Icons.add_a_photo_outlined, size: 20),
                    label: Text(
                      'AI / Camera',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13),
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hạn mức ngân sách hiện tại: ${_dinhDangTien(widget.nganSach.hanMuc)}'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.pie_chart_outline, size: 20),
                    label: Text(
                      'Ngân sách',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

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
                      child: Text('Chưa có giao dịch nào', style: GoogleFonts.manrope()),
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
                      return Container(
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
                              backgroundColor: item.danhMuc.mauSac.withValues(alpha: 0.15),
                              child: Icon(item.danhMuc.icon, color: item.danhMuc.mauSac, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    '${DateFormat('dd/MM, HH:mm').format(item.ngay)} • ${item.viTien.tenVi}',
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
                                color: isExpense ? MauSac.onSurface : MauSac.success,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 80), // bottom padding for FAB & Nav
          ],
        ),
      ),
    );
  }
}
