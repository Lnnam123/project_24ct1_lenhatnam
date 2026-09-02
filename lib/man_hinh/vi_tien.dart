import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

class ManHinhViTien extends StatefulWidget {
  final List<ViTien> danhSachVi;
  final List<GiaoDich> danhSachGiaoDich;
  final VoidCallback moThemViTien;
  final Function(ViTien) moQuanLyViTien;
  final VoidCallback onTapThongBao;
  final bool coThongBaoChuaDoc;
  final Future<void> Function() onRefresh;
  final Function(GiaoDich)? moSuaGiaoDich;

  const ManHinhViTien({
    super.key,
    required this.danhSachVi,
    required this.danhSachGiaoDich,
    required this.moThemViTien,
    required this.moQuanLyViTien,
    required this.onTapThongBao,
    required this.coThongBaoChuaDoc,
    required this.onRefresh,
    this.moSuaGiaoDich,
  });

  @override
  State<ManHinhViTien> createState() => _ManHinhViTienState();
}

class _ManHinhViTienState extends State<ManHinhViTien> {
  String _boloc = 'Tất cả';
  final Set<int> _viTienHienSoDu = {};

  String _dinhDangTien(double soTien) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(soTien);
  }

  @override
  Widget build(BuildContext context) {
    final giaoDichDaLoc = widget.danhSachGiaoDich.where((tx) {
      if (_boloc == 'Chi tiêu') return tx.loai == LoaiGiaoDich.chiTieu;
      if (_boloc == 'Thu nhập') return tx.loai == LoaiGiaoDich.thuNhap;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Tài khoản',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
        actions: [
          IconButton(
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
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách tài khoản',
                  style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: widget.moThemViTien,
                  icon: const Icon(Icons.add_circle, color: MauSac.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Horizontal Wallets List
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.danhSachVi.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                itemBuilder: (ctx, index) {
                  final vi = widget.danhSachVi[index];
                  final isHidden = !_viTienHienSoDu.contains(vi.id);
                  return GestureDetector(
                    onTap: () => widget.moQuanLyViTien(vi),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MauSac.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MauSac.borderSubtle),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: vi.mauSac.withValues(alpha: 0.15),
                                child: Icon(vi.icon, color: vi.mauSac, size: 18),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: MauSac.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  vi.loaiVi,
                                  style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vi.tenVi,
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: MauSac.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    isHidden ? '****** đ' : _dinhDangTien(vi.soDu),
                                    style: GoogleFonts.manrope(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: MauSac.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (isHidden) {
                                          _viTienHienSoDu.add(vi.id);
                                        } else {
                                          _viTienHienSoDu.remove(vi.id);
                                        }
                                      });
                                    },
                                    child: Icon(
                                      isHidden ? Icons.visibility_off : Icons.visibility,
                                      color: MauSac.onSurfaceVariant,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // All Transactions Section Header & Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lịch sử giao dịch',
                  style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 105,
                  child: DropdownButtonFormField<String>(
                    value: _boloc,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: const Color(0xFFF8FAFC),
                    icon: const Icon(Icons.keyboard_arrow_down, color: MauSac.onSurfaceVariant),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.borderSubtle),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: ['Tất cả', 'Thu nhập', 'Chi tiêu'].map((f) {
                      return DropdownMenuItem<String>(
                        value: f,
                        child: Text(
                          f,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: MauSac.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _boloc = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Transactions List
            Builder(
              builder: (context) {
                if (giaoDichDaLoc.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Text('Không tìm thấy giao dịch', style: GoogleFonts.manrope()),
                    ),
                  );
                }
                
                final Map<String, List<GiaoDich>> groups = {};
                for (var tx in giaoDichDaLoc) {
                  final monthStr = 'Tháng ${tx.ngay.month}/${tx.ngay.year}';
                  if (!groups.containsKey(monthStr)) {
                    groups[monthStr] = [];
                  }
                  groups[monthStr]!.add(tx);
                }
                
                final List<dynamic> listItems = [];
                for (var entry in groups.entries) {
                  listItems.add(entry.key);
                  listItems.addAll(entry.value);
                }
                
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listItems.length,
                    itemBuilder: (ctx, index) {
                      final item = listItems[index];
                      if (item is String) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 12),
                          child: Text(
                            item,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: MauSac.onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      
                      final txItem = item as GiaoDich;
                      final isExpense = txItem.loai == LoaiGiaoDich.chiTieu;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => widget.moSuaGiaoDich?.call(txItem),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: MauSac.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: MauSac.borderSubtle),
                            ),
                            child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: txItem.danhMuc.mauSac.withOpacity(0.15),
                                child: Icon(txItem.danhMuc.icon, color: txItem.danhMuc.mauSac, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      txItem.tieuDe,
                                      style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${DateFormat('HH:mm - dd/MM').format(txItem.ngay)} • ${txItem.viTien.tenVi}',
                                      style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        color: MauSac.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isExpense ? '-' : '+'}${_dinhDangTien(txItem.soTien)}',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isExpense ? MauSac.error : MauSac.success,
                                ),
                              ),
                            ],
                          ),
                        )),
                      );
                    },
                  );
              }
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      ),
    );
  }
}
