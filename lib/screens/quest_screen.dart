import 'package:flutter/material.dart';
import '../services/quest_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Stamp palette ────────────────────────────
const _cream      = Color(0xFFFAF3E0);
const _paper      = Color(0xFFF5E6C8);
const _paperDark  = Color(0xFFE8D5A3);
const _inkBrown   = Color(0xFF3D2B1F);
const _stampRed   = Color(0xFFB5341E);
const _stampGreen = Color(0xFF2D6A4F);
const _stampBlue  = Color(0xFF2166AC);
const _stampGold  = Color(0xFFD4A017);
const _stampTeal  = Color(0xFF1A7A6E);
const _dimInk     = Color(0xFF8B7355);
const _stampColors = [_stampBlue, _stampRed, _stampGreen, _stampTeal, _stampGold];

const _placeEmojis = ['🗼','🏰','🌋','🏖','🏔','🎡','⛩','🕌','🗽','🌉','🏝','🛕'];

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> with SingleTickerProviderStateMixin {
  final _service = QuestService();
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _paper,
        elevation: 0,
        iconTheme: const IconThemeData(color: _inkBrown),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(height: 0.5, color: _paperDark),
              TabBar(
                controller: _tabCtrl,
                labelColor: _stampRed,
                unselectedLabelColor: _dimInk,
                indicatorColor: _stampRed,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2),
                tabs: const [
                  Tab(text: '✈  ACTIVE'),
                  Tab(text: '🏆  DONE'),
                  Tab(text: '📬  INVITES'),
                ],
              ),
            ],
          ),
        ),
        title: Row(children: [
          const Text('✈', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          const Text('MY QUESTS',
              style: TextStyle(
                  color: _inkBrown,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  letterSpacing: 3)),
        ]),
        actions: [
          GestureDetector(
            onTap: () => _showCreateQuestDialog(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: _stampRed, width: 1.5),
                borderRadius: BorderRadius.circular(4),
                color: _stampRed.withOpacity(0.08),
              ),
              child: const Text('+ NEW',
                  style: TextStyle(
                      color: _stampRed,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _service.getMyQuests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: _stampRed));
          }
          final allQuests = snapshot.data!.docs;

          return TabBarView(
            controller: _tabCtrl,
            children: [
              // ── ACTIVE TAB ───────────────────
              _QuestListView(
                quests: allQuests,
                uid: _uid,
                service: _service,
                showCompleted: false,
                onEmpty: () => _showCreateQuestDialog(context),
              ),
              // ── SCRAPBOOK TAB ─────────────────
              _QuestListView(
                quests: allQuests,
                uid: _uid,
                service: _service,
                showCompleted: true,
                onEmpty: () => _showCreateQuestDialog(context),
              ),
              // ── INVITES TAB ───────────────────
              _InvitesTab(service: _service, uid: _uid),
            ],
          );
        },
      ),
    );
  }

  void _showCreateQuestDialog(BuildContext context) {
    final titleCtrl  = TextEditingController();
    final friendCtrl = TextEditingController(); // now accepts username
    final placesCtrl = TextEditingController();
    String? _errorMsg;
    bool _loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: _stampRed, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('NEW QUEST',
                      style: TextStyle(
                          color: _stampRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 3)),
                ),
              ),
              const SizedBox(height: 20),
              _stampInput(titleCtrl, 'Quest title e.g. "10 places in Pune"', '🚩'),
              const SizedBox(height: 12),
              _stampInput(placesCtrl, 'Places (comma separated)', '📍'),
              const SizedBox(height: 12),
              _stampInput(friendCtrl, "Friend's username (e.g. gayatri)", '👤'),
              if (_errorMsg != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  const Text('⚠️', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(_errorMsg!,
                      style: const TextStyle(color: _stampRed, fontSize: 12)),
                ]),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _stampRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  onPressed: _loading ? null : () async {
                    setSheet(() { _loading = true; _errorMsg = null; });

                    final username = friendCtrl.text.trim();
                    if (username.isEmpty) {
                      setSheet(() { _errorMsg = "Enter your friend's username"; _loading = false; });
                      return;
                    }

                    // Look up UID from username
                    final friendUid = await _service.lookupUidByUsername(username);
                    if (friendUid == null) {
                      setSheet(() {
                        _errorMsg = 'No user found with username "$username"';
                        _loading = false;
                      });
                      return;
                    }

                    // Make sure they're not inviting themselves
                    if (friendUid == _uid) {
                      setSheet(() {
                        _errorMsg = "That's your own username!";
                        _loading = false;
                      });
                      return;
                    }

                    final places = placesCtrl.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    await _service.createQuest(
                      title: titleCtrl.text,
                      placeIds: places,
                      friendUid: friendUid,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: _loading
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('SEND QUEST',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 2)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _stampInput(TextEditingController ctrl, String hint, String emoji) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: _inkBrown),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _dimInk.withOpacity(0.7), fontSize: 13),
        prefixText: '$emoji  ',
        filled: true,
        fillColor: _cream,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _paperDark)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: _paperDark)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _stampRed, width: 1.5)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INVITES TAB
// ─────────────────────────────────────────────
class _InvitesTab extends StatelessWidget {
  final QuestService service;
  final String uid;

  const _InvitesTab({required this.service, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: service.getPendingInvites(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: _stampRed));
        }

        final invites = snapshot.data!.docs;

        if (invites.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: _stampBlue, width: 2),
                  color: _stampBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text('📬', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('NO PENDING INVITES',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _inkBrown,
                      letterSpacing: 3)),
              const SizedBox(height: 8),
              const Text('Quest invites from friends appear here',
                  style: TextStyle(color: _dimInk, fontSize: 13)),
            ]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          itemCount: invites.length,
          itemBuilder: (context, i) {
            final doc = invites[i];
            final q = doc.data() as Map<String, dynamic>;
            final questId = doc.id;
            final places = List<String>.from(q['places'] ?? []);
            final color = _stampColors[i % _stampColors.length];

            return _InviteCard(
              questId: questId,
              title: q['title'] ?? 'Untitled Quest',
              places: places,
              service: service,
              stampColor: color,
              questIndex: i,
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// INVITE CARD
// ─────────────────────────────────────────────
class _InviteCard extends StatefulWidget {
  final String questId, title;
  final List<String> places;
  final QuestService service;
  final Color stampColor;
  final int questIndex;

  const _InviteCard({
    required this.questId,
    required this.title,
    required this.places,
    required this.service,
    required this.stampColor,
    required this.questIndex,
  });

  @override
  State<_InviteCard> createState() => _InviteCardState();
}

class _InviteCardState extends State<_InviteCard> {
  bool _loading = false;

  static const _icons = ['✈','🌍','🗺','🧭','⛵','🏔','🌊'];

  @override
  Widget build(BuildContext context) {
    final icon = _icons[widget.questIndex % _icons.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: widget.stampColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: widget.stampColor.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Column(
          children: [
            // Colored top bar
            Container(height: 6, color: widget.stampColor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(children: [
                    Text(icon, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title.toUpperCase(),
                              style: TextStyle(
                                  color: widget.stampColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.5)),
                          const SizedBox(height: 2),
                          Text('${widget.places.length} destinations',
                              style: const TextStyle(
                                  color: _dimInk, fontSize: 11)),
                        ],
                      ),
                    ),
                    // "Invited!" badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.stampColor.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(99),
                        color: widget.stampColor.withOpacity(0.07),
                      ),
                      child: Text('📬 INVITED',
                          style: TextStyle(
                              color: widget.stampColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                    ),
                  ]),

                  const SizedBox(height: 12),
                  _PerforatedLine(color: widget.stampColor),
                  const SizedBox(height: 12),

                  // Places preview
                  if (widget.places.isNotEmpty) ...[
                    Text('DESTINATIONS',
                        style: TextStyle(
                            color: widget.stampColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.places.take(6).map((place) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: widget.stampColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: widget.stampColor.withOpacity(0.3)),
                        ),
                        child: Text('📍 $place',
                            style: TextStyle(
                                color: widget.stampColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      )).toList(),
                    ),
                    if (widget.places.length > 6) ...[
                      const SizedBox(height: 6),
                      Text('+${widget.places.length - 6} more places',
                          style: const TextStyle(color: _dimInk, fontSize: 11,
                              fontStyle: FontStyle.italic)),
                    ],
                    const SizedBox(height: 16),
                  ],

                  // Accept / Decline buttons
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(color: _stampRed, strokeWidth: 2),
                      ),
                    )
                  else
                    Row(children: [
                      // Decline
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            setState(() => _loading = true);
                            await widget.service.declineQuest(widget.questId);
                            // card disappears automatically via stream
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _stampRed.withOpacity(0.4)),
                              color: _stampRed.withOpacity(0.04),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('✕', style: TextStyle(color: _stampRed, fontSize: 14)),
                                SizedBox(width: 6),
                                Text('DECLINE',
                                    style: TextStyle(
                                        color: _stampRed,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Accept
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() => _loading = true);
                            await widget.service.acceptQuest(widget.questId);
                            // quest moves to active tab automatically via stream
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: widget.stampColor,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('✓', style: TextStyle(color: Colors.white, fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                                SizedBox(width: 6),
                                Text('ACCEPT QUEST',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QUEST LIST VIEW (used by both tabs)
// ─────────────────────────────────────────────
class _QuestListView extends StatelessWidget {
  final List<dynamic> quests;
  final String uid;
  final QuestService service;
  final bool showCompleted;
  final VoidCallback onEmpty;

  const _QuestListView({
    required this.quests,
    required this.uid,
    required this.service,
    required this.showCompleted,
    required this.onEmpty,
  });

  @override
  Widget build(BuildContext context) {
    if (quests.isEmpty) {
      return _EmptyQuestState(onCreateTap: onEmpty, isScrapbook: showCompleted);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: quests.length,
      itemBuilder: (context, i) {
        final doc     = quests[i];
        final q       = doc.data() as Map<String, dynamic>;
        final questId = doc.id;
        final members = List<String>.from(q['members']);
        final places  = List<String>.from(q['places'] ?? []);
        final color   = _stampColors[i % _stampColors.length];

        return _QuestCard(
          questId: questId,
          title: q['title'],
          targetCount: q['targetCount'],
          members: members,
          places: places,
          currentUid: uid,
          service: service,
          stampColor: color,
          questIndex: i,
          showCompleted: showCompleted,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// QUEST CARD
// ─────────────────────────────────────────────
class _QuestCard extends StatelessWidget {
  final String questId, title;
  final int targetCount;
  final List<String> members;
  final List<String> places;
  final String currentUid;
  final QuestService service;
  final Color stampColor;
  final int questIndex;
  final bool showCompleted;

  static const _icons = ['✈','🌍','🗺','🧭','⛵','🏔','🌊'];

  const _QuestCard({
    required this.questId,
    required this.title,
    required this.targetCount,
    required this.members,
    required this.places,
    required this.currentUid,
    required this.service,
    required this.stampColor,
    required this.questIndex,
    required this.showCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _icons[questIndex % _icons.length];

    return StreamBuilder<Map<String, dynamic>>(
      stream: service.getQuestProgressStream(questId, members),
      builder: (context, snap) {
        final progress        = snap.data ?? {};
        final myData          = progress[currentUid] as Map<String, dynamic>?;
        final myCompleted     = List<String>.from(myData?['completed'] ?? []);
        final myCount         = myCompleted.length;

        final friendUid       = members.firstWhere(
            (m) => m != currentUid, orElse: () => '');
        final friendData      = progress[friendUid] as Map<String, dynamic>?;
        final friendCompleted = List<String>.from(friendData?['completed'] ?? []);
        final friendCount     = friendCompleted.length;

        final isMyComplete   = myCount >= targetCount && targetCount > 0;
        final isBothComplete = isMyComplete && friendCount >= targetCount && targetCount > 0;

        // Only move to scrapbook when BOTH are done
        if (showCompleted && !isBothComplete) return const SizedBox.shrink();
        if (!showCompleted && isBothComplete) return const SizedBox.shrink();

        // ── SCRAPBOOK card (completed) ────────
        if (showCompleted) {
          return _ScrapbookCard(
            title: title,
            places: places,
            myCompleted: myCompleted,
            friendCompleted: friendCompleted,
            stampColor: stampColor,
            icon: icon,
            isBothComplete: isBothComplete,
            questId: questId,
            members: members,
            service: service,
          );
        }

        // ── ACTIVE card ───────────────────────
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: _StampCardWrapper(
            color: stampColor,
            isComplete: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(children: [
                  Text(icon, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title.toUpperCase(),
                            style: TextStyle(
                                color: stampColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 2),
                        Text('${places.length} destinations',
                            style: const TextStyle(
                                color: _dimInk, fontSize: 11)),
                      ],
                    ),
                  ),
                  _ProgressPill(
                      completed: myCount,
                      total: targetCount,
                      color: stampColor),
                  const SizedBox(width: 8),
                  // Delete button
                  GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _stampRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _stampRed.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: _stampRed, size: 16),
                    ),
                  ),
                ]),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: _PerforatedLine(color: stampColor),
                ),

                // Progress bars
                _StampProgressBar(
                    label: 'YOU',
                    emoji: '🧳',
                    completed: myCount,
                    total: targetCount,
                    color: stampColor),
                const SizedBox(height: 8),
                _StampProgressBar(
                    label: 'FRIEND',
                    emoji: '👤',
                    completed: friendCount,
                    total: targetCount,
                    color: _dimInk),

                const SizedBox(height: 18),

                // Your stamp nodes
                Row(children: [
                  const Text('🧳', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text('YOUR STAMPS',
                      style: TextStyle(
                          color: stampColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                ]),
                const SizedBox(height: 10),
                _StampNodesRow(
                  places: places,
                  completed: myCompleted,
                  color: stampColor,
                  isMe: true,
                  onTap: (place, isDone) async {
                    if (isDone) {
                      await service.unmarkPlaceDone(questId, place);
                    } else {
                      await service.markPlaceDone(questId, place);
                    }
                  },
                ),

                const SizedBox(height: 18),

                // Friend stamp nodes
                Row(children: [
                  const Text('👤', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  const Text("FRIEND'S STAMPS",
                      style: TextStyle(
                          color: _dimInk,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                ]),
                const SizedBox(height: 10),
                _StampNodesRow(
                  places: places,
                  completed: friendCompleted,
                  color: _dimInk,
                  isMe: false,
                  onTap: null,
                ),

                const SizedBox(height: 16),

                // Add a place button
                GestureDetector(
                  onTap: () => _showAddPlaceSheet(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: stampColor.withOpacity(0.6)),
                      color: stampColor.withOpacity(0.06),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Text('ADD A PLACE',
                            style: TextStyle(
                                color: stampColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Stamp a place button
                GestureDetector(
                  onTap: () => _showStampSheet(context, places, myCompleted),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: stampColor.withOpacity(0.6)),
                      color: stampColor.withOpacity(0.06),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📮', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Text('STAMP A PLACE',
                            style: TextStyle(
                                color: stampColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(children: [
          Text('🗑', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('DELETE QUEST',
              style: TextStyle(
                  color: _stampRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1)),
        ]),
        content: Text(
          'Are you sure you want to delete "$title"?\nThis cannot be undone.',
          style: const TextStyle(color: _inkBrown, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL',
                style: TextStyle(color: _dimInk, letterSpacing: 1)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _stampRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () async {
              await service.deleteQuest(questId, members);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('DELETE',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  void _showStampSheet(
      BuildContext context, List<String> places, List<String> myCompleted) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _paper,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: _paperDark,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Row(children: [
                Text('📮', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text('YOUR PASSPORT',
                    style: TextStyle(
                        color: _inkBrown,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 2)),
              ]),
              const SizedBox(height: 4),
              const Text('Tap to stamp  •  Tap again to remove stamp',
                  style: TextStyle(
                      color: _dimInk, fontSize: 11, letterSpacing: 0.3)),
              const SizedBox(height: 16),
              ...places.map((place) {
                final done = myCompleted.contains(place);
                return GestureDetector(
                  onTap: () async {
                    if (done) {
                      await service.unmarkPlaceDone(questId, place);
                    } else {
                      await service.markPlaceDone(questId, place);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: done ? stampColor.withOpacity(0.08) : _cream,
                      border: Border.all(
                          color: done
                              ? stampColor.withOpacity(0.5)
                              : _paperDark),
                    ),
                    child: Row(children: [
                      Text(done ? '📍' : '○',
                          style: TextStyle(
                              fontSize: done ? 16 : 18,
                              color: done ? stampColor : _dimInk)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(place,
                            style: TextStyle(
                                color: done ? stampColor : _inkBrown,
                                fontSize: 14,
                                fontWeight: done
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                      ),
                      if (done)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: stampColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                                color: stampColor.withOpacity(0.4)),
                          ),
                          child: Text('STAMPED',
                              style: TextStyle(
                                  color: stampColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                        )
                      else
                        const Text('tap to stamp',
                            style: TextStyle(
                                color: _dimInk,
                                fontSize: 10,
                                fontStyle: FontStyle.italic)),
                    ]),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPlaceSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: _paperDark,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Row(children: [
              Text('📍', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('ADD A PLACE',
                  style: TextStyle(
                      color: _inkBrown,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2)),
            ]),
            const SizedBox(height: 4),
            const Text('Visible to both you and your friend instantly',
                style: TextStyle(color: _dimInk, fontSize: 11)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              style: const TextStyle(color: _inkBrown),
              decoration: InputDecoration(
                hintText: 'e.g. Shaniwar Wada',
                hintStyle:
                    TextStyle(color: _dimInk.withOpacity(0.7), fontSize: 13),
                prefixText: '📍  ',
                filled: true,
                fillColor: _cream,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: _paperDark)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: _paperDark)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: stampColor, width: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: stampColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                onPressed: () async {
                  final name = ctrl.text.trim();
                  if (name.isEmpty) return;
                  await service.addPlaceToQuest(questId, name);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('ADD TO QUEST',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SCRAPBOOK CARD (completed quests)
// ─────────────────────────────────────────────
class _ScrapbookCard extends StatelessWidget {
  final String title, icon, questId;
  final List<String> places, myCompleted, friendCompleted, members;
  final Color stampColor;
  final bool isBothComplete;
  final QuestService service;

  const _ScrapbookCard({
    required this.title,
    required this.places,
    required this.myCompleted,
    required this.friendCompleted,
    required this.stampColor,
    required this.icon,
    required this.isBothComplete,
    required this.questId,
    required this.members,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _stampGold, width: 2),
        boxShadow: [
          BoxShadow(
              color: _stampGold.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Column(
          children: [
            Container(height: 6, color: _stampGold),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title.toUpperCase(),
                              style: const TextStyle(
                                  color: _stampGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.5)),
                          const SizedBox(height: 2),
                          Text('${places.length} places explored',
                              style: const TextStyle(
                                  color: _dimInk, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _stampGold, width: 2.5),
                        color: _stampGold.withOpacity(0.08),
                      ),
                      child: const Center(
                        child: Text('✓',
                            style: TextStyle(
                                color: _stampGold,
                                fontSize: 26,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _stampGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _stampGold.withOpacity(0.4)),
                    ),
                    child: Column(children: [
                      const Text('🏆', style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(
                        isBothComplete
                            ? 'BOTH EXPLORERS COMPLETED!'
                            : 'YOU COMPLETED THIS QUEST!',
                        style: const TextStyle(
                            color: _stampGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.5),
                      ),
                      if (isBothComplete) ...[
                        const SizedBox(height: 2),
                        const Text('🤝 Journey completed together',
                            style: TextStyle(
                                color: _dimInk,
                                fontSize: 10,
                                fontStyle: FontStyle.italic)),
                      ]
                    ]),
                  ),

                  const SizedBox(height: 14),
                  _PerforatedLine(color: _stampGold),
                  const SizedBox(height: 14),

                  const Text('PLACES VISITED',
                      style: TextStyle(
                          color: _stampGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: places.asMap().entries.map((e) {
                      final index = e.key;
                      final name  = e.value;
                      final emoji = _placeEmojis[index % _placeEmojis.length];
                      return Container(
                        width: 62,
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 4),
                        decoration: BoxDecoration(
                          color: _stampGold.withOpacity(0.08),
                          border: Border.all(
                              color: _stampGold.withOpacity(0.5), width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (_) => Container(
                                width: 4, height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                    color: _stampGold.withOpacity(0.3),
                                    shape: BoxShape.circle),
                              )),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 42, height: 32,
                              decoration: BoxDecoration(
                                color: _stampGold.withOpacity(0.12),
                                border: Border.all(
                                    color: _stampGold.withOpacity(0.3)),
                              ),
                              child: Center(
                                child: Text(emoji,
                                    style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (_) => Container(
                                width: 4, height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                    color: _stampGold.withOpacity(0.3),
                                    shape: BoxShape.circle),
                              )),
                            ),
                            const SizedBox(height: 3),
                            Text(name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 8,
                                    color: _stampGold,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _stampRed.withOpacity(0.4)),
                        color: _stampRed.withOpacity(0.04),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline, color: _stampRed, size: 14),
                          SizedBox(width: 6),
                          Text('DELETE QUEST',
                              style: TextStyle(
                                  color: _stampRed,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(children: [
          Text('🗑', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('DELETE QUEST',
              style: TextStyle(
                  color: _stampRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1)),
        ]),
        content: Text(
          'Delete "$title" from your scrapbook?\nThis cannot be undone.',
          style: const TextStyle(color: _inkBrown, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL',
                style: TextStyle(color: _dimInk, letterSpacing: 1)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _stampRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () async {
              await service.deleteQuest(questId, members);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('DELETE',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STAMP CARD WRAPPER
// ─────────────────────────────────────────────
class _StampCardWrapper extends StatelessWidget {
  final Color color;
  final bool isComplete;
  final Widget child;

  const _StampCardWrapper({
    required this.color,
    required this.isComplete,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isComplete ? _stampGold : color.withOpacity(0.4),
          width: isComplete ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4)),
          const BoxShadow(
              color: Color(0x18000000),
              blurRadius: 4,
              offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Column(children: [
          Container(height: 6, color: isComplete ? _stampGold : color),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PERFORATED LINE
// ─────────────────────────────────────────────
class _PerforatedLine extends StatelessWidget {
  final Color color;
  const _PerforatedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const dotSize = 5.0;
      const gap = 5.0;
      final count = (constraints.maxWidth / (dotSize + gap)).floor();
      return Row(
        children: List.generate(count, (i) => Container(
          width: dotSize, height: dotSize,
          margin: const EdgeInsets.only(right: gap),
          decoration: BoxDecoration(
              color: color.withOpacity(0.25), shape: BoxShape.circle),
        )),
      );
    });
  }
}

// ─────────────────────────────────────────────
// PROGRESS BAR
// ─────────────────────────────────────────────
class _StampProgressBar extends StatelessWidget {
  final String label, emoji;
  final int completed, total;
  final Color color;

  const _StampProgressBar({
    required this.label,
    required this.emoji,
    required this.completed,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    return Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1)),
      const SizedBox(width: 8),
      Expanded(
        child: Stack(children: [
          Container(
            height: 7,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
          ),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct,
            child: Container(
              height: 7,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(99)),
            ),
          ),
        ]),
      ),
      const SizedBox(width: 8),
      Text('$completed/$total',
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    ]);
  }
}

// ─────────────────────────────────────────────
// PROGRESS PILL
// ─────────────────────────────────────────────
class _ProgressPill extends StatelessWidget {
  final int completed, total;
  final Color color;
  const _ProgressPill(
      {required this.completed, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(99),
        color: color.withOpacity(0.07),
      ),
      child: Text('$completed/$total',
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5)),
    );
  }
}

// ─────────────────────────────────────────────
// STAMP NODES
// ─────────────────────────────────────────────
class _StampNodesRow extends StatelessWidget {
  final List<String> places;
  final List<String> completed;
  final Color color;
  final bool isMe;
  final void Function(String place, bool isDone)? onTap;

  const _StampNodesRow({
    required this.places,
    required this.completed,
    required this.color,
    required this.isMe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: places.asMap().entries.map((e) {
        final index  = e.key;
        final name   = e.value;
        final isDone = completed.contains(name);
        final emoji  = _placeEmojis[index % _placeEmojis.length];

        return GestureDetector(
          onTap: isMe && onTap != null ? () => onTap!(name, isDone) : null,
          child: Container(
            width: 62,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: isDone ? color.withOpacity(0.08) : _cream,
              border: Border.all(
                  color: isDone ? color : _paperDark,
                  width: isDone ? 1.5 : 1),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isDone
                  ? [BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2))]
                  : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (_) => Container(
                    width: 4, height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                        color: isDone
                            ? color.withOpacity(0.3)
                            : _paperDark.withOpacity(0.5),
                        shape: BoxShape.circle),
                  )),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 42, height: 34,
                  decoration: BoxDecoration(
                    color: isDone
                        ? color.withOpacity(0.12)
                        : _paperDark.withOpacity(0.2),
                    border: Border.all(
                        color: isDone ? color.withOpacity(0.3) : _paperDark,
                        width: 1),
                  ),
                  child: Center(
                    child: isDone
                        ? Text(emoji, style: const TextStyle(fontSize: 18))
                        : Text('${index + 1}',
                            style: const TextStyle(
                                color: _dimInk,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (_) => Container(
                    width: 4, height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                        color: isDone
                            ? color.withOpacity(0.3)
                            : _paperDark.withOpacity(0.5),
                        shape: BoxShape.circle),
                  )),
                ),
                const SizedBox(height: 4),
                Text(name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 8,
                        color: isDone ? color : _dimInk,
                        fontWeight:
                            isDone ? FontWeight.bold : FontWeight.normal,
                        letterSpacing: 0.3)),
                if (isDone && isMe) ...[
                  const SizedBox(height: 2),
                  Text('✕ undo',
                      style: TextStyle(
                          fontSize: 7,
                          color: color.withOpacity(0.5),
                          fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyQuestState extends StatelessWidget {
  final VoidCallback onCreateTap;
  final bool isScrapbook;
  const _EmptyQuestState(
      {required this.onCreateTap, required this.isScrapbook});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            border: Border.all(
                color: isScrapbook ? _stampGold : _stampRed, width: 2),
            color: (isScrapbook ? _stampGold : _stampRed).withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(isScrapbook ? '🏆' : '✈',
                style: const TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isScrapbook ? 'NO COMPLETED QUESTS' : 'NO ACTIVE QUESTS',
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _inkBrown,
              letterSpacing: 3),
        ),
        const SizedBox(height: 8),
        Text(
          isScrapbook
              ? 'Complete a quest to see it here'
              : 'Start a journey with a friend',
          style: const TextStyle(color: _dimInk, fontSize: 13),
        ),
        if (!isScrapbook) ...[
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onCreateTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: _stampRed,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('START YOUR JOURNEY',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.5)),
            ),
          ),
        ]
      ]),
    );
  }
}