import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/sample_data.dart';
import '../widgets/common_widgets.dart';
import 'webview_screen.dart';

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final sources = SampleData.sources;

    final Map<String, List<DataSource>> grouped = {};
    for (final s in sources) { grouped.putIfAbsent(s.category, () => []).add(s); }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader(label: 'All Free Data Sources', title: 'Data', titleAccent: 'Sources'),
          Row(children: [
            _StatCard('9',    'Free Sources',   AppColors.cyan),
            const SizedBox(width: 12),
            _StatCard('100%', 'No Paid APIs',   AppColors.green),
            const SizedBox(width: 12),
            _StatCard('Live', 'Real-time Data', AppColors.gold),
          ]),
          const SizedBox(height: 24),
          ...grouped.entries.map((entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.navyCard2 : AppColors.lightCard2,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(entry.key.toUpperCase(), style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2,
                  color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                )),
              ),
              ...entry.value.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SourceCard(source: s),
              )),
              const SizedBox(height: 10),
            ],
          )),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.navyCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.red.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 16),
                const SizedBox(width: 8),
                const Text('DISCLAIMER', style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w800,
                    color: AppColors.red, letterSpacing: 1)),
              ]),
              const SizedBox(height: 8),
              Text(
                'ForexSnipe is for educational and informational purposes only. This app does not provide financial advice. Always do your own research before trading. Forex trading carries significant risk.',
                style: TextStyle(fontSize: 11,
                    color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                    height: 1.5),
              ),
            ]),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w900,
            color: color, fontFamily: 'monospace')),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
            textAlign: TextAlign.center),
      ]),
    ));
  }
}

class _SourceCard extends StatelessWidget {
  final DataSource source;
  const _SourceCard({required this.source});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.cyan : const Color(0xFF0088AA);

    return GestureDetector(
      onTap: () {
        // â”€â”€ App ke andar WebView mein khulega â”€â”€
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WebViewScreen(
              url: source.url,
              title: source.name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.navyCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withOpacity(0.2)),
            ),
            child: Center(child: Text(source.icon,
                style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(child: Text(source.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace'),
                      overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(source.tag,
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: primary,
                            letterSpacing: 0.5)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(source.description,
                    style: TextStyle(fontSize: 11, height: 1.4,
                        color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
              ])),
          const SizedBox(width: 8),
          // WebView icon (app ke andar khulega)
          Icon(Icons.open_in_new, size: 14,
              color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
        ]),
      ),
    );
  }
}
