import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_cart,
                color: Color.fromARGB(228, 29, 62, 41),
                size: 60,
              ),
              SizedBox(height: 5),
              Text(
                'Cartify',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  color: Color.fromARGB(228, 29, 62, 41),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Login to continue',
                style: GoogleFonts.poppins(color: Colors.black54),
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  await authProvider.login(
                    _emailController.text,
                    _passwordController.text,
                  );
                  setState(() => _isLoading = false);

                  if (authProvider.user != null) {
                    if (authProvider.user!.role == 'admin') {
                      authProvider.name = authProvider.user!.name;
                      authProvider.email = authProvider.user!.email;
                      authProvider.role = authProvider.user!.role;
                      authProvider.photoUrl = authProvider.user!.photoUrl;
                      Navigator.pushReplacementNamed(context, '/admin-home');
                    } else {
                      authProvider.name = authProvider.user!.name;
                      authProvider.email = authProvider.user!.email;
                      authProvider.role = authProvider.user!.role;
                      authProvider.photoUrl = authProvider.user!.photoUrl;
                      Navigator.pushReplacementNamed(context, '/user-home');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(228, 29, 62, 41),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 35,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              SizedBox(height: 20),
              Divider(color: Colors.grey.withOpacity(0.5)),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Image.asset('assets/google.png', height: 24, width: 24),
                label: Text('Sign in with Google'),
                onPressed: () async {
                  setState(() => _isLoading = true);
                  await authProvider.googleLogin();
                  setState(() => _isLoading = false);

                  if (authProvider.user != null) {
                    authProvider.name = authProvider.user!.name;
                    authProvider.email = authProvider.user!.email;
                    authProvider.role = authProvider.user!.role;
                    authProvider.photoUrl = authProvider.user!.photoUrl;

                    if (authProvider.user!.role == 'admin') {
                      Navigator.pushReplacementNamed(context, '/admin-home');
                    } else {
                      authProvider.name = authProvider.user!.name;
                      authProvider.email = authProvider.user!.email;
                      authProvider.role = authProvider.user!.role;
                      authProvider.photoUrl = authProvider.user!.photoUrl;
                      print('abcd');
                      print(authProvider.user!.name);
                      print(authProvider.user!.email);
                      Navigator.pushReplacementNamed(context, '/user-home');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  elevation: 0,
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text(
                  'Register',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    // color: Color(0xFF4A00E0),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.poppins(color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
