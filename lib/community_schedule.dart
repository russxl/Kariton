import 'package:flutter/material.dart';
import 'package:Kariton/api/api.dart';

// Mock ScheduleDetailsScreen implementation
class ScheduleDetailsScreen extends StatelessWidget {
  final String day;
  final String location;
  final String time;
  final String scrapType;
  final String description;
  final String longDescription;
  final Map userData;

  ScheduleDetailsScreen({
    required this.day,
    required this.location,
    required this.time,
    required this.scrapType,
    required this.description,
    required this.longDescription,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Details'),
        centerTitle: true,
        backgroundColor: Colors.green[600],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              day,
              style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Text(
              'Location: $location',
              style: TextStyle(fontSize: 18.0, color: Colors.green[900]),
            ),
            const SizedBox(height: 5.0),
            Text(
              'Time: $time',
              style: TextStyle(fontSize: 18.0, color: Colors.green[900]),
            ),
            const SizedBox(height: 5.0),
            Text(
              'Scrap Type: $scrapType',
              style: TextStyle(fontSize: 18.0, color: Colors.green[900]),
            ),
            const Divider(height: 20.0, thickness: 1.5),
            const Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            const SizedBox(height: 5.0),
            Text(
              description,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
            ),
            const Divider(height: 20.0, thickness: 1.5),
            const Text(
              'Long Description:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            const SizedBox(height: 5.0),
            Text(
              longDescription,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  final Map userData;

  ScheduleScreen({
    required this.userData,
  });

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late List collection;

  @override
  void initState() {
    super.initState();
    collection = widget.userData['collection'] ?? [];
  }

  Future<void> _refreshData() async {
    var requestData = {
      "id": widget.userData['user']['_id'],
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
          'Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[600],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: collection.isEmpty
            ? _buildNoScheduleMessage()
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: collection.length,
                itemBuilder: (context, index) {
                  final item = collection[index];
                  return _buildScheduleItem(
                    context,
                    day: item['dayOfWeek'] ?? 'No data',
                    time: item['startTime'] ?? 'No time',
                    scrapType: item['scrapType'] ?? 'No scrap type',
                    longDescription: item['longDescription'] ?? 'No long description',
                  );
                },
              ),
      ),
    );
  }

  Widget _buildNoScheduleMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No schedules available at the moment.',
          style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildScheduleItem(
    BuildContext context, {
    required String day,
    required String time,
    required String scrapType,
    required String longDescription,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScheduleDetailsScreen(
              day: day,
              location: 'Unknown',
              time: time,
              scrapType: scrapType,
              description: 'Brief description here', // Add proper description
              longDescription: longDescription,
              userData: widget.userData,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.green,
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.green[700], size: 18.0),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Time: $time',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
                ),
                Text(
                  'Scrap Type: $scrapType',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
