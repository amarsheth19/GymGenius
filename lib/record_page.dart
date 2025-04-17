import 'package:flutter/material.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Page')),
      body: Center(
        child: Container(
          width: 800,
          height: 400,
          color: Colors.blue[200], // Just a solid color
          child: const Center(
            child: Text('Record Page', style: TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }
}
<<<<<<< Updated upstream
=======



>>>>>>> Stashed changes
