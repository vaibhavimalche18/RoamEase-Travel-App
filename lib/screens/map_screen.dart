import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String placeName = "Search Location";

  LatLng currentLocation = LatLng(0, 0); // 🌍 center of world
  //String placeName = "India";
  String temperature = "";

  /// 🌦️ FETCH WEATHER (FREE API)
  Future<void> getWeather(double lat, double lon) async {
    final url =
        "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true";

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    setState(() {
      temperature = "${data['current_weather']['temperature']}°C";
    });
  }

  /// 🔍 SEARCH LOCATION (FREE)
  Future<void> searchPlace(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json";

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    if (data.isNotEmpty) {
      final lat = double.parse(data[0]['lat']);
      final lon = double.parse(data[0]['lon']);

      setState(() {
        currentLocation = LatLng(lat, lon);
        placeName = query;
      });

      getWeather(lat, lon);
    }
  }

  @override
  void initState() {
    super.initState();
    getWeather(currentLocation.latitude, currentLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Map Explorer")),

      body: Column(
        children: [

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onSubmitted: searchPlace,
              decoration: InputDecoration(
                hintText: "Search location...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          /// 📍 INFO CARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              child: ListTile(
                title: Text(placeName),
                subtitle: Text("Temperature: $temperature"),
              ),
            ),
          ),

          /// 🗺️ MAP
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: currentLocation,
                initialZoom: 2,

                onTap: (tapPosition, point) {
                  setState(() {
                    currentLocation = point;
                    placeName = "Selected Location";
                  });

                  getWeather(point.latitude, point.longitude);
                },
              ),

              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.psdl_project',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}