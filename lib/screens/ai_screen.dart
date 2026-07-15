import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/data_provider.dart';
import 'learn_screen.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});
  @override State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _ctrl   = TextEditingController();
  bool _showLearn = false;
  final _scroll = ScrollController();
  final List<_Msg> _messages = [
    _Msg(text: 'Hello! I am your ForexSnipe AI Analyst. I can discuss forex pairs, central banks, technical analysis, chart patterns, risk management, trading psychology, COT data, crypto, commodities, live prices, and the in-app Trading Quiz from this app. Ask me anything!', isUser: false),
  ];
  bool _loading = false;

  final _suggestions = [
    'Explain EUR/USD outlook',
    'What is the Fed doing?',
    'How to read RSI?',
    'What is risk management?',
    'Explain head and shoulders pattern',
    'What is leverage in forex?',
    'What is the trading quiz?',
  ];

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, isUser: true));
      _loading = true;
    });
    _ctrl.clear();
    _scrollDown();
    Future.delayed(const Duration(milliseconds: 1000), () {
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

  String _livePriceLine(String pairName) {
    try {
      final dp = context.read<DataProvider>();
      final p  = dp.pairs.where((x) => x.pair.toUpperCase() == pairName.toUpperCase()).toList();
      if (p.isNotEmpty) {
        final pr = p.first;
        final fmt = pr.price >= 100 ? pr.price.toStringAsFixed(2) : pr.price.toStringAsFixed(4);
        return '\n\nLIVE: \ (\\% today)';
      }
    } catch (_) {}
    return '';
  }

  String _getResponse(String q) {
    final t = q.toLowerCase();

    // ═══ APP LIMITATIONS & DATA ACCURACY ═══
    if (t.contains('limitation') || t.contains('delay') || t.contains('accuracy') || t.contains('drawback') || t.contains('real time') || t.contains('realtime') || t.contains('live data') || t.contains('data source') || t.contains('how accurate') || t.contains('app info')) {
      return 'ForexSnipe Data Sources & Limitations:\n\nPRICES TAB\n- Forex: 15-60 min delayed (ExchangeRate/Frankfurter APIs)\n- Crypto BTC/ETH: Real-time via Binance\n- Gold XAU/XAG: Near real-time via GoldAPI\n- Stocks/Indices: 15-min delayed via Yahoo Finance\n\nCOT TAB\n- Data from CFTC.gov, released every Friday\n- Always 1 week behind by design\n- Numbers accurate, directly from CFTC\n\nNEWS TAB\n- Auto-refreshes every 5 minutes\n- Sources: Reuters, Bloomberg, CNBC, Finnhub\n\nCALENDAR TAB\n- Finnhub API, refreshes every 15 minutes\n\nWORLD TAB\n- Earthquakes: USGS, real-time (within minutes)\n- Disasters: NASA EONET (wildfires, storms, sea ice), refreshes every 5 minutes\n- World Events: GDELT global news monitor, ~15 min delay\n\nSENTIMENT TAB\n- Derived from COT data, same 1-week delay\n\nSOURCES TAB (Barchart Analysis)\n- Barchart Trader Cheat Sheet embedded\n- S/R levels, Pivots, Fibonacci, Moving Averages\n- Updated daily from Barchart.com\n\nQUIZ TAB\n- 170 questions, fully offline, no network needed\n- Easy (20), Medium (50), Hard (100) difficulty levels\n- Shuffled every attempt, instant feedback with explanations\n\nWARNING: Use ForexSnipe for context only. Always verify on TradingView before trading.';
    }

    // ═══ QUIZ FEATURE ═══
    if (t.contains('quiz') || t.contains('test my knowledge') || t.contains('test me') || t.contains('flashcard')) {
      return 'ForexSnipe Trading Quiz:\n\nFind it in the bottom nav bar (Quiz tab)\n\nThree difficulty levels:\n- Easy: 20 questions on candlestick basics and simple chart patterns\n- Medium: 50 questions on advanced candlesticks, chart patterns and indicators\n- Hard: 100 questions on prop firms, brokers, risk management, Smart Money Concepts and macro fundamentals\n\n170 total unique questions, shuffled every attempt\nInstant feedback with explanations after each answer\nScore tracking plus a review of missed questions at the end\n\nGreat way to test what you\'ve learned from this AI Analyst!';
    }

    // ═══ BARCHART BENEFITS ═══
    if (t.contains('barchart') || t.contains('cheat sheet') || t.contains('trader cheat') || t.contains('pivot point') || t.contains('key level')) {
      return 'Barchart Trader\u2019s Cheat Sheet (in Sources tab):\u000A\u000A\u{1F4CA} What it shows:\u000A\u2022 Support \u0026 Resistance levels (S1, S2, S3 / R1, R2, R3)\u000A\u2022 Pivot Points \u2014 calculated from previous day High/Low/Close\u000A\u2022 Fibonacci Retracement levels (23.6\u0025, 38.2\u0025, 50\u0025, 61.8\u0025, 78.6\u0025)\u000A\u2022 Moving Average crossover signals (9, 18, 40 day)\u000A\u2022 RSI overbought/oversold price targets\u000A\u2022 52-week High/Low levels\u000A\u000A\u{1F4A1} How to use it:\u000A\u2022 Open Sources tab \u2192 scroll down to BARCHART ANALYSIS section\u000A\u2022 Select your pair (EUR/USD, GBP/USD, Gold, BTC etc)\u000A\u2022 Use S/R levels as entry/exit targets\u000A\u2022 Combine with COT data for stronger confluence\u000A\u2022 Pivot points reset daily \u2014 check every morning before trading\u000A\u000A\u{1F3AF} Pro tip: Price above daily pivot = bullish bias. Price below = bearish bias. R1/R2 are profit targets, S1/S2 are stop-loss reference zones.';
    }

    // ═══ SPECIFIC PAIRS WITH LIVE DATA ═══
    if (t.contains('eur') && (t.contains('usd') || t.contains('dollar'))) {
      return 'EUR/USD Analysis:\n\n• ECB vs Fed policy divergence is the key driver\n• Watch German Bund yields vs US Treasuries for direction\n• Key technical levels: psychological round numbers (1.0800, 1.1000, 1.1200)\n• Eurozone CPI and US NFP are the biggest movers\n• Liquidity is highest during London-NY overlap (1pm-4pm GMT)' + _livePriceLine('EUR/USD');
    }
    if (t.contains('gbp') && (t.contains('usd') || t.contains('dollar') || t.contains('pound') || t.contains('cable'))) {
      return 'GBP/USD ("Cable") Analysis:\n\n• Most volatile major pair — moves fast on BoE and political news\n• UK inflation and wage growth data drive BoE rate expectations\n• Brexit-era volatility has calmed but UK political risk remains a factor\n• Correlates with EUR/USD due to shared European exposure\n• Key levels often align with 1.2500, 1.3000, 1.3500' + _livePriceLine('GBP/USD');
    }
    if (t.contains('usd/jpy') || t.contains('usdjpy') || (t.contains('yen') && t.contains('dollar'))) {
      return 'USD/JPY Analysis:\n\n• Driven primarily by US-Japan interest rate differential\n• BoJ intervention risk increases above 155-160 region historically\n• Safe-haven flows can cause sharp JPY strengthening during risk-off events\n• Correlates inversely with risk sentiment (stocks up = USD/JPY often up)\n• Carry trade unwinds can cause violent JPY rallies' + _livePriceLine('USD/JPY');
    }
    if (t.contains('aud') && t.contains('usd')) {
      return 'AUD/USD Analysis:\n\n• Heavily influenced by China economic data (Australia\'s biggest trade partner)\n• Iron ore and commodity prices directly impact AUD strength\n• RBA policy and China stimulus news are key catalysts\n• Considered a "risk-on" currency — rallies when global sentiment improves\n• Watch Chinese PMI and trade balance data' + _livePriceLine('AUD/USD');
    }
    if (t.contains('usd') && t.contains('cad')) {
      return 'USD/CAD Analysis:\n\n• Strongly correlated with WTI crude oil prices (inverse — oil up, CAD up, USD/CAD down)\n• Bank of Canada policy closely tracks the Fed but with its own domestic data\n• Canadian employment and CPI data move the pair\n• Watch oil inventories (EIA Wednesday reports) for CAD direction' + _livePriceLine('USD/CAD');
    }
    if (t.contains('gold') || t.contains('xau')) {
      return 'Gold (XAU/USD) Analysis:\n\n• Inverse correlation with USD and real interest rates\n• Safe-haven asset — rallies on geopolitical risk and recession fear\n• Central bank gold buying (especially China, India) supports long-term demand\n• Watch US 10-year TIPS yield as the key driver of gold price\n• Seasonally strong in September-February historically' + _livePriceLine('XAU/USD');
    }
    if (t.contains('silver') || t.contains('xag')) {
      return 'Silver (XAG/USD) Analysis:\n\n• More volatile than gold — has industrial demand component too\n• Gold/Silver ratio is a key metric: high ratio (80+) suggests silver undervalued\n• Solar panel demand has become a structural driver for silver\n• Tends to outperform gold in strong bull markets, underperform in bear markets' + _livePriceLine('XAG/USD');
    }
    if (t.contains('oil') || t.contains('crude') || t.contains('wti') || t.contains('brent')) {
      return 'Crude Oil Analysis:\n\n• OPEC+ production decisions are the biggest single catalyst\n• US EIA inventory report (Wednesdays) moves price short-term\n• Geopolitical risk in Middle East/Russia adds risk premium\n• WTI vs Brent spread reflects US vs global supply dynamics\n• China demand data is increasingly important for price direction' + _livePriceLine('WTI OIL');
    }
    if (t.contains('bitcoin') || t.contains('btc')) {
      return 'Bitcoin Analysis:\n\n• Institutional adoption via spot ETFs has changed market structure significantly\n• Halving cycles (every 4 years) historically precede major bull runs 12-18 months later\n• Correlates with risk assets (Nasdaq) more than traditional safe-haven gold\n• On-chain metrics (exchange flows, whale wallets) offer additional signal\n• Watch Fed policy — easier monetary policy generally supports crypto' + _livePriceLine('BTC/USD');
    }
    if (t.contains('ethereum') || t.contains('eth')) {
      return 'Ethereum Analysis:\n\n• Layer 2 scaling adoption (Arbitrum, Optimism, Base) reduces gas fees and drives usage\n• ETH/BTC ratio shows relative strength vs Bitcoin\n• Staking yield provides a "risk-free rate" within crypto markets\n• DeFi and NFT activity on Ethereum impacts network demand\n• Spot ETF flows are an increasingly important catalyst' + _livePriceLine('ETH/USD');
    }

    // ═══ CENTRAL BANKS ═══
    if (t.contains('fed') || t.contains('federal reserve') || t.contains('fomc')) {
      return 'The Federal Reserve (Fed):\n\n• Sets US monetary policy via the FOMC, meeting 8 times per year\n• Dual mandate: maximum employment + price stability (2% inflation target)\n• Fed Funds Rate is the primary policy tool\n• Dot plot shows individual member rate projections\n• Powell press conferences (30 min after each decision) often move markets more than the rate decision itself\n• Hawkish = leaning toward rate hikes; Dovish = leaning toward cuts';
    }
    if (t.contains('ecb') || t.contains('european central bank')) {
      return 'The European Central Bank (ECB):\n\n• Sets monetary policy for the 20-country Eurozone\n• Primary mandate is price stability — 2% inflation target\n• Christine Lagarde is President since 2019\n• Governing Council meets every 6 weeks for rate decisions\n• Eurozone fragmentation (different growth rates across members) makes policy complex\n• German economic data often disproportionately influences ECB thinking';
    }
    if (t.contains('boe') || t.contains('bank of england')) {
      return 'The Bank of England (BoE):\n\n• UK\'s central bank, sets the Bank Rate\n• Monetary Policy Committee (MPC) votes on rate decisions — vote split is closely watched\n• Inflation Report (now Monetary Policy Report) released quarterly\n• UK has historically had stickier inflation than US/EU, keeping rates higher for longer\n• Sensitive to UK fiscal policy and political stability';
    }
    if (t.contains('boj') || t.contains('bank of japan')) {
      return 'The Bank of Japan (BoJ):\n\n• Ended negative interest rate policy in 2024 after decades of ultra-loose policy\n• Yield Curve Control (YCC) adjustments are major market events\n• Most dovish major central bank historically — slow to normalize policy\n• Intervenes directly in FX markets to support the Yen when it weakens excessively\n• Wage growth data is key to future policy normalization pace';
    }
    if (t.contains('rba') || t.contains('reserve bank of australia')) {
      return 'The Reserve Bank of Australia (RBA):\n\n• Sets the Cash Rate, meets monthly (except January)\n• Heavily influenced by Chinese economic conditions due to trade ties\n• Australia\'s economy is commodity and resource-export driven\n• Employment data is given high weight in policy decisions';
    }
    if (t.contains('hawkish') || t.contains('dovish')) {
      return 'Central Bank Stance:\n\n🦅 HAWKISH = Leaning toward higher rates / fighting inflation\n• Bullish for the currency (higher yields attract capital)\n• Often follows strong inflation or employment data\n\n🕊️ DOVISH = Leaning toward lower rates / supporting growth\n• Bearish for the currency (lower yields, less capital attraction)\n• Often follows weak growth or falling inflation\n\nMarkets react more to the CHANGE in tone than the actual rate decision.';
    }

    // ═══ TECHNICAL ANALYSIS ═══
    if (t.contains('rsi') || t.contains('relative strength')) {
      return 'RSI (Relative Strength Index):\n\n• Momentum oscillator, scale 0-100\n• Above 70 = overbought (potential reversal down)\n• Below 30 = oversold (potential reversal up)\n• Divergence (price makes new high, RSI doesn\'t) is a strong reversal signal\n• Works best in ranging markets; can stay overbought/oversold in strong trends\n• Common settings: 14-period';
    }
    if (t.contains('macd')) {
      return 'MACD (Moving Average Convergence Divergence):\n\n• Trend-following momentum indicator\n• Made of MACD line, Signal line, and Histogram\n• Bullish crossover: MACD line crosses above Signal line\n• Bearish crossover: MACD line crosses below Signal line\n• Histogram shows the gap between the two lines — shrinking histogram suggests weakening momentum\n• Standard settings: 12, 26, 9';
    }
    if (t.contains('moving average') || t.contains(' ma ') || t.contains('sma') || t.contains('ema')) {
      return 'Moving Averages:\n\n• SMA (Simple) = average of last N closes, equal weight\n• EMA (Exponential) = weights recent prices more, reacts faster\n• Golden Cross: 50 MA crosses above 200 MA = bullish signal\n• Death Cross: 50 MA crosses below 200 MA = bearish signal\n• Price above MA = uptrend bias; below = downtrend bias\n• Common periods: 20, 50, 100, 200';
    }
    if (t.contains('fibonacci') || t.contains('fib retracement')) {
      return 'Fibonacci Retracement:\n\n• Key levels: 23.6%, 38.2%, 50%, 61.8%, 78.6%\n• Used to identify potential support/resistance during pullbacks in a trend\n• 61.8% ("golden ratio") is considered the most significant level\n• Draw from swing low to swing high (uptrend) or high to low (downtrend)\n• Combine with other confluence (round numbers, previous S/R) for stronger signals';
    }
    if (t.contains('support') && t.contains('resistance')) {
      return 'Support & Resistance:\n\n📊 Support = price floor where buyers historically step in\n📊 Resistance = price ceiling where sellers historically appear\n\nHow to identify them:\n• Previous swing highs/lows\n• Round psychological numbers (1.1000, 2000.00)\n• Moving averages (50/200 period)\n• Fibonacci retracement levels\n\nA broken resistance often becomes new support (and vice versa) — known as "role reversal".';
    }
    if (t.contains('head and shoulders') || t.contains('h&s pattern')) {
      return 'Head and Shoulders Pattern:\n\n• Reversal pattern signaling a trend change from bullish to bearish\n• Three peaks: left shoulder, higher head, right shoulder (similar height to left)\n• "Neckline" connects the two troughs between peaks\n• Breaking below the neckline confirms the pattern\n• Inverse H&S (upside down) signals bullish reversal at the bottom of a downtrend\n• Measure target: height of head to neckline, projected down from breakout';
    }
    if (t.contains('double top') || t.contains('double bottom')) {
      return 'Double Top / Double Bottom:\n\n• Double Top: two peaks at similar price = bearish reversal signal\n• Double Bottom: two troughs at similar price = bullish reversal signal\n• Confirmation comes when price breaks the "neckline" (the low between two tops, or high between two bottoms)\n• Volume should ideally decrease on the second peak/trough vs the first\n• Common and reliable pattern across all timeframes';
    }
    if (t.contains('triangle pattern') || t.contains('ascending triangle') || t.contains('descending triangle')) {
      return 'Triangle Patterns:\n\n• Ascending Triangle: flat resistance, rising support = bullish continuation\n• Descending Triangle: flat support, falling resistance = bearish continuation\n• Symmetrical Triangle: converging trendlines = breakout direction uncertain, trade the break\n• Volume typically contracts as the triangle forms, then expands on breakout\n• Measured move target: height of triangle\'s widest point projected from breakout';
    }
    if (t.contains('candlestick') || t.contains('doji') || t.contains('hammer') || t.contains('pin bar')) {
      return 'Key Candlestick Patterns:\n\n🕯️ Doji: open ≈ close, signals indecision\n🕯️ Hammer: small body, long lower wick = bullish reversal at support\n🕯️ Shooting Star: small body, long upper wick = bearish reversal at resistance\n🕯️ Engulfing: large candle fully engulfs previous candle = strong reversal signal\n🕯️ Pin Bar: long wick rejecting a price level = reversal signal\n\nContext matters most — these patterns work best at key support/resistance levels.';
    }
    if (t.contains('bollinger')) {
      return 'Bollinger Bands:\n\n• Middle band = 20-period SMA\n• Upper/Lower bands = 2 standard deviations from the middle band\n• Price touching upper band = relatively overbought (in ranging markets)\n• Price touching lower band = relatively oversold\n• "Band squeeze" (narrowing) signals low volatility, often precedes a big move\n• In strong trends price can "walk the band" — stay near upper/lower band repeatedly';
    }
    if (t.contains('pivot point')) {
      return 'Pivot Points:\n\n• Calculated from previous period\'s high, low, close\n• Formula: Pivot = (High + Low + Close) / 3\n• R1, R2, R3 = resistance levels above pivot\n• S1, S2, S3 = support levels below pivot\n• Widely used by day traders for intraday support/resistance\n• Price above pivot = bullish bias for the session; below = bearish bias';
    }

    // ═══ RISK MANAGEMENT & PSYCHOLOGY ═══
    if (t.contains('risk management') || t.contains('position sizing')) {
      return 'Risk Management Fundamentals:\n\n• Never risk more than 1-2% of account capital on a single trade\n• Always use a stop loss — define your risk BEFORE entering\n• Position size = (Account Risk \$) / (Stop Loss in pips × pip value)\n• Risk:Reward ratio of at least 1:2 improves long-term profitability even with a 40% win rate\n• Diversify — don\'t put all capital into correlated pairs (e.g. EUR/USD and GBP/USD move together)\n• Track your trades in a journal to identify patterns in your mistakes';
    }
    if (t.contains('leverage')) {
      return 'Leverage in Forex:\n\n• Allows controlling a large position with a small deposit (margin)\n• Example: 50:1 leverage means \,000 controls a \,000 position\n• Amplifies BOTH profits and losses equally\n• High leverage is the #1 reason retail traders blow accounts\n• Conservative traders typically use effective leverage of 5:1 to 10:1, even if broker offers more\n• Regulatory limits vary by region (EU caps retail leverage at 30:1 for major pairs)';
    }
    if (t.contains('stop loss') || t.contains('take profit')) {
      return 'Stop Loss & Take Profit:\n\n• Stop Loss: automatically closes a losing trade at a predefined level — non-negotiable risk control\n• Take Profit: automatically closes a winning trade at a predefined target\n• Place stops beyond key support/resistance, not at arbitrary round numbers (avoids common stop-hunting zones)\n• Trailing stops lock in profit as price moves favorably\n• Never move a stop loss further away from price once trade is open — this is the #1 account-killing mistake';
    }
    if (t.contains('trading psychology') || t.contains('emotion') || t.contains('fomo') || t.contains('revenge trad')) {
      return 'Trading Psychology:\n\n• FOMO (Fear of Missing Out) leads to chasing trades without proper setup — biggest beginner mistake\n• Revenge trading after a loss compounds losses — step away after 2-3 consecutive losers\n• Overconfidence after wins often precedes the biggest losses\n• Stick to your trading plan even when emotions say otherwise\n• Professional traders focus on process (following their system) not individual trade outcomes\n• Journaling trades helps separate emotion from decision-making over time';
    }
    if (t.contains('drawdown')) {
      return 'Drawdown:\n\n• The peak-to-trough decline in account equity\n• Example: account goes from \,000 to \,000 = 20% drawdown\n• Recovering from drawdown requires a LARGER percentage gain (20% loss needs 25% gain to recover)\n• Maximum drawdown is a key risk metric for evaluating any trading strategy\n• Professional risk management aims to keep max drawdown under 20-25%';
    }

    // ═══ COT & SENTIMENT ═══
    if (t.contains('cot') && (t.contains('eur') || t.contains('forex'))) {
      return 'COT (Commitments of Traders) for Forex:\n\n• Released every Friday by the CFTC for the previous Tuesday\'s positions\n• Non-Commercials (hedge funds, speculators) = trend-following — most watched group\n• Commercials (banks, corporations hedging) = typically opposite direction to speculators\n• Extreme net-long or net-short positioning by speculators can signal an approaching reversal\n• Track week-over-week CHANGE in positioning, not just the absolute level';
    }
    if (t.contains('cot')) {
      return 'COT (Commitments of Traders) Report:\n\n• Official CFTC report showing positioning of large traders in futures markets\n• Released every Friday at 3:30pm EST for the previous Tuesday\'s data\n• Three trader categories: Non-Commercials (funds), Commercials (hedgers), Small Traders (retail)\n• Most useful for identifying extreme positioning that often precedes reversals\n• Available for currencies, commodities (gold, oil, etc), and stock indices';
    }
    if (t.contains('sentiment') || t.contains('retail position')) {
      return 'Retail Sentiment as a Contrarian Indicator:\n\n• Retail traders are statistically wrong more often than right at price extremes\n• 75%+ retail traders LONG → often signals smart money is positioned SHORT\n• 75%+ retail traders SHORT → often signals smart money is positioned LONG\n• Logic: when nearly everyone is already long, there are few buyers left to push price higher\n• Best used as one confirmation signal alongside technical and COT analysis, not standalone';
    }

    // ═══ ECONOMIC DATA ═══
    if (t.contains('nfp') || t.contains('non-farm') || t.contains('non farm')) {
      return 'NFP (Non-Farm Payrolls):\n\n• Released first Friday of each month at 8:30am EST\n• Single most important regular USD data release\n• Measures monthly change in US employment (excluding farm workers)\n• Beat forecast → typically USD bullish; Miss → typically USD bearish\n• Also watch the unemployment rate and average hourly earnings (wage inflation) released alongside\n• Average market impact: 50-100+ pips on major USD pairs within minutes';
    }
    if (t.contains('cpi') || (t.contains('inflation') && !t.contains('boj'))) {
      return 'CPI (Consumer Price Index) / Inflation Data:\n\n• Measures the change in prices of a basket of consumer goods and services\n• Core CPI excludes volatile food and energy prices — watched more closely by central banks\n• Higher than expected inflation → hawkish central bank expectations → currency bullish\n• Lower than expected → dovish expectations → currency bearish\n• Year-over-year (y/y) and month-over-month (m/m) figures are both released';
    }
    if (t.contains('gdp')) {
      return 'GDP (Gross Domestic Product):\n\n• Broadest measure of a country\'s total economic output\n• Released quarterly, often with preliminary, second, and final estimates\n• Strong GDP growth → currency bullish (signals healthy economy, potential rate hikes)\n• Recession is technically defined as two consecutive quarters of negative GDP growth\n• Quarter-over-quarter annualized is the most commonly quoted figure in the US';
    }
    if (t.contains('interest rate') || t.contains('rate decision') || t.contains('rate hike') || t.contains('rate cut')) {
      return 'Interest Rate Decisions:\n\n• The single biggest driver of currency value over the medium-to-long term\n• Higher rates attract foreign capital seeking yield → currency strengthens\n• Markets trade on EXPECTATIONS as much as actual decisions — a "priced in" hike may cause minimal reaction\n• Forward guidance (future rate path commentary) often moves markets more than the decision itself\n• Interest rate differentials between two countries drive that currency pair\'s long-term trend';
    }
    if (t.contains('pmi')) {
      return 'PMI (Purchasing Managers\' Index):\n\n• Survey-based leading indicator of economic health\n• Above 50 = expansion; Below 50 = contraction\n• Manufacturing PMI and Services PMI are released separately\n• Considered more timely than GDP since it\'s released monthly\n• S&P Global and ISM (US) are the two major PMI providers';
    }
    if (t.contains('employment') || t.contains('jobless claims') || t.contains('unemployment')) {
      return 'Employment Data:\n\n• Initial Jobless Claims released weekly (Thursdays) — leading indicator of labor market health\n• Unemployment Rate is a lagging indicator but heavily watched by central banks\n• Wage growth (Average Hourly Earnings) signals inflationary pressure from the labor market\n• Strong employment data generally supports a currency (healthy economy, less need for stimulus)';
    }

    // ═══ MARKET STRUCTURE ═══
    if (t.contains('pip') || t.contains('pips')) {
      return 'Pips Explained:\n\n• Smallest standardized price move in forex, usually the 4th decimal place (0.0001) for most pairs\n• JPY pairs are the exception — pip is the 2nd decimal place (0.01)\n• Pipette = 1/10th of a pip, used for more precise pricing\n• Pip value depends on position size and account currency\n• Standard lot (100,000 units) = ~\/pip for USD-quoted pairs';
    }
    if (t.contains('spread') && !t.contains('bid')) {
      return 'Bid-Ask Spread:\n\n• The difference between the buy (ask) price and sell (bid) price\n• Represents the broker\'s/market\'s transaction cost\n• Major pairs (EUR/USD, USD/JPY) have the tightest spreads due to high liquidity\n• Spreads widen during low-liquidity periods (Asian session, news events, weekends approaching)\n• Always factor spread cost into your risk:reward calculations';
    }
    if (t.contains('lot size') || t.contains('lot ')) {
      return 'Lot Sizes in Forex:\n\n• Standard Lot = 100,000 units of base currency\n• Mini Lot = 10,000 units\n• Micro Lot = 1,000 units\n• Nano Lot = 100 units (offered by some brokers)\n• Smaller lot sizes allow finer position sizing for proper risk management\n• Beginners should generally start with micro or mini lots';
    }
    if (t.contains('session') && (t.contains('trading') || t.contains('forex') || t.contains('london') || t.contains('tokyo') || t.contains('new york'))) {
      return 'Forex Trading Sessions:\n\n🌏 Tokyo/Asian Session: ~12am-9am GMT, lower volatility, JPY pairs most active\n🇬🇧 London Session: ~8am-5pm GMT, highest volume, EUR/GBP pairs most active\n🇺🇸 New York Session: ~1pm-10pm GMT, high volatility, USD pairs most active\n⭐ London-NY Overlap (1pm-5pm GMT): highest liquidity and volatility of the day — best for most strategies';
    }
    if (t.contains('correlation') && t.contains('pair')) {
      return 'Currency Pair Correlations:\n\n• Positive correlation: pairs move together (EUR/USD and GBP/USD often correlate positively)\n• Negative correlation: pairs move opposite (EUR/USD and USD/CHF often correlate negatively)\n• Trading multiple correlated pairs simultaneously effectively doubles your risk exposure\n• Correlation can shift over time — check rolling correlation, not just historical assumptions\n• Useful for diversification and for hedging existing positions';
    }

    // ═══ STOCKS / INDICES ═══
    if (t.contains('s&p') || t.contains('spx') || t.contains('s&p 500')) {
      return 'S&P 500 Analysis:\n\n• Tracks 500 largest US publicly traded companies, the most widely followed equity benchmark\n• Tech sector (Apple, Microsoft, Nvidia, etc) carries heavy weighting due to market cap\n• Moves on Fed policy expectations, earnings season results, and macro data\n• Often used as the broad "risk-on/risk-off" barometer for global markets' + _livePriceLine('S&P 500');
    }
    if (t.contains('nasdaq')) {
      return 'NASDAQ Analysis:\n\n• Tech-heavy index, more volatile than S&P 500\n• Highly sensitive to interest rate expectations — growth stocks are valued on future earnings, discounted more by higher rates\n• AI and semiconductor sector strength has been a major driver recently\n• Tends to outperform in risk-on, low-rate environments' + _livePriceLine('NASDAQ');
    }
    if (t.contains('vix') || t.contains('fear gauge') || t.contains('volatility index')) {
      return 'VIX (Volatility Index):\n\n• Measures expected 30-day volatility of S&P 500 options, nicknamed the "fear gauge"\n• Above 30 = high fear/uncertainty in markets\n• Below 15 = complacency/low fear\n• Inverse relationship with stocks — VIX spikes when stocks fall sharply\n• Useful as a contrarian indicator at extremes' + _livePriceLine('VIX');
    }

    // ═══ STRATEGY ═══
    if (t.contains('scalping')) {
      return 'Scalping Strategy:\n\n• Very short-term trading, holding positions for seconds to minutes\n• Targets small price movements, often just a few pips per trade\n• Requires tight spreads, fast execution, and high liquidity (major pairs during peak sessions)\n• High trade frequency means transaction costs (spread/commission) significantly impact profitability\n• Demands intense focus and is not suitable for beginners';
    }
    if (t.contains('swing trading')) {
      return 'Swing Trading Strategy:\n\n• Holds positions for several days to weeks, capturing medium-term price swings\n• Less screen time required compared to day trading or scalping\n• Relies heavily on technical analysis combined with fundamental catalysts\n• Wider stop losses needed to accommodate normal price fluctuation over the holding period\n• Good balance between day trading stress and long-term investing patience';
    }
    if (t.contains('day trading')) {
      return 'Day Trading Strategy:\n\n• Opens and closes all positions within the same trading day, no overnight risk\n• Avoids overnight gap risk and swap/rollover fees\n• Requires significant time commitment to monitor markets during active sessions\n• Higher trade frequency increases transaction cost impact\n• Most day traders focus on the highest-liquidity session for their chosen pairs';
    }

    // ═══ DEFAULT / GENERAL ═══
    return 'I can help analyze that. As your ForexSnipe AI Analyst, I cover:\n\n📊 Currency pairs (EUR/USD, GBP/USD, USD/JPY, etc) with live prices\n🏦 Central banks (Fed, ECB, BoE, BoJ, RBA)\n📈 Technical analysis (RSI, MACD, patterns, Fibonacci)\n💰 Risk management & trading psychology\n📅 Economic data (NFP, CPI, GDP, PMI)\n🎯 COT positioning & retail sentiment\n₿ Crypto (BTC, ETH) and commodities (Gold, Oil)\n🧠 Trading Quiz — test yourself with 170 questions\n\nTry asking about a specific pair, indicator, or concept for a detailed breakdown!';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16,16,16,0),
          child: const SectionHeader(label: 'AI-Powered Market Intelligence', title: 'AI', titleAccent: 'Analyst')),
        Padding(padding: const EdgeInsets.fromLTRB(16,8,16,0),
          child: Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => setState(() => _showLearn = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !_showLearn ? AppColors.cyan.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: !_showLearn ? AppColors.cyan : AppColors.navyBorder)),
                alignment: Alignment.center,
                child: Text('Chat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: !_showLearn ? AppColors.cyan : AppColors.mutedDark))))),
            const SizedBox(width: 8),
            Expanded(child: GestureDetector(
              onTap: () => setState(() => _showLearn = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _showLearn ? AppColors.green.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _showLearn ? AppColors.green : AppColors.navyBorder)),
                alignment: Alignment.center,
                child: Text('Learn', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: _showLearn ? AppColors.green : AppColors.mutedDark))))),
          ])),
        if (_showLearn) const Expanded(child: LearnScreen()),
        if (!_showLearn) Expanded(child: ListView.builder(
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











