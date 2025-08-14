import 'package:equatable/equatable.dart';

class WordState extends Equatable {
  final List<Map<String, String>> dailyWords;

  const WordState({this.dailyWords = const []});

  WordState copyWith({List<Map<String, String>>? dailyWords}) {
    return WordState(dailyWords: dailyWords ?? this.dailyWords);
  }

  @override
  List<Object?> get props => [dailyWords];
}
