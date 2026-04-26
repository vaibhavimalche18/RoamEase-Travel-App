import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class QuestService {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ── LOOKUP UID BY USERNAME ─────────────────────────────────────────
  Future<String?> lookupUidByUsername(String username) async {
    final snap = await _db
        .collection('users')
        .where('username', isEqualTo: username.trim().toLowerCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id; // doc ID is the UID
  }

  // ── CREATE QUEST (sends invite to friend, quest starts as pending) ──
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
      // 'pending' = waiting for friend to accept
      // 'active'  = both accepted, quest is live
      'status': 'pending',
      'invitedUid': friendUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Only create progress doc for the creator — friend's is created on accept
    await _db
        .collection('quest_progress')
        .doc(ref.id)
        .collection('members')
        .doc(_uid)
        .set({'completed': [], 'completedCount': 0});

    return ref.id;
  }

  // ── ACCEPT INVITE ──────────────────────────────────────────────────
  Future<void> acceptQuest(String questId) async {
    // Create progress doc for the friend (acceptor)
    await _db
        .collection('quest_progress')
        .doc(questId)
        .collection('members')
        .doc(_uid)
        .set({'completed': [], 'completedCount': 0});

    // Mark quest as active — now visible to both members
    await _db.collection('quests').doc(questId).update({
      'status': 'active',
    });
  }

  // ── DECLINE INVITE ─────────────────────────────────────────────────
  Future<void> declineQuest(String questId) async {
    await _db.collection('quests').doc(questId).update({
      'status': 'declined',
    });
  }

  // ── MARK PLACE DONE ────────────────────────────────────────────────
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
    await docRef.update({
      'completed': completed,
      'completedCount': completed.length,
    });
  }

  // ── UNMARK PLACE ───────────────────────────────────────────────────
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
    await docRef.update({
      'completed': completed,
      'completedCount': completed.length,
    });
  }

  // ── ADD PLACE TO QUEST (visible to both members instantly) ─────────
  Future<void> addPlaceToQuest(String questId, String placeName) async {
    await _db.collection('quests').doc(questId).update({
      'places': FieldValue.arrayUnion([placeName]),
      'targetCount': FieldValue.increment(1),
    });
  }

  // ── DELETE QUEST ───────────────────────────────────────────────────
  Future<void> deleteQuest(String questId, List<String> memberUids) async {
    final batch = _db.batch();
    for (final uid in memberUids) {
      final ref = _db
          .collection('quest_progress')
          .doc(questId)
          .collection('members')
          .doc(uid);
      batch.delete(ref);
    }
    batch.delete(_db.collection('quests').doc(questId));
    await batch.commit();
  }

  // ── MY ACTIVE QUESTS (status == active, I am a member) ────────────
  Stream<QuerySnapshot> getMyQuests() {
    return _db
        .collection('quests')
        .where('members', arrayContains: _uid)
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  // ── PENDING INVITES sent TO me ─────────────────────────────────────
  Stream<QuerySnapshot> getPendingInvites() {
    return _db
        .collection('quests')
        .where('invitedUid', isEqualTo: _uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // ── REAL-TIME PROGRESS STREAM ──────────────────────────────────────
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
        final completed = List<String>.from(data['completed'] ?? []);
        state[uid] = {
          ...data,
          'completed': completed,
          'completedCount': completed.length,
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

  // ── LEGACY FUTURE VERSION ──────────────────────────────────────────
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