import 'package:flutter/material.dart';
import '../models/api_entry.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ApiEntry>> _apiEntriesFuture;
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  bool _showUserSection = true;
  bool _showBasicValuesSection = true;
  bool _showArraySection = true;
  bool _showNestedObjectSection = true;
  bool _showProductsSection = true;

  @override
  void initState() {
    super.initState();
    _apiEntriesFuture = _apiService.fetchApiEntries();
  }

  void _toggleSection(StateSetter setState, String section) {
    switch (section) {
      case 'user':
        setState(() => _showUserSection = !_showUserSection);
        break;
      case 'basicValues':
        setState(() => _showBasicValuesSection = !_showBasicValuesSection);
        break;
      case 'array':
        setState(() => _showArraySection = !_showArraySection);
        break;
      case 'nestedObject':
        setState(() => _showNestedObjectSection = !_showNestedObjectSection);
        break;
      case 'products':
        setState(() => _showProductsSection = !_showProductsSection);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile Info'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<List<ApiEntry>>(
        future: _apiEntriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          }

          final entry = snapshot.data!.first;
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // User Information Section
              if (_showUserSection) _buildUserSection(entry),

              // Basic Values Section
              if (_showBasicValuesSection) _buildBasicValuesSection(entry),

              // Array Section
              if (_showArraySection) _buildArraySection(entry),

              // Nested Object Section
              if (_showNestedObjectSection) _buildNestedObjectSection(entry),

              // Products Section
              if (_showProductsSection) _buildProductsSection(entry),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String sectionKey) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
        // IconButton(
        //   icon: const Icon(Icons.close),
        //   onPressed: () => setState(() => _toggleSection(setState, sectionKey)),
        // ),
      ],
    );
  }

  Widget _buildUserSection(ApiEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('User Information', 'user'),
        _buildInfoTile('Username', entry.username),
        _buildInfoTile('Email', entry.email),
        _buildInfoTile('User ID', entry.userId.toString()),
        _buildInfoTile('Active Status', entry.isActive ? 'Active' : 'Inactive'),
        _buildInfoTile('Registration Date', entry.registrationDate),
        Divider(),
      ],
    );
  }

  Widget _buildBasicValuesSection(ApiEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Basic Values', 'basicValues'),
        _buildInfoTile('String Value', entry.stringValue),
        _buildInfoTile('Integer Value', entry.integerValue.toString()),
        _buildInfoTile('Float Value', entry.floatValue.toString()),
        _buildInfoTile('Boolean Value', entry.booleanValue.toString()),
        Divider(),
      ],
    );
  }

  Widget _buildArraySection(ApiEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Array Value', 'array'),
        Text('Array: ${entry.arrayValue}'),
        Divider(),
      ],
    );
  }

  Widget _buildNestedObjectSection(ApiEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Nested Object', 'nestedObject'),
        Text('Nested Object: ${entry.nestedObject}'),
        Divider(),
      ],
    );
  }

  Widget _buildProductsSection(ApiEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Products', 'products'),
        Column(
          children: entry.products
              .map((product) => ListTile(
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: \$${product.price}'),
                        Text('Percentage: \$${product.percent}'),
                      ],
                    ),
                    trailing:
                        Text(product.inStock ? 'In Stock' : 'Out of Stock'),
                    onTap: () => _showProductDetails(context, product),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Toggle Sections'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleSwitch(
                      setState,
                      'User Information',
                      _showUserSection,
                      (bool value) => _toggleSection(setState, 'user')),
                  _buildToggleSwitch(
                      setState,
                      'Basic Values',
                      _showBasicValuesSection,
                      (bool value) => _toggleSection(setState, 'basicValues')),
                  _buildToggleSwitch(setState, 'Array', _showArraySection,
                      (bool value) => _toggleSection(setState, 'array')),
                  _buildToggleSwitch(
                      setState,
                      'Nested Object',
                      _showNestedObjectSection,
                      (bool value) => _toggleSection(setState, 'nestedObject')),
                  _buildToggleSwitch(setState, 'Products', _showProductsSection,
                      (bool value) => _toggleSection(setState, 'products')),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildToggleSwitch(StateSetter setState, String title,
      bool currentValue, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: currentValue,
      onChanged: (bool value) {
        onChanged(value);
      },
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product.name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoTile('Product ID', product.productId.toString()),
              _buildInfoTile('Name', product.name),
              _buildInfoTile('Price', '\$${product.price}'),
              _buildInfoTile('Stock Status',
                  product.inStock ? 'In Stock' : 'Out of Stock'),
              _buildInfoTile('Percentage', product.percent.toString()),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
