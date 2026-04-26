import 'package:flutter/material.dart';
import '../screens/blog_detail_screen.dart';

class BlogCard extends StatelessWidget {
  final String blogId;
  final String title;
  final String description;
  final String imageUrl;
  final String username;

  const BlogCard({
    super.key,
    required this.blogId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlogDetailScreen(blogId: blogId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🖼️ COVER IMAGE
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            /// 📝 TEXT
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    description.length > 80
                        ? "${description.substring(0, 80)}..."
                        : description,
                    style: TextStyle(color: Colors.grey[700]),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "by $username",
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
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