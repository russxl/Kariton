import 'package:Kariton/barangay_pick_up.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JunkshopDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data; // Map for the junkshop data

  const JunkshopDetailScreen({Key? key, required this.data}) : super(key: key);

  // Open the map app (Google Maps, Waze, etc.) with the junkshop's location
  void _openDirections(BuildContext context) async {
    String address = data['junkShop']['address'] ?? '';
    String brgy = data['barangay']['bLocation'] ?? '';

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address is not available')),
      );
      return;
    }

    if (brgy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barangay location is not available')),
      );
      return;
    }

    String urlString = 'https://www.google.com/maps/dir/${brgy}/${address}';
    Uri url = Uri.parse(urlString);

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure 'junkScrap' is a List<Map<String, dynamic>>
    var categories = List<Map<String, dynamic>>.from(data['junkScrap'] ?? []);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Junkshop Details"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Junkshop Name
            Text(
              data['junkShop']['jShopName'] ?? 'Unknown Junkshop',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(height: 20.0),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 24),
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Located at ${data['junkShop']['address'] ?? 'Unknown Location'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),

            // Owner
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue, size: 24),
                SizedBox(width: 8.0),
                Text(
                  data['junkShop']['ownerName'] ?? 'Unknown Owner',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),

            // Phone
            Row(
              children: [
                Icon(Icons.call, color: Colors.green, size: 24),
                SizedBox(width: 8.0),
                Text(
                  data['junkShop']['phone'] ?? 'No phone number',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),

            // Email
            Row(
              children: [
                Icon(Icons.mail, color: Colors.orange, size: 24),
                SizedBox(width: 8.0),
                Text(
                  data['junkShop']['email'] ?? 'No email provided',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.0),

            // Details
            Text(
              'Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              data['junkShop']['description'] ?? 'No description available',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Roboto',
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 30.0),

            // Categories Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Categories List
            Column(
              children: categories.map<Widget>((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category['scrapType'] ?? 'Unknown Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Text(
                        '${category['pointsEquivalent'].toString()} Points',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Roboto',
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 30.0),

            // Directions Button
            GestureDetector(
              onTap: () => _openDirections(context),
              child: Row(
                children: [
                  Icon(Icons.directions, color: Colors.blue, size: 24),
                  SizedBox(width: 8.0),
                  Text(
                    'Get Directions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),

            // Set Pickup Schedule Button
            GestureDetector(
              onTap: () {
                // Handle the pickup schedule action
                 Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BarangayBookingPage(data: data)),
                      );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    'Set Pickup Schedule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
