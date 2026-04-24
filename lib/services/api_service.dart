import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String pexelsKey = "hMpwDYkBE0BBYPxG2rX8jOL99SV328r1tSKGJRRcTTyNhMQ0dmwxPsep";

  /// 🔍 MAIN SEARCH (Wikipedia-first)
  static Future<List> searchPlaces(String query) async {
    List<String> searchList = [
      query,
      "$query tourism",
      "$query famous places",
      "$query attractions",
      "$query city",
    ];

    List results = [];

    for (String item in searchList) {
      final wikiData = await fetchWikiData(item);

      String image = wikiData['image'] ??
          await fetchPexelsImage(item);

      results.add({
        "name": item.replaceAll(query, "").trim().isEmpty
            ? query
            : item,
        "image": image,
        "description":
        wikiData['description'] ?? "No description",
        "rating": 4.5,
      });
    }

    return results;
  }

  /// 📖 WIKIPEDIA SEARCH + SUMMARY
  static Future<Map> fetchWikiData(String query) async {
    try {
      final searchUrl =
          "https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=$query&format=json";

      final searchRes = await http.get(Uri.parse(searchUrl));
      final searchData = jsonDecode(searchRes.body);

      if (searchData['query']['search'].isEmpty) {
        return {"description": null, "image": null};
      }

      final title = searchData['query']['search'][0]['title'];

      final summaryUrl =
          "https://en.wikipedia.org/api/rest_v1/page/summary/$title";

      final summaryRes = await http.get(Uri.parse(summaryUrl));
      final data = jsonDecode(summaryRes.body);

      return {
        "description": data['extract'],
        "image": data['thumbnail'] != null
            ? data['thumbnail']['source']
            : null,
      };
    } catch (e) {
      return {"description": null, "image": null};
    }
  }

  /// 🖼️ PEXELS FALLBACK
  static Future<String> fetchPexelsImage(String query) async {
    final url =
        "https://api.pexels.com/v1/search?query=$query&per_page=1";

    final res = await http.get(
      Uri.parse(url),
      headers: {"Authorization": pexelsKey},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data['photos'].isNotEmpty) {
        return data['photos'][0]['src']['medium'];
      }
    }

    return "https://via.placeholder.com/300";
  }

  static Future<List> fetchCategoryPlaces(String category) async {
    final url =
        "https://api.pexels.com/v1/search?query=$category tourism&per_page=10";

    final res = await http.get(
      Uri.parse(url),
      headers: {"Authorization": pexelsKey},
    );

    final data = jsonDecode(res.body);

    List results = [];

    for (var photo in data['photos']) {
      final title = photo['alt'] ?? category;

      results.add({
        "name": title, // ✅ real name
        "image": photo['src']['medium'],
        "description": "Popular $category destination",
        "rating": 4.5,
      });
    }

    return results;
  }
}