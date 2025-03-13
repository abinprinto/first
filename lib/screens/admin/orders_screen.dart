import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, usersSnapshot) {
          if (usersSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)));
          }

          final userDocs = usersSnapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              final userDoc = userDocs[index];
              final userId = userDoc.id;

              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(userId)
                    .collection('orders')
                    .snapshots(),
                builder: (context, ordersSnapshot) {
                  if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)));
                  }

                  final orderDocs = ordersSnapshot.data?.docs ?? [];

                  if (orderDocs.isEmpty) {
                    return SizedBox.shrink(); // No orders for this user
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'User: ${userDoc['name']} (${userDoc['email']})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
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
                              margin: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              elevation: 4,
                              child: ExpansionTile(
                                title: Text(
                                  'Order Date: $formattedDate',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Total: ₹$totalAmount',
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                children: items.map((item) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: Text(
                                      '${item['name']}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    subtitle: Text(
                                      'Variant: ${item['variants'] ?? 'Default'}',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    trailing: Text(
                                      '₹${item['price']} x ${item['quantity']} = ₹${(item['price'] as num) * (item['quantity'] as num)}',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
