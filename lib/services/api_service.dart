import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/stock_data.dart'; // Pastikan model ini tersedia (StockData, PredictionData, StockSummary)
import '../models/search_data.dart'; // Pastikan model ini tersedia

class ApiService {
  // URL Anda yang sudah teruji
  static const String _baseUrl = 'https://api.npoint.io/676f598b7ee38b8bc276';
  Map<String, dynamic>? _allStockDataCache;

  // FUNGSI HELPER DENGAN TIMEOUT DIPERPANJANG DAN RETRY
  Future<Map<String, dynamic>> _fetchStaticData() async {
    if (_allStockDataCache != null) {
      print('DEBUG: Menggunakan cache data');
      return _allStockDataCache!;
    }

    // Retry logic: coba 3 kali jika gagal
    int maxRetries = 3;
    int retryDelay = 2; // detik

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('DEBUG: Percobaan ke-$attempt - Request ke: $_baseUrl');

        final uri = Uri.parse(_baseUrl);

        // PENTING: Timeout diperpanjang menjadi 30 detik
        final response = await http
            .get(
              uri,
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw TimeoutException('Request timeout setelah 10 detik');
              },
            );

        print('DEBUG: Status Code: ${response.statusCode}');
        print('DEBUG: Response Body Length: ${response.body.length} bytes');

        if (response.statusCode == 200) {
          // Decode JSON
          final decodedData = json.decode(response.body);
          print(
            'DEBUG: Data berhasil di-decode. Type: ${decodedData.runtimeType}',
          );

          // V PERBAIKAN KRITIS UNTUK STRUKTUR JSON ANDA [ { ... } ] V
          if (decodedData is List && decodedData.isNotEmpty) {
            final rootMap = decodedData[0]; // Ambil Map di index 0

            if (rootMap is Map<String, dynamic>) {
              _allStockDataCache = rootMap;
              print('DEBUG: ✅ Cache berhasil disimpan');

              // Cetak jumlah saham yang tersedia
              if (rootMap.containsKey('data')) {
                final dataMap = rootMap['data'] as Map<String, dynamic>;
                print('DEBUG: 📊 Jumlah saham: ${dataMap.keys.length}');
                print('DEBUG: 📈 Simbol: ${dataMap.keys.join(', ')}');
              }

              return _allStockDataCache!;
            }
          }

          // Jika tidak lolos dari if di atas
          throw Exception(
            'Struktur JSON tidak sesuai: Expected List[Map] atau Map. Found ${decodedData.runtimeType}',
          );
        } else if (response.statusCode >= 500) {
          // Server error, coba retry
          throw Exception('Server error: ${response.statusCode}');
        } else {
          // Client error, jangan retry
          throw Exception(
            'HTTP Error ${response.statusCode}: ${response.reasonPhrase}',
          );
        }
      } on TimeoutException catch (e) {
        print('⚠️ TIMEOUT pada percobaan $attempt: $e');
        if (attempt < maxRetries) {
          print('🔄 Mencoba lagi dalam $retryDelay detik...');
          await Future.delayed(Duration(seconds: retryDelay));
          retryDelay *= 2; // Exponential backoff
          continue;
        }
        throw Exception(
          'Koneksi timeout setelah $maxRetries percobaan.\n'
          'Pastikan koneksi internet Anda stabil.\n'
          'Error: ${e.message}',
        );
      } on SocketException catch (e) {
        print('❌ SocketException pada percobaan $attempt: $e');
        if (attempt < maxRetries) {
          print('🔄 Mencoba lagi dalam $retryDelay detik...');
          await Future.delayed(Duration(seconds: retryDelay));
          retryDelay *= 2;
          continue;
        }
        throw Exception(
          'Tidak dapat terhubung ke server setelah $maxRetries percobaan.\n'
          '• Cek koneksi internet Anda\n'
          '• Pastikan tidak ada firewall yang memblokir\n'
          '• Coba restart aplikasi\n'
          'Error: ${e.message}',
        );
      } on FormatException catch (e) {
        print('❌ FormatException: $e');
        throw Exception('Format JSON tidak valid dari API: $e');
      } on http.ClientException catch (e) {
        print('❌ ClientException pada percobaan $attempt: $e');
        if (attempt < maxRetries) {
          print('🔄 Mencoba lagi dalam $retryDelay detik...');
          await Future.delayed(Duration(seconds: retryDelay));
          retryDelay *= 2;
          continue;
        }
        throw Exception(
          'Kesalahan HTTP Client setelah $maxRetries percobaan.\n'
          'Cek koneksi internet Anda.\n'
          'Error: $e',
        );
      } catch (e) {
        print('❌ Unknown error pada percobaan $attempt: $e');
        if (attempt < maxRetries) {
          print('🔄 Mencoba lagi dalam $retryDelay detik...');
          await Future.delayed(Duration(seconds: retryDelay));
          retryDelay *= 2;
          continue;
        }
        throw Exception('Kesalahan tidak terduga: $e');
      }
    }

    // Seharusnya tidak pernah sampai sini
    throw Exception('Gagal memuat data setelah $maxRetries percobaan');
  }

  // Test koneksi internet
  Future<bool> testConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('DEBUG: ✅ Koneksi internet OK');
        return true;
      }
    } on SocketException catch (_) {
      print('DEBUG: ❌ Tidak ada koneksi internet');
      return false;
    } catch (e) {
      print('DEBUG: ❌ Error saat test koneksi: $e');
      return false;
    }
    return false;
  }

  // FUNGSI AMBIL DATA PREDIKSI
  // PERBAIKAN 1: Mengubah return type menjadi Future<List<PredictionData>>
  Future<List<PredictionData>> fetchPredictionData(String symbol) async {
    final allData = await _fetchStaticData();
    final upperSymbol = symbol.toUpperCase();

    if (allData.containsKey('data') &&
        allData['data'].containsKey(upperSymbol)) {
      final Map<String, dynamic> symbolData = allData['data'][upperSymbol];

      if (symbolData.containsKey('prediction_data')) {
        final List<dynamic> predictionData = symbolData['prediction_data'];
        print(
          'DEBUG: ✅ Found ${predictionData.length} prediction records for $upperSymbol',
        );
        // PERBAIKAN: Mapping data List<dynamic> ke List<PredictionData>
        return predictionData
            .map((json) => PredictionData.fromJson(json))
            .toList();
      }
    }

    throw Exception('Tidak ada data prediksi untuk simbol $symbol.');
  }

  // FUNGSI AMBIL DATA HISTORIS (Tidak ada perubahan)
  Future<List<StockData>> fetchStockData(String symbol) async {
    final allData = await _fetchStaticData();
    final upperSymbol = symbol.toUpperCase();

    if (allData.containsKey('data')) {
      final Map<String, dynamic> dataMap = allData['data'];

      print('DEBUG: 🔍 Simbol tersedia: ${dataMap.keys.join(', ')}');
      print('DEBUG: 🎯 Mencari: $upperSymbol');

      if (dataMap.containsKey(upperSymbol)) {
        final Map<String, dynamic> symbolData = dataMap[upperSymbol];

        if (symbolData.containsKey('historical')) {
          final List<dynamic> historicalData = symbolData['historical'];
          print(
            'DEBUG: ✅ Found ${historicalData.length} historical records for $upperSymbol',
          );

          return historicalData
              .map((json) => StockData.fromJson(json))
              .toList();
        }
      }
    }

    throw Exception(
      'Tidak ada data historis untuk simbol $symbol.\n'
      'Simbol yang tersedia: ${allData.containsKey('data') ? (allData['data'] as Map).keys.join(', ') : 'N/A'}',
    );
  }

  // FUNGSI AMBIL RINGKASAN SAHAM
  // PERBAIKAN 2: Mengubah return type menjadi Future<StockSummary>
  Future<StockSummary> fetchStockSummary(String symbol) async {
    final allData = await _fetchStaticData();
    final upperSymbol = symbol.toUpperCase();

    if (allData.containsKey('data') &&
        allData['data'].containsKey(upperSymbol)) {
      final Map<String, dynamic> symbolData = allData['data'][upperSymbol];

      if (symbolData.containsKey('historical')) {
        final List<dynamic> history = symbolData['historical'];

        if (history.isNotEmpty) {
          final latestData = history.last;
          print('DEBUG: ✅ Summary loaded for $upperSymbol');

          // PERBAIKAN: Mengembalikan objek StockSummary yang sudah diinisialisasi,
          // bukan hanya Map<String, dynamic> (dynamic)
          return StockSummary(
            symbol: upperSymbol,
            name: symbolData['company_name'] ?? upperSymbol,
            latestPrice: (latestData['close'] as num).toDouble(),
            latestVolume:
                latestData['volume'] as int? ?? 0, // Menggunakan null check
            description:
                symbolData['description'] ?? 'Deskripsi tidak tersedia.',
            marketCap: symbolData['market_cap'] ?? 'N/A',
          );
        }
      }
    }

    throw Exception('Gagal memuat ringkasan untuk $symbol.');
  }

  // FUNGSI PENCARIAN (Tidak ada perubahan)
  Future<List<CompanySearchResult>> searchCompany(String query) async {
    // Memastikan data dimuat (atau diambil dari cache)
    final allData = await _fetchStaticData();
    final List<CompanySearchResult> results = [];
    final lowerQuery = query.toLowerCase();

    // Logika Pemfilteran:
    if (allData.containsKey('search_results')) {
      final List<dynamic> searchResults = allData['search_results'];
      print('DEBUG: 🔍 Searching in ${searchResults.length} companies...');

      for (var json in searchResults) {
        final result = CompanySearchResult.fromJson(json);
        // KUNCI PERBAIKAN: Memeriksa apakah query cocok dengan simbol atau nama
        if (result.symbol.toLowerCase().contains(lowerQuery) ||
            result.name.toLowerCase().contains(lowerQuery)) {
          results.add(result);
        }
      }

      print('DEBUG: ✅ Found ${results.length} matches for "$query"');
    }

    return results;
  }

  // Clear cache jika perlu refresh
  void clearCache() {
    _allStockDataCache = null;
    print('DEBUG: 🗑️ Cache cleared');
  }

  // Get available symbols
  Future<List<String>> getAvailableSymbols() async {
    final allData = await _fetchStaticData();
    if (allData.containsKey('data')) {
      final dataMap = allData['data'] as Map<String, dynamic>;
      return dataMap.keys.toList();
    }
    return [];
  }
}
