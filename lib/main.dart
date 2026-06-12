import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/background_service.dart';
import 'ui/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Requires google-services.json setup)
  // await Firebase.initializeApp();
  
  // Initialize Background Services
  await initializeBackgroundService();
  
  runApp(const ProviderScope(child: StreetParkingApp()));
}

class StreetParkingApp extends StatelessWidget {
  const StreetParkingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Street Parking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Incorporating some modern aesthetics based on user global rules
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF1D1D1F)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFF5F5F7)),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}
