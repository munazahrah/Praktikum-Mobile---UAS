import 'package:flutter/material.dart';
import 'portfolio_screen.dart';
import 'stock_list_screen.dart';
import 'prediction_screen.dart';
import 'user_profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Daftar Screen yang akan ditampilkan di BottomNavBar
  final List<Widget> _screens = [
    const PortfolioScreen(),
    const StockListScreen(),
    const PredictionScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar menyesuaikan berdasarkan Tab
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'S-PARK'
              : _selectedIndex == 1
              ? 'Daftar Kategori Saham'
              : 'Prediksi Saham GRU',
        ),
        actions: [
          // Tombol Search (Placeholder)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigasi ke SearchScreen (jika ada)
            },
          ),
          // Tombol Profile untuk menuju UserProfileScreen
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Daftar Saham',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Prediksi',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
