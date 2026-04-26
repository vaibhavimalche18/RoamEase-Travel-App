import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/card_project.dart';
import '../widgets/category_chip.dart';
import 'detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class ExploreScreen extends StatefulWidget {
  ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List places = [];
  bool isLoading = false;
  String userName = "";

  void searchPlaces(String query) async {
    if (query.length < 3) return;
    setState(() => isLoading = true);
    try {
      final results = await ApiService.searchPlaces(query);
      setState(() {
        places = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  final defaultPlaces = [
    {
      "name": "Altea",
      "image": "https://images.unsplash.com/photo-1501785888041-af3ef285b470",
      "rating": 4.7
    },
    {
      "name": "Paris, France",
      "image": "https://images.unsplash.com/photo-1502602898657-3e91760cbb34",
      "rating": 4.7
    },
    {
      "name": "Maldives",
      "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
      "rating": 4.9
    },
  ];

  Future<void> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          userName = doc['name'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 🔽 BOTTOM NAV
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.blue),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoriteScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
      ),

      /// 🔼 BODY
      /// KEY FIX: SafeArea > Column (not Padding > Column)
      /// Expanded only works inside Row/Column/Flex, so the Column
      /// must be the direct child of SafeArea with unbounded height.
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// All non-scrollable content goes in a Padding block
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔝 HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, ${userName.isEmpty ? "User" : userName} 👋",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Find your favorite place",
                            style: TextStyle(fontSize: 22),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()),
                        ),
                        child: CircleAvatar(
                            backgroundColor: Colors.grey.shade300),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔍 SEARCH
                  TextField(
                    onChanged: searchPlaces,
                    decoration: InputDecoration(
                      hintText: "Search destination...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// 🧭 CATEGORY CHIPS
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CategoryChip(title: "All", isSelected: true),
                        CategoryChip(
                          title: "Mountains",
                          onTap: () async {
                            final results = await ApiService
                                .fetchCategoryPlaces("mountains");
                            setState(() => places = results);
                          },
                        ),
                        CategoryChip(
                          title: "Beaches",
                          onTap: () async {
                            final results = await ApiService
                                .fetchCategoryPlaces("beaches");
                            setState(() => places = results);
                          },
                        ),
                        CategoryChip(
                          title: "Desert",
                          onTap: () async {
                            final results = await ApiService
                                .fetchCategoryPlaces("desert");
                            setState(() => places = results);
                          },
                        ),
                        CategoryChip(
                          title: "National Parks",
                          onTap: () async {
                            final results = await ApiService
                                .fetchCategoryPlaces("national parks");
                            setState(() => places = results);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Explore destinations",
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            /// ⏳ LOADING — outside the inner Padding so it doesn't break Expanded
            if (isLoading)
              const Center(child: CircularProgressIndicator()),

            /// 📦 RESULTS — Expanded here is valid because parent is the outer Column
            if (!isLoading)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    itemCount: places.isEmpty
                        ? defaultPlaces.length
                        : places.length,
                    itemBuilder: (context, index) {
                      final place = places.isEmpty
                          ? defaultPlaces[index]
                          : places[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DetailScreen(place: place)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: PlaceCard(place: place),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}