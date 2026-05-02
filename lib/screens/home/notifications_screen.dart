import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().firebaseUser?.uid ?? '';
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder(
        stream: service.getUserNotifications(uid),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.notifications_off_outlined, size: 56, color: AppColors.textSecondary),
                SizedBox(height: 12),
                Text('No notifications yet',
                    style: TextStyle(color: AppColors.textSecondary)),
              ]),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final status = data['status'] ?? '';
              final trackingId = data['trackingId'] ?? '';
              final eta = data['estimatedDelivery'] ?? '';
              final role = data['role'] ?? 'sender';

              Color dotColor;
              String message;
              switch (status) {
                case 'Delivered':
                  dotColor = AppColors.green;
                  message = '📦 $trackingId has been delivered!';
                  break;
                case 'Out for Delivery':
                  dotColor = AppColors.amber;
                  message = '🚚 $trackingId is out for delivery';
                  break;
                case 'In Transit':
                  dotColor = AppColors.amber;
                  message = '🚛 $trackingId is now in transit';
                  break;
                case 'Package Picked Up':
                  dotColor = AppColors.primaryBlue;
                  message = '📬 $trackingId has been picked up';
                  break;
                default:
                  dotColor = AppColors.textSecondary;
                  message = '✅ $trackingId — Order placed successfully';
              }

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.grey.shade100,
                      blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 10, height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(message,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    if (eta.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('ETA: $eta',
                          style: const TextStyle(fontSize: 12, color: AppColors.green,
                              fontWeight: FontWeight.w500)),
                    ],
                    const SizedBox(height: 4),
                    Text(role == 'receiver' ? 'You are receiving this package' : 'You sent this package',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(data['createdAt']?.toString().substring(0, 10) ?? '',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ])),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}