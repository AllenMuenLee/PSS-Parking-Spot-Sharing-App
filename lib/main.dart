import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'services/background_service.dart';
import 'ui/dashboard_screen.dart';
import 'state/locale_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Background Services
  await initializeBackgroundService();
  
  runApp(const ProviderScope(child: StreetParkingApp()));
}

class StreetParkingApp extends ConsumerWidget {
  const StreetParkingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Street Parking App',
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('zh', ''), // Traditional Chinese
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
