import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../chu_de/mau_sac.dart';
import '../mo_hinh/du_lieu.dart';

class ModalDoiDanhMucGiaoDich extends StatefulWidget {
  final GiaoDich giaoDich;
  final List<DanhMuc> danhSachDanhMuc;
  final Function(int transactionId, DanhMuc danhMucMoi) onDoiDanhMuc;

  const ModalDoiDanhMucGiaoDich({
    super.key,
    required this.giaoDich,
    required this.danhSachDanhMuc,
    required this.onDoiDanhMuc,
  });

  @override
  State<ModalDoiDanhMucGiaoDich> createState() => _ModalDoiDanhMucGiaoDichState();
}

class _ModalDoiDanhMucGiaoDichState extends State<ModalDoiDanhMucGiaoDich> {
  late DanhMuc _danhMucChon;

  @override
  void initState() {
    super.initState();
    _danhMucChon = widget.giaoDich.danhMuc;
  }

  String _dinhDangTien(double soTien) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(soTien);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesFiltered = widget.danhSachDanhMuc
        .where((c) => c.loai == widget.giaoDich.loai)
        .toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: MauSac.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MauSac.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Sửa danh mục giao dịch',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MauSac.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Transaction Summary Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MauSac.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: widget.giaoDich.danhMuc.mauSac.withValues(alpha: 0.15),
                  child: Icon(widget.giaoDich.danhMuc.icon, color: widget.giaoDich.danhMuc.mauSac, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.giaoDich.tieuDe,
                        style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        _dinhDangTien(widget.giaoDich.soTien),
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: widget.giaoDich.loai == LoaiGiaoDich.chiTieu ? MauSac.onSurface : MauSac.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'CHỌN DANH MỤC MỚI',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: MauSac.outline,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          // Category Grid
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categoriesFiltered.map((cat) {
                  final isSelected = _danhMucChon.id == cat.id;
                  return GestureDetector(
                    onTap: () => setState(() => _danhMucChon = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? MauSac.primaryContainer.withValues(alpha: 0.2) : MauSac.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? MauSac.primary : MauSac.borderSubtle,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat.icon,
                            size: 18,
                            color: isSelected ? MauSac.primary : cat.mauSac,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat.ten,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? MauSac.primary : MauSac.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MauSac.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (widget.giaoDich.id != null) {
                  widget.onDoiDanhMuc(widget.giaoDich.id!, _danhMucChon);
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'Lưu thay đổi',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
