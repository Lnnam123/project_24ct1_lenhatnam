import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

class ManHinhViTien extends StatefulWidget {
  final List<ViTien> danhSachVi;
  final List<GiaoDich> danhSachGiaoDich;
  final VoidCallback moThemViTien;

  const ManHinhViTien({
    super.key,
    required this.danhSachVi,
    required this.danhSachGiaoDich,
    required this.moThemViTien,
  });

  @override
  State<ManHinhViTien> createState() => _ManHinhViTienState();
}

class _ManHinhViTienState extends State<ManHinhViTien> {
  String _boloc = 'Tất cả';

  String _dinhDangTien(double soTien) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(soTien);
  }

  @override
  Widget build(BuildContext context) {
    final giaoDichDaLoc = widget.danhSachGiaoDich.where((tx) {
      if (_boloc == 'Chi tiêu') return tx.loai == LoaiGiaoDich.chiTieu;
      if (_boloc == 'Thu nhập') return tx.loai == LoaiGiaoDich.thuNhap;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        title: Text('Tài khoản & Ví tiền', style: GoogleFonts.manrope()),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách tài khoản',
                  style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: widget.moThemViTien,
                  icon: const Icon(Icons.add_circle, color: MauSac.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Horizontal Wallets List
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.danhSachVi.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                itemBuilder: (ctx, index) {
                  final vi = widget.danhSachVi[index];
                  return Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MauSac.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MauSac.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: vi.mauSac.withValues(alpha: 0.15),
                              child: Icon(vi.icon, color: vi.mauSac, size: 18),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: MauSac.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                vi.loaiVi,
                                style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vi.tenVi,
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: MauSac.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _dinhDangTien(vi.soDu),
                              style: GoogleFonts.manrope(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: MauSac.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // All Transactions Section Header & Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lịch sử giao dịch',
                  style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _boloc,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.filter_list, size: 20),
                  items: ['Tất cả', 'Thu nhập', 'Chi tiêu'].map((f) {
                    return DropdownMenuItem<String>(
                      value: f,
                      child: Text(f, style: GoogleFonts.manrope(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _boloc = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Transactions List
            giaoDichDaLoc.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Text('Không tìm thấy giao dịch', style: GoogleFonts.manrope()),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: giaoDichDaLoc.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final item = giaoDichDaLoc[index];
                      final isExpense = item.loai == LoaiGiaoDich.chiTieu;
                      return Container(
                        padding: const EdgeInsets.all(14),
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
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.tieuDe,
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${DateFormat('dd/MM/yyyy HH:mm').format(item.ngay)} • ${item.viTien.tenVi}',
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
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
