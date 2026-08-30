import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

class ModalThemGiaoDich extends StatefulWidget {
  final List<ViTien> danhSachVi;
  final List<DanhMuc> danhSachDanhMuc;
  final Function(GiaoDich) onThemGiaoDich;

  const ModalThemGiaoDich({
    super.key,
    required this.danhSachVi,
    required this.danhSachDanhMuc,
    required this.onThemGiaoDich,
  });

  @override
  State<ModalThemGiaoDich> createState() => _ModalThemGiaoDichState();
}

class _ModalThemGiaoDichState extends State<ModalThemGiaoDich> with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  late ViTien _viDangChon;
  late DanhMuc _danhMucDangChon;
  final DateTime _ngayChon = DateTime.now();

  bool _isManualTab = true;

  // For AI pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _viDangChon = widget.danhSachVi.first;
    _danhMucDangChon = widget.danhSachDanhMuc.first;
    _pageController = PageController(initialPage: 0);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _luuGiaoDich() {
    final amountText = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('đ', '')
        .trim();
    final amount = double.tryParse(amountText);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    final giaoDichMoi = GiaoDich(
      id: DateTime.now().millisecondsSinceEpoch,
      tieuDe: _noteController.text.trim().isEmpty
          ? _danhMucDangChon.ten
          : _noteController.text.trim(),
      soTien: amount,
      loai: _danhMucDangChon.loai,
      danhMuc: _danhMucDangChon,
      viTien: _viDangChon,
      ngay: _ngayChon,
      ghiChu: _noteController.text.trim(),
    );

    widget.onThemGiaoDich(giaoDichMoi);
    Navigator.of(context).pop();
  }

  void _moPhongQuetAI() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isManualTab = true; // Switch back to manual to show results
        _amountController.text = '250000';
        _noteController.text = 'Siêu thị WinMart';
        _danhMucDangChon = widget.danhSachDanhMuc.firstWhere(
          (c) => c.ten.contains('Tạp hóa') || c.ten.contains('Ăn uống'),
          orElse: () => widget.danhSachDanhMuc.first,
        );
      });
      _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã bóc tách dữ liệu từ giọng nói/hóa đơn thành công!',
            style: GoogleFonts.manrope(),
          ),
          backgroundColor: MauSac.success,
        ),
      );
    });
  }

  Widget _buildManualTab() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                
                // Amount
                Center(
                  child: Text(
                    'SỐ TIỀN',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: MauSac.outline,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: MauSac.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: '0đ',
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: MauSac.surfaceContainerHighest,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Category
                Text(
                  'DANH MỤC',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: MauSac.outline,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.danhSachDanhMuc.length,
                    separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final cat = widget.danhSachDanhMuc[i];
                      final isSelected = _danhMucDangChon.id == cat.id;
                      
                      return GestureDetector(
                        onTap: () => setState(() => _danhMucDangChon = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? MauSac.primaryContainer.withValues(alpha: 0.2) : MauSac.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : MauSac.borderSubtle,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                cat.icon,
                                size: 18,
                                color: isSelected ? MauSac.primary : MauSac.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat.ten,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? MauSac.primary : MauSac.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Note
                Text(
                  'GHI CHÚ (TÙY CHỌN)',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: MauSac.outline,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: MauSac.borderSubtle),
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 3,
                    style: GoogleFonts.manrope(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Khoản chi này dùng để làm gì?',
                      hintStyle: GoogleFonts.manrope(fontSize: 14, color: MauSac.outlineVariant),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 48), // align icon to top
                        child: Icon(Icons.edit_note, color: MauSac.outlineVariant),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Wallet selection (subtle addition since it's required for logic)
                Text(
                  'TÀI KHOẢN',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: MauSac.outline,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ViTien>(
                  initialValue: _viDangChon,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: MauSac.onSurfaceVariant),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: MauSac.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: MauSac.borderSubtle),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: widget.danhSachVi.map((w) {
                    return DropdownMenuItem<ViTien>(
                      value: w,
                      child: Row(
                        children: [
                          Icon(w.icon, color: w.mauSac, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            '${w.tenVi} (${w.soDu.toStringAsFixed(0)} đ)',
                            style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _viDangChon = val);
                  },
                ),

                const SizedBox(height: 120), // Bottom padding for FAB
              ],
            ),
          ),
        ),
        
        // Fixed bottom button
        Positioned(
          left: 20,
          right: 20,
          bottom: 20, // keep it slightly above keyboard if possible, or just fixed at bottom
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: MauSac.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MauSac.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _luuGiaoDich,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Lưu giao dịch',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAITab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: GestureDetector(
                  onTap: _moPhongQuetAI,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MauSac.secondary,
                      boxShadow: [
                        BoxShadow(
                          color: MauSac.secondary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Đang nghe...',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MauSac.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"Tôi đã tiêu 300.000 đ cho bữa trưa..."',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: MauSac.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(child: Divider(color: MauSac.borderSubtle)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'HOẶC',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MauSac.outline,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: MauSac.borderSubtle)),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: const Color(0xFFF8FAFC),
                  foregroundColor: MauSac.onSurface,
                  side: const BorderSide(color: MauSac.borderSubtle),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _moPhongQuetAI,
                icon: const Icon(Icons.document_scanner, color: MauSac.secondary),
                label: Text(
                  'Quét biên lai',
                  style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.surface,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MauSac.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Giao dịch mới',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: MauSac.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isManualTab ? MauSac.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isManualTab
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Thủ công',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _isManualTab ? MauSac.primary : MauSac.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isManualTab ? MauSac.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: !_isManualTab
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Trợ lý AI',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: !_isManualTab ? MauSac.primary : MauSac.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _isManualTab = index == 0);
              },
              children: [
                _buildManualTab(),
                _buildAITab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

