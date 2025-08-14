import 'package:flutter/material.dart';
import '../../api/Database_helper.dart';

class MilkPage extends StatefulWidget {
  final String cowId;
  final int role;

  MilkPage({required this.cowId, required this.role});

  @override
  _MilkPageState createState() => _MilkPageState();
}

class _MilkPageState extends State<MilkPage> {
  final List<Map<String, dynamic>> _milkHistory = []; // Placeholder for milk data

  @override
  void initState() {
    super.initState();
    _loadMilkHistory(); // Load milk history when the page is opened
  }

  Future<void> _loadMilkHistory() async {
    final dbHelper = InventoryDatabaseHelper();

    // Fetch the milk history from the database
    final records = await dbHelper.getMilkRecords(widget.cowId);

    // Update the local state with the milk history
    setState(() {
      _milkHistory.clear();
      _milkHistory.addAll(records);
    });
  }

  Future<void> _addMilkRecord(String cowId, String date, double liters) async {
    final dbHelper = InventoryDatabaseHelper();

    // Insert or update the milk record in the database
    await dbHelper.insertMilk(cowId, date, liters);

    // Reload the milk history
    await _loadMilkHistory();
  }

  void _showAddMilkDialog(BuildContext context) {
    DateTime? selectedDate;
    final TextEditingController litersController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Milk Record'),
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
                  TextField(
                    controller: litersController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Liters',
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
                  onPressed: () {
                    if (selectedDate != null && litersController.text.isNotEmpty) {
                      final date = selectedDate!.toIso8601String().split('T')[0];
                      final liters = double.tryParse(litersController.text) ?? 0.0;
                      _addMilkRecord(widget.cowId, date, liters);
                      Navigator.pop(context); // Close the dialog
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a date and enter liters')),
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
        title: Text('Milk - ${widget.cowId}'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add Milk',
            onPressed: () => _showAddMilkDialog(context),
          ),
        ],
      ),
      body: _milkHistory.isEmpty
          ? Center(child: Text('No milk records found'))
          : ListView.builder(
              itemCount: _milkHistory.length,
              itemBuilder: (context, index) {
                final record = _milkHistory[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text('Date: ${record['date']}'),
                    subtitle: Text('Liters: ${record['liters']}'),
                  ),
                );
              },
            ),
    );
  }
}