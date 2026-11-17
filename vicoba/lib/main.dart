import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vicoba/core/dependency_injection.dart';
import 'package:vicoba/firebase_options.dart';
import 'package:vicoba/presentation/pages/splash_page.dart';
import 'package:vicoba/presentation/pages/onboarding_page.dart';
import 'package:vicoba/presentation/pages/welcome_page.dart';
import 'package:vicoba/presentation/pages/login_page.dart';
import 'package:vicoba/presentation/pages/signup_page.dart';
import 'package:vicoba/presentation/pages/admin/admin_dashboard_page.dart';
import 'package:vicoba/presentation/pages/users/member_dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependency injection
  DependencyInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vicoba',
      home: const SplashPage(),
      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(name: '/onboarding', page: () => const OnboardingPage()),
        GetPage(name: '/welcome', page: () => const WelcomePage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/signup', page: () => const SignupPage()),
        GetPage(name: '/admin-dashboard', page: () => AdminDashboard()),
        GetPage(name: '/member-dashboard', page: () => const DashboardScreen()),
      ],
    );
  }
}
