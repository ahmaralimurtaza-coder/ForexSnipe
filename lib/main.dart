import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/prices_screen.dart';
import 'screens/cot_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/news_screen.dart';
import 'screens/sentiment_screen.dart';
import 'screens/barchart_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/sources_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ForexSnipeApp(),
    ),
  );
}

class ForexSnipeApp extends StatelessWidget {
  const ForexSnipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'ForexSnipe',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const _StartRouter(),
    );
  }
}

// ── Decides: first time → Onboarding, returning user → skip ──
class _StartRouter extends StatefulWidget {
  const _StartRouter();
  @override State<_StartRouter> createState() => _StartRouterState();
}

class _StartRouterState extends State<_StartRouter> {
  Widget _afterSplash = const OnboardingScreen(nextScreen: HomeShell());

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final seen  = prefs.getBool('forexsnipe_onboarding') ?? false;
    if (seen && mounted) {
      setState(() => _afterSplash = const HomeShell());
    } else {
      await prefs.setBool('forexsnipe_onboarding', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(nextScreen: _afterSplash);
  }
}

// ── Main shell with bottom navigation ──
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  final _tabs = const [
    _TabItem(icon: Icons.show_chart,               label: 'Prices'),
    _TabItem(icon: Icons.people_alt,               label: 'COT'),
    _TabItem(icon: Icons.calendar_month,           label: 'Calendar'),
    _TabItem(icon: Icons.newspaper,                label: 'News'),
    _TabItem(icon: Icons.sentiment_satisfied_alt,  label: 'Sentiment'),
    _TabItem(icon: Icons.bar_chart,                label: 'Barchart'),
    _TabItem(icon: Icons.smart_toy_outlined,       label: 'AI Chat'),
    _TabItem(icon: Icons.hub_outlined,             label: 'Sources'),
  ];

  final _screens = const [
    PricesScreen(),
    CotScreen(),
    CalendarScreen(),
    NewsScreen(),
    SentimentScreen(),
    BarchartScreen(),
    AiScreen(),
    SourcesScreen(),
  ];

  final _titles = const [
    'Live Prices',
    'COT Report',
    'Economic Calendar',
    'Market News',
    'Sentiment',
    'Barchart COT',
    'AI Analyst',
    'Data Sources',
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark        = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          // ── ForexSnipe Logo in AppBar ──
          RichText(
            text: TextSpan(
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
              children: [
                TextSpan(
                  text: 'Forex',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textLight,
                    shadows: [
                      Shadow(
                        color: AppColors.green.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
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
          const SizedBox(width: 10),
          // Current tab name
          Text(
            '— ${_titles[_tab]}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
            ),
          ),
        ]),
        actions: [
          // ── Dark / Light mode toggle ──
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => themeProvider.toggleTheme(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 56,
                height: 28,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark
                      ? AppColors.green.withOpacity(0.15)
                      : const Color(0xFFDDF5E8),
                  border: Border.all(
                    color: isDark
                        ? AppColors.green.withOpacity(0.4)
                        : AppColors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: isDark
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.green,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.green.withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.navyBorder : AppColors.lightBorder,
          ),
        ),
      ),

      // ── Body — IndexedStack keeps all tabs alive ──
      body: IndexedStack(index: _tab, children: _screens),

      // ── Bottom Navigation Bar — scrollable for 8 tabs ──
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.navyCard : AppColors.lightCard,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.navyBorder : AppColors.lightBorder,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final selected = i == _tab;
                  final col = selected
                      ? AppColors.green
                      : (isDark ? AppColors.mutedDark : AppColors.mutedLight);

                  return GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 2,
                            color: selected ? AppColors.green : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_tabs[i].icon, size: 20, color: col),
                          const SizedBox(height: 4),
                          Text(
                            _tabs[i].label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: col,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}