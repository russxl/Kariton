import 'package:flutter/material.dart';
import 'package:Kariton/api/api.dart';

class BarangayNotificationScreen extends StatefulWidget {
  final Map data;

  const BarangayNotificationScreen({Key? key, required this.data}) : super(key: key);

  @override
  _BarangayNotificationScreenState createState() => _BarangayNotificationScreenState();
}

class _BarangayNotificationScreenState extends State<BarangayNotificationScreen> {
  late List<dynamic> userLogs;

  @override
  void initState() {
    super.initState();
    userLogs = widget.data['userLogs'] ?? [];
  }

  Future<void> _refreshData() async {
    var requestData = {
      "id": widget.data['barangay']['_id'],
      "type": "Barangay"
    };

    try {
      final updatedData = await Api.getHome(context, requestData);
      // Update the state with the refreshed data
    } catch (error) {
      print("Error refreshing data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> reversedUserLogs = userLogs.reversed.toList();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 70.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Centered Title
            Center(
              child: Text(
                'Notification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF344E41),
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            const SizedBox(height: 10.0),

            // Left-aligned Latest Text
            Text(
              'Latest',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF40A858),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 16.0),

            // Notification Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView.builder(
                  itemCount: reversedUserLogs.length,
                  itemBuilder: (context, index) {
                    var log = reversedUserLogs[index];

                    // Assigning a color based on index for variety
                    final backgroundColor = index % 2 == 0
                        ? Color(0xFFE0F7FA) // Light teal
                        : Color(0xFFFFF9C4); // Light yellow

                    return Container(
                      margin: EdgeInsets.only(bottom: 16.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Icon based on log type
                          Icon(
                            log['type'] == 'Alert'
                                ? Icons.warning
                                : Icons.notifications,
                            color: log['type'] == 'Alert'
                                ? Colors.redAccent
                                : Color(0xFF40A858),
                            size: 30,
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      log['date'] ?? 'Unknown date',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey[800],
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    Text(
                                      log['type'] ?? 'General',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: log['type'] == 'Alert'
                                            ? Colors.redAccent
                                            : Color(0xFF40A858),
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  log['time'] ?? 'Unknown time',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  log['logs'] ?? 'No details available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black87,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
     