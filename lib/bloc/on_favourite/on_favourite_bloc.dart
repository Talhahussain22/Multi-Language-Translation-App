import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:meta/meta.dart';

part 'on_favourite_event.dart';
part 'on_favourite_state.dart';

class OnFavouriteBloc extends Bloc<OnFavouriteEvent, OnFavouriteState> {
  
  OnFavouriteBloc() : super(OnFavouriteInitial()) {
    on<OnFavouriteButtonClicked>((event, emit) async{
      final favBox=Hive.box<FavoriteWord>('favourites');
      final keyAvailiable = favBox.keys.firstWhere(
            (key) {
          final item = favBox.get(key);
          return item?.word.toUpperCase() == event.favoriteWord.word.toUpperCase() && item?.translation.toUpperCase()==event.favoriteWord.translation.toUpperCase();
        },
        orElse: ()=>null
      );

      if(keyAvailiable==null)
        {
          favBox.add(FavoriteWord(word: event.favoriteWord.word, translation:event.favoriteWord.translation, fromLanguage: event.favoriteWord.fromLanguage, toLanguage: event.favoriteWord.toLanguage));
          emit(OnFavouriteSuccess(isFavourited: true));
        }
      else
        {
          await favBox.delete(keyAvailiable);
          emit(OnFavouriteSuccess(isFavourited: false));
        }
    });
  }
}
