class ForexPair {
  final String pair, flag, category;
  final double price, change, changePct;
  final bool isUp;
  final List<double> spark;

  ForexPair({
    required this.pair, required this.flag,
    required this.price, required this.change,
    required this.changePct, required this.isUp,
    required this.spark, this.category = 'Forex',
  });
}

class NewsItem {
  final String source, title, timeAgo, sentiment, url, category;
  final List<String> pairs;

  NewsItem({
    required this.source, required this.title,
    required this.timeAgo, required this.sentiment,
    required this.pairs, required this.url,
    this.category = 'Forex',
  });
}

class CalendarEvent {
  final String time, currency, event, impact, actual, forecast, previous, category;
  final bool? isBetter;

  CalendarEvent({
    required this.time, required this.currency,
    required this.event, required this.impact,
    required this.actual, required this.forecast,
    required this.previous, this.isBetter,
    this.category = 'Forex',
  });
}

class CotData {
  final String pair, weekEnding, category;
  final int nonCommercialLong, nonCommercialShort;
  final int commercialLong, commercialShort;
  final int smallTraderLong, smallTraderShort;
  final int openInterest;

  CotData({
    required this.pair,
    required this.nonCommercialLong, required this.nonCommercialShort,
    required this.commercialLong, required this.commercialShort,
    required this.smallTraderLong, required this.smallTraderShort,
    required this.openInterest, required this.weekEnding,
    this.category = 'Forex',
  });

  double get ncNetLong => nonCommercialLong - nonCommercialShort.toDouble();
  double get bullishPct => nonCommercialLong /
      (nonCommercialLong + nonCommercialShort) * 100;
}

class SentimentData {
  final String pair, source, category;
  final double longPct, shortPct;

  SentimentData({
    required this.pair, required this.longPct,
    required this.shortPct, required this.source,
    this.category = 'Forex',
  });
}

class DataSource {
  final String icon, name, description, tag, url, category;

  DataSource({
    required this.icon, required this.name,
    required this.description, required this.tag,
    required this.url, required this.category,
  });
}
