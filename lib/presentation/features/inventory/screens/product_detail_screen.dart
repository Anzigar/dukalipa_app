import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Detail')),
      body: Center(child: Text('Product ID: $productId')),
    );
  }
}
