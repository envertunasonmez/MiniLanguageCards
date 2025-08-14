import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/word_cubit.dart';
import '../cubit/word_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bugünün 5 Kelimesi")),
      body: BlocBuilder<WordCubit, WordState>(
        builder: (context, state) {
          if (state.dailyWords.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: state.dailyWords.length,
            itemBuilder: (context, index) {
              final word = state.dailyWords[index];
              return ListTile(
                title: Text(word["word"]!),
                subtitle: Text(word["meaning"]!),
              );
            },
          );
        },
      ),
    );
  }
}
