import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Shimmer.fromColors(
        baseColor: AppTheme.cardColor,
        highlightColor: AppTheme.surfaceColor.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _buildBox(60, 24),
                  const SizedBox(width: 8),
                  _buildBox(40, 24),
                  const Spacer(),
                  _buildBox(24, 24),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              _buildBox(double.infinity, 24),
              const SizedBox(height: 8),
              _buildBox(200, 24),
              const SizedBox(height: 12),
              // Summary
              _buildBox(double.infinity, 16),
              const SizedBox(height: 6),
              _buildBox(double.infinity, 16),
              const SizedBox(height: 6),
              _buildBox(150, 16),
              const SizedBox(height: 16),
              // Tags
              Row(
                children: [
                  _buildBox(50, 20),
                  const SizedBox(width: 8),
                  _buildBox(50, 20),
                  const SizedBox(width: 8),
                  _buildBox(50, 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
