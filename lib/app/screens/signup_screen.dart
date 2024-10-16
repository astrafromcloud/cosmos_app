import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SignupScreen extends StatefulWidget {
  final Dio dio;

  const SignupScreen({Key? key, required this.dio}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;

  Future<void> _signupUser() async {
    setState(() => _isLoading = true);

    try {
      final response = await widget.dio.post(
        '/register',
        data: {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'phone_number': _phoneController.text,
          'gender': _selectedGender,
          'birth_date': _birthDateController.text,
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
        _handleSuccessfulSignup();
      } else {
        _handleSignupError('Signup failed: ${response.statusCode} ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _handleSignupError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleSuccessfulSignup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signup successful!')),
    );
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _handleSignupError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleDioError(DioException e) {
    print('Dio error!');
    print('STATUS: ${e.response?.statusCode}');
    print('DATA: ${e.response?.data}');
    print('HEADERS: ${e.response?.headers}');
    _handleSignupError('Network error occurred. Please try again.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildTextField(_firstNameController, 'First Name'),
              const SizedBox(height: 16),
              _buildTextField(_lastNameController, 'Last Name'),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Phone Number', TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(_birthDateController, 'Birth Date (YYYY-MM-DD)', TextInputType.datetime),
              const SizedBox(height: 16),
              _buildGenderDropdown(),
              const SizedBox(height: 16),
              _buildTextField(_passwordController, 'Password', TextInputType.visiblePassword, true),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ElevatedButton(
                onPressed: _signupUser,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFF7281C6), backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType? keyboardType, bool obscure = false]) {
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

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      items: ['Male', 'Female'].map((gender) {
        return DropdownMenuItem(
          value: gender.toLowerCase(),
          child: Text(gender),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Gender',
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
      dropdownColor: Color(0xFF7281C6),
      style: TextStyle(color: Colors.white),
    );
  }
}