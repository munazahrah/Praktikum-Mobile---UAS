import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'home_screen.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final username = authViewModel.currentUser?.username ?? '[Guest]';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Username (tanpa tombol logout)
          Text(
            'Halo, $username!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),

          const SizedBox(height: 8),
          const Text(
            'Selamat datang di S-PARK. Pantau investasi dan cek prediksi cepat model GRU.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Divider(height: 30),

          // Tampilan Informasi Utama (Menggunakan HomeScreen embedded)
          const Text(
            'Pantauan Saham Utama (AAPL)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          // Menggunakan HomeScreen dengan isEmbedded: true
          const SizedBox(
            height: 400, // Tinggi tetap agar grafik ditampilkan
            child: HomeScreen(isEmbedded: true),
          ),

          const SizedBox(height: 20),
          const Text(
            'Status Prediksi GRU',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.blue),
            title: Text('Model GRU Aktif dan Siap Digunakan'),
            subtitle: Text('Gunakan tab Prediksi untuk menjalankan analisis.'),
          ),
        ],
      ),
    );
  }
}
