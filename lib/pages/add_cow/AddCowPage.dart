import 'dart:math';
import 'package:flutter/material.dart';
import '../../api/Database_helper.dart';
import '../../models/cow_model.dart';

class AddCowPage extends StatefulWidget {
  @override
  _AddCowPageState createState() => _AddCowPageState();
}

class _AddCowPageState extends State<AddCowPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cowNameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
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

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Generate a valid Cow ID
        String cowId = await _generateCowId();

        // Create Cow object
        final cow = Cow(
          id: cowId,
          isAlive: _isAlive,
          name: _cowNameController.text.trim(),
          farm: _selectedFarm,
          breed: _breedController.text.trim(),
        );

        // Insert the cow into the database
        final dbHelper = InventoryDatabaseHelper();
        await dbHelper.insertCow(cow);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cow added successfully! ID: $cowId'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true); // Return true to indicate successful addition
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding cow: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Cow'),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cow Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _cowNameController,
                        decoration: InputDecoration(
                          labelText: 'Cow Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pets),
                        ),
                        validator: (value) => _validateRequired(value, 'Cow Name'),
                        textCapitalization: TextCapitalization.words,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _breedController,
                        decoration: InputDecoration(
                          labelText: 'Breed *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        validator: (value) => _validateRequired(value, 'Breed'),
                        textCapitalization: TextCapitalization.words,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedFarm,
                        decoration: InputDecoration(
                          labelText: 'Farm Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
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
                      Card(
                        color: Colors.grey[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.health_and_safety, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'Status: ${_isAlive ? "Alive" : "Deceased"}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isAlive,
                                onChanged: (value) {
                                  setState(() {
                                    _isAlive = value;
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: Icon(Icons.save),
                label: Text('Add Cow'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cowNameController.dispose();
    _breedController.dispose();
    super.dispose();
  }
}