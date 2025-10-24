import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../state/app_controller.dart';
import 'post_detail_screen.dart'; // NEW: Import PostDetailScreen
import 'post_edit_screen.dart'; 
import 'user_profile_screen.dart'; // For owner profile navigation

// Helper function for time display
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

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AppController>(context, listen: false);
    final isOwner = post.owner.id == controller.currentUser?.id;

    // Wrap the entire card in a GestureDetector to navigate to the detail screen
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PostDetailScreen(post: post),
        ));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Owner Info and Options
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                       // Navigate to the user's profile screen. 
                       // Uses a different screen for non-current user for safety, 
                       // though both profile screens are placeholders.
                       if (!isOwner) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => UserProfileScreen(), // Use generic placeholder for now
                          ));
                       }
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(post.owner.profilePicUrl),
                      radius: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.owner.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(_timeAgo(post.postedDate), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  // Post Options (only visible to owner)
                  if (isOwner)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PostEditScreen(post: post),
                          ));
                        } else if (value == 'delete') {
                          _showDeleteConfirmationDialog(context, post, controller);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit Post')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete Post', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                ],
              ),
            ),

            // Post Image
            Image.network(
              post.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: const Text('Image Load Failed', style: TextStyle(color: Colors.black54)),
              ),
            ),

            // Title and Price
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    post.price,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
            
            // Description Snippet
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
              child: Text(
                post.description.split('\n')[0], // Show only the first line/snippet
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                         // This will navigate to the Post Detail screen (where the card onTap goes)
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PostDetailScreen(post: post),
                        ));
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Action to initiate chat/booking (placeholder)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Starting transaction for: ${post.title}')),
                        );
                      },
                      icon: const Icon(Icons.bookmark_add, color: Colors.white),
                      label: const Text('Book/Hire', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog for delete confirmation
  void _showDeleteConfirmationDialog(BuildContext context, Post post, AppController controller) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the post "${post.title}"? This cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                final error = await controller.deletePost(post.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Post deleted successfully.'),
                    backgroundColor: error == null ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}