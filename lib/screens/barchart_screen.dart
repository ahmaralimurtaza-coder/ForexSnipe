import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class BarchartScreen extends StatelessWidget {
  const BarchartScreen({super.key});

  final _cotLinks = const [
    {'label': 'EUR/USD COT Chart',  'sub': 'Euro vs US Dollar — CFTC weekly',        'url': 'https://www.barchart.com/forex/cot-reports/EUR'},
    {'label': 'GBP/USD COT Chart',  'sub': 'British Pound — CFTC weekly',             'url': 'https://www.barchart.com/forex/cot-reports/GBP'},
    {'label': 'USD/JPY COT Chart',  'sub': 'Japanese Yen — CFTC weekly',              'url': 'https://www.barchart.com/forex/cot-reports/JPY'},
    {'label': 'AUD/USD COT Chart',  'sub': 'Australian Dollar — CFTC weekly',         'url': 'https://www.barchart.com/forex/cot-reports/AUD'},
    {'label': 'USD/CAD COT Chart',  'sub': 'Canadian Dollar — CFTC weekly',           'url': 'https://www.barchart.com/forex/cot-reports/CAD'},
    {'label': 'NZD/USD COT Chart',  'sub': 'New Zealand Dollar — CFTC weekly',        'url': 'https://www.barchart.com/forex/cot-reports/NZD'},
    {'label': 'All Forex COT Data', 'sub': 'Complete forex COT table + download',     'url': 'https://www.barchart.com/futures/commitment-of-traders'},
    {'label': 'Legacy COT Report',  'sub': 'Commercial vs Non-Commercial net',        'url': 'https://www.barchart.com/futures/legacy-cot-reports'},
    {'label': 'Disaggregated COT',  'sub': 'Managed Money · Swap Dealers · Producers','url': 'https://www.barchart.com/futures/disaggregated-cot-reports'},
    {'label': 'TFF Financial COT',  'sub': 'Dealer · Asset Mgr · Leveraged Funds',   'url': 'https://www.barchart.com/futures/tff-cot-reports'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader(label: 'Barchart.com', title: 'COT Charts &', titleAccent: 'Data'),
          GlowCard(
            glowColor: AppColors.gold,
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('📊', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('BARCHART.COM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1,
                      color: isDark ? AppColors.gold : const Color(0xFFCC8800))),
                  Text('Free COT Charts & Historical Data', style: TextStyle(fontSize: 12,
                      color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
                ])),
              ]),
              const SizedBox(height: 14),
              _FeatureRow('✅ COT charts updated every Friday at 3pm CT'),
              _FeatureRow('✅ Legacy, Disaggregated & TFF report types'),
              _FeatureRow('✅ 52-week high/low net positions'),
              _FeatureRow('✅ Forex-specific COT section'),
              _FeatureRow('✅ Free CSV download available'),
              _FeatureRow('⚠️ OnDemand API = Paid (use CFTC direct for free)'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launch('https://www.barchart.com/forex/cot-reports'),
                  icon: const Icon(Icons.open_in_browser, size: 16),
                  label: const Text('Open Barchart Forex COT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.gold : const Color(0xFFCC8800),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          Text('QUICK LINKS', style: TextStyle(fontSize: 10, letterSpacing: 2.5, fontWeight: FontWeight.w700,
              color: isDark ? AppColors.cyan : const Color(0xFF0088AA))),
          const SizedBox(height: 12),
          ..._cotLinks.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => _launch(l['url']!),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.navyCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.bar_chart, color: AppColors.gold, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l['label']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(l['sub']!,   style: TextStyle(fontSize: 11, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
                  ])),
                  Icon(Icons.chevron_right, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
                ]),
              ),
            ),
          )),
        ]),
      ),
    );
  }

  Widget _FeatureRow(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4)),
  );

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}