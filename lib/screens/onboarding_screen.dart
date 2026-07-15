import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final Widget nextScreen;
  const OnboardingScreen({super.key, required this.nextScreen});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  final _pageCtrl = PageController();
  int _page = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final _pages = const [
    _OnboardPage(
      emoji: 'ðŸŽ¯',
      title: 'Snipe the Market\nWith Precision',
      color: AppColors.green,
      points: [
        'âœ…  Real-time prices for Forex, Stocks,\n      Crypto, Indices & Commodities',
        'âœ…  Animated live ticker with 50+ instruments',
        'âœ…  Sparkline mini-charts on every card',
        'âœ…  Auto-updates every 3 seconds live',
        'âœ…  Powered by Finnhub, Twelve Data\n      & Alpha Vantage â€” all FREE',
      ],
    ),
    _OnboardPage(
      emoji: 'ðŸ›ï¸',
      title: 'COT Report â€”\nTrack Smart Money',
      color: AppColors.gold,
      points: [
        'âœ…  Official CFTC data â€” 100% free',
        'âœ…  See what hedge funds &\n      institutions are doing weekly',
        'âœ…  Net positioning donut charts\n      for all asset classes',
        'âœ…  Forex, Indices, Crypto, Stocks,\n      Commodities & Futures COT data',
        'âœ…  Updated every Friday via\n      CFTC.gov & Barchart direct',
      ],
    ),
    _OnboardPage(
      emoji: 'ðŸ“…',
      title: 'Economic Calendar\n& Market News',
      color: Color(0xFF00D4FF),
      points: [
        'âœ…  HIGH / MED / LOW impact filters\n      for all 6 market categories',
        'âœ…  NFP, CPI, GDP, OPEC, Earnings,\n      ETF decisions â€” all tracked',
        'âœ…  AI-powered sentiment on\n      every news article',
        'âœ…  Bullish / Bearish / Neutral\n      news classification',
        'âœ…  Sources: Reuters, Bloomberg,\n      CoinDesk, CNBC, FXStreet & more',
      ],
    ),
    _OnboardPage(
      emoji: 'ðŸ¤–',
      title: 'AI Sniper Analyst\n& Sentiment Tools',
      color: AppColors.red,
      points: [
        'âœ…  Ask AI anything about forex,\n      stocks, crypto or COT data',
        'âœ…  Retail sentiment for all categories\n      â€” Myfxbook, IG, CME, Finviz',
        'âœ…  Extreme positioning alerts\n      (75%+ long/short warnings)',
        'âœ…  Dark & Light mode toggle\n      saved across sessions',
        'âœ…  In-app browser â€” no switching\n      apps to read source sites',
      ],
    ),
    _OnboardPage(
      emoji: '🧠',
      title: 'Trading Quiz\nTest Your Skills',
      color: Color(0xFFFF9800),
      points: [
        '✅  170 unique questions across\n      Easy, Medium & Hard levels',
        '✅  Easy: candlestick & chart basics\n      Medium: advanced patterns & indicators',
        '✅  Hard: prop firms, brokers, risk\n      management & Smart Money Concepts',
        '✅  Instant feedback with explanations\n      after every answer',
        '✅  Fully offline — works with\n      zero internet connection',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeIn,
    ).drive(Tween(begin: 0.0, end: 1.0));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _animCtrl.reset();
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _animCtrl.forward();
    } else {
      _goToApp();
    }
  }

  void _goToApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.nextScreen,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(children: [

          // â”€â”€ Top bar: logo + skip â”€â”€
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ForexSnipe logo
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Forex',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Snipe',
                        style: TextStyle(
                          color: AppColors.green,
                          shadows: [
                            Shadow(
                              color: AppColors.green.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Skip button
                TextButton(
                  onPressed: _goToApp,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.mutedDark,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // â”€â”€ Page indicator â”€â”€
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              final sel = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: sel ? 28 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: sel
                      ? _pages[_page].color
                      : AppColors.mutedDark.withOpacity(0.4),
                  boxShadow: sel ? [
                    BoxShadow(
                      color: _pages[_page].color.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ] : null,
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          // â”€â”€ Pages â”€â”€
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              onPageChanged: (i) {
                setState(() => _page = i);
                _animCtrl.reset();
                _animCtrl.forward();
              },
              itemCount: _pages.length,
              itemBuilder: (_, i) => FadeTransition(
                opacity: _fadeAnim,
                child: _PageContent(page: _pages[i]),
              ),
            ),
          ),

          // â”€â”€ Bottom button â”€â”€
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    _pages[_page].color,
                    _pages[_page].color.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _pages[_page].color.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: MaterialButton(
                onPressed: _next,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _page == _pages.length - 1
                          ? 'ðŸŽ¯  Start Sniping Markets'
                          : 'Next  â†’',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// â”€â”€ Individual page content â”€â”€
class _PageContent extends StatelessWidget {
  final _OnboardPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // â”€â”€ Emoji in glowing circle â”€â”€
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.color.withOpacity(0.1),
                border: Border.all(
                  color: page.color.withOpacity(0.35),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: page.color.withOpacity(0.25),
                    blurRadius: 35,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  page.emoji,
                  style: const TextStyle(fontSize: 50),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // â”€â”€ Title â”€â”€
          Center(
            child: Text(
              page.title,
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: page.color,
                height: 1.35,
                letterSpacing: 0.4,
                shadows: [
                  Shadow(
                    color: page.color.withOpacity(0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 28),

          // â”€â”€ Feature points â”€â”€
          ...page.points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: page.color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: page.color.withOpacity(0.18),
                ),
              ),
              child: Text(
                point,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textDark,
                  height: 1.55,
                ),
              ),
            ),
          )),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// â”€â”€ Data class for each onboarding page â”€â”€
class _OnboardPage {
  final String emoji;
  final String title;
  final Color color;
  final List<String> points;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.color,
    required this.points,
  });
}

