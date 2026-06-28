import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/models.dart';
import '../models/sample_data.dart';
import 'api_service.dart';

class DataProvider extends ChangeNotifier {
  final _api = ApiService();
  final _rng = Random();

  List<ForexPair>     _pairs     = List.from(SampleData.pairs);
  List<NewsItem>      _news      = List.from(SampleData.news);
  List<CalendarEvent> _calendar  = List.from(SampleData.calendar);
  List<CotData>       _cotData   = List.from(SampleData.cotData);
  List<SentimentData> _sentiment = List.from(SampleData.sentiment);

  bool      _isLoading   = false;
  bool      _hasError    = false;
  String    _errorMsg    = '';
  DateTime? _lastUpdated;

  Map<String, bool> _apiStatus = {
    'forex':       false,
    'crypto':      false,
    'stocks':      false,
    'indices':     false,
    'futures':     false,
    'commodities': false,
    'news':        false,
    'calendar':    false,
    'cot':         false,
  };

  List<ForexPair>     get pairs       => _pairs;
  List<NewsItem>      get news        => _news;
  List<CalendarEvent> get calendar    => _calendar;
  List<CotData>       get cotData     => _cotData;
  List<SentimentData> get sentiment   => _sentiment;
  bool                get isLoading   => _isLoading;
  bool                get hasError    => _hasError;
  String              get errorMsg    => _errorMsg;
  DateTime?           get lastUpdated => _lastUpdated;
  Map<String, bool>   get apiStatus   => _apiStatus;

  Timer? _priceTimer;
  Timer? _newsTimer;
  Timer? _calendarTimer;
  Timer? _slowTimer;

  // ────────────────────────────────────────
  // INITIALIZE
  // ────────────────────────────────────────
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fast APIs parallel
      await Future.wait([
        _fetchForexPrices(),
        _fetchCryptoPrices(),
        _fetchAllNews(),
        _fetchCalendar(),
        _fetchCotData(),
      ]);

      // Slower APIs in background
      _fetchStocks();
      _fetchIndices();
      _fetchFutures();
      _fetchCommodities();

    } catch (e) {
      _hasError = true;
      _errorMsg = e.toString();
      print('Init error: $e');
    }

    _isLoading   = false;
    _lastUpdated = DateTime.now();
    notifyListeners();
    _startTimers();
  }

  void _startTimers() {
    // Forex + Crypto: every 30s
    _priceTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _fetchForexPrices();
      await _fetchCryptoPrices();
    });

    // News: every 5 min
    _newsTimer = Timer.periodic(
        const Duration(minutes: 5), (_) => _fetchAllNews());

    // Calendar: every 15 min
    _calendarTimer = Timer.periodic(
        const Duration(minutes: 15), (_) => _fetchCalendar());

    // Stocks + Indices + Futures: every 5 min
    _slowTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      _fetchStocks();
      _fetchIndices();
      _fetchFutures();
      _fetchCommodities();
    });
  }

  // ────────────────────────────────────────
  // FOREX — ExchangeRate + Fixer fallback
  // ────────────────────────────────────────
  Future<void> _fetchForexPrices() async {
    try {
      var rates = await _api.getForexRates();
      // Fallback to Fixer if empty
      if (rates.isEmpty) rates = await _api.getFixerRates();
      if (rates.isEmpty) return;

      _pairs = _pairs.map((pair) {
        if (pair.category != 'Forex') return pair;
        double newPrice = 0;
        switch (pair.pair) {
          case 'EUR/USD': newPrice = _api.getPairPrice(rates, 'EUR', 'USD'); break;
          case 'GBP/USD': newPrice = _api.getPairPrice(rates, 'GBP', 'USD'); break;
          case 'USD/JPY': newPrice = _api.getPairPrice(rates, 'USD', 'JPY'); break;
          case 'AUD/USD': newPrice = _api.getPairPrice(rates, 'AUD', 'USD'); break;
          case 'USD/CAD': newPrice = _api.getPairPrice(rates, 'USD', 'CAD'); break;
          case 'USD/CHF': newPrice = _api.getPairPrice(rates, 'USD', 'CHF'); break;
          case 'NZD/USD': newPrice = _api.getPairPrice(rates, 'NZD', 'USD'); break;
          case 'EUR/GBP': newPrice = _api.getPairPrice(rates, 'EUR', 'GBP'); break;
          case 'USD/TRY': newPrice = _api.getPairPrice(rates, 'USD', 'TRY'); break;
          case 'USD/ZAR': newPrice = _api.getPairPrice(rates, 'USD', 'ZAR'); break;
          default: return _jitterPair(pair);
        }
        if (newPrice <= 0) return _jitterPair(pair);
        final change    = newPrice - pair.price;
        final changePct = pair.price > 0 ? (change / pair.price) * 100 : 0.0;
        return ForexPair(
          pair: pair.pair, flag: pair.flag,
          price: newPrice, change: change,
          changePct: changePct, isUp: change >= 0,
          spark: [...pair.spark.skip(1), newPrice],
          category: pair.category,
        );
      }).toList();

      _apiStatus['forex'] = true;
      _lastUpdated        = DateTime.now();
      notifyListeners();
    } catch (e) {
      print('Forex error: $e');
    }
  }

  // ────────────────────────────────────────
  // CRYPTO — CoinGecko
  // ────────────────────────────────────────
  Future<void> _fetchCryptoPrices() async {
    try {
      final crypto = await _api.getCryptoPrices();
      if (crypto.isEmpty) return;

      const coinMap = {
        'BTC/USD': 'bitcoin',
        'ETH/USD': 'ethereum',
        'BNB/USD': 'binancecoin',
        'SOL/USD': 'solana',
        'XRP/USD': 'ripple',
        'ADA/USD': 'cardano',
        'DOGE':    'dogecoin',
        'AVAX':    'avalanche-2',
        'LINK':    'chainlink',
        'DOT':     'polkadot',
      };

      _pairs = _pairs.map((pair) {
        if (pair.category != 'Crypto') return pair;
        final coinId = coinMap[pair.pair];
        if (coinId == null) return _jitterPair(pair);
        final data = crypto[coinId] as Map<String, dynamic>?;
        if (data == null) return _jitterPair(pair);

        final price  = (data['price']     as num).toDouble();
        final chgPct = (data['changePct'] as num).toDouble();
        final change = (data['change']    as num).toDouble();
        final raw    = data['sparkline']  as List<double>;
        final spark  = raw.isNotEmpty
            ? (raw.length > 10 ? raw.sublist(raw.length - 10) : raw)
            : [...pair.spark.skip(1), price];

        return ForexPair(
          pair: pair.pair, flag: pair.flag,
          price: price, change: change,
          changePct: chgPct, isUp: chgPct >= 0,
          spark: List<double>.from(spark),
          category: pair.category,
        );
      }).toList();

      _apiStatus['crypto'] = true;
      notifyListeners();
    } catch (e) {
      print('Crypto error: $e');
    }
  }

  // ────────────────────────────────────────
  // STOCKS — Yahoo Finance + Tiingo
  // ────────────────────────────────────────
  Future<void> _fetchStocks() async {
    const stocks = [
      'AAPL','TSLA','NVDA','GOOGL','MSFT',
      'AMZN','META','NFLX','JPM','BABA'
    ];
    for (final sym in stocks) {
      try {
        final data = await _api.getBestStockQuote(sym);
        if (data.isNotEmpty && (data['price'] as double) > 0) {
          _updatePair(
            name:   sym,
            price:  data['price']     as double,
            change: data['change']    as double,
            chgPct: data['changePct'] as double,
            spark:  (data['spark']    as List<double>?) ?? [],
          );
          notifyListeners();
        }
      } catch (e) {
        print('Stock error ($sym): $e');
      }
      await Future.delayed(const Duration(milliseconds: 800));
    }
    _apiStatus['stocks'] = true;
    notifyListeners();
  }

  // ────────────────────────────────────────
  // INDICES — Yahoo Finance (Free, No Key)
  // ────────────────────────────────────────
  Future<void> _fetchIndices() async {
    try {
      final indices = await _api.getAllIndices();
      indices.forEach((name, data) {
        if ((data['price'] as double? ?? 0) > 0) {
          _updatePair(
            name:   name,
            price:  data['price']     as double,
            change: data['change']    as double,
            chgPct: data['changePct'] as double,
            spark:  (data['spark']    as List<double>?) ?? [],
          );
        }
      });
      _apiStatus['indices'] = true;
      notifyListeners();
    } catch (e) {
      print('Indices error: $e');
    }
  }

  // ────────────────────────────────────────
  // FUTURES — Yahoo Finance (Free, No Key)
  // ────────────────────────────────────────
  Future<void> _fetchFutures() async {
    try {
      final futures = await _api.getAllFutures();
      futures.forEach((name, data) {
        if ((data['price'] as double? ?? 0) > 0) {
          _updatePair(
            name:   name,
            price:  data['price']     as double,
            change: data['change']    as double,
            chgPct: data['changePct'] as double,
            spark:  (data['spark']    as List<double>?) ?? [],
          );
        }
      });
      _apiStatus['futures'] = true;
      notifyListeners();
    } catch (e) {
      print('Futures error: $e');
    }
  }

  // ────────────────────────────────────────
  // COMMODITIES — Yahoo Finance + Metals
  // ────────────────────────────────────────
  Future<void> _fetchCommodities() async {
    try {
      // Other commodities via Yahoo Finance
      final comms = await _api.getAllCommodities();
      comms.forEach((name, data) {
        if ((data['price'] as double? ?? 0) > 0) {
          _updatePair(
            name:   name,
            price:  data['price']     as double,
            change: data['change']    as double,
            chgPct: data['changePct'] as double,
            spark:  (data['spark']    as List<double>?) ?? [],
          );
        }
      });

      // Gold + Silver
      final metals = await _api.getMetalPrices();
      metals.forEach((name, price) {
        final old    = _pairs.firstWhere((p) => p.pair == name,
            orElse: () => _pairs.first);
        final change = price - old.price;
        final pct    = old.price > 0 ? (change / old.price) * 100 : 0.0;
        _updatePair(name: name, price: price, change: change, chgPct: pct);
      });

      _apiStatus['commodities'] = true;
      notifyListeners();
    } catch (e) {
      print('Commodities error: $e');
    }
  }

  void _updatePair({
    required String name,
    required double price,
    required double change,
    required double chgPct,
    List<double> spark = const [],
  }) {
    _pairs = _pairs.map((p) {
      if (p.pair != name) return p;
      final newSpark = spark.isNotEmpty
          ? (spark.length > 10 ? spark.sublist(spark.length - 10) : spark)
          : [...p.spark.skip(1), price];
      return ForexPair(
        pair: p.pair, flag: p.flag,
        price: price, change: change,
        changePct: chgPct, isUp: chgPct >= 0,
        spark: List<double>.from(newSpark),
        category: p.category,
      );
    }).toList();
  }

  // ────────────────────────────────────────
  // ALL NEWS — 3 Sources Combined
  // ────────────────────────────────────────
  Future<void> _fetchAllNews() async {
    try {
      final allNews = <NewsItem>[];

      // Finnhub
      final fForex   = await _api.getFinnhubNews('forex');
      final fCrypto  = await _api.getFinnhubNews('crypto');
      final fGeneral = await _api.getFinnhubNews('general');
      final fStocks  = await _api.getFinnhubCompanyNews('AAPL');

      allNews.addAll(_parseFinnhub(fForex,   'Forex'));
      allNews.addAll(_parseFinnhub(fCrypto,  'Crypto'));
      allNews.addAll(_parseFinnhub(fGeneral, 'Indices'));
      allNews.addAll(_parseFinnhub(fStocks,  'Stocks'));

      // NewsAPI
      final nStocks  = await _api.getNewsApiArticles(
          'stock market OR earnings OR S&P 500 OR NASDAQ');
      final nComm    = await _api.getNewsApiArticles(
          'gold price OR oil price OR commodity OR wheat OR copper');
      final nFutures = await _api.getNewsApiArticles(
          'futures market OR crude futures OR bond futures');
      final nIndices = await _api.getNewsApiArticles(
          'Dow Jones OR FTSE OR DAX OR Nikkei OR stock index');

      allNews.addAll(_parseNewsApi(nStocks,  'Stocks'));
      allNews.addAll(_parseNewsApi(nComm,    'Commodities'));
      allNews.addAll(_parseNewsApi(nFutures, 'Futures'));
      allNews.addAll(_parseNewsApi(nIndices, 'Indices'));

      // Mediastack
      final mForex  = await _api.getMediastackNews('forex,currency,EUR,USD,GBP');
      final mCrypto = await _api.getMediastackNews('bitcoin,ethereum,crypto');
      final mComm   = await _api.getMediastackNews('gold,oil,silver,commodity');

      allNews.addAll(_parseMediastack(mForex,  'Forex'));
      allNews.addAll(_parseMediastack(mCrypto, 'Crypto'));
      allNews.addAll(_parseMediastack(mComm,   'Commodities'));

      // Deduplicate
      final seen   = <String>{};
      final unique = allNews.where((n) {
        final key = n.title.length > 40
            ? n.title.substring(0, 40)
            : n.title;
        if (seen.contains(key)) return false;
        seen.add(key);
        return true;
      }).toList();

      if (unique.isNotEmpty) {
        _news = unique;
        _apiStatus['news'] = true;
        notifyListeners();
      }
    } catch (e) {
      print('News error: $e');
    }
  }

  List<NewsItem> _parseFinnhub(
      List<Map<String, dynamic>> raw, String cat) {
    return raw.map((item) {
      final title = item['headline'] as String? ?? '';
      final src   = (item['source'] as String? ?? '').toUpperCase();
      final url   = item['url']      as String? ?? '';
      final unix  = item['datetime'] as int?    ?? 0;
      final dt    = DateTime.fromMillisecondsSinceEpoch(unix * 1000);
      final diff  = DateTime.now().difference(dt);
      return NewsItem(
        source: src, title: title,
        timeAgo: _ago(diff),
        sentiment: _sentiment2(title),
        pairs: _pairs2(title, cat),
        url: url, category: cat,
      );
    }).where((n) => n.title.isNotEmpty).toList();
  }

  List<NewsItem> _parseNewsApi(
      List<Map<String, dynamic>> raw, String cat) {
    return raw.map((item) {
      final title = item['title']              as String? ?? '';
      final src   = (item['source']?['name']   as String? ?? '').toUpperCase();
      final url   = item['url']                as String? ?? '';
      final pub   = item['publishedAt']        as String? ?? '';
      Duration diff = Duration.zero;
      try { diff = DateTime.now().difference(DateTime.parse(pub)); } catch (_) {}
      return NewsItem(
        source: src, title: title,
        timeAgo: _ago(diff),
        sentiment: _sentiment2(title),
        pairs: _pairs2(title, cat),
        url: url, category: cat,
      );
    }).where((n) => n.title.isNotEmpty && n.title != '[Removed]').toList();
  }

  List<NewsItem> _parseMediastack(
      List<Map<String, dynamic>> raw, String cat) {
    return raw.map((item) {
      final title = item['title']        as String? ?? '';
      final src   = (item['source']      as String? ?? '').toUpperCase();
      final url   = item['url']          as String? ?? '';
      final pub   = item['published_at'] as String? ?? '';
      Duration diff = Duration.zero;
      try { diff = DateTime.now().difference(DateTime.parse(pub)); } catch (_) {}
      return NewsItem(
        source: src, title: title,
        timeAgo: _ago(diff),
        sentiment: _sentiment2(title),
        pairs: _pairs2(title, cat),
        url: url, category: cat,
      );
    }).where((n) => n.title.isNotEmpty).toList();
  }

  String _ago(Duration d) {
    if (d.inMinutes < 60)    return '${d.inMinutes}m ago';
    if (d.inHours   < 24)    return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  String _sentiment2(String text) {
    final t = text.toLowerCase();
    const b = ['surge','rise','gain','bull','beat','jump','rally',
      'soar','boost','high','record','strong','advance','up'];
    const r = ['fall','drop','bear','decline','crash','plunge',
      'slide','tumble','slump','loss','weak','cut','down','fear'];
    if (b.any((w) => t.contains(w))) return 'bullish';
    if (r.any((w) => t.contains(w))) return 'bearish';
    return 'neutral';
  }

  List<String> _pairs2(String text, String cat) {
    final t = text.toLowerCase();
    final p = <String>[];
    if (t.contains('euro')     || t.contains('eur'))    p.add('EUR/USD');
    if (t.contains('pound')    || t.contains('gbp'))    p.add('GBP/USD');
    if (t.contains('yen')      || t.contains('japan'))  p.add('USD/JPY');
    if (t.contains('bitcoin')  || t.contains('btc'))    p.add('BTC/USD');
    if (t.contains('ethereum') || t.contains('eth'))    p.add('ETH/USD');
    if (t.contains('gold')     || t.contains('xau'))    p.add('XAU/USD');
    if (t.contains('silver'))                           p.add('XAG/USD');
    if (t.contains('oil')      || t.contains('crude'))  p.add('WTI OIL');
    if (t.contains('s&p')      || t.contains('spx'))    p.add('S&P 500');
    if (t.contains('nasdaq'))                           p.add('NASDAQ');
    if (t.contains('apple')    || t.contains('aapl'))   p.add('AAPL');
    if (t.contains('tesla')    || t.contains('tsla'))   p.add('TSLA');
    if (t.contains('nvidia')   || t.contains('nvda'))   p.add('NVDA');
    if (t.contains('amazon')   || t.contains('amzn'))   p.add('AMZN');
    if (t.contains('wheat'))                            p.add('WHEAT');
    if (t.contains('corn'))                             p.add('CORN');
    if (t.contains('copper'))                           p.add('COPPER');
    if (p.isEmpty) p.add(cat);
    return p;
  }

  // ────────────────────────────────────────
  // ECONOMIC CALENDAR
  // ────────────────────────────────────────
  Future<void> _fetchCalendar() async {
    try {
      final raw = await _api.getEconomicCalendar();
      if (raw.isEmpty) return;

      final events = raw.map((item) {
        final event    = item['event']    as String? ?? '';
        final country  = item['country']  as String? ?? '';
        final impact   = item['impact']   as String? ?? 'low';
        final actual   = item['actual']   as String? ?? '—';
        final estimate = item['estimate'] as String? ?? '—';
        final prev     = item['prev']     as String? ?? '—';
        final timeStr  = item['time']     as String? ?? '00:00';

        String imp;
        switch (impact.toLowerCase()) {
          case 'high':   imp = 'HIGH'; break;
          case 'medium': imp = 'MED';  break;
          default:       imp = 'LOW';
        }

        bool? better;
        if (actual.isNotEmpty && actual != '—' &&
            estimate.isNotEmpty && estimate != '—') {
          try {
            final a = double.parse(actual.replaceAll(RegExp(r'[%KMB,]'), '').trim());
            final e = double.parse(estimate.replaceAll(RegExp(r'[%KMB,]'), '').trim());
            better = a >= e;
          } catch (_) {}
        }

        return CalendarEvent(
          time:     timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr,
          currency: country,
          event:    event,
          impact:   imp,
          actual:   actual.isEmpty   ? '—' : actual,
          forecast: estimate.isEmpty ? '—' : estimate,
          previous: prev.isEmpty     ? '—' : prev,
          isBetter: better,
          category: 'Forex',
        );
      }).toList();

      if (events.isNotEmpty) {
        final other = SampleData.calendar
            .where((e) => e.category != 'Forex').toList();
        _calendar = [...events, ...other];
        _apiStatus['calendar'] = true;
        notifyListeners();
      }
    } catch (e) {
      print('Calendar error: $e');
    }
  }

  // ────────────────────────────────────────
  // COT DATA — CFTC.gov
  // ────────────────────────────────────────
  Future<void> _fetchCotData() async {
    try {
      final cotList = <CotData>[];

      final fCot = await _api.getForexCot();
      cotList.addAll(_parseCot(fCot, 'Forex', {
        'EURO FX':           'EUR/USD',
        'BRITISH POUND':     'GBP/USD',
        'JAPANESE YEN':      'USD/JPY',
        'AUSTRALIAN DOLLAR': 'AUD/USD',
        'CANADIAN DOLLAR':   'USD/CAD',
        'SWISS FRANC':       'USD/CHF',
      }));

      final cCot = await _api.getCommodityCot();
      cotList.addAll(_parseCot(cCot, 'Commodities', {
        'GOLD':      'XAU/USD',
        'SILVER':    'XAG/USD',
        'CRUDE OIL': 'WTI OIL',
        'WHEAT':     'WHEAT',
        'CORN':      'CORN',
      }));

      final iCot = await _api.getIndicesCot();
      cotList.addAll(_parseCot(iCot, 'Indices', {
        'S&P 500':   'S&P 500',
        'NASDAQ':    'NASDAQ',
        'DOW JONES': 'DOW JONES',
      }));

      if (cotList.isNotEmpty) {
        final other = SampleData.cotData
            .where((c) => !['Forex','Commodities','Indices'].contains(c.category))
            .toList();
        _cotData = [...cotList, ...other];
        _apiStatus['cot'] = true;
        notifyListeners();
      }
    } catch (e) {
      print('COT error: $e');
    }
  }

  List<CotData> _parseCot(
      List<Map<String, dynamic>> raw,
      String cat,
      Map<String, String> nameMap,
      ) {
    final result = <CotData>[];
    final seen   = <String>{};
    for (final item in raw) {
      try {
        final name = (item['market_and_exchange_names'] as String? ?? '').toUpperCase();
        String? pair;
        nameMap.forEach((k, v) {
          if (name.contains(k.toUpperCase()) && pair == null) pair = v;
        });
        if (pair == null || seen.contains(pair)) continue;
        seen.add(pair!);

        int pi(dynamic v) =>
            int.tryParse(v?.toString().replaceAll(',', '') ?? '0') ?? 0;

        result.add(CotData(
          pair:               pair!,
          nonCommercialLong:  pi(item['noncomm_positions_long_all']),
          nonCommercialShort: pi(item['noncomm_positions_short_all']),
          commercialLong:     pi(item['comm_positions_long_all']),
          commercialShort:    pi(item['comm_positions_short_all']),
          smallTraderLong:    pi(item['nonrept_positions_long_all']),
          smallTraderShort:   pi(item['nonrept_positions_short_all']),
          openInterest:       pi(item['open_interest_all']),
          weekEnding:         item['report_date_as_yyyy_mm_dd']?.toString() ?? '—',
          category:           cat,
        ));
      } catch (e) { print('COT parse: $e'); }
    }
    return result;
  }

  // ────────────────────────────────────────
  // JITTER
  // ────────────────────────────────────────
  ForexPair _jitterPair(ForexPair p) {
    final d = (_rng.nextDouble() - 0.5) * 0.0003 * p.price;
    return ForexPair(
      pair: p.pair, flag: p.flag,
      price: p.price + d,
      change: p.change + d,
      changePct: p.changePct + (_rng.nextDouble() - 0.5) * 0.01,
      isUp: d >= 0,
      spark: [...p.spark.skip(1), p.price + d],
      category: p.category,
    );
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([
      _fetchForexPrices(),
      _fetchCryptoPrices(),
      _fetchAllNews(),
      _fetchCalendar(),
    ]);
    _fetchStocks();
    _fetchIndices();
    _fetchFutures();
    _fetchCommodities();
    _isLoading   = false;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    _newsTimer?.cancel();
    _calendarTimer?.cancel();
    _slowTimer?.cancel();
    _api.dispose();
    super.dispose();
  }
}