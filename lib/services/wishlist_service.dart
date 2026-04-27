import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {

  static Future<void> addToWishlist(Map place) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ── Normalize fields so PlaceCard always gets name/image/rating ──
    // The API returns different field names (display_name, photo, etc.)
    // We map them all to what PlaceCard expects.
    final normalized = {
      'name':   place['name']
             ?? place['display_name']
             ?? place['title']
             ?? 'Unknown Place',

      'image':  place['image']
             ?? place['photo']
             ?? place['image_url']
             ?? place['thumbnail']
             ?? '',

      'rating': (place['rating']
             ?? place['score']
             ?? place['stars']
             ?? 4.5).toDouble(),

      // Keep any extra fields too, just in case
      'savedAt': DateTime.now().toIso8601String(),
    };

    // Avoid duplicates — check if a place with the same name already exists
    final existing = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .where('name', isEqualTo: normalized['name'])
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return; // already saved, skip

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .add(normalized);
  }

  static Stream<QuerySnapshot> getWishlist() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .orderBy('savedAt', descending: true)
        .snapshots();
  }

  static Future<void> removeFromWishlist(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(docId)
        .delete();
  }
}