import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map place;

  const DetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          Image.network(place['image'], height: 300, fit: BoxFit.cover),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(place['name'],
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange),
                    Text(place['rating'].toString()),
                  ],
                ),

                const SizedBox(height: 15),

                Text(
                  "${place['name']} is a beautiful destination known for its scenic landscapes, vibrant culture, and unforgettable travel experiences.",
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Start Trip"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}