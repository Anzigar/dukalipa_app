import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _shopNameController;
  late TextEditingController _shopAddressController;
  late TextEditingController _shopPhoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().userProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _shopNameController = TextEditingController(text: profile?.shopName ?? '');
    _shopAddressController = TextEditingController(text: profile?.shopAddress ?? '');
    _shopPhoneController = TextEditingController(text: profile?.shopPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _shopPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement updateUserProfile in AuthProvider
      // await context.read<AuthProvider>().updateUserProfile(
      //   name: _nameController.text,
      //   email: _emailController.text,
      //   shopName: _shopNameController.text,
      //   shopAddress: _shopAddressController.text,
      //   shopPhone: _shopPhoneController.text,
      // );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Shop Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _shopNameController,
              labelText: 'Shop Name',
              prefixIcon: Icons.store_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _shopAddressController,
              labelText: 'Shop Address',
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _shopPhoneController,
              labelText: 'Shop Phone',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Save Changes',
              isLoading: _isLoading,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
