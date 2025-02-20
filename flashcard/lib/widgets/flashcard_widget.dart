import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart'; // Import the flip_card package

class FlashcardWidget extends StatelessWidget {
  final Map<String, dynamic> card;

  const FlashcardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: const EdgeInsets.all(10),
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL, // Flip horizontally
        front: Container(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              card["english"], // Show the English word on the front
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        back: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blueAccent, // Optional styling for the back
          child: Center(
            child: Text(
              card["mongolian"], // Show the Mongolian translation on the back
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
