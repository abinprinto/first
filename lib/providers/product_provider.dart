import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _products = [];

  List<Product> get products => _products;

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      _products = snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? 'Unnamed Product',
          imgpath: data['imgpath'] ?? 'No path',
          price: (data['price'] ?? 0).toDouble(),
          description: data['description'] ?? 'No description',
          variants: Map<String, int>.from(data['variants'] ?? {}),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add({
      'name': product.name,
      'imgpath':product.imgpath,
      'price': product.price,
      'variants': product.variants,
      'description': product.description,
    });
  }

  Future<void> updateProductQuantity(String productId, Map<String, int> updatedVariants) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'variants': updatedVariants,
      });
      await fetchProducts();
    } catch (e) {
      print('Error updating product quantity: $e');
    }
  }
}