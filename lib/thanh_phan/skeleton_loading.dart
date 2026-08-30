import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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
        title: Row(
          children: [
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: const CircleAvatar(radius: 18, backgroundColor: Colors.white),
            ),
            const SizedBox(width: 10),
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: Container(width: 100, height: 20, color: Colors.white),
            ),
          ],
        ),
        actions: [
          Shimmer.fromColors(
            baseColor: MauSac.surfaceContainerHigh,
            highlightColor: MauSac.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(radius: 16, backgroundColor: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome msg skeleton
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: Container(width: 200, height: 26, color: Colors.white),
            ),
            const SizedBox(height: 16),
            
            // Balance card skeleton
            Shimmer.fromColors(
              baseColor: MauSac.surfaceContainerHigh,
              highlightColor: MauSac.surfaceContainerHighest,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick actions bar skeleton
            Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: MauSac.surfaceContainerHigh,
                    highlightColor: MauSac.surfaceContainerHighest,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: MauSac.surfaceContainerHigh,
                    highlightColor: MauSac.surfaceContainerHighest,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Transactions header skeleton
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
                  child: Container(width: 70, height: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recent Transactions List skeleton
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (ctx, i) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                return Shimmer.fromColors(
                  baseColor: MauSac.surfaceContainerHigh,
                  highlightColor: MauSac.surfaceContainerHighest,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
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
