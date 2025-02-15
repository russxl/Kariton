import 'package:Kariton/barangay_community_collection.dart';
import 'package:Kariton/barangay_pick_up.dart';
import 'package:Kariton/barangay_sched_status.dart';
import 'package:flutter/material.dart';
import 'barangay_community_page.dart';
import 'barangay_junkshop.dart';
import 'barangay_collect_scrap_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class BarangayHomeScreen extends StatelessWidget {
  final Map data;

  const BarangayHomeScreen({Key? key, required this.data}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Top Background
          Container(
            height: MediaQuery.of(context).size.height / 2.8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF80C784), Color(0xFF40A858)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Greeting Section
                Center(
                  child: Text(
                    getGreeting(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),

                // Barangay Name Display
                Center(
                  child: Text(
                    '${data['barangay']['bName']}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Collect Scrap Button
                Center(
                  child: RoundedButton(
                    label: 'Collect Scrap',
                    color: Color(0xFF34A853),
                    icon: Icons.recycling,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BarangayCollectScrapPage(data: data)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20.0),

                // Set Pickup Schedule Button
                Center(
                  child: RoundedButton(
                    label: 'Pick up schedule status',
                    color: Colors.blueAccent,
                    icon: Icons.schedule,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BarangayPickUpScheduleScreen(data: data)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10.0),

                // Pending Collection Requests Button
                Center(
                  child: RoundedButton(
                    label: 'Pending Collection Requests',
                    color: Colors.orangeAccent,
                    icon: Icons.pending_actions,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BarangayCommunityCollectionScreen(data: data)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20.0),

                // Category Row (Resident and Junkshop)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryItem(
                      title: 'Resident',
                      assetPath: 'assets/COMMUNITYAA.png',
                      backgroundColor: Colors.lightBlue[100]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommunityPage(data: data),
                          ),
                        );
                      },
                    ),
                    CategoryItem(
                      title: 'Junkshop',
                      assetPath: 'assets/JSHOPAAA.png',
                      backgroundColor: Colors.lightGreen[100]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BarangayJunkshopScreen(data: data),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const RoundedButton({
    Key? key,
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Larger radius for rounded effect
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;
  final String assetPath;
  final Color backgroundColor;
  final VoidCallback onTap;

  CategoryItem({
    required this.title,
    required this.assetPath,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(assetPath, width: 60, height: 60),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF40A858),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Click here',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
