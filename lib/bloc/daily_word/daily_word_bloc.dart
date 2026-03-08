import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import '../../model/daily_word_model.dart';
import '../../model/hive_model.dart';
import '../../services/daily_word_service.dart';

part 'daily_word_event.dart';
part 'daily_word_state.dart';

class DailyWordBloc extends Bloc<DailyWordEvent, DailyWordState> {
  final DailyWordService _dailyWordService = DailyWordService();

  DailyWordBloc() : super(DailyWordInitial()) {
    on<LoadDailyWord>(_onLoadDailyWord);
    on<RefreshDailyWord>(_onRefreshDailyWord);
    on<SaveDailyWordToFavorites>(_onSaveDailyWordToFavorites);
  }

  Future<void> _onLoadDailyWord(
    LoadDailyWord event,
    Emitter<DailyWordState> emit,
  ) async {
    emit(DailyWordLoading());

    try {
      final wordsBox = await Hive.openBox<DailyWordModel>('daily_words');
      final streakBox = await Hive.openBox<DailyWordStreak>('daily_word_streak');

      // Get or create streak data
      DailyWordStreak streak = streakBox.get('streak') ??
          DailyWordStreak(
            currentStreak: 0,
            lastViewDate: DateTime.now(),
            longestStreak: 0,
            learningLanguage: event.learningLanguage,
            nativeLanguage: event.nativeLanguage,
          );

      // Update streak logic
      final now = DateTime.now();
      final lastDate = DateTime(
        streak.lastViewDate.year,
        streak.lastViewDate.month,
        streak.lastViewDate.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      final difference = today.difference(lastDate).inDays;

      if (streak.currentStreak == 0) {
        // Brand-new streak – first ever visit
        streak.currentStreak = 1;
        streak.longestStreak = 1;
      } else if (difference == 1) {
        // Visited yesterday – increase streak
        streak.currentStreak++;
        if (streak.currentStreak > streak.longestStreak) {
          streak.longestStreak = streak.currentStreak;
        }
      } else if (difference > 1) {
        // Missed days – reset streak
        streak.currentStreak = 1;
      }
      // If difference == 0, same day – do nothing (streak already >= 1)

      streak.lastViewDate = now;
      streak.learningLanguage = event.learningLanguage;
      streak.nativeLanguage = event.nativeLanguage;
      await streakBox.put('streak', streak);

      // Get all previous words for this language pair
      final allWords = wordsBox.values
          .where((w) => w.language == event.learningLanguage)
          .toList()
        ..sort((a, b) => b.dateShown.compareTo(a.dateShown));

      // Check if we already have a word for today
      final todayWord = allWords.firstWhere(
        (w) {
          final wordDate = DateTime(w.dateShown.year, w.dateShown.month, w.dateShown.day);
          return wordDate.isAtSameMomentAs(today);
        },
        orElse: () => DailyWordModel(
          wordId: '',
          word: '',
          language: '',
          translation: '',
          pronunciation: null,
          exampleSentenceEnglish: '',
          exampleSentenceLearning: '',
          synonyms: const [],
          antonyms: const [],
          dateShown: DateTime.now(),
          englishMeaning: '',
          nativeLanguage: event.nativeLanguage,
        ),
      );

      DailyWordModel currentWord;

      if (todayWord.wordId.isEmpty) {
        // Fetch new word
        final previousWordIds = allWords.map((w) => w.wordId).toList();
        currentWord = await _dailyWordService.fetchDailyWord(
          nativeLanguage: event.nativeLanguage,
          learningLanguage: event.learningLanguage,
          previousWordIds: previousWordIds,
        );
        await wordsBox.add(currentWord);
      } else {
        currentWord = todayWord;
      }

      // Check if word is in favorites
      final favBox = Hive.box<FavoriteWord>('favourites');
      final isSaved = favBox.values.any((fav) =>
          fav.word.toLowerCase() == currentWord.word.toLowerCase() &&
          fav.fromLanguage == currentWord.language);

      emit(DailyWordLoaded(
        currentWord: currentWord,
        previousWords: allWords.where((w) => w.wordId != currentWord.wordId).toList(),
        currentStreak: streak.currentStreak,
        longestStreak: streak.longestStreak,
        isSaved: isSaved,
      ));
    } catch (e) {
      emit(DailyWordError(e.toString()));
    }
  }

  Future<void> _onRefreshDailyWord(
    RefreshDailyWord event,
    Emitter<DailyWordState> emit,
  ) async {
    if (state is DailyWordLoaded) {
      final currentState = state as DailyWordLoaded;
      emit(DailyWordLoading());

      try {
        final wordsBox = await Hive.openBox<DailyWordModel>('daily_words');
        final allWords = wordsBox.values
            .where((w) => w.language == event.learningLanguage)
            .toList();
        final previousWordIds = allWords.map((w) => w.wordId).toList();

        final newWord = await _dailyWordService.fetchDailyWord(
          nativeLanguage: event.nativeLanguage,
          learningLanguage: event.learningLanguage,
          previousWordIds: previousWordIds,
        );
        await wordsBox.add(newWord);

        // Check if word is in favorites
        final favBox = Hive.box<FavoriteWord>('favourites');
        final isSaved = favBox.values.any((fav) =>
            fav.word.toLowerCase() == newWord.word.toLowerCase() &&
            fav.fromLanguage == newWord.language);

        emit(DailyWordLoaded(
          currentWord: newWord,
          previousWords: [...currentState.previousWords, currentState.currentWord],
          currentStreak: currentState.currentStreak,
          longestStreak: currentState.longestStreak,
          isSaved: isSaved,
        ));
      } catch (e) {
        emit(DailyWordError(e.toString()));
      }
    }
  }

  Future<void> _onSaveDailyWordToFavorites(
    SaveDailyWordToFavorites event,
    Emitter<DailyWordState> emit,
  ) async {
    try {
      final box = Hive.box<FavoriteWord>('favourites');

      // Check if already exists
      final exists = box.values.any((fav) =>
          fav.word.toLowerCase() == event.word.toLowerCase() &&
          fav.fromLanguage == event.fromLanguage);

      if (!exists) {
        final favorite = FavoriteWord(
          word: event.word,
          translation: event.translation,
          fromLanguage: event.fromLanguage,
          toLanguage: 'English',
        );
        await box.add(favorite);
      }

      if (state is DailyWordLoaded) {
        final currentState = state as DailyWordLoaded;
        emit(currentState.copyWith(isSaved: true));
      }
    } catch (e) {
      emit(DailyWordError('Failed to save: $e'));
    }
  }
}
