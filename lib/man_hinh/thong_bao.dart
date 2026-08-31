import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../chu_de/mau_sac.dart';
import '../mo_hinh/du_lieu.dart';
import '../du_lieu/database_helper.dart';

class ManHinhThongBao extends StatefulWidget {
  final int userId;
  const ManHinhThongBao({super.key, required this.userId});

  @override
  State<ManHinhThongBao> createState() => _ManHinhThongBaoState();
}

class _ManHinhThongBaoState extends State<ManHinhThongBao> {
  List<ThongBao> _danhSachThongBao = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _taiThongBao();
  }

  Future<void> _taiThongBao() async {
    final thongBaos = await DatabaseHelper.instance.getNotifications(widget.userId);
    setState(() {
      _danhSachThongBao = thongBaos;
      _isLoading = false;
    });
  }

  IconData _layIconTheoLoai(String loai) {
    switch (loai) {
      case 'BUDGET_ALERT':
        return Icons.warning_amber_rounded;
      case 'TRANSACTION_REMINDER':
        return Icons.event_note_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _layMauTheoLoai(String loai) {
    switch (loai) {
      case 'BUDGET_ALERT':
        return MauSac.warning;
      case 'TRANSACTION_REMINDER':
        return MauSac.primary;
      default:
        return MauSac.secondary;
    }
  }

  String _thoiGianTuongDoi(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays >= 365) {
      return DateFormat('dd/MM/yyyy').format(time);
    } else if (difference.inDays >= 30) {
      int months = difference.inDays ~/ 30;
      return '$months tháng trước';
    } else if (difference.inDays >= 1) {
      if (difference.inDays == 1) return 'Hôm qua';
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        title: Text('Thông báo', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _danhSachThongBao.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: MauSac.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('Bạn chưa có thông báo nào', style: GoogleFonts.manrope(color: MauSac.onSurfaceVariant, fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _danhSachThongBao.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final tb = _danhSachThongBao[index];
                return GestureDetector(
                  onTap: () async {
                    if (!tb.daDoc) {
                      await DatabaseHelper.instance.markNotificationAsRead(tb.id);
                      _taiThongBao(); // Reload to update UI
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tb.daDoc ? MauSac.surface : MauSac.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: tb.daDoc ? MauSac.borderSubtle : MauSac.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: _layMauTheoLoai(tb.loai).withValues(alpha: 0.1),
                          child: Icon(_layIconTheoLoai(tb.loai), color: _layMauTheoLoai(tb.loai)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      tb.tieuDe,
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: tb.daDoc ? FontWeight.w600 : FontWeight.bold,
                                        color: MauSac.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (!tb.daDoc)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: MauSac.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tb.noiDung,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  color: MauSac.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _thoiGianTuongDoi(tb.ngayTao),
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: MauSac.onSurfaceVariant.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
