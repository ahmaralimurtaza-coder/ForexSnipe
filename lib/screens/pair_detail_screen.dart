import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class PairDetailScreen extends StatelessWidget {
  final ForexPair pair;
  const PairDetailScreen({super.key, required this.pair});

  String _fmt(double p) {
    if (p >= 10000) return p.toStringAsFixed(2);
    if (p >= 100)   return p.toStringAsFixed(2);
    if (p >= 1)     return p.toStringAsFixed(4);
    return p.toStringAsFixed(5);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = _catColor(pair.category);
    final up     = pair.isUp;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text(pair.flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(pair.pair, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Big price card
          GlowCard(
            glowColor: color,
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(pair.category.toUpperCase(),
                    style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: color, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(_fmt(pair.price),
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: color)),
                  Row(children: [
                    Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: up ? AppColors.green : AppColors.red, size: 22),
                    Text(' (%)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: up ? AppColors.green : AppColors.red)),
                  ]),
                ]),
                const LiveDot(),
              ]),
              const SizedBox(height: 16),
              SizedBox(height: 80, width: double.infinity,
                child: SparkLine(data: pair.spark, isUp: up, width: 320, height: 80)),
            ]),
          ),

          const SizedBox(height: 16),

          // Stats grid
          GlowCard(padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('STATISTICS', style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w700,
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
              const SizedBox(height: 12),
              _StatRow('Current Price', _fmt(pair.price)),
              _StatRow('Change', ''),
              _StatRow('% Change', '%'),
              _StatRow('Direction', up ? 'BULLISH ▲' : 'BEARISH ▼'),
              _StatRow('Category', pair.category),
              if (pair.spark.isNotEmpty) ...[
                _StatRow('Period High', _fmt(pair.spark.reduce((a,b) => a>b?a:b))),
                _StatRow('Period Low',  _fmt(pair.spark.reduce((a,b) => a<b?a:b))),
              ],
            ]),
          ),

          const SizedBox(height: 16),

          // Quick analysis card
          GlowCard(glowColor: up ? AppColors.green : AppColors.red, padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(up ? Icons.trending_up : Icons.trending_down,
                  color: up ? AppColors.green : AppColors.red, size: 18),
                const SizedBox(width: 8),
                Text('QUICK READ', style: TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700,
                  color: up ? AppColors.green : AppColors.red)),
              ]),
              const SizedBox(height: 10),
              Text(
                up
                  ? ' is trading higher, up % in the current session. '
                    'Momentum favors buyers — watch for continuation above recent highs or a pullback to support.'
                  : ' is trading lower, down % in the current session. '
                    'Momentum favors sellers — watch for continuation below recent lows or a bounce to resistance.',
                style: TextStyle(fontSize: 13, height: 1.6, color: isDark ? AppColors.textDark : AppColors.textLight),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // Trading levels (estimated from spark data)
          if (pair.spark.length >= 3)
            GlowCard(padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('KEY LEVELS', style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
                const SizedBox(height: 12),
                _LevelRow('Resistance', _fmt(pair.spark.reduce((a,b) => a>b?a:b) * 1.002), AppColors.red),
                _LevelRow('Current',    _fmt(pair.price), color),
                _LevelRow('Support',    _fmt(pair.spark.reduce((a,b) => a<b?a:b) * 0.998), AppColors.green),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  const _StatRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
      ]));
  }
}

class _LevelRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _LevelRow(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: color)),
      ]));
  }
}
