import 'package:flutter/material.dart';
import 'package:Kariton/api/api.dart';

class BarangayPickUpScheduleScreen extends StatefulWidget {
  final Map<dynamic, dynamic> data;

  const BarangayPickUpScheduleScreen({Key? key, required this.data}) : super(key: key);

  @override
  _BarangayPickUpScheduleScreenState createState() => _BarangayPickUpScheduleScreenState();
}

class _BarangayPickUpScheduleScreenState extends State<BarangayPickUpScheduleScreen> {
  late List<Map<String, dynamic>> pickUpRequests;

 @override
void initState() {
  super.initState();
  // Filter out requests with status 'Done'
  pickUpRequests = List<Map<String, dynamic>>.from(widget.data['pickup'] ?? [])
      .where((request) => request['status'] != 'Done')
      .toList();
}

  Future<void> _refreshData() async {
    if (widget.data['pickup'] != null && widget.data['pickup'].isNotEmpty) {
      var requestData = {
        "id": widget.data['barangay']['_id'],
        "type": "Barangay"
      };

      try {
        final updatedData = await Api.getHome(context, requestData);
        
      } catch (error) {
        print("Error refreshing data: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> reversedPickUpRequests = pickUpRequests.reversed.toList();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 70.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Centered Title
            Center(
              child: Text(
                'Pick-Up Schedule Status',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF344E41),
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            const SizedBox(height: 10.0),

            // Notification Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView.builder(
                  itemCount: reversedPickUpRequests.length,
                  itemBuilder: (context, index) {
                    var request = reversedPickUpRequests[index];

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
                          // Icon based on request status
                          Icon(
                            request['status'] == 'Pending'
                                ? Icons.hourglass_empty
                                : request['status'] == 'Done'
                                    ? Icons.check_circle
                                    : Icons.schedule,
                            color: request['status'] == 'Pending'
                                ? Colors.orangeAccent
                                : request['status'] == 'Done'
                                    ? Colors.green
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
                                      request['setScheduledDate'] ?? 'Unknown date',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey[800],
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    Text(
                                      request['status'] ?? 'Status unknown',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: request['status'] == 'Pending'
                                            ? Colors.orangeAccent
                                            : request['status'] == 'Completed'
                                                ? Colors.green
                                                : Color(0xFF40A858),
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  request['scrapType'] ?? 'Unknown time',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  request['time'] ?? 'No details available',
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
