import 'package:ai_text_to_speech/bloc/favouritequizBloc/favourite_quiz_bloc.dart';
import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../model/gemini_response_model.dart';
import 'TestResultScreen.dart';
import 'components/optioncontainer.dart';

class FavouriteWordsQuizScreen extends StatefulWidget {
  List<FavoriteWord> words;
  FavouriteWordsQuizScreen({super.key,required this.words});

  @override
  State<FavouriteWordsQuizScreen> createState() => _FavouriteWordsQuizScreenState();
}

class _FavouriteWordsQuizScreenState extends State<FavouriteWordsQuizScreen> {
  String? selectedOption;
  List<MCQQuestion>? mcqs;
  int mcqsNumber = 0;
  int correctAnswers = 0;
  String? correctOption;
  int? totalMcqs;
  @override
  void initState() {
    totalMcqs=widget.words.length;
    context.read<FavouriteQuizBloc>().add(OnFavouriteQuizStartButtonPressed(words: widget.words));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Quiz',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text(
                    'Are you sure you want to quit test?',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  backgroundColor: Colors.grey.shade800,
                  actionsAlignment: MainAxisAlignment.spaceAround,

                  actions: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 100,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            'Yes',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 100,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            'No',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<FavouriteQuizBloc,FavouriteQuizState>(

        builder: (context, state) {
          if (state is FavouriteQuizErrorState) {
            Fluttertoast.showToast(
              msg: state.error.toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Color.fromRGBO(0, 51, 102, 1),
              textColor: Colors.white,
              fontSize: 16.0,
            );

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
              });
            });
          } else if (state is FavouriteQuizLoadingState) {
            return Center(
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  TyperAnimatedText(
                    'Generating Quiz',
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                    ),
                  ),
                ],
                pause: Duration(milliseconds: 300),
              ),
            );
          }
          else if(state is FavouriteQuizLoadedState)
            {
              final data = state.mcqs;

              correctOption = data?[mcqsNumber].correctAnswer;

              return SingleChildScrollView(
                child: Center(
                  child:
                  selectedOption == null
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          '${mcqsNumber + 1}/$totalMcqs',
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: LinearProgressIndicator(
                          value:
                          (mcqsNumber + 1) /
                              totalMcqs!,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "What does '${data?[mcqsNumber].question}' mean?",
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = data?[mcqsNumber].options[0];
                          });
                        },
                        child: OptionsContainer(
                          text: data?[mcqsNumber].options[0] ?? '',
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = data?[mcqsNumber].options[1];
                          });
                        },
                        child: OptionsContainer(
                          text: data?[mcqsNumber].options[1] ?? '',
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = data?[mcqsNumber].options[2];
                          });
                        },
                        child: OptionsContainer(
                          text: data?[mcqsNumber].options[2] ?? '',
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = data?[mcqsNumber].options[3];
                          });
                        },
                        child: OptionsContainer(
                          text: data?[mcqsNumber].options[3] ?? '',
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                    ],
                  )
                      : selectedOption != null &&
                      selectedOption == data?[mcqsNumber].correctAnswer
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          '${mcqsNumber + 1}/$totalMcqs',
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: LinearProgressIndicator(
                          value:
                          (mcqsNumber + 1) /
                              totalMcqs!,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "What does '${data?[mcqsNumber].question}' mean?",
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      OptionsContainer(
                        text: data?[mcqsNumber].options[0] ?? '',
                        color:
                        selectedOption == data?[mcqsNumber].options[0]
                            ? Colors.green
                            : Color.fromRGBO(0, 51, 102, 1),
                      ),
                      OptionsContainer(
                        text: data?[mcqsNumber].options[1] ?? '',
                        color:
                        selectedOption == data?[mcqsNumber].options[1]
                            ? Colors.green
                            : Color.fromRGBO(0, 51, 102, 1),
                      ),
                      OptionsContainer(
                        text: data?[mcqsNumber].options[2] ?? '',
                        color:
                        selectedOption == data?[mcqsNumber].options[2]
                            ? Colors.green
                            : Color.fromRGBO(0, 51, 102, 1),
                      ),
                      OptionsContainer(
                        text: data?[mcqsNumber].options[3] ?? '',
                        color:
                        selectedOption == data?[mcqsNumber].options[3]
                            ? Colors.green
                            : Color.fromRGBO(0, 51, 102, 1),
                      ),
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                            '${mcqsNumber + 1}/$totalMcqs'
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: LinearProgressIndicator(
                          value:
                          (mcqsNumber + 1) /
                              totalMcqs!,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "What does '${data?[mcqsNumber].question}' mean?",
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      OptionsContainer(
                        text: data?[mcqsNumber].options[0] ?? '',
                        color:
                        data?[mcqsNumber].correctAnswer ==
                            data?[mcqsNumber].options[0]
                            ? Colors.green
                            : Colors.red,
                      ),
                      OptionsContainer(
                        text: data?[mcqsNumber].options[1] ?? '',
                        color:
                        data?[mcqsNumber].correctAnswer ==
                            data?[mcqsNumber].options[1]
                            ? Colors.green
                            : Colors.red,
                      ),
                      OptionsContainer(
                        text: data?[mcqsNumber].options[2] ?? '',
                        color:
                        data?[mcqsNumber].correctAnswer ==
                            data?[mcqsNumber].options[2]
                            ? Colors.green
                            : Colors.red,
                      ),
                      OptionsContainer(
                        text: data?[mcqsNumber].options[3] ?? '',
                        color:
                        data?[mcqsNumber].correctAnswer ==
                            data?[mcqsNumber].options[3]
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ),
              );
            }

              return Container();

        },

      ),
      floatingActionButton:
      (mcqsNumber + 1) < totalMcqs!
          ? Padding(
        padding: const EdgeInsets.only(left: 30, right: 5),
        child: GestureDetector(
          onTap: () async {
            setState(() {
              if (selectedOption == null) {
                selectedOption = '';
              } else {
                if (selectedOption == correctOption) {
                  correctAnswers++;
                }
                selectedOption = null;
                mcqsNumber++;
              }
            });
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
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.only(left: 30, right: 5),
        child: GestureDetector(
          onTap: () async {
            setState(() {
              if (selectedOption == null) {
                selectedOption = '';
              } else {
                if (selectedOption == correctOption) {
                  correctAnswers++;
                }
                selectedOption = null;
              }
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TestResultScreen(
                  correctAnswers: correctAnswers,
                  totalScore: totalMcqs!,
                ),
              ),
            );
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
                'Check Result',
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
