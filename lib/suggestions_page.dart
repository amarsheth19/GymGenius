import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  _SuggestionsPageState createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late final GenerativeModel _model;
  bool _isLoading = false;
  Map<String, dynamic> _muscleRanks = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: 'AIzaSyCdPKjteBtxcge-wxHAzCZKIDEzp1Saeac',
    );
    _loadMuscleRanks();
  }

  Future<void> _loadMuscleRanks() async {
  final user = _auth.currentUser;
  if (user == null) {
    setState(() {
      _messages.add({
        'role': 'error', 
        'text': 'Please login to access muscle data'
      });
    });
    return;
  }

  try {
    final snapshot = await _firestore
        .collection('userRanks')
        .doc(user.uid)
        .collection('muscleGroups')
        .get();

    if (snapshot.docs.isEmpty) {
      setState(() {
        _messages.add({
          'role': 'info',
          'text': 'No muscle data found. Complete your assessment first.'
        });
      });
      return;
    }

    final ranks = <String, dynamic>{};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      ranks[doc.id] = {
        'rank': data['rank'] ?? 'N/A',
        'score': data['score'] ?? 0,
      };
    }

    setState(() {
      _muscleRanks = ranks;
    });
  } catch (e) {
    setState(() {
      _messages.add({
        'role': 'error',
        'text': 'Failed to load muscle data: ${e.toString()}'
      });
    });
  }
}

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': _controller.text,
      });
      _isLoading = true;
    });

    try {
      // Create prompt with muscle data
      final musclePrompt = _muscleRanks.entries.map((e) => 
          "${e.key}: ${e.value['rank']} (${e.value['score']}/100)").join("\n");

      final prompt = """
      User Query: ${_controller.text}
      
      User's Current Muscle Rankings:
      $musclePrompt
      
      As a professional fitness coach, analyze these muscle group rankings and:
      1. Identify 2-3 weakest muscle groups that need focus
      2. Suggest 3 specific exercises for each weak group
      3. Provide form tips for each exercise
      4. Recommend a weekly training split considering these weaknesses
      5. Address any specific concerns from the user query
      
      Format your response with clear headings and bullet points.
      """;

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      setState(() {
        _messages.add({
          'role': 'model',
          'text': response.text ?? "Couldn't generate response",
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'error',
          'text': 'Error: ${e.toString()}',
        });
      });
    } finally {
      _controller.clear();
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personalized Fitness Coach"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMuscleRanks,
            tooltip: 'Refresh muscle data',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_muscleRanks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(),
            )
          else
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _muscleRanks.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Chip(
                      label: Text(
                        '${entry.key}: ${entry.value['rank']}',
                        style: TextStyle(
                          color: entry.value['score'] < 50 
                              ? Colors.red 
                              : Colors.green,
                        ),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'E.g. "How should I improve my weak back?"',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    final isError = message['role'] == 'error';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isError
                ? Colors.red[100]
                : isUser
                    ? Colors.blue[500]
                    : Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${isUser ? 'You' : isError ? 'Error' : 'Coach'}: ${message['text']}',
            style: TextStyle(
              color: isError ? Colors.red[900] : isUser ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}