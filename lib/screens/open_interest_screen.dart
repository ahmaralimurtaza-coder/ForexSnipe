import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class OpenInterestScreen extends StatefulWidget {
  const OpenInterestScreen({super.key});
  @override State<OpenInterestScreen> createState() => _OpenInterestScreenState();
}

class _OpenInterestScreenState extends State<OpenInterestScreen> {
  String _category = 'All';
  final _categories = ['All','Forex','Indices','Stocks','Crypto','Commodities','Futures'];

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

  String _fmtOI(int oi) {
    if (oi >= 1000000) return '${(oi / 1000000).toStringAsFixed(2)}M';
    if (oi >= 1000) return '${(oi / 1000).toStringAsFixed(1)}K';
    return '$oi';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dp     = context.watch<DataProvider>();
    final all    = dp.cotData;

    final filtered = (_category == 'All' ? all : all.where((c) => c.category == _category).toList())
      ..sort((a, b) => b.openInterest.compareTo(a.openInterest));

    final totalOI = filtered.fold<int>(0, (sum, c) => sum + c.openInterest);
    final topInstrument = filtered.isNotEmpty ? filtered.first : null;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          const SectionHeader(label: 'CFTC.gov . CME Group', title: 'Open', titleAccent: 'Interest'),
          const SizedBox(height: 14),

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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? cc.withOpacity(0.15) : (isDark ? AppColors.navyCard : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? cc : (isDark ? AppColors.navyBorder : AppColors.lightBorder)),
                    ),
                    child: Text(cat, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: sel ? cc : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          Row(children: [
            Expanded(child: _StatCard(label: 'Total OI', value: _fmtOI(totalOI), color: AppColors.cyan)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(label: 'Instruments', value: '${filtered.length}', color: AppColors.gold)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(label: 'Top', value: topInstrument?.pair ?? '-', color: AppColors.green, small: true)),
          ]),
          const SizedBox(height: 16),

          if (filtered.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('No open interest data for $_category',
                  style: TextStyle(color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
            ))
          else
            ...filtered.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OiCard(data: c, color: _catColor(c.category)),
            )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool small;
  const _StatCard({required this.label, required this.value, required this.color, this.small = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: small ? 13 : 17, fontWeight: FontWeight.w900,
                color: color, fontFamily: 'monospace')),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 10,
            color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
      ]),
    );
  }
}

class _OiCard extends StatelessWidget {
  final CotData data;
  final Color color;
  const _OiCard({required this.data, required this.color});

  String _fmtOICompact(int oi) {
    if (oi >= 1000000) return '${(oi / 1000000).toStringAsFixed(2)}M';
    if (oi >= 1000) return '${(oi / 1000).toStringAsFixed(1)}K';
    return '$oi';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Total long always equals total short in any futures market (zero-sum),
    // so we show Non-Commercial (speculator) positioning instead - the
    // meaningful signal, same approach the COT tab uses.
    final ncTotal = data.nonCommercialLong + data.nonCommercialShort;
    final longPct = ncTotal > 0 ? data.nonCommercialLong / ncTotal : 0.5;

    return GlowCard(
      glowColor: color,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Text(data.pair, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                fontFamily: 'monospace', color: isDark ? AppColors.textDark : AppColors.textLight)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(data.category, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
            ),
          ]),
          Text(_fmtOICompact(data.openInterest), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
              color: color, fontFamily: 'monospace')),
        ]),
        const SizedBox(height: 4),
        Text('Week ending ${data.weekEnding}', style: TextStyle(fontSize: 10.5,
            color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            child: Row(children: [
              Expanded(flex: (longPct * 100).round().clamp(1, 99), child: Container(color: AppColors.green)),
              Expanded(flex: 100 - (longPct * 100).round().clamp(1, 99), child: Container(color: AppColors.red)),
            ]),
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Spec. Long ${(longPct * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 10.5, color: AppColors.green, fontWeight: FontWeight.w700)),
          Text('Spec. Short ${(100 - longPct * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 10.5, color: AppColors.red, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }
}




