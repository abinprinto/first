import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  Future<void> addToCart(Product product, int quantity, String variant) async {
    if (userId == null) return;

    final cartDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc('${product.id}_$variant'); // Unique ID for variant

    final docSnapshot = await cartDoc.get();

    if (docSnapshot.exists) {
      await cartDoc.update({
        'quantity': (docSnapshot['quantity'] as int) + quantity,
      });
    } else {
      await cartDoc.set({
        'name': product.name,
        'price': product.price,
        'imgpath': product.imgpath,
        'quantity': quantity,
        'variant': variant,
      });
    }

    notifyListeners();
  }

  Future<void> removeFromCart(String productId, String variant) async {
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc('${productId}_$variant')
        .delete();

    notifyListeners();
  }

  Future<void> updateQuantity(
    String productId,
    String variant,
    int quantity,
  ) async {
    if (userId == null) return;

    final cartDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc('${productId}_$variant');

    if (quantity > 0) {
      await cartDoc.update({'quantity': quantity});
    } else {
      await removeFromCart(productId, variant); // Remove if quantity is zero
    }

    notifyListeners();
  }

  int Tsum = 0;
  Future<void> totalsum() async {
    if (userId == null) return;

    final cartCollection = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart');
    final cartDocs = await cartCollection.get();
    if (cartDocs.docs.isEmpty) return;

    final orderData = cartDocs.docs.map((doc) => doc.data()).toList();
    Tsum = orderData.fold<int>(0, (sum, item) {
      final price = (item['price'] ?? 0) as num; // Ensure price is num
      final quantity = (item['quantity'] ?? 0) as int; // Ensure quantity is int
      return sum +
          (price * quantity).toInt(); // Convert to int after multiplication
    });
  }

  Future<void> checkout() async {
    if (userId == null) return;

    final cartCollection = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart');

    final orderCollection = _firestore
        .collection('users')
        .doc(userId)
        .collection('orders');

    final cartDocs = await cartCollection.get();
    if (cartDocs.docs.isEmpty) return;

    final orderData = cartDocs.docs.map((doc) => doc.data()).toList();
    final totalAmount = orderData.fold<int>(0, (sum, item) {
      final price = (item['price'] ?? 0) as num;
      final quantity = (item['quantity'] ?? 0) as int;
      return sum + (price * quantity).toInt();
    });
    await orderCollection.add({
      'items': orderData,
      'date': FieldValue.serverTimestamp(),
      'totalAmount': totalAmount,
    });

    for (var doc in cartDocs.docs) {
      final item = doc.data();
      final productId = doc.id.split('_')[0];
      final variant = item['variant'] as String;
      final quantity = item['quantity'] as int;
      final productDoc = _firestore.collection('products').doc(productId);
      final productSnapshot = await productDoc.get();

      if (productSnapshot.exists) {
        final productData = productSnapshot.data() as Map<String, dynamic>;
        final variants = Map<String, dynamic>.from(
          productData['variants'] ?? {},
        );

        if (variants.containsKey(variant)) {
          final currentStock = variants[variant] as int;

          if (currentStock >= quantity) {
            variants[variant] = currentStock - quantity;

            await productDoc.update({'variants': variants});
          } else {
            print(
              "Insufficient stock for variant $variant of product $productId",
            );
          }
        }
      }
    }
    for (var doc in cartDocs.docs) {
      await doc.reference.delete();
    }
    notifyListeners();
  }
}
