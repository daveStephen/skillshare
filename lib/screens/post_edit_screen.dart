import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart'; // Import Post model
import '../state/app_controller.dart';

/// A functional screen for editing a post.
class PostEditScreen extends StatefulWidget {
  final Post post;
  
  const PostEditScreen({super.key, required this.post});

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current post data
    _titleController = TextEditingController(text: widget.post.title);
    _descController = TextEditingController(text: widget.post.description);
    _priceController = TextEditingController(text: widget.post.price);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = Provider.of<AppController>(context, listen: false);

    // Create a new Post object using copyWith
    final updatedPost = widget.post.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      price: _priceController.text.trim(),
      // NOTE: Image update logic is complex and is omitted here, keeping the original image.
    );

    final error = await controller.updatePost(updatedPost);

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Go back to the previous screen (PostCard or Profile)
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AppController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.post.title}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Update your listing details:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Image is not editable for simplicity, just shown as a reminder
              Image.network(widget.post.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Title cannot be empty.' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Price/Rate', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Price cannot be empty.' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description and Terms', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Description cannot be empty.' : null,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: controller.isLoading ? null : _saveChanges,
                  icon: controller.isLoading ? const SizedBox(width: 0) : const Icon(Icons.save, color: Colors.white),
                  label: controller.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes', style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}