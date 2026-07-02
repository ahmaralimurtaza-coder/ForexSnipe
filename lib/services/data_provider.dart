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
  List<WorldEvent>    _worldEvents = [];
  List<CalendarEvent> _calendar  = List.from(SampleData.calendar);
  List<CotData>       _cotData   = List.from(SampleData.cotData);
  List<SentimentData> _sentiment = List.from(SampleData.sentiment);

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
  List<WorldEvent>    get worldEvents => _worldEvents;
  List<CalendarEvent> get calendar    => _calendar;
  List<CotData>       get cotData     => _cotData;
  List<SentimentData> get sentiment   => _cotData.map((c) {
    final totalLong  = c.nonCommercialLong + c.commercialLong + c.smallTraderLong;
    final totalShort = c.nonCommercialShort + c.commercialShort + c.smallTraderShort;
    final total      = totalLong + totalShort;
    final longPct    = total > 0 ? (totalLong / total * 100) : 50.0;
    return SentimentData(
      pair: c.pair, longPct: longPct, shortPct: 100 - longPct,
      source: 'CFTC COT', category: c.category,
    );
  }).toList();
  bool                get isLoading   => _isLoading;
  DateTime?           get lastUpdated => _lastUpdated;
  Map<String,bool>    get apiStatus   => _apiStatus;

  Timer? _priceTimer, _newsTimer, _calendarTimer, _worldTimer;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    for (final p in _pairs) { _prevPrices[p.pair] = p.price; }
    try {
      await Future.wait([
        _fetchForex(), _fetchCrypto(), _fetchAllNews(),
        _fetchCalendar(), _fetchCot(), _fetchWorldEvents(),
      ]);
      await Future.wait([_fetchIndices(), _fetchCommodities(), _fetchFutures()]);
      _fetchStocks();
    } catch (e) { print('Init error: $e'); }
    _isLoading = false;
    _lastUpdated = DateTime.now();
    notifyListeners();
    _startTimers();
  }

  void _startTimers() {
    _priceTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      for (final p in _pairs) { _prevPrices[p.pair] = p.price; }
      await Future.wait([
        _fetchForex(), _fetchCrypto(),
        _fetchIndices(), _fetchCommodities(), _fetchFutures(),
      ]);
    });
    _newsTimer     = Timer.periodic(const Duration(minutes: 5),  (_) => _fetchAllNews());
    _worldTimer    = Timer.periodic(const Duration(minutes: 5),  (_) => _fetchWorldEvents());
    _calendarTimer = Timer.periodic(const Duration(minutes: 15), (_) => _fetchCalendar());
  }

  Future<void> _fetchForex() async {
    try {
      // Uses CurrencyFreaks (1 min) -> Frankfurter -> ExchangeRate cascade
      final rates = await _api.getBestForexRates();
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
        return ForexPair(
          pair: p.pair, flag: p.flag, price: np,
          change: change, changePct: chgPct, isUp: change >= 0,
          spark: [...p.spark.skip(1), np], category: p.category,
        );
      }).toList();

      _apiStatus['forex'] = true;
      _lastUpdated = DateTime.now();
      notifyListeners();
    } catch (e) { print('Forex: $e'); }
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
        final d = crypto[p.pair] as Map<String, dynamic>?;
        if (d == null) return _jitter(p);
        final price  = (d['price']     as num?)?.toDouble() ?? p.price;
        final chgPct = (d['changePct'] as num?)?.toDouble() ?? 0.0;
        final change = (d['change']    as num?)?.toDouble() ?? 0.0;
        final raw    = (d['sparkline'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? <double>[];
        final spark  = raw.length > 10 ? raw.sublist(raw.length - 10) : raw;
        return ForexPair(
          pair: p.pair, flag: p.flag, price: price,
          change: change, changePct: chgPct, isUp: chgPct >= 0,
          spark: spark.isEmpty ? [...p.spark.skip(1), price] : spark,
          category: p.category,
        );
      }).toList();
      _apiStatus['crypto'] = true;
      notifyListeners();
    } catch (e) { print('Crypto: $e'); }
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
    } catch (e) { print('Indices: $e'); }
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
      } catch (e) { print('Stock (): $e'); }
      await Future.delayed(const Duration(milliseconds: 300));
    }
    _apiStatus['stocks'] = true;
    notifyListeners();
  }

  Future<void> _fetchCommodities() async {
    try {
      // getCommoditiesData() already merges GoldAPI (XAU/XAG real-time) + Yahoo (oil/gas/etc)
      final data = await _api.getCommoditiesData();
      if (data.isEmpty) return;
      _pairs = _pairs.map((p) {
        if (p.category != 'Commodities') return p;
        final d = data[p.pair];
        if (d == null) return _jitter(p);
        final prev   = _prevPrices[p.pair] ?? p.price;
        final price  = (d['price'] as num?)?.toDouble() ?? p.price;
        // For GoldAPI items, changePct already comes from API; for Yahoo items too.
        final apiChgPct = (d['changePct'] as num?)?.toDouble();
        final change = price - prev;
        final chgPct = apiChgPct != null && apiChgPct != 0
            ? apiChgPct
            : (prev > 0 ? (change / prev) * 100 : 0.0);
        final raw = d['spark'] as List?;
        List<double> spark;
        if (raw != null && raw.isNotEmpty) {
          spark = raw.map((e) => (e as num).toDouble()).toList();
          if (spark.length > 10) spark = spark.sublist(spark.length - 10);
        } else {
          spark = [...p.spark.skip(1), price];
        }
        return ForexPair(
          pair: p.pair, flag: p.flag, price: price,
          change: change, changePct: chgPct, isUp: change >= 0,
          spark: spark, category: p.category,
        );
      }).toList();
      _apiStatus['commodities'] = true;
      notifyListeners();
    } catch (e) { print('Commodities: $e'); }
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
    } catch (e) { print('Futures: $e'); }
  }

  Future<void> _fetchAllNews() async {
    try {
      final results = await Future.wait([
        _api.getReutersNews(),
        _api.getMarketWatchNews(),
        _api.getCnbcNews(),
        _api.getInvestingNews('forex'),
        _api.getInvestingNews('crypto'),
        _api.getInvestingNews('stocks'),
        _api.getInvestingNews('commodities'),
        _api.getFinnhubNews('forex'),
        _api.getFinnhubNews('crypto'),
        _api.getFinnhubNews('general'),
        _api.getFinnhubCompanyNews('AAPL'),
        _api.getStockNews(),
        _api.getIndicesNews(),
        _api.getCommodityNews(),
        _api.getMediastackForexNews(),
        _api.getMediastackCryptoNews(),
        _api.getMediastackCommodityNews(),
      ]);
      final all = <NewsItem>[];
      all.addAll(_parseRss(results[0],      'Forex'));
      all.addAll(_parseRss(results[1],      'Stocks'));
      all.addAll(_parseRss(results[2],      'Indices'));
      all.addAll(_parseRss(results[3],      'Forex'));
      all.addAll(_parseRss(results[4],      'Crypto'));
      all.addAll(_parseRss(results[5],      'Stocks'));
      all.addAll(_parseRss(results[6],      'Commodities'));
      all.addAll(_parseRss(results[7],  'Forex'));
      all.addAll(_parseRss(results[8],  'Crypto'));
      all.addAll(_parseRss(results[9],  'Indices'));
      all.addAll(_parseRss(results[10], 'Stocks'));
      all.addAll(_parseRss(results[11], 'Stocks'));
      all.addAll(_parseRss(results[12], 'Indices'));
      all.addAll(_parseRss(results[13], 'Commodities'));
      all.addAll(_parseRss(results[14],   'Forex'));
      all.addAll(_parseRss(results[15],   'Crypto'));
      all.addAll(_parseRss(results[16],   'Commodities'));
      all.addAll(_parseRss(results[13], 'Futures'));
      all.addAll(_parseRss(results[2],  'Futures'));
      final seen   = <String>{};
      final unique = all.where((n) {
        final k = n.category + (n.title.length > 40 ? n.title.substring(0, 40) : n.title);
        if (seen.contains(k)) return false;
        seen.add(k);
        return n.title.isNotEmpty;
      }).toList();
      if (unique.isNotEmpty) {
        _news = unique;
        _apiStatus['news'] = true;
        notifyListeners();
      }
    } catch (e) { print('News: $e'); }
  }

  Future<void> _fetchWorldEvents() async {
    try {
      final results = await Future.wait([_api.getEarthquakes(), _api.getDisasters(), _api.getGdeltEvents()]);
      final quakes    = results[0];
      final disasters = results[1];
      final gdelt      = results[2];
      final events = <WorldEvent>[];
      for (final q in quakes) {
        final mag = (q['mag'] as num?)?.toDouble();
        final ms  = q['time'] as int?;
        DateTime? dt;
        if (ms != null) dt = DateTime.fromMillisecondsSinceEpoch(ms);
        events.add(WorldEvent(
          title: q['title'] ?? '',
          source: 'USGS',
          category: 'Earthquake',
          timeAgo: dt != null ? _ago(dt) : 'recent',
          url: q['url'] ?? '',
          magnitude: mag,
          lat: (q['lat'] as num?)?.toDouble(),
          lon: (q['lon'] as num?)?.toDouble(),
        ));
      }
      for (final d in disasters) {
        DateTime? dt;
        try { dt = DateTime.parse(d['date'] ?? ''); } catch (_) {}
        events.add(WorldEvent(
          title: d['title'] ?? '',
          source: 'NASA EONET',
          category: d['category'] ?? 'Event',
          timeAgo: dt != null ? _ago(dt) : 'recent',
          url: d['url'] ?? '',
          lat: (d['lat'] as num?)?.toDouble(),
          lon: (d['lon'] as num?)?.toDouble(),
        ));
      }
      for (final g in gdelt) {
        final title = g['title'] as String? ?? '';
        if (title.isEmpty) continue;
        DateTime? dt;
        try {
          final sd = g['seendate'] as String? ?? '';
          if (sd.length >= 8) {
            dt = DateTime.parse('${sd.substring(0,4)}-${sd.substring(4,6)}-${sd.substring(6,8)}');
          }
        } catch (_) {}
        events.add(WorldEvent(
          title: title,
          source: g['domain'] ?? 'GDELT',
          category: 'World',
          timeAgo: dt != null ? _ago(dt) : 'recent',
          url: g['url'] ?? '',
        ));
      }
      if (events.isNotEmpty) {
        _worldEvents = events;
        notifyListeners();
      }
    } catch (e) { print('WorldEvents: $e'); }
  }
  List<NewsItem> _parseRss(List<Map<String, dynamic>> raw, String cat) {
    return raw.map((item) {
      final t   = item['title']       as String? ?? '';
      final src = item['source']      as String? ?? 'RSS';
      final url = item['url']         as String? ?? '';
      final pub = item['publishedAt'] as String? ?? '';
      DateTime? dt; try { dt = DateTime.parse(pub); } catch (_) {}
      return NewsItem(
        source: src, title: t,
        timeAgo:   dt != null ? _ago(dt) : 'recent',
        sentiment: _sent(t), pairs: _det(t, cat), url: url, category: cat,
      );
    }).where((n) => n.title.isNotEmpty).toList();
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
    } catch (e) { print('Calendar: $e'); }
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
    } catch (e) { print('COT: $e'); }
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
      } catch (e) { print('COT parse: $e'); }
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
    if (d.inMinutes < 1)  return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours   < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
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
    for (final p in _pairs) { _prevPrices[p.pair] = p.price; }
    await Future.wait([
      _fetchForex(), _fetchCrypto(), _fetchIndices(),
      _fetchCommodities(), _fetchFutures(),
      _fetchAllNews(), _fetchCalendar(), _fetchWorldEvents(),
    ]);
    _isLoading   = false;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    _newsTimer?.cancel();
    _worldTimer?.cancel();
    _calendarTimer?.cancel();
    _api.dispose();
    super.dispose();
  }
}












