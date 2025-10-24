import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../state/app_controller.dart';
import 'chat_screen.dart'; // For chat navigation
import 'post_edit_screen.dart';
import 'user_profile_screen.dart'; // For viewing owner profile

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  // Helper function for time display (copied from post_screens.dart)
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

  // --- NEW: Helper to resolve the User object from the ownerId ---
  // Since we only have mock users, this checks for the logged-in user or the registered mock users.
  User _getPostOwner(AppController controller, String ownerId) {
    // 1. Check if the current logged-in user is the owner
    if (controller.currentUser?.id == ownerId) {
      return controller.currentUser!;
    }

    // 2. Check against the mock registered user (test@exists.com)
    if (mockCurrentUser.id == ownerId) {
      return mockCurrentUser;
    }

    // 3. Fallback: If not logged-in user or the mock registered user,
    // return the mockOtherUser (System User) for display purposes.
    // This handles the generic placeholder IDs in the initialMockPosts.
    return mockOtherUser;
  }

  // --- ACTIONS ---

  // FIX: _handleChat now accepts the resolved User object
  void _handleChat(BuildContext context, User owner) { 
    // Navigate to chat screen with the owner
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatScreen(targetUser: owner),
    ));
  }

  void _handleBooking(BuildContext context) {
    // Placeholder for booking logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking flow started for "${post.title}"')),
    );
  }

  void _handleEdit(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PostEditScreen(post: post),
    ));
  }
  
  void _handleViewProfile(BuildContext context) {
    // NOTE: Uses the generic placeholder UserProfileScreen
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UserProfileScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Watch AppController to reflect real-time updates (like deletion or edit)
    final controller = context.watch<AppController>();
    final currentUserId = controller.currentUser?.id;

    // Retrieve the most up-to-date post data from the controller's list.
    final currentPost = controller.posts.firstWhereOrNull((p) => p.id == post.id);
    
    // If the post was deleted from the main list, pop back.
    if (currentPost == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This post was deleted by the owner or removed.')),
          );
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // Resolve the owner using the new helper function and ownerId
    final owner = _getPostOwner(controller, currentPost.ownerId);
    final isOwner = owner.id == currentUserId;

    // Use the currentPost for display
    final displayPost = currentPost;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayPost.title),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _handleEdit(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Image
            Image.network(
              displayPost.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayPost.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        displayPost.price,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Owner Info
                  GestureDetector(
                    onTap: () => _handleViewProfile(context),
                    child: Row(
                      children: [
                        // FIX: Use the resolved owner object
                        CircleAvatar(
                          backgroundImage: NetworkImage(owner.profilePicUrl), 
                          radius: 16,
                        ),
                        const SizedBox(width: 8),
                        // FIX: Use the resolved owner object
                        Text(
                          'Posted by ${owner.name}', 
                          style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Text('(${_timeAgo(displayPost.postedDate)})', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 30),

                  // Description
                  const Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    displayPost.description,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const Divider(height: 30),

                  // Action Buttons (Primary)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          // FIX: Pass the resolved owner to the chat handler
                          onPressed: () => _handleChat(context, owner), 
                          icon: const Icon(Icons.message),
                          label: const Text('Chat Owner'),
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleBooking(context),
                          icon: const Icon(Icons.calendar_month, color: Colors.white),
                          label: const Text('Request Booking', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to safely find an item, preventing "Bad state" errors.
extension IterableX<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
