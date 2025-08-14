import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mini_language_cards/data/word_list.dart';
import 'word_state.dart';

class WordCubit extends Cubit<WordState> {
  WordCubit() : super(const WordState());

  final box = Hive.box('wordsBox');

  void loadDailyWords() {
  final today = DateTime.now().toString().substring(0, 10);
  final savedDate = box.get('date');
  final savedWords = box.get('words');

  if (savedDate == today && savedWords is List) {
    // dynamic -> Map<String, String> dönüşümü
    final typedWords = savedWords
        .whereType<Map>() // Sadece map olanları al
        .map((e) => e.map((key, value) => MapEntry(key.toString(), value.toString())))
        .toList();

    emit(state.copyWith(dailyWords: typedWords));
  } else {
    getDailyWords();
  }
}


  void getDailyWords() {
    final shuffled = List<Map<String, String>>.from(wordList)..shuffle(Random());
    final selectedWords = shuffled.take(5).toList();

    final today = DateTime.now().toString().substring(0, 10);
    box.put('date', today);
    box.put('words', selectedWords);

    emit(state.copyWith(dailyWords: selectedWords));
  }
}
