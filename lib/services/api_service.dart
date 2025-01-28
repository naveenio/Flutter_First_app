import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_entry.dart';

class ApiService {
  static const String baseUrl = 'https://api.npoint.io/34523c57681b8804e3e2';

  Future<List<ApiEntry>> fetchApiEntries() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Create a list with the single entry
        return [ApiEntry.fromJson(jsonResponse)];
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  // Methods to filter or search specific data
  Future<List<ApiEntry>> searchByUsername(String username) async {
    final entries = await fetchApiEntries();
    return entries
        .where((entry) =>
            entry.username.toLowerCase().contains(username.toLowerCase()))
        .toList();
  }

  Future<List<ApiEntry>> filterProducts({bool? inStock}) async {
    final entries = await fetchApiEntries();
    if (inStock == null) return entries;

    return entries
        .where((entry) =>
            entry.products.any((product) => product.inStock == inStock))
        .toList();
  }
}
