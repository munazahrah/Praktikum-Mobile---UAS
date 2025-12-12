import 'package:intl/intl.dart';

class StockData {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  StockData({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      date: DateTime.parse(json['date'] as String),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: json['volume'] as int,
    );
  }

  String get formattedDate => DateFormat('dd MMM yyyy').format(date);
}

// Model BARU untuk Detail Ringkasan Saham
class StockSummary {
  final String symbol;
  final String name;
  final double latestPrice;
  final int latestVolume;
  final String description;
  final String marketCap;

  StockSummary({
    required this.symbol,
    required this.name,
    required this.latestPrice,
    required this.latestVolume,
    required this.description,
    required this.marketCap,
  });
}

class PredictionData {
  final int day;
  final double predictedPrice;

  PredictionData({required this.day, required this.predictedPrice});

  factory PredictionData.fromJson(Map<String, dynamic> json) {
    return PredictionData(
      day: json['day'] as int,
      predictedPrice: (json['predicted_price'] as num).toDouble(),
    );
  }
}
