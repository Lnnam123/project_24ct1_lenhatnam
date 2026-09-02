import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';
import '../man_hinh/tong_quan.dart';
import '../man_hinh/bao_cao.dart';
import '../man_hinh/vi_tien.dart';
import '../man_hinh/cai_dat.dart';

class TrangTongQuanSkeleton extends StatelessWidget {
  const TrangTongQuanSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          ManHinhTongQuan.tenTrang,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: MauSac.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: Container(width: 200, height: 28, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Thu chi tháng này skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MauSac.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MauSac.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: MauSac.surfaceContainerHigh,
                    highlightColor: MauSac.surfaceContainerHighest,
                    child: Container(width: 140, height: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Shimmer.fromColors(
                    baseColor: MauSac.surfaceContainerHigh,
                    highlightColor: MauSac.surfaceContainerHighest,
                    child: Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                  ),
                  const SizedBox(height: 24),
                  Shimmer.fromColors(
                    baseColor: MauSac.surfaceContainerHigh,
                    highlightColor: MauSac.surfaceContainerHighest,
                    child: Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Ngân sách skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MauSac.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MauSac.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: MauSac.surfaceContainerHigh,
                    highlightColor: MauSac.surfaceContainerHighest,
                    child: Container(width: 100, height: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 120, height: 24, color: Colors.white)),
                      Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 120, height: 24, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Shimmer.fromColors(
                    baseColor: MauSac.surfaceContainerHigh,
                    highlightColor: MauSac.surfaceContainerHighest,
                    child: Container(width: double.infinity, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tình hình chi tiêu skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MauSac.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MauSac.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Shimmer.fromColors(
                        baseColor: MauSac.surfaceContainerHigh,
                        highlightColor: MauSac.surfaceContainerHighest,
                        child: Container(width: 130, height: 20, color: Colors.white),
                      ),
                      Shimmer.fromColors(
                        baseColor: MauSac.surfaceContainerHigh,
                        highlightColor: MauSac.surfaceContainerHighest,
                        child: Container(width: 125, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Shimmer.fromColors(
                        baseColor: MauSac.surfaceContainerHigh,
                        highlightColor: MauSac.surfaceContainerHighest,
                        child: const CircleAvatar(radius: 60, backgroundColor: Colors.white),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          children: List.generate(3, (index) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Shimmer.fromColors(
                                baseColor: MauSac.surfaceContainerHigh,
                                highlightColor: MauSac.surfaceContainerHighest,
                                child: Container(width: double.infinity, height: 16, color: Colors.white),
                              ),
                            )
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class PhanTichSkeleton extends StatelessWidget {
  const PhanTichSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          ManHinhBaoCao.tenTrang,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: MauSac.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: MauSac.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: List.generate(3, (index) => 
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Shimmer.fromColors(
                          baseColor: MauSac.surfaceContainerHigh,
                          highlightColor: MauSac.surfaceContainerHighest,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    )
                  ),
                ),
              ),
            ),
            
            // Summary Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: MauSac.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MauSac.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 90, height: 14, color: Colors.white)),
                              const SizedBox(height: 8),
                              Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 120, height: 24, color: Colors.white)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 90, height: 14, color: Colors.white)),
                              const SizedBox(height: 8),
                              Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 120, height: 24, color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 140, height: 14, color: Colors.white)),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 130, height: 24, color: Colors.white)),
                    const SizedBox(height: 24),
                    // Legend
                    Row(
                      children: [
                        Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: const CircleAvatar(radius: 6, backgroundColor: Colors.white)),
                        const SizedBox(width: 6),
                        Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 60, height: 12, color: Colors.white)),
                        const SizedBox(width: 16),
                        Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: const CircleAvatar(radius: 6, backgroundColor: Colors.white)),
                        const SizedBox(width: 6),
                        Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 60, height: 12, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Chart Area
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(5, (index) {
                        final heights = [100.0, 60.0, 120.0, 40.0, 80.0];
                        return Column(
                          children: [
                            Shimmer.fromColors(
                              baseColor: MauSac.surfaceContainerHigh, 
                              highlightColor: MauSac.surfaceContainerHighest, 
                              child: Container(
                                width: 24, 
                                height: heights[index], 
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))
                              )
                            ),
                            const SizedBox(height: 8),
                            Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 32, height: 12, color: Colors.white)),
                          ]
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            
            // Calendar section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MauSac.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 140, height: 20, color: Colors.white)),
                        Row(
                          children: [
                            Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 24, height: 24, color: Colors.white)),
                            const SizedBox(width: 16),
                            Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 24, height: 24, color: Colors.white)),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Weekdays
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) => 
                        Shimmer.fromColors(
                          baseColor: MauSac.surfaceContainerHigh, 
                          highlightColor: MauSac.surfaceContainerHighest, 
                          child: Container(width: 20, height: 14, color: Colors.white)
                        )
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Days
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) => 
                        Shimmer.fromColors(
                          baseColor: MauSac.surfaceContainerHigh, 
                          highlightColor: MauSac.surfaceContainerHighest, 
                          child: Container(
                            width: 42, 
                            height: 64, 
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            )
                          )
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class ViTienSkeleton extends StatelessWidget {
  const ViTienSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          ManHinhViTien.tenTrang,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: MauSac.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: MauSac.surfaceContainerHigh,
                  highlightColor: MauSac.surfaceContainerHighest,
                  child: Container(width: 150, height: 24, color: Colors.white),
                ),
                Shimmer.fromColors(
                  baseColor: MauSac.surfaceContainerHigh,
                  highlightColor: MauSac.surfaceContainerHighest,
                  child: const CircleAvatar(radius: 16, backgroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                itemBuilder: (ctx, index) {
                  return Container(
                    width: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MauSac.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MauSac.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: const CircleAvatar(radius: 20, backgroundColor: Colors.white)),
                            Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 48, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)))),
                          ],
                        ),
                        const Spacer(),
                        Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 60, height: 14, color: Colors.white)),
                        const SizedBox(height: 8),
                        Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 120, height: 24, color: Colors.white)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: MauSac.surfaceContainerHigh,
                  highlightColor: MauSac.surfaceContainerHighest,
                  child: Container(width: 150, height: 24, color: Colors.white),
                ),
                Shimmer.fromColors(
                  baseColor: MauSac.surfaceContainerHigh,
                  highlightColor: MauSac.surfaceContainerHighest,
                  child: Container(width: 125, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (ctx, i) => const SizedBox(height: 24),
              itemBuilder: (ctx, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 100, height: 16, color: Colors.white)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: MauSac.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: MauSac.borderSubtle)),
                      child: Row(
                        children: [
                          Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: const CircleAvatar(radius: 20, backgroundColor: Colors.white)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 80, height: 16, color: Colors.white)),
                                const SizedBox(height: 4),
                                Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 120, height: 12, color: Colors.white)),
                              ],
                            ),
                          ),
                          Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 80, height: 16, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class CaiDatSkeleton extends StatelessWidget {
  const CaiDatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          ManHinhCaiDat.tenTrang,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: Container(width: 120, height: 20, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: Container(width: 120, height: 20, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
