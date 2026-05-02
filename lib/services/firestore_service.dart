import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shipment_model.dart';
import '../models/user_model.dart';

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

  // Look up receiver by email AND phone
  Future<UserModel?> findReceiver(String email, String phone) async {
    final snap = await _db
        .collection('users')
        .where('email', isEqualTo: email.trim())
        .where('phone', isEqualTo: phone.trim())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return UserModel.fromMap(snap.docs.first.data());
  }

  Future<ShipmentModel> createShipment({
    required String userId,
    required String receiverUserId,
    required String receiverEmail,
    required String receiverPhone,
    required String senderAddress,
    required String receiverAddress,
    required double weight,
    required String packageType,
    required String deliveryType,
    required String estimatedDelivery,
    double? senderLat,
    double? senderLng,
    double? receiverLat,
    double? receiverLng,
  }) async {
    final trackingId = _generateTrackingId();
    final cost = calculateCost(weight, deliveryType);
    final ref = _db.collection('shipments').doc();
    final shipment = ShipmentModel(
      id: ref.id,
      userId: userId,
      receiverUserId: receiverUserId,
      receiverEmail: receiverEmail,
      receiverPhone: receiverPhone,
      trackingId: trackingId,
      senderAddress: senderAddress,
      receiverAddress: receiverAddress,
      weight: weight,
      packageType: packageType,
      deliveryType: deliveryType,
      estimatedCost: cost,
      status: 'Order Placed',
      estimatedDelivery: estimatedDelivery,
      senderLat: senderLat,
      senderLng: senderLng,
      receiverLat: receiverLat,
      receiverLng: receiverLng,
      createdAt: DateTime.now(),
    );
    await ref.set(shipment.toMap());
    return shipment;
  }

  // Sender's shipments
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

  // Receiver's shipments
  Stream<List<ShipmentModel>> getReceivedShipments(String userId) {
    return _db
        .collection('shipments')
        .where('receiverUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ShipmentModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  // Track by tracking ID — works for anyone
  Stream<ShipmentModel?> trackShipment(String trackingId) {
    return _db
        .collection('shipments')
        .where('trackingId', isEqualTo: trackingId)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return ShipmentModel.fromMap(doc.id, doc.data());
    });
  }

  // Admin — get ALL shipments
  Stream<List<ShipmentModel>> getAllShipments() {
    return _db
        .collection('shipments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ShipmentModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  // Admin — update status + create notification
  Future<void> updateShipmentStatus(
      String shipmentId,
      String status,
      String senderUserId,
      String receiverUserId,
      String trackingId,
      String estimatedDelivery,
      ) async {
    await _db.collection('shipments').doc(shipmentId).update({
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Create notification for sender
    await _createNotification(
      userId: senderUserId,
      trackingId: trackingId,
      status: status,
      estimatedDelivery: estimatedDelivery,
      role: 'sender',
    );

    // Create notification for receiver
    if (receiverUserId.isNotEmpty) {
      await _createNotification(
        userId: receiverUserId,
        trackingId: trackingId,
        status: status,
        estimatedDelivery: estimatedDelivery,
        role: 'receiver',
      );
    }
  }

  Future<void> _createNotification({
    required String userId,
    required String trackingId,
    required String status,
    required String estimatedDelivery,
    required String role,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'trackingId': trackingId,
      'status': status,
      'estimatedDelivery': estimatedDelivery,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
      'read': false,
    });
  }

  // Get notifications for a user
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Check if user is admin
  Future<bool> isAdmin(String uid) async {
    final doc = await _db.collection('admins').doc(uid).get();
    return doc.exists;
  }
}