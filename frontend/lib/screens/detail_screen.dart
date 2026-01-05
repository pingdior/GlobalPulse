import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class DetailScreen extends StatelessWidget {
  final Event event;

  const DetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.getHeatColor(event.heatScore).withOpacity(0.3),
                      AppTheme.backgroundColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Heat & Sentiment badges
                        Row(
                          children: [
                            _buildHeatBadge(),
                            const SizedBox(width: 8),
                            _buildSentimentBadge(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary section
                  _buildSection(
                    context,
                    icon: Icons.summarize,
                    title: '事件摘要',
                    child: Text(
                      event.summary,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Emotion spectrum
                  if (event.emotionTags.isNotEmpty)
                    _buildSection(
                      context,
                      icon: Icons.emoji_emotions,
                      title: '情绪光谱',
                      child: _buildEmotionSpectrum(context),
                    ),

                  const SizedBox(height: 24),

                  // Source info
                  _buildSection(
                    context,
                    icon: Icons.source,
                    title: '信息来源',
                    child: _buildSourceList(context),
                  ),

                  const SizedBox(height: 24),

                  // Keywords
                  if (event.keywords.isNotEmpty)
                    _buildSection(
                      context,
                      icon: Icons.tag,
                      title: '关键词',
                      child: _buildKeywords(context),
                    ),

                  const SizedBox(height: 32),

                  // Action buttons
                  _buildActionButtons(context),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.getHeatColor(event.heatScore).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getHeatColor(event.heatScore).withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 18,
            color: AppTheme.getHeatColor(event.heatScore),
          ),
          const SizedBox(width: 6),
          Text(
            '热度 ${event.heatScore}',
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: event.sentimentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        event.sentimentLabel,
        style: TextStyle(
          color: event.sentimentColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.accentColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.accentColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildEmotionSpectrum(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: event.emotionTags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.3),
                AppTheme.accentColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSourceList(BuildContext context) {
    if (event.sources.isEmpty) {
      return Text(
        '暂无来源信息',
        style: TextStyle(color: Colors.white54),
      );
    }

    return Column(
      children: event.sources.map((source) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _getSourceIcon(source.platform),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSourceName(source.platform),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (source.author != null)
                      Text(
                        source.author!,
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                  ],
                ),
              ),
              InkWell(
                onTap: source.url != null ? () => _launchUrl(source.url!) : null,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.open_in_new, 
                    size: 18, 
                    color: source.url != null ? Colors.white38 : Colors.white10
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _getSourceIcon(String platform) {
    IconData icon;
    Color color;

    switch (platform) {
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

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  String _getSourceName(String platform) {
    switch (platform) {
      case 'weibo':
        return '微博';
      case 'twitter':
      case 'x':
        return 'X (Twitter)';
      case 'reddit':
        return 'Reddit';
      default:
        return platform;
    }
  }

  Widget _buildKeywords(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: event.keywords.map((keyword) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '#$keyword',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement share
            },
            icon: const Icon(Icons.share),
            label: const Text('分享'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showComparisonDialog(context);
            },
            icon: const Icon(Icons.compare_arrows),
            label: const Text('跨区对比'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _showComparisonDialog(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final api = context.read<ApiService>();
      final result = await api.compareEvent(event.title, event.summary);
      
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: const Text('跨区舆情对比分析', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompareItem('🇨🇳 国内观点', result['domestic_view'] ?? '暂无'),
                const SizedBox(height: 16),
                _buildCompareItem('🌍 国际视角', result['international_view'] ?? '暂无'),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                _buildCompareItem('⚡ 核心差异', result['difference_point'] ?? '暂无', isHighlight: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分析失败: $e')),
      );
    }
  }

  Widget _buildCompareItem(String title, String content, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: isHighlight ? AppTheme.accentColor : Colors.white70,
            fontSize: 14,
          )
        ),
        const SizedBox(height: 4),
        Text(
          content, 
          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4)
        ),
      ],
    );
  }
}
