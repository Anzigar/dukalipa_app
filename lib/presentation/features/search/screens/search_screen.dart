import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/airbnb_colors.dart';
import '../../../common/widgets/custom_search_bar.dart';
import '../../../common/widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final List<String> _recentSearches = ['Product name', 'Sale #12345', 'Customer name'];
  List<String> _searchResults = [];

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
          // Mock search results
          _searchResults = [
            'Product: $query Item',
            'Client: $query Customer',
            'Sale: #1234 ($query)',
            'Expense: $query Payment',
          ];

          // Add to recent searches if not empty
          if (query.trim().isNotEmpty && !_recentSearches.contains(query)) {
            _recentSearches.insert(0, query);
            if (_recentSearches.length > 5) {
              _recentSearches.removeLast();
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft, 
            color: isDark ? Colors.white : AirbnbColors.secondary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Search',
          style: TextStyle(
            color: isDark ? Colors.white : AirbnbColors.secondary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search products, sales, clients...',
              onSearch: _performSearch,
              autofocus: true,
            ),
          ),
          
          if (_isSearching)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: AirbnbColors.primary,
                ),
              ),
            )
          else if (_searchController.text.isNotEmpty && _searchResults.isEmpty)
            const Expanded(
              child: EmptyState(
                icon: LucideIcons.search,
                title: 'No results found',
                message: 'Try a different search term',
              ),
            )
          else if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  IconData icon;
                  
                  if (result.startsWith('Product:')) {
                    icon = LucideIcons.package;
                  } else if (result.startsWith('Client:')) {
                    icon = LucideIcons.user;
                  } else if (result.startsWith('Sale:')) {
                    icon = LucideIcons.receipt;
                  } else {
                    icon = LucideIcons.wallet;
                  }
                  
                  return ListTile(
                    leading: Icon(icon),
                    title: Text(result),
                    onTap: () {
                      // Navigate based on result type
                    },
                  );
                },
              ),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AirbnbColors.secondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _recentSearches.isNotEmpty
                        ? ListView.builder(
                            itemCount: _recentSearches.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(LucideIcons.clock),
                                title: Text(_recentSearches[index]),
                                trailing: IconButton(
                                  icon: const Icon(LucideIcons.x, size: 16),
                                  onPressed: () {
                                    setState(() {
                                      _recentSearches.removeAt(index);
                                    });
                                  },
                                ),
                                onTap: () {
                                  _searchController.text = _recentSearches[index];
                                  _performSearch(_recentSearches[index]);
                                },
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              'No recent searches',
                              style: TextStyle(
                                color: AirbnbColors.lightText,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
