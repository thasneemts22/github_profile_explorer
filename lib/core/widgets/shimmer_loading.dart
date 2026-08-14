import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:github_profile_explorer/core/constants/app_colors.dart';

class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkBgTertiary : const Color(0xFFE1E4E8);
    final highlightColor = isDark ? const Color(0xFF30363D) : const Color(0xFFF0F2F5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ProfileSkeletonLoading extends StatelessWidget {
  const ProfileSkeletonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgSecondary : AppColors.lightBgPrimary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + Name Row
            Row(
              children: [
                const ShimmerSkeleton(
                  width: 72,
                  height: 72,
                  borderRadius: 36,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerSkeleton(width: 160, height: 20),
                      SizedBox(height: 8),
                      ShimmerSkeleton(width: 100, height: 14),
                      SizedBox(height: 8),
                      ShimmerSkeleton(width: 70, height: 16, borderRadius: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bio
            const ShimmerSkeleton(width: double.infinity, height: 14),
            const SizedBox(height: 6),
            const ShimmerSkeleton(width: 220, height: 14),
            const SizedBox(height: 20),

            // Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 72,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ShimmerSkeleton(width: double.infinity, height: double.infinity, borderRadius: 10),
                ShimmerSkeleton(width: double.infinity, height: double.infinity, borderRadius: 10),
                ShimmerSkeleton(width: double.infinity, height: double.infinity, borderRadius: 10),
                ShimmerSkeleton(width: double.infinity, height: double.infinity, borderRadius: 10),
              ],
            ),
            const SizedBox(height: 20),

            // Extra Info lines
            const ShimmerSkeleton(width: 180, height: 14),
            const SizedBox(height: 10),
            const ShimmerSkeleton(width: 220, height: 14),
            const SizedBox(height: 10),
            const ShimmerSkeleton(width: 150, height: 14),
            const SizedBox(height: 24),

            // Action Button
            const ShimmerSkeleton(
              width: double.infinity,
              height: 48,
              borderRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class RepoSkeletonLoading extends StatelessWidget {
  final int itemCount;

  const RepoSkeletonLoading({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const RepoSkeletonCard(),
    );
  }
}

class RepoSkeletonCard extends StatelessWidget {
  const RepoSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgSecondary : AppColors.lightBgPrimary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                ShimmerSkeleton(width: 160, height: 18),
                Spacer(),
                ShimmerSkeleton(width: 50, height: 18, borderRadius: 10),
              ],
            ),
            const SizedBox(height: 10),
            const ShimmerSkeleton(width: double.infinity, height: 13),
            const SizedBox(height: 6),
            const ShimmerSkeleton(width: 200, height: 13),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: const [
                ShimmerSkeleton(width: 70, height: 12),
                ShimmerSkeleton(width: 50, height: 12),
                ShimmerSkeleton(width: 50, height: 12),
                ShimmerSkeleton(width: 80, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
