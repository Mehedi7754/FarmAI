import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/news_provider.dart';
import 'providers/symptoms_analysis_provider.dart';
import 'providers/weather_provider.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/weather_service.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    try {
      final storageService = StorageService();
      final weatherService = WeatherService();
      final notificationService = NotificationService();

      await notificationService.initBackground();

      final location = await storageService.getFarmLocation();
      if (location == null) {
        print('No farm location set');
        return Future.value(true);
      }

      final weather =
          await weatherService.fetchWeather(location['lat'], location['lon']);
      if (weather == null) {
        print('Weather fetch failed');
        return Future.value(true);
      }

      if (weather.daily.length <= 1) {
        print('Not enough daily data');
        return Future.value(true);
      }

      final tomorrow = weather.daily[1];

      String? alertTitle;
      String? alertBody;

      if (tomorrow.maxTemp >= 35) {
        alertTitle = 'বেশি গরম সতর্কতা';
        alertBody = 'আগামীকাল তাপমাত্রা বেশি হতে পারে। পানি ও ছায়ার ব্যবস্থা করুন।';
      } else if (tomorrow.minTemp <= 15) {
        alertTitle = 'বেশি ঠান্ডা সতর্কতা';
        alertBody = 'আগামীকাল ঠান্ডা বেশি হতে পারে। পশুদের উষ্ণ রাখুন।';
      } else if (tomorrow.precipProb >= 60) {
        alertTitle = 'বৃষ্টি সতর্কতা';
        alertBody = 'আগামীকাল বৃষ্টির সম্ভাবনা বেশি। প্রস্তুতি নিন।';
      }

      if (alertTitle != null) {
        await notificationService.showNotification(
          id: 1,
          title: alertTitle,
          body: alertBody!,
        );
      }

      return Future.value(true);
    } catch (e, st) {
      print('Workmanager task failed: $e');
      print(st);
      return Future.value(false);
    }
  });
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await NotificationService().init();
  
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  //notification debug ar jonno deya hoyeche
  Workmanager().registerOneOffTask(
  "weather_alert_test",
  "weatherAlertTask",
  initialDelay: const Duration(seconds: 15),
);
  
  Workmanager().registerPeriodicTask(
    "weather_alert_task",
    "weatherAlertTask",
    frequency: const Duration(hours: 24),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => SymptomsAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()..loadFarmLocation()),
      ],
      child: const FarmAIApp(),
    ),
  );
}

class FarmAIApp extends StatelessWidget {
  const FarmAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade700,
          secondary: Colors.amber.shade700,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the authentication state
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
