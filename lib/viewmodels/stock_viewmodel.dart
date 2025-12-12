import 'package:flutter/material.dart';
import '../models/stock_data.dart';
import '../models/search_data.dart';
import '../services/api_service.dart';

// Enum untuk 3. Asynchronous UI: Loading, Success, Error State
enum ViewState { initial, loading, loaded, error }

// Arsitektur: State Management (Provider/ViewModel)
class StockViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String _currentSymbol = 'AAPL';
  ViewState _state = ViewState.initial;
  List<StockData> _stockHistory = [];
  String _errorMessage = '';
  List<CompanySearchResult> _searchResults = [];

  // PERBAIKAN: Tambahkan state untuk indikator loading pencarian
  bool _isSearching = false;

  ApiService get apiService => _apiService;

  String get currentSymbol => _currentSymbol;
  ViewState get state => _state;
  List<StockData> get stockHistory => _stockHistory;
  String get errorMessage => _errorMessage;
  List<CompanySearchResult> get searchResults => _searchResults;

  // PERBAIKAN: Getter untuk state loading pencarian
  bool get isSearching => _isSearching;

  // Business Logic untuk mengambil data (Tidak Diubah)
  Future<void> fetchStockHistory(String symbol) async {
    if (_state == ViewState.loading && symbol == _currentSymbol)
      return; // Hindari double fetch

    _currentSymbol = symbol;
    _state = ViewState.loading;
    _stockHistory = [];
    notifyListeners(); // Tampilkan Loading State

    try {
      final data = await _apiService.fetchStockData(symbol);

      // Data npoint.io sudah urut, kita hanya ambil 30 hari terakhir (jika ada)
      _stockHistory = data.length > 30 ? data.sublist(data.length - 30) : data;

      _state = ViewState.loaded; // Success State
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = ViewState.error; // Error State
    } finally {
      notifyListeners(); // Perbarui UI
    }
  }

  // Business Logic untuk Fitur Pencarian (Diperbaiki)
  Future<void> searchStocks(String query) async {
    if (query.length < 2) {
      _searchResults = [];
      // Reset state jika query terlalu pendek
      _isSearching = false;
      notifyListeners();
      return;
    }

    // MULAI LOADING PENCARIAN
    _isSearching = true;
    notifyListeners();

    try {
      final results = await _apiService.searchCompany(query);
      _searchResults = results;
    } catch (e) {
      _searchResults = [];
      print('Search Error: $e'); // Log error untuk debugging
    } finally {
      // SELESAI LOADING PENCARIAN
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    // Reset isSearching juga saat clear
    _isSearching = false;
    notifyListeners();
  }
}
