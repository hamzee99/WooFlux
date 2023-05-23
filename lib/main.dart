import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluxstore/screens/login_screen.dart';
import 'package:fluxstore/screens/navigate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'models/cart_helper.dart';
import 'models/login_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Current directory: ${Directory.current.path}');
  print('File Exists: ${File('.env').existsSync()}');
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loginCheck = LoginCheck();
    final cartProvider = CartProvider();
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => cartProvider),
          ChangeNotifierProvider(create: (context) => loginCheck)
        ],
        child: MaterialApp(
            title: 'FluxStore',
            theme: ThemeData(
              textTheme: GoogleFonts.poppinsTextTheme(),
              primarySwatch: Colors.blue,
            ),
            debugShowCheckedModeBanner: false,
            home: const LoginScreen()));
  }
}
