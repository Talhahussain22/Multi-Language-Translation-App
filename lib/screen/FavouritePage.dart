import 'package:ai_text_to_speech/bloc/on_favourite_clear/on_favourite_delete_bloc.dart';
import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:ai_text_to_speech/screen/components/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';

class Favouritepage extends StatefulWidget {
  const Favouritepage({super.key});

  @override
  State<Favouritepage> createState() => _FavouritepageState();
}

class _FavouritepageState extends State<Favouritepage> {
  List<FavoriteWord>? words;
  List<FavoriteWord>? intitalwords;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Fluttertoast.showToast(
          msg: "Tap Word to see Translation",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.teal,
          textColor: Colors.white,
          fontSize: 16.0);
    });


    super.initState();
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
      body: BlocBuilder<OnFavouriteDeleteBloc,OnFavouriteDeleteState>(
        builder: (context,state) {
          intitalwords = Hive.box<FavoriteWord>('favourites').values.toList();
          words=intitalwords?.reversed.toList();
          return words!.isEmpty?Center(child: Image.asset('assets/data_unavailiable.png'),):SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: words?.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlashCardWidget(frontText: words![index].word, backText:words![index].translation,fromLanguage: words![index].fromLanguage,toLanguage: words![index].toLanguage,),
                );
              },
            ),
          );
        }
      ),
    );
  }
}
