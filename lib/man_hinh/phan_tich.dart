import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

class ManHinhPhanTich extends StatefulWidget {
  final List<GiaoDich> danhSachGiaoDich;

  const ManHinhPhanTich({super.key, required this.danhSachGiaoDich});

  @override
  State<ManHinhPhanTich> createState() => _ManHinhPhanTichState();
}

class _ManHinhPhanTichState extends State<ManHinhPhanTich> {
  String _kyHienTai = 'Hàng tháng';

  String _dinhDangTien(double soTien) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(soTien);
  }

  // Filter transactions based on current period
  List<GiaoDich> get _giaoDichTrongKy {
    final now = DateTime.now();
    return widget.danhSachGiaoDich.where((tx) {
      if (tx.loai != LoaiGiaoDich.chiTieu) return false;
      
      if (_kyHienTai == 'Hàng tuần') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return tx.ngay.isAfter(startOfWeek) || tx.ngay.isAtSameMomentAs(startOfWeek);
      } else if (_kyHienTai == 'Hàng tháng') {
        return tx.ngay.month == now.month && tx.ngay.year == now.year;
      } else {
        return tx.ngay.year == now.year;
      }
    }).toList();
  }

  // Calculate chart data points
  List<Map<String, dynamic>> _getChartData(List<GiaoDich> txs) {
    if (_kyHienTai == 'Hàng tuần') {
      final data = List.generate(7, (i) => {'label': 'T${i+2 == 8 ? "CN" : i+2}', 'value': 0.0});
      for (var tx in txs) {
        // weekday 1 = Monday, 7 = Sunday
        data[tx.ngay.weekday - 1]['value'] = (data[tx.ngay.weekday - 1]['value'] as double) + tx.soTien;
      }
      return data;
    } else if (_kyHienTai == 'Hàng tháng') {
      final data = [
        {'label': 'Tuần 1', 'value': 0.0},
        {'label': 'Tuần 2', 'value': 0.0},
        {'label': 'Tuần 3', 'value': 0.0},
        {'label': 'Tuần 4', 'value': 0.0},
      ];
      for (var tx in txs) {
        int week = (tx.ngay.day - 1) ~/ 7;
        if (week > 3) week = 3;
        data[week]['value'] = (data[week]['value'] as double) + tx.soTien;
      }
      return data;
    } else {
      final data = List.generate(12, (i) => {'label': 'T${i+1}', 'value': 0.0});
      for (var tx in txs) {
        data[tx.ngay.month - 1]['value'] = (data[tx.ngay.month - 1]['value'] as double) + tx.soTien;
      }
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    final giaoDich = _giaoDichTrongKy;
    final tongChiTieu = giaoDich.fold(0.0, (sum, tx) => sum + tx.soTien);
    
    // Top Categories
    final Map<int, double> tongTheoDanhMuc = {};
    final Map<int, DanhMuc> doiTuongDanhMuc = {};
    for (var tx in giaoDich) {
      tongTheoDanhMuc[tx.danhMuc.id] = (tongTheoDanhMuc[tx.danhMuc.id] ?? 0) + tx.soTien;
      doiTuongDanhMuc[tx.danhMuc.id] = tx.danhMuc;
    }
    
    final danhMucSorted = tongTheoDanhMuc.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final danhMucChinh = danhMucSorted.take(4).toList();

    // Chart Data
    final chartData = _getChartData(giaoDich);
    final maxChartValue = chartData.map((e) => e['value'] as double).fold(0.0, (a, b) => a > b ? a : b);

    // Recent Transactions (Limit to 5)
    final recentTxs = List<GiaoDich>.from(widget.danhSachGiaoDich)
      ..sort((a, b) => b.ngay.compareTo(a.ngay));
    final topRecent = recentTxs.take(5).toList();

    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Phân tích',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: MauSac.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: ['Hàng tuần', 'Hàng tháng', 'Hàng năm'].map((period) {
                    final isSelected = period == _kyHienTai;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _kyHienTai = period),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? MauSac.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: isSelected
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            period,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? MauSac.onSurface : MauSac.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // Total Expense Card & Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: MauSac.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MauSac.borderSubtle),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng chi tiêu',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: MauSac.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _dinhDangTien(tongChiTieu),
                      style: GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: MauSac.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _kyHienTai == 'Hàng tháng' ? 'Tháng ${DateTime.now().month}' : 
                          _kyHienTai == 'Hàng tuần' ? 'Tuần này' : 'Năm ${DateTime.now().year}',
                          style: GoogleFonts.manrope(fontSize: 14, color: MauSac.onSurfaceVariant),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: MauSac.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.trending_up, size: 14, color: MauSac.success),
                              const SizedBox(width: 4),
                              Text(
                                '+5%', // Dummy trend
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: MauSac.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Chart
                    SizedBox(
                      height: 180,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: chartData.map((data) {
                          final value = data['value'] as double;
                          final label = data['label'] as String;
                          final heightRatio = maxChartValue == 0 ? 0.0 : (value / maxChartValue);
                          
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: LayoutBuilder(
                                        builder: (ctx, constraints) {
                                          return Tooltip(
                                            message: _dinhDangTien(value),
                                            child: Container(
                                              width: double.infinity,
                                              height: constraints.maxHeight * heightRatio,
                                              decoration: BoxDecoration(
                                                color: heightRatio == 1.0 ? MauSac.primary : MauSac.primary.withValues(alpha: 0.4),
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                              ),
                                            ),
                                          );
                                        }
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    label,
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: MauSac.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Top Categories
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Danh mục chi tiêu chính',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: MauSac.onSurface,
                ),
              ),
            ),
            if (danhMucChinh.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text('Chưa có chi tiêu', style: GoogleFonts.manrope()),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: danhMucChinh.map((entry) {
                    final cat = doiTuongDanhMuc[entry.key]!;
                    final amount = entry.value;
                    final percentage = tongChiTieu > 0 ? (amount / tongChiTieu * 100) : 0.0;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MauSac.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: cat.mauSac.withValues(alpha: 0.15),
                            child: Icon(cat.icon, color: cat.mauSac, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.ten,
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: MauSac.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    minHeight: 8,
                                    backgroundColor: MauSac.surfaceContainerHigh,
                                    valueColor: AlwaysStoppedAnimation<Color>(cat.mauSac),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            _dinhDangTien(amount),
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: MauSac.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              
            // Recent Transactions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Giao dịch gần đây',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: MauSac.onSurface,
                    ),
                  ),
                  Text(
                    'Xem tất cả',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: MauSac.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: topRecent.map((tx) {
                  final isExpense = tx.loai == LoaiGiaoDich.chiTieu;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: MauSac.borderSubtle)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: MauSac.surfaceContainerHigh,
                          child: Icon(tx.danhMuc.icon, color: MauSac.onSurfaceVariant, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.tieuDe,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: MauSac.onSurface,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM, HH:mm').format(tx.ngay),
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: MauSac.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isExpense ? '-' : '+'}${_dinhDangTien(tx.soTien)}',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isExpense ? MauSac.onSurface : MauSac.success,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

