import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../api/Database_helper.dart';

class ImportExportPage extends StatelessWidget {
  final InventoryDatabaseHelper _dbHelper = InventoryDatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import/Export'),
        backgroundColor: Colors.blue, // Set AppBar color to blue
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Handle import functionality
                try {
                  Directory directory = await getApplicationDocumentsDirectory();
                  String filePath = '${directory.path}/inventory_import.json';
                  File file = File(filePath);

                  if (await file.exists()) {
                    String content = await file.readAsString();
                    List<dynamic> data = jsonDecode(content);

                    // Clear existing inventory and insert new data
                    await _dbHelper.clearInventory();
                    for (var item in data) {
                      await _dbHelper.insertCowLegacy(
                        item['cow_id'],
                        item['alive'] == 1, // Convert integer to boolean
                        item['cow_name'],
                        item['farm'],
                        item['breed'] ?? item['additional_field'] ?? '', // Handle both field names
                      );
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Data imported successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Import file not found at $filePath')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error importing data: $e')),
                  );
                }
              },
              child: Text('Import'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            SizedBox(height: 20), // Add spacing between buttons
            ElevatedButton(
              onPressed: () async {
                // Handle export functionality
                try {
                  List<Map<String, dynamic>> items = await _dbHelper.getAllCows();
                  String jsonContent = jsonEncode(items);

                  Directory directory = await getApplicationDocumentsDirectory();
                  String filePath = '${directory.path}/inventory_export.json';
                  File file = File(filePath);
                  await file.writeAsString(jsonContent);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Data exported to $filePath')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error exporting data: $e')),
                  );
                }
              },
              child: Text('Export'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}