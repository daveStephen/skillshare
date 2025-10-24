import 'package:flutter/material.dart';
import '../data/mock_data.dart'; // IMPORTANT: Uses your existing data model
import 'chat_screen.dart'; // Requires creation of this file
import 'chat_warning_manager.dart'; // Requires creation of this file

class UserProfileScreen extends StatelessWidget {
  // Mock User object for demonstration purposes.
  // The 'username' field has been removed to match your mock_data.dart User class.
  final User user = User(
    id: 'user123',
    name: 'Professor Skill',
    email: 'prof@ua.edu',
    profilePicUrl: 'https://placehold.co/100x100/4CAF50/FFFFFF?text=P.S.',
    bio: 'Teaches advanced algorithms and Flutter development.', // Match your model
  );

  UserProfileScreen({super.key});

  // Function to navigate directly to the chat screen
  void _navigateToChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(targetUser: user),
      ),
    );
  }

  // Function to check warning state and handle navigation
  void _handleChatButton(BuildContext context) async {
    final shouldShow = await ChatWarningManager.shouldShowWarning();

    if (shouldShow) {
      // Show warning dialog if they haven't seen it or chosen "don't show again"
      await ChatWarningManager.showWarningDialog(
        context,
        () => _navigateToChat(context), // Callback function to run if confirmed
      );
    } else {
      // Navigate directly if they have already dismissed the warning permanently
      _navigateToChat(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(user.profilePicUrl),
              ),
              const SizedBox(height: 20),
              Text(
                user.name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              // Removed the Text widget that referenced the non-existent 'username' property
              Text(
                user.email, // Displaying email instead of username
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              
              // --- CHAT and VIEW PROFILE BUTTONS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // CHAT BUTTON (Triggers the warning logic)
                  ElevatedButton.icon(
                    onPressed: () => _handleChatButton(context),
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                    label: const Text('Chat', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE44D26), // Skillshare Orange
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  
                  // VIEW PROFILE BUTTON (Placeholder)
                  OutlinedButton.icon(
                    onPressed: () {
                      // Placeholder action for viewing full profile details
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Viewing full profile... (Feature Placeholder)')),
                      );
                    },
                    icon: const Icon(Icons.person_outline),
                    label: const Text('View Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              const Text(
                'TESTING NOTE: This profile screen is currently the home screen for testing the chat warning feature.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}