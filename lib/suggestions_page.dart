import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';  // Correct Dart import

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  _SuggestionsPageState createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  late final GenerativeModel _model;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the Gemini model
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: 'AIzaSyCdPKjteBtxcge-wxHAzCZKIDEzp1Saeac', // Replace with your actual API key
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _messages.add('You: ${_controller.text}');
      _isLoading = true;
    });

    try {
      final response = await _model.generateContent([
        Content.text(
            "As a professional fitness trainer, provide personalized advice about: ${_controller.text}\n"
            "Include specific exercises, form tips, and safety considerations.")
      ]);

      setState(() {
        _messages.add('Trainer: ${response.text ?? "No response"}');
      });
    } catch (e) {
      setState(() {
        _messages.add('Error: ${e.toString()}');
      });
    } finally {
      setState(() {
        _isLoading = false;
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitness Coach"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isUser = _messages[index].startsWith('You');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[400] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        _messages[index],
                        style: TextStyle(
                            color: isUser ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask for workout advice...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
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
}