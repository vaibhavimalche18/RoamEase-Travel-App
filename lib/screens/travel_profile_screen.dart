import 'package:flutter/material.dart';
import '../services/match_service.dart';

class TravelProfileScreen extends StatefulWidget {
  const TravelProfileScreen({super.key});

  @override
  State<TravelProfileScreen> createState() => _TravelProfileScreenState();
}

class _TravelProfileScreenState extends State<TravelProfileScreen> {
  final _service = MatchService();
  bool _loading = true;
  bool _saving = false;

  // ── Visited places ──
  final List<String> _visitedPlaces = [];
  final _visitedController = TextEditingController();

  // ── Wishlist ──
  final List<String> _wishlist = [];
  final _wishlistController = TextEditingController();

  // ── Travel style (multi-select) ──
  final List<String> _allStyles = [
    'Adventure', 'Beach', 'Culture', 'Foodie', 'Backpacker',
    'Luxury', 'Solo', 'Nature', 'City Break', 'Road Trip',
    'Photography', 'Wellness', 'Spiritual', 'Budget', 'Family',
  ];
  final Set<String> _selectedStyles = {};

  // ── Single-value preferences ──
  String? _budget;
  String? _companionPref;
  String? _climatePref;
  String? _tripDuration;
  String? _travelFrequency;

  static const _budgetOptions = ['Budget', 'Mid-range', 'Luxury'];
  static const _companionOptions = ['Solo', 'Partner', 'Friends', 'Family', 'Any'];
  static const _climateOptions = ['Tropical', 'Cold', 'Dry', 'Temperate', 'Any'];
  static const _durationOptions = ['Weekend', '1 Week', '2 Weeks', '1 Month+'];
  static const _frequencyOptions = ['Monthly', 'Every few months', 'Yearly', 'Rarely'];

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final data = await _service.loadMyProfile();
    if (!mounted) return;
    setState(() {
      _visitedPlaces.addAll(List<String>.from(data['visitedPlaces'] ?? []));
      _wishlist.addAll(List<String>.from(data['wishlist'] ?? []));
      _selectedStyles.addAll(List<String>.from(data['travelStyle'] ?? []));
      _budget = data['budget'];
      _companionPref = data['companionPref'];
      _climatePref = data['climatePref'];
      _tripDuration = data['tripDuration'];
      _travelFrequency = data['travelFrequency'];
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _service.updateProfile({
        'visitedPlaces': _visitedPlaces,
        'wishlist': _wishlist,
        'travelStyle': _selectedStyles.toList(),
        if (_budget != null) 'budget': _budget,
        if (_companionPref != null) 'companionPref': _companionPref,
        if (_climatePref != null) 'climatePref': _climatePref,
        if (_tripDuration != null) 'tripDuration': _tripDuration,
        if (_travelFrequency != null) 'travelFrequency': _travelFrequency,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Travel profile saved!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true); // signal refresh to caller
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addChip(List<String> list, TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isNotEmpty && !list.contains(value)) {
      setState(() => list.add(value));
      controller.clear();
    }
  }

  void _removeChip(List<String> list, String item) =>
      setState(() => list.remove(item));

  @override
  void dispose() {
    _visitedController.dispose();
    _wishlistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: const Text('My Travel Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header hint ──
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(children: [
              Icon(Icons.info_outline, color: Colors.blue.shade400, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Fill in your travel data to get accurate DNA matches with other travelers.',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ]),
          ),

          // ── Places visited ──
          _sectionHeader(
              Icons.where_to_vote, Colors.blue, 'Places You\'ve Visited'),
          _ChipInputField(
            controller: _visitedController,
            hint: 'e.g. Paris, Bali, Tokyo',
            onAdd: () => _addChip(_visitedPlaces, _visitedController),
            chips: _visitedPlaces,
            chipColor: Colors.blue,
            onRemove: (p) => _removeChip(_visitedPlaces, p),
          ),
          const SizedBox(height: 20),

          // ── Wishlist ──
          _sectionHeader(Icons.favorite, Colors.pink, 'Dream Destinations'),
          _ChipInputField(
            controller: _wishlistController,
            hint: 'e.g. Maldives, Iceland, Peru',
            onAdd: () => _addChip(_wishlist, _wishlistController),
            chips: _wishlist,
            chipColor: Colors.pink,
            onRemove: (p) => _removeChip(_wishlist, p),
          ),
          const SizedBox(height: 20),

          // ── Travel style ──
          _sectionHeader(Icons.style, Colors.orange, 'Travel Style'),
          _card(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allStyles.map((style) {
                final selected = _selectedStyles.contains(style);
                return FilterChip(
                  label: Text(style,
                      style: TextStyle(
                          fontSize: 12,
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal)),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) _selectedStyles.add(style);
                    else _selectedStyles.remove(style);
                  }),
                  selectedColor: Colors.orange,
                  backgroundColor: Colors.orange.shade50,
                  checkmarkColor: Colors.white,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // ── Budget ──
          _sectionHeader(Icons.account_balance_wallet, Colors.green, 'Travel Budget'),
          _OptionSelector(
            options: _budgetOptions,
            selected: _budget,
            color: Colors.green,
            onSelect: (v) => setState(() => _budget = v),
          ),
          const SizedBox(height: 20),

          // ── Travel companion ──
          _sectionHeader(Icons.people, Colors.purple, 'Preferred Travel Companion'),
          _OptionSelector(
            options: _companionOptions,
            selected: _companionPref,
            color: Colors.purple,
            onSelect: (v) => setState(() => _companionPref = v),
          ),
          const SizedBox(height: 20),

          // ── Climate ──
          _sectionHeader(Icons.thermostat, Colors.teal, 'Preferred Climate'),
          _OptionSelector(
            options: _climateOptions,
            selected: _climatePref,
            color: Colors.teal,
            onSelect: (v) => setState(() => _climatePref = v),
          ),
          const SizedBox(height: 20),

          // ── Trip duration ──
          _sectionHeader(Icons.calendar_today, Colors.indigo, 'Typical Trip Duration'),
          _OptionSelector(
            options: _durationOptions,
            selected: _tripDuration,
            color: Colors.indigo,
            onSelect: (v) => setState(() => _tripDuration = v),
          ),
          const SizedBox(height: 20),

          // ── Travel frequency ──
          _sectionHeader(Icons.flight_takeoff, Colors.red, 'How Often Do You Travel?'),
          _OptionSelector(
            options: _frequencyOptions,
            selected: _travelFrequency,
            color: Colors.red,
            onSelect: (v) => setState(() => _travelFrequency = v),
          ),
          const SizedBox(height: 32),

          // ── Save button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save Travel Profile',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, Color color, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────
// Chip input widget (text field + chips)
// ─────────────────────────────────────────
class _ChipInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onAdd;
  final List<String> chips;
  final Color chipColor;
  final void Function(String) onRemove;

  const _ChipInputField({
    required this.controller,
    required this.hint,
    required this.onAdd,
    required this.chips,
    required this.chipColor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle:
                      TextStyle(color: Colors.grey[400], fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 14),
                onSubmitted: (_) => onAdd(),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Add',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            )
          ]),
          if (chips.isNotEmpty) ...[
            const Divider(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: chips.map((p) => Chip(
                    label: Text(p,
                        style: const TextStyle(fontSize: 12)),
                    onDeleted: () => onRemove(p),
                    backgroundColor: chipColor.withOpacity(0.1),
                    deleteIconColor: chipColor,
                    side: BorderSide.none,
                  )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Single-select option pill row
// ─────────────────────────────────────────
class _OptionSelector extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final Color color;
  final void Function(String) onSelect;

  const _OptionSelector({
    required this.options,
    required this.selected,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          final isSelected = selected == opt;
          return GestureDetector(
            onTap: () => onSelect(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.07),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}