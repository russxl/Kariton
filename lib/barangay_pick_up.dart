import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Kariton/api/api.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'junkshop_main.dart';

class BarangayBookingPage extends StatefulWidget {
  final Map data;

  const BarangayBookingPage({Key? key, required this.data}) : super(key: key);

  @override
  _BarangayBookingPageState createState() => _BarangayBookingPageState();
}

class _BarangayBookingPageState extends State<BarangayBookingPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _scrapType;
  String? _weight;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  late PageController _pageController;

  // Define GlobalKeys for form validation
  final _formKeyPersonalInfo = GlobalKey<FormState>();
  final _formKeyScrapDetails = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  // Phone number validation function
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    } else if (!RegExp(r'^09\d{9}$').hasMatch(value)) {
      return 'Please enter a valid Philippine phone number (11 digits, starting with 09)';
    }
    return null;
  }

  // Weight validation function
  String? _validateWeight(String? value) {
    final weightValue = double.tryParse(value ?? '0') ?? 0;
    if (value == null || value.isEmpty) {
      return 'Please enter the weight';
    } else if (weightValue < 100) {
      return 'Pickup request is only allowed for 100 kg or more.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Barangay Booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBookingForm(),
                _buildScrapDetailsPage(),
                _buildPersonalInformationPage(),
                _buildAccurateInformationPage(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 4,
              effect: const WormEffect(
                dotColor: Colors.grey,
                activeDotColor: Colors.green,
                dotHeight: 10,
                dotWidth: 10,
                spacing: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingForm() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        const Text(
          'Schedule For Pickup',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Choose what time and date',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Date *',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(), // Prevent past dates
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                _selectedDate = pickedDate;
              });
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: _selectedDate == null
                    ? 'Select Date'
                    : '${_selectedDate!.toLocal()}'.split(' ')[0],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Time *',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: _selectedTime ?? TimeOfDay.now(),
            );
            if (pickedTime != null) {
              final now = TimeOfDay.now();
              if (_selectedDate == DateTime.now().toLocal() &&
                  pickedTime.hour <= now.hour &&
                  pickedTime.minute <= now.minute) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a time in the future.'),
                  ),
                );
              } else {
                setState(() {
                  _selectedTime = pickedTime;
                });
              }
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: _selectedTime == null
                    ? 'Select Time'
                    : '${_selectedTime!.format(context)}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_selectedDate == null || _selectedTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select both date and time'),
                ),
              );
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 16.0,
            ),
          ),
          child: const Text(
            'Next',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrapDetailsPage() {
    return Form(
      key: _formKeyScrapDetails,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Text(
            'Scrap Details',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select the type of scrap and enter weight',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Type of Scrap *',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            items: (widget.data["junkScrap"] as List<dynamic>)
                .map((scrapType) {
              return DropdownMenuItem<String>(
                value: scrapType['scrapType'].toString(),
                child: Text(scrapType['scrapType'].toString()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _scrapType = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a scrap type';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Weight *',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Enter Weight (kg)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              helperText:
                  'Note: Pickup request is only allowed for 100 kg or more.',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (value) {
              setState(() {
                _weight = value;
              });
            },
            validator: _validateWeight,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKeyScrapDetails.currentState!.validate()) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please correct the errors in the form'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Next', style: TextStyle(fontSize: 16.0)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationPage() {
    return Form(
      key: _formKeyPersonalInfo,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Name *',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Enter Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Phone Number *',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _phoneNumberController,
            decoration: InputDecoration(
              labelText: 'Enter Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: _validatePhone,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKeyPersonalInfo.currentState!.validate()) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please correct the errors in the form'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 18.0,
                horizontal: 16.0,
              ),
            ),
            child: const Text(
              'Next',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccurateInformationPage() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        const Text(
          'Accurate Information',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Please double-check your information before submitting',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Any comments or additional information?',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _commentsController,
          decoration: InputDecoration(
            labelText: 'Enter any comments',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            // Gather all the data
            print(widget.data['junkshopID']);
            var data = {
              "name": _nameController.text,
              "phone": _phoneNumberController.text,
              "date": _selectedDate?.toLocal().toString().split(' ')[0],
              "time": _selectedTime?.format(context),
              "scrapType": _scrapType,
              "weight": _weight,
              "junkID": widget.data['junkShop']["_id"],
              "comments": _commentsController.text,
              'id': widget.data['barangay']['_id'],
              "location": widget.data['barangay']['bLocation'],
              'usertype':"Barangay"
            };
  print( widget.data['barangay']['bLocation']);
            // Call the API
            final result = await Api.pickUp(context, data);

            if (result) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Pending Pickup Request - you can check the status in the history.'),
                  duration: Duration(seconds: 3),
                ),
              );
              // Navigate back or to another page if necessary
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Failed to submit pickup request. Please try again.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 16.0,
            ),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }
}
