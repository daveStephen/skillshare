import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart'; 
import '../state/app_controller.dart'; 
import 'chat_screen.dart'; 

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  
  @override
  void initState() {
    super.initState();
    // Simulate a pop-up notification on initial load, as requested
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPopUpNotification(context);
    });
  }

  // Mock function to show a temporary overlay/pop-up notification
  void _showPopUpNotification(BuildContext context) {
    final controller = Provider.of<AppController>(context, listen: false);
    final unreadCount = controller.unreadNotificationCount;

    if (mounted && unreadCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You have $unreadCount new notification${unreadCount > 1 ? 's' : ''}!', 
            style: const TextStyle(fontWeight: FontWeight.bold)
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Helper function to get icon based on notification type
  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.chat:
        return Icons.chat_bubble;
      case NotificationType.booking:
        return Icons.calendar_today;
      case NotificationType.post:
        return Icons.campaign;
      case NotificationType.bookingTime:
        return Icons.alarm_on;
    }
  }
  
  // Helper function for time display (reused)
  String _timeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }

  void _handleTap(BuildContext context, NotificationItem notification, AppController controller) {
    // 1. Mark as read
    controller.markNotificationAsRead(notification.id);

    // 2. Perform navigation based on type
    switch (notification.type) {
      case NotificationType.chat:
        // Navigate to chat with mockOtherUser (assuming the chat notification is from them)
        Navigator.of(context).push(MaterialPageRoute(
          // --- FIX APPLIED HERE: REMOVED 'const' ---
          builder: (context) => ChatScreen(targetUser: mockOtherUser), 
        ));
        break;
      case NotificationType.booking:
      case NotificationType.bookingTime:
        // Navigate to the BookingScreen/Detail
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigating to Booking Details for: ${notification.title}')),
        );
        break;
      case NotificationType.post:
        // Navigate to the Post Detail Screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigating to Post View for: ${notification.title}')),
        );
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    // Watch the AppController for notification updates
    final controller = context.watch<AppController>();
    final notifications = controller.notifications;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? const Center(
              child: Text('You have no notifications.'),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isUnread = !notification.isRead;

                return ListTile(
                  tileColor: isUnread ? Colors.blue.shade50 : null, // Highlight unread
                  leading: CircleAvatar(
                    backgroundColor: isUnread ? Colors.blue : Colors.grey.shade300,
                    child: Icon(_getIcon(notification.type), color: isUnread ? Colors.white : Colors.blue),
                  ),
                  title: Text(notification.title, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                  subtitle: Text(notification.subtitle, style: TextStyle(color: isUnread ? Colors.black : Colors.grey.shade600)),
                  trailing: Text(_timeAgo(notification.time), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  onTap: () => _handleTap(context, notification, controller),
                );
              },
            ),
    );
  }
}