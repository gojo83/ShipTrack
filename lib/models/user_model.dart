class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phone': phone,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'],
    name: map['name'],
    email: map['email'],
    phone: map['phone'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}