import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/shipment_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

class TrackingScreen extends StatelessWidget {
  final String trackingId;
  const TrackingScreen({super.key, required this.trackingId});

  final List<String> _allStatuses = const [
    'Order Placed',
    'Package Picked Up',
    'In Transit',
    'Out for Delivery',
    'Delivered',
  ];

  int _statusIndex(String status) => _allStatuses.indexOf(status);

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Track Shipment')),
      body: StreamBuilder<ShipmentModel?>(
        stream: service.trackShipment(trackingId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final shipment = snap.data;
          if (shipment == null) {
            return const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.search_off, size: 56, color: AppColors.textSecondary),
                SizedBox(height: 12),
                Text('Shipment not found',
                    style: TextStyle(color: AppColors.textSecondary)),
              ]),
            );
          }

          final currentIndex = _statusIndex(shipment.status);
          final hasCoords = shipment.senderLat != null && shipment.receiverLat != null;
          final senderPoint = hasCoords
              ? LatLng(shipment.senderLat!, shipment.senderLng!)
              : null;
          final receiverPoint = hasCoords
              ? LatLng(shipment.receiverLat!, shipment.receiverLng!)
              : null;

          // Center map between the two points
          final mapCenter = hasCoords
              ? LatLng(
            (shipment.senderLat! + shipment.receiverLat!) / 2,
            (shipment.senderLng! + shipment.receiverLng!) / 2,
          )
              : const LatLng(23.8103, 90.4125);

          return SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Info card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(shipment.trackingId,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    _statusBadge(shipment.status),
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
                  if (shipment.estimatedDelivery.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3DE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        const Icon(Icons.schedule, size: 14, color: AppColors.green),
                        const SizedBox(width: 6),
                        Text('ETA: ${shipment.estimatedDelivery}',
                            style: const TextStyle(fontSize: 12,
                                color: AppColors.green, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ],
                ]),
              ),

              // Status stepper
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Delivery Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              ...List.generate(_allStatuses.length, (i) {
                final isDone = i <= currentIndex;
                final isCurrent = i == currentIndex;
                final isLast = i == _allStatuses.length - 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Column(children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? AppColors.primaryBlue : Colors.transparent,
                          border: Border.all(
                            color: isDone ? AppColors.primaryBlue : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: isDone
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 2, height: 40,
                          color: isDone && i < currentIndex
                              ? AppColors.primaryBlue
                              : Colors.grey.shade200,
                        ),
                    ]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_allStatuses[i],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
                              )),
                          if (isCurrent)
                            const Text('Current status',
                                style: TextStyle(fontSize: 12, color: AppColors.primaryBlue)),
                          SizedBox(height: isLast ? 0 : 28),
                        ]),
                      ),
                    ),
                  ]),
                );
              }),

              // Map
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Delivery Route',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: hasCoords
                      ? FlutterMap(
                    options: MapOptions(
                      initialCenter: mapCenter,
                      initialZoom: _calculateZoom(senderPoint!, receiverPoint!),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.proj.shiptrack',
                      ),
                      PolylineLayer(polylines: [
                        Polyline(
                          points: [senderPoint, receiverPoint],
                          strokeWidth: 3.5,
                          color: AppColors.primaryBlue,
                        ),
                      ]),
                      MarkerLayer(markers: [
                        Marker(
                          point: senderPoint,
                          width: 40, height: 40,
                          child: const Icon(Icons.location_on,
                              color: AppColors.primaryBlue, size: 36),
                        ),
                        Marker(
                          point: receiverPoint,
                          width: 40, height: 40,
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 36),
                        ),
                      ]),
                    ],
                  )
                      : const Center(
                    child: Text('Map not available',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              ),

              if (hasCoords)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(children: [
                    const Icon(Icons.location_on, color: AppColors.primaryBlue, size: 16),
                    const SizedBox(width: 4),
                    const Text('Pickup', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    const Text('Delivery', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                ),

              const SizedBox(height: 32),
            ]),
          );
        },
      ),
    );
  }

  double _calculateZoom(LatLng a, LatLng b) {
    final dist = const Distance().as(LengthUnit.Kilometer, a, b);
    if (dist < 5) return 13;
    if (dist < 20) return 11;
    if (dist < 100) return 9;
    if (dist < 300) return 7;
    return 6;
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
      child: Text(status,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}