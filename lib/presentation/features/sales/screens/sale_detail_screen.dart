import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/sale_model.dart';
import '../repositories/sales_repository.dart';

class SaleDetailScreen extends StatefulWidget {
  final String saleId;

  const SaleDetailScreen({
    super.key,
    required this.saleId,
  });

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  late final SalesRepository _repository;
  SaleModel? _sale;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = SalesRepositoryImpl();
    _fetchSaleDetails();
  }

  Future<void> _fetchSaleDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final sale = await _repository.getSaleById(widget.saleId);
      if (mounted) {
        setState(() {
          _sale = sale;
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
      backgroundColor: AppTheme.metaLightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.metaLightBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.mkbhdDarkGrey),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _sale != null ? 'Sale #${_sale!.id}' : 'Sale Details',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.mkbhdDarkGrey,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.mkbhdGrey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading sale details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mkbhdDarkGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage ?? 'Sale not found',
                        style: const TextStyle(
                          color: AppTheme.mkbhdGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchSaleDetails,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _sale != null
                  ? _buildSaleDetails()
                  : const Center(
                      child: Text(
                        'Sale not found',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.mkbhdGrey,
                        ),
                      ),
                    ),
    );
  }

  Widget _buildSaleDetails() {
    if (_sale == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sale header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.mkbhdLightGrey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.mkbhdRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.receipt_rounded,
                        color: AppTheme.mkbhdRed,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sale #${_sale!.id}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.mkbhdDarkGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _sale!.formattedDateTime,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.mkbhdGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_sale!.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _sale!.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (_sale!.hasCustomerInfo) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mkbhdDarkGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (_sale!.customerName != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          color: AppTheme.mkbhdGrey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _sale!.customerName!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.mkbhdDarkGrey,
                          ),
                        ),
                      ],
                    ),
                  
                  if (_sale!.customerPhone != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          color: AppTheme.mkbhdGrey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _sale!.customerPhone!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.mkbhdDarkGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sale items
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.mkbhdLightGrey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items (${_sale!.items.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mkbhdDarkGrey,
                  ),
                ),
                const SizedBox(height: 16),
                
                ..._sale!.items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.metaLightBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.mkbhdDarkGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Qty: ${item.quantity} × TSh ${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.mkbhdGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'TSh ${item.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mkbhdDarkGrey,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Payment summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.mkbhdLightGrey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mkbhdDarkGrey,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (_sale!.discount > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdGrey,
                        ),
                      ),
                      Text(
                        _sale!.formattedSubtotal,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdDarkGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Discount',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdGrey,
                        ),
                      ),
                      Text(
                        '-${_sale!.formattedDiscount}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                ],
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.mkbhdDarkGrey,
                      ),
                    ),
                    Text(
                      _sale!.formattedAmount,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.mkbhdRed,
                      ),
                    ),
                  ],
                ),
                
                if (_sale!.paymentMethod != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.payment,
                        color: AppTheme.mkbhdGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Payment: ${_sale!.paymentMethod}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.mkbhdGrey,
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (_sale!.note != null && _sale!.note!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mkbhdDarkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sale!.note!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.mkbhdGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.mkbhdGrey;
    }
  }
}
