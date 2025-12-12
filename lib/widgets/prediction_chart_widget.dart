import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // <-- IMPORT BARU DARI FL_CHART
import '../models/stock_data.dart';
import '../viewmodels/stock_viewmodel.dart';

class PredictionChartScreen extends StatelessWidget {
  final String symbol;
  const PredictionChartScreen({super.key, required this.symbol});

  // Fungsi untuk membangun LineChart
  Widget _buildLineChart(List<PredictionData> predictions) {
    if (predictions.isEmpty) {
      return const Center(
        child: Text('Tidak ada data prediksi yang tersedia.'),
      );
    }

    // Tentukan harga minimum dan maksimum untuk skala Y-Axis
    final minPrice = predictions
        .map((p) => p.predictedPrice)
        .reduce((a, b) => a < b ? a : b);
    final maxPrice = predictions
        .map((p) => p.predictedPrice)
        .reduce((a, b) => a > b ? a : b);

    // Memberi sedikit padding di Y-Axis
    final chartMinY = minPrice - 0.5;
    final chartMaxY = maxPrice + 0.5;

    // Konversi PredictionData ke FlSpot
    final List<FlSpot> spots = predictions.map((data) {
      // Kita gunakan 'day' sebagai X (dari 1 hingga N)
      return FlSpot(data.day.toDouble(), data.predictedPrice);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          // Judul Sumbu X (Bawah)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Memberi label 'Day 1', 'Day 2', dst.
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    'H${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              interval: 1, // Tampilkan label setiap hari
            ),
          ),
          // Judul Sumbu Y (Kiri)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                // Tampilkan harga dengan 1 desimal
                return Text(
                  '\$${value.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          // Hapus Judul Atas dan Kanan
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: predictions.first.day.toDouble(),
        maxX: predictions.last.day.toDouble(),
        minY: chartMinY,
        maxY: chartMaxY,

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.deepOrange, // Warna untuk prediksi
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true), // Tampilkan titik data
            belowBarData: BarAreaData(
              show: true,
              color: Colors.deepOrange.withOpacity(0.2), // Area di bawah garis
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StockViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Prediksi GRU: $symbol')),
      body: FutureBuilder<List<PredictionData>>(
        future: viewModel.apiService.fetchPredictionData(symbol),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat prediksi: ${snapshot.error}'),
            );
          }

          final predictions = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hasil Analisis Model GRU (3 Hari ke Depan)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // --- TAMPILAN CHART NYATA ---
                Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      10,
                      20,
                      20,
                      10,
                    ), // Padding disesuaikan untuk chart
                    height: 250,
                    // Panggil fungsi chart yang sudah kita buat
                    child: _buildLineChart(predictions),
                  ),
                ),

                // -----------------------------
                const SizedBox(height: 20),
                const Text(
                  'Data Prediksi Mentah:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                // Tampilan Data Prediksi
                ...predictions
                    .map(
                      (p) => ListTile(
                        title: Text('Hari ke-${p.day}'),
                        trailing: Text(
                          '\$${p.predictedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
