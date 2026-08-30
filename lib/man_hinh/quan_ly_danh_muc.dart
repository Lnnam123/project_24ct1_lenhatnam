import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';
import '../mo_hinh/du_lieu.dart';
import 'them_danh_muc.dart';

class ManHinhQuanLyDanhMuc extends StatefulWidget {
  final List<DanhMuc> danhSachDanhMuc;
  final Function(DanhMuc danhMucMoi) onThemDanhMuc;
  final Function(DanhMuc danhMucSua) onCapNhatDanhMuc;
  final Function(int danhMucId) onXoaDanhMuc;

  const ManHinhQuanLyDanhMuc({
    super.key,
    required this.danhSachDanhMuc,
    required this.onThemDanhMuc,
    required this.onCapNhatDanhMuc,
    required this.onXoaDanhMuc,
  });

  @override
  State<ManHinhQuanLyDanhMuc> createState() => _ManHinhQuanLyDanhMucState();
}

class _ManHinhQuanLyDanhMucState extends State<ManHinhQuanLyDanhMuc> {
  LoaiGiaoDich _tabHienTai = LoaiGiaoDich.chiTieu;
  late List<DanhMuc> _danhSachLocal;

  @override
  void initState() {
    super.initState();
    _danhSachLocal = List.from(widget.danhSachDanhMuc);
  }

  @override
  void didUpdateWidget(covariant ManHinhQuanLyDanhMuc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.danhSachDanhMuc != oldWidget.danhSachDanhMuc) {
      setState(() {
        _danhSachLocal = List.from(widget.danhSachDanhMuc);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final danhSachHienThi = _danhSachLocal
        .where((d) => d.loai == _tabHienTai)
        .toList();

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
          'Quản lý danh mục',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          // Segmented Control (Chi tiêu / Thu nhập)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: MauSac.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabHienTai = LoaiGiaoDich.chiTieu),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _tabHienTai == LoaiGiaoDich.chiTieu
                              ? MauSac.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _tabHienTai == LoaiGiaoDich.chiTieu
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 2,
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
                            fontWeight: _tabHienTai == LoaiGiaoDich.chiTieu
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: _tabHienTai == LoaiGiaoDich.chiTieu
                                ? MauSac.primary
                                : MauSac.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabHienTai = LoaiGiaoDich.thuNhap),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _tabHienTai == LoaiGiaoDich.thuNhap
                              ? MauSac.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _tabHienTai == LoaiGiaoDich.thuNhap
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 2,
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
                            fontWeight: _tabHienTai == LoaiGiaoDich.thuNhap
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: _tabHienTai == LoaiGiaoDich.thuNhap
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
          ),

          // Categories List
          Expanded(
            child: danhSachHienThi.isEmpty
                ? Center(
                    child: Text(
                      'Chưa có danh mục nào',
                      style: GoogleFonts.manrope(color: MauSac.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: danhSachHienThi.length,
                    separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = danhSachHienThi[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: MauSac.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: MauSac.borderSubtle),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: item.mauSac.withValues(alpha: 0.15),
                            child: Icon(item.icon, color: item.mauSac, size: 22),
                          ),
                          title: Text(
                            item.ten,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: MauSac.onSurface,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: MauSac.primary, size: 22),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ManHinhThemDanhMuc(
                                        danhMucSua: item,
                                        onThemDanhMuc: (danhMucSua) async {
                                          await widget.onCapNhatDanhMuc(danhMucSua);
                                          setState(() {
                                            final idx = _danhSachLocal.indexWhere((d) => d.id == danhMucSua.id);
                                            if (idx != -1) {
                                              _danhSachLocal[idx] = danhMucSua;
                                            } else {
                                              _danhSachLocal.add(danhMucSua);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: MauSac.error, size: 22),
                                onPressed: () => _xacNhanXoa(item),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Add New Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MauSac.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ManHinhThemDanhMuc(
                        onThemDanhMuc: (danhMucMoi) async {
                          await widget.onThemDanhMuc(danhMucMoi);
                          setState(() {
                            _danhSachLocal.add(danhMucMoi);
                          });
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(
                  'Thêm danh mục mới',
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

  void _xacNhanXoa(DanhMuc item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xóa danh mục', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa danh mục "${item.ten}"?', style: GoogleFonts.manrope()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Hủy', style: GoogleFonts.manrope()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.onXoaDanhMuc(item.id);
              setState(() {
                _danhSachLocal.removeWhere((d) => d.id == item.id);
              });
            },
            child: Text('Xóa', style: GoogleFonts.manrope(color: MauSac.error)),
          ),
        ],
      ),
    );
  }
}
