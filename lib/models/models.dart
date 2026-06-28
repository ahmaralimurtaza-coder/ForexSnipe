class ForexPair {
  final String pair;
  final String flag;
  final double price;
  final double change;
  final double changePct;
  final bool isUp;
  final List<double> spark;
  final String category; // NEW

  ForexPair({
    required this.pair,
    required this.flag,
    required this.price,
    required this.change,
    required this.changePct,
    required this.isUp,
    required this.spark,
    this.category = 'Forex', // default
  });
}

class NewsItem {
  final String source;
  final String title;
  final String timeAgo;
  final String sentiment;
  final List<String> pairs;
  final String url;
  final String category; // NEW

  NewsItem({
    required this.source,
    required this.title,
    required this.timeAgo,
    required this.sentiment,
    required this.pairs,
    required this.url,
    this.category = 'Forex',
  });
}

class CalendarEvent {
  final String time;
  final String currency;
  final String event;
  final String impact;
  final String actual;
  final String forecast;
  final String previous;
  final bool? isBetter;
  final String category; // NEW

  CalendarEvent({
    required this.time,
    required this.currency,
    required this.event,
    required this.impact,
    required this.actual,
    required this.forecast,
    required this.previous,
    this.isBetter,
    this.category = 'Forex',
  });
}

class CotData {
  final String pair;
  final int nonCommercialLong;
  final int nonCommercialShort;
  final int commercialLong;
  final int commercialShort;
  final int smallTraderLong;
  final int smallTraderShort;
  final String weekEnding;
  final int openInterest;
  final String category; // NEW

  CotData({
    required this.pair,
    required this.nonCommercialLong,
    required this.nonCommercialShort,
    required this.commercialLong,
    required this.commercialShort,
    required this.smallTraderLong,
    required this.smallTraderShort,
    required this.weekEnding,
    required this.openInterest,
    this.category = 'Forex',
  });

  double get ncNetLong => nonCommercialLong - nonCommercialShort.toDouble();
  double get bullishPct =>
      nonCommercialLong / (nonCommercialLong + nonCommercialShort) * 100;
}

class SentimentData {
  final String pair;
  final double longPct;
  final double shortPct;
  final String source;
  final String category; // NEW

  SentimentData({
    required this.pair,
    required this.longPct,
    required this.shortPct,
    required this.source,
    this.category = 'Forex',
  });
}

class DataSource {
  final String icon;
  final String name;
  final String description;
  final String tag;
  final String url;
  final String category;

  DataSource({
    required this.icon,
    required this.name,
    required this.description,
    required this.tag,
    required this.url,
    required this.category,
  });
}