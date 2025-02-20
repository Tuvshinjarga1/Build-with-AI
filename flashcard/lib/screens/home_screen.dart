import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/flashcard_controller.dart';
import '../widgets/flashcard_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FlashcardController controller = Get.put(FlashcardController());

    return Scaffold(
      appBar: AppBar(title: const Text("AI Flashcards")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController topicController = TextEditingController();
          Get.defaultDialog(
            title: "Enter a topic",
            content: Column(
              children: [
                TextField(
                  controller: topicController,
                  decoration: const InputDecoration(
                    hintText: "Enter topic name",
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (topicController.text.trim().isNotEmpty) {
                      controller.generateFlashcards(topicController.text.trim());
                      Get.back();
                    }
                  },
                  child: const Text("Generate"),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.auto_awesome),
      ),
      body: Obx(() {
        if (controller.flashcards.isEmpty) {
          return const Center(child: Text("No flashcards available. Add a topic!"));
        }
        return ListView.builder(
          itemCount: controller.flashcards.length,
          itemBuilder: (context, index) {
            return FlashcardWidget(card: controller.flashcards[index]);
          },
        );
      }),
    );
  }
}
