//lin/data/chat model
import 'package:flutter/material.dart';
import 'mock_data.dart'; // Import the User model

// Enum to define who sent the message
enum MessageSender { me, other }

class ChatMessage {
  final String text;
  final DateTime timestamp;
  final MessageSender sender;

  ChatMessage({
    required this.text,
    required this.timestamp,
    required this.sender,
  });
}