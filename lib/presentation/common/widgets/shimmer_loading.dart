import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: baseColor ?? (isDarkMode ? Colors.grey[800]! : Colors.grey[350]!),
      highlightColor: highlightColor ?? (isDarkMode ? Colors.grey[700]! : Colors.grey[200]!),
      period: const Duration(milliseconds: 1500), // Slower animation
      child: child,
    );
  }
}

// Product Card Shimmer
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return ShimmerLoading(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              // Product details placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Product price
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Product stock
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              // Stock indicator placeholder
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Inventory Summary Shimmer
class InventorySummaryShimmer extends StatelessWidget {
  const InventorySummaryShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Summary title
            Container(
              width: 120,
              height: 18,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            // Summary stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) => Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// Product Details Shimmer
class ProductDetailsShimmer extends StatelessWidget {
  const ProductDetailsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),
            // Product name
            Container(
              width: double.infinity,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            // Product description
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 16,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            // Info items
            ...List.generate(4, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// Category Strip Shimmer
class CategoryStripShimmer extends StatelessWidget {
  const CategoryStripShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.only(left: 16),
            child: Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Add Product Form Shimmer
class AddProductFormShimmer extends StatelessWidget {
  const AddProductFormShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),
            // Form fields
            ...List.generate(6, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
            // Save button
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Generic List Shimmer
class ListShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ListShimmer({
    Key? key,
    this.itemCount = 10,
    this.itemHeight = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => ProductCardShimmer(),
    );
  }
}

// Sales Screen Shimmer
class SalesCardShimmer extends StatelessWidget {
  const SalesCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Sale ID
                  Container(
                    width: 80,
                    height: 16,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  // Sale date
                  Container(
                    width: 100,
                    height: 14,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Customer info
              Container(
                width: 150,
                height: 14,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              // Total amount
              Container(
                width: 120,
                height: 18,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              // Items count
              Container(
                width: 100,
                height: 12,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Returns/Damaged/Deleted Screen Shimmer
class TransactionCardShimmer extends StatelessWidget {
  const TransactionCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon placeholder
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              // Status indicator
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dashboard/Home Screen Shimmer
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats cards
          Row(
            children: [
              Expanded(child: _buildStatCardShimmer()),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCardShimmer()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCardShimmer()),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCardShimmer()),
            ],
          ),
          const SizedBox(height: 24),
          // Chart placeholder
          ShimmerLoading(
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Recent activities header
          ShimmerLoading(
            child: Container(
              width: 150,
              height: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Recent activities list
          ...List.generate(3, (index) => const TransactionCardShimmer()),
        ],
      ),
    );
  }

  Widget _buildStatCardShimmer() {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 60,
              height: 20,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Screen Shimmer
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 150,
              height: 20,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 14,
              color: Colors.white,
            ),
            const SizedBox(height: 32),
            // Menu items
            ...List.generate(6, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// Settings/Form Shimmer
class SettingsShimmer extends StatelessWidget {
  const SettingsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section headers and items
            ...List.generate(3, (sectionIndex) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 18,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                ...List.generate(4, (itemIndex) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )),
                const SizedBox(height: 24),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

// Expenses Screen Shimmer
class ExpenseCardShimmer extends StatelessWidget {
  const ExpenseCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              // Expense details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              // Amount
              Container(
                width: 80,
                height: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reports Screen Shimmer
class ReportsShimmer extends StatelessWidget {
  const ReportsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date filter
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            // Summary cards
            Row(
              children: [
                Expanded(child: _buildReportCardShimmer()),
                const SizedBox(width: 16),
                Expanded(child: _buildReportCardShimmer()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildReportCardShimmer()),
                const SizedBox(width: 16),
                Expanded(child: _buildReportCardShimmer()),
              ],
            ),
            const SizedBox(height: 24),
            // Chart
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),
            // Report list
            ...List.generate(5, (index) => const SalesCardShimmer()),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 24,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: 14,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

// Serial Numbers Screen Shimmer
class SerialNumbersShimmer extends StatelessWidget {
  const SerialNumbersShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        // Search and Filter Section Shimmer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ShimmerLoading(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar Shimmer
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Label Shimmer
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Filter Chips Shimmer
                Row(
                  children: List.generate(3, (index) => Padding(
                    padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
                    child: Container(
                      width: 80 + (index * 10),
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
        
        // Results Summary Shimmer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ShimmerLoading(
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 180,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Device Cards List Shimmer
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) => const DeviceCardShimmer(),
          ),
        ),
      ],
    );
  }
}

// Device Card Shimmer for Serial Numbers
class DeviceCardShimmer extends StatelessWidget {
  const DeviceCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return ShimmerLoading(
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with device number and copy button
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Serial Number Container
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Device Variations (chips)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: List.generate(3, (index) => Container(
                  width: 70 + (index * 15),
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
