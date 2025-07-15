import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/meta_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../viewmodels/edit_profile_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _shopPhoneController = TextEditingController();
  
  late EditProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditProfileViewModel(Provider.of<AuthProvider>(context, listen: false));
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    await _viewModel.loadUserProfile();
    _populateFields();
  }

  void _populateFields() {
    final profile = _viewModel.userProfile;
    if (profile != null) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone ?? '';
      _shopNameController.text = profile.shopName ?? '';
      _shopAddressController.text = profile.shopAddress ?? '';
      _shopPhoneController.text = profile.shopPhone ?? '';
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _viewModel.saveProfile(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      shopName: _shopNameController.text,
      shopAddress: _shopAddressController.text,
      shopPhone: _shopPhoneController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: MetaColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage ?? 'Failed to update profile'),
            backgroundColor: MetaColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<EditProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: MetaColors.error,
                ),
              );
              viewModel.clearError();
            });
          }

          return Scaffold(
            backgroundColor: MetaColors.backgroundColor,
            appBar: AppBar(
              title: const Text('Edit Profile'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator(
                    color: MetaColors.primaryBlue,
                  ))
                : Form(
                    key: _formKey,
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Personal Information Section
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: MetaColors.cardBackground,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: MetaColors.borderLight,
                                    width: 1,
                                  ),
                                 
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Personal Information',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: MetaColors.primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    CustomTextField(
                                      controller: _nameController,
                                      labelText: 'Full Name',
                                      hintText: 'Enter your full name',
                                      prefixIcon: Icons.person_outline,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Name is required';
                                        }
                                        if (value.trim().length < 2) {
                                          return 'Name must be at least 2 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _emailController,
                                      labelText: 'Email Address',
                                      hintText: 'Enter your email',
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _phoneController,
                                      labelText: 'Phone Number',
                                      hintText: 'Enter your phone number',
                                      prefixIcon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value != null && value.trim().isNotEmpty) {
                                          if (value.trim().length < 10) {
                                            return 'Phone number must be at least 10 digits';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Shop Information Section
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: MetaColors.cardBackground,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: MetaColors.borderLight,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: MetaColors.darkGrey.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Shop Information',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: MetaColors.primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    CustomTextField(
                                      controller: _shopNameController,
                                      labelText: 'Shop Name',
                                      hintText: 'Enter your shop name',
                                      prefixIcon: Icons.store_outlined,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _shopAddressController,
                                      labelText: 'Shop Address',
                                      hintText: 'Enter your shop address',
                                      prefixIcon: Icons.location_on_outlined,
                                      maxLines: 3,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _shopPhoneController,
                                      labelText: 'Shop Phone',
                                      hintText: 'Enter shop phone number',
                                      prefixIcon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Save Button - Fixed to work with existing CustomButton
                              viewModel.isSaving
                                  ? Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      decoration: BoxDecoration(
                                        color: MetaColors.primaryBlue.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Saving...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : CustomButton(
                                      text: 'Save Changes',
                                      onPressed: _saveProfile,
                                      backgroundColor: MetaColors.primaryBlue,
                                      textColor: Colors.white,
                                      borderRadius: 16,
                                      fullWidth: true,
                                    ),
                              
                              const SizedBox(height: 32),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _shopPhoneController.dispose();
    super.dispose();
  }
}
