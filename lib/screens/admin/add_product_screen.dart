import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _imgpathController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _variantController = TextEditingController();
  final _quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _variants = [];

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Product Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a product name';
                    return null;
                  },
                ),
                // Image Path
                TextFormField(
                  controller: _imgpathController,
                  decoration: const InputDecoration(labelText: 'Image Url'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter image path';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter description';
                    return null;
                  },
                ),
                // Price
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a price';
                    if (double.tryParse(value) == null) return 'Enter a valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Add Variant Section
                const Text('Add Variants', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _variantController,
                  decoration: const InputDecoration(labelText: 'Variant Name'),
                ),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (_variantController.text.isNotEmpty && _quantityController.text.isNotEmpty) {
                      setState(() {
                        _variants.add({
                          'name': _variantController.text,
                          'quantity': int.parse(_quantityController.text),
                        });
                        _variantController.clear();
                        _quantityController.clear();
                      });
                    }
                  },
                  child: const Text('Add Variant',style: TextStyle(color: Colors.black),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Button background color
                    foregroundColor: Colors.black, // Text color
                  ),

                ),

                // List of Added Variants
                if (_variants.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Variants:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _variants.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text('${_variants[index]['name']} - ${_variants[index]['quantity']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _variants.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 20),

                // Save Product Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _variants.isNotEmpty) {
                      final Map<String, int> variantMap = {
                        for (var variant in _variants) variant['name']: variant['quantity']
                      };

                      await productProvider.addProduct(
                        Product(
                          id: '',
                          name: _nameController.text,
                          imgpath: _imgpathController.text,
                          description: _descriptionController.text,
                          price: double.parse(_priceController.text),
                          variants: variantMap,
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product added successfully!')),
                      );

                      Navigator.pop(context);
                    } else if (_variants.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add at least one variant')),
                      );
                    }
                  },style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Button background color
                  foregroundColor: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                  child: const Text('Save Product',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
