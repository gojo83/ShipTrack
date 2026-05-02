import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(children: [
          // Avatar section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            color: AppColors.primaryBlue,
            child: Column(children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(user?.name ?? 'User',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(user?.email ?? '',
                  style: const TextStyle(fontSize: 13, color: Color(0xFFB5D4F4))),
            ]),
          ),

          const SizedBox(height: 24),

          // Info
          _sectionTitle('Account Info'),
          _infoTile('Full Name', user?.name ?? '—'),
          _infoTile('Email', user?.email ?? '—'),
          _infoTile('Phone', user?.phone ?? '—'),
          _infoTile('Member Since', user?.createdAt.toString().substring(0, 10) ?? '—'),

          const SizedBox(height: 24),

          // Settings
          _sectionTitle('Settings'),
          _actionTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            color: AppColors.primaryBlue,
            onTap: () {},
          ),
          _actionTile(
            icon: Icons.help_outline,
            label: 'Help & Support',
            color: AppColors.primaryBlue,
            onTap: () => Navigator.pushNamed(context, '/help'),
          ),

          const SizedBox(height: 8),

          // Sign out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    ),
  );

  Widget _infoTile(String label, String value) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _actionTile({required IconData icon, required String label, required Color color, required VoidCallback onTap}) =>
      Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
          onTap: onTap,
        ),
      );
}