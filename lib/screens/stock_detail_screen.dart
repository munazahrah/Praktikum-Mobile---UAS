import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock_data.dart';
import '../viewmodels/stock_viewmodel.dart';

class StockDetailScreen extends StatelessWidget {
  final String symbol;
  const StockDetailScreen({super.key, required this.symbol});

  // Fungsi helper untuk memuat summary dari ApiService
  Future<StockSummary> _fetchSummary(BuildContext context) {
    final viewModel = Provider.of<StockViewModel>(context, listen: false);
    // Memanggil public getter apiService (perbaikan sebelumnya)
    return viewModel.apiService.fetchStockSummary(symbol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Saham: $symbol')),
      body: FutureBuilder<StockSummary>(
        // Mengambil detail informasi secara "real-time" (simulasi HTTP)
        future: _fetchSummary(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat detail: ${snapshot.error}'),
            );
          }

          final summary = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // --- Bagian Informasi Utama ---
                Text(
                  summary.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Simbol: ${summary.symbol}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),

                const Divider(height: 25),

                // --- Deskripsi Perusahaan ---
                const Text(
                  'Tentang Perusahaan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  summary.description,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),

                const Divider(height: 25),

                // --- Data Kunci (Kartu Detail) ---
                _buildDetailCard(
                  'Harga Penutupan Terbaru',
                  '\$${summary.latestPrice.toStringAsFixed(2)}',
                  Colors.green,
                ),
                _buildDetailCard(
                  'Volume Transaksi Terakhir',
                  summary.latestVolume.toString(),
                  Colors.blue,
                ),
                _buildDetailCard(
                  'Kapitalisasi Pasar',
                  summary.marketCap,
                  Colors.purple,
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget Pembantu untuk Kartu Detail
  Widget _buildDetailCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
