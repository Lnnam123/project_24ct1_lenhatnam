import 'package:flutter/material.dart';
import '../chu_de/mau_sac.dart';
import '../mo_hinh/du_lieu.dart';
import '../man_hinh/tro_ly_ai.dart';

class NutAiChatFloating extends StatefulWidget {
  final NguoiDung? nguoiDung;

  const NutAiChatFloating({
    super.key,
    this.nguoiDung,
  });

  // Tọa độ tĩnh để chia sẻ vị trí và trạng thái đồng bộ xuyên suốt các tab
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
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Khởi tạo tọa độ ban đầu an toàn, nằm phía trên thanh Bottom Bar
    if (!NutAiChatFloating.daKhoiTao || NutAiChatFloating.toaDoX == null || NutAiChatFloating.toaDoY == null) {
      NutAiChatFloating.toaDoX = size.width - 70;
      NutAiChatFloating.toaDoY = size.height - padding.bottom - 160;
      NutAiChatFloating.daKhoiTao = true;
    } else {
      // Đảm bảo tọa độ hiện tại không bị lọt ra ngoài màn hình
      final minY = padding.top + 60;
      final maxY = size.height - padding.bottom - 130;
      NutAiChatFloating.toaDoX = NutAiChatFloating.toaDoX!.clamp(10.0, size.width - 66);
      NutAiChatFloating.toaDoY = NutAiChatFloating.toaDoY!.clamp(minY, maxY);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!NutAiChatFloating.daKhoiTao || NutAiChatFloating.toaDoX == null || NutAiChatFloating.toaDoY == null) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final minY = padding.top + 60;
    final maxY = size.height - padding.bottom - 130;

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
                  NutAiChatFloating.toaDoX = (NutAiChatFloating.toaDoX! + details.delta.dx)
                      .clamp(10.0, size.width - 66);
                  NutAiChatFloating.toaDoY = (NutAiChatFloating.toaDoY! + details.delta.dy)
                      .clamp(minY, maxY);
                });
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ManHinhTroLyAI(nguoiDung: widget.nguoiDung),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: MauSac.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: MauSac.primary.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.smart_toy_rounded, size: 28, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
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
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.close, size: 10, color: Colors.white),
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
                height: 56,
                decoration: BoxDecoration(
                  color: MauSac.primary,
                  borderRadius: NutAiChatFloating.toaDoX! < size.width / 2
                      ? const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    NutAiChatFloating.toaDoX! < size.width / 2
                        ? Icons.chevron_right
                        : Icons.chevron_left,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
    );
  }
}
