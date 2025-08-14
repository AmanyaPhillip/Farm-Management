import 'package:flutter/material.dart';
import 'Database_helper.dart'; // Import the database helper

class DippingPage extends StatefulWidget {
  final String cowId;
  final int role;

  DippingPage({required this.cowId, required this.role});

  @override
  _DippingPageState createState() => _DippingPageState();
}

class _DippingPageState extends State<DippingPage> {
  final List<Map<String, String>> _dippingHistory = []; // Placeholder for dipping data

  @override
  void initState() {
    super.initState();
    _loadDippingHistory(); // Load dipping history when the page is opened
  }

  Future<void> _loadDippingHistory() async {
    final dbHelper = InventoryDatabaseHelper();

    // Fetch the dipping history from the database
    final records = await dbHelper.getDippingRecords(widget.cowId);

    // Update the local state with the dipping history
    setState(() {
      _dippingHistory.clear();
      _dippingHistory.addAll(records.map((record) => {
            'date': record['date'],
            'status': record['status'],
          }));
    });
  }

  Future<void> _addDippingRecord(String cowId, String date, String status) async {
    final dbHelper = InventoryDatabaseHelper();

    // Insert or update the dipping record in the database
    await dbHelper.insertDipping(cowId, date, status);

    // Reload the dipping history
    await _loadDippingHistory();
  }

  void _showAddDippingDialog(BuildContext context) {
    DateTime? selectedDate;
    String selectedStatus = 'Success'; // Default dropdown value

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Dipping Record'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      selectedDate == null
                          ? 'Select Date'
                          : 'Selected: ${selectedDate!.toIso8601String().split('T')[0]}',
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Success', 'Fail', 'N/A']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Close the dialog
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedDate != null) {
                      final date = selectedDate!.toIso8601String().split('T')[0];
                      _addDippingRecord(widget.cowId, date, selectedStatus);
                      Navigator.pop(context); // Close the dialog
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a date')),
                      );
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dipping ${widget.cowId}'),
        backgroundColor: Colors.blue,
        actions: [
          if (widget.role == 1) // Show the "+" button only for role 1
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Add Dipping',
              onPressed: () => _showAddDippingDialog(context),
            ),
        ],
      ),
      body: _dippingHistory.isEmpty
          ? Center(child: Text('No dipping history found'))
          : ListView.builder(
              itemCount: _dippingHistory.length,
              itemBuilder: (context, index) {
                final record = _dippingHistory[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text('Dipping Date: ${record['date']}'),
                    subtitle: Text('Status: ${record['status']}'),
                  ),
                );
              },
            ),
    );
  }
}