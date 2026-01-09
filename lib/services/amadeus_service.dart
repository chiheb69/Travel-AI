import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travel_planner/models/flight.dart';

class AmadeusService {
  final String _baseUrl = 'https://test.api.amadeus.com/v2';
  final String _apiKey = 'dFjuGeyYGYDwnO8c5FpgXa2vLh5jW4wb'; // Placeholder
  final String _apiSecret = 'GM76pje8eePEVFaS'; // Placeholder

  String? _accessToken;
  DateTime? _tokenExpiry; // Keeping this for robust expiry handling

  Future<void> _authenticate() async {
    // If we have a valid token that isn't expired, return
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return;
    }

    final response = await http.post(
      Uri.parse('https://test.api.amadeus.com/v1/security/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'client_credentials',
        'client_id': _apiKey,
        'client_secret': _apiSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      // Handle optional expiry if provided, default to a safe buffer if not
      int expiresIn = data['expires_in'] ?? 1799; 
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
    } else {
      throw Exception('Failed to fetch Amadeus access token');
    }
  }

  Future<List<Flight>> searchFlights({
    required String origin,
    required String destination,
    required String date,
  }) async {
    await _authenticate();

    // Use the clean URI construction from user snippet
    final uri = Uri.parse('$_baseUrl/shopping/flight-offers').replace(queryParameters: {
      'originLocationCode': origin,
      'destinationLocationCode': destination,
      'departureDate': date,
      'adults': '1',
      'max': '10',
    });

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['data'];
      final dictionaries = data['dictionaries'];
      
      // Use our robust model parsing to handle airline names properly
      return results.map((json) => Flight.fromMap(json, dictionaries)).toList();
    } else {
      throw Exception('Failed to load flight offers: ${response.body}');
    }
  }
}
