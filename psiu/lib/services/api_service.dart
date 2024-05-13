import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.69:8080'; // Replace with your Spring Boot API URL
  Future<List<Message>> getChatHistory(String userId1, String userId2) async {

    final response = await http.get(
        Uri.parse('$baseUrl/api/messages/$userId1/$userId2'),
        headers: {'Content-Type': 'application/json',
                  'Accept': '*/*'}
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat history');
    }
  }

  Future<Message> sendMessage(Message message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }
}