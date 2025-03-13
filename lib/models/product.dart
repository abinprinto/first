class Product {
  final String id;
  final String name;
  final double price;
  final Map<String, int> variants;
  final String imgpath;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.variants,
    required this.imgpath,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'variants': variants,
      'imgpath': imgpath,
      'description': description,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      imgpath: map['imgpath'] ?? '',
      variants: Map<String, int>.from(map['variants'] ?? {}),
      description: map['description'] ?? '',

    );
  }
}