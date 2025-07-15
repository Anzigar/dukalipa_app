import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dukalipa_app/core/theme/app_theme.dart';

class BarcodeHistoryScreen extends StatefulWidget {
  const BarcodeHistoryScreen({super.key});

  @override
  State<BarcodeHistoryScreen> createState() => _BarcodeHistoryScreenState();
}

class _BarcodeHistoryScreenState extends State<BarcodeHistoryScreen> {
  final List<ScannedBarcode> _history = [
    ScannedBarcode(
      barcode: '8901030865278',
      productName: 'iPhone 13 Pro',
      scannedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      action: 'Added to Sale',
    ),
    ScannedBarcode(
      barcode: '8901030865279',
      productName: 'Samsung Galaxy S21',
      scannedAt: DateTime.now().subtract(const Duration(hours: 1)),
      action: 'Product Lookup',
    ),
    ScannedBarcode(
      barcode: '8901030865280',
      productName: 'AirPods Pro',
      scannedAt: DateTime.now().subtract(const Duration(days: 1)),
      action: 'Inventory Check',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: _history.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return _BarcodeHistoryItem(
                  item: item,
                  onTap: () => _showBarcodeDetails(item),
                  onDelete: () => _deleteItem(index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/barcode-scanner'),
        backgroundColor: AppTheme.mkbhdRed, // Meta blue
        icon: const Icon(LucideIcons.scan),
        label: const Text('Scan New'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.scanLine,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Scan History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your scanned barcodes will appear here',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all scan history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _history.clear();
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.mkbhdRed), // Meta blue
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(int index) {
    setState(() {
      _history.removeAt(index);
    });
  }

  void _showBarcodeDetails(ScannedBarcode item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.scanLine, size: 24),
                const SizedBox(width: 12),
                Text(
                  item.barcode,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (item.productName != null) ...[
              Text(
                'Product: ${item.productName}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Action: ${item.action}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scanned: ${_formatDateTime(item.scannedAt)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/barcode-scanner');
                    },
                    child: const Text('Scan Again'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/inventory/search?barcode=${item.barcode}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.mkbhdRed, // Meta blue
                    ),
                    child: const Text('Search Product'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

class _BarcodeHistoryItem extends StatelessWidget {
  final ScannedBarcode item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BarcodeHistoryItem({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.barcode + item.scannedAt.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.mkbhdRed, // Meta blue instead of red
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          LucideIcons.trash2,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.mkbhdRed.withOpacity(0.1), // Meta blue
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.scanLine,
                      color: AppTheme.mkbhdRed, // Meta blue
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.barcode,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (item.productName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.productName!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(item.scannedAt),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.action,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class ScannedBarcode {
  final String barcode;
  final String? productName;
  final DateTime scannedAt;
  final String action;

  ScannedBarcode({
    required this.barcode,
    this.productName,
    required this.scannedAt,
    required this.action,
  });
}
