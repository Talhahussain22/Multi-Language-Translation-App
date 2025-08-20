import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:ai_text_to_speech/screen/FavouriteWordsQuizScreen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';

class FavouriteWordTestScreen extends StatefulWidget {
  const FavouriteWordTestScreen({super.key});

  @override
  State<FavouriteWordTestScreen> createState() => _FavouriteWordTestScreenState();
}

class _FavouriteWordTestScreenState extends State<FavouriteWordTestScreen> {
  late TextEditingController controller=TextEditingController();
  late List<FavoriteWord> favouritewords;
  late int hinttextval;
  List<FavoriteWord>? finalselectedwords;

  @override
  void initState() {
    controller=TextEditingController();
    final hivebox=Hive.box<FavoriteWord>('favourites');
    favouritewords=hivebox.values.toList();
    hinttextval=favouritewords.length??0;

    if(hinttextval==0)
      {
        WidgetsBinding.instance.addPostFrameCallback((_){
          Fluttertoast.showToast(
              msg: "Please Favourite some words before starting Quiz",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor:Colors.teal,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      }
    super.initState();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        title: Text(
          'Favourite Word Test',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Number of Quiz',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
            TextField(
            controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter Number of Quiz',
                hintStyle: TextStyle(color: Colors.black12,fontSize: 14,letterSpacing: 0,wordSpacing: 1),
                filled: true,
                fillColor:Colors.white54 ,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color:Colors.deepOrange )
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color.fromRGBO(0, 51, 102, 1) )
                )
              ),
                  )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, right: 5),
        child: GestureDetector(
          onTap: () async {
            if(controller.text.isNotEmpty)
              {
                int controllervalue=int.parse(controller.text.trim());
                favouritewords.shuffle();


                if(hinttextval==0)
                  {
                    Fluttertoast.showToast(
                        msg: "Please ADD some words to Favourite During Translation before starting Quiz",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Colors.teal,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    return;
                  }

                if(controllervalue>hinttextval || controllervalue<=0 )
                {

                  Fluttertoast.showToast(
                      msg: "Enter number of quiz between 1 and $hinttextval",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.teal,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  return;
                }
                finalselectedwords=favouritewords.sublist(0,controllervalue);

                Navigator.push(context, MaterialPageRoute(builder: (context)=>FavouriteWordsQuizScreen(words: finalselectedwords!)));
              }

          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 51, 102, 1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                'Start Quiz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
