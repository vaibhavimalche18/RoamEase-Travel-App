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

    // ── Sets ──
    final myVisited = Set<String>.from(my['visitedPlaces'] ?? []);
    final otherVisited = Set<String>.from(other['visitedPlaces'] ?? []);
    final myWishlist = Set<String>.from(my['wishlist'] ?? []);
    final otherWishlist = Set<String>.from(other['wishlist'] ?? []);
    final myStyle = Set<String>.from(my['travelStyle'] ?? []);
    final otherStyle = Set<String>.from(other['travelStyle'] ?? []);

    // ── Single-value fields ──
    final myBudget = my['budget'] as String?;
    final otherBudget = other['budget'] as String?;
    final myCompanion = my['companionPref'] as String?;
    final otherCompanion = other['companionPref'] as String?;
    final myClimate = my['climatePref'] as String?;
    final otherClimate = other['climatePref'] as String?;
    final myDuration = my['tripDuration'] as String?;
    final otherDuration = other['tripDuration'] as String?;

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
      'otherName': other['displayName'] ?? 'Traveler',
      'otherBio': other['bio'] ?? '',
      // Overlap lists
      'sharedVisited': myVisited.intersection(otherVisited).toList(),
      'sharedWishlist': myWishlist.intersection(otherWishlist).toList(),
      'youCanGuide': myVisited.intersection(otherWishlist).toList(),
      'theyCanGuide': otherVisited.intersection(myWishlist).toList(),
      'sharedStyles': myStyle.intersection(otherStyle).toList(),
      // Single-value matches
      'budgetMatch': _exactMatch(myBudget, otherBudget),
      'companionMatch': _exactMatch(myCompanion, otherCompanion),
      'climateMatch': _exactMatch(myClimate, otherClimate),
      'durationMatch': _exactMatch(myDuration, otherDuration),
      // Raw values for display
      'otherBudget': otherBudget,
      'otherCompanion': otherCompanion,
      'otherClimate': otherClimate,
      'otherDuration': otherDuration,
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

  int _max(int a, int b) => a > b ? a : b;

  bool _exactMatch(String? a, String? b) =>
      a != null && b != null && a == b;
}