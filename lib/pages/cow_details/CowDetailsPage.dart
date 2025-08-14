import 'package:flutter/material.dart';
import '../../api/Database_helper.dart';
import 'VaccinationPage.dart';
import 'DippingPage.dart';
import 'MilkPage.dart';
import 'ChildrenPage.dart';

class CowDetailsPage extends StatefulWidget {
  final String cowName;
  final String cowId;
  final String farm;
  final String cowBreed;
  final int role; // Add role to check user permissions

  CowDetailsPage({
    required this.cowName,
    required this.cowId,
    required this.farm,
    required this.cowBreed,
    required this.role,
  });

  @override
  _CowDetailsPageState createState() => _CowDetailsPageState();
}

class _CowDetailsPageState extends State<CowDetailsPage> {
  final InventoryDatabaseHelper _dbHelper = InventoryDatabaseHelper();
  Map<String, dynamic>? _cowDetails;
  String? latestVaccinationDate;
  String? latestDippingDate;
  double totalMilkLiters = 0.0; // Initialize totalMilkLiters

  @override
  void initState() {
    super.initState();
    _fetchCowDetails(); // Fetch cow details when the page loads
  }

  Future<void> _fetchCowDetails() async {
    try {
      final cows = await _dbHelper.getAllCows();
      final cow = cows.firstWhere((c) => c['cow_id'] == widget.cowId, orElse: () => {});

      String? latestVaccinationDate;
      String? latestDippingDate;
      double totalMilkLiters = 0.0;
      String? parent1;
      String? parent2;

      if (cow != null) {
        // Fetch vaccination records for the cow
        final vaccinationRecords = await _dbHelper.getVaccinationRecords(widget.cowId);

        // Find the most recent vaccination date
        if (vaccinationRecords.isNotEmpty) {
          latestVaccinationDate = vaccinationRecords
              .map((record) => DateTime.parse(record['date']))
              .reduce((a, b) => a.isAfter(b) ? a : b)
              .toIso8601String()
              .split('T')[0]; // Format as YYYY-MM-DD
        }

        // Fetch dipping records for the cow
        final dippingRecords = await _dbHelper.getDippingRecords(widget.cowId);

        // Find the most recent dipping date
        if (dippingRecords.isNotEmpty) {
          latestDippingDate = dippingRecords
              .map((record) => DateTime.parse(record['date']))
              .reduce((a, b) => a.isAfter(b) ? a : b)
              .toIso8601String()
              .split('T')[0]; // Format as YYYY-MM-DD
        }

        // Fetch milk records for the cow
        final milkRecords = await _dbHelper.getMilkRecords(widget.cowId);

        // Calculate the total liters of milk
        if (milkRecords.isNotEmpty) {
          totalMilkLiters = milkRecords.fold(
            0.0,
            (sum, record) => sum + (record['liters'] as double),
          );
        }

        // Fetch parent details from FamilyTreeTable
        final familyTreeRecord = await _dbHelper.getFamilyTreeRecord(widget.cowId);
        if (familyTreeRecord != null) {
          parent1 = familyTreeRecord['parent1'];
          parent2 = familyTreeRecord['parent2'];
        }

        setState(() {
          _cowDetails = {
            ...cow,
            'latestVaccinationDate': latestVaccinationDate,
            'latestDippingDate': latestDippingDate,
            'totalMilkLiters': totalMilkLiters, // Add total milk liters
            'parent1': parent1,
            'parent2': parent2,
          };
        });
      } else {
        setState(() {
          _cowDetails = null; // Set to null if cow is not found
        });
      }
    } catch (e) {
      // Handle any errors that occur during the fetch
      setState(() {
        _cowDetails = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching cow details: $e')),
      );
    }
  }

  void _showEditDialog(BuildContext context, String field, String currentValue, Function(String) onSave) {
    final TextEditingController _controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(16.0), // Add padding to prevent overflow
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit $field',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'New $field',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Close the dialog
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final newValue = _controller.text.trim();
                          if (newValue.isNotEmpty) {
                            await onSave(newValue); // Save the new value
                            Navigator.pop(context); // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$field updated successfully!')),
                            );
                            _fetchCowDetails(); // Reload cow details
                          }
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditParentsDialog(BuildContext context) {
    final TextEditingController parent1Controller = TextEditingController();
    final TextEditingController parent2Controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Parents'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: parent1Controller,
                decoration: InputDecoration(
                  labelText: 'Parent 1 Cow ID',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: parent2Controller,
                decoration: InputDecoration(
                  labelText: 'Parent 2 Cow ID',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final parent1 = parent1Controller.text.trim();
                final parent2 = parent2Controller.text.trim();

                if (parent1.isEmpty || parent2.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Both Parent 1 and Parent 2 must be provided')),
                  );
                  return;
                }

                if (parent1 == parent2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Parent 1 and Parent 2 cannot be the same')),
                  );
                  return;
                }

                try {
                  // Insert or update the family tree record in the database
                  await _dbHelper.insertFamilyTreeRecord(
                    widget.cowId,
                    parent1,
                    parent2,
                    [], // Empty list for kids (can be updated later)
                  );

                  Navigator.pop(context); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Parents updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating parents: $e')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cowDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Cow Details - ${widget.cowId}'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Text(
            'No details found for this cow.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Ensure the layout adjusts for the keyboard
        appBar: AppBar(
          title: Text('Cow Details - ${widget.cowId}'),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView( // Make the content scrollable
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Cow Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_cowDetails?['cow_name'] ?? widget.cowName),
                    onTap: widget.role == 1
                        ? () {
                            _showEditDialog(
                              context,
                              'Cow Name',
                              _cowDetails?['cow_name'] ?? widget.cowName,
                              (newValue) async {
                                await _dbHelper.updateCowName(widget.cowId, newValue);
                              },
                            );
                          }
                        : null, // Disable tap for non-role 1 users
                  ),
                ),
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Cow Breed',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_cowDetails?['breed'] ?? widget.cowBreed),
                    onTap: widget.role == 1
                        ? () {
                            _showEditDialog(
                              context,
                              'Cow Breed',
                              _cowDetails?['breed'] ?? widget.cowBreed,
                              (newValue) async {
                                await _dbHelper.updateCowBreed(widget.cowId, newValue);
                              },
                            );
                          }
                        : null, // Disable tap for non-role 1 users
                  ),
                ),
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Farm',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_cowDetails?['farm'] ?? widget.farm),
                    onTap: widget.role == 1
                        ? () {
                            _showEditDialog(
                              context,
                              'Farm',
                              _cowDetails?['farm'] ?? widget.farm,
                              (newValue) async {
                                await _dbHelper.updateCowFarm(widget.cowId, newValue);
                              },
                            );
                          }
                        : null, // Disable tap for non-role 1 users
                  ),
                ),
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Last Vaccinated: ${_cowDetails?['latestVaccinationDate'] ?? 'No vaccination history'}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('View vaccination history'),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VaccinationPage(
                            cowId: widget.cowId,
                            role: widget.role,
                          ),
                        ),
                      );
                      // Refresh data when returning from the VaccinationPage
                      _fetchCowDetails();
                    },
                  ),
                ),
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Last Dipped: ${_cowDetails?['latestDippingDate'] ?? 'No dipping history'}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('View dipping history'),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DippingPage(
                            cowId: widget.cowId,
                            role: widget.role,
                          ),
                        ),
                      );
                      // Refresh data when returning from the DippingPage
                      _fetchCowDetails();
                    },
                  ),
                ),
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Milk: ${_cowDetails?['totalMilkLiters']?.toStringAsFixed(2) ?? '0.00'} liters',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('View milk records'),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MilkPage(
                            cowId: widget.cowId,
                            role: widget.role,
                          ),
                        ),
                      );
                      // Refresh data when returning from the MilkPage
                      _fetchCowDetails();
                    },
                  ),
                ),
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Parents',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Parent 1: ${_cowDetails?['parent1'] ?? 'Not available'}\n'
                      'Parent 2: ${_cowDetails?['parent2'] ?? 'Not available'}',
                    ),
                    onTap: widget.role == 1
                        ? () {
                            _showEditParentsDialog(context);
                          }
                        : null, // Disable tap for non-role 1 users
                  ),
                ),
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Children',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('View children'), // Updated subtitle text
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChildrenPage(
                            cowId: widget.cowId,
                            role: widget.role,
                          ),
                        ),
                      );
                      // Refresh data when returning from the ChildrenPage
                      _fetchCowDetails();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}