import 'package:flutter/material.dart';
import 'package:ridetracker/presentation/screens/splash_screen.dart';
import 'package:ridetracker/presentation/theme/app_colors.dart';

class RideTrackerApp extends StatelessWidget {
  const RideTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Ride Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
