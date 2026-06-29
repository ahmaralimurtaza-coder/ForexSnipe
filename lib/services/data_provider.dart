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

  // Previous prices store karo change % ke liye
  Map<String, double> _prevPrices = {};
  bool      _isLoading = false;
  DateTime? _lastUpdated;

  Map<String,bool> _apiStatus = {
    'forex':false,'crypto':false,'stocks':false,
    'indices':false,'commodities':false,'futures':false,
    'news':false,'calendar':false,'cot':false,
  };

  List<ForexPair>     get pairs       => _pairs;
  List<NewsItem>      get news        => _news;
  List<CalendarEvent> get calendar    => _calendar;
  List<CotData>       get cotData     => _cotData;
  List<SentimentData> get sentiment   => _sentiment;
  bool                get isLoading   => _isLoading;
  DateTime?           get lastUpdated => _lastUpdated;
  Map<String,bool>    get apiStatus   => _apiStatus;

  Timer? _priceTimer, _newsTimer, _calendarTimer;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    // Save initial prices as previous
    for (final p in _pairs) { _prevPrices[p.pair] = p.price; }
    try {
      await Future.wait([
        _fetchForex(), _fetchCrypto(), _fetchAllNews(),
        _fetchCalendar(), _fetchCot(),
      ]);
      await Future.wait([_fetchIndices(), _fetchCommodities(), _fetchFutures()]);
      _fetchStocks();
    } catch (e) { print('Init error: '); }
    _isLoading = false;
    _lastUpdated = DateTime.now();
    notifyListeners();
    _startTimers();
  }

  void _startTimers() {
    _priceTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await Future.wait([
        _fetchForex(), _fetchCrypto(),
        _fetchIndices(), _fetchCommodities(), _fetchFutures(),
      ]);
    });
    _newsTimer     = Timer.periodic(const Duration(minutes: 5),  (_) => _fetchAllNews());
    _calendarTimer = Timer.periodic(const Duration(minutes: 15), (_) => _fetchCalendar());
  }

  Future<void> _fetchForex() async {
    try {
      var rates = await _api.getForexRates();
      if (rates.isEmpty) {
        final fixer = await _api.getFixerRates();
        if (fixer.isNotEmpty) {
          final eu = fixer['USD'] ?? 1.0;
          rates = fixer.map((k, v) => MapEntry(k, v / eu));
        }
      }
      if (rates.isEmpty) return;

      _pairs = _pairs.map((p) {
        if (p.category != 'Forex') return p;
        double np = 0;
        switch (p.pair) {
          case 'EUR/USD': np = _api.getPairPrice(rates, 'EUR', 'USD'); break;
          case 'GBP/USD': np = _api.getPairPrice(rates, 'GBP', 'USD'); break;
          case 'USD/JPY': np = _api.getPairPrice(rates, 'USD', 'JPY'); break;
          case 'AUD/USD': np = _api.getPairPrice(rates, 'AUD', 'USD'); break;
          case 'USD/CAD': np = _api.getPairPrice(rates, 'USD', 'CAD'); break;
          case 'USD/CHF': np = _api.getPairPrice(rates, 'USD', 'CHF'); break;
          case 'NZD/USD': np = _api.getPairPrice(rates, 'NZD', 'USD'); break;
          case 'EUR/GBP': np = _api.getPairPrice(rates, 'EUR', 'GBP'); break;
          case 'USD/TRY': np = _api.getPairPrice(rates, 'USD', 'TRY'); break;
          case 'USD/ZAR': np = _api.getPairPrice(rates, 'USD', 'ZAR'); break;
          default: return _jitter(p);
        }
        if (np <= 0) return _jitter(p);
        final prev   = _prevPrices[p.pair] ?? p.price;
        final change = np - prev;
        final chgPct = prev > 0 ? (change / prev) * 100 : 0.0;
        final spark  = [...p.spark.skip(1), np];
        return ForexPair(
          pair: p.pair, flag: p.flag, price: np,
          change: change, changePct: chgPct, isUp: change >= 0,
          spark: spark, category: p.category,
        );
      }).toList();

      _apiStatus['forex'] = true;
      _lastUpdated = DateTime.now();
      notifyListeners();
    } catch (e) { print('Forex: '); }
  }

  Future<void> _fetchCrypto() async {
    try {
      final crypto = await _api.getCryptoPrices();
      if (crypto.isEmpty) return;
      const cm = {
        'BTC/USD': 'bitcoin', 'ETH/USD': 'ethereum',
        'BNB/USD': 'binancecoin', 'SOL/USD': 'solana',
        'XRP/USD': 'ripple', 'ADA/USD': 'cardano',
        'DOGE': 'dogecoin', 'AVAX': 'avalanche-2',
        'LINK': 'chainlink', 'DOT': 'polkadot',
      };
      _pairs = _pairs.map((p) {
        if (p.category != 'Crypto') return p;
        final id = cm[p.pair];
        if (id == null) return _jitter(p);
        final d = crypto[id] as Map<String, dynamic>?;
        if (d == null) return _jitter(p);
        final price  = (d['price']     as num).toDouble();
        final chgPct = (d['changePct'] as num).toDouble();
        final change = (d['change']    as num).toDouble();
        final raw    = d['sparkline']  as List<double>;
        final spark  = raw.length > 10 ? raw.sublist(raw.length - 10) : raw;
        return ForexPair(
          pair: p.pair, flag: p.flag, price: price,
          change: change, changePct: chgPct, isUp: chgPct >= 0,
          spark: List<double>.from(spark.isEmpty ? [...p.spark.skip(1), price] : spark),
          category: p.category,
        );
      }).toList();
      _apiStatus['crypto'] = true;
      notifyListeners();
    } catch (e) { print('Crypto: '); }
  }

  Future<void> _fetchIndices() async {
    try {
      final data = await _api.getIndicesData();
      if (data.isEmpty) return;
      _pairs = _pairs.map((p) {
        if (p.category != 'Indices') return p;
        final d = data[p.pair];
        return d == null ? _jitter(p) : _makeYahoo(p, d);
      }).toList();
      _apiStatus['indices'] = true;
      notifyListeners();
    } catch (e) { print('Indices: '); }
  }

  Future<void> _fetchStocks() async {
    const stocks = ['AAPL','TSLA','NVDA','GOOGL','MSFT','AMZN','META','NFLX','JPM','BABA'];
    for (final sym in stocks) {
      try {
        var d = await _api.getTiingoQuote(sym);
        if (d.isEmpty) d = await _api.getYahooQuote(sym);
        if (d.isNotEmpty) {
          _pairs = _pairs.map((p) {
            if (p.pair != sym) return p;
            final spark = (d['spark'] as List?)?.isNotEmpty == true
                ? List<double>.from(d['spark'] as List)
                : [...p.spark.skip(1), d['price'] as double];
            return ForexPair(
              pair: p.pair, flag: p.flag,
              price:     d['price']     as double,
              change:    d['change']    as double,
              changePct: d['changePct'] as double,
              isUp:      (d['changePct'] as double) >= 0,
              spark: spark, category: p.category,
            );
          }).toList();
          notifyListeners();
        }
      } catch (e) { print('Stock (): '); }
      await Future.delayed(const Duration(milliseconds: 300));
    }
    _apiStatus['stocks'] = true;
    notifyListeners();
  }

  Future<void> _fetchCommodities() async {
    try {
      final data = await _api.getCommoditiesData();
      if (data.isEmpty) return;
      _pairs = _pairs.map((p) {
        if (p.category != 'Commodities') return p;
        final d = data[p.pair];
        return d == null ? _jitter(p) : _makeYahoo(p, d);
      }).toList();
      _apiStatus['commodities'] = true;
      notifyListeners();
    } catch (e) { print('Commodities: '); }
  }

  Future<void> _fetchFutures() async {
    try {
      final data = await _api.getFuturesData();
      if (data.isEmpty) return;
      _pairs = _pairs.map((p) {
        if (p.category != 'Futures') return p;
        final d = data[p.pair];
        return d == null ? _jitter(p) : _makeYahoo(p, d);
      }).toList();
      _apiStatus['futures'] = true;
      notifyListeners();
    } catch (e) { print('Futures: '); }
  }

  Future<void> _fetchAllNews() async {
    try {
      final all = <NewsItem>[];
      all.addAll(_parseFinnhub(await _api.getFinnhubNews('forex'),       'Forex'));
      all.addAll(_parseFinnhub(await _api.getFinnhubNews('crypto'),      'Crypto'));
      all.addAll(_parseFinnhub(await _api.getFinnhubNews('general'),     'Indices'));
      all.addAll(_parseFinnhub(await _api.getFinnhubCompanyNews('AAPL'), 'Stocks'));
      all.addAll(_parseNewsApi(await _api.getStockNews(),                'Stocks'));
      all.addAll(_parseNewsApi(await _api.getIndicesNews(),              'Indices'));
      all.addAll(_parseNewsApi(await _api.getCommodityNews(),            'Commodities'));
      all.addAll(_parseNewsApi(await _api.getFuturesNews(),              'Futures'));
      all.addAll(_parseMedia(await _api.getMediastackForexNews(),        'Forex'));
      all.addAll(_parseMedia(await _api.getMediastackCryptoNews(),       'Crypto'));
      all.addAll(_parseMedia(await _api.getMediastackCommodityNews(),    'Commodities'));
      final seen = <String>{};
      final unique = all.where((n) {
        final k = n.title.length > 40 ? n.title.substring(0, 40) : n.title;
        if (seen.contains(k)) return false;
        seen.add(k);
        return n.title.isNotEmpty;
      }).toList();
      if (unique.isNotEmpty) {
        _news = unique;
        _apiStatus['news'] = true;
        notifyListeners();
      }
    } catch (e) { print('News: '); }
  }

  Future<void> _fetchCalendar() async {
    try {
      final raw = await _api.getEconomicCalendar();
      if (raw.isEmpty) return;
      final events = <CalendarEvent>[];
      for (final item in raw) {
        final event    = item['event']    as String? ?? '';
        final country  = item['country']  as String? ?? '';
        final impact   = item['impact']   as String? ?? 'low';
        final actual   = item['actual']   as String? ?? '';
        final estimate = item['estimate'] as String? ?? '';
        final prev     = item['prev']     as String? ?? '';
        final timeStr  = item['time']     as String? ?? '00:00';
        String il;
        switch (impact.toLowerCase()) {
          case 'high':   il = 'HIGH'; break;
          case 'medium': il = 'MED';  break;
          default:       il = 'LOW';
        }
        bool? ib;
        if (actual.isNotEmpty && estimate.isNotEmpty) {
          try {
            final a = double.parse(actual.replaceAll('%','').replaceAll('K','').replaceAll('M','').replaceAll(',','').trim());
            final e = double.parse(estimate.replaceAll('%','').replaceAll('K','').replaceAll('M','').replaceAll(',','').trim());
            ib = a >= e;
          } catch (_) {}
        }
        events.add(CalendarEvent(
          time:     timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr,
          currency: country, event: event, impact: il,
          actual:   actual.isEmpty   ? '' : actual,
          forecast: estimate.isEmpty ? '' : estimate,
          previous: prev.isEmpty     ? '' : prev,
          isBetter: ib, category: 'Forex',
        ));
      }
      if (events.isNotEmpty) {
        final other = SampleData.calendar.where((e) => e.category != 'Forex').toList();
        _calendar = [...events, ...other];
        _apiStatus['calendar'] = true;
        notifyListeners();
      }
    } catch (e) { print('Calendar: '); }
  }

  Future<void> _fetchCot() async {
    try {
      final list = <CotData>[];
      list.addAll(_parseCot(await _api.getForexCot(), 'Forex', {
        'EURO FX': 'EUR/USD', 'BRITISH POUND': 'GBP/USD',
        'JAPANESE YEN': 'USD/JPY', 'AUSTRALIAN DOLLAR': 'AUD/USD',
        'CANADIAN DOLLAR': 'USD/CAD', 'SWISS FRANC': 'USD/CHF',
      }));
      list.addAll(_parseCot(await _api.getCommodityCot(), 'Commodities', {
        'GOLD': 'XAU/USD', 'SILVER': 'XAG/USD',
        'CRUDE OIL': 'WTI OIL', 'WHEAT': 'WHEAT', 'CORN': 'CORN',
      }));
      list.addAll(_parseCot(await _api.getIndicesCot(), 'Indices', {
        'S&P 500': 'S&P 500', 'NASDAQ': 'NASDAQ', 'DOW JONES': 'DOW JONES',
      }));
      if (list.isNotEmpty) {
        final cats  = ['Forex', 'Commodities', 'Indices'];
        final other = SampleData.cotData.where((c) => !cats.contains(c.category)).toList();
        _cotData = [...list, ...other];
        _apiStatus['cot'] = true;
        notifyListeners();
      }
    } catch (e) { print('COT: '); }
  }

  List<CotData> _parseCot(List<Map<String,dynamic>> raw, String category, Map<String,String> nameMap) {
    final result = <CotData>[];
    final seen   = <String>{};
    for (final item in raw) {
      try {
        final name = (item['market_and_exchange_names'] as String? ?? '').toUpperCase();
        String? pair;
        nameMap.forEach((k, v) { if (name.contains(k.toUpperCase()) && pair == null) pair = v; });
        if (pair == null || seen.contains(pair)) continue;
        seen.add(pair!);
        int pi(dynamic v) => int.tryParse(v?.toString().replaceAll(',', '') ?? '0') ?? 0;
        result.add(CotData(
          pair: pair!,
          nonCommercialLong:  pi(item['noncomm_positions_long_all']),
          nonCommercialShort: pi(item['noncomm_positions_short_all']),
          commercialLong:     pi(item['comm_positions_long_all']),
          commercialShort:    pi(item['comm_positions_short_all']),
          smallTraderLong:    pi(item['nonrept_positions_long_all']),
          smallTraderShort:   pi(item['nonrept_positions_short_all']),
          openInterest:       pi(item['open_interest_all']),
          weekEnding:         item['report_date_as_yyyy_mm_dd']?.toString() ?? '',
          category:           category,
        ));
      } catch (e) { print('COT parse: '); }
    }
    return result;
  }

  List<NewsItem> _parseFinnhub(List<Map<String,dynamic>> raw, String cat) {
    return raw.map((item) {
      final hl   = item['headline'] as String? ?? '';
      final src  = (item['source'] as String? ?? 'Unknown').toUpperCase();
      final url  = item['url']      as String? ?? '';
      final unix = item['datetime'] as int?    ?? 0;
      return NewsItem(
        source: src, title: hl,
        timeAgo: _ago(DateTime.fromMillisecondsSinceEpoch(unix * 1000)),
        sentiment: _sent(hl), pairs: _det(hl, cat), url: url, category: cat,
      );
    }).where((n) => n.title.isNotEmpty).toList();
  }

  List<NewsItem> _parseNewsApi(List<Map<String,dynamic>> raw, String cat) {
    return raw.map((item) {
      final t   = item['title']                       as String? ?? '';
      final src = (item['source']?['name'] as String? ?? 'Unknown').toUpperCase();
      final url = item['url']                         as String? ?? '';
      final pub = item['publishedAt']                 as String? ?? '';
      DateTime? dt; try { dt = DateTime.parse(pub); } catch (_) {}
      return NewsItem(
        source: src, title: t,
        timeAgo: dt != null ? _ago(dt) : 'recent',
        sentiment: _sent(t), pairs: _det(t, cat), url: url, category: cat,
      );
    }).where((n) => n.title.isNotEmpty && n.title != '[Removed]').toList();
  }

  List<NewsItem> _parseMedia(List<Map<String,dynamic>> raw, String cat) {
    return raw.map((item) {
      final t   = item['title']        as String? ?? '';
      final src = (item['source'] as String? ?? 'Unknown').toUpperCase();
      final url = item['url']          as String? ?? '';
      final pub = item['published_at'] as String? ?? '';
      DateTime? dt; try { dt = DateTime.parse(pub); } catch (_) {}
      return NewsItem(
        source: src, title: t,
        timeAgo: dt != null ? _ago(dt) : 'recent',
        sentiment: _sent(t), pairs: _det(t, cat), url: url, category: cat,
      );
    }).where((n) => n.title.isNotEmpty).toList();
  }

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return 'm ago';
    if (d.inHours   < 24) return 'h ago';
    return 'd ago';
  }

  String _sent(String t) {
    final s = t.toLowerCase();
    const bull = ['surge','rise','gain','bull','beat','jump','rally','soar','boost','high','strong','record','advance'];
    const bear = ['fall','drop','bear','decline','crash','plunge','slide','tumble','loss','weak','cut','recession'];
    if (bull.any((w) => s.contains(w))) return 'bullish';
    if (bear.any((w) => s.contains(w))) return 'bearish';
    return 'neutral';
  }

  List<String> _det(String t, String cat) {
    final s = t.toLowerCase();
    final p = <String>[];
    if (s.contains('euro')    || s.contains('eur'))   p.add('EUR/USD');
    if (s.contains('pound')   || s.contains('gbp'))   p.add('GBP/USD');
    if (s.contains('yen')     || s.contains('japan')) p.add('USD/JPY');
    if (s.contains('bitcoin') || s.contains('btc'))   p.add('BTC/USD');
    if (s.contains('ethereum')|| s.contains('eth'))   p.add('ETH/USD');
    if (s.contains('gold')    || s.contains('xau'))   p.add('XAU/USD');
    if (s.contains('oil')     || s.contains('crude')) p.add('WTI OIL');
    if (s.contains('s&p')     || s.contains('spx'))   p.add('S&P 500');
    if (s.contains('nasdaq'))                         p.add('NASDAQ');
    if (s.contains('apple')   || s.contains('aapl'))  p.add('AAPL');
    if (s.contains('tesla')   || s.contains('tsla'))  p.add('TSLA');
    if (s.contains('nvidia')  || s.contains('nvda'))  p.add('NVDA');
    if (p.isEmpty) p.add(cat);
    return p;
  }

  ForexPair _makeYahoo(ForexPair p, Map<String,dynamic> d) {
    final price  = (d['price']     as num?)?.toDouble() ?? p.price;
    final change = (d['change']    as num?)?.toDouble() ?? 0.0;
    final chgPct = (d['changePct'] as num?)?.toDouble() ?? 0.0;
    final raw    = d['spark'] as List?;
    List<double> spark;
    if (raw != null && raw.isNotEmpty) {
      spark = raw.map((e) => (e as num).toDouble()).toList();
      if (spark.length > 10) spark = spark.sublist(spark.length - 10);
    } else {
      spark = [...p.spark.skip(1), price];
    }
    return ForexPair(
      pair: p.pair, flag: p.flag, price: price,
      change: change, changePct: chgPct, isUp: chgPct >= 0,
      spark: spark, category: p.category,
    );
  }

  ForexPair _jitter(ForexPair p) {
    final d  = (_rng.nextDouble() - 0.5) * 0.0003 * p.price;
    final np = p.price + d;
    return ForexPair(
      pair: p.pair, flag: p.flag, price: np,
      change: p.change + d,
      changePct: p.changePct + (_rng.nextDouble() - 0.5) * 0.01,
      isUp: d >= 0,
      spark: [...p.spark.skip(1), np],
      category: p.category,
    );
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    // Update previous prices before refresh
    for (final p in _pairs) { _prevPrices[p.pair] = p.price; }
    await Future.wait([
      _fetchForex(), _fetchCrypto(), _fetchIndices(),
      _fetchCommodities(), _fetchFutures(),
      _fetchAllNews(), _fetchCalendar(),
    ]);
    _isLoading   = false;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    _newsTimer?.cancel();
    _calendarTimer?.cancel();
    _api.dispose();
    super.dispose();
  }
}
