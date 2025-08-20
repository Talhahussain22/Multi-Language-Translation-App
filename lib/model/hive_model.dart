import 'package:hive_flutter/adapters.dart';
part 'hive_model.g.dart';
@HiveType(typeId: 0)
class FavoriteWord extends HiveObject {
  @HiveField(0)
  final String word;

  @HiveField(1)
  final String translation;

  @HiveField(2)
  final String fromLanguage;

  @HiveField(3)
  final String toLanguage;

  FavoriteWord({
    required this.word,
    required this.translation,
    required this.fromLanguage,
    required this.toLanguage,
  });
}
