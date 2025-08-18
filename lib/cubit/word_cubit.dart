import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_language_cards/data/word_list.dart';
import 'word_state.dart';

class WordCubit extends Cubit<WordState> {
  WordCubit() : super(const WordState());
  List<Map<String, String>> _lastWords = const [];

  void getRandomWords() {
    final random = Random();
    List<Map<String, String>> pick() {
      final shuffled = List<Map<String, String>>.from(wordList)
        ..shuffle(random);
      return shuffled.take(5).toList();
    }

    const int maxAttempts = 10;
    List<Map<String, String>> next = pick();
    int attempts = 1;
    if (_lastWords.isNotEmpty && wordList.length >= 10) {
      bool overlaps(List<Map<String, String>> a, List<Map<String, String>> b) {
        final Set<String> aw = a.map((e) => e['word'] ?? '').toSet();
        final Set<String> bw = b.map((e) => e['word'] ?? '').toSet();
        return aw.intersection(bw).isNotEmpty;
      }

      while (overlaps(next, _lastWords) && attempts < maxAttempts) {
        next = pick();
        attempts++;
      }
    }

    _lastWords = next;
    emit(state.copyWith(dailyWords: next));
  }
}
