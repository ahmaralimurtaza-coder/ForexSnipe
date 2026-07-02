import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../services/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/sample_data.dart';
import '../widgets/common_widgets.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});
  @override State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _category  = 'Forex';
  String _sentiment = 'ALL';

  final _categories = ['Forex','Indices','Stocks','Crypto','Commodities','Futures'];
  final _sentiments = ['ALL','bullish','bearish','neutral'];

  List<NewsItem> _filteredFrom(List<NewsItem> source) {
    var list = source.where((n) => n.category == _category).toList();
    if (_sentiment != 'ALL') list = list.where((n) => n.sentiment == _sentiment).toList();
    return list;
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'Forex':       return AppColors.cyan;
      case 'Indices':     return AppColors.gold;
      case 'Stocks':      return AppColors.green;
      case 'Crypto':      return const Color(0xFFFF9800);
      case 'Commodities': return const Color(0xFFE040FB);
      case 'Futures':     return AppColors.red;
      default:            return AppColors.cyan;
    }
  }

  String _catEmoji(String cat) {
    switch (cat) {
      case 'Forex':       return '\u{1F4B1}';
      case 'Indices':     return '\u{1F4C8}';
      case 'Stocks':      return '\u{1F3E2}';
      case 'Crypto':      return '\u{20BF}';
      case 'Commodities': return '\u{1F6E2}';
      case 'Futures':     return '\u{1F52E}';
      default:            return '\u{1F4CA}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final dp       = context.watch<DataProvider>();
    final filtered = _filteredFrom(dp.news);
    final color    = _catColor(_category);

    return Scaffold(
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader(label: 'Reuters · Bloomberg · CoinDesk · CNBC', title: 'Market', titleAccent: 'News'),

            // Category chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final cat = _categories[i];
                  final sel = cat == _category;
                  final cc  = _catColor(cat);
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? cc.withOpacity(0.15) : (isDark ? AppColors.navyCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? cc : (isDark ? AppColors.navyBorder : AppColors.lightBorder)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(_catEmoji(cat), style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(cat, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: sel ? cc : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Sentiment filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _sentiments.map((s) {
                final sel = s == _sentiment;
                Color sc;
                switch (s) {
                  case 'bullish': sc = AppColors.green; break;
                  case 'bearish': sc = AppColors.red;   break;
                  case 'neutral': sc = AppColors.mutedDark; break;
                  default:        sc = color;
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _sentiment = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? sc.withOpacity(0.15) : (isDark ? AppColors.navyCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? sc : (isDark ? AppColors.navyBorder : AppColors.lightBorder)),
                      ),
                      child: Text(s.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: sel ? sc : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
                    ),
                  ),
                );
              }).toList()),
            ),
            const SizedBox(height: 12),
          ]),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text('No news for $_category',
              style: TextStyle(color: isDark ? AppColors.mutedDark : AppColors.mutedLight)))
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) => _NewsCard(item: filtered[i], catColor: _catColor(filtered[i].category)),
          ),
        ),
      ]),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem item;
  final Color catColor;
  const _NewsCard({required this.item, required this.catColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(item.url);
        if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.navyCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(item.source, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                  letterSpacing: 1, color: catColor)),
            ),
            Text(item.timeAgo, style: TextStyle(fontSize: 11,
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
          ]),
          const SizedBox(height: 10),
          Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.5)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SentimentBadge(sentiment: item.sentiment),
            Icon(Icons.open_in_new, size: 14,
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: item.pairs.map((p) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.navyCard2 : AppColors.lightCard2,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
            ),
            child: Text(p, style: TextStyle(fontSize: 10, fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
          )).toList()),
        ]),
      ),
    );
  }
}







