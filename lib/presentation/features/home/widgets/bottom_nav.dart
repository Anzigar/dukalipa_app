import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dukalipa_app/core/theme/dukalipa_colors.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        // Handle navigation tap
        switch (index) {
          case 0:
            // Already on home, do nothing
            break;
          case 1:
            context.push('/sales');
            break;
          case 2:
            context.push('/inventory');
            break;
          case 3:
            context.push('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.shoppingCart),
          label: 'Sales',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.package),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.user),
          label: 'Profile',
        ),
      ],
      selectedItemColor: AirbnbColors.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 8,
    );
  }
}
