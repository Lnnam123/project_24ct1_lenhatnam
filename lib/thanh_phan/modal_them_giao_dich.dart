import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

class ModalThemGiaoDich extends StatefulWidget {
  final List<ViTien> danhSachVi;
  final List<DanhMuc> danhSachDanhMuc;
  final Function(GiaoDich) onThemGiaoDich;
  final Function(GiaoDich)? onSuaGiaoDich;
  final Function(int)? onXoaGiaoDich;
  final GiaoDich? giaoDichCu;

  const ModalThemGiaoDich({
    super.key,
    required this.danhSachVi,
    required this.danhSachDanhMuc,
    required this.onThemGiaoDich,
    this.onSuaGiaoDich,
    this.onXoaGiaoDich,
    this.giaoDichCu,
  });

  @override
  State<ModalThemGiaoDich> createState() => _ModalThemGiaoDichState();
}

class _ModalThemGiaoDichState extends State<ModalThemGiaoDich> with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  late ViTien _viDangChon;
  late DanhMuc _danhMucDangChon;
  late DateTime _ngayChon;
  late LoaiGiaoDich _loaiDangChon;

  bool _isManualTab = true;

  // For AI pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    if (widget.giaoDichCu != null) {
      _ngayChon = widget.giaoDichCu!.ngay;
      _viDangChon = widget.danhSachVi.firstWhere((v) => v.id == widget.giaoDichCu!.viTien.id, orElse: () => widget.danhSachVi.first);
      _danhMucDangChon = widget.danhSachDanhMuc.firstWhere((d) => d.id == widget.giaoDichCu!.danhMuc.id, orElse: () => widget.danhSachDanhMuc.first);
      
      // Format balance
      String amountStr = widget.giaoDichCu!.soTien.toStringAsFixed(0);
      String formattedText = '';
      int count = 0;
      for (int i = amountStr.length - 1; i >= 0; i--) {
        formattedText = amountStr[i] + formattedText;
        count++;
        if (count % 3 == 0 && i != 0) {
          formattedText = ',$formattedText';
        }
      }
      _amountController.text = formattedText;
      _noteController.text = widget.giaoDichCu!.ghiChu ?? '';
      _loaiDangChon = widget.giaoDichCu!.loai;
    } else {
      _ngayChon = DateTime.now();
      _loaiDangChon = LoaiGiaoDich.chiTieu;
      _viDangChon = widget.danhSachVi.first;
      _danhMucDangChon = widget.danhSachDanhMuc.firstWhere((d) => d.loai == _loaiDangChon, orElse: () => widget.danhSachDanhMuc.first);
    }
    
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

    double availableBalance = _viDangChon.soDu;
    if (widget.giaoDichCu != null && widget.giaoDichCu!.viTien.id == _viDangChon.id && widget.giaoDichCu!.loai == LoaiGiaoDich.chiTieu) {
      availableBalance += widget.giaoDichCu!.soTien;
    }

    if (_danhMucDangChon.loai == LoaiGiaoDich.chiTieu && amount > availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số dư ví không đủ! Vui lòng chọn ví khác hoặc nhập số tiền nhỏ hơn.'),
          backgroundColor: MauSac.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final giaoDichMoi = GiaoDich(
      id: widget.giaoDichCu?.id ?? DateTime.now().millisecondsSinceEpoch,
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

    if (widget.giaoDichCu != null) {
      widget.onSuaGiaoDich?.call(giaoDichMoi);
    } else {
      widget.onThemGiaoDich(giaoDichMoi);
    }
    
    Navigator.of(context).pop();
  }

  void _moPhongQuetAI() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isManualTab = true; // Switch back to manual to show results
        _amountController.text = '250,000';
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

  Future<void> _chonNgay() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _ngayChon,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'CHỌN NGÀY',
      cancelText: 'HỦY',
      confirmText: 'CHỌN',
      fieldLabelText: 'Nhập ngày',
      fieldHintText: 'dd/mm/yyyy',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: MauSac.primary,
              onPrimary: Colors.white,
              onSurface: MauSac.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _ngayChon = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _ngayChon.hour,
          _ngayChon.minute,
          _ngayChon.second,
        );
      });
    }
  }

  Future<void> _chonGio() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return _BoChonGioDialog(
          initialDateTime: _ngayChon,
          onConfirmed: (newDateTime) {
            setState(() {
              _ngayChon = newDateTime;
            });
          },
        );
      },
    );
  }

  Widget _buildManualTab() {
    return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                
                // Amount
                Center(
                  child: Text(
                    'Số tiền',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
                      inputFormatters: [CurrencyInputFormatter()],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: MauSac.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: MauSac.surfaceContainerHighest,
                        ),
                        suffixText: 'đ',
                        suffixStyle: GoogleFonts.manrope(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: MauSac.onSurface,
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
                  'Danh mục',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MauSac.outline,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Toggle Type (Chi tiêu / Thu nhập)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: MauSac.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOutCubic,
                          alignment: _loaiDangChon == LoaiGiaoDich.chiTieu ? Alignment.centerLeft : Alignment.centerRight,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: MauSac.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _loaiDangChon = LoaiGiaoDich.chiTieu;
                                  _danhMucDangChon = widget.danhSachDanhMuc.firstWhere(
                                    (d) => d.loai == LoaiGiaoDich.chiTieu,
                                    orElse: () => widget.danhSachDanhMuc.first,
                                  );
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: Text(
                                    'Chi tiêu',
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _loaiDangChon == LoaiGiaoDich.chiTieu ? MauSac.primary : MauSac.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _loaiDangChon = LoaiGiaoDich.thuNhap;
                                  _danhMucDangChon = widget.danhSachDanhMuc.firstWhere(
                                    (d) => d.loai == LoaiGiaoDich.thuNhap,
                                    orElse: () => widget.danhSachDanhMuc.first,
                                  );
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: Text(
                                    'Thu nhập',
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _loaiDangChon == LoaiGiaoDich.thuNhap ? MauSac.primary : MauSac.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                Builder(
                  builder: (ctx) {
                    final categoriesFiltered = widget.danhSachDanhMuc
                        .where((d) => d.loai == _loaiDangChon)
                        .toList();

                    return SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoriesFiltered.length,
                        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          final cat = categoriesFiltered[i];
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
                    );
                  },
                ),
                const SizedBox(height: 32),

                const SizedBox(height: 24),

                // Wallet selection
                Text(
                  'Tài khoản',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MauSac.outline,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ViTien>(
                  initialValue: _viDangChon,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(16),
                  dropdownColor: const Color(0xFFF8FAFC),
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
                const SizedBox(height: 24),

                // Date & Time selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thời gian',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MauSac.outline,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _ngayChon = DateTime.now();
                        });
                      },
                      child: Text(
                        'Bây giờ',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: MauSac.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Ngày tháng năm
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: _chonNgay,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: MauSac.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 18, color: MauSac.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Ngày',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: MauSac.outlineVariant,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(_ngayChon),
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: MauSac.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: MauSac.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Giờ phút
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: _chonGio,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: MauSac.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 18, color: MauSac.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Giờ',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: MauSac.outlineVariant,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('HH:mm').format(_ngayChon),
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: MauSac.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: MauSac.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Note
                Text(
                  'Ghi chú (tùy chọn)',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

                const SizedBox(height: 48), // Padding before button
                
                // Fixed bottom button moved inside scroll view
                Container(
                  height: 56,
                  width: double.infinity,
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
                          widget.giaoDichCu != null ? 'Cập nhật' : 'Lưu giao dịch',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
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
          widget.giaoDichCu != null ? 'Sửa giao dịch' : 'Thêm giao dịch mới',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.giaoDichCu != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: MauSac.error),
              onPressed: () {
                if (widget.onXoaGiaoDich != null) {
                  widget.onXoaGiaoDich!(widget.giaoDichCu!.id!);
                  Navigator.of(context).pop();
                }
              },
            ),
        ],
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
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOutCubic,
                        alignment: _isManualTab ? Alignment.centerLeft : Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: MauSac.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
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
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Tính năng đang phát triển', style: GoogleFonts.manrope()),
                                  backgroundColor: MauSac.primary,
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ),
          
          // Content
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
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

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
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
        formattedText = ',$formattedText';
      }
    }

    int selectionIndexFromTheRight = newValue.text.length - newValue.selection.end;
    int offset = formattedText.length - selectionIndexFromTheRight;
    if (offset < 0) offset = 0;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

class _BoChonGioDialog extends StatefulWidget {
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onConfirmed;

  const _BoChonGioDialog({
    required this.initialDateTime,
    required this.onConfirmed,
  });

  @override
  State<_BoChonGioDialog> createState() => _BoChonGioDialogState();
}

class _BoChonGioDialogState extends State<_BoChonGioDialog> {
  late int selectedHour;
  late int selectedMinute;

  late final FixedExtentScrollController hourController;
  late final FixedExtentScrollController minuteController;

  late final TextEditingController hourInputCtrl;
  late final TextEditingController minuteInputCtrl;
  final FocusNode hourFocus = FocusNode();
  final FocusNode minuteFocus = FocusNode();

  bool isEditingHour = false;
  bool isEditingMinute = false;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialDateTime.hour;
    selectedMinute = widget.initialDateTime.minute;

    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);

    hourInputCtrl = TextEditingController(text: selectedHour.toString().padLeft(2, '0'));
    minuteInputCtrl = TextEditingController(text: selectedMinute.toString().padLeft(2, '0'));
  }

  @override
  void dispose() {
    hourFocus.dispose();
    minuteFocus.dispose();
    hourInputCtrl.dispose();
    minuteInputCtrl.dispose();
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  void batDauSuaGio() {
    minuteFocus.unfocus();
    if (isEditingMinute) {
      if (minuteInputCtrl.text.isNotEmpty) {
        final m = int.tryParse(minuteInputCtrl.text);
        if (m != null) {
          selectedMinute = m.clamp(0, 59);
          minuteController.jumpToItem(selectedMinute);
        }
      }
      minuteInputCtrl.text = selectedMinute.toString().padLeft(2, '0');
    }

    setState(() {
      isEditingHour = true;
      isEditingMinute = false;
      hourInputCtrl.text = '';
    });
    hourFocus.requestFocus();
  }

  void batDauSuaPhut() {
    hourFocus.unfocus();
    if (hourInputCtrl.text.isNotEmpty) {
      final h = int.tryParse(hourInputCtrl.text);
      if (h != null) {
        selectedHour = h.clamp(0, 23);
        hourController.jumpToItem(selectedHour);
      }
    }
    hourInputCtrl.text = selectedHour.toString().padLeft(2, '0');

    setState(() {
      isEditingMinute = true;
      isEditingHour = false;
      minuteInputCtrl.text = '';
    });
    minuteFocus.requestFocus();
  }

  void ketThucSua() {
    hourFocus.unfocus();
    minuteFocus.unfocus();

    if (hourInputCtrl.text.isNotEmpty) {
      final h = int.tryParse(hourInputCtrl.text);
      if (h != null) {
        selectedHour = h.clamp(0, 23);
        hourController.jumpToItem(selectedHour);
      }
    }
    hourInputCtrl.text = selectedHour.toString().padLeft(2, '0');

    if (minuteInputCtrl.text.isNotEmpty) {
      final m = int.tryParse(minuteInputCtrl.text);
      if (m != null) {
        selectedMinute = m.clamp(0, 59);
        minuteController.jumpToItem(selectedMinute);
      }
    }
    minuteInputCtrl.text = selectedMinute.toString().padLeft(2, '0');

    setState(() {
      isEditingHour = false;
      isEditingMinute = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = widget.initialDateTime.year == now.year &&
        widget.initialDateTime.month == now.month &&
        widget.initialDateTime.day == now.day;
    final dateFormatted = DateFormat('dd/MM/yyyy').format(widget.initialDateTime);
    final headerDate = isToday ? 'Hôm nay - $dateFormatted' : dateFormatted;

    return Dialog(
      backgroundColor: MauSac.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: MauSac.borderSubtle, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: ketThucSua,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: Ngày bên trái, Giờ có thể nhấn để nhập trực tiếp bên phải
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      headerDate,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: MauSac.outline,
                      ),
                    ),
                    InkWell(
                      onTap: batDauSuaGio,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 19,
                              color: MauSac.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: MauSac.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: MauSac.outline,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Con lăn chọn giờ và phút kèm ô nhập số trực tiếp tại chỗ
                SizedBox(
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Danh sách cuộn giờ và phút (background wheel)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Cột giờ (00 - 23)
                          SizedBox(
                            width: 54,
                            child: ListWheelScrollView.useDelegate(
                              controller: hourController,
                              itemExtent: 42,
                              perspective: 0.003,
                              physics: isEditingHour || isEditingMinute
                                  ? const NeverScrollableScrollPhysics()
                                  : const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                if (isEditingHour) return;
                                setState(() {
                                  selectedHour = index;
                                  hourInputCtrl.text = index.toString().padLeft(2, '0');
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 24,
                                builder: (context, index) {
                                  final isSelected = index == selectedHour;
                                  return Center(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        if (isSelected) {
                                          batDauSuaGio();
                                        } else {
                                          hourController.animateToItem(
                                            index,
                                            duration: const Duration(milliseconds: 200),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: isSelected && !isEditingHour
                                            ? BoxDecoration(
                                                color: MauSac.primaryContainer.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              )
                                            : null,
                                        child: Text(
                                          index.toString().padLeft(2, '0'),
                                          style: GoogleFonts.manrope(
                                            fontSize: isSelected ? 20 : 15,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected
                                                ? MauSac.primary
                                                : MauSac.outlineVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Dấu hai chấm ":"
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              ':',
                              style: GoogleFonts.manrope(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: MauSac.onSurface,
                              ),
                            ),
                          ),

                          // Cột phút (00 - 59)
                          SizedBox(
                            width: 54,
                            child: ListWheelScrollView.useDelegate(
                              controller: minuteController,
                              itemExtent: 42,
                              perspective: 0.003,
                              physics: isEditingHour || isEditingMinute
                                  ? const NeverScrollableScrollPhysics()
                                  : const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                if (isEditingMinute) return;
                                setState(() {
                                  selectedMinute = index;
                                  minuteInputCtrl.text = index.toString().padLeft(2, '0');
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 60,
                                builder: (context, index) {
                                  final isSelected = index == selectedMinute;
                                  return Center(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        if (isSelected) {
                                          batDauSuaPhut();
                                        } else {
                                          minuteController.animateToItem(
                                            index,
                                            duration: const Duration(milliseconds: 200),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: isSelected && !isEditingMinute
                                            ? BoxDecoration(
                                                color: MauSac.primaryContainer.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              )
                                            : null,
                                        child: Text(
                                          index.toString().padLeft(2, '0'),
                                          style: GoogleFonts.manrope(
                                            fontSize: isSelected ? 20 : 15,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected
                                                ? MauSac.primary
                                                : MauSac.outlineVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Hai cặp vạch kẻ ngang màu primary của theme
                      IgnorePointer(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Vạch giờ
                            SizedBox(
                              width: 54,
                              height: 42,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(height: 1.5, color: MauSac.primary),
                                  Container(height: 1.5, color: MauSac.primary),
                                ],
                              ),
                            ),
                            const SizedBox(width: 26),
                            // Vạch phút
                            SizedBox(
                              width: 54,
                              height: 42,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(height: 1.5, color: MauSac.primary),
                                  Container(height: 1.5, color: MauSac.primary),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Khung nhập số trực tiếp tại chỗ khi người dùng nhấn vào để gõ
                      if (isEditingHour || isEditingMinute)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Ô gõ giờ trực tiếp
                            SizedBox(
                              width: 54,
                              height: 38,
                              child: isEditingHour
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: MauSac.surface,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: MauSac.primaryContainer.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        alignment: Alignment.center,
                                        child: TextField(
                                        controller: hourInputCtrl,
                                        focusNode: hourFocus,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(2),
                                        ],
                                        style: GoogleFonts.manrope(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: MauSac.primary,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (val) {
                                          if (val.isEmpty) return;
                                          final h = int.tryParse(val);
                                          if (h != null) {
                                            final validH = h.clamp(0, 23);
                                            setState(() {
                                              selectedHour = validH;
                                            });
                                          }
                                          // Chỉ khi nhập đủ 2 số mới tự động chuyển qua phút
                                          if (val.length >= 2) {
                                            final h = int.tryParse(val);
                                            if (h != null) {
                                              final validH = h.clamp(0, 23);
                                              selectedHour = validH;
                                              hourInputCtrl.text = validH.toString().padLeft(2, '0');
                                              hourController.jumpToItem(validH);
                                            }
                                            batDauSuaPhut();
                                          }
                                        },
                                        onSubmitted: (_) {
                                          batDauSuaPhut();
                                        },
                                      ),
                                    ),
                                  )
                                  : const SizedBox(),
                            ),

                            const SizedBox(width: 26),

                            // Ô gõ phút trực tiếp
                            SizedBox(
                              width: 54,
                              height: 38,
                              child: isEditingMinute
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: MauSac.surface,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: MauSac.primaryContainer.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        alignment: Alignment.center,
                                        child: TextField(
                                        controller: minuteInputCtrl,
                                        focusNode: minuteFocus,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(2),
                                        ],
                                        style: GoogleFonts.manrope(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: MauSac.primary,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (val) {
                                          if (val.isEmpty) return;
                                          final m = int.tryParse(val);
                                          if (m != null) {
                                            final validM = m.clamp(0, 59);
                                            setState(() {
                                              selectedMinute = validM;
                                            });
                                          }
                                          // Khi nhập đủ 2 số phút thì hoàn tất
                                          if (val.length >= 2) {
                                            final m = int.tryParse(val);
                                            if (m != null) {
                                              final validM = m.clamp(0, 59);
                                              selectedMinute = validM;
                                              minuteInputCtrl.text = validM.toString().padLeft(2, '0');
                                              minuteController.jumpToItem(validM);
                                            }
                                            ketThucSua();
                                          }
                                        },
                                        onSubmitted: (_) => ketThucSua(),
                                      ),
                                    ),
                                  )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Hàng nút: Giờ hiện tại (trái), Đóng & Xác nhận (phải)
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        ketThucSua();
                        final current = DateTime.now();
                        setState(() {
                          selectedHour = current.hour;
                          selectedMinute = current.minute;
                          hourInputCtrl.text = current.hour.toString().padLeft(2, '0');
                          minuteInputCtrl.text = current.minute.toString().padLeft(2, '0');
                        });
                        hourController.animateToItem(
                          current.hour,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        minuteController.animateToItem(
                          current.minute,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text(
                          'Giờ hiện tại',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MauSac.primary,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Nút Đóng
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MauSac.onSurfaceVariant,
                        side: const BorderSide(color: MauSac.borderSubtle, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'Đóng',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Nút Xác nhận
                    ElevatedButton(
                      onPressed: () {
                        final h = int.tryParse(hourInputCtrl.text) ?? selectedHour;
                        final m = int.tryParse(minuteInputCtrl.text) ?? selectedMinute;
                        final finalH = h.clamp(0, 23);
                        final finalM = m.clamp(0, 59);

                        final result = DateTime(
                          widget.initialDateTime.year,
                          widget.initialDateTime.month,
                          widget.initialDateTime.day,
                          finalH,
                          finalM,
                        );
                        widget.onConfirmed(result);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MauSac.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'Xác nhận',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

