import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../data/chat_model.dart'; // Import the ChatMessage model
import '../state/app_controller.dart';

// Helper Widget for a single chat bubble
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.sender == MessageSender.me;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = isMe ? Colors.blue.shade600 : Colors.grey.shade300;
    final textColor = isMe ? Colors.white : Colors.black;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

/// The main interactive Chat Screen
class ChatScreen extends StatefulWidget {
  final User targetUser;

  const ChatScreen({super.key, required this.targetUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Declare the message list, but initialize it in initState
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // FIX: Initialize the list here where 'widget' is available
    _messages = [
      ChatMessage(
        // This is a message FROM the target user TO the current user (mockCurrentUser)
        text: "Hi ${mockCurrentUser.name}, I'm interested in your services. Is this item still available?",
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        sender: MessageSender.other, 
      ),
      ChatMessage(
        // This is a message FROM the current user TO the target user
        text: "Hi ${widget.targetUser.name}! Yes, it is. What can I help you with?",
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        sender: MessageSender.me, 
      ),
    ];
    
    // Scroll to the bottom when the screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      text: text,
      timestamp: DateTime.now(),
      sender: MessageSender.me,
    );

    setState(() {
      _messages.add(newMessage);
      _textController.clear();
    });

    // Scroll to the new message after it's been added
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });

    // In a real app, this is where you would call an API/Firestore to send the message.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message sent (Mock API)!'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the current user's name for context in the title
    final currentUser = context.read<AppController>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.targetUser.profilePicUrl),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Text(widget.targetUser.name),
          ],
        ),
        elevation: 1,
      ),
      body: Column(
        children: <Widget>[
          // Chat Messages Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8.0),
                Material(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(30),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
    
