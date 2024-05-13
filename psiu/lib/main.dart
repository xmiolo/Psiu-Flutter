import 'package:flutter/material.dart';
import 'package:psiu/screen/chat_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Psiu Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(
        userId: 'gregori123', // Replace with the actual user ID
        otherUserId: 'marina123', // Replace with the ID of the other user in the chat
      ),
    );
  }
}