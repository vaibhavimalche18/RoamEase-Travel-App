import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class QuestService {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<String> createQuest({
    required String title,
    required List<String> placeIds,
    required String friendUid,
  }) async {
    final ref = await _db.collection('quests').add({
      'title': title,
      'targetCount': placeIds.length,
      'places': placeIds,
      'createdBy': _uid,
      'members': [_uid, friendUid],
      'createdAt': FieldValue.serverTimestamp(),
    });
    for (final uid in [_uid, friendUid]) {
      await _db
          .collection('quest_progress')
          .doc(ref.id)
          .collection('members')
          .doc(uid)
          .set({'completed': [], 'completedCount': 0});
    }
    return ref.id;
  }

  // ✅ FIX: Mark done — prevents duplicates, syncs count from array
  Future<void> markPlaceDone(String questId, String placeId) async {
    final docRef = _db
        .collection('quest_progress')
        .doc(questId)
        .collection('members')
        .doc(_uid);

    final snap = await docRef.get();
    final data = snap.data();
    if (data == null) return;

    final completed = List<String>.from(data['completed'] ?? []);
    if (completed.contains(placeId)) return;

    completed.add(placeId);
    // ✅ FIX: always write count = array length, never use increment
    await docRef.update({
      'completed': completed,
      'completedCount': completed.length,
    });
  }

  Future<void> addPlaceToQuest(String questId, String placeName) async {
    await _db.collection('quests').doc(questId).update({
      'places': FieldValue.arrayUnion([placeName]),
      'targetCount': FieldValue.increment(1),
    });
  }
  // ✅ Unmark — removes from array, resyncs count
  Future<void> unmarkPlaceDone(String questId, String placeId) async {
    final docRef = _db
        .collection('quest_progress')
        .doc(questId)
        .collection('members')
        .doc(_uid);

    final snap = await docRef.get();
    final data = snap.data();
    if (data == null) return;

    final completed = List<String>.from(data['completed'] ?? []);
    if (!completed.contains(placeId)) return;

    completed.remove(placeId);
    // ✅ FIX: always write count = array length
    await docRef.update({
      'completed': completed,
      'completedCount': completed.length,
    });
  }

  // ✅ NEW: Delete a quest and all its progress docs
  Future<void> deleteQuest(String questId, List<String> memberUids) async {
    final batch = _db.batch();
    // Delete progress docs for all members
    for (final uid in memberUids) {
      final ref = _db
          .collection('quest_progress')
          .doc(questId)
          .collection('members')
          .doc(uid);
      batch.delete(ref);
    }
    // Delete the quest itself
    batch.delete(_db.collection('quests').doc(questId));
    await batch.commit();
  }

  Stream<QuerySnapshot> getMyQuests() {
    return _db
        .collection('quests')
        .where('members', arrayContains: _uid)
        .snapshots();
  }

  // ✅ Real-time stream per quest — instant UI updates
  Stream<Map<String, dynamic>> getQuestProgressStream(
      String questId, List<String> memberUids) {
    final controller = StreamController<Map<String, dynamic>>();
    final Map<String, dynamic> state = {};
    final subs = <StreamSubscription>[];

    for (final uid in memberUids) {
      final sub = _db
          .collection('quest_progress')
          .doc(questId)
          .collection('members')
          .doc(uid)
          .snapshots()
          .listen((snap) {
        final data = snap.data() ?? {'completedCount': 0, 'completed': []};
        // ✅ FIX: always recompute count from array so UI is never wrong
        final completed = List<String>.from(data['completed'] ?? []);
        state[uid] = {
          ...data,
          'completed': completed,
          'completedCount': completed.length, // always derived from array
        };
        if (!controller.isClosed) {
          controller.add(Map<String, dynamic>.from(state));
        }
      });
      subs.add(sub);
    }

    controller.onCancel = () {
      for (final s in subs) s.cancel();
    };

    return controller.stream;
  }

  // Legacy Future version
  Future<Map<String, dynamic>> getQuestProgress(
      String questId, List<String> memberUids) async {
    final result = <String, dynamic>{};
    for (final uid in memberUids) {
      final snap = await _db
          .collection('quest_progress')
          .doc(questId)
          .collection('members')
          .doc(uid)
          .get();
      final data = snap.data() ?? {'completedCount': 0, 'completed': []};
      final completed = List<String>.from(data['completed'] ?? []);
      result[uid] = {
        ...data,
        'completed': completed,
        'completedCount': completed.length,
      };
    }
    return result;
  }
}