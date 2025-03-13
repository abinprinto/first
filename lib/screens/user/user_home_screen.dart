import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../auth/login_screen.dart';
import '../profile_page.dart';
import 'my_orders.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';

class UserHomeScreen extends StatefulWidget {
  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    UserHomeScreenBody(),
    CartScreen(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override

  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text(
          'Cartify',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.black),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MyOrders()),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              bool? logoutConfirmed = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Log out?'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text(
                          'Log Out',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (logoutConfirmed == true) {
                await authProvider.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

}

class UserHomeScreenBody extends StatefulWidget {
  @override
  _UserHomeScreenBodyState createState() => _UserHomeScreenBodyState();
}

class _UserHomeScreenBodyState extends State<UserHomeScreenBody> {
  TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override

  void initState() {
    super.initState();
    Future.microtask(() {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.fetchProducts().then((_) {
        setState(() {
          _filteredProducts = productProvider.products;
        });
      });
    });
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    setState(() {
      _filteredProducts =
          productProvider.products.where((product) {
            return product.name.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override

  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fixed Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search Products...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {}); // Update UI when text changes
            },
          ),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    enlargeCenterPage: true,
                  ),
                  items:
                      [
                            'assets/ramdan.jpg',
                            'assets/tabby.png',
                            'assets/friday.jpg',
                          ]
                          .map(
                            (bannerPath) => ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                bannerPath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          )
                          .toList(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  child: SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              final productProvider =
                                  Provider.of<ProductProvider>(
                                    context,
                                    listen: false,
                                  );
                              _filteredProducts =
                                  productProvider.products
                                      .where(
                                        (product) =>
                                            product.name == 'Phone' ||
                                                product.name == 'Iphone 16 Pro'||
                                                product.name == 'Smart Phone',
                                      ) // Assuming you have a 'category' property in your product model
                                      .toList();
                            });
                          },
                          child: _buildCategoryItem(
                            Icons.phone_android,
                            "Phone",
                          ),
                        ),
                        const SizedBox(width: 20), // Add spacing between items
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              final productProvider =
                                  Provider.of<ProductProvider>(
                                    context,
                                    listen: false,
                                  );
                              _filteredProducts =
                                  productProvider.products
                                      .where(
                                        (product) => product.name == 'Laptop',
                                      ) // Assuming you have a 'category' property in your product model
                                      .toList();
                            });
                          },
                          child: _buildCategoryItem(Icons.laptop, "Laptop"),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              final productProvider =
                                  Provider.of<ProductProvider>(
                                    context,
                                    listen: false,
                                  );
                              _filteredProducts =
                                  productProvider.products
                                      .where(
                                        (product) =>
                                            product.name == 'Watch' ||
                                            product.name == 'Smart watch' ||
                                            product.name == 'watch' ||
                                            product.name == 'Smart watch',
                                      ) // Assuming you have a 'category' property in your product model
                                      .toList();
                            });
                          },
                          child: _buildCategoryItem(Icons.watch, "Watch"),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              final productProvider =
                                  Provider.of<ProductProvider>(
                                    context,
                                    listen: false,
                                  );
                              _filteredProducts =
                                  productProvider.products
                                      .where(
                                        (product) => product.name == 'Earbuds',
                                      ) // Assuming you have a 'category' property in your product model
                                      .toList();
                            });
                          },
                          child: _buildCategoryItem(
                            Icons.headphones,
                            "Earbuds",
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              final productProvider =
                                  Provider.of<ProductProvider>(
                                    context,
                                    listen: false,
                                  );
                              _filteredProducts =
                                  productProvider.products
                                      .where(
                                        (product) =>
                                            product.name == 'TV' ||
                                            product.name == 'Tv' ||
                                            product.name == ' LEDTv',
                                      ) // Assuming you have a 'category' property in your product model
                                      .toList();
                            });
                          },
                          child: _buildCategoryItem(Icons.tv, "TV"),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              final productProvider =
                                  Provider.of<ProductProvider>(
                                    context,
                                    listen: false,
                                  );
                              _filteredProducts =
                                  productProvider.products
                                      .where(
                                        (product) => product.name == 'Camera',
                                      ) // Assuming you have a 'category' property in your product model
                                      .toList();
                            });
                          },
                          child: _buildCategoryItem(Icons.camera_alt, "Camera"),
                        ),
                      ],
                    ),
                  ),
                ),
                _filteredProducts.isEmpty
                    ? Center(child: Text("No products found"))
                    : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      shrinkWrap:
                          true, // ✅ Makes GridView adapt to content height
                      physics:
                          NeverScrollableScrollPhysics(), // ✅ Prevents nested scrolling
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product, context);
                      },
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(product, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                getDirectImageUrl(product.imgpath), // Convert Google Drive link
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 120),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'AED ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.green),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                product.description,
                maxLines: 2, // Limit to 2 lines
                overflow:
                    TextOverflow.ellipsis, // Show "..." when text overflows
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getDirectImageUrl(String driveUrl) {
    final regex = RegExp(r'd/([a-zA-Z0-9_-]+)/');
    final match = regex.firstMatch(driveUrl);
    return match != null
        ? 'https://drive.google.com/uc?export=view&id=${match.group(1)}'
        : driveUrl;
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.black,
          radius: 25,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

}

