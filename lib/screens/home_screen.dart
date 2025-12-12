import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/stock_viewmodel.dart';
import '../widgets/stock_chart_widget.dart';
import '../screens/search_screen.dart';
import '../screens/category_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isEmbedded;
  const HomeScreen({super.key, this.isEmbedded = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StockViewModel>(
        context,
        listen: false,
      ).fetchStockHistory('AAPL');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockViewModel>(
      builder: (context, viewModel, child) {
        // Logika sudah benar: gunakan widget.isEmbedded
        if (!widget.isEmbedded) {
          return Scaffold(body: _buildContent(viewModel));
        }
        return _buildContent(viewModel);
      },
    );
  }

  // Pisahkan logika content utama
  Widget _buildContent(StockViewModel viewModel) {
    // ... (sisa kode _buildContent tetap sama) ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Ringkas (Simbol, Harga Terbaru)
        _buildHeader(
          viewModel.currentSymbol,
          viewModel.stockHistory.isNotEmpty
              ? viewModel.stockHistory.last.close
              : 0.0,
        ),
        const SizedBox(height: 10),
        Expanded(child: _buildUIBasedOnState(viewModel)),
      ],
    );
  }

  Widget _buildHeader(String symbol, double latestClose) {
    // ... (sisa kode _buildHeader tetap sama) ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Historis 30 Hari',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          'Harga Penutupan: \$${latestClose.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildUIBasedOnState(StockViewModel viewModel) {
    // ... (sisa kode _buildUIBasedOnState tetap sama) ...
    switch (viewModel.state) {
      case ViewState.initial:
        return const Center(child: Text('Memuat data awal...'));

      case ViewState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        ); // Indikator Visual

      case ViewState.error:
        // Error State
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              Text(
                'Gagal memuat data: ${viewModel.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () =>
                    viewModel.fetchStockHistory(viewModel.currentSymbol),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );

      case ViewState.loaded:
        // Success State
        if (viewModel.stockHistory.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada data historis yang tersedia untuk simbol ini.',
            ),
          );
        }
        return StockChartWidget(history: viewModel.stockHistory);
      default:
        return const Center(child: Text('State tidak dikenal.'));
    }
  }
}
