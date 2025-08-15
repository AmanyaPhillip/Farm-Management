import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../api/Database_helper.dart';

class ImportExportPage extends StatelessWidget {
  final InventoryDatabaseHelper _dbHelper = InventoryDatabaseHelper();

  /// Opens file picker to select import file
  Future<void> _importData(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select JSON file to import',
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
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
            SnackBar(
              content: Text('Data imported successfully! ${data.length} cows imported.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected file does not exist'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // User cancelled the picker
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import cancelled'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Requests storage permission
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 30) {
        // Android 11+ (API 30+) - Use MANAGE_EXTERNAL_STORAGE
        var status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      } else {
        // Android 10 and below - Use WRITE_EXTERNAL_STORAGE
        var status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true; // iOS doesn't need explicit storage permission for app documents
  }

  /// Creates the Farm_export directory in a publicly accessible location
  Future<Directory?> _createFarmExportDirectory() async {
    try {
      Directory? directory;
      
      if (Platform.isAndroid) {
        // Try to get external storage directory (like Downloads or Documents)
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Create Farm_export in the external storage
          String farmExportPath = '${directory.path}/Farm_export';
          directory = Directory(farmExportPath);
        } else {
          // Fallback to app documents directory
          directory = await getApplicationDocumentsDirectory();
          String farmExportPath = '${directory.path}/Farm_export';
          directory = Directory(farmExportPath);
        }
      } else {
        // iOS - use documents directory
        directory = await getApplicationDocumentsDirectory();
        String farmExportPath = '${directory.path}/Farm_export';
        directory = Directory(farmExportPath);
      }
      
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      return directory;
    } catch (e) {
      print('Error creating directory: $e');
      return null;
    }
  }

  /// Exports data to the Farm_export folder with timestamp
  Future<void> _exportData(BuildContext context) async {
    try {
      // Check and request permissions first
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Storage permission required to export files'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      }

      List<Map<String, dynamic>> items = await _dbHelper.getAllCows();
      
      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No data to export'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Create Farm_export directory
      Directory? farmExportDirectory = await _createFarmExportDirectory();
      if (farmExportDirectory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create export directory'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Generate filename with timestamp
      String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      String fileName = 'inventory_export_$timestamp.json';
      String filePath = '${farmExportDirectory.path}/$fileName';

      // Export data
      String jsonContent = jsonEncode(items);
      File file = File(filePath);
      await file.writeAsString(jsonContent);

      // Verify file was created
      if (await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully!\n${items.length} cows exported to:\n$filePath'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export completed but file verification failed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import/Export'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Import Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.file_download,
                      size: 48,
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Import Data',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Import cow data by selecting any JSON file from your device',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _importData(context),
                      icon: Icon(Icons.file_download),
                      label: Text('Import'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 32),
            
            // Export Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.file_upload,
                      size: 48,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Export Data',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Export all cow data to Farm_export folder with timestamp',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _exportData(context),
                      icon: Icon(Icons.file_upload),
                      label: Text('Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 32),
            
            // Info Section
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Import: Select any JSON file from your device storage',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Export: Automatically saves to Documents/Farm_export/ with timestamp',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Importing will replace all existing cow data',
                      style: TextStyle(fontSize: 12, color: Colors.red[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}