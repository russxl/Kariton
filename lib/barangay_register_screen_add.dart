import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Kariton/api/api.dart';
import 'package:Kariton/community_login_screen.dart';
import 'package:Kariton/barangay_register_screen.dart';

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
                builder: (context) =>
                    BarangayRegisterScreen(userType: userType),
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
  _RegisterBarangayAddFormState createState() =>
      _RegisterBarangayAddFormState();
}

class _RegisterBarangayAddFormState extends State<RegisterBarangayAddForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  bool _isTermsAccepted = false;
  XFile? _barangayHallImage;
  XFile? _validIdImage;

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
            child: _buildImageContainer(_barangayHallImage, 'Barangay Hall'),
          ),
          SizedBox(height: 20),
          _buildLabelWithAsterisk('Upload a Valid ID'),
          GestureDetector(
            onTap: () => _pickImage(isBarangayHallImage: false),
            child: _buildImageContainer(_validIdImage, 'Valid ID'),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: _isTermsAccepted,
                onChanged: (value) {
                  setState(() {
                    _isTermsAccepted = value ?? false;
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showTermsAndConditions(context),
                  child: Text(
                    'I accept the Terms and Conditions',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: () async {
  if (_formKey.currentState!.validate() &&
      _isTermsAccepted &&
      _barangayHallImage != null &&
      _validIdImage != null) {

    // Initialize files for size validation
    File? barangayHallImageFile;
    File? validIdImageFile;

    // Create a map to store data
    Map<String, dynamic> data = {
      'userType': widget.userType,
      'password': widget.password,
      'email': widget.email,
      'confirmPassword': widget.confirmPassword,
      'phone': widget.phone,
      'address': _addressController.text,
      'captainName': widget.captainName,
      'barangayName': widget.barangayName,
    };

    try {
      // Check image sizes before processing
      if (_barangayHallImage != null) {
        barangayHallImageFile = File(_barangayHallImage!.path);
        int barangayHallImageSize = await barangayHallImageFile.length();
        if (barangayHallImageSize > 3 * 1024 * 1024) { // If > 3MB
          _showImageSizeAlert(context, 'Barangay Hall Photo');
          return; // Stop registration if size exceeds limit
        }
        data['barangayHallImage'] = base64Encode(await barangayHallImageFile.readAsBytes());
      }

      if (_validIdImage != null) {
        validIdImageFile = File(_validIdImage!.path);
        int validIdImageSize = await validIdImageFile.length();
        if (validIdImageSize > 3 * 1024 * 1024) { // If > 3MB
          _showImageSizeAlert(context, 'Valid ID');
          return; // Stop registration if size exceeds limit
        }
        data['validIdImage'] = base64Encode(await validIdImageFile.readAsBytes());
      }

      // Show the registration progress dialog
      _showRegistrationDialog(context);

      // Perform registration API call
      bool isSuccess = await Api.registrationBarangay(
        context,
        data,
        barangayHallImageFile!,
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (isSuccess) {
        _showSuccessDialog(context);
      } else {
        throw Exception('Registration failed. Please try again.');
      }

    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if error occurs
      _showErrorDialog(context, e.toString());
    }
  } else {
    if (!_isTermsAccepted) {
      _showErrorDialog(context, 'Please accept the Terms and Conditions.');
    } else {
      _showMissingImageAlert(context);
    }
  }
},

              child: Text('Register'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(XFile? image, String placeholder) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: image == null
          ? Center(child: Text('Upload $placeholder'))
          : Image.file(File(image.path)),
    );
  }

  void _pickImage({required bool isBarangayHallImage}) async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (isBarangayHallImage) {
        _barangayHallImage = pickedFile;
      } else {
        _validIdImage = pickedFile;
      }
    });
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Privacy Policy'),
          content: SingleChildScrollView(
            child: Text(
              'Privacy Policy\nEffective Date: October 27, 2024\nKARITON: A Mobile and Web-Based Solution for Recycling...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
 Widget _buildLabelWithAsterisk(String label) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          '*',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      ],
    );
  }
  void _showMissingImageAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Missing Image'),
          content: Text('Please upload all required images.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Registering...'),
            ],
          ),
        );
      },
    );
  }
  void _showImageSizeAlert(BuildContext context, String imageType) {
    _showAlertDialog(
      context,
      'Image Size Too Large',
      '$imageType exceeds the size limit of 3MB. Please upload a smaller image.',
    );
  }
  

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Registration successful!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
 void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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


