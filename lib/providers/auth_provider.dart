import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _loading = false;

  UserModel? get userModel => _userModel;
  bool get loading => _loading;
  User? get firebaseUser => _authService.currentUser;

  void setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  Future<String?> register(String name, String email, String phone, String password) async {
    try {
      setLoading(true);
      _userModel = await _authService.registerUser(
        name: name, email: email, phone: phone, password: password,
      );
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      setLoading(false);
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      setLoading(true);
      await _authService.loginUser(email: email, password: password);
      _userModel = await _authService.getUserData(_authService.currentUser!.uid);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    notifyListeners();
  }
}