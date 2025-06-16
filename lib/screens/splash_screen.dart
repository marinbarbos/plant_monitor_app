import 'dart:async';
import 'package:flutter/material.dart';
import 'ip_entry_screen.dart'; // Will be created

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const IPInputPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF66FF99), // Match the green from image
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'MICRO GARDEN',
              style: TextStyle(
                fontSize: 28,
                letterSpacing: 6,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'The microgreen companion app',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/sprout.png', // <-- Add this image to assets
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
