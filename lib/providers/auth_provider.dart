import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _userModel;
  bool _loading = false;
  bool _isAdmin = false;

  UserModel? get userModel => _userModel;
  bool get loading => _loading;
  bool get isAdmin => _isAdmin;
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
      _isAdmin = false;
      notifyListeners();
      return null;
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
      final uid = _authService.currentUser!.uid;
      _userModel = await _authService.getUserData(uid);
      _isAdmin = await _firestoreService.isAdmin(uid);
      notifyListeners();
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
    _isAdmin = false;
    notifyListeners();
  }
}