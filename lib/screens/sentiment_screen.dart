import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/sample_data.dart';
import '../widgets/common_widgets.dart';

class SentimentScreen extends StatefulWidget {
  const SentimentScreen({super.key});
  @override State<SentimentScreen> createState() => _SentimentScreenState();
}

class _SentimentScreenState extends State<SentimentScreen> {
  String _category = 'Forex';
  final _categories = ['Forex','Indices','Stocks','Crypto','Commodities','Futures'];

  List<SentimentData> get _filtered =>
      SampleData.sentiment.where((s) => s.category == _category).toList();

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
      case 'Forex':       return '💱';
      case 'Indices':     return '📈';
      case 'Stocks':      return '🏢';
      case 'Crypto':      return '₿';
      case 'Commodities': return '🛢️';
      case 'Futures':     return '🔮';
      default:            return '📊';
    }
  }

  String _sourceInfo(String cat) {
    switch (cat) {
      case 'Forex':       return 'Myfxbook community retail positioning';
      case 'Indices':     return 'IG Group retail client positioning data';
      case 'Stocks':      return 'Finviz analyst & retail sentiment data';
      case 'Crypto':      return 'Myfxbook & exchange order book data';
      case 'Commodities': return 'Myfxbook & broker positioning data';
      case 'Futures':     return 'CME Group open interest & positioning';
      default:            return 'Retail trader positioning';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;
    final color    = _catColor(_category);

    // Summary stats
    final bullishCount = filtered.where((s) => s.longPct > 50).length;
    final bearishCount = filtered.where((s) => s.longPct <= 50).length;
    final extremeCount = filtered.where((s) => s.longPct > 75 || s.longPct < 25).length;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader(label: 'Myfxbook · IG Group · CME · Finviz', title: 'Market', titleAccent: 'Sentiment'),

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
          const SizedBox(height: 14),

          // Info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(children: [
              Icon(Icons.people_alt_outlined, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(_sourceInfo(_category),
                  style: TextStyle(fontSize: 11, color: color))),
            ]),
          ),
          const SizedBox(height: 14),

          // Summary stats
          Row(children: [
            _MiniStat('${filtered.length}', 'Total', color),
            const SizedBox(width: 10),
            _MiniStat('$bullishCount', 'Bullish', AppColors.green),
            const SizedBox(width: 10),
            _MiniStat('$bearishCount', 'Bearish', AppColors.red),
            const SizedBox(width: 10),
            _MiniStat('$extremeCount', 'Extreme', AppColors.gold),
          ]),
          const SizedBox(height: 16),

          // Cards
          ...filtered.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SentimentCard(data: s, catColor: color),
          )),

          if (filtered.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('No sentiment data for $_category',
                  style: TextStyle(color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
            )),
        ]),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _MiniStat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
            color: color, fontFamily: 'monospace')),
        Text(label, style: TextStyle(fontSize: 10,
            color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
      ]),
    ));
  }
}

class _SentimentCard extends StatelessWidget {
  final SentimentData data;
  final Color catColor;
  const _SentimentCard({required this.data, required this.catColor});

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final isLongBias = data.longPct > 50;
    final isExtreme  = data.longPct > 75 || data.longPct < 25;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isExtreme ? AppColors.gold.withOpacity(0.5) : (isDark ? AppColors.navyBorder : AppColors.lightBorder)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(data.pair, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
              fontFamily: 'monospace', color: isDark ? AppColors.textDark : AppColors.textLight)),
          Row(children: [
            if (isExtreme) Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
              ),
              child: const Text('⚠️ EXTREME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.gold)),
            ),
            Text(data.source, style: TextStyle(fontSize: 10,
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
          ]),
        ]),
        const SizedBox(height: 10),

        // Combined bar
        Stack(children: [
          Container(height: 22, decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.25), borderRadius: BorderRadius.circular(6))),
          FractionallySizedBox(
            widthFactor: data.longPct / 100,
            child: Container(height: 22, decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.3), blurRadius: 8)],
            )),
          ),
          Positioned.fill(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${data.longPct.toStringAsFixed(1)}% LONG',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${data.shortPct.toStringAsFixed(1)}% SHORT',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
          ])),
        ]),
        const SizedBox(height: 8),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: isLongBias ? AppColors.green : AppColors.red)),
            Text('Bias: ${isLongBias ? "LONG" : "SHORT"}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: isLongBias ? AppColors.green : AppColors.red)),
          ]),
          Text('Retail Crowd',
              style: TextStyle(fontSize: 11, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
        ]),

        if (isExtreme) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.gold),
              const SizedBox(width: 6),
              Expanded(child: Text(
                isLongBias
                    ? 'Extreme long retail bias — smart money may be positioned SHORT (contrarian signal)'
                    : 'Extreme short retail bias — smart money may be positioned LONG (contrarian signal)',
                style: const TextStyle(fontSize: 11, color: AppColors.gold),
              )),
            ]),
          ),
        ],
      ]),
    );
  }
}