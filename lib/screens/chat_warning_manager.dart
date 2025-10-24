import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Key for SharedPreferences
const String _kChatWarningShownKey = 'chatWarningShown';

class ChatWarningManager {

  /// Checks if the warning should be shown (i.e., if it has never been shown before).
  static Future<bool> shouldShowWarning() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true if key is not found (meaning it has not been shown)
    return !(prefs.getBool(_kChatWarningShownKey) ?? false);
  }

  /// Sets the preference so the warning is not shown again.
  static Future<void> _markWarningAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kChatWarningShownKey, true);
  }

  /// Shows the critical safety warning dialog.
  static Future<void> showWarningDialog(BuildContext context, VoidCallback onConfirmed) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security, color: Colors.red),
              SizedBox(width: 8),
              Text('Safety Warning'),
            ],
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Always prioritize your safety and only meet in public, well-lit areas. Never share personal bank details or passwords.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('By proceeding, you agree to follow safety guidelines and accept full responsibility for your interactions.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Understand & Proceed', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _markWarningAsShown(); // Mark as shown for the future
                Navigator.of(dialogContext).pop(); // Close dialog
                onConfirmed(); // Navigate to the chat screen
              },
            ),
          ],
        );
      },
    );
  }
}