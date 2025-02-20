// main.dart
import 'package:english_mongolian_words/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Vocabulary Generator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _topicController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String apiKey = 'YOUR_GEMINI_AI_API_KEY'; // Add your Gemini AI API Key here

Future<void> generateWords(String topic) async {
  final model = GenerativeModel(apiKey: apiKey, model: 'gemini-pro');
  
  final response = await model.generateContent([
    Content.text('Generate 5 English-Mongolian words for topic: $topic')
  ]);

  if (response.text != null) {
    List<String> words = response.text!.split('\n');
    _firestore.collection('topics').add({
      'topic': topic,
      'words': words,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Vocabulary Generator')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(labelText: 'Enter Topic'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => generateWords(_topicController.text),
              child: Text('Generate Words'),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _firestore.collection('topics').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text(data['topic']),
                          subtitle: Text(data['words'].join(', ')),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
