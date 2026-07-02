import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});
  @override State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _section = 'Candlesticks';
  final _sections = ['Candlesticks', 'Chart Patterns', 'Support/Resistance', 'Indicators'];

  Color _catColor(String s) {
    switch (s) {
      case 'Candlesticks':        return AppColors.green;
      case 'Chart Patterns':      return AppColors.cyan;
      case 'Support/Resistance':  return AppColors.gold;
      case 'Indicators':          return const Color(0xFFFF9800);
      default:                    return AppColors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = _catColor(_section);
    return Scaffold(
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16,16,16,8),
          child: SizedBox(height: 40, child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _sections.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final s   = _sections[i];
              final sel = s == _section;
              final cc  = _catColor(s);
              return GestureDetector(
                onTap: () => setState(() => _section = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: sel ? cc.withOpacity(0.15) : (isDark ? AppColors.navyCard : AppColors.lightCard),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? cc : (isDark ? AppColors.navyBorder : AppColors.lightBorder)),
                  ),
                  alignment: Alignment.center,
                  child: Text(s, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: sel ? cc : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
                ),
              );
            },
          )),
        ),
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(16,0,16,16),
          children: _lessonsFor(_section, color, isDark),
        )),
      ]),
    );
  }

  List<Widget> _lessonsFor(String section, Color color, bool isDark) {
    switch (section) {
      case 'Candlesticks':       return _candlestickLessons(color, isDark);
      case 'Chart Patterns':     return _chartPatternLessons(color, isDark);
      case 'Support/Resistance': return _supportResistanceLessons(color, isDark);
      case 'Indicators':         return _indicatorLessons(color, isDark);
      default: return [];
    }
  }

  List<Widget> _candlestickLessons(Color color, bool isDark) {
    return [
      LessonCard(color: color, isDark: isDark,
        title: 'Doji', emoji: '\u{1F56F}\u{FE0F}',
        desc: 'Open and close are nearly equal, creating a tiny or no body with wicks on both sides. Signals market indecision \u2014 neither buyers nor sellers are in control. Often appears before a reversal, especially after a strong trend.',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: SingleCandlePainter(open: 50, close: 51, high: 75, low: 25, color: color))),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'Hammer', emoji: '\u{1F528}',
        desc: 'Small body near the top, with a long lower wick (at least 2x the body) and little to no upper wick. Appears at the bottom of a downtrend \u2014 sellers pushed price down, but buyers stepped in hard and pushed it back up. Bullish reversal signal.',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: SingleCandlePainter(open: 60, close: 68, high: 70, low: 15, color: AppColors.green))),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'Shooting Star', emoji: '\u{1F320}',
        desc: 'Small body near the bottom, with a long upper wick and little to no lower wick. Appears at the top of an uptrend \u2014 buyers pushed price up, but sellers overwhelmed them and pushed it back down. Bearish reversal signal.',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: SingleCandlePainter(open: 40, close: 32, high: 85, low: 30, color: AppColors.red))),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'Bullish Engulfing', emoji: '\u{1F4C8}',
        desc: 'A small red (bearish) candle is immediately followed by a larger green (bullish) candle that completely engulfs the previous candle\u2019s body. Shows buyers have overwhelmed sellers \u2014 a strong reversal signal, especially after a downtrend.',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: EngulfingPatternPainter(bullish: true))),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'Bearish Engulfing', emoji: '\u{1F4C9}',
        desc: 'A small green (bullish) candle is immediately followed by a larger red (bearish) candle that completely engulfs the previous candle\u2019s body. Shows sellers have overwhelmed buyers \u2014 a strong reversal signal, especially after an uptrend.',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: EngulfingPatternPainter(bullish: false))),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'Pin Bar', emoji: '\u{1F4CC}',
        desc: 'A candle with a very long wick (upper or lower) and a small body near one end, showing a strong rejection of a price level. The long wick shows price tried to go one way but was firmly rejected. Most reliable when it forms at a key support or resistance level.',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: SingleCandlePainter(open: 55, close: 62, high: 65, low: 10, color: AppColors.green))),
      ),
    ];
  }

  List<Widget> _chartPatternLessons(Color color, bool isDark) {
    return [
      LessonCard(color: color, isDark: isDark,
        title: 'Head & Shoulders', emoji: '\u{1F4CA}',
        desc: 'Three peaks: a left shoulder, a higher middle peak (the head), and a right shoulder roughly equal to the left. The "neckline" connects the two troughs. A break below the neckline signals a bearish reversal after an uptrend. The inverse (Inverse H&S) signals a bullish reversal after a downtrend.',
        chart: SizedBox(height: 130, width: double.infinity,
          child: CustomPaint(painter: HeadShouldersPainter(inverse: false))),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'Double Top', emoji: '\u{1F53A}',
        desc: 'Price hits a resistance level twice, forming two peaks at roughly the same height with a trough between them ("M" shape). Failure to break above resistance the second time signals exhausted buying pressure \u2014 a bearish reversal signal once the trough/neckline breaks.',
        chart: SizedBox(height: 130, width: double.infinity,
          child: CustomPaint(painter: DoubleTopBottomPainter(isTop: true))),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'Double Bottom', emoji: '\u{1F53B}',
        desc: 'Price hits a support level twice, forming two troughs at roughly the same level with a peak between them ("W" shape). Failure to break below support the second time signals exhausted selling pressure \u2014 a bullish reversal signal once the peak/neckline breaks.',
        chart: SizedBox(height: 130, width: double.infinity,
          child: CustomPaint(painter: DoubleTopBottomPainter(isTop: false))),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'Ascending Triangle', emoji: '\u{1F53A}',
        desc: 'A flat resistance line on top with a rising trendline of higher lows underneath. Shows buyers becoming more aggressive while sellers defend a fixed level. Usually breaks upward \u2014 a bullish continuation pattern. Volume often contracts during formation, then expands on breakout.',
        chart: SizedBox(height: 130, width: double.infinity,
          child: CustomPaint(painter: TrianglePainter(ascending: true))),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'Descending Triangle', emoji: '\u{1F53B}',
        desc: 'A flat support line on the bottom with a falling trendline of lower highs above. Shows sellers becoming more aggressive while buyers defend a fixed level. Usually breaks downward \u2014 a bearish continuation pattern.',
        chart: SizedBox(height: 130, width: double.infinity,
          child: CustomPaint(painter: TrianglePainter(ascending: false))),
      ),
    ];
  }

  List<Widget> _supportResistanceLessons(Color color, bool isDark) {
    return [
      LessonCard(color: color, isDark: isDark,
        title: 'Support Level', emoji: '\u{1F6E1}\u{FE0F}',
        desc: 'A price level where buying pressure has historically been strong enough to stop a decline and push price back up. Think of it as a "floor". The more times price touches and bounces off a level, the stronger that support is considered.',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: SupportResistancePainter(isSupport: true))),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'Resistance Level', emoji: '\u{1F6A7}',
        desc: 'A price level where selling pressure has historically been strong enough to stop a rally and push price back down. Think of it as a "ceiling". Once resistance breaks decisively, it often flips and becomes new support \u2014 known as role reversal.',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: SupportResistancePainter(isSupport: false))),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'Role Reversal', emoji: '\u{1F504}',
        desc: 'When a resistance level is broken, it often becomes a new support level (and vice versa for support becoming resistance). This happens because traders who missed the breakout look to buy on the retest of the old resistance, now acting as a floor.',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: RoleReversalPainter())),
      ),
    ];
  }

  List<Widget> _indicatorLessons(Color color, bool isDark) {
    return [
      LessonCard(color: color, isDark: isDark,
        title: 'Moving Average (MA)', emoji: '\u{1F4C9}',
        desc: 'A line that smooths price by averaging the last N periods (e.g. 50-period or 200-period MA). Price above a rising MA = uptrend bias. Price below a falling MA = downtrend bias. When a short MA crosses above a long MA, it\u2019s called a "Golden Cross" (bullish); the opposite is a "Death Cross" (bearish).',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: MovingAveragePainter())),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'RSI (Relative Strength Index)', emoji: '\u{2696}\u{FE0F}',
        desc: 'A momentum oscillator ranging 0-100. Above 70 = overbought (potential pullback). Below 30 = oversold (potential bounce). Divergence \u2014 when price makes a new high/low but RSI doesn\u2019t \u2014 is a powerful early reversal warning signal.',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: RsiPainter())),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'MACD', emoji: '\u{1F4D0}',
        desc: 'Moving Average Convergence Divergence \u2014 shows the relationship between two moving averages (typically 12 and 26 period EMAs) plus a signal line (9-period EMA of the MACD line). When MACD crosses above the signal line, it\u2019s a bullish signal; crossing below is bearish. The histogram shows the strength of momentum.',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: MacdPainter())),
      ),
      LessonCard(color: color, isDark: isDark,
        title: 'Bollinger Bands', emoji: '\u{1F3D2}',
        desc: 'A middle moving average band with two outer bands set at a standard deviation distance above and below. Bands widen during high volatility and contract during low volatility ("the squeeze"). Price touching the outer bands often signals overextension, while a squeeze often precedes a big breakout move.',
        chart: SizedBox(height: 120, width: double.infinity,
          child: CustomPaint(painter: BollingerPainter())),
      ),
    ];
  }
}

class LessonCard extends StatelessWidget {
  final Color color;
  final bool isDark;
  final String title, emoji, desc;
  final Widget chart;
  const LessonCard({required this.color, required this.isDark, required this.title,
    required this.emoji, required this.desc, required this.chart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textDark : AppColors.textLight))),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.navy : AppColors.lightBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: chart,
        ),
        const SizedBox(height: 10),
        Text(desc, style: TextStyle(fontSize: 13, height: 1.5,
          color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
      ]),
    );
  }
}

class SingleCandlePainter extends CustomPainter {
  final double open, close, high, low;
  final Color color;
  SingleCandlePainter({required this.open, required this.close, required this.high,
    required this.low, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    double toY(double v) => size.height - (v / 100 * size.height);
    final wickPaint = Paint()..color = color..strokeWidth = 2;
    canvas.drawLine(Offset(cx, toY(high)), Offset(cx, toY(low)), wickPaint);
    final top = toY(open > close ? open : close);
    final bot = toY(open > close ? close : open);
    final bodyH = (bot - top).abs().clamp(3.0, size.height);
    canvas.drawRect(
      Rect.fromLTWH(cx - 16, top, 32, bodyH),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EngulfingPatternPainter extends CustomPainter {
  final bool bullish;
  EngulfingPatternPainter({required this.bullish});

  @override
  void paint(Canvas canvas, Size size) {
    double toY(double v) => size.height - (v / 100 * size.height);
    final smallColor = bullish ? AppColors.red : AppColors.green;
    final bigColor    = bullish ? AppColors.green : AppColors.red;

    final cx1 = size.width * 0.35;
    final cx2 = size.width * 0.65;

    final smallTop = bullish ? toY(58) : toY(42);
    final smallBot = bullish ? toY(50) : toY(50);
    canvas.drawLine(Offset(cx1, toY(62)), Offset(cx1, toY(46)), Paint()..color = smallColor..strokeWidth = 2);
    canvas.drawRect(Rect.fromLTWH(cx1 - 14, smallTop, 28, (smallBot - smallTop).abs().clamp(4.0, size.height)),
      Paint()..color = smallColor);

    final bigTop = bullish ? toY(75) : toY(25);
    final bigBot = bullish ? toY(38) : toY(62);
    canvas.drawLine(Offset(cx2, toY(80)), Offset(cx2, toY(20)), Paint()..color = bigColor..strokeWidth = 2);
    canvas.drawRect(Rect.fromLTWH(cx2 - 18, bigTop, 36, (bigBot - bigTop).abs().clamp(4.0, size.height)),
      Paint()..color = bigColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeadShouldersPainter extends CustomPainter {
  final bool inverse;
  HeadShouldersPainter({required this.inverse});

  @override
  void paint(Canvas canvas, Size size) {
    final pts = [
      Offset(0, 0.55), Offset(0.15, 0.25), Offset(0.3, 0.55),
      Offset(0.5, 0.05), Offset(0.7, 0.55), Offset(0.85, 0.25), Offset(1.0, 0.55),
    ];
    final mapped = pts.map((p) => Offset(
      p.dx * size.width,
      inverse ? p.dy * size.height : (1 - p.dy) * size.height,
    )).toList();

    final path = Path()..moveTo(mapped[0].dx, mapped[0].dy);
    for (final p in mapped.skip(1)) { path.lineTo(p.dx, p.dy); }
    canvas.drawPath(path, Paint()..color = AppColors.cyan..style = PaintingStyle.stroke..strokeWidth = 2.5);

    final neckY = inverse ? mapped[2].dy : mapped[2].dy;
    canvas.drawLine(Offset(mapped[1].dx, neckY), Offset(mapped[5].dx, neckY),
      Paint()..color = AppColors.gold..strokeWidth = 1.5..style = PaintingStyle.stroke);

    for (final p in mapped) {
      canvas.drawCircle(p, 3, Paint()..color = AppColors.cyan);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DoubleTopBottomPainter extends CustomPainter {
  final bool isTop;
  DoubleTopBottomPainter({required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    final pts = [
      Offset(0, 0.6), Offset(0.25, 0.1), Offset(0.5, 0.6),
      Offset(0.75, 0.1), Offset(1.0, 0.6),
    ];
    final mapped = pts.map((p) => Offset(
      p.dx * size.width,
      isTop ? p.dy * size.height : (1 - p.dy) * size.height,
    )).toList();

    final path = Path()..moveTo(mapped[0].dx, mapped[0].dy);
    for (final p in mapped.skip(1)) { path.lineTo(p.dx, p.dy); }
    canvas.drawPath(path, Paint()..color = isTop ? AppColors.red : AppColors.green
      ..style = PaintingStyle.stroke..strokeWidth = 2.5);

    canvas.drawLine(Offset(mapped[0].dx, mapped[2].dy), Offset(mapped[4].dx, mapped[2].dy),
      Paint()..color = AppColors.gold..strokeWidth = 1.5..style = PaintingStyle.stroke);

    for (final p in mapped) {
      canvas.drawCircle(p, 3, Paint()..color = isTop ? AppColors.red : AppColors.green);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrianglePainter extends CustomPainter {
  final bool ascending;
  TrianglePainter({required this.ascending});

  @override
  void paint(Canvas canvas, Size size) {
    final flatY = ascending ? size.height * 0.15 : size.height * 0.85;
    canvas.drawLine(Offset(0, flatY), Offset(size.width, flatY),
      Paint()..color = AppColors.red..strokeWidth = 2..style = PaintingStyle.stroke);

    final slopeStart = ascending ? size.height * 0.85 : size.height * 0.15;
    canvas.drawLine(Offset(0, slopeStart), Offset(size.width, flatY),
      Paint()..color = AppColors.green..strokeWidth = 2..style = PaintingStyle.stroke);

    final zig = [
      Offset(0, slopeStart),
      Offset(size.width * 0.2, flatY + (ascending ? 10 : -10)),
      Offset(size.width * 0.4, slopeStart * 0.7 + flatY * 0.3),
      Offset(size.width * 0.6, flatY + (ascending ? 6 : -6)),
      Offset(size.width * 0.8, slopeStart * 0.4 + flatY * 0.6),
      Offset(size.width, flatY),
    ];
    final path = Path()..moveTo(zig[0].dx, zig[0].dy);
    for (final p in zig.skip(1)) { path.lineTo(p.dx, p.dy); }
    canvas.drawPath(path, Paint()..color = AppColors.cyan..strokeWidth = 1.5..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SupportResistancePainter extends CustomPainter {
  final bool isSupport;
  SupportResistancePainter({required this.isSupport});

  @override
  void paint(Canvas canvas, Size size) {
    final lineY = isSupport ? size.height * 0.75 : size.height * 0.25;
    canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY),
      Paint()..color = AppColors.gold..strokeWidth = 2..style = PaintingStyle.stroke);

    final pts = isSupport
      ? [Offset(0, 0.2), Offset(0.2, 0.7), Offset(0.4, 0.3), Offset(0.6, 0.72), Offset(0.8, 0.35), Offset(1.0, 0.68)]
      : [Offset(0, 0.7), Offset(0.2, 0.25), Offset(0.4, 0.65), Offset(0.6, 0.22), Offset(0.8, 0.6), Offset(1.0, 0.28)];
    final mapped = pts.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();
    final path = Path()..moveTo(mapped[0].dx, mapped[0].dy);
    for (final p in mapped.skip(1)) { path.lineTo(p.dx, p.dy); }
    canvas.drawPath(path, Paint()..color = AppColors.cyan..strokeWidth = 2..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoleReversalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lineY = size.height * 0.4;
    canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY),
      Paint()..color = AppColors.gold..strokeWidth = 2..style = PaintingStyle.stroke);

    final pts = [
      Offset(0, 0.75), Offset(0.2, 0.5), Offset(0.35, 0.75),
      Offset(0.5, 0.4), Offset(0.65, 0.15), Offset(0.8, 0.35), Offset(1.0, 0.15),
    ];
    final mapped = pts.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();
    final path = Path()..moveTo(mapped[0].dx, mapped[0].dy);
    for (final p in mapped.skip(1)) { path.lineTo(p.dx, p.dy); }
    canvas.drawPath(path, Paint()..color = AppColors.green..strokeWidth = 2..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MovingAveragePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pricePts = [0.6, 0.4, 0.55, 0.3, 0.45, 0.2, 0.35, 0.15, 0.25, 0.1];
    final maPts     = [0.65, 0.55, 0.5, 0.45, 0.42, 0.38, 0.35, 0.3, 0.27, 0.22];
    void drawSeries(List<double> vals, Color color, double strokeW) {
      final path = Path();
      for (int i = 0; i < vals.length; i++) {
        final x = size.width * i / (vals.length - 1);
        final y = size.height * vals[i];
        if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      }
      canvas.drawPath(path, Paint()..color = color..strokeWidth = strokeW..style = PaintingStyle.stroke);
    }
    drawSeries(pricePts, AppColors.cyan, 2);
    drawSeries(maPts, AppColors.gold, 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RsiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25),
      Paint()..color = AppColors.red..strokeWidth = 1..style = PaintingStyle.stroke);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75),
      Paint()..color = AppColors.green..strokeWidth = 1..style = PaintingStyle.stroke);

    final vals = [0.5, 0.3, 0.15, 0.35, 0.6, 0.8, 0.9, 0.7, 0.5, 0.65];
    final path = Path();
    for (int i = 0; i < vals.length; i++) {
      final x = size.width * i / (vals.length - 1);
      final y = size.height * (1 - vals[i]);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, Paint()..color = AppColors.cyan..strokeWidth = 2..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MacdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final macd   = [0.5, 0.45, 0.4, 0.42, 0.55, 0.65, 0.6, 0.5, 0.45, 0.55];
    final signal = [0.55, 0.5, 0.45, 0.4, 0.45, 0.55, 0.62, 0.58, 0.5, 0.48];

    final barW = size.width / macd.length * 0.6;
    for (int i = 0; i < macd.length; i++) {
      final diff = macd[i] - signal[i];
      final x = size.width * i / (macd.length - 1);
      final barH = diff.abs() * size.height * 1.5;
      final top = diff >= 0 ? size.height * 0.5 - barH : size.height * 0.5;
      canvas.drawRect(Rect.fromLTWH(x - barW/2, top, barW, barH),
        Paint()..color = diff >= 0 ? AppColors.green.withOpacity(0.5) : AppColors.red.withOpacity(0.5));
    }

    void drawSeries(List<double> vals, Color color) {
      final path = Path();
      for (int i = 0; i < vals.length; i++) {
        final x = size.width * i / (vals.length - 1);
        final y = size.height * (1 - vals[i]);
        if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      }
      canvas.drawPath(path, Paint()..color = color..strokeWidth = 1.8..style = PaintingStyle.stroke);
    }
    drawSeries(macd, AppColors.cyan);
    drawSeries(signal, AppColors.gold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BollingerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mid   = [0.5, 0.48, 0.46, 0.44, 0.43, 0.42, 0.41, 0.4, 0.39, 0.38];
    final upper = [0.3, 0.28, 0.25, 0.22, 0.24, 0.3, 0.35, 0.28, 0.22, 0.18];
    final lower = [0.7, 0.68, 0.67, 0.66, 0.62, 0.55, 0.5, 0.52, 0.56, 0.58];
    final price = [0.55, 0.4, 0.3, 0.5, 0.6, 0.32, 0.45, 0.35, 0.25, 0.2];

    void drawSeries(List<double> vals, Color color, double w) {
      final path = Path();
      for (int i = 0; i < vals.length; i++) {
        final x = size.width * i / (vals.length - 1);
        final y = size.height * vals[i];
        if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      }
      canvas.drawPath(path, Paint()..color = color..strokeWidth = w..style = PaintingStyle.stroke);
    }
    drawSeries(upper, AppColors.gold.withOpacity(0.6), 1.5);
    drawSeries(lower, AppColors.gold.withOpacity(0.6), 1.5);
    drawSeries(mid, AppColors.mutedDark, 1);
    drawSeries(price, AppColors.cyan, 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
