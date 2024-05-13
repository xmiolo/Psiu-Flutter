import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/message.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String otherUserId;

  ChatScreen({required this.userId, required this.otherUserId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  List<Message> _messages = [];
  final _textController = TextEditingController();
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _connectToWebSocket();
  }

  void _loadChatHistory() async {
    try {
      final messages = await _apiService.getChatHistory(widget.userId, widget.otherUserId);
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      print('Error fetching chat history: $e');
      // Show an error message to the user
    }
  }

  void _connectToWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.0.69:8080/chat'), // Replace with your backend's WebSocket URL
    );

    _channel!.stream.listen((message) {
      final newMessage = Message.fromJson(jsonDecode(message));
      setState(() {
        _messages.add(newMessage);
      });
    });
  }

  void _sendMessage() async {
    if (_textController.text.isNotEmpty) {
      final newMessage = Message(
        id: '', // Let the backend generate the ID
        senderId: widget.userId,
        recipientId: widget.otherUserId,
        content: _textController.text,
        timestamp: DateTime.now(),
      );

      try {
        await _apiService.sendMessage(newMessage);
        _textController.clear();
      } catch (e) {
        print('Error sending message: $e');
        // Show an error message to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isOwnMessage = message.senderId == widget.userId;
                return Align(
                  alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isOwnMessage ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('HH:mm').format(message.timestamp),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _textController.dispose();
    super.dispose();
  }
}