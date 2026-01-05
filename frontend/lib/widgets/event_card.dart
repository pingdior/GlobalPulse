import 'package:flutter/material.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onSwipeRight;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          onSwipeRight?.call();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor,
              AppTheme.cardColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Heat indicator bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.getHeatColor(event.heatScore),
                        AppTheme.getHeatColor(event.heatScore).withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Heat score + Sentiment
                    Row(
                      children: [
                        _buildHeatBadge(),
                        const SizedBox(width: 8),
                        _buildSentimentBadge(),
                        const Spacer(),
                        _buildSourceIcon(),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Summary
                    Text(
                      event.summary,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Emotion tags
                    if (event.emotionTags.isNotEmpty) _buildEmotionTags(),
                    
                    const SizedBox(height: 12),
                    
                    // Swipe hint
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.swipe_right_alt,
                          color: Colors.white38,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '右滑查看详情',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeatBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.getHeatColor(event.heatScore).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getHeatColor(event.heatScore).withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: AppTheme.getHeatColor(event.heatScore),
          ),
          const SizedBox(width: 4),
          Text(
            '${event.heatScore}',
            style: TextStyle(
              color: AppTheme.getHeatColor(event.heatScore),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: event.sentimentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        event.sentimentLabel,
        style: TextStyle(
          color: event.sentimentColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSourceIcon() {
    final source = event.sources.isNotEmpty ? event.sources.first.platform : 'unknown';
    IconData icon;
    Color color;
    
    switch (source) {
      case 'weibo':
        icon = Icons.chat_bubble;
        color = const Color(0xFFE6162D);
        break;
      case 'twitter':
      case 'x':
        icon = Icons.alternate_email;
        color = Colors.white;
        break;
      default:
        icon = Icons.public;
        color = Colors.white54;
    }
    
    return Icon(icon, size: 20, color: color);
  }

  Widget _buildEmotionTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: event.emotionTags.take(4).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }
}
