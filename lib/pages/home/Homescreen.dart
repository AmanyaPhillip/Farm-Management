import 'package:flutter/material.dart';
import '../import_export/ImportExportPage.dart';
import '../add_cow/AddCowPage.dart';
import '../cow_details/CowDetailsPage.dart';
import '../../api/Database_helper.dart';
import '../../models/cow_model.dart';

class MyHomeScreen extends StatefulWidget {
  final int role; // Add a role parameter

  MyHomeScreen({required this.role}); // Constructor to accept role

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final InventoryDatabaseHelper _dbHelper = InventoryDatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  List<Cow> _allCows = []; // Store all cows
  List<Cow> _filteredCows = []; // Store filtered cows for display
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCows();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCows() async {
    setState(() => _isLoading = true);
    try {
      final cows = await _dbHelper.getAllCowsAsModels();
      setState(() {
        _allCows = cows;
        _filteredCows = cows;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading cows: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredCows = _allCows;
      } else {
        _filteredCows = _allCows.where((cow) {
          return cow.name.toLowerCase().contains(query) ||
                 cow.id.toLowerCase().contains(query) ||
                 cow.breed.toLowerCase().contains(query) ||
                 cow.farm.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  Future<void> _navigateToAddCow() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCowPage()),
    );
    if (result == true) {
      await _fetchCows(); // Refresh the list
    }
  }

  Future<void> _navigateToCowDetails(Cow cow) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CowDetailsPage(
          cowName: cow.name,
          cowId: cow.id,
          farm: cow.farm,
          cowBreed: cow.breed,
          role: widget.role,
        ),
      ),
    );
    await _fetchCows(); // Refresh data after returning
  }

  Widget _buildCowCard(Cow cow) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => _navigateToCowDetails(cow),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cow.isAlive ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pets,
                  color: cow.isAlive ? Colors.green : Colors.red,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cow.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID: ${cow.id}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                        SizedBox(width: 4),
                        Text(
                          cow.farm,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.category, size: 14, color: Colors.grey[500]),
                        SizedBox(width: 4),
                        Text(
                          cow.breed,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cow.isAlive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      cow.isAlive ? 'Alive' : 'Deceased',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cow Management'),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          if (widget.role == 1)
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Add Cow',
              onPressed: _navigateToAddCow,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID, breed, or farm...',
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredCows.length} cow${_filteredCows.length != 1 ? 's' : ''} found',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      Text(
                        'Searching: "${_searchController.text}"',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Content Section
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.blue),
                        SizedBox(height: 16),
                        Text('Loading cows...'),
                      ],
                    ),
                  )
                : _filteredCows.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _allCows.isEmpty ? Icons.pets_outlined : Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              _allCows.isEmpty 
                                  ? 'No cows added yet'
                                  : 'No cows match your search',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _allCows.isEmpty 
                                  ? 'Tap the + button to add your first cow'
                                  : 'Try adjusting your search terms',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchCows,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredCows.length,
                          itemBuilder: (context, index) {
                            return _buildCowCard(_filteredCows[index]);
                          },
                        ),
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
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.blue,
        onTap: (index) {
          if (index == 0) {
            // Already on Home
          } else if (index == 1) {
            // Navigate to Money (not implemented)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Money feature coming soon!')),
            );
          } else if (index == 2) {
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