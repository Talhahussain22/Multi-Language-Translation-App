import 'package:hive/hive.dart';
part 'history_model.g.dart';
@HiveType(typeId: 2)
class HistoryModel extends HiveObject {
  @HiveField(0)
  final String word;

  @HiveField(1)
  final String translation;

  @HiveField(2)
  final String fromLanguage;

  @HiveField(3)
  final String toLanguage;

  HistoryModel({
    required this.word,
    required this.translation,
    required this.fromLanguage,
    required this.toLanguage,
  });
}