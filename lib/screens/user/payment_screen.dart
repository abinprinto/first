import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';

class PaymentScreen extends StatefulWidget {
  final CartProvider cartProvider;

  const PaymentScreen({Key? key, required this.cartProvider}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = "Credit Card";

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController upiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeTotalSum();
  }

  void _initializeTotalSum() async {
    await widget.cartProvider.totalsum();
    setState(() {
      int totalPrice = widget.cartProvider.Tsum;
    });
  }


  @override
  Widget build(BuildContext context) {

    int totalPrice = widget.cartProvider.Tsum;// Fetch actual price

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Payment'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Makes the screen scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentCard(),
              const SizedBox(height: 20),
              _buildOrderSummary(totalPrice),
              const SizedBox(height: 20),
              _buildPaymentButton(totalPrice),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildPaymentCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionTitle('Choose Payment Method'),
            _buildPaymentOptions(),
            const SizedBox(height: 10),
            if (selectedPaymentMethod == "Credit Card") _buildCardPaymentForm(),
            if (selectedPaymentMethod == "Tabby") _buildTabby(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      children: [
        _buildRadioTile("Credit Card", Icons.credit_card),
        _buildRadioTile("Tabby", Icons.percent_outlined),
        _buildRadioTile("Net Banking", Icons.payment),
        _buildRadioTile("Cash on Delivery (COD)", Icons.money),
      ],
    );
  }

  Widget _buildRadioTile(String title, IconData icon) {
    return RadioListTile(
      value: title,
      groupValue: selectedPaymentMethod,
      onChanged: (value) {
        setState(() {
          selectedPaymentMethod = value.toString();
        });
      },
      title: Text(title, style: const TextStyle(fontSize: 16)),
      secondary: Icon(icon, color: Colors.black),
      activeColor: Colors.black,
    );
  }

  Widget _buildCardPaymentForm() {
    return _buildFormContainer(
      title: "Card Details",
      children: [
        _buildTextField(controller: cardNumberController, label: "Card Number", icon: Icons.credit_card),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTextField(controller: expiryDateController, label: "Expiry Date (MM/YY)", icon: Icons.date_range),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(controller: cvvController, label: "CVV", icon: Icons.lock, obscure: true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabby() {
    int totalPrice = widget.cartProvider.Tsum; // Fetch actual price
    double tabbyAmount = totalPrice / 4; // Calculate 1/4th of total price

    return _buildFormContainer(
      title: "Tabby Payment",
      children: [
        Text(
          "AED ${tabbyAmount.toStringAsFixed(2)} X4",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildFormContainer({required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: obscure ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildOrderSummary(int totalPrice) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              'AED  ${totalPrice.toStringAsFixed(2)}', // Fetch actual price dynamically
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(int totalPrice) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (selectedPaymentMethod == "Cash on Delivery (COD)") {
            await widget.cartProvider.checkout();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order placed successfully!')),
            );
            Navigator.pop(context);
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Processing Payment'),
                content: const Text('Please wait while we process your payment...'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                       widget.cartProvider.checkout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order placed successfully!')),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(selectedPaymentMethod == "Cash on Delivery (COD)"
            ? 'Confirm Order'
            : 'Make Payment', style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
