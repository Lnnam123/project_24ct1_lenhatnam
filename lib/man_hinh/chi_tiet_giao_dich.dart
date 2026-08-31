import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

class ManHinhChiTietGiaoDich extends StatelessWidget {
  final String tieuDe;
  final List<GiaoDich> danhSach;

  const ManHinhChiTietGiaoDich({
    super.key,
    required this.tieuDe,
    required this.danhSach,
  });

  String _dinhDangTien(double soTien) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(soTien);
  }

  @override
  Widget build(BuildContext context) {
    double tongThu = 0;
    double tongChi = 0;
    
    // Sắp xếp giảm dần theo thời gian
    final danhSachSapXep = List<GiaoDich>.from(danhSach);
    danhSachSapXep.sort((a, b) => b.ngay.compareTo(a.ngay));

    for (var tx in danhSachSapXep) {
      if (tx.loai == LoaiGiaoDich.thuNhap) {
        tongThu += tx.soTien;
      } else {
        tongChi += tx.soTien;
      }
    }

    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          tieuDe,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: MauSac.onSurface,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MauSac.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: MauSac.outlineVariant.withValues(alpha: 0.3),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryCards(tongThu, tongChi),
          Expanded(
            child: danhSachSapXep.isEmpty
                ? Center(
                    child: Text(
                      'Không có giao dịch nào',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: MauSac.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: danhSachSapXep.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: MauSac.outlineVariant.withValues(alpha: 0.3),
                    ),
                    itemBuilder: (context, index) {
                      return _buildTransactionItem(danhSachSapXep[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double tongThu, double tongChi) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MauSac.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MauSac.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '+ ${_dinhDangTien(tongThu)}',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MauSac.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tổng thu',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: MauSac.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MauSac.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MauSac.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '- ${_dinhDangTien(tongChi)}',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MauSac.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tổng chi',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: MauSac.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(GiaoDich tx) {
    final bool isIncome = tx.loai == LoaiGiaoDich.thuNhap;
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isIncome ? MauSac.success.withValues(alpha: 0.1) : MauSac.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    tx.loai == LoaiGiaoDich.thuNhap ? Icons.payments : tx.danhMuc.icon,
                    color: isIncome ? MauSac.success : MauSac.onSurface,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.danhMuc.ten,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MauSac.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            timeFormat.format(tx.ngay),
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: MauSac.onSurfaceVariant,
                            ),
                          ),
                          if (tx.ghiChu != null && tx.ghiChu!.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: MauSac.outlineVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tx.ghiChu!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  color: MauSac.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isIncome ? '+' : '-'} ${_dinhDangTien(tx.soTien)}',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isIncome ? MauSac.success : MauSac.error,
            ),
          ),
        ],
      ),
    );
  }

}
