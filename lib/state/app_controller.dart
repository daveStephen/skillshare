import 'package:flutter/material.dart';

import '../data/mock_data.dart'; // Import mock data

// Helper models for the mock notification data
enum NotificationType { chat, booking, post, bookingTime }

class NotificationItem {
  final String id; // Unique ID for tracking
  final String title;
  final String subtitle;
  final NotificationType type;
  final DateTime time;
  bool isRead; // Added to track read status

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.time,
    this.isRead = false,
  });
}

class AppController extends ChangeNotifier {
  // --- AUTH STATE ---
  User? _currentUser;
  bool _isLoading = false;
  String? _authError;

  // Use the initial mock data to populate the live list
  List<Post> _posts = [...initialMockPosts]; 
  
  // --- NOTIFICATION STATE (NEW) ---
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'n_001',
      title: 'New Chat Message!',
      // Uses the single remaining mockOtherUser placeholder
      subtitle: '${mockOtherUser.name} sent you a message about the Drone.',
      type: NotificationType.chat,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    NotificationItem(
      id: 'n_002',
      title: 'Booking Confirmed',
      subtitle: 'Your session for "Guitar Lessons" is scheduled for 3 PM today.',
      type: NotificationType.booking,
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      id: 'n_003',
      title: 'New Post from Jane Doe',
      subtitle: 'Jane posted "Vintage Camera for Sale". Check it out!',
      type: NotificationType.post,
      time: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true, // Mock an already read notification
    ),
  ];

  // --- GETTERS ---
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get authError => _authError;
  List<Post> get posts => _posts; 
  List<NotificationItem> get notifications => _notifications; // Getter for notifications

  // Calculate the number of unread notifications
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  // --- NOTIFICATION METHODS (NEW) ---

  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  // --- AUTH METHODS (MOCK) ---

  // FIX: Simplified mockLogin to use a single hardcoded test user.
  bool mockLogin(String email, String password) {
    _isLoading = true;
    notifyListeners();

    final inputEmail = email.trim().toLowerCase();
    const testEmail = 'test@user.com'; // NEW LOGIN EMAIL
    const testPassword = 'password';

    // Simulate successful login only for a single test user
    if (inputEmail == testEmail && password == testPassword) {
      // Create a new User object to represent the logged-in user
      _currentUser = const User(
        id: 'test_user_001',
        name: 'Test User',
        email: testEmail,
        profilePicUrl: 'https://via.placeholder.com/100/0000FF/FFFFFF?text=TU',
        bio: 'This is a test account.',
        posts: [],
      );
      _authError = null;
    } else {
      _authError = 'Invalid email or password.';
    }

    _isLoading = false;
    notifyListeners();
    return isLoggedIn;
  }

  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>> START OF SIGNUP FIX <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  Future<String?> signUp(String email, String password, String name) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    // Only check against the new mock registered emails
    final inputEmail = email.trim().toLowerCase();
    if (inputEmail == mockCurrentUser.email.toLowerCase() || inputEmail == 'test@user.com') {
      _authError = 'This email is already registered.';
    } else {
      // SUCCESSFUL SIGNUP: We create a new User object.
      User(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        name: name,
        email: email,
        profilePicUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF?text=${name.substring(0, 1).toUpperCase()}', // Simple generated avatar
        bio: 'Just joined the SkillShare community!',
        posts: const [], 
      );
      _authError = null; // Clear error on success
    }

    _isLoading = false;
    notifyListeners();
    return _authError; // Returns null on success, or an error string
  }
  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>> END OF SIGNUP FIX <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  // --- POST MANAGEMENT METHODS ---

  // C - Create
  void addPost(Post post) {
    _posts.insert(0, post); // Add to the top of the list
    notifyListeners();
  }

  // U - Update
  Future<String?> updatePost(Post updatedPost) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate API delay

    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
      _isLoading = false;
      notifyListeners();
      return null; // Success
    }
    
    _isLoading = false;
    notifyListeners();
    return 'Post not found.'; // Failure
  }

  // D - Delete
  Future<String?> deletePost(String postId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800)); // Simulate API delay

    final initialLength = _posts.length;
    _posts.removeWhere((p) => p.id == postId);
    
    _isLoading = false;
    if (_posts.length < initialLength) {
      notifyListeners();
      return null; // Success
    }
    
    notifyListeners();
    return 'Post could not be deleted.'; // Failure
  }
}