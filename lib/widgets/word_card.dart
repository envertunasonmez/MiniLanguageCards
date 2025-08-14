import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {
  final String word;
  final String meaning;

  const WordCard({
    super.key,
    required this.word,
    required this.meaning,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Text(
          word,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(meaning),
      ),
    );
  }
}
