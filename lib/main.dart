import 'package:ai_text_to_speech/bloc/favouritequizBloc/favourite_quiz_bloc.dart';
import 'package:ai_text_to_speech/bloc/generalquizBloc/generalquiz_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_favourite/on_favourite_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_favourite_clear/on_favourite_delete_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_history_delete/on_history_delete_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_translate/on_translate_bloc.dart';
import 'package:ai_text_to_speech/bloc/summary_fetch/summary_fetch_bloc.dart';
import 'package:ai_text_to_speech/model/history_model.dart';
import 'package:ai_text_to_speech/model/saved_language.dart';
import 'package:ai_text_to_speech/screen/Dashboard.dart';
import 'package:ai_text_to_speech/screen/FavouritePage.dart';
import 'package:ai_text_to_speech/screen/HistoryPage.dart';
import 'package:ai_text_to_speech/services/network_services.dart';
import 'package:ai_text_to_speech/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';


import 'model/hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OnTranslateBloc(networkServices)),
        BlocProvider(create: (_) => OnFavouriteBloc()),
        BlocProvider(create: (_)=>OnHistoryDeleteBloc()),
        BlocProvider(create: (_)=>OnFavouriteDeleteBloc()),
        BlocProvider(create: (_)=>SummaryFetchBloc()),
        BlocProvider(create: (_)=>GeneralquizBloc()),
        BlocProvider(create: (_)=>FavouriteQuizBloc())
      ],
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue,scaffoldBackgroundColor: Colors.white),
        debugShowCheckedModeBanner: false,

        home: SplashScreen(),
      ),
    );
  }
}
