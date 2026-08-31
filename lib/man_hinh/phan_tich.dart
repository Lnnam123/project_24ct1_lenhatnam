import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';
import '../dich_vu/time_service.dart';
import 'chi_tiet_giao_dich.dart';
import '../thanh_phan/skeleton_loading.dart';

class ManHinhPhanTich extends StatefulWidget {
  final List<GiaoDich> danhSachGiaoDich;
  final VoidCallback onTapThongBao;
  final bool coThongBaoChuaDoc;
  final Future<void> Function() onRefresh;
  final Function(GiaoDich)? moSuaGiaoDich;

  const ManHinhPhanTich({
    super.key, 
    required this.danhSachGiaoDich, 
    required this.onTapThongBao,
    required this.coThongBaoChuaDoc, 
    required this.onRefresh,
    this.moSuaGiaoDich
  });

  @override
  State<ManHinhPhanTich> createState() => _ManHinhPhanTichState();
}

class _ManHinhPhanTichState extends State<ManHinhPhanTich> {
  DateTime _homNay = DateTime.now();
  bool _isLoadingTime = true;
  
  // Biến cho Lịch (Calendar)
  late DateTime _kyDangXem;
  late PageController _pageController;
  int _currentIndex = 1; // 0: Tuần, 1: Tháng, 2: Năm
  int _slideDirection = 1;

  final List<String> _danhSachKy = ['Hàng tuần', 'Hàng tháng', 'Hàng năm'];

  @override
  void initState() {
    super.initState();
    _kyDangXem = _homNay;
    _pageController = PageController(initialPage: _currentIndex);
    _taiThoiGianThuc();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _taiThoiGianThuc() async {
    final now = await TimeService.getCurrentTime();
    if (mounted) {
      setState(() {
        _homNay = now;
        _kyDangXem = _homNay;
        _isLoadingTime = false;
      });
    }
  }

  String _dinhDangTien(double soTien) {
    if (soTien >= 1000000) {
      return '${(soTien / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    } else if (soTien >= 1000) {
      return '${(soTien / 1000).toStringAsFixed(0)}k';
    }
    return soTien.toStringAsFixed(0);
  }

  String _dinhDangTienDayDu(double soTien) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(soTien);
  }

  void _thayDoiKy(int delta) {
    setState(() {
      _slideDirection = delta;
      final kyHienTai = _danhSachKy[_currentIndex];
      if (kyHienTai == 'Hàng tuần') {
        _kyDangXem = _kyDangXem.add(Duration(days: 7 * delta));
      } else if (kyHienTai == 'Hàng tháng') {
        _kyDangXem = DateTime(_kyDangXem.year, _kyDangXem.month + delta, 1);
      } else {
        _kyDangXem = DateTime(_kyDangXem.year + delta, _kyDangXem.month, 1);
      }
    });
  }

  List<GiaoDich> _layGiaoDichTrongKy(String kyHienTai) {
    if (kyHienTai == 'Hàng tuần') {
      final today = DateTime(_kyDangXem.year, _kyDangXem.month, _kyDangXem.day);
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));
      return widget.danhSachGiaoDich.where((tx) => 
        (tx.ngay.isAfter(startOfWeek) || tx.ngay.isAtSameMomentAs(startOfWeek)) && 
        tx.ngay.isBefore(endOfWeek)
      ).toList();
    } else if (kyHienTai == 'Hàng tháng') {
      return widget.danhSachGiaoDich.where((tx) => 
        tx.ngay.year == _kyDangXem.year && tx.ngay.month == _kyDangXem.month
      ).toList();
    } else {
      return widget.danhSachGiaoDich.where((tx) => 
        tx.ngay.year == _kyDangXem.year
      ).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingTime) {
      return const PhanTichSkeleton();
    }

    return Scaffold(
      backgroundColor: MauSac.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _danhSachKy.length,
                itemBuilder: (context, index) {
                  final kyHienTai = _danhSachKy[index];
                  return _buildPageContent(kyHienTai);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildPageContent(String kyHienTai) {
    final giaoDich = _layGiaoDichTrongKy(kyHienTai);
    final tongChiTieu = giaoDich
        .where((tx) => tx.loai == LoaiGiaoDich.chiTieu)
        .fold(0.0, (sum, tx) => sum + tx.soTien);
    final tongThuNhap = giaoDich
        .where((tx) => tx.loai == LoaiGiaoDich.thuNhap)
        .fold(0.0, (sum, tx) => sum + tx.soTien);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildSummaryCard(kyHienTai, tongChiTieu, tongThuNhap, giaoDich),
            if (kyHienTai != 'Hàng năm') _buildCalendarSection(kyHienTai, giaoDich),
            _buildTopCategories(giaoDich),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              'Phân tích',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MauSac.onSurface,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
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
              onPressed: widget.onTapThongBao,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: MauSac.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: List.generate(_danhSachKy.length, (index) {
            final ky = _danhSachKy[index];
            final isSelected = _currentIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index, 
                    duration: const Duration(milliseconds: 300), 
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? MauSac.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ky,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? MauSac.onSurface : MauSac.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String kyHienTai, double tongChiTieu, double tongThuNhap, List<GiaoDich> giaoDich) {
    double chenhLechThuChi = tongThuNhap - tongChiTieu;
    bool isPositive = chenhLechThuChi >= 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: MauSac.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MauSac.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng thu nhập',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: MauSac.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dinhDangTienDayDu(tongThuNhap),
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: MauSac.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng chi tiêu',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: MauSac.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dinhDangTienDayDu(tongChiTieu),
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: MauSac.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chênh lệch (Thu - Chi)',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: MauSac.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dinhDangTienDayDu(chenhLechThuChi.abs()),
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? MauSac.success : MauSac.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Legend
            Row(
              children: [
                _buildLegendItem(MauSac.success, 'Thu nhập'),
                const SizedBox(width: 16),
                _buildLegendItem(MauSac.primary, 'Chi tiêu'),
              ],
            ),
            
            const SizedBox(height: 24),
            // Bar Chart
            SizedBox(
              height: 180,
              child: Builder(
                builder: (context) {
                  List<Map<String, dynamic>> chartData = [];
                    
                    if (kyHienTai == 'Hàng tuần') {
                      final startOfWeek = _kyDangXem.subtract(Duration(days: _kyDangXem.weekday - 1));
                      for (int i = 0; i < 7; i++) {
                        final date = startOfWeek.add(Duration(days: i));
                        double chi = 0;
                        double thu = 0;
                        List<GiaoDich> txs = [];
                        for (var tx in widget.danhSachGiaoDich) {
                           if (tx.ngay.year == date.year && tx.ngay.month == date.month && tx.ngay.day == date.day) {
                             if (tx.loai == LoaiGiaoDich.chiTieu) chi += tx.soTien;
                             if (tx.loai == LoaiGiaoDich.thuNhap) thu += tx.soTien;
                             txs.add(tx);
                           }
                        }
                        chartData.add({'label': ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][i], 'expense': chi, 'income': thu, 'txs': txs});
                      }
                    } else if (kyHienTai == 'Hàng tháng') {
                      final daysInMonth = DateTime(_kyDangXem.year, _kyDangXem.month + 1, 0).day;
                      int weeks = (daysInMonth / 7).ceil();
                      for (int i = 0; i < weeks; i++) {
                        chartData.add({'label': 'Tuần ${i+1}', 'expense': 0.0, 'income': 0.0, 'txs': <GiaoDich>[]});
                      }
                      for (var tx in giaoDich) {
                        int week = (tx.ngay.day - 1) ~/ 7;
                        if (week >= weeks) week = weeks - 1;
                        if (tx.loai == LoaiGiaoDich.chiTieu) chartData[week]['expense'] += tx.soTien;
                        if (tx.loai == LoaiGiaoDich.thuNhap) chartData[week]['income'] += tx.soTien;
                        chartData[week]['txs'].add(tx);
                      }
                    } else {
                      for (int i = 0; i < 12; i++) {
                        chartData.add({'label': 'T${i+1}', 'expense': 0.0, 'income': 0.0, 'txs': <GiaoDich>[]});
                      }
                      for (var tx in giaoDich) {
                        if (tx.loai == LoaiGiaoDich.chiTieu) chartData[tx.ngay.month - 1]['expense'] += tx.soTien;
                        if (tx.loai == LoaiGiaoDich.thuNhap) chartData[tx.ngay.month - 1]['income'] += tx.soTien;
                        chartData[tx.ngay.month - 1]['txs'].add(tx);
                      }
                    }

                    double maxAmount = 1;
                    for (var d in chartData) {
                      final total = d['expense'] + d['income'];
                      if (total > maxAmount) maxAmount = total;
                    }

                    double barWidth = 16;
                    if (kyHienTai == 'Hàng tháng') barWidth = 24;
                    if (kyHienTai == 'Hàng năm') barWidth = 10;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: chartData.map((d) {
                        double expensePercent = d['expense'] / (maxAmount * 1.2);
                        double incomePercent = d['income'] / (maxAmount * 1.2);
                        
                        if (expensePercent > 1) expensePercent = 1;
                        if (incomePercent > 1) incomePercent = 1;
                        
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManHinhChiTietGiaoDich(
                                    tieuDe: d['label'],
                                    danhSach: d['txs'],
                                  ),
                                ),
                              );
                            },
                            child: _buildChartBar(d['label'], expensePercent, incomePercent, d['expense'], d['income'], barWidth),
                          ),
                        );
                      }).toList(),
                    );
                  }
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w500, color: MauSac.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildChartBar(String label, double expensePercent, double incomePercent, double expenseAmount, double incomeAmount, double barWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Solid stacked bar (Income on top, Expense on bottom)
                Tooltip(
                  message: 'Thu: ${_dinhDangTienDayDu(incomeAmount)}\nChi: ${_dinhDangTienDayDu(expenseAmount)}',
                  triggerMode: TooltipTriggerMode.tap,
                  preferBelow: false,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: MauSac.onSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  textStyle: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: MauSac.surface,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuart,
                    width: barWidth,
                    height: 180 * (expensePercent + incomePercent),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutQuart,
                          width: barWidth,
                          height: 180 * incomePercent,
                          decoration: BoxDecoration(
                            color: MauSac.success,
                            borderRadius: BorderRadius.vertical(
                              top: const Radius.circular(6),
                              bottom: expensePercent == 0 ? const Radius.circular(6) : Radius.zero,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutQuart,
                          width: barWidth,
                          height: 180 * expensePercent,
                          decoration: BoxDecoration(
                            color: MauSac.primary,
                            borderRadius: BorderRadius.vertical(
                              top: incomePercent == 0 ? const Radius.circular(6) : Radius.zero,
                              bottom: const Radius.circular(6)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
      );
  }

  Widget _buildCalendarSection(String kyHienTai, List<GiaoDich> giaoDich) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MauSac.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  kyHienTai == 'Hàng tuần' 
                      ? 'Tuần này (${_kyDangXem.month}/${_kyDangXem.year})'
                      : 'Tháng ${_kyDangXem.month}, ${_kyDangXem.year}',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MauSac.onSurface,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: MauSac.onSurfaceVariant),
                      onPressed: () => _thayDoiKy(-1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: MauSac.onSurfaceVariant),
                      onPressed: () => _thayDoiKy(1),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                final currentKey = 'cal_${kyHienTai}_${_kyDangXem.toIso8601String()}';
                final isIncoming = child.key == ValueKey<String>(currentKey);
                
                final offsetTween = isIncoming
                    ? Tween<Offset>(begin: Offset(_slideDirection.toDouble(), 0.0), end: Offset.zero)
                    : Tween<Offset>(begin: Offset(-_slideDirection.toDouble(), 0.0), end: Offset.zero);

                return SlideTransition(
                  position: offsetTween.animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                key: ValueKey<String>('cal_${kyHienTai}_${_kyDangXem.toIso8601String()}'),
                child: kyHienTai == 'Hàng tuần' ? _buildWeeklyCalendar() : _buildMonthlyCalendar(giaoDich),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    final startOfWeek = _kyDangXem.subtract(Duration(days: _kyDangXem.weekday - 1));
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (index) {
          final date = startOfWeek.add(Duration(days: index));
          final isToday = date.year == _homNay.year && date.month == _homNay.month && date.day == _homNay.day;
          final weekday = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][index];
          
          return GestureDetector(
            onTap: () {
              final txs = widget.danhSachGiaoDich.where((tx) => 
                tx.ngay.year == date.year && tx.ngay.month == date.month && tx.ngay.day == date.day
              ).toList();
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManHinhChiTietGiaoDich(
                    tieuDe: 'Ngày ${date.day}/${date.month}/${date.year}',
                    danhSach: txs,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: isToday ? MauSac.primary : MauSac.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isToday ? [BoxShadow(color: MauSac.primary.withValues(alpha: 0.3), blurRadius: 4)] : [],
              ),
              child: Column(
                children: [
                  Text(
                    weekday,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: isToday ? Colors.white.withValues(alpha: 0.8) : MauSac.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.white : MauSac.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthlyCalendar(List<GiaoDich> giaoDich) {
    final daysInMonth = DateTime(_kyDangXem.year, _kyDangXem.month + 1, 0).day;
    final firstDayWeekday = DateTime(_kyDangXem.year, _kyDangXem.month, 1).weekday;
    
    final weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    
    final Map<int, Map<String, double>> tongTheoNgay = {};
    for (var tx in giaoDich) {
      final day = tx.ngay.day;
      tongTheoNgay.putIfAbsent(day, () => {'INCOME': 0.0, 'EXPENSE': 0.0});
      if (tx.loai == LoaiGiaoDich.thuNhap) {
        tongTheoNgay[day]!['INCOME'] = tongTheoNgay[day]!['INCOME']! + tx.soTien;
      } else {
        tongTheoNgay[day]!['EXPENSE'] = tongTheoNgay[day]!['EXPENSE']! + tx.soTien;
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays.map((d) => SizedBox(
            width: 40, 
            child: Text(d, textAlign: TextAlign.center, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w500, color: MauSac.onSurfaceVariant))
          )).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 4,
            childAspectRatio: 0.6,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final dayOffset = index - (firstDayWeekday - 1);
            if (dayOffset < 0 || dayOffset >= daysInMonth) {
              return const SizedBox.shrink();
            }
            
            final day = dayOffset + 1;
            final isToday = _homNay.year == _kyDangXem.year && 
                            _homNay.month == _kyDangXem.month && 
                            _homNay.day == day;
            
            final data = tongTheoNgay[day];
            final thu = data?['INCOME'] ?? 0;
            final chi = data?['EXPENSE'] ?? 0;

            return GestureDetector(
              onTap: () {
                final txs = widget.danhSachGiaoDich.where((tx) => 
                  tx.ngay.year == _kyDangXem.year && tx.ngay.month == _kyDangXem.month && tx.ngay.day == day
                ).toList();
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManHinhChiTietGiaoDich(
                      tieuDe: 'Ngày $day/${_kyDangXem.month}/${_kyDangXem.year}',
                      danhSach: txs,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isToday ? MauSac.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isToday ? Colors.white : MauSac.onSurfaceVariant,
                      ),
                    ),
                    if (thu > 0 || chi > 0)
                      Column(
                        children: [
                          if (thu > 0)
                            Text(
                              '+${_dinhDangTien(thu)}',
                              style: GoogleFonts.manrope(fontSize: 10, color: isToday ? Colors.white : MauSac.success),
                            ),
                          if (chi > 0)
                            Text(
                              '-${_dinhDangTien(chi)}',
                              style: GoogleFonts.manrope(fontSize: 10, color: isToday ? Colors.red.shade100 : MauSac.error),
                            ),
                        ],
                      )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopCategories(List<GiaoDich> giaoDichTrongKy) {
    final Map<int, double> tongTheoDanhMuc = {};
    final Map<int, DanhMuc> doiTuongDanhMuc = {};
    
    for (var tx in giaoDichTrongKy.where((tx) => tx.loai == LoaiGiaoDich.chiTieu)) {
      tongTheoDanhMuc[tx.danhMuc.id] = (tongTheoDanhMuc[tx.danhMuc.id] ?? 0) + tx.soTien;
      doiTuongDanhMuc[tx.danhMuc.id] = tx.danhMuc;
    }
    
    final danhMucSorted = tongTheoDanhMuc.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    final top3 = danhMucSorted.take(3).toList();
    final tongChi = top3.fold(0.0, (sum, e) => sum + e.value);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh mục chi tiêu chính',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MauSac.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (top3.isEmpty)
            Center(
              child: Text(
                'Không có dữ liệu chi tiêu',
                style: GoogleFonts.manrope(color: MauSac.onSurfaceVariant),
              ),
            )
          else
            ...top3.map((entry) {
              final dm = doiTuongDanhMuc[entry.key]!;
              final percent = tongChi > 0 ? entry.value / tongChi : 0.0;
              return GestureDetector(
                onTap: () {
                  final txs = giaoDichTrongKy.where((tx) => tx.danhMuc.id == entry.key).toList();
                  String titleSuffix = '';
                  final String kyHienTai = _danhSachKy[_currentIndex];
                  if (kyHienTai == 'Hàng tuần') {
                    titleSuffix = '(Tuần này)';
                  } else if (kyHienTai == 'Hàng tháng') {
                    titleSuffix = '(Tháng ${_kyDangXem.month}, ${_kyDangXem.year})';
                  } else {
                    titleSuffix = '(Năm ${_kyDangXem.year})';
                  }
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManHinhChiTietGiaoDich(
                        tieuDe: '${dm.ten} $titleSuffix',
                        danhSach: txs,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MauSac.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: dm.mauSac.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(dm.icon, color: dm.mauSac),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dm.ten,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w500,
                                color: MauSac.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: percent,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                              backgroundColor: MauSac.surfaceContainerHigh,
                              valueColor: AlwaysStoppedAnimation<Color>(dm.mauSac),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _dinhDangTienDayDu(entry.value),
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          color: MauSac.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
