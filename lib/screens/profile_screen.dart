import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart'; 
import '../state/app_controller.dart';
import 'login_screen.dart';
import 'post_screens.dart'; // Import PostCard

class ProfileScreen extends StatelessWidget {
  final User? user; 

  const ProfileScreen({super.key, required this.user});

  void _handleLogout(BuildContext context) async {
    final controller = Provider.of<AppController>(context, listen: false);
    await controller.logout();
    
    if (!controller.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully.')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('Error: User not found.'));
    }

    // Watch the AppController to get the live, updated list of posts
    final controller = context.watch<AppController>();
    
    // Filter posts that belong to the current user from the live list
    final userPosts = controller.posts.where((post) => post.owner.id == user!.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings menu opened.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(user!.profilePicUrl),
                    ),
                    const SizedBox(height: 15),
                    Text(user!.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    Text(user!.email, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                    const SizedBox(height: 20),
                    Text(user!.bio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                    const Divider(height: 40),
                    
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'My Active Listings (${userPosts.length})',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ]),
          ),
          // Display the current user's posts using PostCard
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = userPosts[index];
                return PostCard(post: post); 
              },
              childCount: userPosts.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}