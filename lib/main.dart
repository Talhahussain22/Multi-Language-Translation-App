import 'package:ai_text_to_speech/bloc/favouritequizBloc/favourite_quiz_bloc.dart';
import 'package:ai_text_to_speech/bloc/generalquizBloc/generalquiz_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_favourite/on_favourite_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_favourite_clear/on_favourite_delete_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_history_delete/on_history_delete_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_translate/on_translate_bloc.dart';
import 'package:ai_text_to_speech/bloc/summary_fetch/summary_fetch_bloc.dart';
import 'package:ai_text_to_speech/model/history_model.dart';
import 'package:ai_text_to_speech/model/saved_language.dart';
import 'package:ai_text_to_speech/services/ad_manager.dart';
import 'package:ai_text_to_speech/services/network_services.dart';
import 'package:ai_text_to_speech/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'model/hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();


  Hive.registerAdapter(FavoriteWordAdapter()); // Register your adapter
  Hive.registerAdapter(HistoryModelAdapter());
  Hive.registerAdapter(SavedLanguageAdapter());
  await Hive.openBox<FavoriteWord>('favourites');
  await Hive.openBox<HistoryModel>('History');
  await Hive.openBox<SavedLanguage>('saved_lang');

  await dotenv.load(fileName: '.env');

  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NetworkServices networkServices = NetworkServices();
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF003366));
    final theme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: Brightness.light, // Light mode only
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

    // Initialize AdManager and preload ads after first frame to ensure plugins are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await AdManager().initialize();
      } catch (e) {
          // Handle ad initialization errors gracefully, e.g., log to console or show a non-intrusive message.
        debugPrint("Ad init failed: ${e.toString()}");
      }
    });

    return ScreenUtilInit(
      designSize: const Size(390, 844), // Base size (Pixel 6-ish). Adjust as needed.
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => OnTranslateBloc(networkServices)),
            BlocProvider(create: (_) => OnFavouriteBloc()),
            BlocProvider(create: (_) => OnHistoryDeleteBloc()),
            BlocProvider(create: (_) => OnFavouriteDeleteBloc()),
            BlocProvider(create: (_) => SummaryFetchBloc()),
            BlocProvider(create: (_) => GeneralquizBloc()),
            BlocProvider(create: (_) => FavouriteQuizBloc()),
          ],
          child: MaterialApp(
            // Note: Add your AdMob App ID in AndroidManifest.xml under <application>:
            // <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-3940256099942544~3347511713" />
            // Use test IDs above in debug; replace with real IDs for release.
            theme: theme,
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          ),
        );
      },
    );
  }
}
