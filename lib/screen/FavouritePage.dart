import 'package:ai_text_to_speech/bloc/on_favourite_clear/on_favourite_delete_bloc.dart';
import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:ai_text_to_speech/screen/components/flip_card.dart';
import 'package:ai_text_to_speech/Utils/app_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class Favouritepage extends StatefulWidget {
  const Favouritepage({super.key});

  @override
  State<Favouritepage> createState() => _FavouritepageState();
}

class _FavouritepageState extends State<Favouritepage> {
  List<FavoriteWord> _words = [];

  void _reloadWords() {
    final box = Hive.box<FavoriteWord>('favourites');
    setState(() {
      _words = box.values.toList().reversed.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _reloadWords();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppDialogs.showSnack(
          context,
          message: 'Tap a word to see its translation',
          background: Colors.teal,
          duration: const Duration(seconds: 2),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        title: Text(
          'Favourite',
          style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            color: Colors.black,
            elevation: 7, // Shadow depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
              // Border
            ),

            constraints: BoxConstraints(maxHeight: 50),


            onSelected: (value) {
              if(value=='clear')
              {

                  context.read<OnFavouriteDeleteBloc>().add(OnFavouriteClearButtonPressed());

              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'clear',
                textStyle: TextStyle(color: Colors.red),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history,color: Colors.red,),
                      SizedBox(width: 5),
                      Text('Clear Favourite',style: TextStyle(color: Colors.red),),
                    ],
                  ),
                ),

              ),

            ],
            icon: Icon(Icons.more_vert,color: Colors.white,),
            // or use Icons.menu
          ),
        ],
      ),
      body: BlocBuilder<OnFavouriteDeleteBloc, OnFavouriteDeleteState>(
        builder: (context, state) {
          // Always read from Hive box (in-memory, O(1)) so deletions are reflected
          if (state is OnFavouriteDeleteLoadedState) {
            final box = Hive.box<FavoriteWord>('favourites');
            _words = box.values.toList().reversed.toList();
          }
          if (_words.isEmpty) {
            return Center(
              child: Image.asset(
                'assets/data_unavailiable.png',
                cacheWidth: 400,
              ),
            );
          }
          return ListView.builder(
            itemCount: _words.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final w = _words[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlashCardWidget(
                  frontText: w.word,
                  backText: w.translation,
                  fromLanguage: w.fromLanguage,
                  toLanguage: w.toLanguage,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
