import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shipment_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _service = FirestoreService();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<String> _allStatuses = [
    'Order Placed',
    'Package Picked Up',
    'In Transit',
    'Out for Delivery',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(children: [
        // Search bar
        Container(
          color: AppColors.primaryBlue,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by tracking ID…',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (v) => setState(() => _searchQuery = v.trim().toUpperCase()),
          ),
        ),

        // Shipments list
        Expanded(
          child: StreamBuilder<List<ShipmentModel>>(
            stream: _service.getAllShipments(),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              var shipments = snap.data!;
              if (_searchQuery.isNotEmpty) {
                shipments = shipments
                    .where((s) => s.trackingId.toUpperCase().contains(_searchQuery))
                    .toList();
              }
              if (shipments.isEmpty) {
                return const Center(
                  child: Text('No shipments found', style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: shipments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _AdminShipmentCard(
                  shipment: shipments[i],
                  allStatuses: _allStatuses,
                  service: _service,
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _AdminShipmentCard extends StatelessWidget {
  final ShipmentModel shipment;
  final List<String> allStatuses;
  final FirestoreService service;

  const _AdminShipmentCard({
    required this.shipment,
    required this.allStatuses,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(shipment.trackingId,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          _statusBadge(shipment.status),
        ]),
        const SizedBox(height: 6),
        Text('From: ${shipment.senderAddress}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text('To: ${shipment.receiverAddress}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text('Receiver: ${shipment.receiverEmail}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text('${shipment.packageType} · ${shipment.weight}kg · ৳${shipment.estimatedCost.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 10),

        // Status updater
        const Text('Update Status:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: allStatuses.map((s) {
            final isCurrent = shipment.status == s;
            return GestureDetector(
              onTap: isCurrent ? null : () => _confirmUpdate(context, s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.primaryBlue : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCurrent ? AppColors.primaryBlue : Colors.grey.shade300,
                  ),
                ),
                child: Text(s,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isCurrent ? Colors.white : AppColors.textSecondary,
                    )),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  void _confirmUpdate(BuildContext context, String newStatus) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Status'),
        content: Text('Change status of ${shipment.trackingId} to "$newStatus"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await service.updateShipmentStatus(
                shipment.id,
                newStatus,
                shipment.userId,
                shipment.receiverUserId,
                shipment.trackingId,
                shipment.estimatedDelivery,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Status updated to $newStatus'),
                      backgroundColor: AppColors.green),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg; Color fg;
    switch (status) {
      case 'Delivered': bg = const Color(0xFFEAF3DE); fg = AppColors.green; break;
      case 'In Transit': bg = AppColors.lightAmber; fg = AppColors.amber; break;
      case 'Out for Delivery': bg = AppColors.lightAmber; fg = AppColors.amber; break;
      default: bg = AppColors.lightBlue; fg = AppColors.primaryBlue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}