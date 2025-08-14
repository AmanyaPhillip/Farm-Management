import 'package:flutter/material.dart';
import 'Database_helper.dart'; // Import the database helper

class VaccinationPage extends StatefulWidget {
  final String cowId;
  final int role;

  VaccinationPage({required this.cowId, required this.role});

  @override
  _VaccinationPageState createState() => _VaccinationPageState();
}


class _VaccinationPageState extends State<VaccinationPage> {
  final List<Map<String, String>> _vaccinationHistory = []; // Placeholder for vaccination data

  @override
  void initState() {
    super.initState();
    _loadVaccinationHistory(); // Load vaccination history when the page is opened
  }

  Future<void> _loadVaccinationHistory() async {
    final dbHelper = InventoryDatabaseHelper();

    // Fetch the vaccination history from the database
    final records = await dbHelper.getVaccinationRecords(widget.cowId);

    // Update the local state with the vaccination history
    setState(() {
      _vaccinationHistory.clear();
      _vaccinationHistory.addAll(records.map((record) => {
            'date': record['date'],
            'status': record['status'],
          }));
    });
  }

  Future<void> _addVaccinationRecord(String cowId, String date, String status) async {
    final dbHelper = InventoryDatabaseHelper();

    // Insert or update the vaccination record in the database
    await dbHelper.insertVaccination(cowId, date, status);

    // Reload the vaccination history
    await _loadVaccinationHistory();
  }

  void _showAddVaccinationDialog(BuildContext context) {
    DateTime? selectedDate;
    String selectedStatus = 'Success'; // Default dropdown value

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Vaccination Record'),
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
                      _addVaccinationRecord(widget.cowId, date, selectedStatus);
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
        title: Text('Vaccination ${widget.cowId}'),
        backgroundColor: Colors.blue,
        actions: [
          if (widget.role == 1) // Show the "+" button only for role 1
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Add Vaccination',
              onPressed: () => _showAddVaccinationDialog(context),
            ),
        ],
      ),
      body: _vaccinationHistory.isEmpty
          ? Center(child: Text('No vaccination history found'))
          : ListView.builder(
              itemCount: _vaccinationHistory.length,
              itemBuilder: (context, index) {
                final record = _vaccinationHistory[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text('Vaccination Date: ${record['date']}'),
                    subtitle: Text('Status: ${record['status']}'),
                  ),
                );
              },
            ),
    );
  }
}