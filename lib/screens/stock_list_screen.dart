import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/stock_viewmodel.dart';
import '../models/search_data.dart'; 
import 'stock_detail_screen.dart';

class StockListScreen extends StatelessWidget {
  const StockListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StockViewModel>(context, listen: false);

    // Kita panggil fungsi searchCompany dengan query kosong
    // agar semua data di 'search_results' dimuat
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
              leading: const Icon(
                Icons.business_center,
                color: Color(0xFF1B5E20),
              ),
              title: Text(
                stock.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Simbol: ${stock.symbol}'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                // Navigasi ke Detail Informasi
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        StockDetailScreen(symbol: stock.symbol),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
