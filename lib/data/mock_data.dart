import 'package:flutter/material.dart';

// --- PLACEHOLDER IDs ---
// These are used in the initialMockPosts list instead of full User objects.
const String placeholderUserId1 = 'user_post_owner_1';
const String placeholderUserId2 = 'user_post_owner_2';

// --- MOCK POST DATA ---
class Post {
  final String id;
  // Post now refers to the owner via a simple ID, which is safer
  // than relying on a complex, interdependent User object for mock data.
  final String ownerId; 
  final String title;
  final String description;
  final String imageUrl;
  final String price;
  final DateTime postedDate;

  Post({
    required this.id,
    required this.ownerId, 
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.postedDate,
  });

  // Method to create a copy of the Post with new values
  Post copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? price,
  }) {
    return Post(
      id: id,
      ownerId: ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      postedDate: postedDate,
    );
  }
}

// --- MOCK USER DATA ---
class User {
  final String id;
  final String name;
  final String email;
  final String profilePicUrl;
  final String bio;
  final List<Post> posts;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicUrl,
    required this.bio,
    this.posts = const [],
  });

  // This copyWith method is necessary for the AppController's signup function
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicUrl,
    String? bio,
    List<Post>? posts,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      bio: bio ?? this.bio,
      posts: posts ?? this.posts,
    );
  }
}

// --- INITIAL MOCK POSTS (Uses simple IDs for owners) ---

final List<Post> initialMockPosts = [
  Post(
    id: 'post_001',
    ownerId: placeholderUserId1,
    title: 'Drone Rental (Phantom 4 Pro)',
    description: 'Rent my drone for aerial shots. P500/hour. Includes operator.',
    imageUrl: 'https://via.placeholder.com/600x400/2ecc71/FFFFFF?text=GADGET+1',
    price: '₱500/hr',
    postedDate: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  Post(
    id: 'post_002',
    ownerId: placeholderUserId2,
    title: 'Physics Tutoring Service',
    description: 'Offering tutoring for Physics 101. I have A+ marks. Rates negotiable.',
    imageUrl: 'https://via.placeholder.com/600x400/9b59b6/FFFFFF?text=SERVICE+1',
    price: 'Negotiable',
    postedDate: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Post(
    id: 'post_003',
    ownerId: placeholderUserId1,
    title: 'Guitar Lessons',
    description: 'Beginner to intermediate guitar lessons. Acoustic and electric.',
    imageUrl: 'https://via.placeholder.com/600x400/f1c40f/FFFFFF?text=SERVICE+2',
    price: '₱300/session',
    postedDate: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

// --- MINIMAL MOCK USER INSTANCES (Used for System/Notification purposes only) ---

// We keep a single, generic user for notifications (like in the AppController's list)
const mockOtherUser = User(
  id: 'system_user_001',
  name: 'System User', 
  email: 'system.user@app.com',
  profilePicUrl: 'https://via.placeholder.com/100/aaaaaa/FFFFFF?text=SU',
  bio: 'Placeholder user for app notifications.',
);

// We define mockCurrentUser as a separate entity that can be matched against
// for the "already registered" check in the signup function.
const mockCurrentUser = User(
  id: 'registered_user_001',
  name: 'Registered User',
  email: 'test@exists.com', // This email is now the one checked in signUp
  profilePicUrl: 'https://via.placeholder.com/100/333333/FFFFFF?text=RU',
  bio: 'Placeholder for a successfully logged-in user.',
);