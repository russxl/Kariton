import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Kariton/api/api.dart';
import 'package:Kariton/community_login_screen.dart'; // Assuming this is correct
import 'package:Kariton/barangay_register_screen.dart'; // Assuming this is correct
import 'dart:io';

class RegisterBarangayAdd extends StatelessWidget {
  final String userType;
  final String captainName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final String barangayName;

  RegisterBarangayAdd({
    required this.userType,
    required this.captainName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    required this.barangayName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BarangayRegisterScreen(userType: userType),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 30.0),
        child: RegisterBarangayAddForm(
          userType: userType,
          captainName: captainName,
          email: email,
          phone: phone,
          password: password,
          confirmPassword: confirmPassword,
          barangayName: barangayName,
        ),
      ),
    );
  }
}

class RegisterBarangayAddForm extends StatefulWidget {
  final String userType;
  final String captainName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final String barangayName;

  RegisterBarangayAddForm({
    required this.userType,
    required this.captainName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    required this.barangayName,
  });

  @override
  _RegisterBarangayAddFormState createState() => _RegisterBarangayAddFormState();
}

class _RegisterBarangayAddFormState extends State<RegisterBarangayAddForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  bool _isTermsAccepted = false;
  XFile? _barangayHallImage;
  XFile? _validIdImage;
  XFile? _barangayPermitImage;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Text(
            "Additional Information",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 30),
          _buildLabelWithAsterisk('Address'),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: 'Enter your barangay address',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildLabelWithAsterisk('Provide a photo of your Barangay Hall'),
          GestureDetector(
            onTap: () => _pickImage(isBarangayHallImage: true),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _barangayHallImage == null
                  ? Center(
                      child: Text(
                        'Upload Barangay Hall photo',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    )
                  : Image.file(File(_barangayHallImage!.path)),
            ),
          ),
          SizedBox(height: 20),
          _buildLabelWithAsterisk('Upload a Valid ID'),
        
          GestureDetector(
            onTap: () => _pickImage(isBarangayHallImage: false, isBarangayPermit: true),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _barangayPermitImage == null
                  ? Center(
                      child: Text(
                        'Upload Valid Id of Representative',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    )
                  : Image.file(File(_barangayPermitImage!.path)),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: _isTermsAccepted,
                onChanged: (value) {
                  setState(() {
                    _isTermsAccepted = value!;
                  });
                },
              ),
              GestureDetector(
                onTap: _showTermsAndConditionsDialog,
                child: Text(
                  'I agree to the Terms and Conditions',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (!_isTermsAccepted) {
                    _showAlertDialog(context, 'Terms and Conditions', 'Please accept the Terms and Conditions to continue.');
                    return;
                  }
                  if (_barangayHallImage == null || _validIdImage == null || _barangayPermitImage == null) {
                    _showMissingImageAlert(context);
                  } else if (_addressController.text.isEmpty) {
                    _showMissingAddressAlert(context);
                  } else {
                    var data = {
                      'userType': widget.userType,
                      'password': widget.password,
                      'email': widget.email,
                      'confirmPassword': widget.confirmPassword,
                      'phone': widget.phone,
                      'address': _addressController.text,
                      'captainName': widget.captainName,
                      'barangayName': widget.barangayName,
                    };

                    File? barangayHallImageFile;
                    String? validIdImageBase64;
                    String? barangayPermitImageBase64;

                    if (_barangayHallImage != null) {
                      barangayHallImageFile = File(_barangayHallImage!.path);
                      int barangayHallImageSize = await barangayHallImageFile.length();
                      if (barangayHallImageSize > 3 * 1024 * 1024) {
                        _showImageSizeAlert(context, 'Barangay Hall Photo');
                        return;
                      }
                      data['barangayHallImage'] = base64Encode(await barangayHallImageFile.readAsBytes());
                    }
                    if (_validIdImage != null) {
                      File validIdImageFile = File(_validIdImage!.path);
                      int validIdImageSize = await validIdImageFile.length();
                      if (validIdImageSize > 3 * 1024 * 1024) {
                        _showImageSizeAlert(context, 'Valid ID');
                        return;
                      }
                      validIdImageBase64 = base64Encode(await validIdImageFile.readAsBytes());
                      data['validIdImage'] = validIdImageBase64;
                    }
                    if (_barangayPermitImage != null) {
                      File barangayPermitImageFile = File(_barangayPermitImage!.path);
                      int barangayPermitImageSize = await barangayPermitImageFile.length();
                      if (barangayPermitImageSize > 3 * 1024 * 1024) {
                        _showImageSizeAlert(context, 'Barangay Permit');
                        return;
                      }
                      barangayPermitImageBase64 = base64Encode(await barangayPermitImageFile.readAsBytes());
                      data['barangayPermit'] = barangayPermitImageBase64;
                    }

                    _showRegistrationDialog(context);

                    try {
                      bool isSuccess = await Api.registrationBarangay(context, data, barangayHallImageFile!);
                      Navigator.of(context).pop();
                      if (isSuccess) {
                        _showSuccessDialog(context);
                      } else {
                        throw Exception('Registration failed. Please check your entered credentials or email is already used.');
                      }
                    } catch (e) {
                      Navigator.of(context).pop();
                      _showErrorDialog(context, e.toString());
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF40A858),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Register',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy Policy'),
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
          actions: <Widget>[
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

  Future<void> _pickImage({required bool isBarangayHallImage, bool isBarangayPermit = false}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        if (isBarangayHallImage) {
          _barangayHallImage = pickedFile;
        } else if (isBarangayPermit) {
          _barangayPermitImage = pickedFile;
        } else {
          _validIdImage = pickedFile;
        }
      }
    });
  }

  Widget _buildLabelWithAsterisk(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: '*',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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

  void _showImageSizeAlert(BuildContext context, String imageType) {
    _showAlertDialog(context, 'Image Size Too Large', 'The selected $imageType is larger than the allowed limit of 3 MB.');
  }

  void _showMissingImageAlert(BuildContext context) {
    _showAlertDialog(context, 'Missing Image', 'Please upload all required images.');
  }

  void _showMissingAddressAlert(BuildContext context) {
    _showAlertDialog(context, 'Missing Address', 'Please enter your barangay address.');
  }

  void _showRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Registering, please wait...'),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    _showAlertDialog(context, 'Registration Successful', 'Your barangay has been successfully registered.');
  }

  void _showErrorDialog(BuildContext context, String message) {
    _showAlertDialog(context, 'Error', message);
  }
}
