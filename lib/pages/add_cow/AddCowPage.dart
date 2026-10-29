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
  final TextEditingController _cowDoBController = TextEditingController();
  final TextEditingController _cowIdController =
    TextEditingController(text: 'MAF-');
  final TextEditingController _breedController =
    TextEditingController(text: 'Holstein Friesian');
  bool _isAlive = true; // Default value for "Alive"
  bool _isFemale = true; // Default value for "Female"
  DateTime? _dob;

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {

        // Create Cow object
        final cow = Cow(
          id: _cowIdController.text.trim(),
          isAlive: _isAlive,
          name: _cowNameController.text.trim(),
          breed: _breedController.text.trim(),
          isFemale: _isFemale,
        );

        // Insert the cow into the database
        final dbHelper = InventoryDatabaseHelper();
        await dbHelper.insertCow(cow);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cow added successfully! ID: ${cow.id}'),
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
        title: const Text('Add Cow'),
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
                      const Text(
                        'Cow Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cowNameController,
                        decoration: const InputDecoration(
                          labelText: 'Cow Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pets),
                        ),
                        validator: (value) => _validateRequired(value, 'Cow Name'),
                        textCapitalization: TextCapitalization.words,
                      ),

                      const SizedBox(height: 16),

                      Card(
                        color: Colors.grey[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.date_range_rounded, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(
                                    _dob == null
                                        ? 'Date of Birth'
                                        : 'DOB: ${_dob!.toIso8601String().split('T')[0]}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _dob ?? DateTime.now(),
                                    firstDate: DateTime(1980),
                                    lastDate: DateTime.now(),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      _dob = pickedDate;
                                    });
                                  }
                                },
                                child: const Text('Select'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cowIdController,
                        decoration: const InputDecoration(
                          labelText: 'Cow ID *',
                          hintText: 'MAF-X-XX-XX-XXX',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.tag),
                        ),
                        validator: (value) => _validateRequired(value, 'Cow ID'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _breedController,
                        decoration: const InputDecoration(
                          labelText: 'Breed *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        validator: (value) => _validateRequired(value, 'Breed'),
                        textCapitalization: TextCapitalization.words,
                      ),
                      
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.grey[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.health_and_safety, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Status: ${_isAlive ? "Alive" : "Deceased"}',
                                    style: const TextStyle(
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
                      activeThumbColor: Colors.green,
                    ),
                    ],
                    ),
                    ),
                    ),
                    Card(
                        color: Colors.grey[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.female, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Gender: ${_isFemale ? "Female" : "Male"}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isFemale,
                                onChanged: (value) {
                                  setState(() {
                                    _isFemale = value;
                                  });
                                },
                                activeThumbColor: const Color.fromARGB(255, 187, 102, 215),
                                inactiveThumbColor: const Color.fromARGB(255, 40, 173, 255),
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
    _cowIdController.dispose();
    _cowDoBController.dispose();
    super.dispose();
  }
}