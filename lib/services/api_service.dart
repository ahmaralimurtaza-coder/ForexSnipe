import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
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
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final rates = json.decode(res.body)['rates'] as Map<String, dynamic>?;
        if (rates != null) return rates.map((k, v) => MapEntry(k, double.tryParse(v.toString()) ?? 0.0));
      }
    } catch (e) { print('CurrencyFreaks: '); }
    return {};
  }

  Future<Map<String, double>> getFrankfurterRates() async {
    try {
      final res = await _client
          .get(Uri.parse('/latest?from=USD'), headers: _h)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data  = json.decode(res.body);
        final rates = Map<String, double>.from(
            (data['rates'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toDouble())));
        rates['USD'] = 1.0;
        return rates;
      }
    } catch (e) { print('Frankfurter: '); }
    return {};
  }

  Future<Map<String, double>> getForexRates() async {
    try {
      final res = await _client.get(Uri.parse(_exchangeRate), headers: _h).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(res.body)['rates'])
            .map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    } catch (e) { print('ExchangeRate: '); }
    return {};
  }

  Future<Map<String, double>> getFixerRates() async {
    try {
      final res = await _client
          .get(Uri.parse('/latest?access_key=&base=EUR'), headers: _h)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['rates'] != null)
          return Map<String, dynamic>.from(data['rates']).map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    } catch (e) { print('Fixer: '); }
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
      ).timeout(const Duration(seconds: 10));
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
    } catch (e) { print('GoldAPI (): '); }
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
    } catch (e) { print('Binance (): '); }
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
    } catch (e) { print('Binance spark (): '); }
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
    } catch (e) { print('Binance crypto: '); }
    return result;
  }

  Future<Map<String, dynamic>> _getCoinCapCrypto() async {
    try {
      const ids = 'bitcoin,ethereum,binance-coin,solana,xrp,cardano,dogecoin,avalanche,chainlink,polkadot';
      final res = await _client
          .get(Uri.parse('/assets?ids=&limit=10'), headers: _h)
          .timeout(const Duration(seconds: 10));
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
    } catch (e) { print('CoinCap: '); }
    return {};
  }

  Future<Map<String, dynamic>> _getCoinGeckoCrypto() async {
    try {
      final url = '/coins/markets?vs_currency=usd'
          '&ids=bitcoin,ethereum,binancecoin,solana,ripple,cardano,dogecoin,avalanche-2,chainlink,polkadot'
          '&order=market_cap_desc&per_page=10&page=1&sparkline=true&price_change_percentage=24h';
      final res = await _client.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 12));
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
    } catch (e) { print('CoinGecko: '); }
    return {};
  }

  // ═══ STOCKS / INDICES / COMMODITIES / FUTURES ═══

  Future<Map<String, dynamic>> getYahooQuote(String symbol) async {
    for (final base in [_yahoo, _yahoo2]) {
      try {
        final res = await _client
            .get(Uri.parse('/=1d&range=5d'), headers: _h)
            .timeout(const Duration(seconds: 12));
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
      } catch (e) { print('Yahoo (): '); }
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
          .timeout(const Duration(seconds: 10));
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
    } catch (e) { print('Tiingo (): '); }
    return {};
  }

  // ═══ NEWS ═══

  Future<List<Map<String, dynamic>>> getReutersNews() async {
    try {
      const feeds = [
        'https://feeds.reuters.com/reuters/businessNews',
        'https://feeds.reuters.com/reuters/UKBusinessNews',
      ];
      final all = <Map<String, dynamic>>[];
      for (final feed in feeds) {
        final res = await _client
            .get(Uri.parse('=&count=10'), headers: _h)
            .timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final items = json.decode(res.body)['items'] as List? ?? [];
          for (final i in items) {
            all.add({'title':i['title']??'','source':'REUTERS','url':i['link']??'','publishedAt':i['pubDate']??''});
          }
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }
      return all;
    } catch (e) { print('Reuters: '); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getMarketWatchNews() async {
    try {
      const feeds = [
        'https://feeds.marketwatch.com/marketwatch/topstories/',
        'https://feeds.marketwatch.com/marketwatch/marketpulse/',
      ];
      final all = <Map<String, dynamic>>[];
      for (final feed in feeds) {
        final res = await _client
            .get(Uri.parse('=&count=10'), headers: _h)
            .timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final items = json.decode(res.body)['items'] as List? ?? [];
          for (final i in items) {
            all.add({'title':i['title']??'','source':'MARKETWATCH','url':i['link']??'','publishedAt':i['pubDate']??''});
          }
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }
      return all;
    } catch (e) { print('MarketWatch: '); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getCnbcNews() async {
    try {
      const feeds = [
        'https://www.cnbc.com/id/10000664/device/rss/rss.html',
        'https://www.cnbc.com/id/20910258/device/rss/rss.html',
      ];
      final all = <Map<String, dynamic>>[];
      for (final feed in feeds) {
        final res = await _client
            .get(Uri.parse('=&count=10'), headers: _h)
            .timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final items = json.decode(res.body)['items'] as List? ?? [];
          for (final i in items) {
            all.add({'title':i['title']??'','source':'CNBC','url':i['link']??'','publishedAt':i['pubDate']??''});
          }
        }
      }
      return all;
    } catch (e) { print('CNBC: '); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getInvestingNews(String category) async {
    try {
      const catMap = {
        'forex':       'https://www.investing.com/rss/news_25.rss',
        'crypto':      'https://www.investing.com/rss/news_301.rss',
        'stocks':      'https://www.investing.com/rss/news_14.rss',
        'commodities': 'https://www.investing.com/rss/news_8.rss',
        'economy':     'https://www.investing.com/rss/news_95.rss',
      };
      final feed = catMap[category] ?? catMap['forex']!;
      final res  = await _client
          .get(Uri.parse('=&count=15'), headers: _h)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final items = json.decode(res.body)['items'] as List? ?? [];
        return items.map((i) => {
          'title':i['title']??'','source':'INVESTING.COM',
          'url':i['link']??'','publishedAt':i['pubDate']??''
        }).toList();
      }
    } catch (e) { print('Investing (): '); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getFinnhubNews(String category) async {
    try {
      final res = await _client
          .get(Uri.parse('/news?category=&token='), headers: _h)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return (json.decode(res.body) as List).take(20).map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) { print('Finnhub news: '); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getFinnhubCompanyNews(String symbol) async {
    try {
      final now  = DateTime.now();
      final from = now.subtract(const Duration(days: 3));
      String fmt(DateTime d) => '--';
      final res = await _client
          .get(Uri.parse('/company-news?symbol=&from=&to=&token='), headers: _h)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return (json.decode(res.body) as List).take(10).map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) { print('Finnhub company: '); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getNewsApiArticles(String query) async {
    try {
      final url = '=&language=en&sortBy=publishedAt&pageSize=15&apiKey=';
      final res = await _client.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        return (json.decode(res.body)['articles'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .where((a) => a['title'] != null && a['title'] != '[Removed]')
            .toList();
      }
    } catch (e) { print('NewsAPI: '); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getStockNews()     => getNewsApiArticles('stock market OR S&P 500 OR NASDAQ OR earnings');
  Future<List<Map<String, dynamic>>> getIndicesNews()   => getNewsApiArticles('stock index OR Dow Jones OR FTSE OR DAX OR Nikkei');
  Future<List<Map<String, dynamic>>> getCommodityNews() => getNewsApiArticles('gold price OR crude oil OR silver OR commodity');
  Future<List<Map<String, dynamic>>> getFuturesNews()   => getNewsApiArticles('futures market OR crude futures');

  Future<List<Map<String, dynamic>>> getMediastackNews(String kw) async {
    try {
      final res = await _client
          .get(Uri.parse('=&keywords=&languages=en&sort=published_desc&limit=20'), headers: _h)
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        return (json.decode(res.body)['data'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .where((a) => a['title'] != null)
            .toList();
      }
    } catch (e) { print('Mediastack: '); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getMediastackForexNews()     => getMediastackNews('forex,currency,EUR USD,GBP JPY');
  Future<List<Map<String, dynamic>>> getMediastackCryptoNews()    => getMediastackNews('bitcoin,ethereum,cryptocurrency');
  Future<List<Map<String, dynamic>>> getMediastackCommodityNews() => getMediastackNews('gold price,crude oil,silver commodity');

  // ═══ CALENDAR ═══

  Future<List<Map<String, dynamic>>> getEconomicCalendar() async {
    try {
      final now  = DateTime.now();
      final from = now.subtract(const Duration(days: 1));
      final to   = now.add(const Duration(days: 7));
      String fmt(DateTime d) => '--';
      final res = await _client
          .get(Uri.parse('/calendar/economic?from=&to=&token='), headers: _h)
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['economicCalendar'] != null) return List<Map<String, dynamic>>.from(data['economicCalendar']);
      }
    } catch (e) { print('Calendar: '); }
    return [];
  }

  // ═══ COT ═══

  Future<List<Map<String, dynamic>>> _fetchCftc(String where) async {
    try {
      final url = Uri.encodeFull('\=&\=30&\=report_date_as_yyyy_mm_dd DESC');
      final res = await _client.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(res.body));
    } catch (e) { print('CFTC: '); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getForexCot() => _fetchCftc(
    "market_and_exchange_names like '%EURO FX%' OR market_and_exchange_names like '%BRITISH POUND%' OR "
    "market_and_exchange_names like '%JAPANESE YEN%' OR market_and_exchange_names like '%AUSTRALIAN DOLLAR%' OR "
    "market_and_exchange_names like '%CANADIAN DOLLAR%' OR market_and_exchange_names like '%SWISS FRANC%'"
  );

  Future<List<Map<String, dynamic>>> getCommodityCot() => _fetchCftc(
    "market_and_exchange_names like '%GOLD%' OR market_and_exchange_names like '%SILVER%' OR "
    "market_and_exchange_names like '%CRUDE OIL%' OR market_and_exchange_names like '%WHEAT%' OR "
    "market_and_exchange_names like '%CORN%'"
  );

  Future<List<Map<String, dynamic>>> getIndicesCot() => _fetchCftc(
    "market_and_exchange_names like '%S&P 500%' OR market_and_exchange_names like '%NASDAQ%' OR "
    "market_and_exchange_names like '%DOW JONES%'"
  );

  void dispose() => _client.close();
}
