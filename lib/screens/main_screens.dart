import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/mock_data.dart';
import '../state/app_controller.dart';
import 'post_screens.dart'; // Contains PostCard
import 'post_detail_screen.dart'; // NEW: Import the detail screen
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart'; // Ensure ChatScreen is imported for navigation from notifications

// --- MAIN NAVIGATION SHELL ---

class MainAppWrapper extends StatefulWidget {
  final AppController controller;
  const MainAppWrapper({super.key, required this.controller});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const BookingScreen(), // ENHANCED BOOKING SCREEN
    // NOTE: This access to currentUser! is safe because MainAppWrapper is only built when a user is logged in
    PostCreationScreen(currentUser: widget.controller.currentUser!), 
    const NotificationScreen(),
    ProfileScreen(user: widget.controller.currentUser!),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// --- HOME SCREEN (Feed) ---

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final currentUser = controller.currentUser;
    // FETCH POSTS FROM THE CONTROLLER
    final posts = controller.posts; 

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              if (currentUser != null) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: currentUser),
                ));
              }
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(currentUser?.profilePicUrl ?? 'https://via.placeholder.com/100'),
            ),
          ),
        ),
        title: const Text('SkillShare'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to Chat/Message List...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search function not yet implemented.')),
              );
            },
          ),
        ],
      ),
      body: posts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feed_outlined, size: 80, color: Colors.grey),
                  Text('The feed is currently empty.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 5),
                  Text('Create a new post to see it here!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(post: post);
              },
            ),
    );
  }
}

// --- BOOKING SCREEN (ENHANCED PLACEHOLDER) ---

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mock data for bookings
  final List<String> activeBookings = [
    'Guitar Lessons with Franz (Today, 3 PM)',
    'Renting Power Drill (Due back tomorrow)',
    'Photography Session (Pending Confirmation)',
  ];

  final List<String> historyBookings = [
    'Drone Rental (Completed 2 weeks ago)',
    'Physics Tutoring (Completed last week)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active (3)'),
            Tab(text: 'History (2)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Bookings Tab
          ListView.builder(
            itemCount: activeBookings.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.blue),
                title: Text(activeBookings[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Tap for details and payment status'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Viewing active booking: ${activeBookings[index]}')),
                  );
                },
              );
            },
          ),

          // History Bookings Tab
          ListView.builder(
            itemCount: historyBookings.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(historyBookings[index]),
                subtitle: const Text('View receipt and rating'),
                trailing: const Icon(Icons.star, color: Colors.amber),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Viewing booking history: ${historyBookings[index]}')),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- POST CREATION SCREEN ---

class PostCreationScreen extends StatefulWidget {
  final User currentUser;
  const PostCreationScreen({super.key, required this.currentUser});

  @override
  State<PostCreationScreen> createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(); // NEW: Added price controller
  File? _selectedImageFile; 
  bool _isSaving = false; // NEW: Added loading state

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose(); // Dispose new controller
    super.dispose();
  }

  // Image picker logic
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path); 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selected from ${source == ImageSource.camera ? "Camera" : "Gallery"}.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selection cancelled.')),
      );
    }
    Navigator.of(context).pop(); 
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture (Camera)'),
                onTap: () => _pickImage(ImageSource.camera), 
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => _pickImage(ImageSource.gallery), 
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // UPDATED: Use AppController's addPost method
  void _publishPost(BuildContext context) async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty || _priceController.text.isEmpty || _selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a picture.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // SIMULATION: In a real app, this delay simulates image upload and API call.
    await Future.delayed(const Duration(seconds: 1));

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      // FIX: Use ownerId (string) instead of owner (User object)
      ownerId: widget.currentUser.id, 
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      // Mocked image URL as real upload is skipped
      imageUrl: 'https://via.placeholder.com/600x400/${DateTime.now().millisecond % 900 + 100}/FFFFFF?text=${_titleController.text.trim().substring(0, 1).toUpperCase()}+NEW', 
      price: _priceController.text.trim(), 
      postedDate: DateTime.now(),
    );

    // Use AppController to manage the state
    Provider.of<AppController>(context, listen: false).addPost(newPost);
    
    // Clear the form fields after successful posting
    _titleController.clear();
    _descController.clear();
    _priceController.clear();

    setState(() {
      _selectedImageFile = null;
      _isSaving = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Posting "${newPost.title}" successful. Check the Home tab.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What are you sharing today?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Divider(height: 30),

            // Image Upload Area 
            GestureDetector(
              onTap: _isSaving ? null : _showImageSourceDialog,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _selectedImageFile == null ? Colors.grey.shade400 : Colors.blue.shade700, width: 2),
                  image: _selectedImageFile != null
                      ? DecorationImage(
                            image: FileImage(_selectedImageFile!),
                            fit: BoxFit.cover,
                          )
                      : null,
                ),
                child: _selectedImageFile == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                          Text('Upload Picture (Gadget/Service)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                          Text('Tap to select source (Camera/Gallery)', style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title (e.g., Drone Rental, Makeup Service)', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _priceController, // NEW: Added Price field
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (e.g., ₱500/hr, Negotiable)', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description and Terms', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSaving ? null : () => _publishPost(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSaving
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : const Text('Publish Post', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
