import 'package:flutter/material.dart';
import 'package:Kariton/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'community_notification_screen.dart';
import 'community_general_prof.dart';
import 'community_login_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final Map data;

  const HomeScreen({Key? key, required this.data}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _refreshData() async {
    var requestData = {
      "id": widget.data['user']['_id'],
      "type": "Community"
    };

    try {
      final updatedData = await Api.getHome(context, requestData);
      // Handle updated data if needed
    } catch (error) {
      print("Error refreshing data: $error");
    }
  }

  String getGreeting() {
    tz.initializeTimeZones();
    final now = tz.TZDateTime.now(tz.getLocation('Asia/Manila'));
    final hour = now.hour;

    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Future<bool> _isAlreadyNotifiedToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return prefs.getBool('notified_$todayKey') ?? false;
  }

  Future<void> _setNotifiedToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setBool('notified_$todayKey', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                SizedBox(height: 16.0),
                _buildTodayScrap(), // New scrap type for today section
                SizedBox(height: 16.0),
                _buildContent(),
                SizedBox(height: 16.0),
                _buildCategories(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFFC9e4B9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${getGreeting()}, ${widget.data['user']['fullname']}!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(data: widget.data),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodayScrap() {
    final now = DateTime.now().toUtc().add(Duration(hours: 8));
    final dayOfWeek = DateFormat('EEEE').format(now);
    print(widget.data['collection']);
    final scrapSchedule = {
      'Monday': 'Plastic',
      'Tuesday': 'Metal',
      'Wednesday': 'Paper',
      'Thursday': 'Glass',
      'Friday': 'Electronics',
      'Saturday': 'Organic Waste',
      'Sunday': 'No collection',
    };

    final todayScrapType = scrapSchedule[dayOfWeek];
    final todayScrap = (widget.data['collection'] as List).firstWhere(
      (scrap) => scrap['dayOfWeek'] == dayOfWeek,
      orElse: () => null,
    );
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.orange, size: 36),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                   todayScrap != null
                      ? 'Today\'s Scrap: ${todayScrap['scrapType']}'
                      : 'No scrap scheduled for today',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          FutureBuilder<bool>(
            future: _isAlreadyNotifiedToday(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              final alreadyNotified = snapshot.data ?? false;

              return Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: alreadyNotified
                      ? null
                      : () async {
                          var data = {
                            "date": dayOfWeek,
                            "id": widget.data['user']['_id'],
                            "scrapType": todayScrap['scrapType'],
                            "name": widget.data['user']['fullname'],
                            "usertype": 'Resident',
                            "barangayID": widget.data['barangay']['_id']
                          };

                          await Api.pickUp(context, data);
                          await _setNotifiedToday();
                          setState(() {}); // Refresh the UI to disable button
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    alreadyNotified ? 'Barangay Notified' : 'Collect Me',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.lightGreen[100],
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage('assets/home_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'By collecting,\nsorting, and \nselling scraps',
            style: TextStyle(fontSize: 18, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Accepted Scraps',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.data['scraps'].length,
            itemBuilder: (context, index) {
              final scrap = widget.data['scraps'][index];
              return _buildCategoryItem(scrap);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(Map scrap) {
    return Container(
      width: 120,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      padding: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.green[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          scrap['scrapType'],
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
