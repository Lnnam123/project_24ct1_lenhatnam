import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';
import '../mo_hinh/du_lieu.dart';

class ManHinhThemDanhMuc extends StatefulWidget {
  final Function(DanhMuc danhMucMoi) onThemDanhMuc;
  final DanhMuc? danhMucSua;

  const ManHinhThemDanhMuc({super.key, required this.onThemDanhMuc, this.danhMucSua});

  @override
  State<ManHinhThemDanhMuc> createState() => _ManHinhThemDanhMucState();
}

class _ManHinhThemDanhMucState extends State<ManHinhThemDanhMuc> {
  LoaiGiaoDich _loaiSelected = LoaiGiaoDich.chiTieu;
  final TextEditingController _tenController = TextEditingController();

  final List<IconData> _icons = [
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.directions_car,
    Icons.health_and_safety,
    Icons.movie,
    Icons.home,
    Icons.school,
    Icons.flight,
    Icons.sports_esports,
  ];

  late IconData _iconSelected;

  final List<Color> _colors = [
    const Color(0xFF004AC6), // Primary Blue
    const Color(0xFF712AE2), // Secondary Purple
    const Color(0xFF10B981), // Success Green
    const Color(0xFFF59E0B), // Warning Amber
    const Color(0xFFEF4444), // Error Red
    const Color(0xFF14B8A6), // Teal
    const Color(0xFFEC4899), // Pink
    const Color(0xFFF97316), // Orange
  ];

  late Color _colorSelected;

  @override
  void initState() {
    super.initState();
    if (widget.danhMucSua != null) {
      _loaiSelected = widget.danhMucSua!.loai;
      _tenController.text = widget.danhMucSua!.ten;
      _iconSelected = widget.danhMucSua!.icon;
      _colorSelected = widget.danhMucSua!.mauSac;
    } else {
      _iconSelected = _icons[0];
      _colorSelected = _colors[0];
    }
  }

  @override
  void dispose() {
    _tenController.dispose();
    super.dispose();
  }

  void _luuDanhMuc() {
    final ten = _tenController.text.trim();
    if (ten.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập tên danh mục', style: GoogleFonts.manrope()),
          backgroundColor: MauSac.error,
        ),
      );
      return;
    }

    final danhMucLuu = DanhMuc(
      id: widget.danhMucSua?.id ?? DateTime.now().millisecondsSinceEpoch,
      ten: ten,
      loai: _loaiSelected,
      icon: _iconSelected,
      mauSac: _colorSelected,
    );

    widget.onThemDanhMuc(danhMucLuu);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.danhMucSua != null;
    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MauSac.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit ? 'Sửa danh mục' : 'Thêm danh mục',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Selector (Chi tiêu / Thu nhập)
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: MauSac.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _loaiSelected = LoaiGiaoDich.chiTieu),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _loaiSelected == LoaiGiaoDich.chiTieu
                                    ? MauSac.surface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _loaiSelected == LoaiGiaoDich.chiTieu
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        )
                                      ]
                                    : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Chi tiêu',
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: _loaiSelected == LoaiGiaoDich.chiTieu
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: _loaiSelected == LoaiGiaoDich.chiTieu
                                      ? MauSac.primary
                                      : MauSac.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _loaiSelected = LoaiGiaoDich.thuNhap),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _loaiSelected == LoaiGiaoDich.thuNhap
                                    ? MauSac.surface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _loaiSelected == LoaiGiaoDich.thuNhap
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        )
                                      ]
                                    : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Thu nhập',
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: _loaiSelected == LoaiGiaoDich.thuNhap
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: _loaiSelected == LoaiGiaoDich.thuNhap
                                      ? MauSac.primary
                                      : MauSac.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Name Input
                  Text(
                    'Tên danh mục',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: MauSac.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tenController,
                    style: GoogleFonts.manrope(fontSize: 16, color: MauSac.onSurface),
                    decoration: InputDecoration(
                      hintText: 'VD: Mua sắm, Ăn uống...',
                      hintStyle: GoogleFonts.manrope(color: MauSac.outlineVariant),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Choose Icon
                  Text(
                    'Chọn biểu tượng',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: MauSac.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _icons.length,
                    itemBuilder: (context, index) {
                      final icon = _icons[index];
                      final isSelected = icon == _iconSelected;
                      return GestureDetector(
                        onTap: () => setState(() => _iconSelected = icon),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isSelected ? _colorSelected : MauSac.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : MauSac.borderSubtle,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _colorSelected.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                          ),
                          child: Icon(
                            icon,
                            size: 28,
                            color: isSelected ? Colors.white : MauSac.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Color Picker
                  Text(
                    'Màu sắc',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: MauSac.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _colors.length,
                      separatorBuilder: (ctx, idx) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final color = _colors[index];
                        final isSelected = color == _colorSelected;
                        return GestureDetector(
                          onTap: () => setState(() => _colorSelected = color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : [],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 24)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed Bottom Action Area
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: MauSac.surface,
              border: Border(top: BorderSide(color: MauSac.borderSubtle)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MauSac.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: MauSac.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _luuDanhMuc,
                icon: const Icon(Icons.save, size: 22),
                label: Text(
                  isEdit ? 'Cập nhật danh mục' : 'Lưu danh mục',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
