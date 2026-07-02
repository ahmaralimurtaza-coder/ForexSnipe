import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class BarchartScreen extends StatefulWidget {
  const BarchartScreen({super.key});
  @override State<BarchartScreen> createState() => _BarchartScreenState();
}

class _BarchartScreenState extends State<BarchartScreen> {
  String _symbol = 'EURUSD';
  String _interval = '60';
  late WebViewController _controller;

  final _pairs = const [
    ['EUR/USD', 'EURUSD'],
    ['GBP/USD', 'GBPUSD'],
    ['USD/JPY', 'USDJPY'],
    ['AUD/USD', 'AUDUSD'],
    ['USD/CHF', 'USDCHF'],
    ['Gold',    'XAUUSD'],
    ['Silver',  'XAGUSD'],
    ['BTC/USD', 'BTCUSD'],
    ['ETH/USD', 'ETHUSD'],
    ['S&P 500', 'SPX500'],
    ['Oil',     'USOIL'],
  ];

  final _intervals = const [
    ['1m',  '1'],
    ['5m',  '5'],
    ['15m', '15'],
    ['1H',  '60'],
    ['4H',  '240'],
    ['1D',  'D'],
    ['1W',  'W'],
  ];

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_buildHtml(_symbol, _interval));
  }

  String _buildHtml(String symbol, String interval) {
    return '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { background: #0A0F1E; }
  .tradingview-widget-container { width: 100%; height: 100vh; }
</style>
</head>
<body>
<div class="tradingview-widget-container">
  <div id="tv_chart"></div>
  <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
  <script type="text/javascript">
  new TradingView.widget({
    "width": "100%",
    "height": "100%",
    "symbol": "FX:$symbol",
    "interval": "$interval",
    "timezone": "Etc/UTC",
    "theme": "dark",
    "style": "1",
    "locale": "en",
    "toolbar_bg": "#0A0F1E",
    "enable_publishing": false,
    "hide_top_toolbar": false,
    "hide_legend": false,
    "save_image": false,
    "container_id": "tv_chart"
  });
  </script>
</div>
</body>
</html>
''';
  }

  void _loadChart() {
    _controller.loadHtmlString(_buildHtml(_symbol, _interval));
  }

  Color _catColor(String sym) {
    if (['BTCUSD','ETHUSD'].contains(sym)) return const Color(0xFFFF9800);
    if (['XAUUSD','XAGUSD'].contains(sym)) return AppColors.gold;
    if (['SPX500','USOIL'].contains(sym))  return AppColors.cyan;
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = _catColor(_symbol);
    return Scaffold(
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16,16,16,8),
          child: const SectionHeader(label: 'TradingView \u00b7 Real-Time Charts', title: 'Live', titleAccent: 'Charts')),
        SizedBox(height: 38, child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _pairs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final label = _pairs[i][0];
            final sym   = _pairs[i][1];
            final sel   = sym == _symbol;
            final cc    = _catColor(sym);
            return GestureDetector(
              onTap: () { setState(() => _symbol = sym); _loadChart(); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: sel ? cc.withOpacity(0.15) : (isDark ? AppColors.navyCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: sel ? cc : (isDark ? AppColors.navyBorder : AppColors.lightBorder)),
                ),
                alignment: Alignment.center,
                child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: sel ? cc : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
              ),
            );
          },
        )),
        const SizedBox(height: 6),
        SizedBox(height: 34, child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _intervals.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (ctx, i) {
            final label = _intervals[i][0];
            final val   = _intervals[i][1];
            final sel   = val == _interval;
            return GestureDetector(
              onTap: () { setState(() => _interval = val); _loadChart(); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: sel ? color.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: sel ? color : (isDark ? AppColors.navyBorder : AppColors.lightBorder)),
                ),
                alignment: Alignment.center,
                child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: sel ? color : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
              ),
            );
          },
        )),
        const SizedBox(height: 8),
        Expanded(child: Padding(
          padding: const EdgeInsets.fromLTRB(16,0,16,16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: WebViewWidget(controller: _controller),
          ),
        )),
      ]),
    );
  }
}
