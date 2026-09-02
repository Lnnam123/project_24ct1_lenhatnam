import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

class ManHinhChiTietPhanTich extends StatefulWidget {
  final List<GiaoDich> danhSachGiaoDich;

  const ManHinhChiTietPhanTich({
    super.key,
    required this.danhSachGiaoDich,
  });

  @override
  State<ManHinhChiTietPhanTich> createState() => _ManHinhChiTietPhanTichState();
}

class _ManHinhChiTietPhanTichState extends State<ManHinhChiTietPhanTich> {
  String _thoiGianChon = 'Tháng này';
  final List<String> _danhSachThoiGian = [
    'Hôm nay',
    'Tuần này',
    'Tháng này',
    'Quý này',
    'Năm nay'
  ];

  String _dinhDangTien(double soTien) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(soTien);
  }

  List<GiaoDich> _layGiaoDichTheoThoiGian() {
    final now = DateTime.now();
    return widget.danhSachGiaoDich.where((gd) {
      if (gd.loai != LoaiGiaoDich.chiTieu) return false;
      
      switch (_thoiGianChon) {
        case 'Hôm nay':
          return gd.ngay.year == now.year &&
              gd.ngay.month == now.month &&
              gd.ngay.day == now.day;
        case 'Tuần này':
          final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          return gd.ngay.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                 gd.ngay.isBefore(endOfWeek.add(const Duration(days: 1)));
        case 'Tháng này':
          return gd.ngay.year == now.year && gd.ngay.month == now.month;
        case 'Quý này':
          final currentQuarter = ((now.month - 1) / 3).floor() + 1;
          final gdQuarter = ((gd.ngay.month - 1) / 3).floor() + 1;
          return gd.ngay.year == now.year && gdQuarter == currentQuarter;
        case 'Năm nay':
          return gd.ngay.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gdTheoThoiGian = _layGiaoDichTheoThoiGian();

    double tongChi = 0;
    Map<DanhMuc, double> thongKe = {};
    for (var gd in gdTheoThoiGian) {
      tongChi += gd.soTien;
      thongKe[gd.danhMuc] = (thongKe[gd.danhMuc] ?? 0) + gd.soTien;
    }

    final dsThongKe = thongKe.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
          'Tình hình chi tiêu',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 105,
                  child: DropdownButtonFormField<String>(
                    value: _thoiGianChon,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(16),
                    dropdownColor: const Color(0xFFF8FAFC),
                    icon: const Icon(Icons.keyboard_arrow_down, color: MauSac.onSurfaceVariant),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.borderSubtle),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: _danhSachThoiGian.map((time) {
                      return DropdownMenuItem<String>(
                        value: time,
                        child: Text(
                          time,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: MauSac.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _thoiGianChon = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          
          Expanded(
            child: tongChi == 0
                ? Center(
                    child: Text(
                      'Chưa có chi tiêu nào trong thời gian này',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: MauSac.onSurfaceVariant,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              TweenAnimationBuilder<double>(
                                key: ValueKey(_thoiGianChon), // Re-animate on filter change
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1500),
                                curve: Curves.easeOutCubic,
                                builder: (context, animValue, child) {
                                  return SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CircularProgressIndicator(
                                          value: 1.0,
                                          strokeWidth: 20,
                                          backgroundColor: MauSac.surfaceContainer,
                                          valueColor: const AlwaysStoppedAnimation<Color>(
                                              MauSac.surfaceContainer),
                                        ),
                                        ...List.generate(dsThongKe.length, (index) {
                                          double accumulated = 0;
                                          for (int i = 0; i <= index; i++) {
                                            accumulated += dsThongKe[i].value;
                                          }
                                          final targetValue = accumulated / tongChi;
                                          final value = targetValue * animValue; // Animate value
                                          final color = dsThongKe[index].key.mauSac;
                                          return CircularProgressIndicator(
                                            value: value,
                                            strokeWidth: 20,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(color),
                                          );
                                        }).reversed,
                                        Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Tổng chi',
                                                  style: GoogleFonts.manrope(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: MauSac.onSurfaceVariant)),
                                              const SizedBox(height: 4),
                                              Text(_dinhDangTien(tongChi * animValue),
                                                  style: GoogleFonts.manrope(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: MauSac.onSurface)),
                                            ],
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
                        const SizedBox(height: 24),
                        Text(
                          'Chi tiết từng danh mục',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MauSac.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...dsThongKe.map((e) {
                          final percent = (e.value / tongChi * 100).toStringAsFixed(1);
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
                                    color: e.key.mauSac.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    e.key.icon,
                                    color: e.key.mauSac,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.key.ten,
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: MauSac.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$percent%',
                                        style: GoogleFonts.manrope(
                                          color: MauSac.onSurfaceVariant,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _dinhDangTien(e.value),
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: MauSac.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
