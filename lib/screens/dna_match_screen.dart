import 'package:flutter/material.dart';
import '../services/match_service.dart';

class DNAMatchScreen extends StatefulWidget {
  final String otherUid;
  const DNAMatchScreen({super.key, required this.otherUid});

  @override
  State<DNAMatchScreen> createState() => _DNAMatchScreenState();
}

class _DNAMatchScreenState extends State<DNAMatchScreen> {
  final _service = MatchService();
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.calculateDNA(widget.otherUid);
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final score = _data!['score'] as int;
    final name = _data!['otherName'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: Text('DNA Match with $name'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 12),
          // Score ring
          Container(
            width: 150, height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: _scoreColor(score), width: 6),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$score%',
                    style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: _scoreColor(score))),
                Text('match',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(_scoreLabel(score),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Based on visited places, wishlist & travel style',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(height: 28),

          _DNACard(icon: Icons.where_to_vote, color: Colors.blue,
              title: 'Places you both visited',
              items: List<String>.from(_data!['sharedVisited'])),
          _DNACard(icon: Icons.favorite, color: Colors.pink,
              title: 'Shared dream destinations',
              items: List<String>.from(_data!['sharedWishlist'])),
          _DNACard(icon: Icons.local_activity, color: Colors.teal,
              title: 'You can guide them',
              items: List<String>.from(_data!['youCanGuide'])),
          _DNACard(icon: Icons.explore, color: Colors.purple,
              title: '$name can guide you',
              items: List<String>.from(_data!['theyCanGuide'])),
          _DNACard(icon: Icons.style, color: Colors.orange,
              title: 'Shared travel style',
              items: List<String>.from(_data!['sharedStyles'])),
        ]),
      ),
    );
  }

  Color _scoreColor(int s) =>
      s >= 70 ? Colors.green : s >= 40 ? Colors.blue : Colors.orange;

  String _scoreLabel(int s) {
    if (s >= 80) return 'Travel soulmates!';
    if (s >= 60) return 'Great travel buddies';
    if (s >= 40) return 'Good match';
    return 'Different paths — still interesting!';
  }
}

class _DNACard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<String> items;

  const _DNACard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text('${items.length}',
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            )
          ]),
          const SizedBox(height: 12),
          items.isEmpty
              ? Text('None yet',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items
                      .map((p) => Chip(
                            label: Text(p,
                                style: const TextStyle(fontSize: 12)),
                            backgroundColor: color.withOpacity(0.08),
                            side: BorderSide.none,
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }
}