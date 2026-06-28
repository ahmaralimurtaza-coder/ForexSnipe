import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/sample_data.dart';
import '../widgets/common_widgets.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});
  @override State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  late List<ForexPair> _pairs;
  Timer? _timer;
  final _rng = Random();
  String _category = 'Forex';

  final _categories = ['Forex', 'Indices', 'Stocks', 'Crypto', 'Commodities', 'Futures'];

  // Category ranges in the pairs list
  Map<String, List<int>> get _ranges => {
    'Forex':       [0,  7],
    'Indices':     [8,  13],
    'Stocks':      [14, 19],
    'Crypto':      [20, 24],
    'Commodities': [25, 30],
    'Futures':     [31, 33],
  };

  List<ForexPair> get _filtered {
    final range = _ranges[_category]!;
    return _pairs.sublist(range[0], range[1] + 1);
  }

  @override
  void initState() {
    super.initState();
    _pairs = List.from(SampleData.pairs);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _jitter());
  }

  void _jitter() {
    setState(() {
      _pairs = _pairs.map((p) {
        final delta = (_rng.nextDouble() - 0.5) * 0.001 * p.price;
        final newPrice = p.price + delta;
        final newSpark = [...p.spark.skip(1), newPrice];
        return ForexPair(
          pair: p.pair, flag: p.flag,
          price: newPrice, change: p.change + delta,
          changePct: p.changePct + (_rng.nextDouble() - 0.5) * 0.02,
          isUp: delta > 0, spark: newSpark,
        );
      }).toList();
    });
  }

  @override void dispose() { _timer?.cancel(); super.dispose(); }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.cyan : const Color(0xFF0088AA);
    final filtered = _filtered;
    final color = _catColor(_category);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Ticker
          SliverToBoxAdapter(child: _TickerBanner(pairs: _pairs.sublist(0, 8))),

          // Header + Featured card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionHeader(
                  label: 'Finnhub · Twelve Data · Alpha Vantage',
                  title: 'Live',
                  titleAccent: 'Markets',
                ),

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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? cc.withOpacity(0.15) : (isDark ? AppColors.navyCard : AppColors.lightCard),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: sel ? cc : (isDark ? AppColors.navyBorder : AppColors.lightBorder)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(_catEmoji(cat), style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 5),
                            Text(cat, style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: sel ? cc : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
                            )),
                          ]),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // Featured card
                GlowCard(
                  glowColor: color,
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${filtered[0].flag} ${filtered[0].pair}',
                            style: TextStyle(fontSize: 12, color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
                        const SizedBox(height: 4),
                        Text(
                            filtered[0].price > 999
                                ? filtered[0].price.toStringAsFixed(2)
                                : filtered[0].price.toStringAsFixed(filtered[0].price > 10 ? 2 : 4),
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: color)),
                        Row(children: [
                          Icon(filtered[0].isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                              color: filtered[0].isUp ? AppColors.green : AppColors.red, size: 18),
                          Text('${filtered[0].changePct.toStringAsFixed(2)}%',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                  color: filtered[0].isUp ? AppColors.green : AppColors.red)),
                        ]),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        const LiveDot(),
                        const SizedBox(height: 10),
                        SparkLine(data: filtered[0].spark, isUp: filtered[0].isUp, width: 90, height: 36),
                      ]),
                    ]),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(children: [
                      _StatBox(label: 'Change', value: '${filtered[0].isUp ? '+' : ''}${filtered[0].change.toStringAsFixed(filtered[0].price > 10 ? 2 : 4)}'),
                      _StatBox(label: '% Change', value: '${filtered[0].changePct.toStringAsFixed(2)}%'),
                      _StatBox(label: 'Category', value: _category),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),

          // Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.55,
              ),
              delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _PairCard(pair: filtered[i], catColor: _catColor(_category)),
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Column(children: [
      Text(label, style: TextStyle(fontSize: 10, color: isDark ? AppColors.mutedDark : AppColors.mutedLight, letterSpacing: 1)),
      const SizedBox(height: 3),
      Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis),
    ]));
  }
}

class _PairCard extends StatelessWidget {
  final ForexPair pair;
  final Color catColor;
  const _PairCard({required this.pair, required this.catColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final up = pair.isUp;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
      ),
      child: Stack(children: [
        Positioned(top: 0, left: 0, right: 0,
            child: Container(height: 2, decoration: BoxDecoration(
              color: up ? AppColors.green : AppColors.red,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ))),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(pair.flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 2),
            Text(pair.pair, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
            const SizedBox(height: 2),
            Text(
                pair.price > 999
                    ? pair.price.toStringAsFixed(2)
                    : pair.price.toStringAsFixed(pair.price > 10 ? 2 : 4),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: catColor)),
            const SizedBox(height: 2),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(child: Text('${up ? '+' : ''}${pair.changePct.toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: up ? AppColors.green : AppColors.red))),
              SparkLine(data: pair.spark, isUp: up, width: 55, height: 22),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _TickerBanner extends StatefulWidget {
  final List<ForexPair> pairs;
  const _TickerBanner({required this.pairs});
  @override State<_TickerBanner> createState() => _TickerBannerState();
}

class _TickerBannerState extends State<_TickerBanner> with SingleTickerProviderStateMixin {
  late ScrollController _sc;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _sc = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  void _startScroll() {
    _t = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!_sc.hasClients) return;
      final max = _sc.position.maxScrollExtent;
      if (_sc.offset >= max) { _sc.jumpTo(0); }
      else { _sc.animateTo(_sc.offset + 1.5, duration: const Duration(milliseconds: 30), curve: Curves.linear); }
    });
  }

  @override void dispose() { _t?.cancel(); _sc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 36,
      color: isDark ? AppColors.navyCard : AppColors.lightCard2,
      child: ListView.separated(
        controller: _sc,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.pairs.length * 2,
        separatorBuilder: (_, __) => Container(width: 1,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
        itemBuilder: (ctx, i) {
          final p = widget.pairs[i % widget.pairs.length];
          return Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('${p.pair} ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
            Text(p.price.toStringAsFixed(p.price > 10 ? 2 : 4),
                style: TextStyle(fontSize: 11, fontFamily: 'monospace',
                    color: isDark ? AppColors.cyan : const Color(0xFF0088AA))),
            const SizedBox(width: 4),
            Text('${p.isUp ? '▲' : '▼'} ${p.changePct.abs().toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 10, color: p.isUp ? AppColors.green : AppColors.red)),
          ]));
        },
      ),
    );
  }
}