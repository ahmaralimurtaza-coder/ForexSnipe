import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'webview_screen.dart';

class BarchartScreen extends StatelessWidget {
  const BarchartScreen({super.key});

  final _links = const [
    ['EUR/USD COT', 'https://www.barchart.com/forex/cot-reports/6E'],
    ['GBP/USD COT', 'https://www.barchart.com/forex/cot-reports/6B'],
    ['USD/JPY COT', 'https://www.barchart.com/forex/cot-reports/6J'],
    ['AUD/USD COT', 'https://www.barchart.com/forex/cot-reports/6A'],
    ['USD/CAD COT', 'https://www.barchart.com/forex/cot-reports/6C'],
    ['NZD/USD COT', 'https://www.barchart.com/forex/cot-reports/6N'],
    ['Gold COT',    'https://www.barchart.com/futures/cot-reports/GC'],
    ['Silver COT',  'https://www.barchart.com/futures/cot-reports/SI'],
    ['Crude Oil COT','https://www.barchart.com/futures/cot-reports/CL'],
    ['S&P 500 COT', 'https://www.barchart.com/futures/cot-reports/ES'],
  ];

  Future<void> _launch(BuildContext context, String url, String title) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => WebViewScreen(url: url, title: title)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader(label: 'Barchart.com · Updated Every Friday', title: 'COT', titleAccent: 'Charts'),
          GlowCard(glowColor: AppColors.gold, padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MAIN COT REPORT', style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w700, color: AppColors.gold)),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launch(context, 'https://www.barchart.com/forex/cot-reports', 'Barchart COT Reports'),
                  icon: const Icon(Icons.bar_chart, size: 18),
                  label: const Text('Open Barchart COT Reports'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold, foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                )),
            ])),
          const SizedBox(height: 16),
          const SectionHeader(label: 'Quick Links', title: 'Pair', titleAccent: 'Charts'),
          ..._links.map((link) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => _launch(context, link[1], link[0]),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.navyCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(link[0], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const Icon(Icons.open_in_new, size: 16, color: AppColors.gold),
                ]),
              ),
            ),
          )),
        ]),
      ),
    );
  }
}
