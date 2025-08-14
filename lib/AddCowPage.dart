import 'dart:math';
import 'package:flutter/material.dart';
import 'Database_helper.dart';

class AddCowPage extends StatefulWidget {
  @override
  _AddCowPageState createState() => _AddCowPageState();
}

class _AddCowPageState extends State<AddCowPage> {
  final TextEditingController _cowNameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController(); // Controller for breed
  String _selectedFarm = 'Mubende'; // Default value for the dropdown
  bool _isAlive = true; // Default value for "Alive"

  Future<String> _generateCowId() async {
    final dbHelper = InventoryDatabaseHelper();
    String cowId;
    bool exists;

    do {
      // Generate a random 4-digit number and format it as "CWXXXX"
      int randomNumber = Random().nextInt(9000) + 1000; // Ensures a 4-digit number
      cowId = 'CW$randomNumber';

      // Check if the Cow ID already exists in the database
      final cows = await dbHelper.getAllCows();
      exists = cows.any((cow) => cow['cow_id'] == cowId);
    } while (exists); // Repeat until a unique Cow ID is found

    return cowId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Cow'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cowNameController,
              decoration: InputDecoration(
                labelText: 'Cow Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _breedController,
              decoration: InputDecoration(
                labelText: 'Breed',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFarm,
              decoration: InputDecoration(
                labelText: 'Farm Name',
                border: OutlineInputBorder(),
              ),
              items: ['Mubende', 'Ibanda']
                  .map((farm) => DropdownMenuItem(
                        value: farm,
                        child: Text(farm),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFarm = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Alive'),
                Switch(
                  value: _isAlive,
                  onChanged: (value) {
                    setState(() {
                      _isAlive = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Generate a valid Cow ID
                String cowId = await _generateCowId();

                // Insert the cow into the database
                final dbHelper = InventoryDatabaseHelper();
                await dbHelper.insertCow(
                  cowId,
                  _isAlive,
                  _cowNameController.text,
                  _selectedFarm,
                  _breedController.text, // Pass the breed value
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cow added successfully! ID: $cowId')),
                );

                Navigator.pop(context, cowId); // Return the new cow ID
              },
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}