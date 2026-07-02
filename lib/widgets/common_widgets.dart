import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_theme.dart';

class GlowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? glowColor;
  const GlowCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.glowColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glowColor?.withOpacity(0.3) ?? (isDark ? AppColors.navyBorder : AppColors.lightBorder)),
        boxShadow: glowColor != null ? [BoxShadow(color: glowColor!.withOpacity(0.08), blurRadius: 20, spreadRadius: 2)] : null,
      ),
      child: child,
    );
  }
}

class SparkLine extends StatelessWidget {
  final List<double> data;
  final bool isUp;
  final double width, height;
  const SparkLine({super.key, required this.data, required this.isUp, this.width = 80, this.height = 30});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(width: width, height: height);
    return SizedBox(width: width, height: height,
      child: CustomPaint(painter: _SparkPainter(data: data, isUp: isUp)));
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> data;
  final bool isUp;
  _SparkPainter({required this.data, required this.isUp});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final mn = data.reduce(min), mx = data.reduce(max), rng = mx - mn == 0 ? 1.0 : mx - mn;
    final col = isUp ? AppColors.green : AppColors.red;
    final pts = data.asMap().entries.map((e) => Offset(e.key / (data.length - 1) * size.width, (1 - (e.value - mn) / rng) * size.height)).toList();
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    canvas.drawPath(path, Paint()..color = col..strokeWidth = 1.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    final fill = Path()..addPath(path, Offset.zero)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(fill, Paint()..color = col.withOpacity(0.08)..style = PaintingStyle.fill);
  }

  @override bool shouldRepaint(_SparkPainter old) => old.data != data;
}

class LiveDot extends StatefulWidget {
  const LiveDot({super.key});
  @override State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true); _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _a, builder: (_, __) => Container(width: 8, height: 8,
    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.green, boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.6 * _a.value), blurRadius: 6 * _a.value, spreadRadius: 1)])));
}

class SectionHeader extends StatelessWidget {
  final String label, title, titleAccent;
  const SectionHeader({super.key, required this.label, required this.title, required this.titleAccent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w600, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
      const SizedBox(height: 4),
      RichText(text: TextSpan(style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2), children: [
        TextSpan(text: ' ', style: TextStyle(color: isDark ? AppColors.textDark : AppColors.textLight)),
        TextSpan(text: titleAccent, style: TextStyle(color: AppColors.green)),
      ])),
      const SizedBox(height: 14),
    ]);
  }
}

class CurrencyTag extends StatelessWidget {
  final String currency;
  const CurrencyTag({super.key, required this.currency});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: AppColors.cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.cyan.withOpacity(0.3))),
      child: Text(currency, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.cyan, fontFamily: 'monospace')));
  }
}

class ImpactBadge extends StatelessWidget {
  final String impact;
  const ImpactBadge({super.key, required this.impact});
  @override
  Widget build(BuildContext context) {
    Color c;
    switch (impact) {
      case 'HIGH': c = AppColors.red; break;
      case 'MED':  c = AppColors.gold; break;
      default:     c = AppColors.mutedDark;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: c.withOpacity(0.4))),
      child: Text(impact, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: c, letterSpacing: 0.5)));
  }
}

class SentimentBadge extends StatelessWidget {
  final String sentiment;
  const SentimentBadge({super.key, required this.sentiment});
  @override
  Widget build(BuildContext context) {
    Color c; String e;
    switch (sentiment) {
      case 'bullish': c = AppColors.green; e = '▲ BULLISH'; break;
      case 'bearish': c = AppColors.red;   e = '▼ BEARISH'; break;
      default:        c = AppColors.mutedDark; e = '● NEUTRAL';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: c.withOpacity(0.3))),
      child: Text(e, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c, letterSpacing: 0.5)));
  }
}

class CotBar extends StatelessWidget {
  final String label;
  final int value;
  final double fraction;
  final Color color;
  const CotBar({super.key, required this.label, required this.value, required this.fraction, required this.color});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safe = fraction.clamp(0.0, 1.0);
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
        Text(value >= 0 ? '+' + _fmt(value) : _fmt(value), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: value >= 0 ? AppColors.green : AppColors.red)),
      ]),
      const SizedBox(height: 4),
      Stack(children: [
        Container(height: 6, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(3))),
        FractionallySizedBox(widthFactor: safe, child: Container(height: 6, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3), boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)]))),
      ]),
    ]));
  }
  String _fmt(int v) { if (v.abs() >= 1000000) return '${(v/1000000).toStringAsFixed(1)}M'; if (v.abs() >= 1000) return '${(v/1000).toStringAsFixed(1)}K'; return v.toString(); }
}

