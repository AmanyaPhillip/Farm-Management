import 'package:flutter/material.dart';
import 'ImportExportPage.dart'; // Import the ImportExportPage
import 'AddCowPage.dart'; // Import the AddCowPage
import 'CowDetailsPage.dart'; // Import the CowDetailsPage
import 'Database_helper.dart'; // Import the InventoryDatabaseHelper

class MyHomeScreen extends StatefulWidget {
  final int role; // Add a role parameter

  MyHomeScreen({required this.role}); // Constructor to accept role

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final InventoryDatabaseHelper _dbHelper = InventoryDatabaseHelper();
  List<Map<String, dynamic>> _cows = []; // List to store cow data

  @override
  void initState() {
    super.initState();
    _fetchCows(); // Fetch cows from the database when the screen loads
  }

  Future<void> _fetchCows() async {
    final cows = await _dbHelper.getAllCows(); // Fetch all cows from the database
    setState(() {
      _cows = cows; // Update the state with the fetched data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        backgroundColor: Colors.blue, // Set AppBar color to blue
        actions: [
          if (widget.role == 1) // Show the button only for role 1
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Add Cow',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCowPage()),
                );
                _fetchCows(); // Refresh the list after adding a new cow
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _cows.length, // Use the length of the fetched cow list
              itemBuilder: (context, index) {
                final cow = _cows[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 4, // Add shadow to the card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(
                        cow['cow_name'], // Display the cow name
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text('ID: ${cow['cow_id']}'), // Display the cow ID
                      leading: Icon(Icons.pets, color: Colors.blue), // Add an icon
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () async {
                        if (cow.containsKey('cow_name') &&
                            cow.containsKey('cow_id') &&
                            cow.containsKey('farm') &&
                            cow.containsKey('breed')) {
                          // Navigate to CowDetailsPage with the selected cow's data
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CowDetailsPage(
                                cowName: cow['cow_name'],
                                cowId: cow['cow_id'],
                                farm: cow['farm'],
                                cowBreed: cow['breed'], // Pass the required cowBreed parameter
                                role: widget.role, // Pass the role parameter from MyHomeScreen
                              ),
                            ),
                          );
                          // Refresh the list after returning from CowDetailsPage
                          _fetchCows();
                        } else {
                          // Show an error message if required keys are missing
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: Missing cow details')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Money',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.import_export),
            label: 'Import/Export',
          ),
        ],
        selectedItemColor: Colors.white, // Highlight color for selected item
        unselectedItemColor: Colors.white70, // Color for unselected items
        backgroundColor: Colors.blue, // Set the background color to blue
        onTap: (index) {
          if (index == 0) {
            // Navigate to Home
          } else if (index == 1) {
            // Navigate to Money
          } else if (index == 2) {
            // Navigate to Import/Export
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImportExportPage()),
            );
          }
        },
      ),
    );
  }
}