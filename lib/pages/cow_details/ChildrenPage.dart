import 'package:flutter/material.dart';
import 'dart:convert';
import '../../api/Database_helper.dart';
import '../add_cow/AddCowPage.dart';

class ChildrenPage extends StatefulWidget {
  final String cowId;
  final int role;

  ChildrenPage({required this.cowId, required this.role});

  @override
  _ChildrenPageState createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {
  final InventoryDatabaseHelper _dbHelper = InventoryDatabaseHelper();
  List<Map<String, String>> _children = []; // List to store child details (ID and name)

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final familyTreeRecord = await _dbHelper.getFamilyTreeRecord(widget.cowId);
    if (familyTreeRecord != null) {
      final kids = List<String>.from(
        (familyTreeRecord['kids'] != null)
            ? jsonDecode(familyTreeRecord['kids']) // Decode JSON string into a list
            : [],
      );

      // Fetch child details from the inventory table
      final List<Map<String, String>> childrenDetails = [];
      for (String childId in kids) {
        final childRecord = await _dbHelper.getCowById(childId);
        if (childRecord != null) {
          childrenDetails.add({
            'id': childId,
            'name': childRecord['cow_name'] ?? 'Unknown',
          });
        }
      }

      setState(() {
        _children = childrenDetails; // Assign the processed list of maps
      });
    }
  }

  Future<void> _addChild(String newCowId) async {
    final familyTreeRecord = await _dbHelper.getFamilyTreeRecord(widget.cowId);
    if (familyTreeRecord != null) {
      final kids = List<String>.from(
        (familyTreeRecord['kids'] != null)
            ? jsonDecode(familyTreeRecord['kids']) // Decode JSON string into a list
            : [],
      );
      kids.add(newCowId);
      await _dbHelper.insertFamilyTreeRecord(
        widget.cowId,
        familyTreeRecord['parent1'],
        familyTreeRecord['parent2'],
        kids,
      );
      _loadChildren(); // Refresh the list of children
    }
  }

  void _navigateToAddCowPage() async {
    final newCowId = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCowPage(),
      ),
    );
    if (newCowId != null) {
      await _addChild(newCowId);
      _loadChildren(); // Reload the data after adding a new child
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowId}\'s Children'),
        backgroundColor: Colors.blue,
        actions: [
          if (widget.role == 1)
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Add Child',
              onPressed: _navigateToAddCowPage,
            ),
        ],
      ),
      body: _children.isEmpty
          ? Center(child: Text('No children found'))
          : ListView.builder(
              itemCount: _children.length,
              itemBuilder: (context, index) {
                final child = _children[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 4, // Add shadow to the card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(
                        child['name'] ?? 'Unknown', // Display the child's name
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text('ID: ${child['id']}'), // Display the child ID
                      leading: Icon(Icons.pets, color: Colors.blue), // Add an icon
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }
}