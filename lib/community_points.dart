import 'package:flutter/material.dart';
import 'package:Kariton/api/api.dart';
import 'community_redeem_cash_screen.dart';
import 'community_redeem_goods_screen.dart';
import 'community_scrap_points_screen.dart';

class PointsScreen extends StatefulWidget {
  final Map userData;

  const PointsScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _PointsScreenState createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
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
    var points = widget.userData['user']['points'];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Collect Points',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[600],
        elevation: 5.0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(30.0, 60.0, 30.0, 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildGreeting(),
              const SizedBox(height: 16.0),
              _buildPointsCard(points),
              const SizedBox(height: 24.0),
              const Text(
                'Redeem your points...',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              _buildRedeemOptions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, ${widget.userData['user']['fullname']}!',
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8.0),
        const Text(
          'You have earned:',
          style: TextStyle(fontSize: 18.0, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildPointsCard(String points) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$points',
                style: const TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF40A858),
                ),
              ),
              const SizedBox(height: 4.0),
              const Text(
                'Total Points',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScrapPointsScreen(userData: widget.userData),
                ),
              );
            },
            child: const Icon(
              Icons.more_vert,
              color: Color(0xFF40A858),
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemOptions(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildRedeemItem('Cash', 'assets/cash_icon.png', context),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: _buildRedeemItem('Goods', 'assets/goods_icon.png', context),
        ),
      ],
    );
  }

  Widget _buildRedeemItem(String label, String imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (label == 'Cash') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RedeemCashScreen(userData: widget.userData),
            ),
          );
        } else if (label == 'Goods') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RedeemGoodsScreen(userData: widget.userData),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(imagePath, width: 50, height: 50),
            const SizedBox(height: 12.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
