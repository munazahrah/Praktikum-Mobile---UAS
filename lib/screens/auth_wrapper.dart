import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Tampilkan loading saat aplikasi mengecek status login awal
    if (authViewModel.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Memuat status login...'),
            ],
          ),
        ),
      );
    }

    // Jika sudah login, arahkan ke Main Navigation (Home)
    if (authViewModel.isLoggedIn) {
      return const MainNavigationScreen();
    }

    // Jika belum login, arahkan ke Login Screen
    return const LoginScreen();
  }
}
