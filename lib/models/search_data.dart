class CompanySearchResult {
  final String symbol;
  final String name;

  CompanySearchResult({required this.symbol, required this.name});

  factory CompanySearchResult.fromJson(Map<String, dynamic> json) {
    return CompanySearchResult(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
    );
  }
}
