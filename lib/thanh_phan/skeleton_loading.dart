import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';

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
          'Trang chủ',
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
            Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: MauSac.surfaceContainerHigh,
                    highlightColor: MauSac.surfaceContainerHighest,
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: MauSac.surfaceContainerHigh,
                    highlightColor: MauSac.surfaceContainerHighest,
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: Container(width: 150, height: 24, color: Colors.white),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                return Shimmer.fromColors(
                  baseColor: MauSac.surfaceContainerHigh,
                  highlightColor: MauSac.surfaceContainerHighest,
                  child: Container(
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
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
          'Phân tích',
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
              child: Shimmer.fromColors(
                baseColor: MauSac.surfaceContainerHigh,
                highlightColor: MauSac.surfaceContainerHighest,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
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
                      children: List.generate(5, (index) => 
                        Column(
                          children: [
                            Shimmer.fromColors(
                              baseColor: MauSac.surfaceContainerHigh, 
                              highlightColor: MauSac.surfaceContainerHighest, 
                              child: Container(
                                width: 20, 
                                height: 40.0 + (index * 20), 
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))
                              )
                            ),
                            const SizedBox(height: 8),
                            Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 30, height: 10, color: Colors.white)),
                          ]
                        )
                      ),
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
                        Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 120, height: 16, color: Colors.white)),
                        Shimmer.fromColors(baseColor: MauSac.surfaceContainerHigh, highlightColor: MauSac.surfaceContainerHighest, child: Container(width: 48, height: 16, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) => 
                        Shimmer.fromColors(
                          baseColor: MauSac.surfaceContainerHigh, 
                          highlightColor: MauSac.surfaceContainerHighest, 
                          child: const CircleAvatar(radius: 14, backgroundColor: Colors.white)
                        )
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) => 
                        Shimmer.fromColors(
                          baseColor: MauSac.surfaceContainerHigh, 
                          highlightColor: MauSac.surfaceContainerHighest, 
                          child: const CircleAvatar(radius: 14, backgroundColor: Colors.white)
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
          'Ví tiền',
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
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                itemBuilder: (ctx, index) {
                  return Shimmer.fromColors(
                    baseColor: MauSac.surfaceContainerHigh,
                    highlightColor: MauSac.surfaceContainerHighest,
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: Container(width: 150, height: 24, color: Colors.white),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                return Shimmer.fromColors(
                  baseColor: MauSac.surfaceContainerHigh,
                  highlightColor: MauSac.surfaceContainerHighest,
                  child: Container(
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
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
          'Cài đặt',
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
