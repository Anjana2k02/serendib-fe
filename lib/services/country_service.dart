import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';

class CountryService {
  static const String _baseUrl = 'https://restcountries.com/v3.1';

  Future<List<Country>> getAllCountries() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/all'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Country> countries = data
            .map((json) => Country.fromJson(json))
            .toList();

        // Sort countries alphabetically by name
        countries.sort((a, b) => a.name.compareTo(b.name));

        return countries;
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      throw Exception('Error fetching countries: $e');
    }
  }
}
