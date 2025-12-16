import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import localizations
import 'package:intl/date_symbol_data_local.dart'; // Import date symbol data

import 'firebase_options.dart';
import 'providers/trips_provider.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // 1. Обов'язкова прив'язка до нативного коду
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Ukrainian
  await initializeDateFormatting('uk', null);

  // 2. Ініціалізація Firebase (ЦЕ МАЄ БУТИ ТУТ, ЗОВНІ)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Налаштування Crashlytics для синхронних помилок
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // 4. Запуск додатку в зоні (для асинхронних помилок)
  runZonedGuarded<Future<void>>(
    () async {
      runApp(
        MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => TripsProvider())],
          child: const TravelDairyApp(),
        ),
      );
    },
    // Цей блок спрацює при помилці. Оскільки Firebase вже ініціалізовано вище (крок 2),
    // виклик instance не впаде з помилкою.
    (error, stack) =>
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
  );
}

class TravelDairyApp extends StatelessWidget {
  const TravelDairyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A56DB);

    return MaterialApp(
      title: 'Travel Dairy',
      debugShowCheckedModeBanner: false,
      // Localization setup
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('uk', 'UA'), // Ukrainian
      ],
      locale: const Locale('uk', 'UA'), // Force Ukrainian
      
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        primaryColor: primaryBlue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7F7F7),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
