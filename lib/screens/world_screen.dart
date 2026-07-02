import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../services/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});
  @override State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  String _category = 'All';
  final _categories = ['All', 'Earthquake', 'Disaster', 'World'];

  Color _catColor(String cat) {
    switch (cat) {
      case 'Earthquake': return AppColors.red;
      case 'Disaster':   return AppColors.gold;
      case 'World':      return AppColors.cyan;
      default:           return AppColors.green;
    }
  }

  Color _magColor(double? mag) {
    if (mag == null) return AppColors.mutedDark;
    if (mag >= 6.0) return AppColors.red;
    if (mag >= 4.5) return AppColors.gold;
    return AppColors.green;
  }

  String _mapCat(String rawCategory) {
    if (rawCategory == 'Earthquake') return 'Earthquake';
    if (rawCategory == 'World') return 'World';
    return 'Disaster';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dp     = context.watch<DataProvider>();
    final events = dp.worldEvents;

    final quakeCount    = events.where((e) => e.category == 'Earthquake').length;
    final disasterCount = events.where((e) => e.category != 'Earthquake' && e.category != 'World').length;
    final worldCount    = events.where((e) => e.category == 'World').length;

    final filtered = _category == 'All'
        ? events
        : events.where((e) => _mapCat(e.category) == _category).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          const SectionHeader(label: 'USGS · NASA EONET · GDELT', title: 'World', titleAccent: 'Monitor'),
          const SizedBox(height: 14),

          Row(children: [
            _MiniStat('${events.length}', 'Total', AppColors.cyan),
            const SizedBox(width: 10),
            _MiniStat('$quakeCount', 'Quakes', AppColors.red),
            const SizedBox(width: 10),
            _MiniStat('$disasterCount', 'Disasters', AppColors.gold),
            const SizedBox(width: 10),
            _MiniStat('$worldCount', 'World', AppColors.green),
          ]),
          const SizedBox(height: 16),

          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final selected = _category == cat;
                final color = cat == 'All' ? AppColors.cyan : _catColor(cat);
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? color.withOpacity(0.15) : (isDark ? AppColors.navyCard : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? color : (isDark ? AppColors.navyBorder : AppColors.lightBorder)),
                    ),
                    alignment: Alignment.center,
                    child: Text(cat.toUpperCase(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                            color: selected ? color : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(child: Text('No events for $_category',
                  style: TextStyle(color: isDark ? AppColors.mutedDark : AppColors.mutedLight))),
            )
          else
            ...filtered.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _WorldCard(event: e, color: e.category == 'Earthquake' ? _magColor(e.magnitude) : _catColor(_mapCat(e.category))),
            )),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _MiniStat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
            color: color, fontFamily: 'monospace')),
        Text(label, style: TextStyle(fontSize: 10,
            color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
      ]),
    ));
  }
}

class _WorldCard extends StatelessWidget {
  final WorldEvent event;
  final Color color;
  const _WorldCard({required this.event, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        if (event.url.isEmpty) return;
        final uri = Uri.parse(event.url);
        if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.navyCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                event.magnitude != null ? 'M ${event.magnitude!.toStringAsFixed(1)}' : event.category.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: color),
              ),
            ),
            Text(event.timeAgo, style: TextStyle(fontSize: 11,
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
          ]),
          const SizedBox(height: 10),
          Text(event.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.5)),
          const SizedBox(height: 8),
          Text(event.source, style: TextStyle(fontSize: 11,
              color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
        ]),
      ),
    );
  }
}
