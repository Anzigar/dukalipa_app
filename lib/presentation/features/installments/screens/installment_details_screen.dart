import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/installment_model.dart';
import '../repositories/installment_repository.dart';
import '../repositories/installment_repository_impl.dart' as impl;
import '../../../common/widgets/shimmer_loading.dart';

class InstallmentDetailsScreen extends StatefulWidget {
  final String installmentId;
  
  const InstallmentDetailsScreen({
    Key? key,
    required this.installmentId,
  }) : super(key: key);

  @override
  State<InstallmentDetailsScreen> createState() => _InstallmentDetailsScreenState();
}

class _InstallmentDetailsScreenState extends State<InstallmentDetailsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  InstallmentModel? _installment;
  late InstallmentRepository _repository;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _fetchInstallment();
    });
  }
  
  void _initRepository() {
    try {
      // Try to get the repository from the provider first
      _repository = Provider.of<InstallmentRepository>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance
      _repository = impl.InstallmentRepositoryImpl();
    }
  }
  
  Future<void> _fetchInstallment() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final installment = await _repository.getInstallmentById(widget.installmentId);
      
      if (mounted) {
        setState(() {
          _installment = installment;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installment Details'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit2),
            onPressed: () {
              // Navigate to edit installment page
              // context.push('/installments/edit/${widget.installmentId}');
            },
          ),
        ],
      ),
      body: _buildContent(),
    );
  }
  
  Widget _buildContent() {
    if (_isLoading) {
      return const TransactionCardShimmer();
    }
    
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertTriangle,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred while loading the installment',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchInstallment,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_installment == null) {
      return const Center(
        child: Text('Installment not found'),
      );
    }
    
    // This is a temporary implementation until you define the actual UI
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client information
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey.shade700 
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Client Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Name', _installment!.clientName),
                  _buildDetailRow('Phone', _installment!.clientPhone),
                  if (_installment!.clientEmail != null)
                    _buildDetailRow('Email', _installment!.clientEmail!),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Payment information
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey.shade700 
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Total Amount', _installment!.formattedTotalAmount),
                  _buildDetailRow('Down Payment', _installment!.formattedDownPayment),
                  _buildDetailRow('Remaining Amount', _installment!.formattedRemainingAmount),
                  _buildDetailRow('Status', _installment!.status),
                  _buildDetailRow('Start Date', _installment!.formattedStartDate),
                  _buildDetailRow('Due Date', _installment!.formattedDueDate),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Products
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey.shade700 
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _installment!.productNames.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_installment!.productNames[index]),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.mkbhdRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.package,
                            color: AppTheme.mkbhdRed,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Payment history
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey.shade700 
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payment History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Show add payment dialog
                        },
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text('Add Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_installment!.payments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No payments recorded yet'),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _installment!.payments.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final payment = _installment!.payments[index];
                        return ListTile(
                          title: Text('Payment #${index + 1}'),
                          subtitle: Text(payment.formattedDate),
                          trailing: Text(
                            payment.formattedAmount,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.mkbhdRed,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.mkbhdLightGrey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
