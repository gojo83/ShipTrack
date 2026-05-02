class ShipmentModel {
  final String id;
  final String userId;         // sender's uid
  final String receiverUserId; // receiver's uid
  final String receiverEmail;
  final String receiverPhone;
  final String trackingId;
  final String senderAddress;
  final String receiverAddress;
  final double weight;
  final String packageType;
  final String deliveryType;
  final double estimatedCost;
  final String status;
  final String estimatedDelivery;
  final double? senderLat;
  final double? senderLng;
  final double? receiverLat;
  final double? receiverLng;
  final DateTime createdAt;

  ShipmentModel({
    required this.id,
    required this.userId,
    required this.receiverUserId,
    required this.receiverEmail,
    required this.receiverPhone,
    required this.trackingId,
    required this.senderAddress,
    required this.receiverAddress,
    required this.weight,
    required this.packageType,
    required this.deliveryType,
    required this.estimatedCost,
    required this.status,
    required this.estimatedDelivery,
    this.senderLat,
    this.senderLng,
    this.receiverLat,
    this.receiverLng,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'receiverUserId': receiverUserId,
    'receiverEmail': receiverEmail,
    'receiverPhone': receiverPhone,
    'trackingId': trackingId,
    'senderAddress': senderAddress,
    'receiverAddress': receiverAddress,
    'weight': weight,
    'packageType': packageType,
    'deliveryType': deliveryType,
    'estimatedCost': estimatedCost,
    'status': status,
    'estimatedDelivery': estimatedDelivery,
    'senderLat': senderLat,
    'senderLng': senderLng,
    'receiverLat': receiverLat,
    'receiverLng': receiverLng,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ShipmentModel.fromMap(String id, Map<String, dynamic> map) => ShipmentModel(
    id: id,
    userId: map['userId'] ?? '',
    receiverUserId: map['receiverUserId'] ?? '',
    receiverEmail: map['receiverEmail'] ?? '',
    receiverPhone: map['receiverPhone'] ?? '',
    trackingId: map['trackingId'] ?? '',
    senderAddress: map['senderAddress'] ?? '',
    receiverAddress: map['receiverAddress'] ?? '',
    weight: (map['weight'] as num).toDouble(),
    packageType: map['packageType'] ?? '',
    deliveryType: map['deliveryType'] ?? '',
    estimatedCost: (map['estimatedCost'] as num).toDouble(),
    status: map['status'] ?? 'Order Placed',
    estimatedDelivery: map['estimatedDelivery'] ?? '',
    senderLat: map['senderLat'] != null ? (map['senderLat'] as num).toDouble() : null,
    senderLng: map['senderLng'] != null ? (map['senderLng'] as num).toDouble() : null,
    receiverLat: map['receiverLat'] != null ? (map['receiverLat'] as num).toDouble() : null,
    receiverLng: map['receiverLng'] != null ? (map['receiverLng'] as num).toDouble() : null,
    createdAt: DateTime.parse(map['createdAt']),
  );
}