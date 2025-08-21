import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../widgets/customer_selection_dialog.dart';

class CustomerUtils {
  /// Shows a customer selection dialog and returns the selected customer
  /// 
  /// [context] - The build context
  /// [initialSearch] - Optional initial search term
  /// [allowNewCustomer] - Whether to allow adding new customers
  /// 
  /// Returns the selected CustomerModel or null if cancelled
  static Future<CustomerModel?> showCustomerSelection({
    required BuildContext context,
    String? initialSearch,
    bool allowNewCustomer = true,
  }) async {
    return showDialog<CustomerModel>(
      context: context,
      builder: (context) => CustomerSelectionDialog(
        initialSearch: initialSearch,
        allowNewCustomer: allowNewCustomer,
      ),
    );
  }

  /// Shows a customer selection dialog specifically for sales
  /// 
  /// [context] - The build context
  /// [initialSearch] - Optional initial search term (usually phone number)
  /// 
  /// Returns the selected CustomerModel or null if cancelled
  static Future<CustomerModel?> showCustomerSelectionForSales({
    required BuildContext context,
    String? initialSearch,
  }) async {
    return showCustomerSelection(
      context: context,
      initialSearch: initialSearch,
      allowNewCustomer: true,
    );
  }

  /// Shows a customer selection dialog for viewing only (no new customer creation)
  /// 
  /// [context] - The build context
  /// [initialSearch] - Optional initial search term
  /// 
  /// Returns the selected CustomerModel or null if cancelled
  static Future<CustomerModel?> showCustomerSelectionViewOnly({
    required BuildContext context,
    String? initialSearch,
  }) async {
    return showCustomerSelection(
      context: context,
      initialSearch: initialSearch,
      allowNewCustomer: false,
    );
  }

  /// Shows a customer selection dialog with a specific title
  /// 
  /// [context] - The build context
  /// [title] - Custom title for the dialog
  /// [initialSearch] - Optional initial search term
  /// [allowNewCustomer] - Whether to allow adding new customers
  /// 
  /// Returns the selected CustomerModel or null if cancelled
  static Future<CustomerModel?> showCustomerSelectionWithTitle({
    required BuildContext context,
    required String title,
    String? initialSearch,
    bool allowNewCustomer = true,
  }) async {
    return showDialog<CustomerModel>(
      context: context,
      builder: (context) => CustomerSelectionDialog(
        initialSearch: initialSearch,
        allowNewCustomer: allowNewCustomer,
      ),
    );
  }
}
