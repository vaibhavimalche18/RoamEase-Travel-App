import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quest_screen.dart';       // NEW
import 'dna_match_screen.dart';   // NEW

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  // NEW ↓
  final _friendUidCtrl = TextEditingController();

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
      name = doc['name'];
      email = doc['email'];
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
      body: SingleChildScrollView(               // NEW — was just Column
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── existing ──────────────────────────
            const CircleAvatar(radius: 40),
            const SizedBox(height: 20),
            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(email, style: TextStyle(color: Colors.grey[600])),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // ── NEW: Quest button ─────────────────
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

            // ── NEW: DNA Match button ─────────────
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

  // NEW — dialog to enter friend UID before opening DNA screen
  void _showDNADialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Travel DNA Match'),
        content: TextField(
          controller: _friendUidCtrl,
          decoration: const InputDecoration(
            hintText: "Paste your friend's user ID",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (_friendUidCtrl.text.trim().isEmpty) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DNAMatchScreen(
                    otherUid: _friendUidCtrl.text.trim(),
                  ),
                ),
              );
            },
            child: const Text('Match'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _friendUidCtrl.dispose();  // NEW
    super.dispose();
  }
}

// NEW widget — reusable card for feature buttons
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