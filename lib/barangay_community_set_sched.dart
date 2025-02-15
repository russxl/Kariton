import 'package:flutter/material.dart';
import 'package:Kariton/api/api.dart';
import 'barangay_community_save_sched.dart';

class BarangayCommunitySetSchedScreen extends StatefulWidget {
  final Map data;

  const BarangayCommunitySetSchedScreen({Key? key, required this.data}) : super(key: key);
  @override
  _BarangayCommunitySetSchedScreenState createState() => _BarangayCommunitySetSchedScreenState();
}

class _BarangayCommunitySetSchedScreenState extends State<BarangayCommunitySetSchedScreen> {
  final Map<String, _Schedule> _schedules = {
    'Monday': _Schedule(),
    'Tuesday': _Schedule(),
    'Wednesday': _Schedule(),
    'Thursday': _Schedule(),
    'Friday': _Schedule(),
  };

  @override
  void initState() {
    super.initState();
    _initializeSchedule();
  }

  void _initializeSchedule() {
    // Initialize _schedules based on data from widget.data['collection']
    if (widget.data['collection'] != null) {
      for (var schedule in widget.data['collection']) {
        final day = schedule['dayOfWeek'];
        final scrapType = schedule['scrapType'];
        final startTime = schedule['startTime'];

        if (_schedules.containsKey(day)) {
          _schedules[day]!.scrapType = scrapType;
          _schedules[day]!.collectionTime = _parseTimeOfDay(startTime);
        }
      }
    }
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1].split(' ')[0]);
    String period = parts[1].split(' ')[1];

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Community',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Set Schedule',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  '(for pickup)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Roboto',
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.0),

            Expanded(
              child: ListView(
                children: _schedules.keys.map((day) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showScheduleDialog(day),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF40A858),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          day,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20.0),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final scheduleData = {
                      'Monday': {
                        'scrapType': _schedules['Monday']!.scrapType,
                        'collectionTime': _schedules['Monday']!.collectionTime.format(context),
                      },
                      'Tuesday': {
                        'scrapType': _schedules['Tuesday']!.scrapType,
                        'collectionTime': _schedules['Tuesday']!.collectionTime.format(context),
                      },
                      'Wednesday': {
                        'scrapType': _schedules['Wednesday']!.scrapType,
                        'collectionTime': _schedules['Wednesday']!.collectionTime.format(context),
                      },
                      'Thursday': {
                        'scrapType': _schedules['Thursday']!.scrapType,
                        'collectionTime': _schedules['Thursday']!.collectionTime.format(context),
                      },
                      'Friday': {
                        'scrapType': _schedules['Friday']!.scrapType,
                        'collectionTime': _schedules['Friday']!.collectionTime.format(context),
                      },
                      'barangayID': widget.data['barangay']['_id'],
                    };

                    await Api.saveSched(context, scheduleData);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF40A858),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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

  Future<void> _showScheduleDialog(String day) async {
    final _schedule = _schedules[day]!;
    List<String> scrapTypes = List<String>.from(
      widget.data['scrap'].map((scrap) => scrap['scrapType'])
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Schedule for $day'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _schedule.scrapType.isNotEmpty ? _schedule.scrapType : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _schedule.scrapType = newValue!;
                  });
                },
                items: scrapTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select Category',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF40A858)),
                  ),
                ),
              ),
              SizedBox(height: 20.0),

              GestureDetector(
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _schedule.collectionTime,
                  );
                  if (pickedTime != null && pickedTime != _schedule.collectionTime)
                    setState(() {
                      _schedule.collectionTime = pickedTime;
                    });
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Collection Time',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF40A858)),
                    ),
                  ),
                  child: Text(
                    _schedule.collectionTime.format(context),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                print('$day Schedule:');
                print('Scrap Type: ${_schedule.scrapType}');
                print('Collection Time: ${_schedule.collectionTime.format(context)}');
              },
            ),
          ],
        );
      },
    );
  }
}

class _Schedule {
  String scrapType = '';
  TimeOfDay collectionTime = TimeOfDay.now();
}
