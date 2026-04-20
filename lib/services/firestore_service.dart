import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shipment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _generateTrackingId() {
    final now = DateTime.now();
    return 'SHP-${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  double calculateCost(double weight, String deliveryType) {
    final base = deliveryType == 'Express' ? 150.0 : 80.0;
    return base + (weight * 50);
  }

  Future<ShipmentModel> createShipment({
    required String userId,
    required String senderAddress,
    required String receiverAddress,
    required double weight,
    required String packageType,
    required String deliveryType,
  }) async {
    final trackingId = _generateTrackingId();
    final cost = calculateCost(weight, deliveryType);
    final ref = _db.collection('shipments').doc();
    final shipment = ShipmentModel(
      id: ref.id,
      userId: userId,
      trackingId: trackingId,
      senderAddress: senderAddress,
      receiverAddress: receiverAddress,
      weight: weight,
      packageType: packageType,
      deliveryType: deliveryType,
      estimatedCost: cost,
      status: 'Order Placed',
      createdAt: DateTime.now(),
    );
    await ref.set(shipment.toMap());
    return shipment;
  }

  Stream<List<ShipmentModel>> getUserShipments(String userId) {
    return _db
        .collection('shipments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ShipmentModel.fromMap(doc.id, doc.data()))
        .toList());
  }
}