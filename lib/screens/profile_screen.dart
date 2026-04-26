import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quest_screen.dart';
import 'dna_match_screen.dart';
import '../services/quest_service.dart';
import 'travel_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String name = "";
  String email = "";
  String username = "";
  int visitedCount = 0;
  int wishlistCount = 0;

  final _friendUsernameCtrl = TextEditingController();
  final _questService = QuestService();
  late AnimationController _stampController;
  late Animation<double> _stampAnimation;

  @override
  void initState() {
    super.initState();
    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _stampAnimation = CurvedAnimation(
      parent: _stampController,
      curve: Curves.elasticOut,
    );
    loadUser();
  }

  void loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final data = doc.data() ?? {};
    setState(() {
      name = data['name'] ?? '';
      email = data['email'] ?? '';
      username = data['username'] ?? '';
      visitedCount = (data['visitedPlaces'] as List?)?.length ?? 0;
      wishlistCount = (data['wishlist'] as List?)?.length ?? 0;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _stampController.forward();
    });
  }

  @override
  void dispose() {
    _stampController.dispose();
    _friendUsernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: CustomScrollView(
        slivers: [
          // ── Passport cover header ──────────────
          SliverToBoxAdapter(
            child: _PassportHeader(
              name: name,
              email: email,
              username: username,
              visitedCount: visitedCount,
              wishlistCount: wishlistCount,
              stampAnimation: _stampAnimation,
              onCopyUsername: () {
                Clipboard.setData(ClipboardData(text: username));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Username copied!'),
                    backgroundColor: const Color(0xFF2D6A4F),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),

          // ── Section label ──────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Row(children: [
                const Text('✈', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  'BOARDING PASSES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: Colors.brown.shade400,
                  ),
                ),
              ]),
            ),
          ),

          // ── Boarding pass cards ────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _BoardingPassCard(
                  destination: 'QUEST ZONE',
                  subtitle: 'Shared Goal Quests',
                  tagline: 'Race friends to travel goals',
                  flightCode: 'RE-001',
                  accentColor: const Color(0xFF1B4F72),
                  bgColor: const Color(0xFFEBF5FB),
                  icon: Icons.flag_rounded,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const QuestScreen())),
                ),
                const SizedBox(height: 14),
                _BoardingPassCard(
                  destination: 'DNA LOUNGE',
                  subtitle: 'Travel DNA Match',
                  tagline: 'Find your travel soulmate',
                  flightCode: 'RE-002',
                  accentColor: const Color(0xFF6C3483),
                  bgColor: const Color(0xFFF5EEF8),
                  icon: Icons.people_alt_rounded,
                  onTap: () => _showDNADialog(context),
                ),
                const SizedBox(height: 14),
                _BoardingPassCard(
                  destination: 'MY PASSPORT',
                  subtitle: 'My Travel Profile',
                  tagline: 'Stamps, wishlist & style',
                  flightCode: 'RE-003',
                  accentColor: const Color(0xFF1E8449),
                  bgColor: const Color(0xFFEAF7EF),
                  icon: Icons.book_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TravelProfileScreen()),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDNADialog(BuildContext context) {
    bool isSearching = false;
    String? errorMsg;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EEF8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.people_alt_rounded,
                        color: Color(0xFF9B59B6), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('DNA Match',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 16),
                TextField(
                  controller: _friendUsernameCtrl,
                  decoration: InputDecoration(
                    hintText: "Friend's username",
                    prefixText: '@',
                    filled: true,
                    fillColor: const Color(0xFFF7F3E8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  autocorrect: false,
                ),
                if (errorMsg != null) ...[
                  const SizedBox(height: 8),
                  Text(errorMsg!,
                      style: const TextStyle(
                          color: Colors.red, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isSearching
                          ? null
                          : () async {
                              final input =
                                  _friendUsernameCtrl.text.trim();
                              if (input.isEmpty) return;
                              setDialog(() {
                                isSearching = true;
                                errorMsg = null;
                              });
                              final friendUid = await _questService
                                  .lookupUidByUsername(input);
                              setDialog(() => isSearching = false);
                              if (friendUid == null) {
                                setDialog(() => errorMsg =
                                    'No user found with "@$input"');
                                return;
                              }
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DNAMatchScreen(
                                        otherUid: friendUid),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B59B6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSearching
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Find Match'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Passport Header
// ─────────────────────────────────────────
class _PassportHeader extends StatelessWidget {
  final String name, email, username;
  final int visitedCount, wishlistCount;
  final Animation<double> stampAnimation;
  final VoidCallback onCopyUsername;

  const _PassportHeader({
    required this.name,
    required this.email,
    required this.username,
    required this.visitedCount,
    required this.wishlistCount,
    required this.stampAnimation,
    required this.onCopyUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A3C34),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Dot pattern overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: CustomPaint(painter: _DotPatternPainter()),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ROAMEASE',
                        style: TextStyle(
                          color: Color(0xFF7EC8A4),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF7EC8A4), width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('PASSPORT',
                          style: TextStyle(
                            color: Color(0xFF7EC8A4),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Avatar
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF7EC8A4), width: 3),
                        color: const Color(0xFF2D6A4F),
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Color(0xFF7EC8A4),
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: ScaleTransition(
                        scale: stampAnimation,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE74C3C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 4),
                Text(email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 13,
                    )),
                const SizedBox(height: 12),

                if (username.isNotEmpty)
                  GestureDetector(
                    onTap: onCopyUsername,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7EC8A4).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                const Color(0xFF7EC8A4).withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.alternate_email,
                              color: Color(0xFF7EC8A4), size: 14),
                          const SizedBox(width: 6),
                          Text(username,
                              style: const TextStyle(
                                color: Color(0xFF7EC8A4),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy,
                              color: Color(0xFF7EC8A4), size: 12),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatBadge(
                        count: visitedCount, label: 'Visited', emoji: '🗺️'),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withOpacity(0.15),
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                    ),
                    _StatBadge(
                        count: wishlistCount,
                        label: 'Wishlist',
                        emoji: '⭐'),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final int count;
  final String label, emoji;
  const _StatBadge(
      {required this.count, required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 4),
      Text('$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
      Text(label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
          )),
    ]);
  }
}

// ─────────────────────────────────────────
// Boarding Pass Card
// ─────────────────────────────────────────
class _BoardingPassCard extends StatelessWidget {
  final String destination, subtitle, tagline, flightCode;
  final Color accentColor, bgColor;
  final IconData icon;
  final VoidCallback onTap;

  const _BoardingPassCard({
    required this.destination,
    required this.subtitle,
    required this.tagline,
    required this.flightCode,
    required this.accentColor,
    required this.bgColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent strip
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),

              // Icon column
              SizedBox(
                width: 70,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accentColor, size: 22),
                  ),
                ),
              ),

              // Dashed divider
              SizedBox(
                width: 1,
                child: CustomPaint(
                  painter: _DashedLinePainter(color: accentColor),
                ),
              ),

              // Text content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(destination,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: accentColor.withOpacity(0.65),
                          )),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          )),
                      const SizedBox(height: 4),
                      Text(tagline,
                          style: TextStyle(
                            fontSize: 12,
                            color: accentColor.withOpacity(0.55),
                          )),
                    ],
                  ),
                ),
              ),

              // Right: code + chevron
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 14, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.chevron_right_rounded,
                        color: accentColor.withOpacity(0.45)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: accentColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(flightCode,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: accentColor.withOpacity(0.55),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Custom Painters
// ─────────────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 1;
    const dashH = 5.0, gap = 4.0;
    double y = 8;
    while (y < size.height - 8) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashH), paint);
      y += dashH + gap;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    const spacing = 22.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}