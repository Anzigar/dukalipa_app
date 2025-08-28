# Claude Development Instructions

## Project Overview
This is a Flutter shop management application called Dukalipa that uses Appwrite as the backend service for authentication, database, and storage.

## Key Technologies
- **Frontend**: Flutter with Provider state management
- **Backend**: Appwrite Backend-as-a-Service
- **UI Design**: Material 3 (Material You) with expressive design
- **Animations**: Lottie animations for enhanced UX
- **Fonts**: Google Fonts (Poppins primary)
- **Responsive**: flutter_screenutil for responsive sizing

## Architecture Patterns
- **Repository Pattern**: Used for data abstraction between UI and services
- **Provider Pattern**: Used for state management across the app
- **Dependency Injection**: Using get_it for service location

## UI/UX Guidelines

### Button Design
- **Primary Buttons**: Use `FilledButton.icon` with Material 3 expressive design
### Use Material 3 expressive:
 UI as `https://m3.material.io/components`
- **Border Radius**: 28.r for expressive rounded corners
- **Elevation**: Always set to 0 (no shadows)
- **Size**: Small to medium sizes, avoid oversized buttons
- **Colors**: Use `colorScheme.primary` for consistency

### Empty States
- **Animation**: Use `assets/animations/Empty_box.json` Lottie animation
- **Centered Layout**: Always center content in empty states
- **Action Button**: Include "Add Product" button below content

### Loading States
- Use `CircularProgressIndicator` for loading
- Consider shimmer effects for list items (shimmer package available)

### Error States
- Replace "Try Again" buttons with relevant action buttons (e.g., "Add Product")
- Use Lottie animations instead of static icons when possible
- Keep messaging encouraging and solution-focused

## Backend Integration

### Appwrite Configuration
- **Database ID**: `shop_management_db`
- **Collections**: 
  - `products` - Product inventory
  - User isolation implemented via user-based filtering

### Authentication
- Email/password authentication implemented
- Google Sign-In configured
- Session persistence enabled

### File Storage
- Product images stored in Appwrite Storage
- Bucket: `product_images`

## Development Commands

### Testing
- Run tests: `flutter test`
- Integration tests: (command to be added)

### Build
- Debug build: `flutter run`
- Release build: `flutter build apk --release`

### Linting
- Run linter: `flutter analyze`
- Format code: `dart format .`

## Important Files Structure

```
lib/
├── core/
│   ├── di/service_locator.dart          # Dependency injection setup
│   ├── services/appwrite_service.dart   # Appwrite configuration
│   └── constants/shop_types.dart        # Shop type definitions
├── data/
│   └── services/
│       └── appwrite_inventory_service.dart  # Appwrite inventory operations
├── presentation/
│   └── features/
│       ├── auth/                        # Authentication screens
│       ├── inventory/                   # Inventory management
│       │   ├── screens/
│       │   │   ├── inventory_screen.dart
│       │   │   └── add_product_screen.dart
│       │   └── repositories/
│       └── home/                        # Dashboard/home screens
└── assets/
    └── animations/
        └── Empty_box.json               # Primary empty state animation
```

## Code Style Guidelines

### Import Organization
1. Flutter/Dart imports first
2. Third-party packages
3. Local imports (grouped by feature)

### Naming Conventions
- Use descriptive names for methods and variables
- Private methods start with underscore `_`
- Constants in SCREAMING_SNAKE_CASE

### Widget Building
- Break complex widgets into smaller methods
- Use `const` constructors where possible
- Prefer composition over inheritance

## Common Patterns

### Error Handling
```dart
try {
  // API call
} catch (e) {
  if (mounted) {
    setState(() {
      _isLoading = false;
      _hasError = true;
    });
  }
}
```

### Navigation
```dart
context.push('/route', extra: {'key': 'value'});
```

### State Management
```dart
Consumer<ProviderName>(
  builder: (context, provider, child) {
    return Widget();
  },
)
```

## Troubleshooting

### Common Issues
1. **Build errors**: Run `flutter clean && flutter pub get`
2. **Dependency conflicts**: Check pubspec.yaml for version conflicts
3. **Appwrite connection**: Verify endpoints in AppwriteService

### Performance Tips
- Use `const` constructors
- Implement proper dispose methods
- Avoid rebuilding widgets unnecessarily
- Use `ListView.builder` for long lists

## Assets
- **Animations**: Located in `assets/animations/`
- **Images**: Located in `assets/images/`
- **Icons**: Using Lucide Icons package
- **Fonts**: Google Fonts (Poppins) loaded dynamically

## Future Enhancements
- Barcode scanning integration
- Advanced analytics dashboard
- Multi-language support (i18n structure exists)
- Push notifications
- Offline synchronization

---

**Note**: This file should be updated as the project evolves. Add new patterns, configurations, and guidelines as they are established during development.