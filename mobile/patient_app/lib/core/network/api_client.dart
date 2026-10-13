import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiClient {
  final http.Client client;
  ApiClient({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    final response = await client.post(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('API error: ${response.statusCode}');
  }
}
