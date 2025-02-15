import 'package:flutter/material.dart';
import 'package:Kariton/api/api.dart';

class HistoryJunkshop extends StatefulWidget {
  final Map data;

  const HistoryJunkshop({Key? key, required this.data}) : super(key: key);

  @override
  _HistoryJunkshopState createState() => _HistoryJunkshopState();
}

class _HistoryJunkshopState extends State<HistoryJunkshop> {
  int _selectedIndex = 0;
  late List<Map<dynamic, dynamic>> pendingData;
  late List<Map<dynamic, dynamic>> declinedData;
  late List<Map<dynamic, dynamic>> approvedData;
  late List<Map<dynamic, dynamic>> doneData;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    pendingData = List<Map<dynamic, dynamic>>.from(widget.data['pending'] ?? []).reversed.toList();
    declinedData = List<Map<dynamic, dynamic>>.from(widget.data['declined'] ?? []).reversed.toList();
    approvedData = List<Map<dynamic, dynamic>>.from(widget.data['approved'] ?? []).reversed.toList();
    doneData = List<Map<dynamic, dynamic>>.from(widget.data['done'] ?? []).reversed.toList();
  }

  Future<void> _reloadData() async {
    var data = {
      "id": widget.data['junkOwner']['_id'],
      'type': "Junkshop",
    };

    await Api.getHome(context, data);

    setState(() {
      _initializeData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scraps list refreshed successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reloadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle),
                  label: 'Approved',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.hourglass_empty),
                  label: 'Pending',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.cancel),
                  label: 'Cancelled',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.done_all),
                  label: 'Done',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.green.shade800,
              unselectedItemColor: Colors.green.shade600,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reloadData,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    List<Map<dynamic, dynamic>> currentData;
    String title;

    if (_selectedIndex == 1) {
      currentData = pendingData;
      title = 'Pending Records';
    } else if (_selectedIndex == 0) {
      currentData = approvedData;
      title = 'Approved Records';
    } else if (_selectedIndex == 2) {
      currentData = declinedData;
      title = 'Declined Records';
    } else {
      currentData = doneData;
      title = 'Done Records';
    }

    if (currentData.isEmpty) {
      return Center(
        key: ValueKey<int>(_selectedIndex),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No records found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView(
      key: ValueKey<int>(_selectedIndex),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.green),
                onPressed: () {
                  // Add filter functionality here
                },
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.green.shade50),
            dataRowColor: MaterialStateProperty.all(Colors.white),
            columns: const [
              DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Phone No.', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Scrap Type', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: currentData.map((record) {
              return DataRow(
                cells: [
                  DataCell(Text(record['name'] ?? '', style: const TextStyle(color: Colors.black87))),
                  DataCell(Text(record['location'] ?? '', style: const TextStyle(color: Colors.black87))),
                  DataCell(Text(record['phone'] ?? '', style: const TextStyle(color: Colors.black87))),
                  DataCell(Text("${record['weight'] ?? ''} KG", style: const TextStyle(color: Colors.black87))),
                  DataCell(Text(record['scrapType'] ?? '', style: const TextStyle(color: Colors.black87))),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
