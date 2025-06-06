import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../models/sale_model.dart';
import '../repositories/sales_repository.dart';
import '../repositories/sales_repository_impl.dart' as impl;
import '../../../common/widgets/loading_widget.dart';

class SaleDetailsScreen extends StatefulWidget {
  final String saleId;
  
  const SaleDetailsScreen({
    Key? key,
    required this.saleId,
  }) : super(key: key);

  @override
  State<SaleDetailsScreen> createState() => _SaleDetailsScreenState();
}

class _SaleDetailsScreenState extends State<SaleDetailsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  SaleModel? _sale;
  late SalesRepository _repository;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
      _fetchSale();
    });
  }
  
  void _initRepository() {
    try {
      // Try to get the repository from the provider first
      _repository = Provider.of<SalesRepository>(context, listen: false);
    } catch (e) {
      // If provider not found, create a local instance with default API client
      final apiClient = ApiClient();
      _repository = impl.SalesRepositoryImpl(apiClient);
    }
  }
  
  Future<void> _fetchSale() async {
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
      appBar: AppBar(
        title: const Text('Sale Details'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_sale != null) ...[
            IconButton(
              icon: const Icon(LucideIcons.download),
              onPressed: () => _downloadReceipt(),
              tooltip: 'Download receipt',
            ),
            IconButton(
              icon: const Icon(LucideIcons.share2),
              onPressed: () => _shareReceipt(),
              tooltip: 'Share receipt',
            ),
          ],
        ],
      ),
      body: _buildContent(),
    );
  }
  
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
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
              _errorMessage ?? 'An error occurred while loading the sale',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchSale,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.mkbhdRed,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_sale == null) {
      return const Center(
        child: Text('Sale not found'),
      );
    }
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sale header
          SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Increased from 12 to 20
                side: BorderSide(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sale #${_sale!.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_sale!.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getStatusText(_sale!.status),
                            style: TextStyle(
                              color: _getStatusColor(_sale!.status),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.calendar,
                          size: 16,
                          color: AppTheme.mkbhdLightGrey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _sale!.formattedDateTime,
                          style: const TextStyle(
                            color: AppTheme.mkbhdLightGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_sale!.customerName != null) ...[
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.user,
                            size: 16,
                            color: AppTheme.mkbhdLightGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _sale!.customerName!,
                            style: const TextStyle(
                              color: AppTheme.mkbhdLightGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (_sale!.paymentMethod != null) ...[
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.creditCard,
                            size: 16,
                            color: AppTheme.mkbhdLightGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _sale!.paymentMethod!,
                            style: const TextStyle(
                              color: AppTheme.mkbhdLightGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Items section
          const Text(
            'Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Increased from 12 to 20
              side: BorderSide(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Item',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Qty',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Price',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ..._sale!.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            item.productName,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'TSh ${item.price.toStringAsFixed(0)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const Divider(height: 24),
                  
                  // Subtotal row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'TSh ${NumberFormat('#,###').format(_calculateSubtotal())}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Discount row (if there is a discount)
                  if (_sale!.discount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Discount',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '- TSh ${NumberFormat('#,###').format(_sale!.discount)}',
                          style: const TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Total row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'TSh ${NumberFormat('#,###').format(_sale!.totalAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.mkbhdRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Notes section (if there are notes)
          if (_sale!.note != null && _sale!.note!.isNotEmpty) ...[
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Increased from 12 to 20
                side: BorderSide(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _sale!.note!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
          
          // Actions
          if (_sale!.status != 'cancelled') ...[
            Row(
              children: [
                if (_sale!.status != 'completed')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markAsCompleted(),
                      icon: const Icon(LucideIcons.check),
                      label: const Text('Mark as Completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // Increased from 8 to 16
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(),
                    icon: const Icon(LucideIcons.trash2),
                    label: const Text('Cancel Sale'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // Increased from 8 to 16
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  double _calculateSubtotal() {
    return _sale!.totalAmount + _sale!.discount;
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
        return Colors.blue;
    }
  }
  
  String _getStatusText(String status) {
    // Capitalize first letter
    return status.isNotEmpty 
        ? status[0].toUpperCase() + status.substring(1)
        : '';
  }
  
  void _printReceipt() {
    // Redirect to download receipt
    _downloadReceipt();
  }
  
  Future<void> _downloadReceipt() async {
    if (_sale == null) return;
    
    final pdf = await _generateReceiptPdf();
    
    // Open the PDF document for viewing or saving
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Sale_${_sale!.id.substring(0, 8)}_receipt.pdf',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt downloaded successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Future<void> _shareReceipt() async {
    if (_sale == null) return;
    
    try {
      // Show loading indicator
      setState(() {
        _isLoading = true;
      });
      
      final pdf = await _generateReceiptPdf();
      final bytes = await pdf.save();
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/sale_${_sale!.id.substring(0, 8)}_receipt.pdf');
      await file.writeAsBytes(bytes);
      
      setState(() {
        _isLoading = false;
      });
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Sale Receipt #${_sale!.id.substring(0, 8)}',
        subject: 'Sale Receipt',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share receipt: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<pw.Document> _generateReceiptPdf() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('DUKALIPA', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('Smart Shop Management')
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('RECEIPT', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('#${_sale!.id.substring(0, 8)}', style: pw.TextStyle(fontSize: 16))
                    ]
                  )
                ]
              ),
              
              pw.SizedBox(height: 20),
              
              pw.Divider(thickness: 1),
              
              pw.SizedBox(height: 20),
              
              // Sale Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Date:'),
                      pw.Text('Status:'),
                      if (_sale!.customerName != null) pw.Text('Customer:'),
                      if (_sale!.paymentMethod != null) pw.Text('Payment Method:'),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(_sale!.formattedDateTime),
                      pw.Text(_getStatusText(_sale!.status)),
                      if (_sale!.customerName != null) pw.Text(_sale!.customerName!),
                      if (_sale!.paymentMethod != null) pw.Text(_sale!.paymentMethod!),
                    ]
                  )
                ]
              ),
              
              pw.SizedBox(height: 30),
              
              // Items Table
              pw.Text('ITEMS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                    ]
                  ),
                  // Item rows
                  ..._sale!.items.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item.productName),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item.quantity.toString(), textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('TSh ${item.price.toStringAsFixed(0)}', textAlign: pw.TextAlign.right),
                      ),
                    ]
                  )),
                ]
              ),
              
              pw.SizedBox(height: 20),
              
              // Totals
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Container(width: 100, child: pw.Text('Subtotal:')),
                        pw.Container(width: 100, child: pw.Text('TSh ${NumberFormat('#,###').format(_calculateSubtotal())}', textAlign: pw.TextAlign.right)),
                      ]
                    ),
                    if (_sale!.discount > 0) pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Container(width: 100, child: pw.Text('Discount:')),
                        pw.Container(
                          width: 100, 
                          child: pw.Text('- TSh ${NumberFormat('#,###').format(_sale!.discount)}', 
                            textAlign: pw.TextAlign.right, 
                            style: pw.TextStyle(color: PdfColors.green)
                          )
                        ),
                      ]
                    ),
                    pw.Divider(thickness: 1),
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Container(width: 100, child: pw.Text('TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Container(
                          width: 100, 
                          child: pw.Text('TSh ${NumberFormat('#,###').format(_sale!.totalAmount)}', 
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold), 
                            textAlign: pw.TextAlign.right
                          )
                        ),
                      ]
                    ),
                  ]
                )
              ),
              
              pw.SizedBox(height: 30),
              
              // Notes if available
              if (_sale!.note != null && _sale!.note!.isNotEmpty) ...[
                pw.Text('NOTES:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10))
                  ),
                  child: pw.Text(_sale!.note!),
                ),
                pw.SizedBox(height: 20),
              ],
              
              // Footer
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text('Thank you for your business!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic))
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text('Powered by Dukalipa')
              )
            ]
          );
        }
      )
    );
    
    return pdf;
  }
  
  Future<void> _markAsCompleted() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final updatedSale = await _repository.updateSale(
        id: widget.saleId,
        status: 'completed',
      );
      
      if (mounted) {
        setState(() {
          _sale = updatedSale;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update sale: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Sale'),
        content: const Text('Are you sure you want to cancel this sale? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelSale();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _cancelSale() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final updatedSale = await _repository.updateSale(
        id: widget.saleId,
        status: 'cancelled',
        note: _sale!.note != null 
            ? '${_sale!.note}\n[CANCELLED]' 
            : '[CANCELLED]',
      );
      
      if (mounted) {
        setState(() {
          _sale = updatedSale;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale cancelled successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel sale: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

