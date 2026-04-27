import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ─────────────────────────────────────────
  // Core DNA calculation
  // ─────────────────────────────────────────
  //
  // Scoring breakdown (100 pts total):
  //  - Shared visited places  → 25 pts
  //  - Shared wishlist        → 20 pts
  //  - Travel style overlap   → 20 pts
  //  - Budget match           → 15 pts
  //  - Companion pref match   → 10 pts
  //  - Climate pref match     →  5 pts
  //  - Trip duration match    →  5 pts
  //
  Future<Map<String, dynamic>> calculateDNA(String otherUid) async {
    final myDoc = await _db.collection('users').doc(_uid).get();
    final otherDoc = await _db.collection('users').doc(otherUid).get();

    final my = myDoc.data() ?? {};
    final other = otherDoc.data() ?? {};

    // ── Normalize to lowercase sets for comparison ──
    final myVisited = _normalizedSet(my['visitedPlaces']);
    final otherVisited = _normalizedSet(other['visitedPlaces']);
    final myWishlist = _normalizedSet(my['wishlist']);
    final otherWishlist = _normalizedSet(other['wishlist']);
    final myStyle = _normalizedSet(my['travelStyle']);
    final otherStyle = _normalizedSet(other['travelStyle']);

    // ── Single-value fields (lowercase for comparison) ──
    final myBudget = _norm(my['budget']);
    final otherBudget = _norm(other['budget']);
    final myCompanion = _norm(my['companionPref']);
    final otherCompanion = _norm(other['companionPref']);
    final myClimate = _norm(my['climatePref']);
    final otherClimate = _norm(other['climatePref']);
    final myDuration = _norm(my['tripDuration']);
    final otherDuration = _norm(other['tripDuration']);

    // ── Score calculation ──
    double score = 0;

    final maxV = _max(myVisited.length, otherVisited.length);
    final maxW = _max(myWishlist.length, otherWishlist.length);
    final maxS = _max(myStyle.length, otherStyle.length);

    if (maxV > 0) score += (myVisited.intersection(otherVisited).length / maxV) * 25;
    if (maxW > 0) score += (myWishlist.intersection(otherWishlist).length / maxW) * 20;
    if (maxS > 0) score += (myStyle.intersection(otherStyle).length / maxS) * 20;

    if (_exactMatch(myBudget, otherBudget)) score += 15;
    if (_exactMatch(myCompanion, otherCompanion)) score += 10;
    if (_exactMatch(myClimate, otherClimate)) score += 5;
    if (_exactMatch(myDuration, otherDuration)) score += 5;

    return {
      'score': score.round(),
      'otherName': other['name'] ?? other['displayName'] ?? 'Traveler',
      'otherBio': other['bio'] ?? '',
      // Overlap lists — capitalized for display
      'sharedVisited': _capitalize(myVisited.intersection(otherVisited)),
      'sharedWishlist': _capitalize(myWishlist.intersection(otherWishlist)),
      'youCanGuide': _capitalize(myVisited.intersection(otherWishlist)),
      'theyCanGuide': _capitalize(otherVisited.intersection(myWishlist)),
      'sharedStyles': _capitalize(myStyle.intersection(otherStyle)),
      // Single-value matches
      'budgetMatch': _exactMatch(myBudget, otherBudget),
      'companionMatch': _exactMatch(myCompanion, otherCompanion),
      'climateMatch': _exactMatch(myClimate, otherClimate),
      'durationMatch': _exactMatch(myDuration, otherDuration),
      // Raw values for display (original casing from Firestore)
      'otherBudget': other['budget'],
      'otherCompanion': other['companionPref'],
      'otherClimate': other['climatePref'],
      'otherDuration': other['tripDuration'],
      'otherFrequency': other['travelFrequency'],
    };
  }

  // ─────────────────────────────────────────
  // Profile writes
  // ─────────────────────────────────────────

  Future<void> addVisitedPlace(String place) async {
    await _db.collection('users').doc(_uid).set({
      'visitedPlaces': FieldValue.arrayUnion([place])
    }, SetOptions(merge: true));
  }

  Future<void> addWishlistPlace(String place) async {
    await _db.collection('users').doc(_uid).set({
      'wishlist': FieldValue.arrayUnion([place])
    }, SetOptions(merge: true));
  }

  Future<void> updateTravelStyle(List<String> styles) async {
    await _db.collection('users').doc(_uid).set({
      'travelStyle': styles
    }, SetOptions(merge: true));
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _db.collection('users').doc(_uid).set(
      {...data, 'profileUpdatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  /// Load the current user's own profile (for pre-filling TravelProfileScreen).
  Future<Map<String, dynamic>> loadMyProfile() async {
    final doc = await _db.collection('users').doc(_uid).get();
    return doc.data() ?? {};
  }

  // ─────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────

  /// Converts a Firestore list field into a normalized lowercase Set<String>.
  Set<String> _normalizedSet(dynamic field) {
    if (field == null) return {};
    return Set<String>.from(
      (field as List).map((e) => e.toString().trim().toLowerCase()),
    );
  }

  /// Normalizes a single string value to lowercase for comparison.
  String? _norm(dynamic value) =>
      value == null ? null : value.toString().trim().toLowerCase();

  /// Capitalizes first letter of each word in a set for display.
  List<String> _capitalize(Set<String> items) {
    return items.map((s) {
      if (s.isEmpty) return s;
      return s.split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');
    }).toList();
  }

  int _max(int a, int b) => a > b ? a : b;

  bool _exactMatch(String? a, String? b) =>
      a != null && b != null && a == b;
}