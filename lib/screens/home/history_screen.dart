import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/shipment_model.dart';
import '../../utils/constants.dart';

class HistoryScreen extends StatelessWidget {
  final String userId;
  const HistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Shipment History')),
      body: StreamBuilder<List<ShipmentModel>>(
        stream: service.getUserShipments(userId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final shipments = snap.data ?? [];
          if (shipments.isEmpty) {
            return const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.history, size: 64, color: AppColors.textSecondary),
                SizedBox(height: 12),
                Text('No shipments yet', style: TextStyle(color: AppColors.textSecondary)),
              ]),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: shipments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ShipmentCard(shipment: shipments[i]),
          );
        },
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final ShipmentModel shipment;
  const _ShipmentCard({required this.shipment});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color textColor;
    switch (shipment.status) {
      case 'Delivered': badgeColor = AppColors.lightGreen; textColor = AppColors.green; break;
      case 'In Transit': badgeColor = AppColors.lightAmber; textColor = AppColors.amber; break;
      default: badgeColor = AppColors.lightBlue; textColor = AppColors.primaryBlue;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(shipment.trackingId,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
            child: Text(shipment.status,
                style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.circle, size: 8, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(child: Text(shipment.senderAddress,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.location_on, size: 8, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Expanded(child: Text(shipment.receiverAddress,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${shipment.packageType} · ${shipment.weight}kg',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('৳ ${shipment.estimatedCost.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
      ]),
    );
  }
}