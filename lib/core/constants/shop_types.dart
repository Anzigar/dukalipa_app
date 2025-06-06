/// Constants for shop types used throughout the application
class ShopTypes {
  /// A general shop with mixed inventory
  static const String general = 'General';
  
  /// Shop specializing in electronics
  static const String electronics = 'Electronics';
  
  /// Shop specializing in clothing
  static const String clothing = 'Clothing';
  
  /// Shop specializing in food items
  static const String food = 'Food';
  
  /// Shop specializing in beverages
  static const String beverages = 'Beverages';
  
  /// Shop specializing in stationery
  static const String stationery = 'Stationery';
  
  /// Shop specializing in household items
  static const String household = 'Household';
  
  /// Shop specializing in health and beauty products
  static const String healthAndBeauty = 'Health & Beauty';
  
  /// List of all available shop types
  static List<String> get all => [
    general, 
    electronics, 
    clothing, 
    food, 
    beverages, 
    stationery, 
    household, 
    healthAndBeauty
  ];
}

