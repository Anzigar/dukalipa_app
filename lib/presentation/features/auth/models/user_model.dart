class UserModel {
  final String id;
  final String name;
  final String email;
  final String shopName;
  final String? phoneNumber;
  final String? profileImage;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.shopName,
    this.phoneNumber,
    this.profileImage,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      shopName: json['shop_name'],
      phoneNumber: json['phone_number'],
      profileImage: json['profile_image'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'shop_name': shopName,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
    };
  }
  
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? shopName,
    String? phoneNumber,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      shopName: shopName ?? this.shopName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
