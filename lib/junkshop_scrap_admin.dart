import 'package:flutter/material.dart';

class ScrapPriceScreen extends StatelessWidget {
  final Map data; // Data containing the scrap prices

  ScrapPriceScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assuming data['adminscrap'] is a list of maps with 'scrapType' and 'pricePerKilo'
    List<Map<String, dynamic>> scrapPrices = List<Map<String, dynamic>>.from(data['adminscrap']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AJCD Scrap Prices'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Header Section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text(
                  'Current Scrap Prices',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.0, // Increased font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Changed text color to white
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              // Container for DataTable
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // Shadow position
                    ),
                  ],
                  border: Border.all(color: Colors.greenAccent, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: DataTable(
                    columnSpacing: 24.0,
                    headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.green.shade200,
                    ),
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Scrap Type',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Price per Kilo (₱)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                    rows: scrapPrices.map((scrap) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Text(
                              scrap['scrapType'] ?? 'N/A',
                              style: const TextStyle(fontSize: 14.0),
                            ),
                          ),
                          DataCell(
                            Text(
                              scrap['pointsEquivalent']?.toString() ?? '0.00',
                              style: const TextStyle(fontSize: 14.0),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
