import 'package:flutter/material.dart';
import 'stock_detail_screen.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftar simbol yang tersedia di data statis npoint.io
    final availableSymbols = ['AAPL', 'MSFT', 'GOOG', 'TSLA'];

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kategori Saham')),
      body: ListView.builder(
        itemCount: availableSymbols.length,
        itemBuilder: (context, index) {
          final symbol = availableSymbols[index];

          return ListTile(
            leading: const Icon(Icons.category, color: Colors.blueGrey),
            title: Text(
              symbol,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Lihat Detail Informasi dan Prediksi'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigasi ke Detail Saham
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StockDetailScreen(symbol: symbol),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
