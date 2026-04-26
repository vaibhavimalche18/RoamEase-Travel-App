import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<Map<String, dynamic>> calculateDNA(String otherUid) async {
    final myDoc = await _db.collection('users').doc(_uid).get();
    final otherDoc = await _db.collection('users').doc(otherUid).get();

    final my = myDoc.data() ?? {};
    final other = otherDoc.data() ?? {};

    final myVisited = Set<String>.from(my['visitedPlaces'] ?? []);
    final otherVisited = Set<String>.from(other['visitedPlaces'] ?? []);
    final myWishlist = Set<String>.from(my['wishlist'] ?? []);
    final otherWishlist = Set<String>.from(other['wishlist'] ?? []);
    final myStyle = Set<String>.from(my['travelStyle'] ?? []);
    final otherStyle = Set<String>.from(other['travelStyle'] ?? []);

    double score = 0;
    final maxV = myVisited.length > otherVisited.length
        ? myVisited.length : otherVisited.length;
    final maxW = myWishlist.length > otherWishlist.length
        ? myWishlist.length : otherWishlist.length;
    final maxS = myStyle.length > otherStyle.length
        ? myStyle.length : otherStyle.length;

    if (maxV > 0) score += (myVisited.intersection(otherVisited).length / maxV) * 40;
    if (maxW > 0) score += (myWishlist.intersection(otherWishlist).length / maxW) * 30;
    if (maxS > 0) score += (myStyle.intersection(otherStyle).length / maxS) * 30;

    return {
      'score': score.round(),
      'otherName': other['displayName'] ?? 'Traveler',
      'sharedVisited': myVisited.intersection(otherVisited).toList(),
      'sharedWishlist': myWishlist.intersection(otherWishlist).toList(),
      'youCanGuide': myVisited.intersection(otherWishlist).toList(),
      'theyCanGuide': otherVisited.intersection(myWishlist).toList(),
      'sharedStyles': myStyle.intersection(otherStyle).toList(),
    };
  }

  // Save visited place to current user's Firestore profile
  Future<void> addVisitedPlace(String placeId) async {
    await _db.collection('users').doc(_uid).set({
      'visitedPlaces': FieldValue.arrayUnion([placeId])
    }, SetOptions(merge: true));
  }

  // Save travel style tags
  Future<void> updateTravelStyle(List<String> styles) async {
    await _db.collection('users').doc(_uid).set({
      'travelStyle': styles
    }, SetOptions(merge: true));
  }
}