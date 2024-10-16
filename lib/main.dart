import 'package:cosmos_test/app/screens/home_screen.dart';
import 'package:cosmos_test/app/screens/login_screen.dart';
import 'package:cosmos_test/app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final Dio dio;

  MyApp({required this.isLoggedIn})
      : dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.0.103:8000/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmos Test',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn ? HomeScreen(dio: dio) : LoginScreen(dio: dio),
      routes: {
        '/signup': (context) => SignupScreen(dio: dio),
        '/home': (context) => HomeScreen(dio: dio),
        '/login': (context) => LoginScreen(dio: dio),
      },
    );
  }
}