import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

class ModalQuanLyViTien extends StatefulWidget {
  final ViTien? viTienCu; // Thêm hoặc sửa
  final Function(ViTien)? onThemViTien;
  final Function(ViTien)? onCapNhatViTien;
  final Function(int)? onXoaViTien;

  const ModalQuanLyViTien({
    super.key,
    this.viTienCu,
    this.onThemViTien,
    this.onCapNhatViTien,
    this.onXoaViTien,
  });

  @override
  State<ModalQuanLyViTien> createState() => _ModalQuanLyViTienState();
}

class _ModalQuanLyViTienState extends State<ModalQuanLyViTien> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _loaiViDangChon = 'CASH';
  IconData _iconDangChon = Icons.account_balance_wallet;
  Color _mauDangChon = const Color(0xFF10B981); // Default Green

  final List<String> _loaiViOptions = ['CASH', 'BANK', 'CREDIT'];
  
  final List<IconData> _iconOptions = [
    Icons.account_balance_wallet,
    Icons.credit_card,
    Icons.savings,
    Icons.account_balance,
  ];

  final List<Color> _mauOptions = [
    const Color(0xFF10B981), // Green
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFF59E0B), // Orange
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEF4444), // Red
  ];

  @override
  void initState() {
    super.initState();
    if (widget.viTienCu != null) {
      _nameController.text = widget.viTienCu!.tenVi;
      
      // Format number with commas
      String balanceStr = widget.viTienCu!.soDu.toStringAsFixed(0);
      String formattedText = '';
      int count = 0;
      for (int i = balanceStr.length - 1; i >= 0; i--) {
        formattedText = balanceStr[i] + formattedText;
        count++;
        if (count % 3 == 0 && i != 0) {
          formattedText = ',' + formattedText;
        }
      }
      _balanceController.text = formattedText;
      
      _loaiViDangChon = widget.viTienCu!.loaiVi;
      _iconDangChon = widget.viTienCu!.icon;
      _mauDangChon = widget.viTienCu!.mauSac;
    }
  }

  void _luuViTien() {
    final nameText = _nameController.text.trim();
    if (nameText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên ví')),
      );
      return;
    }

    final balanceText = _balanceController.text.replaceAll('.', '').replaceAll(',', '');
    final balance = double.tryParse(balanceText) ?? 0.0;

    final viMoi = ViTien(
      id: widget.viTienCu?.id ?? DateTime.now().millisecondsSinceEpoch,
      tenVi: nameText,
      loaiVi: _loaiViDangChon,
      soDu: balance,
      icon: _iconDangChon,
      mauSac: _mauDangChon,
    );

    if (widget.viTienCu == null) {
      widget.onThemViTien?.call(viMoi);
    } else {
      widget.onCapNhatViTien?.call(viMoi);
    }
    
    Navigator.of(context).pop();
  }

  void _xoaViTien() {
    if (widget.viTienCu != null) {
      widget.onXoaViTien?.call(widget.viTienCu!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.viTienCu != null;

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
          isEdit ? 'Sửa thông tin ví' : 'Thêm ví tiền mới',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: MauSac.error),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Xóa ví', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                    content: Text('Bạn có chắc chắn muốn xóa ví "${widget.viTienCu!.tenVi}" không?', style: GoogleFonts.manrope()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Hủy', style: GoogleFonts.manrope()),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _xoaViTien();
                        },
                        child: Text('Xóa', style: GoogleFonts.manrope(color: MauSac.error, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  
                  // Balance (SỐ TIỀN)
                  Center(
                    child: Text(
                      'SỐ DƯ BAN ĐẦU (₫)',
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
                        controller: _balanceController,
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

                  // Name
                  Text(
                    'TÊN TÀI KHOẢN',
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
                      controller: _nameController,
                      style: GoogleFonts.manrope(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'VD: Tiền mặt, Vietcombank...',
                        hintStyle: GoogleFonts.manrope(color: MauSac.outline),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Wallet Type
                  Text(
                    'LOẠI TÀI KHOẢN',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: MauSac.outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MauSac.borderSubtle),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _loaiViDangChon,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: MauSac.onSurfaceVariant),
                        items: _loaiViOptions.map((w) {
                          return DropdownMenuItem<String>(
                            value: w,
                            child: Text(
                              w == 'CASH' ? 'Tiền mặt' : (w == 'BANK' ? 'Tài khoản Ngân hàng' : 'Thẻ Tín Dụng'), 
                              style: GoogleFonts.manrope(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _loaiViDangChon = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Icon selector
                  Text(
                    'BIỂU TƯỢNG',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: MauSac.outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _iconOptions.map((icon) {
                      final isSelected = icon == _iconDangChon;
                      return GestureDetector(
                        onTap: () => setState(() => _iconDangChon = icon),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: isSelected ? _mauDangChon : MauSac.surfaceContainerHigh,
                          child: Icon(icon, color: isSelected ? Colors.white : MauSac.onSurfaceVariant, size: 24),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Color selector
                  Text(
                    'MÀU SẮC',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: MauSac.outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _mauOptions.map((color) {
                      final isSelected = color == _mauDangChon;
                      return GestureDetector(
                        onTap: () => setState(() => _mauDangChon = color),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: color,
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 120), // padding for bottom button
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MauSac.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MauSac.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _luuViTien,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        isEdit ? 'Cập nhật ví tiền' : 'Lưu ví tiền',
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
        formattedText = ',' + formattedText;
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
