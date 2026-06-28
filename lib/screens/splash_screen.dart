import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoCtrl;
  late AnimationController _crosshairCtrl;
  late AnimationController _lineCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _textCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _crosshairScale;
  late Animation<double> _crosshairOpacity;
  late Animation<double> _lineWidth;
  late Animation<double> _fadeOut;
  late Animation<double> _pulse;
  late Animation<double> _textOpacity;

  final List<_Candle> _candles = [];
  final _rng = Random();
  Timer? _candleTimer;

  // ── Sniper scope drawing progress
  late AnimationController _scopeCtrl;
  late Animation<double> _scopeProgress;

  @override
  void initState() {
    super.initState();
    _generateCandles();

    // Logo pop-in (starts at 0.3s)
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoScale   = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut).drive(Tween(begin: 0.0, end: 1.0));
    _logoOpacity = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn).drive(Tween(begin: 0.0, end: 1.0));

    // Crosshair animate in
    _crosshairCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _crosshairScale   = CurvedAnimation(parent: _crosshairCtrl, curve: Curves.easeOutBack).drive(Tween(begin: 0.0, end: 1.0));
    _crosshairOpacity = CurvedAnimation(parent: _crosshairCtrl, curve: Curves.easeIn).drive(Tween(begin: 0.0, end: 1.0));

    // Scope draw animation
    _scopeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scopeProgress = CurvedAnimation(parent: _scopeCtrl, curve: Curves.easeInOut).drive(Tween(begin: 0.0, end: 1.0));

    // Line draw
    _lineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _lineWidth = CurvedAnimation(parent: _lineCtrl, curve: Curves.easeOut).drive(Tween(begin: 0.0, end: 1.0));

    // Tagline fade in
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn).drive(Tween(begin: 0.0, end: 1.0));

    // Pulse glow (continuous)
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut).drive(Tween(begin: 0.5, end: 1.0));

    // Fade out
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeOut  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn).drive(Tween(begin: 1.0, end: 0.0));

    // Candle updates
    _candleTimer = Timer.periodic(const Duration(milliseconds: 350), (_) {
      if (mounted) setState(() => _updateCandles());
    });

    // ── 5 SECOND SEQUENCE ──
    // 0.0s - candles appear immediately (background)
    // 0.3s - logo pops in
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) _logoCtrl.forward(); });
    // 0.8s - crosshair scales in
    Future.delayed(const Duration(milliseconds: 800), () { if (mounted) _crosshairCtrl.forward(); });
    // 1.0s - scope circle draws
    Future.delayed(const Duration(milliseconds: 1000), () { if (mounted) _scopeCtrl.forward(); });
    // 1.8s - underline draws
    Future.delayed(const Duration(milliseconds: 1800), () { if (mounted) _lineCtrl.forward(); });
    // 2.2s - tagline fades in
    Future.delayed(const Duration(milliseconds: 2200), () { if (mounted) _textCtrl.forward(); });
    // 4.4s - start fade out
    Future.delayed(const Duration(milliseconds: 4400), () async {
      if (!mounted) return;
      await _fadeCtrl.forward();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => widget.nextScreen,
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  void _generateCandles() {
    double price = 1.0850;
    for (int i = 0; i < 20; i++) {
      final open   = price;
      final change = (_rng.nextDouble() - 0.47) * 0.007;
      final close  = open + change;
      final high   = [open, close].reduce(max) + _rng.nextDouble() * 0.003;
      final low    = [open, close].reduce(min) - _rng.nextDouble() * 0.003;
      _candles.add(_Candle(open: open, close: close, high: high, low: low));
      price = close;
    }
  }

  void _updateCandles() {
    final last   = _candles.last;
    final change = (_rng.nextDouble() - 0.47) * 0.005;
    final open   = last.close;
    final close  = open + change;
    final high   = [open, close].reduce(max) + _rng.nextDouble() * 0.002;
    final low    = [open, close].reduce(min) - _rng.nextDouble() * 0.002;
    _candles.removeAt(0);
    _candles.add(_Candle(open: open, close: close, high: high, low: low));
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _crosshairCtrl.dispose();
    _scopeCtrl.dispose();
    _lineCtrl.dispose();
    _textCtrl.dispose();
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    _candleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeOut,
      child: Scaffold(
        backgroundColor: const Color(0xFF06080E),
        body: Stack(children: [

          // ── Background candlestick chart ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => CustomPaint(
                painter: _CandlePainter(candles: _candles, pulse: _pulse.value),
              ),
            ),
          ),

          // ── Dark gradient overlay ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF06080E).withOpacity(0.55),
                    const Color(0xFF06080E).withOpacity(0.80),
                    const Color(0xFF06080E),
                    const Color(0xFF06080E),
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ──
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Crosshair scope (top decoration)
                AnimatedBuilder(
                  animation: Listenable.merge([_crosshairCtrl, _scopeCtrl, _pulseCtrl]),
                  builder: (_, __) => ScaleTransition(
                    scale: _crosshairScale,
                    child: FadeTransition(
                      opacity: _crosshairOpacity,
                      child: SizedBox(
                        width: 90, height: 90,
                        child: CustomPaint(
                          painter: _ScopePainter(
                            progress: _scopeProgress.value,
                            pulse: _pulse.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // App name
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: Column(children: [

                      // "Forex" + "Snipe" stacked
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.orbitron(fontSize: 46, fontWeight: FontWeight.w900, letterSpacing: 1),
                          children: [
                            TextSpan(text: 'Forex',
                                style: TextStyle(
                                    color: Colors.white,
                                    shadows: [Shadow(color: AppColors.green.withOpacity(0.4), blurRadius: 20)])),
                            TextSpan(text: 'Snipe',
                                style: TextStyle(
                                    color: AppColors.green,
                                    shadows: [Shadow(color: AppColors.green.withOpacity(0.7), blurRadius: 25)])),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Animated underline
                      AnimatedBuilder(
                        animation: _lineWidth,
                        builder: (_, __) => Container(
                          height: 2,
                          width: 260 * _lineWidth.value,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(colors: [
                              Colors.transparent,
                              AppColors.green,
                              AppColors.gold,
                              Colors.transparent,
                            ]),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tagline
                      FadeTransition(
                        opacity: _textOpacity,
                        child: Text(
                          'PRECISION MARKET INTELLIGENCE',
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            letterSpacing: 3,
                            color: AppColors.mutedDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),

                const Spacer(flex: 1),

                // Motivational quote
                FadeTransition(
                  opacity: _textOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: AppColors.green, width: 3),
                        ),
                        color: AppColors.green.withOpacity(0.04),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          '"Snipers don\'t spray bullets.\nThey wait. They aim. They strike.\nTrade like a sniper."',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark.withOpacity(0.85),
                            height: 1.7,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('— ForexSnipe Philosophy',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.green.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            )),
                      ]),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // Progress bar (5 second countdown)
                FadeTransition(
                  opacity: _logoOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(children: [
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 4400),
                            curve: Curves.linear,
                            builder: (_, val, __) => Column(children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('Loading markets...',
                                    style: TextStyle(fontSize: 11, color: AppColors.mutedDark)),
                                Text('${(val * 100).toInt()}%',
                                    style: TextStyle(fontSize: 11, color: AppColors.green,
                                        fontFamily: 'monospace', fontWeight: FontWeight.w700)),
                              ]),
                              const SizedBox(height: 6),
                              Stack(children: [
                                Container(height: 3, decoration: BoxDecoration(
                                  color: AppColors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(2),
                                )),
                                FractionallySizedBox(
                                  widthFactor: val,
                                  child: Container(height: 3, decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: LinearGradient(colors: [AppColors.green, AppColors.gold]),
                                    boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.5), blurRadius: 6)],
                                  )),
                                ),
                              ]),
                            ]),
                          );
                        },
                      ),
                    ]),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Candle model ──
class _Candle {
  final double open, close, high, low;
  const _Candle({required this.open, required this.close, required this.high, required this.low});
  bool get isBull => close >= open;
}

// ── Background chart painter ──
class _CandlePainter extends CustomPainter {
  final List<_Candle> candles;
  final double pulse;
  _CandlePainter({required this.candles, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;
    final allH = candles.map((c) => c.high).toList();
    final allL = candles.map((c) => c.low).toList();
    final maxP = allH.reduce(max);
    final minP = allL.reduce(min);
    final range = maxP - minP == 0 ? 1.0 : maxP - minP;
    final cw = size.width / candles.length;
    final bw = cw * 0.45;
    final pad = size.height * 0.08;

    double toY(double p) => pad + (1 - (p - minP) / range) * (size.height - pad * 2);

    for (int i = 0; i < candles.length; i++) {
      final c  = candles[i];
      final cx = i * cw + cw / 2;
      final col = c.isBull
          ? AppColors.green.withOpacity(0.20)
          : AppColors.red.withOpacity(0.20);

      canvas.drawLine(Offset(cx, toY(c.high)), Offset(cx, toY(c.low)),
          Paint()..color = col..strokeWidth = 1);

      final top = toY(max(c.open, c.close));
      final bot = toY(min(c.open, c.close));
      canvas.drawRect(
        Rect.fromLTRB(cx - bw/2, top, cx + bw/2, bot.clamp(top+2, size.height)),
        Paint()..color = col,
      );
    }

    // Trend line
    final pts = candles.asMap().entries.map((e) =>
        Offset(e.key * cw + cw/2, toY(e.value.close))).toList();
    final path = Path();
    for (int i = 0; i < pts.length; i++) {
      if (i == 0) path.moveTo(pts[i].dx, pts[i].dy);
      else path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, Paint()
      ..color = AppColors.green.withOpacity(0.25 * pulse)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);
  }

  @override bool shouldRepaint(_CandlePainter old) => true;
}

// ── Animated sniper scope painter ──
class _ScopePainter extends CustomPainter {
  final double progress;
  final double pulse;
  _ScopePainter({required this.progress, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.38;
    final ir = size.width * 0.12;
    final lw = size.width * 0.03;
    final col = AppColors.green;

    final paint = Paint()
      ..color = col.withOpacity(0.8 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lw
      ..strokeCap = StrokeCap.round;

    // Outer circle (draws progressively)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );

    // Inner circle
    if (progress > 0.4) {
      canvas.drawCircle(Offset(cx, cy), ir,
          paint..color = col.withOpacity(0.5 * progress * pulse));
    }

    // Crosshair lines (appear after scope drawn)
    if (progress > 0.7) {
      final gap    = size.width * 0.15;
      final extend = size.width * 0.1;
      final lp     = Paint()..color = col.withOpacity(0.9 * pulse)..strokeWidth = lw * 0.7..strokeCap = StrokeCap.round;
      final fade   = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);

      // Horizontal
      canvas.drawLine(Offset(cx - r - extend, cy), Offset(cx - gap, cy),
          lp..color = col.withOpacity(0.9 * pulse * fade));
      canvas.drawLine(Offset(cx + gap, cy), Offset(cx + r + extend, cy),
          lp..color = col.withOpacity(0.9 * pulse * fade));
      // Vertical
      canvas.drawLine(Offset(cx, cy - r - extend), Offset(cx, cy - gap),
          lp..color = col.withOpacity(0.9 * pulse * fade));
      canvas.drawLine(Offset(cx, cy + gap), Offset(cx, cy + r + extend),
          lp..color = col.withOpacity(0.9 * pulse * fade));

      // Center dot
      canvas.drawCircle(Offset(cx, cy), size.width * 0.04 * fade,
          Paint()..color = col.withOpacity(pulse * fade)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
  }

  @override bool shouldRepaint(_ScopePainter old) =>
      old.progress != progress || old.pulse != pulse;
}