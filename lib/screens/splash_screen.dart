import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      final user = FirebaseAuth.instance.currentUser;
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          user != null ? '/home' : '/login',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF185FA5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_rounded, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text('ShipTrack',
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8),
            Text('Your shipments, tracked.',
                style: TextStyle(fontSize: 14, color: Color(0xFFB5D4F4))),
          ],
        ),
      ),
    );
  }
}