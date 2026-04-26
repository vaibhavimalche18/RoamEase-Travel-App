import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/blog_service.dart';
import 'comment_screen.dart';
import 'edit_blog_screen.dart';

class BlogDetailScreen extends StatefulWidget {
  final String blogId;

  const BlogDetailScreen({super.key, required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final BlogService blogService = BlogService();

  void toggleLike() async {
    await blogService.toggleLike(widget.blogId);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Blog Detail"),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blogs')
            .doc(widget.blogId)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final title = data['title'] ?? "";
          final description = data['description'] ?? "";
          final imageUrl = data['imageUrl'] ?? "";
          final likes = data['likesCount'] ?? 0;
          final ownerId = data['userId'] ?? "";

          final isOwner = user != null && user.uid == ownerId;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),

                      const SizedBox(height: 20),

                      /// ❤️ LIKE + 💬 COMMENT
                      Row(
                        children: [

                          IconButton(
                            icon: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('blogs')
                                  .doc(widget.blogId)
                                  .collection('likes')
                                  .doc(user?.uid)
                                  .snapshots(),
                              builder: (context, snap) {
                                final liked = snap.data?.exists ?? false;

                                return Icon(
                                  Icons.favorite,
                                  color: liked ? Colors.red : Colors.grey,
                                );
                              },
                            ),
                            onPressed: toggleLike,
                          ),

                          Text("$likes likes"),

                          const SizedBox(width: 20),

                          IconButton(
                            icon: const Icon(Icons.comment),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CommentsScreen(blogId: widget.blogId),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// ✏️ EDIT + 🗑 DELETE
                      if (isOwner)
                        Row(
                          children: [

                            TextButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text("Edit"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditBlogScreen(
                                      blogId: widget.blogId,
                                    ),
                                  ),
                                );
                              },
                            ),

                            TextButton.icon(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text("Delete"),
                              onPressed: () async {
                                await blogService.deleteBlog(widget.blogId);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}