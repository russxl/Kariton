import 'package:Kariton/junkshop_scrap_admin.dart';
import 'package:flutter/material.dart';
import 'package:Kariton/api/api.dart';
import 'package:Kariton/community_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'junkshop_notification.dart';
import 'junkshop_history.dart';
import 'junkshop_profile.dart';
import 'junkshop_scrap_price.dart';
import 'junkshop_sorting.dart';
import 'junkshop_booking_page.dart';
import 'junkshop_view_sched.dart';

class JunkshopMainScreen extends StatefulWidget {
  final Map data;

  const JunkshopMainScreen({Key? key, required this.data}) : super(key: key);

  @override
  _JunkshopMainScreenState createState() => _JunkshopMainScreenState();
}

class _JunkshopMainScreenState extends State<JunkshopMainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isLoading = false; // Loading state variable

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    // Prepare data for API call
    var data = {
      "id": widget.data['junkOwner']['_id'],
      'type': "Junkshop",
    };

    // Fetch new data
    await Api.getHome(context, data);

    setState(() {
      _isLoading = false; // Reset loading state after data is fetched
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    bool isApproved = data['junkOwner']['isApproved'] == true;

    // If the account is not approved, show the under review screen
    if (!isApproved) {
      return _buildUnderReviewScreen();
    }

    // Main content
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false, // Remove back button
        title: const Text(
          'KARITON',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          // The first page contains the refreshable content
          RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Hello, ${data['junkOwner']['ownerName']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildActionContainer(
                      context,
                      icon: Icons.attach_money,
                      label: 'Set Scrap Price for Barangay',
                      color: Colors.orangeAccent,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SetPriceJunkshop(data: data),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20.0),
                    _buildActionContainer(
                      context,
                      icon: Icons.list,
                      label: 'AJCD Scrap Pricelist',
                      color: Colors.blueAccent,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScrapPriceScreen(data: data),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Schedule your first scrap collection',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingPage(data: data),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 24.0,
                    ),
                  ),
                  child: const Text(
                    'Schedule Now',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Other pages in the PageView
          NotificationJunkshop(data: data),
          HistoryJunkshop(data: data),
          ProfileJunkshop(data: data),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green[700],
        selectedLabelStyle: const TextStyle(color: Colors.white),
        unselectedLabelStyle: const TextStyle(color: Colors.white70),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
    );
  }

  // Widget for the under review screen
  Widget _buildUnderReviewScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.hourglass_empty, size: 100, color: Colors.orangeAccent),
            const SizedBox(height: 24),
            const Text(
              'Your account is under review.',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please wait for your approval to fully access the app.',
              style: TextStyle(
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true; // Start loading when the button is pressed
                });
                await _refreshData(); // Refresh data
                setState(() {
                  _isLoading = false; // Stop loading after data is refreshed
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              ),
              child: _isLoading // Show loading spinner if loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Reload',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionContainer(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2.0,
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(
            icon,
            color: color,
            size: 36.0,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: color),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
