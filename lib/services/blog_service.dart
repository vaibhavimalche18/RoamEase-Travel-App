import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BlogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 📌 Get blogs (feed)
  Stream<QuerySnapshot> getBlogs() {
    return _firestore
        .collection('blogs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// 📌 Add blog
  Future<void> addBlog({
    required String title,
    required String description,
    required String imageUrl,
    required String username,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _firestore.collection('blogs').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'username': username,
      'userId': user.uid,
      'likesCount': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// ❤️ Toggle Like (TRANSACTION — race condition safe)
  Future<void> toggleLike(String blogId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final blogRef = _firestore.collection('blogs').doc(blogId);
    final likeRef = blogRef.collection('likes').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final likeSnap = await transaction.get(likeRef);

      if (likeSnap.exists) {
        // Already liked → unlike
        transaction.delete(likeRef);
        transaction.update(blogRef, {
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // Not liked → like
        transaction.set(likeRef, {
          'likedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(blogRef, {
          'likesCount': FieldValue.increment(1),
        });
      }
    });
  }

  /// 🗑 Delete blog
  Future<void> deleteBlog(String blogId) async {
    await _firestore.collection('blogs').doc(blogId).delete();
  }

  /// 💬 Add comment
  Future<void> addComment(String blogId, String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .add({
      'text': text,
      'username': user.email ?? "User",
      'userId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}