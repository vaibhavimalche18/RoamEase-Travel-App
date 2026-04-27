import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/blog_card.dart';
import '../services/blog_service.dart';
import 'add_blog_screen.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState(); // ✅ this was missing
}

class _BlogScreenState extends State<BlogScreen> {
  final BlogService _blogService = BlogService(); // ✅ created once, not on every build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travel Blogs"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddBlogScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _blogService.getBlogs(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No blogs yet"));
          }

          final blogs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final blog = blogs[index];

              return BlogCard(
                blogId: blog.id,
                title: blog['title'] ?? "",
                description: blog['description'] ?? "",
                imageUrl: blog['imageUrl'] ?? "",
                username: blog['username'] ?? "User",
              );
            },
          );
        },
      ),
    );
  }
}