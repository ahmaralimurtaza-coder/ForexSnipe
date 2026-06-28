import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});
  @override State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _controller = TextEditingController();
  final _scroll     = ScrollController();

  final List<_Msg> _messages = [
    _Msg(
      role: 'ai',
      text: "🎯 Assalam u Alaikum! I'm **Forex Sniper** — your AI Market Analyst.\n\n"
          "I'm trained to help you:\n"
          "• 📊 Analyze COT report signals\n"
          "• 💱 Explain currency pair movements\n"
          "• 📈 Read market sentiment correctly\n"
          "• 📅 Understand economic events impact\n"
          "• 🛢️ Track commodities & indices\n"
          "• ₿ Analyze crypto market trends\n\n"
          "Ask me anything — I snipe the best trades! 🎯",
    ),
  ];

  bool _loading = false;

  final _suggestions = const [
    '🎯 Snipe EUR/USD setup',
    '📊 COT signal for Gold',
    '💡 Best trade this week?',
    '📈 Why is USD rising?',
    '₿ Bitcoin outlook today',
    '🛢️ Oil price analysis',
    '📅 NFP impact on USD',
    '🔍 COT vs Sentiment',
  ];

  String _getResponse(String q) {
    final ql = q.toLowerCase();

    if (ql.contains('cot') && (ql.contains('eur') || ql.contains('euro'))) {
      return "🎯 **Forex Sniper COT Analysis — EUR/USD**\n\n"
          "Latest CFTC Data:\n\n"
          "🟢 Non-Commercial (Hedge Funds): NET LONG\n"
          "   → Speculators bullish on EUR\n\n"
          "🔴 Commercial Hedgers: NET SHORT\n"
          "   → Banks hedging long exposure\n\n"
          "🟡 Small Traders: Neutral\n\n"
          "📊 **Sniper Signal: BULLISH EUR/USD**\n\n"
          "When hedge funds increase net longs week-over-week → trend confirmation. "
          "Watch for reversal when positions reach historic extremes.\n\n"
          "🎯 Sniper Entry Zone: Look for pullbacks to support!";
    }

    if (ql.contains('cot') && (ql.contains('gold') || ql.contains('xau'))) {
      return "🎯 **Forex Sniper COT Analysis — XAU/USD (Gold)**\n\n"
          "Latest CFTC Data:\n\n"
          "🟢 Non-Commercial: +284,200 LONG positions\n"
          "🔴 Commercial Hedgers: NET SHORT (hedging)\n"
          "📊 Bullish %: ~74% — approaching extreme\n\n"
          "⚠️ **Sniper Warning:**\n"
          "When retail + non-commercial both extremely long → "
          "smart money (commercials) positioning short.\n\n"
          "🎯 **Sniper Strategy:**\n"
          "Wait for pullback. If COT net longs decrease next week → "
          "possible reversal signal. Strong support at previous week low.";
    }

    if (ql.contains('nfp') || ql.contains('non-farm') || ql.contains('payroll')) {
      return "🎯 **Forex Sniper — NFP Playbook**\n\n"
          "Non-Farm Payrolls = Most explosive USD event!\n\n"
          "📈 **Better than Expected:**\n"
          "→ USD strengthens immediately\n"
          "→ EUR/USD drops, GBP/USD drops\n"
          "→ USD/JPY rises sharply\n"
          "→ Gold (XAU/USD) falls\n\n"
          "📉 **Worse than Expected:**\n"
          "→ USD weakens across board\n"
          "→ AUD/USD, NZD/USD rise\n"
          "→ Gold rallies\n\n"
          "🎯 **Sniper Tip:**\n"
          "NEVER enter right at release — spread explodes!\n"
          "Wait 3-5 minutes for volatility to settle.\n"
          "Then snipe the continuation move. 🎯";
    }

    if (ql.contains('hawkish') || ql.contains('fed') || ql.contains('interest rate')) {
      return "🎯 **Forex Sniper — Fed & Interest Rates**\n\n"
          "🏦 **Hawkish Fed = Strong USD:**\n\n"
          "Hawkish = Fed wants HIGHER rates\n\n"
          "Effect on markets:\n"
          "• USD/JPY: ⬆️ RISES\n"
          "• EUR/USD: ⬇️ FALLS\n"
          "• GBP/USD: ⬇️ FALLS\n"
          "• XAU/USD: ⬇️ FALLS (gold no interest)\n"
          "• Crypto:  ⬇️ Usually falls\n\n"
          "🕊️ **Dovish Fed = Weak USD:**\n"
          "• EUR/USD: ⬆️ RISES\n"
          "• Gold:    ⬆️ RALLIES\n"
          "• Crypto:  ⬆️ Often rises\n\n"
          "🎯 **Sniper Rule:**\n"
          "Trade WITH the central bank — not against it!";
    }

    if (ql.contains('sentiment')) {
      return "🎯 **Forex Sniper — Sentiment Analysis**\n\n"
          "Retail sentiment = CONTRARIAN indicator!\n\n"
          "📊 **How to Read It:**\n\n"
          "If 75%+ retail = LONG →\n"
          "🎯 Smart money likely SHORT\n"
          "→ Sniper looks for SHORT opportunities\n\n"
          "If 75%+ retail = SHORT →\n"
          "🎯 Smart money likely LONG\n"
          "→ Sniper looks for LONG opportunities\n\n"
          "⚠️ **Extreme Readings (Most Powerful):**\n"
          "• >80% one direction = high probability reversal\n"
          "• Combine with COT for confirmation\n"
          "• Check economic calendar for catalyst\n\n"
          "🎯 **Sniper Formula:**\n"
          "COT Signal + Extreme Sentiment + Key Level = SNIPE! 🎯";
    }

    if (ql.contains('commercial') || ql.contains('non-commercial') || ql.contains('cot')) {
      return "🎯 **Forex Sniper — COT Breakdown**\n\n"
          "Three groups in COT report:\n\n"
          "🏢 **Commercials (Smart Money):**\n"
          "• Banks, corporations, exporters\n"
          "• Hedge real business risk\n"
          "• Usually OPPOSITE to trend\n"
          "• When extreme → near reversal\n\n"
          "🐋 **Non-Commercials (Whales):**\n"
          "• Hedge funds, large speculators\n"
          "• Trade for PROFIT\n"
          "• Follow the trend\n"
          "• Their direction = trend direction\n\n"
          "🐟 **Small Traders (Retail):**\n"
          "• Us — retail traders!\n"
          "• Often wrong at extremes\n"
          "• Use as contrarian signal\n\n"
          "🎯 **Sniper Signal:**\n"
          "Non-Commercial increasing longs + "
          "Commercial increasing shorts = "
          "Strong BULLISH trend! 🎯";
    }

    if (ql.contains('bitcoin') || ql.contains('btc') || ql.contains('crypto')) {
      return "🎯 **Forex Sniper — Bitcoin/Crypto Analysis**\n\n"
          "Current Market Structure:\n\n"
          "📊 **Key Levels to Watch:**\n"
          "• BTC resistance: \$70,000 psychological\n"
          "• BTC support: \$60,000 key zone\n\n"
          "📈 **Bullish Factors:**\n"
          "• ETF institutional inflows\n"
          "• Post-halving supply reduction\n"
          "• Risk-on market sentiment\n\n"
          "📉 **Bearish Risks:**\n"
          "• Fed hawkish = crypto sells off\n"
          "• Regulatory concerns\n"
          "• Whale distribution\n\n"
          "🎯 **Sniper Strategy:**\n"
          "Wait for weekly close above resistance.\n"
          "Strong close = buy the retest.\n"
          "Risk 1% per trade maximum! 🎯";
    }

    if (ql.contains('gold') || ql.contains('xau')) {
      return "🎯 **Forex Sniper — Gold Analysis**\n\n"
          "Gold (XAU/USD) Key Drivers:\n\n"
          "📈 **Bullish for Gold:**\n"
          "• USD weakness\n"
          "• Geopolitical tensions\n"
          "• Inflation fears\n"
          "• Fed rate cut expectations\n"
          "• Central bank buying\n\n"
          "📉 **Bearish for Gold:**\n"
          "• Strong USD\n"
          "• Rising real yields\n"
          "• Risk-on sentiment\n"
          "• Fed hawkish policy\n\n"
          "📊 **COT Signal:**\n"
          "Hedge funds hold large net longs → \n"
          "Bullish trend intact but watch for extreme!\n\n"
          "🎯 **Sniper Level:**\n"
          "Key support: \$2,300 zone\n"
          "Break above \$2,400 = new highs! 🎯";
    }

    if (ql.contains('oil') || ql.contains('crude') || ql.contains('wti')) {
      return "🎯 **Forex Sniper — Oil Analysis**\n\n"
          "WTI Crude Oil Key Factors:\n\n"
          "📈 **Bullish for Oil:**\n"
          "• OPEC+ production cuts\n"
          "• US inventory drawdown\n"
          "• Geopolitical risk (Middle East)\n"
          "• Strong global demand\n\n"
          "📉 **Bearish for Oil:**\n"
          "• US inventory build\n"
          "• Recession fears\n"
          "• OPEC+ output increase\n"
          "• Strong USD\n\n"
          "📊 **EIA Data:**\n"
          "Watch Wednesday 10:30am ET — \n"
          "Crude Oil Inventories = biggest oil mover!\n\n"
          "🎯 **Sniper Tip:**\n"
          "CAD strongly correlated with oil.\n"
          "Oil up → USD/CAD falls! 🎯";
    }

    if (ql.contains('snipe') || ql.contains('setup') || ql.contains('trade')) {
      return "🎯 **Forex Sniper — Trade Setup Checklist**\n\n"
          "Before ANY trade, check:\n\n"
          "✅ 1. COT Report\n"
          "   → Are hedge funds on your side?\n\n"
          "✅ 2. Market Sentiment\n"
          "   → Is retail extreme? (contrarian)\n\n"
          "✅ 3. Economic Calendar\n"
          "   → Any high impact news coming?\n\n"
          "✅ 4. Technical Level\n"
          "   → Key support/resistance zone?\n\n"
          "✅ 5. Risk Management\n"
          "   → Max 1-2% risk per trade\n\n"
          "✅ 6. Trend Direction\n"
          "   → Trade WITH the trend!\n\n"
          "🎯 **Sniper Rule:**\n"
          "All 6 aligned = SNIPE THE TRADE!\n"
          "Missing any = STAY OUT! 🎯";
    }

    if (ql.contains('usd') || ql.contains('dollar')) {
      return "🎯 **Forex Sniper — USD Analysis**\n\n"
          "US Dollar key drivers:\n\n"
          "📊 **USD Strengthens when:**\n"
          "• Fed is hawkish (rate hikes)\n"
          "• US economic data beats\n"
          "• Risk-off sentiment (safe haven)\n"
          "• NFP beats expectations\n"
          "• CPI higher than expected\n\n"
          "📊 **USD Weakens when:**\n"
          "• Fed dovish (rate cuts expected)\n"
          "• US data disappoints\n"
          "• Risk-on (markets rallying)\n"
          "• NFP misses expectations\n\n"
          "🎯 **Sniper Watch:**\n"
          "DXY (Dollar Index) above 105 = USD strong\n"
          "DXY below 100 = USD weak\n"
          "Trade EUR/USD OPPOSITE to DXY! 🎯";
    }

    if (ql.contains('best trade') || ql.contains('this week') || ql.contains('opportunity')) {
      return "🎯 **Forex Sniper — This Week's Opportunities**\n\n"
          "Based on current market analysis:\n\n"
          "💱 **Forex:**\n"
          "• EUR/USD: Watch Fed commentary\n"
          "• USD/JPY: BOJ policy key level\n"
          "• GBP/USD: UK data dependent\n\n"
          "🥇 **Commodities:**\n"
          "• Gold: Safe haven demand strong\n"
          "• Oil: OPEC decision pending\n\n"
          "₿ **Crypto:**\n"
          "• BTC: Institutional flows positive\n"
          "• ETH: Network upgrade bullish\n\n"
          "📈 **Indices:**\n"
          "• S&P 500: Earnings season key\n"
          "• Tech heavy — NVDA leads\n\n"
          "🎯 **Sniper Priority:**\n"
          "1st → Check COT tab\n"
          "2nd → Check Calendar tab\n"
          "3rd → Check Sentiment tab\n"
          "Then SNIPE! 🎯";
    }

    // Default response
    return "🎯 **Forex Sniper is analyzing...**\n\n"
        "Based on current market conditions:\n\n"
        "📊 **Market Overview:**\n"
        "• Forex: EUR/USD bullish bias (COT)\n"
        "• Crypto: BTC consolidating\n"
        "• Gold: Safe haven demand active\n"
        "• Indices: Cautious — watch Fed\n\n"
        "💡 **Ask me specifically about:**\n"
        "• A currency pair (EUR/USD, GBP/USD)\n"
        "• COT analysis for any market\n"
        "• Economic event impact\n"
        "• Trade setup checklist\n"
        "• Sentiment reading\n\n"
        "🎯 I'm Forex Sniper — precision is my game!";
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(role: 'user', text: text));
      _loading = true;
    });
    _controller.clear();
    _scrollDown();
    await Future.delayed(const Duration(milliseconds: 1400));
    setState(() {
      _messages.add(_Msg(role: 'ai', text: _getResponse(text)));
      _loading = false;
    });
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.green;

    return Scaffold(
      body: Column(children: [

        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Analyst card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.navyCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.green.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(children: [
                // Avatar
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green.withOpacity(0.15),
                    border: Border.all(color: AppColors.green, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.green.withOpacity(0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🎯', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('Forex Sniper',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green,
                          letterSpacing: 0.5,
                        )),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.green.withOpacity(0.4)),
                      ),
                      child: const Text('AI ANALYST',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.green,
                            letterSpacing: 1,
                          )),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text('Precision Market Intelligence',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                      )),
                  const SizedBox(height: 4),
                  Row(children: [
                    const LiveDot(),
                    const SizedBox(width: 6),
                    Text('Online — Ready to Snipe',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.green,
                          fontWeight: FontWeight.w500,
                        )),
                  ]),
                ])),
              ]),
            ),

            const SizedBox(height: 12),

            // Suggestion chips
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () {
                    _controller.text = _suggestions[i]
                        .replaceAll('🎯 ', '')
                        .replaceAll('📊 ', '')
                        .replaceAll('💡 ', '')
                        .replaceAll('📈 ', '')
                        .replaceAll('₿ ', '')
                        .replaceAll('🛢️ ', '')
                        .replaceAll('📅 ', '')
                        .replaceAll('🔍 ', '');
                    _send();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.navyCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
                    ),
                    child: Text(_suggestions[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                        )),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ]),
        ),

        // ── Chat messages ──
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == _messages.length) return _TypingIndicator();
              return _ChatBubble(msg: _messages[i]);
            },
          ),
        ),

        // ── Input bar ──
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.navyCard : AppColors.lightCard,
            border: Border(
                top: BorderSide(
                    color: isDark ? AppColors.navyBorder : AppColors.lightBorder)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            // Sniper icon
            Container(
              width: 36, height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withOpacity(0.1),
                border: Border.all(color: AppColors.green.withOpacity(0.3)),
              ),
              child: const Center(child: Text('🎯', style: TextStyle(fontSize: 18))),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Ask Forex Sniper anything...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.navyCard2 : AppColors.lightCard2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Msg {
  final String role, text;
  const _Msg({required this.role, required this.text});
}

class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAi   = msg.role == 'ai';

    return Padding(
      padding: EdgeInsets.only(
        bottom: 14,
        left:  isAi ? 0 : 50,
        right: isAi ? 50 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi) ...[
            // Forex Sniper avatar
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withOpacity(0.15),
                border: Border.all(color: AppColors.green.withOpacity(0.5)),
              ),
              child: const Center(child: Text('🎯', style: TextStyle(fontSize: 17))),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
              isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                // Name label for AI
                if (isAi)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 2),
                    child: Text('Forex Sniper',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                          letterSpacing: 0.3,
                        )),
                  ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isAi
                        ? (isDark ? AppColors.navyCard : AppColors.lightCard)
                        : AppColors.green,
                    borderRadius: BorderRadius.only(
                      topLeft:     Radius.circular(isAi ? 2 : 14),
                      topRight:    Radius.circular(isAi ? 14 : 2),
                      bottomLeft:  const Radius.circular(14),
                      bottomRight: const Radius.circular(14),
                    ),
                    border: isAi
                        ? Border.all(
                        color: isDark
                            ? AppColors.navyBorder
                            : AppColors.lightBorder)
                        : null,
                    boxShadow: isAi ? [
                      BoxShadow(
                        color: AppColors.green.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ] : null,
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: isAi
                          ? (isDark ? AppColors.textDark : AppColors.textLight)
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.green.withOpacity(0.15),
              border: Border.all(color: AppColors.green.withOpacity(0.5)),
            ),
            child: const Center(child: Text('🎯', style: TextStyle(fontSize: 17))),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 2),
                child: Text('Forex Sniper',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    )),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.navyCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isDark ? AppColors.navyBorder : AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎯 Sniping the answer',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                          fontStyle: FontStyle.italic,
                        )),
                    const SizedBox(width: 8),
                    ...List.generate(3, (i) => AnimatedBuilder(
                      animation: _c,
                      builder: (_, __) => Container(
                        width: 6, height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.green.withOpacity(
                              i == 0 ? _c.value
                                  : i == 1 ? (_c.value * 0.7)
                                  : (_c.value * 0.4)),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}