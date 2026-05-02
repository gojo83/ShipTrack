import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AuthProvider>();
    final error = await provider.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red.shade700),
      );
    } else {
      final isAdmin = context.read<AuthProvider>().isAdmin;
      Navigator.pushReplacementNamed(context, isAdmin ? '/admin' : '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Icon(Icons.local_shipping_rounded,
                    size: 48, color: AppColors.primaryBlue),
                const SizedBox(height: 16),
                const Text('Welcome back',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Sign in to continue',
                    style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                const SizedBox(height: 36),
                CustomTextField(
                  label: 'Email address',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                  v!.isEmpty ? 'Enter your email' : null,
                ),
                CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passCtrl,
                  obscureText: _obscure,
                  validator: (v) =>
                  v!.length < 6 ? 'Min 6 characters' : null,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 8),
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                    onPressed: _login, child: const Text('Log In')),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Sign up',
                          style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}