import 'dart:async'; // Diperlukan untuk Timer
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/stock_viewmodel.dart';
import '../models/search_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Tambahkan Timer untuk mekanisme Debounce
  Timer? _debounce;

  @override
  void dispose() {
    // Pastikan timer dibatalkan saat widget dibuang
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk menangani pencarian dengan Debounce
  void _onSearchChanged(String query, StockViewModel viewModel) {
    // 1. Batalkan timer sebelumnya
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 2. Jika query kosong, bersihkan hasil pencarian dan keluar
    if (query.isEmpty) {
      viewModel.clearSearch();
      return;
    }

    // 3. Hanya proses jika query minimal 2 karakter (sesuai pesan UI)
    if (query.length < 2) {
      // Jika kurang dari 2, kita tetap bersihkan hasil sebelumnya, tapi tidak panggil API/ViewModel.
      viewModel.clearSearch();
      return;
    }

    // 4. Set timer baru (Debounce: 500ms)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Panggil fungsi pencarian di ViewModel setelah penundaan
      viewModel.searchStocks(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StockViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Saham'),
        backgroundColor: Theme.of(context).primaryColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Cari Simbol atau Nama Perusahaan...',
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    // 1. Bersihkan controller
                    _searchController.clear();
                    // 2. Bersihkan hasil pencarian di ViewModel
                    viewModel.clearSearch();
                    // 3. Batalkan timer debounce jika aktif
                    _debounce?.cancel();
                  },
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
              // Panggil fungsi _onSearchChanged yang sudah menerapkan Debounce
              onChanged: (query) => _onSearchChanged(query, viewModel),
            ),
          ),
        ),
      ),
      body: Consumer<StockViewModel>(
        builder: (context, vm, child) {
          if (vm.isSearching) {
            return const Center(child: CircularProgressIndicator());
          }

          // Kondisi untuk menampilkan pesan minimal 2 huruf
          if (_searchController.text.isEmpty ||
              _searchController.text.length < 2) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Masukkan minimal 2 huruf untuk mulai mencari simbol atau nama perusahaan (misal: "AP" atau "Tesla").',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }

          // Kondisi untuk menampilkan jika hasil kosong setelah pencarian > 2 huruf
          if (vm.searchResults.isEmpty) {
            return const Center(
              child: Text(
                '❌ Tidak ditemukan hasil yang cocok.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          }

          // Tampilkan hasil pencarian
          return ListView.builder(
            itemCount: vm.searchResults.length,
            itemBuilder: (context, index) {
              final result = vm.searchResults[index];
              return _buildSearchResultTile(context, vm, result);
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchResultTile(
    BuildContext context,
    StockViewModel vm,
    CompanySearchResult result,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            result.symbol.substring(0, 1),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          result.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Simbol: ${result.symbol}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          // 1. Set simbol baru dan mulai fetching data
          vm.fetchStockHistory(result.symbol);
          // 2. Bersihkan hasil pencarian agar layar Search bersih saat dibuka lagi
          vm.clearSearch();
          // 3. Kembali ke layar sebelumnya (biasanya HomeScreen)
          Navigator.pop(context);
        },
      ),
    );
  }
}
