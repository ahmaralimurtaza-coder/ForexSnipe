import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlowCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final EdgeInsets? padding;
  final double radius;

  const GlowCard({super.key, required this.child, this.glowColor, this.padding, this.radius = 14});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
        boxShadow: glowColor != null ? [
          BoxShadow(color: glowColor!.withOpacity(0.12), blurRadius: 20, spreadRadius: 2),
        ] : null,
      ),
      child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String label;
  final String title;
  final String? titleAccent;

  const SectionHeader({super.key, required this.label, required this.title, this.titleAccent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: TextStyle(
        fontSize: 10, letterSpacing: 2.5, fontWeight: FontWeight.w700,
        color: isDark ? AppColors.cyan : const Color(0xFF0088AA),
      )),
      const SizedBox(height: 6),
      RichText(text: TextSpan(
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3,
            color: isDark ? AppColors.textDark : AppColors.textLight),
        children: [
          TextSpan(text: title),
          if (titleAccent != null)
            TextSpan(text: ' $titleAccent',
                style: TextStyle(color: isDark ? AppColors.gold : const Color(0xFFCC8800))),
        ],
      )),
      const SizedBox(height: 20),
    ]);
  }
}

class ImpactBadge extends StatelessWidget {
  final String impact;
  const ImpactBadge({super.key, required this.impact});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (impact) {
      case 'HIGH': color = AppColors.red;  break;
      case 'MED':  color = AppColors.gold; break;
      default:     color = AppColors.mutedDark;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(impact, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 1)),
    );
  }
}

class CurrencyTag extends StatelessWidget {
  final String currency;
  const CurrencyTag({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cyanDim : const Color(0x220088AA),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isDark ? AppColors.cyan.withOpacity(0.3) : const Color(0x440088AA)),
      ),
      child: Text(currency, style: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1,
        fontFamily: 'monospace',
        color: isDark ? AppColors.cyan : const Color(0xFF0088AA),
      )),
    );
  }
}

class SentimentBadge extends StatelessWidget {
  final String sentiment;
  const SentimentBadge({super.key, required this.sentiment});

  @override
  Widget build(BuildContext context) {
    Color color; String label; IconData icon;
    switch (sentiment) {
      case 'bullish': color = AppColors.green; label = 'BULLISH'; icon = Icons.trending_up;   break;
      case 'bearish': color = AppColors.red;   label = 'BEARISH'; icon = Icons.trending_down; break;
      default:        color = AppColors.mutedDark; label = 'NEUTRAL'; icon = Icons.remove;    break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 1)),
      ]),
    );
  }
}

class LiveDot extends StatefulWidget {
  const LiveDot({super.key});
  @override State<LiveDot> createState() => _LiveDotState();
}
class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _a = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    FadeTransition(opacity: _a, child: Container(
      width: 7, height: 7,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.green,
          boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.6), blurRadius: 6)]),
    )),
    const SizedBox(width: 5),
    Text('LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.green, letterSpacing: 1.5)),
  ]);
}

class SparkLine extends StatelessWidget {
  final List<double> data;
  final bool isUp;
  final double width;
  final double height;

  const SparkLine({super.key, required this.data, required this.isUp, this.width = 80, this.height = 32});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: width, height: height, child: CustomPaint(painter: _SparkPainter(data: data, isUp: isUp)));
}

class _SparkPainter extends CustomPainter {
  final List<double> data;
  final bool isUp;
  _SparkPainter({required this.data, required this.isUp});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = max - min == 0 ? 1.0 : max - min;
    final color = isUp ? AppColors.green : AppColors.red;
    final paint = Paint()..color = color..strokeWidth = 1.8..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - ((data[i] - min) / range * size.height);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override bool shouldRepaint(_SparkPainter old) => old.data != data;
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppColors.mutedDark : AppColors.mutedLight))),
        Text(value >= 0 ? '+${_fmt(value)}' : _fmt(value),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, fontFamily: 'monospace')),
      ]),
      const SizedBox(height: 5),
      Container(
        height: 7,
        decoration: BoxDecoration(color: isDark ? AppColors.navyCard2 : AppColors.lightCard2, borderRadius: BorderRadius.circular(4)),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction.clamp(0.0, 1.0),
          child: Container(decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4), color: color,
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)],
          )),
        ),
      ),
      const SizedBox(height: 14),
    ]);
  }

  String _fmt(int v) {
    final abs = v.abs();
    if (abs >= 1000) return '${(abs / 1000).toStringAsFixed(1)}K';
    return abs.toString();
  }
}