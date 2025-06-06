class ProfileModel {
  final String userId;
  final String name;
  final String email;
  final String shopName;
  final String? phoneNumber;
  final String? avatar;
  final ShopDetailsModel? shopDetails;
  final List<String>? roles;
  final DateTime createdAt;
  final DateTime? lastLogin;

  ProfileModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.shopName,
    this.phoneNumber,
    this.avatar,
    this.shopDetails,
    this.roles,
    required this.createdAt,
    this.lastLogin,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      shopName: json['shop_name'],
      phoneNumber: json['phone_number'],
      avatar: json['avatar'],
      shopDetails: json['shop_details'] != null 
          ? ShopDetailsModel.fromJson(json['shop_details']) 
          : null,
      roles: json['roles'] != null 
          ? List<String>.from(json['roles']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'shop_name': shopName,
      'phone_number': phoneNumber,
      'avatar': avatar,
      'shop_details': shopDetails?.toJson(),
      'roles': roles,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  // Get initials for avatar placeholder
  String get initials {
    if (name.isEmpty) return '';
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Check if user is an admin
  bool get isAdmin => roles?.contains('admin') ?? false;

  // Check if user can edit settings
  bool get canEdit => isAdmin;

  ProfileModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? shopName,
    String? phoneNumber,
    String? avatar,
    ShopDetailsModel? shopDetails,
    List<String>? roles,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      shopName: shopName ?? this.shopName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      shopDetails: shopDetails ?? this.shopDetails,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class ShopDetailsModel {
  final String? address;
  final String? city;
  final String? region;
  final String? country;
  final String? businessType;
  final String? taxId;
  final String? logo;
  final String? website;
  final BusinessHoursModel? businessHours;

  ShopDetailsModel({
    this.address,
    this.city,
    this.region,
    this.country,
    this.businessType,
    this.taxId,
    this.logo,
    this.website,
    this.businessHours,
  });

  factory ShopDetailsModel.fromJson(Map<String, dynamic> json) {
    return ShopDetailsModel(
      address: json['address'],
      city: json['city'],
      region: json['region'],
      country: json['country'],
      businessType: json['business_type'],
      taxId: json['tax_id'],
      logo: json['logo'],
      website: json['website'],
      businessHours: json['business_hours'] != null 
          ? BusinessHoursModel.fromJson(json['business_hours']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'region': region,
      'country': country,
      'business_type': businessType,
      'tax_id': taxId,
      'logo': logo,
      'website': website,
      'business_hours': businessHours?.toJson(),
    };
  }
}

class BusinessHoursModel {
  final Map<String, DayHoursModel> days;
  
  BusinessHoursModel({required this.days});
  
  factory BusinessHoursModel.fromJson(Map<String, dynamic> json) {
    final Map<String, DayHoursModel> daysMap = {};
    
    json.forEach((key, value) {
      daysMap[key] = DayHoursModel.fromJson(value);
    });
    
    return BusinessHoursModel(days: daysMap);
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    days.forEach((key, value) {
      data[key] = value.toJson();
    });
    
    return data;
  }
}

class DayHoursModel {
  final bool isOpen;
  final String? openTime;
  final String? closeTime;
  
  DayHoursModel({
    required this.isOpen,
    this.openTime,
    this.closeTime,
  });
  
  factory DayHoursModel.fromJson(Map<String, dynamic> json) {
    return DayHoursModel(
      isOpen: json['is_open'],
      openTime: json['open_time'],
      closeTime: json['close_time'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'is_open': isOpen,
      'open_time': openTime,
      'close_time': closeTime,
    };
  }
}
