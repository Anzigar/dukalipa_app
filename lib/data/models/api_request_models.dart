/// Base class for all API request models
abstract class ApiRequestModel {
  Map<String, dynamic> toJson();
}

/// Product creation request model
class ProductCreate extends ApiRequestModel {
  final String name;
  final String? description;
  final String sku;
  final String? barcode;
  final String? category;
  final String? supplier;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String? unitOfMeasure;
  final double? weight;
  final String? dimensions;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? location;

  ProductCreate({
    required this.name,
    this.description,
    required this.sku,
    this.barcode,
    this.category,
    this.supplier,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    this.lowStockThreshold = 5,
    this.unitOfMeasure = 'pieces',
    this.weight,
    this.dimensions,
    this.expiryDate,
    this.batchNumber,
    this.location,
  });

  factory ProductCreate.fromJson(Map<String, dynamic> json) {
    return ProductCreate(
      name: json['name'] as String,
      description: json['description'] as String?,
      sku: json['sku'] as String,
      barcode: json['barcode'] as String?,
      category: json['category'] as String?,
      supplier: json['supplier'] as String?,
      costPrice: (json['cost_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] as int,
      lowStockThreshold: json['low_stock_threshold'] as int? ?? 5,
      unitOfMeasure: json['unit_of_measure'] as String? ?? 'pieces',
      weight: json['weight'] as double?,
      dimensions: json['dimensions'] as String?,
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      batchNumber: json['batch_number'] as String?,
      location: json['location'] as String?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'sku': sku,
      'barcode': barcode,
      'category': category,
      'supplier': supplier,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'low_stock_threshold': lowStockThreshold,
      'unit_of_measure': unitOfMeasure,
      'weight': weight,
      'dimensions': dimensions,
      'expiry_date': expiryDate?.toIso8601String(),
      'batch_number': batchNumber,
      'location': location,
    };
  }
}

/// Product update request model
class ProductUpdate extends ApiRequestModel {
  final String? name;
  final String? description;
  final String? sku;
  final String? barcode;
  final String? category;
  final String? supplier;
  final double? costPrice;
  final double? sellingPrice;
  final int? stockQuantity;
  final int? lowStockThreshold;
  final String? unitOfMeasure;
  final double? weight;
  final String? dimensions;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? location;

  ProductUpdate({
    this.name,
    this.description,
    this.sku,
    this.barcode,
    this.category,
    this.supplier,
    this.costPrice,
    this.sellingPrice,
    this.stockQuantity,
    this.lowStockThreshold,
    this.unitOfMeasure,
    this.weight,
    this.dimensions,
    this.expiryDate,
    this.batchNumber,
    this.location,
  });

  factory ProductUpdate.fromJson(Map<String, dynamic> json) {
    return ProductUpdate(
      name: json['name'] as String?,
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      category: json['category'] as String?,
      supplier: json['supplier'] as String?,
      costPrice: json['cost_price'] != null ? (json['cost_price'] as num).toDouble() : null,
      sellingPrice: json['selling_price'] != null ? (json['selling_price'] as num).toDouble() : null,
      stockQuantity: json['stock_quantity'] as int?,
      lowStockThreshold: json['low_stock_threshold'] as int?,
      unitOfMeasure: json['unit_of_measure'] as String?,
      weight: json['weight'] as double?,
      dimensions: json['dimensions'] as String?,
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      batchNumber: json['batch_number'] as String?,
      location: json['location'] as String?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (sku != null) data['sku'] = sku;
    if (barcode != null) data['barcode'] = barcode;
    if (category != null) data['category'] = category;
    if (supplier != null) data['supplier'] = supplier;
    if (costPrice != null) data['cost_price'] = costPrice;
    if (sellingPrice != null) data['selling_price'] = sellingPrice;
    if (stockQuantity != null) data['stock_quantity'] = stockQuantity;
    if (lowStockThreshold != null) data['low_stock_threshold'] = lowStockThreshold;
    if (unitOfMeasure != null) data['unit_of_measure'] = unitOfMeasure;
    if (weight != null) data['weight'] = weight;
    if (dimensions != null) data['dimensions'] = dimensions;
    if (expiryDate != null) data['expiry_date'] = expiryDate!.toIso8601String();
    if (batchNumber != null) data['batch_number'] = batchNumber;
    if (location != null) data['location'] = location;
    return data;
  }
}

/// Stock update request model
class StockUpdate extends ApiRequestModel {
  final int quantity;
  final String adjustmentType;
  final String reason;
  final String? referenceNumber;
  final String updatedBy;

  StockUpdate({
    required this.quantity,
    required this.adjustmentType,
    required this.reason,
    this.referenceNumber,
    required this.updatedBy,
  });

  factory StockUpdate.fromJson(Map<String, dynamic> json) {
    return StockUpdate(
      quantity: json['quantity'] as int,
      adjustmentType: json['adjustment_type'] as String,
      reason: json['reason'] as String,
      referenceNumber: json['reference_number'] as String?,
      updatedBy: json['updated_by'] as String,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'adjustment_type': adjustmentType,
      'reason': reason,
      'reference_number': referenceNumber,
      'updated_by': updatedBy,
    };
  }
}

/// Sale item creation request model
class SaleItemCreate extends ApiRequestModel {
  final String productId;
  final int quantity;
  final double price;

  SaleItemCreate({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory SaleItemCreate.fromJson(Map<String, dynamic> json) {
    return SaleItemCreate(
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}

/// Sale creation request model
class SaleCreate extends ApiRequestModel {
  final String customerName;
  final String? customerPhone;
  final List<SaleItemCreate> items;
  final double discount;
  final String paymentMethod;
  final String? note;
  final String createdBy;

  SaleCreate({
    required this.customerName,
    this.customerPhone,
    required this.items,
    this.discount = 0.0,
    required this.paymentMethod,
    this.note,
    required this.createdBy,
  });

  factory SaleCreate.fromJson(Map<String, dynamic> json) {
    return SaleCreate(
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String?,
      items: (json['items'] as List).map((e) => SaleItemCreate.fromJson(e)).toList(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String,
      note: json['note'] as String?,
      createdBy: json['created_by'] as String,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'items': items.map((e) => e.toJson()).toList(),
      'discount': discount,
      'payment_method': paymentMethod,
      'note': note,
      'created_by': createdBy,
    };
  }
}

/// Sale update request model
class SaleUpdate extends ApiRequestModel {
  final String? customerName;
  final String? customerPhone;
  final List<SaleItemCreate>? items;
  final double? discount;
  final String? paymentMethod;
  final String? note;

  SaleUpdate({
    this.customerName,
    this.customerPhone,
    this.items,
    this.discount,
    this.paymentMethod,
    this.note,
  });

  factory SaleUpdate.fromJson(Map<String, dynamic> json) {
    return SaleUpdate(
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      items: json['items'] != null ? (json['items'] as List).map((e) => SaleItemCreate.fromJson(e)).toList() : null,
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      paymentMethod: json['payment_method'] as String?,
      note: json['note'] as String?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (customerName != null) data['customer_name'] = customerName;
    if (customerPhone != null) data['customer_phone'] = customerPhone;
    if (items != null) data['items'] = items!.map((e) => e.toJson()).toList();
    if (discount != null) data['discount'] = discount;
    if (paymentMethod != null) data['payment_method'] = paymentMethod;
    if (note != null) data['note'] = note;
    return data;
  }
}

/// Return item creation request model
class ReturnItemCreate extends ApiRequestModel {
  final String productId;
  final int quantity;
  final double returnPrice;
  final String reason;

  ReturnItemCreate({
    required this.productId,
    required this.quantity,
    required this.returnPrice,
    required this.reason,
  });

  factory ReturnItemCreate.fromJson(Map<String, dynamic> json) {
    return ReturnItemCreate(
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int,
      returnPrice: (json['return_price'] as num).toDouble(),
      reason: json['reason'] as String,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'return_price': returnPrice,
      'reason': reason,
    };
  }
}

/// Return creation request model
class ReturnCreate extends ApiRequestModel {
  final String originalSaleId;
  final String customerName;
  final String? customerPhone;
  final List<ReturnItemCreate> items;
  final String refundMethod;
  final String reason;
  final String processedBy;
  final String? notes;

  ReturnCreate({
    required this.originalSaleId,
    required this.customerName,
    this.customerPhone,
    required this.items,
    required this.refundMethod,
    required this.reason,
    required this.processedBy,
    this.notes,
  });

  factory ReturnCreate.fromJson(Map<String, dynamic> json) {
    return ReturnCreate(
      originalSaleId: json['original_sale_id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String?,
      items: (json['items'] as List).map((e) => ReturnItemCreate.fromJson(e)).toList(),
      refundMethod: json['refund_method'] as String,
      reason: json['reason'] as String,
      processedBy: json['processed_by'] as String,
      notes: json['notes'] as String?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'original_sale_id': originalSaleId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'items': items.map((e) => e.toJson()).toList(),
      'refund_method': refundMethod,
      'reason': reason,
      'processed_by': processedBy,
      'notes': notes,
    };
  }
}

/// Return update request model
class ReturnUpdate extends ApiRequestModel {
  final String? status;
  final String? processedBy;
  final String? notes;

  ReturnUpdate({
    this.status,
    this.processedBy,
    this.notes,
  });

  factory ReturnUpdate.fromJson(Map<String, dynamic> json) {
    return ReturnUpdate(
      status: json['status'] as String?,
      processedBy: json['processed_by'] as String?,
      notes: json['notes'] as String?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (status != null) data['status'] = status;
    if (processedBy != null) data['processed_by'] = processedBy;
    if (notes != null) data['notes'] = notes;
    return data;
  }
}

/// Insurance claim model
class InsuranceClaim extends ApiRequestModel {
  final String claimNumber;
  final double claimAmount;
  final String status;

  InsuranceClaim({
    required this.claimNumber,
    required this.claimAmount,
    required this.status,
  });

  factory InsuranceClaim.fromJson(Map<String, dynamic> json) {
    return InsuranceClaim(
      claimNumber: json['claim_number'] as String,
      claimAmount: (json['claim_amount'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'claim_number': claimNumber,
      'claim_amount': claimAmount,
      'status': status,
    };
  }
}

/// Damaged product creation request model
class DamagedProductCreate extends ApiRequestModel {
  final String productId;
  final String productName;
  final int quantity;
  final double originalPrice;
  final double estimatedLoss;
  final String damageType;
  final String severity;
  final String description;
  final String location;
  final String discoveredBy;
  final List<String>? images;
  final InsuranceClaim? insuranceClaim;
  final String actionTaken;

  DamagedProductCreate({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.originalPrice,
    required this.estimatedLoss,
    required this.damageType,
    required this.severity,
    required this.description,
    required this.location,
    required this.discoveredBy,
    this.images,
    this.insuranceClaim,
    required this.actionTaken,
  });

  factory DamagedProductCreate.fromJson(Map<String, dynamic> json) {
    return DamagedProductCreate(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      originalPrice: (json['original_price'] as num).toDouble(),
      estimatedLoss: (json['estimated_loss'] as num).toDouble(),
      damageType: json['damage_type'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      discoveredBy: json['discovered_by'] as String,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      insuranceClaim: json['insurance_claim'] != null ? InsuranceClaim.fromJson(json['insurance_claim']) : null,
      actionTaken: json['action_taken'] as String,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'original_price': originalPrice,
      'estimated_loss': estimatedLoss,
      'damage_type': damageType,
      'severity': severity,
      'description': description,
      'location': location,
      'discovered_by': discoveredBy,
      'images': images,
      'insurance_claim': insuranceClaim?.toJson(),
      'action_taken': actionTaken,
    };
  }
}

/// Damaged product update request model
class DamagedProductUpdate extends ApiRequestModel {
  final String? productName;
  final int? quantity;
  final double? originalPrice;
  final double? estimatedLoss;
  final String? damageType;
  final String? severity;
  final String? description;
  final String? location;
  final List<String>? images;
  final InsuranceClaim? insuranceClaim;
  final String? actionTaken;
  final String? status;

  DamagedProductUpdate({
    this.productName,
    this.quantity,
    this.originalPrice,
    this.estimatedLoss,
    this.damageType,
    this.severity,
    this.description,
    this.location,
    this.images,
    this.insuranceClaim,
    this.actionTaken,
    this.status,
  });

  factory DamagedProductUpdate.fromJson(Map<String, dynamic> json) {
    return DamagedProductUpdate(
      productName: json['product_name'] as String?,
      quantity: json['quantity'] as int?,
      originalPrice: json['original_price'] != null ? (json['original_price'] as num).toDouble() : null,
      estimatedLoss: json['estimated_loss'] != null ? (json['estimated_loss'] as num).toDouble() : null,
      damageType: json['damage_type'] as String?,
      severity: json['severity'] as String?,
      description: json['description'] as String?,
      location: json['location'] as String?,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      insuranceClaim: json['insurance_claim'] != null ? InsuranceClaim.fromJson(json['insurance_claim']) : null,
      actionTaken: json['action_taken'] as String?,
      status: json['status'] as String?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (productName != null) data['product_name'] = productName;
    if (quantity != null) data['quantity'] = quantity;
    if (originalPrice != null) data['original_price'] = originalPrice;
    if (estimatedLoss != null) data['estimated_loss'] = estimatedLoss;
    if (damageType != null) data['damage_type'] = damageType;
    if (severity != null) data['severity'] = severity;
    if (description != null) data['description'] = description;
    if (location != null) data['location'] = location;
    if (images != null) data['images'] = images;
    if (insuranceClaim != null) data['insurance_claim'] = insuranceClaim!.toJson();
    if (actionTaken != null) data['action_taken'] = actionTaken;
    if (status != null) data['status'] = status;
    return data;
  }
}

/// Vendor model
class Vendor extends ApiRequestModel {
  final String name;
  final String? phone;
  final String? email;

  Vendor({
    required this.name,
    this.phone,
    this.email,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}

/// Attachment model
class Attachment extends ApiRequestModel {
  final String type;
  final String url;
  final String filename;

  Attachment({
    required this.type,
    required this.url,
    required this.filename,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      type: json['type'] as String,
      url: json['url'] as String,
      filename: json['filename'] as String,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      'filename': filename,
    };
  }
}

/// Recurring pattern model
class RecurringPattern extends ApiRequestModel {
  final String frequency;
  final DateTime nextDueDate;

  RecurringPattern({
    required this.frequency,
    required this.nextDueDate,
  });

  factory RecurringPattern.fromJson(Map<String, dynamic> json) {
    return RecurringPattern(
      frequency: json['frequency'] as String,
      nextDueDate: DateTime.parse(json['next_due_date'] as String),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency,
      'next_due_date': nextDueDate.toIso8601String(),
    };
  }
}

/// Expense creation request model
class ExpenseCreate extends ApiRequestModel {
  final String category;
  final String? subcategory;
  final String title;
  final String? description;
  final double amount;
  final String currency;
  final DateTime date;
  final String paymentMethod;
  final Vendor? vendor;
  final String? receiptNumber;
  final String approvedBy;
  final List<String>? tags;
  final List<Attachment>? attachments;
  final bool isRecurring;
  final RecurringPattern? recurringPattern;
  final String? budgetCategory;
  final String createdBy;

  ExpenseCreate({
    required this.category,
    this.subcategory,
    required this.title,
    this.description,
    required this.amount,
    this.currency = 'TZS',
    required this.date,
    required this.paymentMethod,
    this.vendor,
    this.receiptNumber,
    required this.approvedBy,
    this.tags,
    this.attachments,
    this.isRecurring = false,
    this.recurringPattern,
    this.budgetCategory,
    required this.createdBy,
  });

  factory ExpenseCreate.fromJson(Map<String, dynamic> json) {
    return ExpenseCreate(
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TZS',
      date: DateTime.parse(json['date'] as String),
      paymentMethod: json['payment_method'] as String,
      vendor: json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null,
      receiptNumber: json['receipt_number'] as String?,
      approvedBy: json['approved_by'] as String,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      attachments: json['attachments'] != null ? (json['attachments'] as List).map((e) => Attachment.fromJson(e)).toList() : null,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringPattern: json['recurring_pattern'] != null ? RecurringPattern.fromJson(json['recurring_pattern']) : null,
      budgetCategory: json['budget_category'] as String?,
      createdBy: json['created_by'] as String,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'subcategory': subcategory,
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency,
      'date': date.toIso8601String(),
      'payment_method': paymentMethod,
      'vendor': vendor?.toJson(),
      'receipt_number': receiptNumber,
      'approved_by': approvedBy,
      'tags': tags,
      'attachments': attachments?.map((e) => e.toJson()).toList(),
      'is_recurring': isRecurring,
      'recurring_pattern': recurringPattern?.toJson(),
      'budget_category': budgetCategory,
      'created_by': createdBy,
    };
  }
}

/// Expense update request model
class ExpenseUpdate extends ApiRequestModel {
  final String? category;
  final String? subcategory;
  final String? title;
  final String? description;
  final double? amount;
  final String? currency;
  final DateTime? date;
  final String? paymentMethod;
  final Vendor? vendor;
  final String? receiptNumber;
  final String? approvedBy;
  final List<String>? tags;
  final List<Attachment>? attachments;
  final bool? isRecurring;
  final RecurringPattern? recurringPattern;
  final String? budgetCategory;
  final String? status;

  ExpenseUpdate({
    this.category,
    this.subcategory,
    this.title,
    this.description,
    this.amount,
    this.currency,
    this.date,
    this.paymentMethod,
    this.vendor,
    this.receiptNumber,
    this.approvedBy,
    this.tags,
    this.attachments,
    this.isRecurring,
    this.recurringPattern,
    this.budgetCategory,
    this.status,
  });

  factory ExpenseUpdate.fromJson(Map<String, dynamic> json) {
    return ExpenseUpdate(
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currency: json['currency'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      paymentMethod: json['payment_method'] as String?,
      vendor: json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null,
      receiptNumber: json['receipt_number'] as String?,
      approvedBy: json['approved_by'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      attachments: json['attachments'] != null ? (json['attachments'] as List).map((e) => Attachment.fromJson(e)).toList() : null,
      isRecurring: json['is_recurring'] as bool?,
      recurringPattern: json['recurring_pattern'] != null ? RecurringPattern.fromJson(json['recurring_pattern']) : null,
      budgetCategory: json['budget_category'] as String?,
      status: json['status'] as String?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (category != null) data['category'] = category;
    if (subcategory != null) data['subcategory'] = subcategory;
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (amount != null) data['amount'] = amount;
    if (currency != null) data['currency'] = currency;
    if (date != null) data['date'] = date!.toIso8601String();
    if (paymentMethod != null) data['payment_method'] = paymentMethod;
    if (vendor != null) data['vendor'] = vendor!.toJson();
    if (receiptNumber != null) data['receipt_number'] = receiptNumber;
    if (approvedBy != null) data['approved_by'] = approvedBy;
    if (tags != null) data['tags'] = tags;
    if (attachments != null) data['attachments'] = attachments!.map((e) => e.toJson()).toList();
    if (isRecurring != null) data['is_recurring'] = isRecurring;
    if (recurringPattern != null) data['recurring_pattern'] = recurringPattern!.toJson();
    if (budgetCategory != null) data['budget_category'] = budgetCategory;
    if (status != null) data['status'] = status;
    return data;
  }
}

/// Restore sale request model
class RestoreSaleRequest extends ApiRequestModel {
  final String? restoreReason;

  RestoreSaleRequest({
    this.restoreReason,
  });

  factory RestoreSaleRequest.fromJson(Map<String, dynamic> json) {
    return RestoreSaleRequest(
      restoreReason: json['restore_reason'] as String?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'restore_reason': restoreReason,
    };
  }
}
