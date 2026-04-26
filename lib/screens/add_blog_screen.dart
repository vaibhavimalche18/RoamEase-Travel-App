import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/blog_service.dart';

class AddBlogScreen extends StatefulWidget {
  const AddBlogScreen({super.key});

  @override
  State<AddBlogScreen> createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final imageUrlController = TextEditingController();

  final BlogService blogService = BlogService();

  bool isLoading = false;

  void postBlog() async {
    if (titleController.text.isEmpty || descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser;

    await blogService.addBlog(
      title: titleController.text,
      description: descController.text,
      imageUrl: imageUrlController.text,
      username: user?.email ?? "User",

    );

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write Blog"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [

              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: descController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Description"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: "Image URL (optional)",
                ),
              ),

              const SizedBox(height: 20),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: postBlog,
                child: const Text("Post Blog"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}