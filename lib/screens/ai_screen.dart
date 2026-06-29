import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});
  @override State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [
    _Msg(text: 'Hello! I am your ForexSnipe AI Analyst. Ask me about forex pairs, COT data, market sentiment, economic events, or trading strategies.', isUser: false),
  ];
  bool _loading = false;

  final _suggestions = [
    'What does COT data tell us?',
    'Explain EUR/USD outlook',
    'What is NFP impact on USD?',
    'How to read sentiment data?',
    'What is hawkish vs dovish?',
    'Explain support and resistance',
  ];

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, isUser: true));
      _loading = true;
    });
    _ctrl.clear();
    _scrollDown();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(text: _getResponse(text), isUser: false));
        _loading = false;
      });
      _scrollDown();
    });
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  String _getResponse(String q) {
    final t = q.toLowerCase();
    if (t.contains('cot') && t.contains('eur')) return 'EUR/USD COT: Non-commercials (hedge funds) are net LONG EUR. This is bullish for EUR/USD. Watch for extreme readings above 150K net longs as a potential reversal signal. Commercials are typically opposite — they hedge their exposure.';
    if (t.contains('cot')) return 'COT (Commitments of Traders) report is released every Friday by CFTC. Key groups:\n\n• Non-Commercials (Hedge Funds): Trend followers — most important for direction\n• Commercials: Hedgers — opposite to trend\n• Small Traders: Retail — contrarian at extremes\n\nWatch for extreme net positions as reversal signals.';
    if (t.contains('nfp') || t.contains('non-farm')) return 'NFP (Non-Farm Payrolls) is the most important USD event:\n\n• Released first Friday of each month\n• Beat forecast → USD bullish\n• Miss forecast → USD bearish\n• Average impact: 50-80 pips on major pairs\n\nTrade the revision + current number together for best signal.';
    if (t.contains('hawkish') || t.contains('dovish')) return 'Central bank stance:\n\n🦅 HAWKISH = Wants to raise rates\n• Fights inflation\n• Bullish for currency\n• Example: Fed hiking rates → USD bullish\n\n🕊️ DOVISH = Wants to cut rates\n• Stimulates economy\n• Bearish for currency\n• Example: ECB cutting → EUR bearish';
    if (t.contains('sentiment')) return 'Retail sentiment is a CONTRARIAN indicator:\n\n• 75%+ retail LONG → Smart money likely SHORT\n• 75%+ retail SHORT → Smart money likely LONG\n\nWhy? Retail traders are usually wrong at extremes. When everyone is long, there is no one left to buy — price must fall.\n\nCombine with COT data for confirmation.';
    if (t.contains('eur') || t.contains('eurusd')) return 'EUR/USD Analysis:\n\n• Trend: Bearish short-term (USD strength)\n• Key support: 1.0800\n• Key resistance: 1.0950\n• COT: Funds net long EUR — watch for reversal\n• Sentiment: 58% retail long — slightly contrarian bearish\n• Key events: ECB rate decision, US CPI data';
    if (t.contains('support') || t.contains('resistance')) return 'Support & Resistance:\n\n📊 Support = Price floor where buyers step in\n📊 Resistance = Price ceiling where sellers appear\n\nHow to find them:\n• Previous highs/lows\n• Round numbers (1.0800, 1.1000)\n• 50/200 day moving averages\n• Fibonacci levels (38.2%, 61.8%)\n\nStronger when tested multiple times.';
    if (t.contains('gold') || t.contains('xau')) return 'Gold (XAU/USD) Analysis:\n\n• Safe haven — rises on uncertainty\n• Inverse correlation with USD\n• Key drivers: Fed policy, inflation, geopolitics\n• COT: Funds heavily long gold — bullish\n• Key levels: Support 2300, Resistance 2400\n• Seasonality: Strong in Q1 and Q3';
    if (t.contains('bitcoin') || t.contains('btc') || t.contains('crypto')) return 'Bitcoin Analysis:\n\n• Post-halving cycle — historically bullish 12-18 months\n• Institutional adoption via ETFs driving demand\n• Key support: 60,000 - 62,000\n• Key resistance: 72,000 - 75,000\n• Correlation with risk assets (Nasdaq)\n• Watch: Fed policy, ETF flows, on-chain data';
    return 'Great question! As your ForexSnipe AI Analyst, I analyze:\n\n📊 COT positioning data\n💱 Forex pair technicals\n📰 Market news sentiment\n📅 Economic calendar impact\n🎯 Trading setups\n\nAsk me about specific pairs, indicators, or market events for detailed analysis!';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16,16,16,0),
          child: const SectionHeader(label: 'AI-Powered Market Intelligence', title: 'AI', titleAccent: 'Analyst')),
        Expanded(child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _messages.length + (_loading ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i == _messages.length) return _TypingIndicator();
            final msg = _messages[i];
            return Padding(padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!msg.isUser) Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.green.withOpacity(0.2), border: Border.all(color: AppColors.green.withOpacity(0.4))),
                    child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16)))),
                  Flexible(child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: msg.isUser ? AppColors.green : (isDark ? AppColors.navyCard : AppColors.lightCard),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                        bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                      ),
                      border: msg.isUser ? null : Border.all(color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
                    ),
                    child: Text(msg.text, style: TextStyle(fontSize: 13, height: 1.6, color: msg.isUser ? Colors.white : null)),
                  )),
                ],
              ));
          },
        )),
        // Suggestions
        if (_messages.length <= 2)
          SizedBox(height: 44, child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _send(_suggestions[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.green.withOpacity(0.3))),
                child: Text(_suggestions[i], style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w500)),
              )),
          )),
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.fromLTRB(16,0,16,16),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _ctrl,
              onSubmitted: _send,
              decoration: InputDecoration(
                hintText: 'Ask about forex, COT, crypto...',
                hintStyle: TextStyle(color: isDark ? AppColors.mutedDark : AppColors.mutedLight, fontSize: 13),
                filled: true,
                fillColor: isDark ? AppColors.navyCard : AppColors.lightCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: isDark ? AppColors.navyBorder : AppColors.lightBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: isDark ? AppColors.navyBorder : AppColors.lightBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            )),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _send(_ctrl.text),
              child: Container(width: 46, height: 46,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.green, boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.4), blurRadius: 10)]),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
            ),
          ])),
      ]),
    );
  }
}

class _Msg { final String text; final bool isUser; const _Msg({required this.text, required this.isUser}); }

class _TypingIndicator extends StatefulWidget { @override State<_TypingIndicator> createState() => _TypingIndicatorState(); }
class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _c; late Animation<double> _a;
  @override void initState() { super.initState(); _c=AnimationController(vsync:this,duration:const Duration(milliseconds:800))..repeat(reverse:true); _a=CurvedAnimation(parent:_c,curve:Curves.easeInOut); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom:12),
    child: Row(children: [
      Container(width:32,height:32,margin:const EdgeInsets.only(right:8),decoration:BoxDecoration(shape:BoxShape.circle,color:AppColors.green.withOpacity(0.2),border:Border.all(color:AppColors.green.withOpacity(0.4))),child:const Center(child:Text('🤖',style:TextStyle(fontSize:16)))),
      AnimatedBuilder(animation:_a,builder:(_,__)=>Row(children:List.generate(3,(i)=>Container(width:8,height:8,margin:const EdgeInsets.only(right:4),decoration:BoxDecoration(shape:BoxShape.circle,color:AppColors.green.withOpacity(0.3+0.7*_a.value)))))),
    ]));
}
