import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/stock_data.dart';

class StockChartWidget extends StatelessWidget {
  final List<StockData> history;

  const StockChartWidget({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text('Data tidak cukup untuk grafik.'));
    }

    // Ambil harga penutupan (Close) untuk grafik garis
    final prices = history.map((e) => e.close).toList();
    if (prices.isEmpty) return const SizedBox();

    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);

    // Konversi data menjadi FlSpot
    final spots = prices
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();

    // Ambil harga penutupan hari ini (terakhir) dan sebelumnya
    final latestClose = history.last.close;
    final previousClose = history.length > 1
        ? history[history.length - 2].close
        : latestClose;
    final change = latestClose - previousClose;
    final changePercent = previousClose != 0
        ? (change / previousClose) * 100
        : 0.0;
    final isPositive = change >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tampilkan Harga Terbaru dan Perubahan
        _buildLatestPriceInfo(latestClose, change, changePercent, isPositive),
        const SizedBox(height: 15),

        // Grafik Saham
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      // Tampilkan label tanggal
                      if (value.toInt() % 7 == 0 &&
                          value.toInt() < history.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8.0,
                          child: Text(
                            history[value.toInt()].formattedDate.substring(
                              0,
                              6,
                            ),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (maxPrice - minPrice) / 3, // 3 Interval
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: isPositive
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color:
                        (isPositive
                                ? Colors.green.shade700
                                : Colors.red.shade700)
                            .withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestPriceInfo(
    double latestClose,
    double change,
    double changePercent,
    bool isPositive,
  ) {
    final color = isPositive ? Colors.green.shade700 : Colors.red.shade700;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Harga Penutupan Terbaru',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                '\$${latestClose.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
