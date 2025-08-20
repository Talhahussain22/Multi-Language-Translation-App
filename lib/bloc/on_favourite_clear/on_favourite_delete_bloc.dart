import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'on_favourite_delete_event.dart';
part 'on_favourite_delete_state.dart';

class OnFavouriteDeleteBloc extends Bloc<OnFavouriteDeleteEvent, OnFavouriteDeleteState> {
  OnFavouriteDeleteBloc() : super(OnFavouriteDeleteInitial()) {
    on<OnFavouriteClearButtonPressed>((event, emit) async{
      final hivebox=Hive.box<FavoriteWord>('favourites');
      await hivebox.clear();
      emit(OnFavouriteDeleteLoadedState());

    });
  }
}
