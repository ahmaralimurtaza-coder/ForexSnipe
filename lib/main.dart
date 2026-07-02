import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'services/data_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/prices_screen.dart';
import 'screens/cot_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/news_screen.dart';
import 'screens/world_screen.dart';
import 'screens/sentiment_screen.dart';
import 'screens/barchart_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/sources_screen.dart';
import 'widgets/common_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const ForexSnipeApp(),
    ),
  );
}

class ForexSnipeApp extends StatelessWidget {
  const ForexSnipeApp({super.key});
  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'ForexSnipe',
      debugShowCheckedModeBanner: false,
      themeMode: tp.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const _StartRouter(),
    );
  }
}

class _StartRouter extends StatefulWidget {
  const _StartRouter();
  @override State<_StartRouter> createState() => _StartRouterState();
}

class _StartRouterState extends State<_StartRouter> {
  Widget _afterSplash = const OnboardingScreen(nextScreen: HomeShell());

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final seen  = prefs.getBool('forexsnipe_onboarding') ?? false;
    if (seen && mounted) {
      setState(() => _afterSplash = const HomeShell());
    } else {
      await prefs.setBool('forexsnipe_onboarding', true);
    }
  }

  @override
  Widget build(BuildContext context) => SplashScreen(nextScreen: _afterSplash);
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().initialize();
    });
  }

  final _tabs = const [
    _Tab(icon: Icons.show_chart,              label: 'Prices'),
    _Tab(icon: Icons.people_alt,              label: 'COT'),
    _Tab(icon: Icons.calendar_month,          label: 'Calendar'),
    _Tab(icon: Icons.newspaper,               label: 'News'),
    _Tab(icon: Icons.public,                  label: 'World'),
    _Tab(icon: Icons.sentiment_satisfied_alt, label: 'Sentiment'),

    _Tab(icon: Icons.smart_toy_outlined,      label: 'AI Chat'),
    _Tab(icon: Icons.hub_outlined,            label: 'Sources'),
  ];

  final _screens = const [
    PricesScreen(), CotScreen(), CalendarScreen(), NewsScreen(), WorldScreen(),
    SentimentScreen(), AiScreen(), SourcesScreen(),
  ];

  final _titles = const [
    'Live Prices', 'COT Report', 'Economic Calendar', 'Market News', 'World Monitor',
    'Sentiment', 'AI Analyst', 'Data Sources',
  ];

  @override
  Widget build(BuildContext context) {
    final tp     = context.watch<ThemeProvider>();
    final dp     = context.watch<DataProvider>();
    final isDark = tp.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          RichText(text: TextSpan(
            style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w900),
            children: [
              TextSpan(text: 'Forex',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textLight,
                  shadows: [Shadow(color: AppColors.green.withOpacity(0.3), blurRadius: 8)],
                )),
              TextSpan(text: 'Snipe',
                style: TextStyle(
                  color: AppColors.green,
                  shadows: [Shadow(color: AppColors.green.withOpacity(0.5), blurRadius: 10)],
                )),
            ],
          )),
          const SizedBox(width: 8),
          Text('— ',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400,
              color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
          const SizedBox(width: 8),
          if (dp.isLoading)
            const SizedBox(width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.green))
          else
            const LiveDot(),
        ]),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh,
              color: isDark ? AppColors.mutedDark : AppColors.mutedLight, size: 20),
            onPressed: () => dp.refresh(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => tp.toggleTheme(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 56, height: 28,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark
                      ? AppColors.green.withOpacity(0.15)
                      : const Color(0xFFDDF5E8),
                  border: Border.all(color: AppColors.green.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: isDark ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.green,
                        boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.4), blurRadius: 6)],
                      ),
                      child: Icon(isDark ? Icons.dark_mode : Icons.light_mode,
                        size: 13, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1,
            color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
        ),
      ),
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.navyCard : AppColors.lightCard,
          border: Border(top: BorderSide(
            color: isDark ? AppColors.navyBorder : AppColors.lightBorder)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final sel = i == _tab;
                  final col = sel ? AppColors.green
                      : (isDark ? AppColors.mutedDark : AppColors.mutedLight);
                  return GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(
                          width: 2,
                          color: sel ? AppColors.green : Colors.transparent,
                        )),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_tabs[i].icon, size: 20, color: col),
                        const SizedBox(height: 4),
                        Text(_tabs[i].label,
                          style: TextStyle(fontSize: 10,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                            color: col),
                          overflow: TextOverflow.ellipsis),
                      ]),
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

class _Tab {
  final IconData icon;
  final String label;
  const _Tab({required this.icon, required this.label});
}




