import 'package:flutter/material.dart';
import '../../api/Database_helper.dart';

class InseminationPage extends StatefulWidget {
  final String cowId;
  final int role;

  InseminationPage({required this.cowId, required this.role});

  @override
  _InseminationPageState createState() => _InseminationPageState();
}

class _InseminationPageState extends State<InseminationPage> {
  final List<Map<String, String>> _inseminationHistory = []; // Placeholder for insemination data

  @override
  void initState() {
    super.initState();
    _loadInseminationHistory(); // Load insemination history when the page is opened
  }

  Future<void> _loadInseminationHistory() async {
    final dbHelper = InventoryDatabaseHelper();

    // Fetch the insemination history from the database
    final records = await dbHelper.getInseminationRecords(widget.cowId);

    // Update the local state with the insemination history
    setState(() {
      _inseminationHistory.clear();
      _inseminationHistory.addAll(records.map((record) => {
            'date': record['date'],
            'status': record['status'],
          }));
    });
  }

  Future<void> _addInseminationRecord(String cowId, String date, String status) async {
    final dbHelper = InventoryDatabaseHelper();

    // Insert or update the insemination record in the database
    await dbHelper.insertInsemination(cowId, date, status);

    // Reload the insemination history
    await _loadInseminationHistory();
  }

  void _showAddInseminationDialog(BuildContext context) {
    DateTime? selectedDate;
    String selectedStatus = 'Success'; // Default dropdown value

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Insemination Record'),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedDate != null) {
                      final date = selectedDate!.toIso8601String().split('T')[0];
                      _addInseminationRecord(widget.cowId, date, selectedStatus);
                      Navigator.pop(context); // Close the dialog
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: const Text('Please select a date')),
                      );
                    }
                  },
                  child: const Text('Save'),
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
        title: Text('Insemination ${widget.cowId}'),
        backgroundColor: Colors.blue,
        actions: [
          if (widget.role == 1) // Show the "+" button only for role 1
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Insemination',
              onPressed: () => _showAddInseminationDialog(context),
            ),
        ],
      ),
      body: _inseminationHistory.isEmpty
          ? const Center(child: const Text('No Insemination history found'))
          : ListView.builder(
              itemCount: _inseminationHistory.length,
              itemBuilder: (context, index) {
                final record = _inseminationHistory[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text('Insemination Date: ${record['date']}'),
                    subtitle: Text('Status: ${record['status']}'),
                  ),
                );
              },
            ),
    );
  }
}