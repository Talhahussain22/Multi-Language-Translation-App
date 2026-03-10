import 'package:ai_text_to_speech/bloc/favouritequizBloc/favourite_quiz_bloc.dart';
import 'package:ai_text_to_speech/bloc/generalquizBloc/generalquiz_bloc.dart';
import 'package:ai_text_to_speech/bloc/grammarTestBloc/grammar_test_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_favourite/on_favourite_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_favourite_clear/on_favourite_delete_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_history_delete/on_history_delete_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_translate/on_translate_bloc.dart';
import 'package:ai_text_to_speech/bloc/daily_word/daily_word_bloc.dart';
import 'package:ai_text_to_speech/model/history_model.dart';
import 'package:ai_text_to_speech/model/saved_language.dart';
import 'package:ai_text_to_speech/model/daily_word_model.dart';
import 'package:ai_text_to_speech/services/ad_manager.dart';
import 'package:ai_text_to_speech/services/app_config.dart';
import 'package:ai_text_to_speech/services/network_services.dart';
import 'package:ai_text_to_speech/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'model/hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();

  Hive.registerAdapter(FavoriteWordAdapter());
  Hive.registerAdapter(HistoryModelAdapter());
  Hive.registerAdapter(SavedLanguageAdapter());
  Hive.registerAdapter(DailyWordModelAdapter());
  Hive.registerAdapter(DailyWordStreakAdapter());

  await Hive.openBox<FavoriteWord>('favourites');
  await Hive.openBox<HistoryModel>('History');
  await Hive.openBox<SavedLanguage>('saved_lang');
  await Hive.openBox<DailyWordModel>('daily_words');
  await Hive.openBox<DailyWordStreak>('daily_word_streak');

  // Validate API key is present at startup
  AppConfig.validate();

  // Initialize AdMob SDK once at startup — before runApp so ads are warm early.
  try {
    await AdManager().initialize();
  } catch (_) {
    // Ad init failure is non-fatal; app continues without ads.
  }

  runApp(const MyApp());
}

// Single shared NetworkServices instance — never recreated.
final _networkServices = NetworkServices();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF003366));
    final theme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      dividerTheme: const DividerThemeData(thickness: 0.8),
    );

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => OnTranslateBloc(_networkServices)),
            BlocProvider(create: (_) => OnFavouriteBloc()),
            BlocProvider(create: (_) => DailyWordBloc()),
            BlocProvider(create: (_) => OnHistoryDeleteBloc()),
            BlocProvider(create: (_) => OnFavouriteDeleteBloc()),
            BlocProvider(create: (_) => GeneralquizBloc()),
            BlocProvider(create: (_) => FavouriteQuizBloc()),
            BlocProvider(create: (_) => GrammarTestBloc()),
          ],
          child: MaterialApp(
            theme: theme,
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
