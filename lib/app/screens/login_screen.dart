import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final Dio dio;

  const LoginScreen({Key? key, required this.dio}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginUser() async {
    setState(() => _isLoading = true);

    try {
      final response = await widget.dio.post(
        '/login',
        data: {
          'phone_number': _phoneController.text,
          'password': _passwordController.text,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _handleSuccessfulLogin();
      } else {
        _handleLoginError('Login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _handleLoginError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSuccessfulLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login successful!')),
    );
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _handleLoginError(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleDioError(DioException e) {
    print('Dio error!');
    print('STATUS: ${e.response?.statusCode}');
    print('DATA: ${e.response?.data}');
    print('HEADERS: ${e.response?.headers}');
    _handleLoginError('Network error occurred. Please try again.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7281C6),
        elevation: 0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: [0.8, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7281C6), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                scale: 5,
              ),
              _buildTextField(
                  _phoneController, 'Phone Number', TextInputType.phone),
              const SizedBox(height: 20),
              _buildTextField(_passwordController, 'Password',
                  TextInputType.visiblePassword, true),
              const SizedBox(height: 32),
              const SizedBox(height: 20),
              _isLoading
                  ? AbsorbPointer(
                    child: ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            const Text('Login', style: TextStyle(fontSize: 18)),
                      ),
                  )
                  : ElevatedButton(
                      onPressed: _loginUser,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xFF7281C6),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          const Text('Login', style: TextStyle(fontSize: 18)),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text(
                  'Don' 't have an account? Sign up',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType? keyboardType, bool obscure = false]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white60),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      obscureText: obscure,
    );
  }
}
