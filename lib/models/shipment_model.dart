class ShipmentModel {
  final String id;
  final String userId;
  final String trackingId;
  final String senderAddress;
  final String receiverAddress;
  final double weight;
  final String packageType;
  final String deliveryType;
  final double estimatedCost;
  final String status;
  final DateTime createdAt;

  ShipmentModel({
    required this.id,
    required this.userId,
    required this.trackingId,
    required this.senderAddress,
    required this.receiverAddress,
    required this.weight,
    required this.packageType,
    required this.deliveryType,
    required this.estimatedCost,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'trackingId': trackingId,
    'senderAddress': senderAddress,
    'receiverAddress': receiverAddress,
    'weight': weight,
    'packageType': packageType,
    'deliveryType': deliveryType,
    'estimatedCost': estimatedCost,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ShipmentModel.fromMap(String id, Map<String, dynamic> map) => ShipmentModel(
    id: id,
    userId: map['userId'],
    trackingId: map['trackingId'],
    senderAddress: map['senderAddress'],
    receiverAddress: map['receiverAddress'],
    weight: (map['weight'] as num).toDouble(),
    packageType: map['packageType'],
    deliveryType: map['deliveryType'],
    estimatedCost: (map['estimatedCost'] as num).toDouble(),
    status: map['status'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}