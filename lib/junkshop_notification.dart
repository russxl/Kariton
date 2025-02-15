import 'package:flutter/material.dart';
import 'package:Kariton/api/api.dart';

class NotificationJunkshop extends StatelessWidget {
  final Map data;

  const NotificationJunkshop({Key? key, required this.data}) : super(key: key);

  Future<void> _refreshData(BuildContext context) async {
    // Prepare data for API call
    var newData = {
      "id": data['junkOwner']['_id'],
      'type': "Junkshop",
    };

    // Fetch new data
    await Api.getHome(context, newData);
    
    // Show a message indicating successful refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scraps list updated successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if userLogs exists and is a list
    List userLogs = data['userLogs'] ?? [];
    print(userLogs); // Debug print

    // Reverse the logs to display the latest first
    List reversedLogs = userLogs.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(context), // Link to the refresh function
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recent Updates',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: reversedLogs.isEmpty
                  ? Center(
                      child: Text(
                        'No new notifications',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: reversedLogs.length, // Length of reversedLogs
                      itemBuilder: (context, index) {
                        // For each log, display a notification tile
                        var log = reversedLogs[index];
                        return _buildNotificationTile(
                          title: log['logs'] ?? 'No Title', // Title from log
                          subtitle: 'Date: ${log['date'] ?? 'Unknown'} - ${log['scrapType'] ?? 'No Scrap Type'}',
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(
            Icons.notifications,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}
