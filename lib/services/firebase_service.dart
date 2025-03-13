import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add({
      'name': product.name,
      'price': product.price,
      'variants': product.variants,
    });
  }

  Future<void> updateProductQuantity(String productId, Map<String, int> variants) async {
    await _firestore.collection('products').doc(productId).update({
      'variants': variants,
    });
  }
}