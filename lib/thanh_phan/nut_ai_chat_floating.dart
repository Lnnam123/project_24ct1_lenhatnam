import 'package:flutter/material.dart';
import '../chu_de/mau_sac.dart';
import '../mo_hinh/du_lieu.dart';
import '../man_hinh/tro_ly_ai.dart';

class NutAiChatFloating extends StatefulWidget {
  final NguoiDung? nguoiDung;
  final String? heroTag;

  const NutAiChatFloating({
    super.key,
    this.nguoiDung,
    this.heroTag,
  });

  // Tọa độ tĩnh để chia sẻ vị trí và trạng thái đồng bộ giữa các màn hình (Tổng quan, Báo cáo, Ví)
  static double? toaDoX;
  static double? toaDoY;
  static bool daKhoiTao = false;
  static bool dangHienThi = true;

  @override
  State<NutAiChatFloating> createState() => _NutAiChatFloatingState();
}

class _NutAiChatFloatingState extends State<NutAiChatFloating> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!NutAiChatFloating.daKhoiTao || NutAiChatFloating.toaDoX == null || NutAiChatFloating.toaDoY == null) {
      final size = MediaQuery.of(context).size;
      NutAiChatFloating.toaDoX = size.width - 80;
      NutAiChatFloating.toaDoY = size.height * 0.65;
      NutAiChatFloating.daKhoiTao = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!NutAiChatFloating.daKhoiTao || NutAiChatFloating.toaDoX == null || NutAiChatFloating.toaDoY == null) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final double leftPos = NutAiChatFloating.dangHienThi
        ? NutAiChatFloating.toaDoX!
        : (NutAiChatFloating.toaDoX! < size.width / 2 ? 0.0 : size.width - 24);

    return Positioned(
      left: leftPos,
      top: NutAiChatFloating.toaDoY,
      child: NutAiChatFloating.dangHienThi
          ? GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  NutAiChatFloating.toaDoX = (NutAiChatFloating.toaDoX! + details.delta.dx).clamp(0.0, size.width - 64);
                  NutAiChatFloating.toaDoY = (NutAiChatFloating.toaDoY! + details.delta.dy).clamp(0.0, size.height - 160);
                });
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  FloatingActionButton(
                    heroTag: widget.heroTag,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ManHinhTroLyAI(nguoiDung: widget.nguoiDung),
                        ),
                      );
                    },
                    backgroundColor: MauSac.primary, // Nền xanh
                    foregroundColor: Colors.white,   // Icon trắng
                    elevation: 8,
                    child: const Icon(Icons.smart_toy, size: 28),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          NutAiChatFloating.dangHienThi = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: MauSac.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: MauSac.surface, width: 2),
                        ),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  NutAiChatFloating.dangHienThi = true;
                });
              },
              child: Container(
                width: 24,
                height: 64,
                decoration: BoxDecoration(
                  color: MauSac.primary,
                  borderRadius: NutAiChatFloating.toaDoX! < size.width / 2
                      ? const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    NutAiChatFloating.toaDoX! < size.width / 2
                        ? Icons.chevron_right
                        : Icons.chevron_left,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
    );
  }
}
