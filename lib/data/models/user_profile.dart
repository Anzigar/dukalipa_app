class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? shopName;
  final String? shopAddress;
  final String? shopPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.shopName,
    this.shopAddress,
    this.shopPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      shopPhone: shopPhone ?? this.shopPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'shopName': shopName,
      'shopAddress': shopAddress,
      'shopPhone': shopPhone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      shopName: json['shopName'],
      shopAddress: json['shopAddress'],
      shopPhone: json['shopPhone'],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }
  
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return DateTime.now();
    }
  }
}
