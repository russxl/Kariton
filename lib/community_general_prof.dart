import 'package:flutter/material.dart';
import 'package:Kariton/api/api.dart';

class CommunityGeneralProf extends StatefulWidget {
  final Map userData;

  const CommunityGeneralProf({Key? key, required this.userData}) : super(key: key);

  @override
  _CommunityGeneralProfState createState() => _CommunityGeneralProfState();
}

class _CommunityGeneralProfState extends State<CommunityGeneralProf> {
  Map userData = {};

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
  }

  Future<void> _refreshData() async {
    var requestData = {
      "id": userData['user']['_id'],
      "type": "Community"
    };

    try {
      final updatedData = await Api.getHome(context, requestData);
    } catch (error) {
      print("Error refreshing data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[600],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 30.0),
          children: <Widget>[
            _buildProfileInfo(),
            const SizedBox(height: 30.0),
            _buildEditProfileButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileItem(Icons.person, 'UserID', userData['user']['userID'].toString()),
          _buildProfileItem(Icons.account_circle, 'Name', userData['user']['fullname']),
          _buildProfileItem(Icons.email, 'Email', userData['user']['email']),
          _buildProfileItem(Icons.phone, 'Phone', userData['user']['phone'].toString()),
          _buildProfileItem(Icons.home, 'Barangay', userData['user']['barangay']),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[600]),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              '$title: $info',
              style: const TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfileScreen(userData: userData),
          ),
        );
      },
      icon: const Icon(
        Icons.edit,
        color: Colors.white,
      ),
      label: const Text(
        'Edit Profile',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[600],
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final Map userData;

  const EditProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['user']['fullname']);
    _emailController = TextEditingController(text: widget.userData['user']['email']);
    _phoneController = TextEditingController(text: widget.userData['user']['phone'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[600],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextField(_nameController, 'Full Name', 'Change your name'),
              const SizedBox(height: 20.0),
              _buildTextField(_emailController, 'Email', null, readOnly: true),
              const SizedBox(height: 20.0),
              _buildTextField(_phoneController, 'Phone Number', 'Enter your phone number'),
              const SizedBox(height: 30.0),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String? hintText, {
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: Icon(
          label == 'Full Name'
              ? Icons.person
              : label == 'Email'
                  ? Icons.email
                  : Icons.phone,
          color: Colors.green[600],
        ),
      ),
      validator: (value) {
        if (label == 'Phone Number') {
          String pattern = r'^(09|\+639)\d{9}$';
          RegExp regex = RegExp(pattern);
          if (value == null || value.isEmpty) {
            return 'Please enter your phone number';
          } else if (!regex.hasMatch(value)) {
            return 'Please enter a valid Philippine phone number';
          }
        }
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          var data = {
            'fullname': _nameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'userType': 'Community',
            'user_id': widget.userData['user']['_id']
          };

          Api.updateCommunity(context, data);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[600],
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: const Text(
        'Save Changes',
        style: TextStyle(fontSize: 18.0, color: Colors.white),
      ),
    );
  }
}
