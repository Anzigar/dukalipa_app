class UserProfile {
  final String id;
  final String? name;
  final String email;
  final String? phone;
  final String? role;
  final String? shopName;
  final String? shopAddress;
  final String? shopPhone;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    this.name,
    required this.email,
    this.phone,
    this.role,
    this.shopName,
    this.shopAddress,
    this.shopPhone,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      shopName: json['shop_name'],
      shopAddress: json['shop_address'],
      shopPhone: json['shop_phone'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'shop_name': shopName,
      'shop_address': shopAddress,
      'shop_phone': shopPhone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      shopPhone: shopPhone ?? this.shopPhone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
