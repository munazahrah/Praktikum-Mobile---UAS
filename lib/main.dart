import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/stock_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'screens/auth_wrapper.dart';

void main() {
  runApp(const SPARKApp());
}

class SPARKApp extends StatelessWidget {
  const SPARKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'S-PARK',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B5E20),
            foregroundColor: Colors.white,
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.green,
          ).copyWith(secondary: Colors.amber),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
