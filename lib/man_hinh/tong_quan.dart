import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';
import '../man_hinh/quan_ly_ngan_sach.dart';
import '../man_hinh/chi_tiet_thu_chi.dart';
import '../man_hinh/chi_tiet_phan_tich.dart';
import '../man_hinh/chi_tiet_vi.dart';
import '../man_hinh/tro_ly_ai.dart';

class ManHinhTongQuan extends StatefulWidget {
  static const String tenTrang = 'Tổng quan';
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
  double _aiChatX = 0;
  double _aiChatY = 0;
  bool _isAiChatInitialized = false;
  bool _showAiChat = true;

  String _thoiGianChonPhanTich = 'Tháng này';
  final List<String> _danhSachThoiGian = [
    'Hôm nay',
    'Tuần này',
    'Tháng này',
    'Quý này',
    'Năm nay',
  ];

  double get tongSoDu => widget.danhSachVi.fold(0, (sum, v) => sum + v.soDu);

  String _dinhDangTien(double soTien) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(soTien);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isAiChatInitialized) {
      final size = MediaQuery.of(context).size;
      // Vị trí mặc định: Ở bên phải, cao lên tầm 1/3 trang
      _aiChatX = size.width - 80;
      _aiChatY = size.height * 0.65; // Đẩy lên cao hơn một chút
      _isAiChatInitialized = true;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          ManHinhTongQuan.tenTrang,
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
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Xin chào, ${widget.nguoiDung.hoTen}',
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Thu chi tháng này
              Builder(
                builder: (ctx) {
                  final now = DateTime.now();
                  final gdThangNay = widget.danhSachGiaoDich
                      .where(
                        (gd) =>
                            gd.ngay.year == now.year &&
                            gd.ngay.month == now.month,
                      )
                      .toList();
                  final thu = gdThangNay
                      .where((gd) => gd.loai == LoaiGiaoDich.thuNhap)
                      .fold(0.0, (s, e) => s + e.soTien);
                  final chi = gdThangNay
                      .where((gd) => gd.loai == LoaiGiaoDich.chiTieu)
                      .fold(0.0, (s, e) => s + e.soTien);

                  final maxVal = (thu > chi ? thu : chi);
                  final thuPercent = maxVal > 0 ? (thu / maxVal) : 0.0;
                  final chiPercent = maxVal > 0 ? (chi / maxVal) : 0.0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManHinhChiTietThuChi(
                            danhSachGiaoDich: widget.danhSachGiaoDich,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MauSac.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: MauSac.borderSubtle.withValues(alpha: 0.4),
                        ),
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
                              Text(
                                'Thu chi tháng này',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: MauSac.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Income
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Thu nhập',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: MauSac.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '+${_dinhDangTien(thu)}',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: MauSac.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: thuPercent,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            backgroundColor: MauSac.surfaceContainer,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              MauSac.success,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Expense
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Chi tiêu',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: MauSac.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '-${_dinhDangTien(chi)}',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: MauSac.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: chiPercent,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            backgroundColor: MauSac.surfaceContainer,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              MauSac.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Budget Progress Widget
              Builder(
                builder: (context) {
                  final tongNganSach = widget.danhSachNganSach.fold<double>(
                    0,
                    (sum, ns) => sum + ns.hanMuc,
                  );
                  final tongDaChi = widget.danhSachNganSach.fold<double>(
                    0,
                    (sum, ns) => sum + ns.daChi,
                  );
                  final phanTram = tongNganSach > 0
                      ? (tongDaChi / tongNganSach).clamp(0.0, 1.0)
                      : 0.0;
                  final conLai = tongNganSach > 0
                      ? tongNganSach - tongDaChi
                      : 0.0;

                  return GestureDetector(
                    onTap: _moManHinhNganSach,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MauSac.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: MauSac.borderSubtle.withValues(alpha: 0.4),
                        ),
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
                              Text(
                                'Ngân sách',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: MauSac.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Đã chi tiêu',
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      color: MauSac.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _dinhDangTien(tongDaChi),
                                    style: GoogleFonts.manrope(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: MauSac.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Tổng ngân sách',
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      color: MauSac.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _dinhDangTien(tongNganSach),
                                    style: GoogleFonts.manrope(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: MauSac.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: phanTram,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                            backgroundColor: MauSac.surfaceContainer,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              phanTram >= 1 ? MauSac.error : MauSac.warning,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                conLai >= 0
                                    ? 'Còn lại ${_dinhDangTien(conLai)}'
                                    : 'Vượt quá ${_dinhDangTien(-conLai)}',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  color: MauSac.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${(phanTram * 100).toStringAsFixed(0)}%',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  color: MauSac.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Phân tích chi tiêu
              Builder(
                builder: (context) {
                  final now = DateTime.now();
                  final gdThangNay = widget.danhSachGiaoDich.where((gd) {
                    if (gd.loai != LoaiGiaoDich.chiTieu) return false;
                    switch (_thoiGianChonPhanTich) {
                      case 'Hôm nay':
                        return gd.ngay.year == now.year &&
                            gd.ngay.month == now.month &&
                            gd.ngay.day == now.day;
                      case 'Tuần này':
                        final startOfWeek = DateTime(
                          now.year,
                          now.month,
                          now.day,
                        ).subtract(Duration(days: now.weekday - 1));
                        final endOfWeek = startOfWeek.add(
                          const Duration(
                            days: 6,
                            hours: 23,
                            minutes: 59,
                            seconds: 59,
                          ),
                        );
                        return gd.ngay.isAfter(
                              startOfWeek.subtract(const Duration(days: 1)),
                            ) &&
                            gd.ngay.isBefore(
                              endOfWeek.add(const Duration(days: 1)),
                            );
                      case 'Tháng này':
                        return gd.ngay.year == now.year &&
                            gd.ngay.month == now.month;
                      case 'Quý này':
                        final currentQuarter =
                            ((now.month - 1) / 3).floor() + 1;
                        final gdQuarter = ((gd.ngay.month - 1) / 3).floor() + 1;
                        return gd.ngay.year == now.year &&
                            gdQuarter == currentQuarter;
                      case 'Năm nay':
                        return gd.ngay.year == now.year;
                      default:
                        return true;
                    }
                  }).toList();

                  double tongChi = 0;
                  Map<DanhMuc, double> thongKe = {};
                  for (var gd in gdThangNay) {
                    tongChi += gd.soTien;
                    thongKe[gd.danhMuc] =
                        (thongKe[gd.danhMuc] ?? 0) + gd.soTien;
                  }

                  final dsThongKe = thongKe.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final top3 = dsThongKe.take(3).toList();
                  final khac = dsThongKe
                      .skip(3)
                      .fold<double>(0.0, (s, e) => s + e.value);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManHinhChiTietPhanTich(
                            danhSachGiaoDich: widget.danhSachGiaoDich,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MauSac.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: MauSac.borderSubtle.withValues(alpha: 0.4),
                        ),
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
                              Text(
                                'Tình hình chi tiêu',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: MauSac.onSurface,
                                ),
                              ),
                              SizedBox(
                                width: 125,
                                child: DropdownButtonFormField<String>(
                                  value: _thoiGianChonPhanTich,
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: const Color(0xFFF8FAFC),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: MauSac.onSurfaceVariant,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: MauSac.borderSubtle,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: MauSac.borderSubtle,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: _danhSachThoiGian.map((time) {
                                    return DropdownMenuItem<String>(
                                      value: time,
                                      child: Text(
                                        time,
                                        style: GoogleFonts.manrope(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: MauSac.onSurface,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _thoiGianChonPhanTich = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (tongChi == 0)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Chưa có chi tiêu nào trong tháng',
                                  style: GoogleFonts.manrope(
                                    color: MauSac.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            )
                          else
                            Row(
                              children: [
                                // Donut Chart Placeholder (Stack of CircularProgressIndicators)
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: TweenAnimationBuilder<double>(
                                    key: ValueKey(_thoiGianChonPhanTich),
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 1500),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, animValue, child) {
                                      return Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          CircularProgressIndicator(
                                            value: 1.0,
                                            strokeWidth: 12,
                                            backgroundColor:
                                                MauSac.surfaceContainer,
                                            valueColor:
                                                const AlwaysStoppedAnimation<Color>(
                                                  MauSac.surfaceContainer,
                                                ),
                                          ),
                                          ...List.generate(
                                            top3.length + (khac > 0 ? 1 : 0),
                                            (index) {
                                              double accumulated = 0;
                                              for (int i = 0; i <= index; i++) {
                                                if (i < top3.length) {
                                                  accumulated += top3[i].value;
                                                } else {
                                                  accumulated += khac;
                                                }
                                              }
                                              final targetValue = accumulated / tongChi;
                                              final value = targetValue * animValue;
                                              final color = index < top3.length
                                                  ? top3[index].key.mauSac
                                                  : MauSac.outlineVariant;
                                              return CircularProgressIndicator(
                                                value: value,
                                                strokeWidth: 12,
                                                valueColor: AlwaysStoppedAnimation<Color>(color),
                                              );
                                            },
                                          ).reversed, // Reverse to draw larger circles first
                                          Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Tổng',
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: MauSac.onSurfaceVariant,
                                                  ),
                                                ),
                                                Text(
                                                  '${(100 * animValue).toInt()}%',
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: MauSac.onSurface,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // Legend
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...top3.map((e) {
                                        final percent =
                                            (e.value / tongChi * 100)
                                                .toStringAsFixed(0);
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        color: e.key.mauSac,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        e.key.ten,
                                                        style: GoogleFonts.manrope(
                                                          fontSize: 14,
                                                          color: MauSac
                                                              .onSurfaceVariant,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '$percent%',
                                                style: GoogleFonts.manrope(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: MauSac.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      if (khac > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: MauSac
                                                                .outlineVariant,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Khác',
                                                      style: GoogleFonts.manrope(
                                                        fontSize: 14,
                                                        color: MauSac
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '${(khac / tongChi * 100).toStringAsFixed(0)}%',
                                                style: GoogleFonts.manrope(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: MauSac.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ManHinhChiTietVi(danhSachVi: widget.danhSachVi),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MauSac.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: MauSac.borderSubtle.withValues(alpha: 0.4),
                    ),
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
                          Text(
                            'Tài khoản',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: MauSac.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...widget.danhSachVi.take(2).map((vi) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: vi.mauSac.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      vi.icon,
                                      color: vi.mauSac,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    vi.tenVi,
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: MauSac.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _dinhDangTien(vi.soDu),
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
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
              const SizedBox(height: 24),

              const SizedBox(height: 80), // bottom padding for FAB & Nav
            ],
          ),
        ),
      ),
    ),
    if (_isAiChatInitialized)
      Positioned(
        left: _showAiChat 
            ? _aiChatX 
            : (_aiChatX < MediaQuery.of(context).size.width / 2 ? 0.0 : MediaQuery.of(context).size.width - 24),
        top: _aiChatY,
        child: _showAiChat
            ? GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _aiChatX += details.delta.dx;
                    _aiChatY += details.delta.dy;

                    // Giới hạn để nút không bị kéo văng ra khỏi màn hình
                    final size = MediaQuery.of(context).size;
                    _aiChatX = _aiChatX.clamp(0.0, size.width - 64);
                    _aiChatY = _aiChatY.clamp(0.0, size.height - 160);
                  });
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FloatingActionButton(
                      heroTag: 'ai_chat_float',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const ManHinhTroLyAI()),
                        );
                      },
                      backgroundColor: MauSac.primary, // Nền xanh
                      foregroundColor: Colors.white,   // Icon trắng
                      elevation: 8,
                      child: const Icon(Icons.smart_toy, size: 28),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showAiChat = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: MauSac.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: MauSac.surface, width: 2),
                          ),
                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : GestureDetector(
                onTap: () {
                  setState(() {
                    _showAiChat = true;
                  });
                },
                child: Container(
                  width: 24,
                  height: 64,
                  decoration: BoxDecoration(
                    color: MauSac.primary,
                    borderRadius: _aiChatX < MediaQuery.of(context).size.width / 2
                        ? const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          )
                        : const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _aiChatX < MediaQuery.of(context).size.width / 2
                          ? Icons.chevron_right
                          : Icons.chevron_left,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
      ),
  ],
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
