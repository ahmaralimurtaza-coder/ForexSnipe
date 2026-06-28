import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ── ALL API KEYS ──
  static const String _finnhubKey      = 'd90cstpr01qk8bfkjeq0d90cstpr01qk8bfkjeqg';
  static const String _alphaVantageKey = 'O18ZSSREDGIJXJW5';
  static const String _mediastackKey   = '0f4517ce9ef6a7891cba0892517e9b6a';
  static const String _newsApiKey      = '1b64f827220b48f7b3645d6d3aa9edf9';
  static const String _forexNewsKey    = '54398889d916ecc2d6af929328a42055';
  static const String _massiveKey      = 'Ep9JBJ44g9F8E2xzxpViPfaPRhZ_UV9B';
  static const String _tiingoKey       = '2ba30238a0a10fb0d87a54e1484d6716f176527d';
  static const String _fixerKey        = 'f91677b613d3fa627db71b15e896bb09';
  static const String _marketstackKey  = 'ccd5e625dee1d9c075cc906bbeea84c7';

  // ── BASE URLS ──
  static const String _finnhub      = 'https://finnhub.io/api/v1';
  static const String _alphaVantage = 'https://www.alphavantage.co/query';
  static const String _coingecko    = 'https://api.coingecko.com/api/v3';
  static const String _exchangeRate = 'https://open.er-api.com/v6/latest/USD';
  static const String _cftc         = 'https://publicreporting.cftc.gov/resource/6dca-aqww.json';
  static const String _mediastack   = 'http://api.mediastack.com/v1/news';
  static const String _newsApi      = 'https://newsapi.org/v2/everything';
  static const String _tiingo       = 'https://api.tiingo.com';
  static const String _fixer        = 'http://data.fixer.io/api';
  static const String _marketstack  = 'http://api.marketstack.com/v1';
  static const String _yahooFinance = 'https://query1.finance.yahoo.com/v8/finance/chart';
  static const String _yahooQuote   = 'https://query1.finance.yahoo.com/v7/finance/quote';
  static const String _stooq        = 'https://stooq.com/q/l';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();

  // ════════════════════════════════════════
  // FOREX RATES
  // ════════════════════════════════════════

  // Source 1: ExchangeRate API (Free, No Key)
  Future<Map<String, double>> getForexRates() async {
    try {
      final res = await _client
          .get(Uri.parse(_exchangeRate))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data  = json.decode(res.body);
        final rates = Map<String, dynamic>.from(data['rates']);
        return rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    } catch (e) {
      print('ExchangeRate error: $e');
    }
    return {};
  }

  // Source 2: Fixer.io (500 req/month free)
  Future<Map<String, double>> getFixerRates() async {
    try {
      final url = '$_fixer/latest?access_key=$_fixerKey&base=USD';
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          final rates = Map<String, dynamic>.from(data['rates']);
          return rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
        }
      }
    } catch (e) {
      print('Fixer error: $e');
    }
    return {};
  }

  double getPairPrice(
      Map<String, double> rates, String base, String quote) {
    if (base == 'USD') {
      return rates[quote] ?? 0.0;
    } else if (quote == 'USD') {
      final r = rates[base];
      return r != null && r != 0 ? 1.0 / r : 0.0;
    } else {
      final b = rates[base];
      final q = rates[quote];
      if (b != null && q != null && b != 0) return q / b;
    }
    return 0.0;
  }

  // ════════════════════════════════════════
  // STOCKS — Multiple Sources
  // ════════════════════════════════════════

  // Source 1: Yahoo Finance (Free, No Key)
  Future<Map<String, dynamic>> getYahooQuote(String symbol) async {
    try {
      final url = '$_yahooFinance/$symbol'
          '?interval=1d&range=5d';
      final res = await _client.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final data   = json.decode(res.body);
        final result = data['chart']['result'];
        if (result != null && result.isNotEmpty) {
          final meta    = result[0]['meta'];
          final price   = (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0;
          final prevCls = (meta['chartPreviousClose'] as num?)?.toDouble() ?? 0;
          final change  = price - prevCls;
          final chgPct  = prevCls > 0 ? (change / prevCls) * 100 : 0.0;

          // Spark from closes
          final closes = result[0]['indicators']?['quote']?[0]?['close'] as List?;
          final spark = closes
              ?.whereType<num>()
              .map((e) => e.toDouble())
              .toList() ?? <double>[];

          return {
            'price':     price,
            'change':    change,
            'changePct': chgPct,
            'high':      (meta['regularMarketDayHigh']  as num?)?.toDouble() ?? 0,
            'low':       (meta['regularMarketDayLow']   as num?)?.toDouble() ?? 0,
            'volume':    (meta['regularMarketVolume']   as num?)?.toDouble() ?? 0,
            'prevClose': prevCls,
            'name':       meta['longName']              as String? ?? symbol,
            'spark':      spark,
          };
        }
      }
    } catch (e) {
      print('Yahoo Finance error ($symbol): $e');
    }
    return {};
  }

  // Source 2: Tiingo (500 req/day free)
  Future<Map<String, dynamic>> getTiingoQuote(String symbol) async {
    try {
      final url = '$_tiingo/iex/$symbol?token=$_tiingoKey';
      final res = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List?;
        if (list != null && list.isNotEmpty) {
          final q = list[0] as Map<String, dynamic>;
          final price   = (q['last']      as num?)?.toDouble() ?? 0;
          final prevCls = (q['prevClose'] as num?)?.toDouble() ?? 0;
          final change  = price - prevCls;
          final chgPct  = prevCls > 0 ? (change / prevCls) * 100 : 0.0;
          return {
            'price':     price,
            'change':    change,
            'changePct': chgPct,
            'high':      (q['high'] as num?)?.toDouble() ?? 0,
            'low':       (q['low']  as num?)?.toDouble() ?? 0,
            'volume':    (q['volume'] as num?)?.toDouble() ?? 0,
          };
        }
      }
    } catch (e) {
      print('Tiingo error ($symbol): $e');
    }
    return {};
  }

  // Source 3: Marketstack (100 req/month free)
  Future<Map<String, dynamic>> getMarketstackQuote(String symbol) async {
    try {
      final url = '$_marketstack/eod/latest'
          '?access_key=$_marketstackKey&symbols=$symbol';
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final list = data['data'] as List?;
        if (list != null && list.isNotEmpty) {
          final q      = list[0] as Map<String, dynamic>;
          final price  = (q['close'] as num?)?.toDouble() ?? 0;
          final open   = (q['open']  as num?)?.toDouble() ?? 0;
          final change = price - open;
          final chgPct = open > 0 ? (change / open) * 100 : 0.0;
          return {
            'price':     price,
            'change':    change,
            'changePct': chgPct,
            'high':      (q['high']   as num?)?.toDouble() ?? 0,
            'low':       (q['low']    as num?)?.toDouble() ?? 0,
            'volume':    (q['volume'] as num?)?.toDouble() ?? 0,
          };
        }
      }
    } catch (e) {
      print('Marketstack error ($symbol): $e');
    }
    return {};
  }

  // Best stock quote — tries Yahoo first, then Tiingo
  Future<Map<String, dynamic>> getBestStockQuote(String symbol) async {
    // Try Yahoo Finance first (free, no key)
    final yahoo = await getYahooQuote(symbol);
    if (yahoo.isNotEmpty && (yahoo['price'] as double) > 0) return yahoo;

    // Fallback to Tiingo
    final tiingo = await getTiingoQuote(symbol);
    if (tiingo.isNotEmpty) return tiingo;

    return {};
  }

  // ════════════════════════════════════════
  // INDICES — Yahoo Finance (Free, No Key)
  // ════════════════════════════════════════

  // Yahoo Finance symbols for indices
  static const Map<String, String> indexSymbols = {
    'S&P 500':   '^GSPC',
    'NASDAQ':    '^IXIC',
    'DOW JONES': '^DJI',
    'FTSE 100':  '^FTSE',
    'DAX 40':    '^GDAXI',
    'NIKKEI':    '^N225',
    'CAC 40':    '^FCHI',
    'HANG SENG': '^HSI',
    'ASX 200':   '^AXJO',
    'VIX':       '^VIX',
  };

  Future<Map<String, Map<String, dynamic>>> getAllIndices() async {
    final results = <String, Map<String, dynamic>>{};
    for (final entry in indexSymbols.entries) {
      final data = await getYahooQuote(entry.value);
      if (data.isNotEmpty) {
        results[entry.key] = data;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return results;
  }

  // ════════════════════════════════════════
  // FUTURES — Yahoo Finance (Free, No Key)
  // ════════════════════════════════════════

  static const Map<String, String> futuresSymbols = {
    'ES1! SPX':  'ES=F',
    'NQ1! NAS':  'NQ=F',
    'YM1! DOW':  'YM=F',
    'GC1! GOLD': 'GC=F',
    'CL1! OIL':  'CL=F',
    'SI1! SILV': 'SI=F',
    'ZB1! BOND': 'ZB=F',
    'HG1! COP':  'HG=F',
  };

  Future<Map<String, Map<String, dynamic>>> getAllFutures() async {
    final results = <String, Map<String, dynamic>>{};
    for (final entry in futuresSymbols.entries) {
      final data = await getYahooQuote(entry.value);
      if (data.isNotEmpty) {
        results[entry.key] = data;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return results;
  }

  // ════════════════════════════════════════
  // COMMODITIES — Yahoo Finance + Alpha Vantage
  // ════════════════════════════════════════

  static const Map<String, String> commoditySymbols = {
    'WTI OIL': 'CL=F',
    'BRENT':   'BZ=F',
    'NAT GAS': 'NG=F',
    'COPPER':  'HG=F',
    'WHEAT':   'ZW=F',
    'CORN':    'ZC=F',
    'COTTON':  'CT=F',
  };

  Future<Map<String, Map<String, dynamic>>> getAllCommodities() async {
    final results = <String, Map<String, dynamic>>{};
    for (final entry in commoditySymbols.entries) {
      final data = await getYahooQuote(entry.value);
      if (data.isNotEmpty) {
        results[entry.key] = data;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return results;
  }

  // Gold + Silver via Alpha Vantage
  Future<Map<String, double>> getMetalPrices() async {
    final metals = <String, double>{};
    try {
      // Try Yahoo first
      final gold = await getYahooQuote('GC=F');
      if ((gold['price'] as double? ?? 0) > 0) {
        metals['XAU/USD'] = gold['price'] as double;
      } else {
        // Fallback to Alpha Vantage
        final avgGold = await _getAlphaForexRate('XAU', 'USD');
        if ((avgGold['rate'] ?? 0) > 0) metals['XAU/USD'] = avgGold['rate']!;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final silver = await getYahooQuote('SI=F');
      if ((silver['price'] as double? ?? 0) > 0) {
        metals['XAG/USD'] = silver['price'] as double;
      } else {
        final avgSilver = await _getAlphaForexRate('XAG', 'USD');
        if ((avgSilver['rate'] ?? 0) > 0) metals['XAG/USD'] = avgSilver['rate']!;
      }
    } catch (e) {
      print('Metal prices error: $e');
    }
    return metals;
  }

  Future<Map<String, double>> _getAlphaForexRate(
      String from, String to) async {
    try {
      final url = '$_alphaVantage'
          '?function=CURRENCY_EXCHANGE_RATE'
          '&from_currency=$from'
          '&to_currency=$to'
          '&apikey=$_alphaVantageKey';
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final info = data['Realtime Currency Exchange Rate'];
        if (info != null) {
          return {
            'rate': double.tryParse(info['5. Exchange Rate'] ?? '0') ?? 0,
          };
        }
      }
    } catch (e) {
      print('Alpha forex error: $e');
    }
    return {};
  }

  // ════════════════════════════════════════
  // CRYPTO — CoinGecko (Free, No Key)
  // ════════════════════════════════════════

  Future<Map<String, dynamic>> getCryptoPrices() async {
    try {
      final url = '$_coingecko/coins/markets'
          '?vs_currency=usd'
          '&ids=bitcoin,ethereum,binancecoin,solana,ripple,'
          'cardano,dogecoin,avalanche-2,chainlink,polkadot'
          '&order=market_cap_desc'
          '&per_page=10'
          '&page=1'
          '&sparkline=true'
          '&price_change_percentage=24h';
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final list   = json.decode(res.body) as List;
        final result = <String, dynamic>{};
        for (final coin in list) {
          final id = coin['id'] as String;
          result[id] = {
            'price':     (coin['current_price']               as num?)?.toDouble() ?? 0,
            'change':    (coin['price_change_24h']            as num?)?.toDouble() ?? 0,
            'changePct': (coin['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
            'high':      (coin['high_24h']                    as num?)?.toDouble() ?? 0,
            'low':       (coin['low_24h']                     as num?)?.toDouble() ?? 0,
            'volume':    (coin['total_volume']                as num?)?.toDouble() ?? 0,
            'marketCap': (coin['market_cap']                  as num?)?.toDouble() ?? 0,
            'symbol':     coin['symbol'] as String? ?? '',
            'name':       coin['name']   as String? ?? '',
            'sparkline':  (coin['sparkline_in_7d']?['price'] as List?)
                ?.map((e) => (e as num).toDouble())
                .toList() ?? <double>[],
          };
        }
        return result;
      }
    } catch (e) {
      print('Crypto prices error: $e');
    }
    return {};
  }

  // ════════════════════════════════════════
  // NEWS — 4 Sources
  // ════════════════════════════════════════

  // Finnhub News (Free Forever)
  Future<List<Map<String, dynamic>>> getFinnhubNews(String category) async {
    try {
      final url = '$_finnhub/news?category=$category&token=$_finnhubKey';
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List;
        return list.take(25).map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Finnhub news error: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getFinnhubCompanyNews(String symbol) async {
    try {
      final now  = DateTime.now();
      final from = now.subtract(const Duration(days: 3));
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
      final url = '$_finnhub/company-news'
          '?symbol=$symbol&from=${fmt(from)}&to=${fmt(now)}&token=$_finnhubKey';
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List;
        return list.take(10).map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Finnhub company news error: $e');
    }
    return [];
  }

  // NewsAPI (100 req/day free)
  Future<List<Map<String, dynamic>>> getNewsApiArticles(String query) async {
    try {
      final url = '$_newsApi'
          '?q=${Uri.encodeComponent(query)}'
          '&language=en'
          '&sortBy=publishedAt'
          '&pageSize=15'
          '&apiKey=$_newsApiKey';
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final data     = json.decode(res.body);
        final articles = data['articles'] as List? ?? [];
        return articles
            .map((e) => Map<String, dynamic>.from(e))
            .where((a) => a['title'] != null && a['title'] != '[Removed]')
            .toList();
      }
    } catch (e) {
      print('NewsAPI error ($query): $e');
    }
    return [];
  }

  // Mediastack (500 req/month free)
  Future<List<Map<String, dynamic>>> getMediastackNews(String keywords) async {
    try {
      final url = '$_mediastack'
          '?access_key=$_mediastackKey'
          '&keywords=${Uri.encodeComponent(keywords)}'
          '&languages=en'
          '&sort=published_desc'
          '&limit=15';
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final list = data['data'] as List? ?? [];
        return list
            .map((e) => Map<String, dynamic>.from(e))
            .where((a) => a['title'] != null)
            .toList();
      }
    } catch (e) {
      print('Mediastack error: $e');
    }
    return [];
  }

  // ════════════════════════════════════════
  // ECONOMIC CALENDAR — Finnhub
  // ════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getEconomicCalendar() async {
    try {
      final now  = DateTime.now();
      final from = now.subtract(const Duration(days: 1));
      final to   = now.add(const Duration(days: 7));
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
      final url = '$_finnhub/calendar/economic'
          '?from=${fmt(from)}&to=${fmt(to)}&token=$_finnhubKey';
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['economicCalendar'] != null) {
          return List<Map<String, dynamic>>.from(data['economicCalendar']);
        }
      }
    } catch (e) {
      print('Calendar error: $e');
    }
    return [];
  }

  // ════════════════════════════════════════
  // COT DATA — CFTC.gov (Free Forever)
  // ════════════════════════════════════════

  Future<List<Map<String, dynamic>>> _fetchCftc(String whereClause) async {
    try {
      final url = Uri.encodeFull(
          '$_cftc?\$where=$whereClause&\$limit=30&\$order=report_date_as_yyyy_mm_dd DESC');
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(res.body));
      }
    } catch (e) {
      print('CFTC error: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getForexCot() => _fetchCftc(
      "market_and_exchange_names like '%EURO FX%'"
          " OR market_and_exchange_names like '%BRITISH POUND%'"
          " OR market_and_exchange_names like '%JAPANESE YEN%'"
          " OR market_and_exchange_names like '%AUSTRALIAN DOLLAR%'"
          " OR market_and_exchange_names like '%CANADIAN DOLLAR%'"
          " OR market_and_exchange_names like '%SWISS FRANC%'");

  Future<List<Map<String, dynamic>>> getCommodityCot() => _fetchCftc(
      "market_and_exchange_names like '%GOLD%'"
          " OR market_and_exchange_names like '%SILVER%'"
          " OR market_and_exchange_names like '%CRUDE OIL%'"
          " OR market_and_exchange_names like '%WHEAT%'"
          " OR market_and_exchange_names like '%CORN%'");

  Future<List<Map<String, dynamic>>> getIndicesCot() => _fetchCftc(
      "market_and_exchange_names like '%S&P 500%'"
          " OR market_and_exchange_names like '%NASDAQ%'"
          " OR market_and_exchange_names like '%DOW JONES%'");

  // ════════════════════════════════════════
  // SENTIMENT — Finnhub
  // ════════════════════════════════════════

  Future<Map<String, dynamic>> getStockSentiment(String symbol) async {
    try {
      final url = '$_finnhub/news-sentiment?symbol=$symbol&token=$_finnhubKey';
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Sentiment error ($symbol): $e');
    }
    return {};
  }

  void dispose() => _client.close();
}