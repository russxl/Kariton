import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Kariton/api/api.dart'; // Ensure the API is correctly imported

class BarangayCommunityCollectionScreen extends StatefulWidget {
  final Map<dynamic, dynamic> data;

  const BarangayCommunityCollectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  _BarangayCommunityCollectionScreenState createState() => _BarangayCommunityCollectionScreenState();
}

class _BarangayCommunityCollectionScreenState extends State<BarangayCommunityCollectionScreen> {
  late List<Map<String, dynamic>> collectionRequests;

  @override
  void initState() {
    super.initState();
    collectionRequests = List<Map<String, dynamic>>.from(widget.data['collectionRequests'] ?? []);
    collectionRequests.removeWhere((request) => request['status'] == 'Done');
  }

  Future<void> _refreshData() async {
    if (widget.data['collectionRequests'] != null && widget.data['collectionRequests'].isNotEmpty) {
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
    List<Map<String, dynamic>> reversedCollectionRequests = collectionRequests.reversed.toList();
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 70.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Centered Title
            Center(
              child: Text(
                'Community Collection Requests',
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
                  itemCount: reversedCollectionRequests.length,
                  itemBuilder: (context, index) {
                    var request = reversedCollectionRequests[index];

                    // Assigning a color based on index for variety
                    final backgroundColor = index % 2 == 0
                        ? Color(0xFFE0F7FA) // Light teal
                        : Color(0xFFFFF9C4); // Light yellow

                    return GestureDetector(
                      onTap: () {
                       Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BarangayCollectScrapPage1(
      data: {
        ...widget.data,
        'selectedRequest': request,
        'userId': request['uID'],
        'transactionID':request['_id']
      },
    ),
  ),
);

                      },
                      child: Container(
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
                                  : request['status'] == 'Completed'
                                      ? Icons.check_circle
                                      : Icons.schedule,
                              color: request['status'] == 'Pending'
                                  ? Colors.orangeAccent
                                  : request['status'] == 'Completed'
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
                                        request['name'] ?? 'Unknown name',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
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
                                    'Scrap Type: ${request['scrapType'] ?? 'Unknown scrap type'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey[800],
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

class BarangayCollectScrapPage1 extends StatefulWidget {
  final Map data;

  const BarangayCollectScrapPage1({Key? key, required this.data}) : super(key: key);

  @override
  _BarangayCollectScrapPageState createState() => _BarangayCollectScrapPageState();
}

class _BarangayCollectScrapPageState extends State<BarangayCollectScrapPage1> {
  final _pageController = PageController();
  final _idController = TextEditingController();
  bool _userExists = false;
  bool _isUserIdProvided = false;

  @override
  void initState() {
    super.initState();
    if (widget.data.containsKey('selectedRequest')) {
      // Automatically proceed to second step if request data is passed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isUserIdProvided = true;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Collect Scrap',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe to prevent invalid index
        children: [
          _buildInitialPage(context),
          Builder(
            builder: (context) {
             return DetailPage(userId: widget.data.containsKey('userId') ? widget.data['userId'] : _idController.text, data: widget.data, transactionID:widget.data['transactionID']);

            },
          ),
        ],
      ),
    );
  }

  Widget _buildInitialPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Collection of Scraps',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Please enter the member ID',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          if (!_isUserIdProvided) ...[
            const Text(
              'ID No. *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number, // Accept only numbers
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Ensure only digits are accepted
            ),
            const SizedBox(height: 20),
          ],
          Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isUserIdProvided = false;
                    });
                    if (_idController.text.isNotEmpty) {
                      // Check if the user exists using the API
                      _userExists = await _checkUserExists(_idController.text);
                      
                      if (_userExists) {
                        setState(() {}); // Update UI
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        // Show an alert if user does not exist
                        _showUserNotExistAlert(context);
                      }
                    } else {
                      // Show an alert if ID is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter an ID')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF40A858),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Enter User ID',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isUserIdProvided = true;
                    });
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF40A858),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Proceed Without User ID',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkUserExists(String userId) async {
    try {
      // Pass the user ID as part of the data map
      Map<String, String> data = {'userId': userId};  // Adjust based on your backend needs
      bool userExists = await Api.checkUserExist(data); // Call the updated API method

      return userExists; // Return true or false based on the API response
    } catch (e) {
      // Handle error cases and print if needed
      print('Error checking user: $e');
      return false;
    }
  }

  void _showUserNotExistAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('User does not exist. Please check the ID.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class DetailPage extends StatefulWidget {
  final String userId;
  final String transactionID;
  final Map data;

  const DetailPage({Key? key, required this.userId, required this.data, required this.transactionID}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String _selectedScrapType = '';
  late List<String> _scrapTypes;
  final _weightController = TextEditingController();
  final _pointsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrapTypes = List<String>.from(widget.data['scrap'].map((scrap) => scrap['scrapType']));
    _selectedScrapType = _scrapTypes.isNotEmpty ? _scrapTypes.first : '';
    _weightController.addListener(_calculatePoints);
  }

  @override
  void dispose() {
    _weightController.removeListener(_calculatePoints);
    _weightController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _calculatePoints() {
    if (_weightController.text.isEmpty) {
      _pointsController.text = '0';
      return;
    }

    double weight = double.tryParse(_weightController.text) ?? 0.0;
    int scrapPoints = _getScrapPoints(_selectedScrapType);
    int equivalentPoints = (weight * scrapPoints).toInt();
    _pointsController.text = equivalentPoints.toString();
  }

  int _getScrapPoints(String scrapType) {
    var scrap = widget.data['scrap'].firstWhere(
      (scrap) => scrap['scrapType'] == scrapType,
      orElse: () => {'pointsEquivalent': '0'},
    );
    return int.tryParse(scrap['pointsEquivalent'].toString()) ?? 0;
  }

 Future<void> _confirmCollection() async {
  // Check if all required fields are filled
  if (_selectedScrapType.isEmpty || _weightController.text.isEmpty || _pointsController.text == '0') {
    // Show a validation alert
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Please complete all the required fields and ensure the weight is valid.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return; // Exit the function to prevent further processing
  }

  // Show confirmation dialog before collecting the scrap
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Collection'),
        content: const Text('Are you sure you want to collect the scraps?'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close confirmation dialog

              // Show success alert
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: const Text('Scrap collection confirmed!'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          // Proceed with the scrap collection
                          Map<String, dynamic> collectionData = {
                            'userId': widget.userId,
                            'scrapType': _selectedScrapType,
                            'weight': _weightController.text,
                            'points': _pointsController.text,
                            'barangayID': widget.data['barangay']['_id'],
                            'barangayName': widget.data['barangay']['bName'],
                            'transactionID':widget.transactionID,
                          };

                          await Api.collectScrap(context, collectionData);
                          

                        },
                        child: const Text('Done'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('No'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Complete all the information',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Scrap Type *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        DropdownButtonFormField<String>(
          value: _selectedScrapType,
          items: _scrapTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedScrapType = newValue!;
              _calculatePoints();
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Weight (kg) *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        TextField(
  controller: _weightController,
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Allows numbers with up to two decimal places
  ],
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
    hintText: 'Enter weight in kg',
  ),
),

        const SizedBox(height: 20),
        const Text(
          'Points Equivalent',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        TextField(
          controller: _pointsController,
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Calculated points',
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _confirmCollection,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF40A858),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Confirm Collection',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
