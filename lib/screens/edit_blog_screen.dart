import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditBlogScreen extends StatefulWidget {
  final String blogId;

  const EditBlogScreen({super.key, required this.blogId});

  @override
  State<EditBlogScreen> createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final imageController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection('blogs')
        .doc(widget.blogId)
        .get();

    final data = doc.data() as Map<String, dynamic>;

    titleController.text = data['title'] ?? "";
    descController.text = data['description'] ?? "";
    imageController.text = data['imageUrl'] ?? "";
  }

  void updateBlog() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('blogs')
        .doc(widget.blogId)
        .update({
      'title': titleController.text,
      'description': descController.text,
      'imageUrl': imageController.text,
    });

    setState(() => loading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Blog")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: "Image URL"),
            ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: updateBlog,
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}