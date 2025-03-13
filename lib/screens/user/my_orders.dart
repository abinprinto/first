import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyOrders extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please log in to see your orders.', style: TextStyle(color: Colors.black))),
        backgroundColor: Colors.white,
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('My Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').doc(user.uid).collection('orders').snapshots(),
        builder: (context, ordersSnapshot) {
          if (ordersSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)));
          }

          final orderDocs = ordersSnapshot.data?.docs ?? [];

          if (orderDocs.isEmpty) {
            return Center(child: Text('No orders found.', style: TextStyle(color: Colors.black)));
          }

          return ListView.builder(
            itemCount: orderDocs.length,
            itemBuilder: (context, orderIndex) {
              final orderDoc = orderDocs[orderIndex];
              final orderData = orderDoc.data() as Map<String, dynamic>;
              final items = (orderData['items'] as List<dynamic>?) ?? [];
              final date = (orderData['date'] as Timestamp?)?.toDate() ?? DateTime.now();
              final formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(date);

              double totalAmount = 0;
              items.forEach((item) {
                totalAmount += (item['price'] as num) * (item['quantity'] as num);
              });

              return Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text(
                    'Ordered On: $formattedDate',
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Left-align children
                      children: [
                        Text(
                          'Total: AED $totalAmount',
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          "Order placed successfully.",
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.green),
                        ),
                      ],
                    ),
                  ),

                  children: items.map((item) {
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      title: Text('${item['name']}', style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Variant: ${item['variant'] ?? 'Default'}',
                        style: TextStyle(color: Colors.black54,fontSize: 14),
                      ),
                      trailing: Text(
                        'AED ${item['price']} x ${item['quantity']} = AED ${(item['price'] as num) * (item['quantity'] as num)}',
                        style: TextStyle(color: Colors.black54,fontSize: 12),
                      ),
                    );
                  }).toList(),

                ),
              );
            },
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}
