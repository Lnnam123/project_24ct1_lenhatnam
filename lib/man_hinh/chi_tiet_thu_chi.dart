import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

class ManHinhChiTietThuChi extends StatelessWidget {
  final List<GiaoDich> danhSachGiaoDich;

  const ManHinhChiTietThuChi({
    super.key,
    required this.danhSachGiaoDich,
  });

  String _dinhDangTien(double soTien) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(soTien);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final gdThangNay = danhSachGiaoDich
        .where((gd) => gd.ngay.year == now.year && gd.ngay.month == now.month)
        .toList();
        
    // Sort descending by date
    gdThangNay.sort((a, b) => b.ngay.compareTo(a.ngay));

    final thu = gdThangNay
        .where((gd) => gd.loai == LoaiGiaoDich.thuNhap)
        .fold(0.0, (s, e) => s + e.soTien);
    final chi = gdThangNay
        .where((gd) => gd.loai == LoaiGiaoDich.chiTieu)
        .fold(0.0, (s, e) => s + e.soTien);

    final maxVal = (thu > chi ? thu : chi);
    final thuPercent = maxVal > 0 ? (thu / maxVal) : 0.0;
    final chiPercent = maxVal > 0 ? (chi / maxVal) : 0.0;

    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MauSac.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thu chi tháng này',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tổng kết thu chi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MauSac.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: MauSac.borderSubtle.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Thu nhập',
                          style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: MauSac.onSurfaceVariant)),
                      Text('+${_dinhDangTien(thu)}',
                          style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: MauSac.success)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: thuPercent,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                    backgroundColor: MauSac.surfaceContainer,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(MauSac.success),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Chi tiêu',
                          style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: MauSac.onSurfaceVariant)),
                      Text('-${_dinhDangTien(chi)}',
                          style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: MauSac.error)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: chiPercent,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                    backgroundColor: MauSac.surfaceContainer,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(MauSac.error),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Danh sách giao dịch',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MauSac.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (gdThangNay.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'Chưa có giao dịch nào trong tháng này',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: MauSac.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gdThangNay.length,
                itemBuilder: (context, index) {
                  final gd = gdThangNay[index];
                  final isThu = gd.loai == LoaiGiaoDich.thuNhap;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MauSac.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: MauSac.borderSubtle.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (gd.danhMuc.mauSac)
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            gd.danhMuc.icon,
                            color: gd.danhMuc.mauSac,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gd.danhMuc.ten,
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: MauSac.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(gd.ngay),
                                style: GoogleFonts.manrope(
                                  color: MauSac.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isThu ? "+" : "-"}${_dinhDangTien(gd.soTien)}',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isThu ? MauSac.success : MauSac.error,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
