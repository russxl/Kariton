import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Kariton/api/api.dart';
import 'community_login_screen.dart'; // Adjust the path if necessary

class SignUpScreen extends StatefulWidget {
  final String userType;
  final Map userData;

  SignUpScreen({Key? key, required this.userData, required this.userType}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;
  bool _acceptedTerms = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedBarangay;
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _barangayError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;

  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isObscurePassword = !_isObscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isObscureConfirmPassword = !_isObscureConfirmPassword;
    });
  }

  bool _isValidPhoneNumber(String phone) {
    final RegExp phoneRegExp = RegExp(r'^(?:\+63|0)\d{10}$');
    return phoneRegExp.hasMatch(phone);
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\W).{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Registering..."),
            ],
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    Navigator.pop(context);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Successful'),
          content: Text('You have successfully registered. You can now log in.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Failed'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Privacy Policy"),
          content: SingleChildScrollView(
          child: Text(
  "Privacy Policy\n\n"
  "Effective Date: October 27, 2024\n\n"
  "KARITON: A Mobile and Web-Based Solution for Recycling in a Circular Economy\n\n"
  "Welcome to KARITON! Your privacy is of utmost importance to us. This Privacy Policy outlines how we handle your personal data, your rights, and our commitment to safeguarding your information.\n\n"
  
  "1. About this Policy\n\n"
  "This Privacy Policy explains how KARITON collects, uses, and protects your personal data when you use our mobile and web-based recycling platform. Our goal is to provide you with a secure and transparent experience. By using KARITON, you agree to the collection and use of your data as described in this policy.\n\n"
  
  "2. Your Personal Data Rights and Controls\n\n"
  "At KARITON, we empower you to manage your personal data. You have the following rights:\n"
  "• Right of Access: You can request a copy of the personal data we hold about you.\n"
  "• Right to Rectification: You may request corrections to any incomplete or inaccurate personal data we hold.\n"
  "• Right to Erasure: You can request the deletion of your personal data, subject to certain conditions.\n"
  "• Right to Restrict Processing: You may request the limitation of the processing of your personal data in specific cases.\n"
  "• Right to Data Portability: You can request a copy of your data in a machine-readable format, where technically feasible.\n"
  "• Right to Object: You may object to the processing of your data based on legitimate interests.\n\n"
  "To exercise any of these rights, please refer to the contact details in Section 7.\n\n"
  
  "3. Personal Data We Collect About You\n\n"
  "We collect and process the following types of personal data:\n"
  "• Contact Information: Name, email address, and phone number.\n"
  "• Location Data: Information about your general location to facilitate local recycling services and pickups.\n"
  "• Account Information: Email, password, and contact number associated with your KARITON account.\n"
  "• Transaction Data: Details of recycling transactions, such as items recycled, quantities, and points or rewards accumulated.\n"
  "• Device Information: Information about the device you use to access KARITON, such as IP address, operating system, and browser type.\n\n"
  
  "KARITON may also collect other data as necessary to improve our service. We only collect data that is relevant to our platform and necessary to serve you.\n\n"
  
  "4. Our Purpose for Using Your Personal Data\n\n"
  "We use your personal data to provide and improve the KARITON platform. Specifically, we process your data for the following purposes:\n"
  "• Account Management: To create, manage, and maintain your KARITON account.\n"
  "• Service Provision: To enable recycling services, pickups, and rewards.\n"
  "• User Communication: To send you important notifications, updates, and responses to inquiries.\n"
  "• Analytics: To improve user experience through analysis of user behavior and platform performance.\n"
  "• Security: To safeguard your account and prevent unauthorized access or misuse.\n\n"
  
  "Your data will not be used for unrelated purposes without your consent.\n\n"
  
  "5. Keeping Your Personal Data Safe\n\n"
  "We are committed to maintaining the security and confidentiality of your data. We use industry-standard security measures, including encryption, firewalls, and secure servers, to protect your information from unauthorized access, disclosure, or destruction. However, no method of transmission over the internet is completely secure, and we cannot guarantee absolute security.\n\n"
  
  "6. Changes to This Policy\n\n"
  "We may update this Privacy Policy to reflect changes in our practices or for other operational, legal, or regulatory reasons. Any updates will be posted on this page with an updated effective date. We encourage you to review this policy periodically to stay informed of how we protect your data.\n\n"
  
  "7. How to Contact Us\n\n"
  "If you have questions, concerns, or wish to exercise your rights regarding your personal data, please contact us at:\n"
  "Email: karitonscraps.ph@gmail.com\n"
  "Phone: 0927-662-8981\n\n"
  
  "Thank you for trusting KARITON with your personal data. We are dedicated to protecting your privacy and providing a safe and rewarding experience in recycling."
),

          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _registerUser() {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String phone = _phoneController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    setState(() {
      _nameError = name.isEmpty ? 'Name is required' : null;
      _emailError = email.isEmpty
          ? 'Email is required'
          : !_isValidEmail(email)
              ? 'Enter a valid email'
              : null;
      _phoneError = phone.isEmpty
          ? 'Phone number is required'
          : !_isValidPhoneNumber(phone)
              ? 'Enter a valid Philippine phone number'
              : null;
      _barangayError = _selectedBarangay == null ? 'Please select a barangay' : null;
      _passwordError = password.isEmpty
          ? 'Password is required'
          : !_isValidPassword(password)
              ? 'Password must be at least 8 characters, have 1 uppercase letter, and 1 special character'
              : null;
      _confirmPasswordError = confirmPassword.isEmpty
          ? 'Please confirm your password'
          : confirmPassword != password
              ? 'Passwords do not match'
              : null;
      _termsError = !_acceptedTerms ? 'You must accept the terms and conditions' : null;
    });

    if (_nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _barangayError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _termsError == null) {
      final Map<String, String> data = {
        "name": name,
        "email": email,
        "phone": phone,
        "barangay": _selectedBarangay ?? '',
        "password": password,
        "confirmPassword": confirmPassword,
        "userType": widget.userType
      };

      _showLoadingDialog();

      Api.registrationCommunity(context, data).then((success) {
        _hideLoadingDialog();
        if (success) {
          _showSuccessDialog();
        } else {
          _showErrorDialog("Registration failed. Please try again.");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> _barangays = List<String>.from(
      widget.userData['barangay'].map((barangay) => barangay['bName']),
    );

    InputDecoration _inputDecoration({String? hintText, bool isValid = true}) {
      return InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: isValid ? Color(0xFF40A858) : Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isValid ? Color(0xFF40A858) : Colors.red),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Full Name"),
            SizedBox(height: 10.0),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration(hintText: "Enter your full name", isValid: _nameError == null),
            ),
            if (_nameError != null) Text(_nameError!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10.0),

            Text("Email"),
            SizedBox(height: 10.0),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration(hintText: "Enter your email", isValid: _emailError == null),
            ),
            if (_emailError != null) Text(_emailError!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10.0),

            Text("Phone Number"),
            SizedBox(height: 10.0),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration(hintText: "Enter your phone number", isValid: _phoneError == null),
            ),
            if (_phoneError != null) Text(_phoneError!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10.0),

            Text("Barangay"),
            SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              value: _selectedBarangay,
              decoration: _inputDecoration(isValid: _barangayError == null),
              items: _barangays.map((barangay) {
                return DropdownMenuItem<String>(
                  value: barangay,
                  child: Text(barangay),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBarangay = value;
                });
              },
            ),
            if (_barangayError != null) Text(_barangayError!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10.0),

            Text("Password"),
            SizedBox(height: 10.0),
            TextField(
              controller: _passwordController,
              obscureText: _isObscurePassword,
              decoration: _inputDecoration(hintText: "Enter your password", isValid: _passwordError == null).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_isObscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
            ),
            if (_passwordError != null) Text(_passwordError!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10.0),

            Text("Confirm Password"),
            SizedBox(height: 10.0),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _isObscureConfirmPassword,
              decoration: _inputDecoration(hintText: "Confirm your password", isValid: _confirmPasswordError == null).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_isObscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: _toggleConfirmPasswordVisibility,
                ),
              ),
            ),
            if (_confirmPasswordError != null) Text(_confirmPasswordError!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10.0),

            Row(
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptedTerms = value!;
                    });
                  },
                ),
                GestureDetector(
                  onTap: _showTermsDialog,
                  child: Text(
                    "I agree to the Terms and Conditions",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            if (_termsError != null) Text(_termsError!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20.0),

            Center(
              child: ElevatedButton(
                onPressed: _registerUser,
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF40A858),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
