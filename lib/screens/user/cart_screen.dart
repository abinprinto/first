import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first/screens/user/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(cartProvider.userId)
            .collection('cart')
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.docs.isEmpty) {
            return const Center(child: Text('Cart is empty', style: TextStyle(color: Colors.black)));
          }

          final cartItems = snapshot.data.docs;

          // Calculate total amount
          double totalAmount = cartItems.fold(
              0.0, (sum, item) => sum + (item['price'] * item['quantity']));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      color: Colors.white, // Set the card color to white
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      elevation: 5, // Add elevation to create shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0), // Rounded corners
                      ),
                      child: ListTile(
                        title: Text(
                          item['name'],
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          'Variant: ${item['variant']}\nPrice: AED ${item['price']}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.black),
                              onPressed: () {
                                if (item['quantity'] > 1) {
                                  cartProvider.updateQuantity(
                                    item.id.split('_').first,
                                    item['variant'],
                                    item['quantity'] - 1,
                                  );
                                }
                              },
                            ),
                            Text(
                              '${item['quantity']}',
                              style: const TextStyle(color: Colors.black),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.black),
                              onPressed: () {
                                cartProvider.updateQuantity(
                                  item.id.split('_').first,
                                  item['variant'],
                                  item['quantity'] + 1,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Total Amount: AED ${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(cartProvider: cartProvider),
                          ),
                        );
                      },
                      child: const Text('Order Now', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}
