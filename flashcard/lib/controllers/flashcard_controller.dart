import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FlashcardController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxList<Map<String, dynamic>> flashcards = <Map<String, dynamic>>[].obs;
  RxList<String> topics = <String>[].obs;
  RxList<Map<String, dynamic>> words = <Map<String, dynamic>>[].obs;
  RxString selectedTopic = "".obs;

  @override
  void onInit() {
    fetchTopics();
    super.onInit();
  }

  /// Fetch all topics from Firestore
  Future<void> fetchTopics() async {
    try {
      QuerySnapshot query = await firestore.collection('flashcards').get();
      topics.assignAll(query.docs.map((doc) => doc.id).toList());
    } catch (e) {
      print("🔥 Error fetching topics: $e");
    }
  }

  /// Fetch flashcards (words) under a selected topic
  Future<void> fetchFlashcards(String topic) async {
    selectedTopic.value = topic;
    try {
      QuerySnapshot query = await firestore.collection('flashcards').doc(topic).collection('words').get();
      flashcards.assignAll(query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
    } catch (e) {
      print("🔥 Error fetching flashcards: $e");
    }
  }

  /// Add a flashcard (word pair) to Firestore under a specific topic
  Future<void> addFlashcard(String topic, String english, String mongolian) async {
    try {
      await firestore.collection('flashcards').doc(topic).collection('words').add({
        "english": english,
        "mongolian": mongolian,
        "memorized": false // Default: Not memorized
      });
      fetchFlashcards(topic); // Refresh words
    } catch (e) {
      print("🔥 Error adding flashcard: $e");
    }
  }

  /// Generate English-Mongolian word pairs using Gemini AI
  Future<void> generateFlashcards(String topic) async {
    const String apiKey = "YOUR_GEMINI_AI_API_KEY"; // Replace with a valid key
    const String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey";

    String prompt = "Generate 10 English words related to '$topic' with their Mongolian translations. Format: word - translation.";

    var requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data.containsKey("candidates")) {
          var content = data["candidates"][0]["content"]["parts"][0]["text"];

          if (content is String) {
            // Remove any unwanted numbering prefix (e.g., "1.", "2.", "3.") by splitting the string
            List<String> flashcardsList = content
                .split("\n")
                .where((line) => line.contains(" - ")) // Ensure the line contains " - " to be considered a valid flashcard
                .map((line) {
                  // Remove leading numbers or counters, if present
                  var cleanedLine = line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
                  return cleanedLine;
                })
                .toList();

            for (var line in flashcardsList) {
              var parts = line.split(" - ");
              if (parts.length > 1) {
                await addFlashcard(topic, parts[0].trim(), parts[1].trim());
              }
            }
          } else {
            print("🔥 Error: Unexpected response format.");
          }
        }
      } else {
        print("🔥 API Error: ${response.body}");
      }
    } catch (e) {
      print("🔥 Error fetching Gemini API: $e");
    }
  }
}
