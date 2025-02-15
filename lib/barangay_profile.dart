import 'dart:convert'; // Import the convert library to decode Base64
import 'package:flutter/material.dart';
import 'package:Kariton/community_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'barangay_edit_profile.dart'; // Import the EditProfile page
import 'barangay_activity_page.dart'; // Import the BarangayActivityPage

class BarangayProfileScreen extends StatefulWidget {
  final Map data;

  const BarangayProfileScreen({Key? key, required this.data}) : super(key: key);

  @override
  _BarangayProfileScreenState createState() => _BarangayProfileScreenState();
}

class _BarangayProfileScreenState extends State<BarangayProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8FA), // Light background color
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Profile Title
            Center(
              child: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Color(0xFF344E41),
                ),
              ),
            ),
            SizedBox(height: 20.0),

            // Profile Card
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF40A858),
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: widget.data['barangay']['bImg'] != null
                        ? MemoryImage(
                            base64Decode(widget.data['barangay']['bImg']),
                          )
                        : AssetImage('assets/barangay_icon.png') as ImageProvider,
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.data['barangay']['bName']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Barangay Administrator',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(data: widget.data),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),

            // Profile Details
            Expanded(
              child: ListView(
                children: <Widget>[
                  _buildProfileOption(
                    icon: Icons.history,
                    title: 'Activity',
                    subtitle: 'View all transactions and activities',
                    color: Colors.blue[600]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BarangayActivityPage(data: widget.data),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.0),

                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Log out',
                    subtitle: 'Further secure your account for safety',
                    color: Colors.red[400]!,
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Roboto',
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
