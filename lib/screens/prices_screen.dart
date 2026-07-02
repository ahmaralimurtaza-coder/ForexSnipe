import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/sample_data.dart';
import '../widgets/common_widgets.dart';
import '../services/data_provider.dart';
import 'pair_detail_screen.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});
  @override State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  String _category = 'Forex';
  int _selectedIndex = 0;
  final _categories = ['Forex','Indices','Stocks','Crypto','Commodities','Futures'];

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

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return 's ago';
    if (d.inMinutes < 60) return 'm ago';
    return 'h ago';
  }

  String _fmt(ForexPair p) {
    if (p.price >= 10000) return p.price.toStringAsFixed(2);
    if (p.price >= 100)   return p.price.toStringAsFixed(2);
    if (p.price >= 1)     return p.price.toStringAsFixed(4);
    return p.price.toStringAsFixed(5);
  }

  void _openDetail(ForexPair p) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PairDetailScreen(pair: p)));
  }

  @override
  Widget build(BuildContext context) {
    final dp     = context.watch<DataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = _catColor(_category);

    final allPairs    = dp.pairs;
    final filtered    = allPairs.where((p) => p.category == _category).toList();
    final tickerPairs = allPairs.where((p) => p.category == 'Forex').toList();

    return Scaffold(
      body: dp.isLoading && allPairs.isEmpty
          ? _buildLoading()
          : CustomScrollView(slivers: [

              SliverToBoxAdapter(child: _TickerBanner(pairs: tickerPairs)),

              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16,16,16,0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Row(children: [
                    const LiveDot(),
                    const SizedBox(width:8),
                    Text(
                      dp.lastUpdated != null ? 'Updated: ' : 'Connecting...',
                      style: TextStyle(fontSize:10, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
                    ),
                    const Spacer(),
                    _ApiDot('FX',  dp.apiStatus['forex']??false,       AppColors.cyan),
                    _ApiDot('IDX', dp.apiStatus['indices']??false,     AppColors.gold),
                    _ApiDot('STK', dp.apiStatus['stocks']??false,      AppColors.green),
                    _ApiDot('CRY', dp.apiStatus['crypto']??false,      const Color(0xFFFF9800)),
                    _ApiDot('COM', dp.apiStatus['commodities']??false,  const Color(0xFFE040FB)),
                    _ApiDot('FUT', dp.apiStatus['futures']??false,     AppColors.red),
                  ]),

                  const SizedBox(height:12),
                  const SectionHeader(label:'ExchangeRate · CoinGecko · Yahoo Finance · Tiingo', title:'Live', titleAccent:'Markets'),

                  SizedBox(height:40, child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_,__) => const SizedBox(width:8),
                    itemBuilder: (ctx,i) {
                      final cat = _categories[i];
                      final sel = cat == _category;
                      final cc  = _catColor(cat);
                      return GestureDetector(
                        onTap: () => setState(() { _category = cat; _selectedIndex = 0; }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds:200),
                          padding: const EdgeInsets.symmetric(horizontal:14, vertical:8),
                          decoration: BoxDecoration(
                            color: sel ? cc.withOpacity(0.18) : (isDark ? AppColors.navyCard : AppColors.lightCard),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: sel ? cc : (isDark ? AppColors.navyBorder : AppColors.lightBorder), width: sel?1.5:1),
                            boxShadow: sel ? [BoxShadow(color:cc.withOpacity(0.2), blurRadius:8)] : null,
                          ),
                          child: Row(mainAxisSize:MainAxisSize.min, children:[
                            Text(_catEmoji(cat), style:const TextStyle(fontSize:12)),
                            const SizedBox(width:5),
                            Text(cat, style:TextStyle(fontSize:12, fontWeight:FontWeight.w700, color: sel?cc:(isDark?AppColors.mutedDark:AppColors.mutedLight))),
                          ]),
                        ),
                      );
                    },
                  )),

                  const SizedBox(height:14),

                  if (filtered.isNotEmpty)
                    GestureDetector(
                      onTap: () => _openDetail(filtered[_selectedIndex]),
                      child: GlowCard(
                        glowColor: color,
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[
                            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                              Text(' ',
                                style:TextStyle(fontSize:12, color:isDark?AppColors.mutedDark:AppColors.mutedLight)),
                              const SizedBox(height:4),
                              Text(_fmt(filtered[_selectedIndex]),
                                style:TextStyle(fontSize:28, fontWeight:FontWeight.w800, fontFamily:'monospace', color:color)),
                              Row(children:[
                                Icon(filtered[_selectedIndex].isUp?Icons.arrow_drop_up:Icons.arrow_drop_down,
                                  color:filtered[_selectedIndex].isUp?AppColors.green:AppColors.red, size:18),
                                Text('%',
                                  style:TextStyle(fontSize:13, fontWeight:FontWeight.w600,
                                    color:filtered[_selectedIndex].isUp?AppColors.green:AppColors.red)),
                              ]),
                            ])),
                            Column(crossAxisAlignment:CrossAxisAlignment.end, children:[
                              const LiveDot(),
                              const SizedBox(height:10),
                              SparkLine(data:filtered[_selectedIndex].spark, isUp:filtered[_selectedIndex].isUp, width:90, height:36),
                              const SizedBox(height: 8),
                              Icon(Icons.touch_app, size: 14, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
                            ]),
                          ]),
                          const SizedBox(height:10),
                          const Divider(),
                          const SizedBox(height:8),
                          Row(children:[
                            _StatBox(label:'Change',
                              value:(filtered[_selectedIndex].change>=0?'+':'')+filtered[_selectedIndex].change.toStringAsFixed(4)),
                            _StatBox(label:'% Change',
                              value:(filtered[_selectedIndex].changePct>=0?'+':'')+filtered[_selectedIndex].changePct.toStringAsFixed(2)+'%'),
                            _StatBox(label:'Category', value:_category),
                          ]),
                          const SizedBox(height: 8),
                          Center(child: Text('Tap for full details →',
                            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600))),
                        ]),
                      ),
                    )
                  else
                    GlowCard(padding:const EdgeInsets.all(24),
                      child:Center(child:Column(children:[
                        Text(_catEmoji(_category), style:const TextStyle(fontSize:40)),
                        const SizedBox(height:12),
                        Text('Loading ...',
                          style:TextStyle(color:isDark?AppColors.mutedDark:AppColors.mutedLight)),
                        const SizedBox(height:8),
                        CircularProgressIndicator(color:color, strokeWidth:2),
                      ]))),

                  const SizedBox(height:8),
                  GestureDetector(
                    onTap: () => dp.refresh(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal:14, vertical:7),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color:color.withOpacity(0.3))),
                      child: Row(mainAxisSize:MainAxisSize.min, children:[
                        Icon(Icons.refresh, size:14, color:color),
                        const SizedBox(width:6),
                        Text('Refresh', style:TextStyle(fontSize:11, color:color, fontWeight:FontWeight.w600)),
                      ]),
                    ),
                  ),
                ]),
              )),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:2, mainAxisSpacing:10, crossAxisSpacing:10, childAspectRatio:1.55),
                  delegate: SliverChildBuilderDelegate(
                    (ctx,i) => GestureDetector(
                      onTap: () => _openDetail(filtered[i]),
                      child: _PairCard(pair:filtered[i], catColor:color),
                    ),
                    childCount: filtered.length),
                ),
              ),
            ]),
    );
  }

  Widget _buildLoading() => const Center(child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[
    CircularProgressIndicator(color:AppColors.green),
    SizedBox(height:16),
    Text('Loading live market data...', style:TextStyle(color:AppColors.mutedDark)),
  ]));

  Widget _ApiDot(String label, bool active, Color color) => Container(
    margin: const EdgeInsets.only(left:3),
    padding: const EdgeInsets.symmetric(horizontal:4, vertical:2),
    decoration: BoxDecoration(
      color: active ? color.withOpacity(0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: active ? color : AppColors.mutedDark.withOpacity(0.3))),
    child: Text(label, style:TextStyle(fontSize:8, fontWeight:FontWeight.w700, color:active?color:AppColors.mutedDark)));
}

class _StatBox extends StatelessWidget {
  final String label, value;
  const _StatBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child:Column(children:[
      Text(label, style:TextStyle(fontSize:10, color:isDark?AppColors.mutedDark:AppColors.mutedLight, letterSpacing:0.5)),
      const SizedBox(height:3),
      Text(value, style:const TextStyle(fontSize:11, fontWeight:FontWeight.w700, fontFamily:'monospace'), overflow:TextOverflow.ellipsis),
    ]));
  }
}

class _PairCard extends StatelessWidget {
  final ForexPair pair;
  final Color catColor;
  const _PairCard({required this.pair, required this.catColor});

  String _fmt(ForexPair p) {
    if (p.price >= 10000) return p.price.toStringAsFixed(2);
    if (p.price >= 100)   return p.price.toStringAsFixed(2);
    if (p.price >= 1)     return p.price.toStringAsFixed(4);
    return p.price.toStringAsFixed(5);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final up     = pair.isUp;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color:isDark?AppColors.navyBorder:AppColors.lightBorder)),
      child: Stack(children:[
        Positioned(top:0, left:0, right:0, child:Container(height:2,
          decoration:BoxDecoration(
            color: up ? AppColors.green : AppColors.red,
            borderRadius:const BorderRadius.only(topLeft:Radius.circular(12), topRight:Radius.circular(12))))),
        Padding(padding:const EdgeInsets.fromLTRB(10,12,10,8),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start, mainAxisSize:MainAxisSize.min, children:[
            Text(pair.flag, style:const TextStyle(fontSize:14)),
            const SizedBox(height:2),
            Text(pair.pair, style:const TextStyle(fontSize:11, fontWeight:FontWeight.w700, fontFamily:'monospace'), overflow:TextOverflow.ellipsis),
            const SizedBox(height:2),
            Text(_fmt(pair), style:TextStyle(fontSize:14, fontWeight:FontWeight.w800, fontFamily:'monospace', color:catColor)),
            const SizedBox(height:2),
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[
              Flexible(child:Text((pair.changePct>=0?'+':'')+pair.changePct.toStringAsFixed(2)+'%',
                style:TextStyle(fontSize:11, fontWeight:FontWeight.w600, color:up?AppColors.green:AppColors.red))),
              SparkLine(data:pair.spark, isUp:up, width:55, height:22),
            ]),
          ])),
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    _t = Timer.periodic(const Duration(milliseconds:30), (_) {
      if (!_sc.hasClients) return;
      final mx = _sc.position.maxScrollExtent;
      if (_sc.offset >= mx) { _sc.jumpTo(0); }
      else { _sc.animateTo(_sc.offset+1.5, duration:const Duration(milliseconds:30), curve:Curves.linear); }
    });
  }

  @override void dispose() { _t?.cancel(); _sc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pairs  = widget.pairs.isEmpty
        ? SampleData.pairs.where((p) => p.category == 'Forex').toList()
        : widget.pairs;
    return Container(height:36,
      color: isDark ? AppColors.navyCard : AppColors.lightCard2,
      child: ListView.separated(
        controller: _sc,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal:16),
        itemCount: pairs.length * 2,
        separatorBuilder: (_,__) => Container(width:1, margin:const EdgeInsets.symmetric(vertical:10, horizontal:12), color:isDark?AppColors.navyBorder:AppColors.lightBorder),
        itemBuilder: (ctx,i) {
          final p = pairs[i % pairs.length];
          return Center(child:Row(mainAxisSize:MainAxisSize.min, children:[
            Text(' ', style:const TextStyle(fontSize:11, fontWeight:FontWeight.w600, fontFamily:'monospace')),
            Text(p.price>=10?p.price.toStringAsFixed(2):p.price.toStringAsFixed(4),
              style:TextStyle(fontSize:11, fontFamily:'monospace', color:isDark?AppColors.cyan:const Color(0xFF0088AA))),
            const SizedBox(width:4),
            Text(' %',
              style:TextStyle(fontSize:10, color:p.isUp?AppColors.green:AppColors.red)),
          ]));
        },
      ));
  }
}






