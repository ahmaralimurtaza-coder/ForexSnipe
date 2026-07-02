import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/sample_data.dart';
import '../widgets/common_widgets.dart';
import '../services/data_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String _category = 'Forex';
  String _impact   = 'ALL';
  DateTime _selectedDate = DateTime.now();
  final _categories = ['Forex','Indices','Stocks','Crypto','Commodities','Futures'];
  final _impacts    = ['ALL','HIGH','MED','LOW'];

  List<CalendarEvent> _filtered(List<CalendarEvent> source) {
    var list = source.where((e) => e.category == _category).toList();
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

  String _dayLabel(DateTime d) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cmp   = DateTime(d.year, d.month, d.day);
    if (cmp == today) return 'Today';
    if (cmp == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (cmp == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  bool get _isWeekend => _selectedDate.weekday == DateTime.saturday || _selectedDate.weekday == DateTime.sunday;

  void _changeDay(int delta) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: delta)));
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 14)),
      lastDate: DateTime.now().add(const Duration(days: 14)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.green)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final dp     = context.watch<DataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = _catColor(_category);

    // Use real DataProvider calendar, fallback to sample if empty
    final source   = dp.calendar.isNotEmpty ? dp.calendar : SampleData.calendar;
    final filtered = _filtered(source);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              const SectionHeader(label: 'Finnhub · Economic Events', title: 'Calendar', titleAccent: ''),

              // Category chips
              SizedBox(height: 40, child: ListView.separated(
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? cc.withOpacity(0.18) : (isDark ? AppColors.navyCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? cc : (isDark ? AppColors.navyBorder : AppColors.lightBorder), width: sel ? 1.5 : 1),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(_catEmoji(cat), style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 5),
                        Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          color: sel ? cc : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
                      ]),
                    ),
                  );
                },
              )),

              const SizedBox(height: 12),

              // Date navigator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.navyCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
                ),
                child: Row(children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: AppColors.cyan, size: 22),
                    onPressed: () => _changeDay(-1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(child: GestureDetector(
                    onTap: () => _pickDate(context),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.calendar_month, size: 16, color: AppColors.cyan),
                      const SizedBox(width: 8),
                      Flexible(child: Text(_dayLabel(_selectedDate),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis)),
                    ]),
                  )),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: AppColors.cyan, size: 22),
                    onPressed: () => _changeDay(1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ]),
              ),

              const SizedBox(height: 10),

              // Impact filter
              SizedBox(height: 36, child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _impacts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final imp = _impacts[i];
                  final sel = imp == _impact;
                  Color c;
                  switch (imp) {
                    case 'HIGH': c = AppColors.red; break;
                    case 'MED':  c = AppColors.gold; break;
                    case 'LOW':  c = AppColors.mutedDark; break;
                    default:     c = AppColors.cyan;
                  }
                  return GestureDetector(
                    onTap: () => setState(() => _impact = imp),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? c.withOpacity(0.18) : (isDark ? AppColors.navyCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? c : (isDark ? AppColors.navyBorder : AppColors.lightBorder), width: sel ? 1.5 : 1),
                      ),
                      child: Text(imp, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: sel ? c : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
                    ),
                  );
                },
              )),

              const SizedBox(height: 8),

              if (_isWeekend)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'Markets are closed on weekends — fewer events scheduled. Try a weekday for full calendar.',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.mutedDark : AppColors.mutedLight))),
                  ]),
                ),
            ]),
          ),

          Expanded(
            child: filtered.isEmpty
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_catEmoji(_category), style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 12),
                    Text('No \ events for this view',
                      style: TextStyle(color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
                  ]),
                ))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _EventCard(event: filtered[i], catColor: color),
                ),
          ),
        ]),
      ),
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
    final isPending = event.actual.isEmpty || event.actual == '—';
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
              _DataCell('Actual',   event.actual.isEmpty ? '—' : event.actual,
                  color: event.isBetter == true ? AppColors.green : event.isBetter == false ? AppColors.red : null),
              _DataCell('Forecast', event.forecast.isEmpty ? '—' : event.forecast),
              _DataCell('Previous', event.previous.isEmpty ? '—' : event.previous),
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

