import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  String _decodeHtml(String s) {
    return s
        .replaceAll('&#039;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&#x2019;', '\u2019')
        .replaceAll('&#x2018;', '\u2018')
        .replaceAll('&#8217;', '\u2019')
        .replaceAll('&#8216;', '\u2018')
        .replaceAll('&quot;', '"')
        .replaceAll('&#034;', '"')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&mdash;', '\u2014')
        .replaceAll('&ndash;', '\u2013')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
  static const _finnhubKey        = 'd90cstpr01qk8bfkjeq0d90cstpr01qk8bfkjeqg';
  static const _newsApiKey        = '1b64f827220b48f7b3645d6d3aa9edf9';
  static const _mediastackKey     = '0f4517ce9ef6a7891cba0892517e9b6a';
  static const _tiingoKey         = '2ba30238a0a10fb0d87a54e1484d6716f176527d';
  static const _fixerKey          = 'f91677b613d3fa627db71b15e896bb09';
  static const _currencyFreaksKey = '65039742f4c04d90841f02f8a2ff97c0';
  static const _goldApiKey        = 'goldapi-5ff40f39ae501ec41f76b22d05071533-io';

  static const _frankfurter    = 'https://api.frankfurter.app';
  static const _exchangeRate   = 'https://open.er-api.com/v6/latest/USD';
  static const _currencyFreaks = 'https://api.currencyfreaks.com/v2.0/rates/latest';
  static const _fixer          = 'http://data.fixer.io/api';
  static const _goldApi        = 'https://www.goldapi.io/api';
  static const _binance        = 'https://api.binance.com/api/v3';
  static const _coincap        = 'https://api.coincap.io/v2';
  static const _coingecko      = 'https://api.coingecko.com/api/v3';
  static const _yahoo          = 'https://query1.finance.yahoo.com/v8/finance/chart';
  static const _yahoo2         = 'https://query2.finance.yahoo.com/v8/finance/chart';
  static const _tiingo         = 'https://api.tiingo.com';
  static const _rss2json       = 'https://api.rss2json.com/v1/api.json';
  static const _finnhub        = 'https://finnhub.io/api/v1';
  static const _newsApi        = 'https://newsapi.org/v2/everything';
  static const _mediastack     = 'http://api.mediastack.com/v1/news';
  static const _cftc           = 'https://publicreporting.cftc.gov/resource/6dca-aqww.json';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();
  final _h = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    'Accept': 'application/json',
  };

  // ═══ FOREX ═══

  Future<Map<String, double>> getCurrencyFreaksRates() async {
    try {
      final res = await _client
          .get(Uri.parse('='), headers: _h)
          .timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) {
        final rates = json.decode(res.body)['rates'] as Map<String, dynamic>?;
        if (rates != null) return rates.map((k, v) => MapEntry(k, double.tryParse(v.toString()) ?? 0.0));
      }
    } catch (e) { print('CurrencyFreaks: $e'); }
    return {};
  }

  Future<Map<String, double>> getFrankfurterRates() async {
    try {
      final res = await _client
          .get(Uri.parse('/latest?from=USD'), headers: _h)
          .timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) {
        final data  = json.decode(res.body);
        final rates = Map<String, double>.from(
            (data['rates'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toDouble())));
        rates['USD'] = 1.0;
        return rates;
      }
    } catch (e) { print('Frankfurter: $e'); }
    return {};
  }

  Future<Map<String, double>> getForexRates() async {
    try {
      final res = await _client.get(Uri.parse(_exchangeRate), headers: _h).timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(res.body)['rates'])
            .map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    } catch (e) { print('ExchangeRate: $e'); }
    return {};
  }

  Future<Map<String, double>> getFixerRates() async {
    try {
      final res = await _client
          .get(Uri.parse('/latest?access_key=&base=EUR'), headers: _h)
          .timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['rates'] != null)
          return Map<String, dynamic>.from(data['rates']).map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    } catch (e) { print('Fixer: $e'); }
    return {};
  }

  Future<Map<String, double>> getBestForexRates() async {
    var r = await getCurrencyFreaksRates(); if (r.isNotEmpty) return r;
    r     = await getFrankfurterRates();   if (r.isNotEmpty) return r;
    r     = await getForexRates();         if (r.isNotEmpty) return r;
    return {};
  }

  double getPairPrice(Map<String, double> rates, String base, String quote) {
    if (base == 'USD') return rates[quote] ?? 0.0;
    if (quote == 'USD') { final r = rates[base]; return r != null && r != 0 ? 1.0 / r : 0.0; }
    final b = rates[base], q = rates[quote];
    if (b != null && q != null && b != 0) return q / b;
    return 0.0;
  }

  // ═══ GOLD API — Real-time Gold & Silver ═══

  /// GoldAPI.io — Real-time spot prices for XAU, XAG, XPT, XPD
  Future<Map<String, dynamic>> getGoldApiPrice(String metal) async {
    try {
      final res = await _client.get(
        Uri.parse('//USD'),
        headers: {
          ..._h,
          'x-access-token': _goldApiKey,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) {
        final d = json.decode(res.body);
        final price  = (d['price']          as num?)?.toDouble() ?? 0.0;
        final prev   = (d['prev_close_price'] as num?)?.toDouble() ?? price;
        final change = (d['ch']             as num?)?.toDouble() ?? (price - prev);
        final chgPct = (d['chp']            as num?)?.toDouble() ?? 0.0;
        return {
          'price':     price,
          'change':    change,
          'changePct': chgPct,
          'high':      (d['high_price'] as num?)?.toDouble() ?? price,
          'low':       (d['low_price']  as num?)?.toDouble() ?? price,
          'open':      (d['open_price'] as num?)?.toDouble() ?? price,
        };
      }
    } catch (e) { print('GoldAPI (): $e'); }
    return {};
  }

  /// Get all precious metals — XAU, XAG, XPT, XPD
  Future<Map<String, Map<String, dynamic>>> getPreciousMetals() async {
    const metals = {
      'XAU/USD': 'XAU',  // Gold
      'XAG/USD': 'XAG',  // Silver
      'PLATINUM': 'XPT', // Platinum
    };
    final result = <String, Map<String, dynamic>>{};
    for (final e in metals.entries) {
      final d = await getGoldApiPrice(e.value);
      if (d.isNotEmpty) result[e.key] = d;
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return result;
  }

  // ═══ CRYPTO ═══

  Future<Map<String, dynamic>> getBinanceTicker(String symbol) async {
    try {
      final res = await _client
          .get(Uri.parse('/ticker/24hr?symbol='), headers: _h)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final d = json.decode(res.body);
        return {
          'price':     double.tryParse(d['lastPrice'].toString())          ?? 0.0,
          'changePct': double.tryParse(d['priceChangePercent'].toString()) ?? 0.0,
          'change':    double.tryParse(d['priceChange'].toString())        ?? 0.0,
        };
      }
    } catch (e) { print('Binance (): $e'); }
    return {};
  }

  Future<List<double>> getBinanceSparkline(String symbol) async {
    try {
      final res = await _client
          .get(Uri.parse('/klines?symbol=&interval=1h&limit=10'), headers: _h)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return (json.decode(res.body) as List).map((k) => double.tryParse(k[4].toString()) ?? 0.0).toList();
      }
    } catch (e) { print('Binance spark (): $e'); }
    return [];
  }

  Future<Map<String, dynamic>> getCryptoPrices() async {
    final r = await _getBinanceCrypto(); if (r.isNotEmpty) return r;
    final c = await _getCoinCapCrypto(); if (c.isNotEmpty) return c;
    return await _getCoinGeckoCrypto();
  }

  Future<Map<String, dynamic>> _getBinanceCrypto() async {
    const pairs = {
      'BTC/USD':'BTCUSDT','ETH/USD':'ETHUSDT','BNB/USD':'BNBUSDT',
      'SOL/USD':'SOLUSDT','XRP/USD':'XRPUSDT','ADA/USD':'ADAUSDT',
      'DOGE':'DOGEUSDT','AVAX':'AVAXUSDT','LINK':'LINKUSDT','DOT':'DOTUSDT',
    };
    final result = <String, dynamic>{};
    try {
      for (final e in pairs.entries) {
        final d = await getBinanceTicker(e.value);
        if (d.isNotEmpty) {
          final spark = await getBinanceSparkline(e.value);
          result[e.key] = {...d, 'sparkline': spark};
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) { print('Binance crypto: $e'); }
    return result;
  }

  Future<Map<String, dynamic>> _getCoinCapCrypto() async {
    try {
      const ids = 'bitcoin,ethereum,binance-coin,solana,xrp,cardano,dogecoin,avalanche,chainlink,polkadot';
      final res = await _client
          .get(Uri.parse('/assets?ids=&limit=10'), headers: _h)
          .timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) {
        const nm = {
          'bitcoin':'BTC/USD','ethereum':'ETH/USD','binance-coin':'BNB/USD',
          'solana':'SOL/USD','xrp':'XRP/USD','cardano':'ADA/USD',
          'dogecoin':'DOGE','avalanche':'AVAX','chainlink':'LINK','polkadot':'DOT',
        };
        final result = <String, dynamic>{};
        for (final coin in json.decode(res.body)['data'] as List) {
          final pair = nm[coin['id'] as String]; if (pair == null) continue;
          final p  = double.tryParse(coin['priceUsd'].toString()) ?? 0.0;
          final cp = double.tryParse(coin['changePercent24Hr'].toString()) ?? 0.0;
          result[pair] = {'price':p,'changePct':cp,'change':p*cp/100,'sparkline':<double>[]};
        }
        return result;
      }
    } catch (e) { print('CoinCap: $e'); }
    return {};
  }

  Future<Map<String, dynamic>> _getCoinGeckoCrypto() async {
    try {
      final url = '/coins/markets?vs_currency=usd'
          '&ids=bitcoin,ethereum,binancecoin,solana,ripple,cardano,dogecoin,avalanche-2,chainlink,polkadot'
          '&order=market_cap_desc&per_page=10&page=1&sparkline=true&price_change_percentage=24h';
      final res = await _client.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) {
        const idMap = {
          'bitcoin':'BTC/USD','ethereum':'ETH/USD','binancecoin':'BNB/USD',
          'solana':'SOL/USD','ripple':'XRP/USD','cardano':'ADA/USD',
          'dogecoin':'DOGE','avalanche-2':'AVAX','chainlink':'LINK','polkadot':'DOT',
        };
        final result = <String, dynamic>{};
        for (final coin in json.decode(res.body) as List) {
          final pair = idMap[coin['id'] as String]; if (pair == null) continue;
          final raw   = coin['sparkline_in_7d']?['price'] as List? ?? [];
          final spark = raw.map((e) => (e as num).toDouble()).toList();
          result[pair] = {
            'price':     (coin['current_price']               as num?)?.toDouble() ?? 0.0,
            'changePct': (coin['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
            'change':    (coin['price_change_24h']            as num?)?.toDouble() ?? 0.0,
            'sparkline': spark.length > 10 ? spark.sublist(spark.length - 10) : spark,
          };
        }
        return result;
      }
    } catch (e) { print('CoinGecko: $e'); }
    return {};
  }

  // ═══ STOCKS / INDICES / COMMODITIES / FUTURES ═══

  Future<Map<String, dynamic>> getYahooQuote(String symbol) async {
    for (final base in [_yahoo, _yahoo2]) {
      try {
        final res = await _client
            .get(Uri.parse('/=1d&range=5d'), headers: _h)
            .timeout(const Duration(seconds: 25));
        if (res.statusCode == 200) {
          final result = json.decode(res.body)['chart']?['result'];
          if (result != null && (result as List).isNotEmpty) {
            final meta   = result[0]['meta'];
            final price  = (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0.0;
            final prev   = (meta['chartPreviousClose'] as num?)?.toDouble() ?? 0.0;
            final change = price - prev;
            final chgPct = prev > 0 ? (change / prev) * 100 : 0.0;
            final closes = result[0]['indicators']?['quote']?[0]?['close'] as List?;
            List<double> spark = [];
            if (closes != null) {
              spark = closes.where((e) => e != null).map((e) => (e as num).toDouble()).toList();
              if (spark.length > 10) spark = spark.sublist(spark.length - 10);
            }
            return {'price': price, 'change': change, 'changePct': chgPct, 'spark': spark};
          }
        }
      } catch (e) { print('Yahoo (): $e'); }
    }
    return {};
  }

  Future<Map<String, Map<String, dynamic>>> getIndicesData() async {
    const idx = {
      'S&P 500':'^GSPC','NASDAQ':'^IXIC','DOW JONES':'^DJI','FTSE 100':'^FTSE',
      'DAX 40':'^GDAXI','NIKKEI':'^N225','CAC 40':'^FCHI','HANG SENG':'^HSI',
      'ASX 200':'^AXJO','VIX':'^VIX',
    };
    final r = <String, Map<String, dynamic>>{};
    for (final e in idx.entries) {
      final d = await getYahooQuote(e.value);
      if (d.isNotEmpty) r[e.key] = d;
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return r;
  }

  Future<Map<String, Map<String, dynamic>>> getCommoditiesData() async {
    // Step 1: Get Gold & Silver from GoldAPI (real-time)
    final metals = await getPreciousMetals();

    // Step 2: Get Oil, Gas, Copper, Wheat etc from Yahoo (15 min)
    const yahooComm = {
      'WTI OIL':'CL=F','BRENT':'BZ=F','NAT GAS':'NG=F',
      'COPPER':'HG=F','WHEAT':'ZW=F','CORN':'ZC=F',
      'COTTON':'CT=F','PLATINUM':'PL=F',
    };
    final result = <String, Map<String, dynamic>>{};

    // Add metals first (real-time from GoldAPI)
    for (final e in metals.entries) {
      result[e.key] = {
        'price':     e.value['price']     ?? 0.0,
        'change':    e.value['change']    ?? 0.0,
        'changePct': e.value['changePct'] ?? 0.0,
        'spark':     <double>[],
      };
    }

    // Add Yahoo commodities
    for (final e in yahooComm.entries) {
      if (result.containsKey(e.key)) continue; // skip if already from GoldAPI
      final d = await getYahooQuote(e.value);
      if (d.isNotEmpty) result[e.key] = d;
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return result;
  }

  Future<Map<String, Map<String, dynamic>>> getFuturesData() async {
    const fut = {
      'ES1! SPX':'ES=F','NQ1! NAS':'NQ=F','GC1! GOLD':'GC=F','CL1! OIL':'CL=F',
      'ZB1! BOND':'ZB=F','SI1! SILV':'SI=F','HG1! COP':'HG=F','YM1! DOW':'YM=F',
    };
    final r = <String, Map<String, dynamic>>{};
    for (final e in fut.entries) {
      final d = await getYahooQuote(e.value);
      if (d.isNotEmpty) r[e.key] = d;
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return r;
  }

  Future<Map<String, dynamic>> getTiingoQuote(String symbol) async {
    try {
      final res = await _client
          .get(Uri.parse('/iex/='), headers: _h)
          .timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List?;
        if (list != null && list.isNotEmpty) {
          final q = list[0];
          final p = (q['last']      as num?)?.toDouble() ?? 0.0;
          final v = (q['prevClose'] as num?)?.toDouble() ?? 0.0;
          final c = p - v;
          return {'price': p, 'change': c, 'changePct': v > 0 ? (c / v) * 100 : 0.0};
        }
      }
    } catch (e) { print('Tiingo (): $e'); }
    return {};
  }

  Future<List<Map<String, dynamic>>> getEconomicCalendar() async {
    try {
      final now  = DateTime.now();
      final from = now.subtract(const Duration(days: 7)).toIso8601String().substring(0,10);
      final to   = now.add(const Duration(days: 7)).toIso8601String().substring(0,10);
      final url  = 'https://finnhub.io/api/v1/calendar/economic?from=' + from + '&to=' + to + '&token=d90cstpr01qk8bfkjeq0d90cstpr01qk8bfkjeqg';
      final res  = await _client.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) {
        return ((json.decode(res.body)['economicCalendar'] as List?) ?? [])
            .map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) { print('Calendar: $e'); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getForexCot() async {
    try {
      final where = Uri.encodeComponent("market_and_exchange_names like '%EURO FX%' OR market_and_exchange_names like '%BRITISH POUND%' OR market_and_exchange_names like '%JAPANESE YEN%' OR market_and_exchange_names like '%AUSTRALIAN DOLLAR%' OR market_and_exchange_names like '%CANADIAN DOLLAR%' OR market_and_exchange_names like '%SWISS FRANC%'"); final url = 'https://publicreporting.cftc.gov/resource/6dca-aqww.json?\$where=$where&\$limit=30&\$order=report_date_as_yyyy_mm_dd DESC';
      final res = await _client.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) return (json.decode(res.body) as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) { print('ForexCOT: $e'); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getCommodityCot() async {
    try {
      final url = 'https://publicreporting.cftc.gov/resource/6dca-aqww.json?\$limit=20&\$order=report_date_as_yyyy_mm_dd DESC&cftc_market_code=CMX';
      final res = await _client.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) return (json.decode(res.body) as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) { print('CommodityCOT: $e'); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getIndicesCot() async {
    try {
      final url = 'https://publicreporting.cftc.gov/resource/6dca-aqww.json?\$limit=20&\$order=report_date_as_yyyy_mm_dd DESC&cftc_market_code=CME';
      final res = await _client.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) return (json.decode(res.body) as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) { print('IndicesCOT: $e'); }
    return [];
  }

  void dispose() { _client.close(); }

  // NEWS
  Future<List<Map<String, dynamic>>> _fetchRss(String url, String source) async {
    try {
      final res = await _client.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final body = utf8.decode(res.bodyBytes, allowMalformed: true);
        final items = <Map<String, dynamic>>[];
        final itemRegex = RegExp(r'<item[\s\S]*?<\/item>', multiLine: true);
        final titleRegex = RegExp(r'<title>(?:<!\[CDATA\[)?(.*?)(?:\]\]>)?<\/title>', dotAll: true);
        final linkRegex = RegExp(r'<link>(.*?)<\/link>', dotAll: true);
        final pubRegex = RegExp(r'<pubDate>(.*?)<\/pubDate>', dotAll: true);
        for (final m in itemRegex.allMatches(body)) {
          final chunk = m.group(0) ?? '';
          final title = _decodeHtml(titleRegex.firstMatch(chunk)?.group(1)?.trim() ?? '');
          final link = linkRegex.firstMatch(chunk)?.group(1)?.trim() ?? '';
          final pub = pubRegex.firstMatch(chunk)?.group(1)?.trim() ?? '';
          if (title.isNotEmpty) {
            items.add({'title': title, 'source': source, 'url': link, 'publishedAt': pub});
          }
          if (items.length >= 15) break;
        }
        return items;
      }
    } catch (e) { print('RSS $source: $e'); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getReutersNews() async {
    final all = <Map<String, dynamic>>[];
    all.addAll(await _fetchRss('https://feeds.bbci.co.uk/news/business/rss.xml', 'BBC BUSINESS'));
    all.addAll(await _fetchRss('https://www.ft.com/rss/home', 'FT'));
    return all;
  }

  Future<List<Map<String, dynamic>>> getMarketWatchNews() async {
    final all = <Map<String, dynamic>>[];
    all.addAll(await _fetchRss('https://feeds.content.dowjones.io/public/rss/mw_realtimeheadlines', 'MARKETWATCH'));
    all.addAll(await _fetchRss('https://www.nasdaq.com/feed/rssoutbound?category=Stocks', 'NASDAQ'));
    return all;
  }

  Future<List<Map<String, dynamic>>> getCnbcNews() async {
    final all = <Map<String, dynamic>>[];
    all.addAll(await _fetchRss('https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=100003114', 'CNBC'));
    all.addAll(await _fetchRss('https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=15839135', 'CNBC MARKETS'));
    return all;
  }

  Future<List<Map<String, dynamic>>> getInvestingNews(String category) async {
    final urls = <String,String>{
      'forex':       'https://www.fxstreet.com/rss/news',
      'crypto':      'https://cointelegraph.com/rss',
      'stocks':      'https://finance.yahoo.com/news/rssindex',
      'commodities': 'https://www.mining.com/feed/',
      'economy':     'https://feeds.bbci.co.uk/news/business/economy/rss.xml',
    };
    return await _fetchRss(urls[category] ?? urls['forex']!, category.toUpperCase());
  }

  Future<List<Map<String, dynamic>>> getFinnhubNews(String category) async {
    final urls = <String,String>{
      'forex':   'https://www.forexlive.com/feed/news',
      'crypto':  'https://coindesk.com/arc/outboundfeeds/rss/',
      'general': 'https://finance.yahoo.com/rss/headline',
    };
    return await _fetchRss(urls[category] ?? urls['general']!, category.toUpperCase());
  }

  Future<List<Map<String, dynamic>>> getFinnhubCompanyNews(String symbol) async {
    return await _fetchRss('https://finance.yahoo.com/rss/headline?s=' + symbol, symbol);
  }

  Future<List<Map<String, dynamic>>> getStockNews() async {
    return await _fetchRss('https://finance.yahoo.com/news/rssindex', 'YAHOO FINANCE');
  }

  Future<List<Map<String, dynamic>>> getIndicesNews() async {
    return await _fetchRss('https://feeds.bbci.co.uk/news/business/market-data/rss.xml', 'BBC MARKETS');
  }

  Future<List<Map<String, dynamic>>> getCommodityNews() async {
    return await _fetchRss('https://www.kitco.com/rss/kitconews.rss', 'KITCO');
  }

  Future<List<Map<String, dynamic>>> getMediastackForexNews() async {
    return await _fetchRss('https://www.forexlive.com/feed/news', 'FOREXLIVE');
  }

  Future<List<Map<String, dynamic>>> getMediastackCryptoNews() async {
    return await _fetchRss('https://coindesk.com/arc/outboundfeeds/rss/', 'COINDESK');
  }

  Future<List<Map<String, dynamic>>> getMediastackCommodityNews() async {
    return await _fetchRss('https://oilprice.com/rss/main', 'OILPRICE');
  }

  Future<List<Map<String, dynamic>>> getNewsApiArticles(String query) async {
    return await _fetchRss('https://finance.yahoo.com/news/rssindex', 'YAHOO');
  }
  Future<List<Map<String, dynamic>>> getEarthquakes() async {
    try {
      final url = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_week.geojson';
      final res = await _client.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final body = utf8.decode(res.bodyBytes, allowMalformed: true);
        final data = json.decode(body);
        final features = data['features'] as List? ?? [];
        return features.map((f) {
          final props = f['properties'] as Map<String, dynamic>? ?? {};
          final geom = f['geometry'] as Map<String, dynamic>? ?? {};
          final coords = geom['coordinates'] as List? ?? [];
          return {
            'title': props['title'] ?? '',
            'mag': props['mag'],
            'place': props['place'] ?? '',
            'time': props['time'],
            'url': props['url'] ?? '',
            'lon': coords.isNotEmpty ? coords[0] : null,
            'lat': coords.length > 1 ? coords[1] : null,
          };
        }).toList();
      }
    } catch (e) { print('Earthquakes: $e'); }
    return [];
  }
  Future<List<Map<String, dynamic>>> getDisasters() async {
    try {
      final url = 'https://eonet.gsfc.nasa.gov/api/v3/events?status=open&limit=20';
      final res = await _client.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final body = utf8.decode(res.bodyBytes, allowMalformed: true);
        final data = json.decode(body);
        final events = data['events'] as List? ?? [];
        return events.map((e) {
          final categories = e['categories'] as List? ?? [];
          final catTitle = categories.isNotEmpty ? (categories[0]['title'] ?? 'Event') : 'Event';
          final geoms = e['geometry'] as List? ?? [];
          final coords = geoms.isNotEmpty ? (geoms.last['coordinates'] as List? ?? []) : [];
          final dateStr = geoms.isNotEmpty ? geoms.last['date'] : null;
          return {
            'title': e['title'] ?? '',
            'category': catTitle,
            'url': (e['sources'] as List?)?.isNotEmpty == true ? e['sources'][0]['url'] ?? '' : '',
            'date': dateStr,
            'lon': coords.isNotEmpty ? coords[0] : null,
            'lat': coords.length > 1 ? coords[1] : null,
          };
        }).toList();
      }
    } catch (e) { print('Disasters: $e'); }
    return [];
  }
  Future<List<Map<String, dynamic>>> getGdeltEvents() async {
    try {
      final url = 'https://api.gdeltproject.org/api/v2/doc/doc?query=sourcelang:eng%20(conflict%20OR%20protest%20OR%20crisis)&mode=artlist&maxrecords=20&format=json&sort=datedesc';
      final res = await _client.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final body = utf8.decode(res.bodyBytes, allowMalformed: true);
        if (!body.trim().startsWith('{')) { print('GDELT: non-json response (likely rate limited)'); return []; }
        final data = json.decode(body);
        final arts = data['articles'] as List? ?? [];
        return arts.map((a) => {
          'title': a['title'] ?? '',
          'url': a['url'] ?? '',
          'domain': a['domain'] ?? '',
          'seendate': a['seendate'] ?? '',
        }).toList();
      }
    } catch (e) { print('GDELT: $e'); }
    return [];
  }
}







