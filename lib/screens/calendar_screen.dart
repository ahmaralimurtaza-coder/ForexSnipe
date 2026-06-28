import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/sample_data.dart';
import '../widgets/common_widgets.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String _category = 'Forex';
  String _impact   = 'ALL';

  final _categories = ['Forex','Indices','Stocks','Crypto','Commodities','Futures'];
  final _impacts    = ['ALL','HIGH','MED','LOW'];

  List<CalendarEvent> get _filtered {
    var list = SampleData.calendar.where((e) => e.category == _category).toList();
    if (_impact != 'ALL') list = list.where((e) => e.impact == _impact).toList();
    return list;
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'Forex':       return AppColors.cyan;
      case 'Indices':     return AppColors.gold;
      case 'Stocks':      return AppColors.green;
      case 'Crypto':      return const Color(0xFFFF9800);
      case 'Commodities': return const Color(0xFFE040FB);
      case 'Futures':     return AppColors.red;
      default:            return AppColors.cyan;
    }
  }

  String _catEmoji(String cat) {
    switch (cat) {
      case 'Forex':       return '💱';
      case 'Indices':     return '📈';
      case 'Stocks':      return '🏢';
      case 'Crypto':      return '₿';
      case 'Commodities': return '🛢️';
      case 'Futures':     return '🔮';
      default:            return '📊';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;
    final color    = _catColor(_category);

    return Scaffold(
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader(label: 'Finnhub · RapidAPI · Trading Economics', title: 'Economic', titleAccent: 'Calendar'),

            // Category chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final cat = _categories[i];
                  final sel = cat == _category;
                  final cc  = _catColor(cat);
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? cc.withOpacity(0.15) : (isDark ? AppColors.navyCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? cc : (isDark ? AppColors.navyBorder : AppColors.lightBorder)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(_catEmoji(cat), style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(cat, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: sel ? cc : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Date + live dot
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.navyCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Icon(Icons.calendar_today, size: 14, color: color),
                  const SizedBox(width: 8),
                  const Text('Sunday, June 28, 2026',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
                const LiveDot(),
              ]),
            ),
            const SizedBox(height: 10),

            // Impact filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _impacts.map((f) {
                final sel = f == _impact;
                Color fc;
                switch (f) {
                  case 'HIGH': fc = AppColors.red;  break;
                  case 'MED':  fc = AppColors.gold; break;
                  case 'LOW':  fc = AppColors.mutedDark; break;
                  default:     fc = color;
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _impact = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? fc.withOpacity(0.15) : (isDark ? AppColors.navyCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? fc : (isDark ? AppColors.navyBorder : AppColors.lightBorder)),
                      ),
                      child: Text(f, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: sel ? fc : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
                    ),
                  ),
                );
              }).toList()),
            ),
            const SizedBox(height: 12),
          ]),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text('No events for $_category',
              style: TextStyle(color: isDark ? AppColors.mutedDark : AppColors.mutedLight)))
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) => _EventCard(event: filtered[i], catColor: _catColor(filtered[i].category)),
          ),
        ),
      ]),
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEvent event;
  final Color catColor;
  const _EventCard({required this.event, required this.catColor});

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final isPending = event.actual == '—';
    Color impactColor;
    switch (event.impact) {
      case 'HIGH': impactColor = AppColors.red;  break;
      case 'MED':  impactColor = AppColors.gold; break;
      default:     impactColor = AppColors.mutedDark;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
      ),
      child: Column(children: [
        Container(height: 3, decoration: BoxDecoration(
          color: impactColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        )),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Text(event.time, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    fontFamily: 'monospace', color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
                const SizedBox(width: 8),
                CurrencyTag(currency: event.currency),
                const SizedBox(width: 6),
                ImpactBadge(impact: event.impact),
              ]),
              if (isPending) Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: AppColors.navyCard2, borderRadius: BorderRadius.circular(4)),
                child: Text('PENDING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.mutedDark : AppColors.mutedLight, letterSpacing: 1)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(event.event, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(children: [
              _DataCell('Actual',   event.actual,
                  color: event.isBetter == true ? AppColors.green : event.isBetter == false ? AppColors.red : null),
              _DataCell('Forecast', event.forecast),
              _DataCell('Previous', event.previous),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _DataCell(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: TextStyle(fontSize: 9, letterSpacing: 1,
          color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
      const SizedBox(height: 3),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          fontFamily: 'monospace', color: color)),
    ]));
  }
}