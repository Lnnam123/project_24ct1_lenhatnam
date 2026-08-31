import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

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

class ModalNganSach extends StatefulWidget {
  final NganSach? nganSachCu;
  final List<DanhMuc> danhSachDanhMuc;
  final Function(NganSach) onCapNhatNganSach;
  final Function(int)? onXoaNganSach;

  const ModalNganSach({
    super.key,
    this.nganSachCu,
    required this.danhSachDanhMuc,
    required this.onCapNhatNganSach,
    this.onXoaNganSach,
  });

  @override
  State<ModalNganSach> createState() => _ModalNganSachState();
}

class _ModalNganSachState extends State<ModalNganSach> {
  final _amountController = TextEditingController();
  DanhMuc? _danhMucChon;

  @override
  void initState() {
    super.initState();
    if (widget.nganSachCu != null) {
      _danhMucChon = widget.nganSachCu!.danhMuc;
      // Format initial number with commas
      String balanceStr = widget.nganSachCu!.hanMuc.toStringAsFixed(0);
      String formattedText = '';
      int count = 0;
      for (int i = balanceStr.length - 1; i >= 0; i--) {
        formattedText = balanceStr[i] + formattedText;
        count++;
        if (count % 3 == 0 && i != 0) {
          formattedText = ',' + formattedText;
        }
      }
      _amountController.text = formattedText;
    }
  }

  void _luuNganSach() {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập ngân sách lớn hơn 0')),
      );
      return;
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final nganSachMoi = NganSach(
      id: widget.nganSachCu?.id ?? 0,
      hanMuc: amount,
      daChi: 0,
      ngayBatDau: widget.nganSachCu?.ngayBatDau ?? startOfMonth,
      ngayKetThuc: widget.nganSachCu?.ngayKetThuc ?? endOfMonth,
      danhMuc: _danhMucChon,
    );

    widget.onCapNhatNganSach(nganSachMoi);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.surface,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: MauSac.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Thiết lập ngân sách',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Category Selector
                  Text(
                    'ÁP DỤNG CHO',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: MauSac.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: MauSac.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DanhMuc?>(
                        value: _danhMucChon,
                        isExpanded: true,
                        hint: Text('Tất cả chi tiêu (Ngân sách chung)', style: GoogleFonts.manrope(color: MauSac.onSurfaceVariant)),
                        items: [
                          DropdownMenuItem<DanhMuc?>(
                            value: null,
                            child: Row(
                              children: [
                                Icon(Icons.apps, color: MauSac.primary, size: 20),
                                const SizedBox(width: 12),
                                Text('Tất cả chi tiêu', style: GoogleFonts.manrope()),
                              ],
                            ),
                          ),
                          ...widget.danhSachDanhMuc.map((dm) {
                            return DropdownMenuItem<DanhMuc?>(
                              value: dm,
                              child: Row(
                                children: [
                                  Icon(dm.icon, color: dm.mauSac, size: 20),
                                  const SizedBox(width: 12),
                                  Text(dm.ten, style: GoogleFonts.manrope()),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _danhMucChon = val;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // Limit amount
                  Center(
                    child: Text(
                      'HẠN MỨC CHI TIÊU THÁNG NÀY (₫)',
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
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MauSac.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, color: MauSac.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ngân sách giúp bạn kiểm soát chi tiêu tốt hơn. Hệ thống sẽ cảnh báo khi bạn chi tiêu gần hết ngân sách.',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                color: MauSac.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
              decoration: const BoxDecoration(
                color: MauSac.surface,
                border: Border(top: BorderSide(color: MauSac.borderSubtle)),
              ),
              child: Row(
                children: [
                  if (widget.nganSachCu != null && widget.onXoaNganSach != null) ...[
                    IconButton(
                      onPressed: () {
                        widget.onXoaNganSach!(widget.nganSachCu!.id);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete_outline, color: MauSac.error),
                      style: IconButton.styleFrom(
                        backgroundColor: MauSac.error.withValues(alpha: 0.1),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _luuNganSach,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MauSac.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Lưu ngân sách',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
