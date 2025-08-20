import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:ai_text_to_speech/screen/SummaryDisplayScreen.dart';
import 'package:ai_text_to_speech/screen/components/CustomDropDown.dart';
import 'package:ai_text_to_speech/screen/components/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late TextEditingController topiccontroller;
  late TextEditingController numberController;
  List<String>? languages;
  List<String>? favouritewords;
  String? selectedLanguage;
  List<FavoriteWord>? words;

  @override
  void initState() {
    topiccontroller = TextEditingController();
    numberController = TextEditingController();
    final hivebox = Hive.box<FavoriteWord>('favourites');
    words = hivebox.values.toList();
    languages = words?.map((word) => word.fromLanguage).toSet().toList();
    if (languages!.isNotEmpty) {
      selectedLanguage = languages![0];
    }
    final tempfav =
        words?.where((word) => word.fromLanguage == 'English').toSet().toList();
    favouritewords = tempfav?.map((word) => word.word).toSet().toList();

    if (languages!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Fluttertoast.showToast(
          msg: "ADD some words to favourite before getting summary",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.teal,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    topiccontroller.dispose();
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        title: Text('Summary', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Favourite Words Summary',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  letterSpacing: -0.5,
                  wordSpacing: 0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 70),
                child: Text(
                  'See how your favourite words are used in real sentences.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    letterSpacing: 0,
                    wordSpacing: 0,
                  ),
                ),
              ),
        
              SizedBox(height: 30),
              Text(
                'Topic',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 5),
              CustomTextField(
                controller: topiccontroller,
                hintext: 'Enter Topic e.g How to build focus',
              ),
              SizedBox(height: 15),
              Text(
                'Number of words',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 5),
              CustomTextField(
                controller: numberController,
                hintext: 'Favourite words want to use in summary',
                type: TextInputType.number,
              ),
              SizedBox(height: 15),
              Text(
                'Language',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 5),
              CustomDropDown(
                items: languages ?? [],
                onChanged: (String? val) {
                  setState(() {
                    selectedLanguage = val!;
                    final tempfav =
                        words
                            ?.where((word) => word.fromLanguage == val)
                            .toSet()
                            .toList();
                    favouritewords =
                        tempfav?.map((word) => word.word).toSet().toList();
                  });
                },
                selectedValue: selectedLanguage,
                color: Colors.white54,
                dropdowniconcolor: Colors.black,
                textcolor: Colors.black,
                dropdownColor: Colors.grey.shade50,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, right: 5),
        child: GestureDetector(
          onTap: () async {
            if (numberController.text.isNotEmpty) {
              final fieldvalue=int.parse(numberController.text.trim());
              if(fieldvalue>favouritewords!.length)
              {
                Fluttertoast.showToast(
                  msg: "You have only ${favouritewords!.length} word of $selectedLanguage in favourite",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.teal,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                return;
              }
              if(fieldvalue<=0)
              {
                Fluttertoast.showToast(
                  msg: "Select 1 or more words",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.teal,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                return;
              }
            }
            favouritewords?.shuffle();
            final finalwords=favouritewords?.sublist(0,int.parse(numberController.text.trim()))??[];


            Navigator.push(context, MaterialPageRoute(builder: (context)=>SummaryDisplayScreen(topic: topiccontroller.text.toString(), words: finalwords, targetLanguage: selectedLanguage!)));


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
                'Get Summary',
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
