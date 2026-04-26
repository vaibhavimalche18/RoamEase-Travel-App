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
import 'quest_screen.dart';
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

  /// 🔍 SEARCH
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

  /// 👤 GET USER NAME
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
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [


            /// 🏠 HOME
            IconButton(
              icon: const Icon(Icons.home, color: Colors.blue),
              onPressed: () {}, // already here, do nothing
            ),

            /// 🗺️ MAP (🔥 THIS IS WHAT YOU WERE MISSING)
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MapScreen(),
                  ),
                );
              },
            ),

            /// ❤️ FAVORITES
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FavoriteScreen(),
                  ),
                );
              },
            ),

            /// ⚙️ SETTINGS
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
      body: SafeArea(
        ///child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔝 HEADER
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, ${userName.isEmpty ? "User" : userName} 👋",
                          style:  TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                         SizedBox(height: 5),
                         Text(
                          "Find your favorite place",
                          style: TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?img=3"),
                    ),
                  )
                  ],
                ),

                 SizedBox(height: 20),

                /// 🔍 SEARCH
                TextField(
                  onChanged: searchPlaces,
                  decoration: InputDecoration(
                    hintText: "Search destination...",
                    prefixIcon:  Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                 SizedBox(height: 15),

                /// 🧭 CATEGORY
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CategoryChip(title: "All", isSelected: true),
                      CategoryChip(
                        title: "Mountains",
                        onTap: () async {
                          final results =
                          await ApiService.fetchCategoryPlaces("mountains");

                          setState(() => places = results);
                        },
                      ),
                      CategoryChip(
                        title: "Beaches",
                        onTap: () async {
                          final results =
                          await ApiService.fetchCategoryPlaces("beaches");

                          setState(() => places = results);
                        },
                      ),
                      CategoryChip(
                        title: "Desert",
                        onTap: () async {
                          final results =
                          await ApiService.fetchCategoryPlaces("desert");

                          setState(() => places = results);
                        },
                      ),
                      CategoryChip(
                        title: "National Parks",
                        onTap: () async {
                          final results =
                          await ApiService.fetchCategoryPlaces("national parks");

                          setState(() => places = results);
                        },
                      ),
                    ],
                  ),
                ),

                 SizedBox(height: 20),

                 Text(
                  "Explore destinations",
                  style: TextStyle(fontSize: 16),
                ),

                 SizedBox(height: 10),

                /// ⏳ LOADING
                if (isLoading)
                   Center(child: CircularProgressIndicator()),

                /// 📦 RESULTS
                if (!isLoading)
                  Expanded(
                    child: ListView.builder(
                      itemCount: places.isEmpty
                          ? defaultPlaces.length
                          : places.length,
                      itemBuilder: (context, index) {
                        final place = places.isEmpty
                            ? defaultPlaces[index]
                            : places[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailScreen(place: place),
                              ),
                            );
                          },
                          child: Padding(
                            padding:  EdgeInsets.only(bottom: 15),
                            child: PlaceCard(place: place),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ///),
      ),
    );
  }
}