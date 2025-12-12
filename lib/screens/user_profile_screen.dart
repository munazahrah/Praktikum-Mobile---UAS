import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            // Ikon atau Avatar Pengguna
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                user?.username[0].toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 40, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            // Nama Pengguna
            Text(
              user?.username ?? 'Pengguna Tidak Dikenal',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Email Pengguna
            Text(
              user?.email ?? 'Tidak ada email',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const Divider(height: 40),
            // Kartu Detail Akun
            _buildProfileInfoCard(
              icon: Icons.person_outline,
              title: 'Username',
              subtitle: user?.username ?? 'N/A',
            ),
            _buildProfileInfoCard(
              icon: Icons.alternate_email,
              title: 'Email Akun',
              subtitle: user?.email ?? 'N/A',
            ),
            const SizedBox(height: 40),
            // Tombol Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Konfirmasi sebelum logout
                  _showLogoutConfirmation(context, authViewModel.logout);
                },
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Metode pembantu: _buildProfileInfoCard dan _showLogoutConfirmation
  Widget _buildProfileInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, VoidCallback onLogout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Tutup dialog
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              onLogout(); // Jalankan fungsi logout (Ini memicu perubahan status di AuthViewModel)
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
