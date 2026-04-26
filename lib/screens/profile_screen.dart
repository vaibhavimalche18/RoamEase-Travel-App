import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quest_screen.dart';
import 'dna_match_screen.dart';
import '../services/quest_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name     = "";
  String email    = "";
  String username = "";

  final _friendUsernameCtrl = TextEditingController();
  final _questService = QuestService();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    setState(() {
      name     = doc['name']     ?? '';
      email    = doc['email']    ?? '';
      username = doc['username'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar + name + email ─────────────
            const CircleAvatar(radius: 40),
            const SizedBox(height: 12),
            Text(name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(email,
                style: TextStyle(color: Colors.grey[600])),

            // ── Username chip ─────────────────────
            if (username.isNotEmpty) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: username));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Username copied to clipboard!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👤 ',
                          style: TextStyle(fontSize: 13)),
                      Text('@$username',
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5)),
                      const SizedBox(width: 6),
                      const Icon(Icons.copy, size: 13, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Share your username so friends can invite you to quests',
                style: TextStyle(color: Colors.grey, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // ── Quest button ──────────────────────
            _FeatureCard(
              icon: Icons.flag_outlined,
              color: Colors.blue,
              title: 'Shared Goal Quests',
              subtitle: 'Race friends to complete travel goals',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuestScreen()),
              ),
            ),

            const SizedBox(height: 16),

            // ── DNA Match button ──────────────────
            _FeatureCard(
              icon: Icons.people_outline,
              color: Colors.purple,
              title: 'Travel DNA Match',
              subtitle: 'Find your travel soulmate',
              onTap: () => _showDNADialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDNADialog(BuildContext context) {
    bool isSearching = false;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('Travel DNA Match'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _friendUsernameCtrl,
                decoration: const InputDecoration(
                  hintText: "Friend's username (e.g. gayatri)",
                  prefixText: '@',
                  border: OutlineInputBorder(),
                ),
                autocorrect: false,
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 8),
                Text(errorMsg!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSearching ? null : () async {
                final input = _friendUsernameCtrl.text.trim();
                if (input.isEmpty) return;

                setDialog(() { isSearching = true; errorMsg = null; });

                final friendUid =
                    await _questService.lookupUidByUsername(input);

                setDialog(() => isSearching = false);

                if (friendUid == null) {
                  setDialog(() => errorMsg = 'No user found with username "@$input"');
                  return;
                }

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DNAMatchScreen(otherUid: friendUid),
                    ),
                  );
                }
              },
              child: isSearching
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Match'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _friendUsernameCtrl.dispose();
    super.dispose();
  }
}

// ── Reusable feature card ─────────────────────
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}