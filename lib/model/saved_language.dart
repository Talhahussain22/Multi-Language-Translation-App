import 'package:hive/hive.dart';

part 'saved_language.g.dart'; // Generated file

@HiveType(typeId: 3)
class SavedLanguage extends HiveObject {
  @HiveField(0)
  Map<String,String>? fromLanguage;

  @HiveField(1)
  Map<String,String>? toLanguage;



  SavedLanguage({
    this.fromLanguage,
    this.toLanguage,
  });
}
