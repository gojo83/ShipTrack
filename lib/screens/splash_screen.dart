import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    final isAdmin = await FirestoreService().isAdmin(user.uid);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, isAdmin ? '/admin' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF185FA5),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.local_shipping_rounded, size: 72, color: Colors.white),
          SizedBox(height: 16),
          Text('ShipTrack',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          Text('Your shipments, tracked.',
              style: TextStyle(fontSize: 14, color: Color(0xFFB5D4F4))),
        ]),
      ),
    );
  }
}