import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/stock_viewmodel.dart';
import '../models/search_data.dart';
import '../widgets/prediction_chart_widget.dart'; 

class PredictionScreen extends StatelessWidget {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StockViewModel>(context, listen: false);

    // Asumsi kita menampilkan semua saham yang ada di 'search_results'
    Future<List<CompanySearchResult>> futureResults = viewModel.apiService
        .searchCompany('');

    return FutureBuilder<List<CompanySearchResult>>(
      future: futureResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Gagal memuat daftar saham: ${snapshot.error}'),
          );
        }

        final stocks = snapshot.data ?? [];

        return ListView.builder(
          itemCount: stocks.length,
          itemBuilder: (context, index) {
            final stock = stocks[index];
            return ListTile(
              leading: const Icon(Icons.analytics, color: Colors.orange),
              title: Text(
                stock.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Simbol: ${stock.symbol}'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Navigasi ke Chart Prediksi
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          PredictionChartScreen(symbol: stock.symbol),
                    ),
                  );
                },
                child: const Text('Mulai Prediksi'),
              ),
            );
          },
        );
      },
    );
  }
}
