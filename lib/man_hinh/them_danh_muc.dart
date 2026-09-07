import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';
import '../mo_hinh/du_lieu.dart';
import '../tien_ich/bieu_tuong_helper.dart';

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
  final TextEditingController _timKiemIconController = TextEditingController();
  String _tuKhoaIcon = '';
  String _nhomIconSelected = 'ALL';

  late List<IconData> _icons;
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
    _icons = List<IconData>.from(BieuTuongHelper.danhSachTatCaIcon);

    if (widget.danhMucSua != null) {
      _loaiSelected = widget.danhMucSua!.loai;
      _tenController.text = widget.danhMucSua!.ten;
      _iconSelected = widget.danhMucSua!.icon;
      _colorSelected = widget.danhMucSua!.mauSac;

      // Đảm bảo icon của danh mục sửa luôn có trong danh sách
      if (!_icons.any((ic) => ic.codePoint == _iconSelected.codePoint)) {
        _icons.insert(0, _iconSelected);
      }
    } else {
      _iconSelected = _icons[0];
      _colorSelected = _colors[0];
    }
  }

  @override
  void dispose() {
    _tenController.dispose();
    _timKiemIconController.dispose();
    super.dispose();
  }

  List<BieuTuongItem> get _danhSachIconHienThi {
    return BieuTuongHelper.danhSachBieuTuong.where((item) {
      if (_nhomIconSelected != 'ALL' && item.category != _nhomIconSelected) {
        return false;
      }
      if (_tuKhoaIcon.trim().isNotEmpty) {
        final q = _tuKhoaIcon.trim().toLowerCase();
        return item.name.toLowerCase().contains(q) ||
            item.label.toLowerCase().contains(q) ||
            item.tags.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  void _luuDanhMuc() {
    final ten = _tenController.text.trim();
    if (ten.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập tên danh mục', style: GoogleFonts.manrope()),
          backgroundColor: MauSac.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chọn biểu tượng',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: MauSac.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _colorSelected.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _colorSelected.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_iconSelected, size: 15, color: _colorSelected),
                            const SizedBox(width: 6),
                            Text(
                              BieuTuongHelper.layNhanIcon(_iconSelected),
                              style: GoogleFonts.manrope(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: _colorSelected,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search Box
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: MauSac.borderSubtle),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: MauSac.outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _timKiemIconController,
                            onChanged: (val) => setState(() => _tuKhoaIcon = val),
                            style: GoogleFonts.manrope(fontSize: 13, color: MauSac.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Tìm biểu tượng (ăn, xe, bill, game, tiền...)...',
                              hintStyle: GoogleFonts.manrope(fontSize: 12.5, color: MauSac.outlineVariant),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_tuKhoaIcon.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _timKiemIconController.clear();
                              setState(() => _tuKhoaIcon = '');
                            },
                            child: const Icon(Icons.close, size: 16, color: MauSac.outline),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Category Filter Tabs
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: BieuTuongHelper.danhSachNhom.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 6),
                      itemBuilder: (context, idx) {
                        final nhom = BieuTuongHelper.danhSachNhom[idx];
                        final isSelected = _nhomIconSelected == nhom.id;
                        return GestureDetector(
                          onTap: () => setState(() => _nhomIconSelected = nhom.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? MauSac.primary : MauSac.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? MauSac.primary : MauSac.borderSubtle,
                              ),
                            ),
                            child: Text(
                              nhom.label,
                              style: GoogleFonts.manrope(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : MauSac.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Icons Grid
                  if (_danhSachIconHienThi.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: MauSac.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MauSac.borderSubtle),
                      ),
                      child: Text(
                        'Không tìm thấy biểu tượng nào phù hợp với "$_tuKhoaIcon"',
                        style: GoogleFonts.manrope(fontSize: 13, color: MauSac.outline),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _danhSachIconHienThi.length,
                      itemBuilder: (context, index) {
                        final item = _danhSachIconHienThi[index];
                        final isSelected = item.icon.codePoint == _iconSelected.codePoint;
                        return Tooltip(
                          message: item.label,
                          child: GestureDetector(
                            onTap: () => setState(() => _iconSelected = item.icon),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isSelected ? _colorSelected : MauSac.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : MauSac.borderSubtle,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: _colorSelected.withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                item.icon,
                                size: 24,
                                color: isSelected ? Colors.white : MauSac.onSurfaceVariant,
                              ),
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
