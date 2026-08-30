import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

class ModalThemViTien extends StatefulWidget {
  final Function(ViTien) onThemViTien;

  const ModalThemViTien({
    super.key,
    required this.onThemViTien,
  });

  @override
  State<ModalThemViTien> createState() => _ModalThemViTienState();
}

class _ModalThemViTienState extends State<ModalThemViTien> {
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
      id: DateTime.now().millisecondsSinceEpoch, // temporary
      tenVi: nameText,
      loaiVi: _loaiViDangChon,
      soDu: balance,
      icon: _iconDangChon,
      mauSac: _mauDangChon,
    );

    widget.onThemViTien(viMoi);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: MauSac.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thêm ví tiền mới',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MauSac.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Name
            TextField(
              controller: _nameController,
              style: GoogleFonts.manrope(),
              decoration: InputDecoration(
                labelText: 'Tên ví (VD: Tiền mặt, Vietcombank)',
                labelStyle: GoogleFonts.manrope(),
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Balance
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MauSac.primary,
              ),
              decoration: InputDecoration(
                labelText: 'Số dư ban đầu (₫)',
                labelStyle: GoogleFonts.manrope(fontSize: 16),
                prefixIcon: const Icon(Icons.attach_money, color: MauSac.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Wallet Type
            DropdownButtonFormField<String>(
              initialValue: _loaiViDangChon,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Loại tài khoản',
                labelStyle: GoogleFonts.manrope(),
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _loaiViOptions.map((w) {
                return DropdownMenuItem<String>(
                  value: w,
                  child: Text(
                    w == 'CASH' ? 'Tiền mặt' : (w == 'BANK' ? 'Tài khoản Ngân hàng' : 'Thẻ Tín Dụng'), 
                    style: GoogleFonts.manrope(),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _loaiViDangChon = val);
              },
            ),
            const SizedBox(height: 16),

            // Icon selector
            Text(
              'Chọn biểu tượng',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _iconOptions.map((icon) {
                final isSelected = icon == _iconDangChon;
                return GestureDetector(
                  onTap: () => setState(() => _iconDangChon = icon),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: isSelected ? _mauDangChon : MauSac.surfaceContainerHigh,
                    child: Icon(icon, color: isSelected ? Colors.white : MauSac.onSurfaceVariant),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Color selector
            Text(
              'Chọn màu sắc',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _mauOptions.map((color) {
                final isSelected = color == _mauDangChon;
                return GestureDetector(
                  onTap: () => setState(() => _mauDangChon = color),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: color,
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Save button
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
                onPressed: _luuViTien,
                child: Text(
                  'LƯU VÍ TIỀN',
                  style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
