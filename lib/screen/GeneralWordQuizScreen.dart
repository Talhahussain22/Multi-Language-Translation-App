import 'package:ai_text_to_speech/bloc/generalquizBloc/generalquiz_bloc.dart';
import 'package:ai_text_to_speech/model/gemini_response_model.dart';
import 'package:ai_text_to_speech/screen/TestResultScreen.dart';
import 'package:ai_text_to_speech/screen/components/optioncontainer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GeneralWordQuizScreen extends StatefulWidget {
  String selectedfromLanguage;
  String selectedtoLanguage;
  String selecteddifficultyLevel;
  String selectedMcqsCount;
  GeneralWordQuizScreen({
    super.key,
    required this.selectedfromLanguage,
    required this.selectedtoLanguage,
    required this.selecteddifficultyLevel,
    required this.selectedMcqsCount,
  });

  @override
  State<GeneralWordQuizScreen> createState() => _GeneralWordQuizScreenState();
}

class _GeneralWordQuizScreenState extends State<GeneralWordQuizScreen> {
  String? selectedOption;
  List<MCQQuestion>? mcqs;
  int mcqsNumber = 0;
  int correctAnswers = 0;
  String? correctOption;


  @override
  void initState() {
    context.read<GeneralquizBloc>().add(GeneralQuizStartButtonPressesd(fromLang: widget.selectedfromLanguage, toLang: widget.selectedtoLanguage, difficulty: widget.selecteddifficultyLevel, numberofQuiz: widget.selectedMcqsCount));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
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
                  content: const Text(
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
                          child: const Text(
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
                          child: const Text(
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
      body: BlocBuilder<GeneralquizBloc,GeneralquizState>(

        builder: (context, state) {
          if (state is GeneralQuizErrorState) {
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
          } else if (state is GeneralQuizLoadingState) {
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
          if(state is GeneralQuizLoadedState)
            {
              final data = state.mcqs;
              correctOption = data?[mcqsNumber].correctAnswer;

              return data==null?Container():SingleChildScrollView(
                child: Center(
                  child:
                  selectedOption == null
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          '${mcqsNumber + 1}/${widget.selectedMcqsCount}',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: LinearProgressIndicator(
                          value:
                          (mcqsNumber + 1) /
                              int.parse(widget.selectedMcqsCount),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "What does '${data[mcqsNumber].question}' mean?",
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
                            selectedOption = data[mcqsNumber].options[0];
                          });
                        },
                        child: OptionsContainer(
                          text: data[mcqsNumber].options[0] ?? '',
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = data[mcqsNumber].options[1];
                          });
                        },
                        child: OptionsContainer(
                          text: data[mcqsNumber].options[1] ?? '',
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = data[mcqsNumber].options[2];
                          });
                        },
                        child: OptionsContainer(
                          text: data[mcqsNumber].options[2] ?? '',
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = data[mcqsNumber].options[3];
                          });
                        },
                        child: OptionsContainer(
                          text: data[mcqsNumber].options[3] ?? '',
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                    ],
                  )
                      : selectedOption != null &&
                      selectedOption == data[mcqsNumber].correctAnswer
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          '${mcqsNumber + 1}/${widget.selectedMcqsCount}',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: LinearProgressIndicator(
                          value:
                          (mcqsNumber + 1) /
                              int.parse(widget.selectedMcqsCount),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "What does '${data[mcqsNumber].question}' mean?",
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      OptionsContainer(
                        text: data[mcqsNumber].options[0] ?? '',
                        color:
                        selectedOption == data[mcqsNumber].options[0]
                            ? Colors.green
                            : Color.fromRGBO(0, 51, 102, 1),
                      ),
                      OptionsContainer(
                        text: data[mcqsNumber].options[1] ?? '',
                        color:
                        selectedOption == data[mcqsNumber].options[1]
                            ? Colors.green
                            : Color.fromRGBO(0, 51, 102, 1),
                      ),
                      OptionsContainer(
                        text: data[mcqsNumber].options[2] ?? '',
                        color:
                        selectedOption == data[mcqsNumber].options[2]
                            ? Colors.green
                            : Color.fromRGBO(0, 51, 102, 1),
                      ),
                      OptionsContainer(
                        text: data[mcqsNumber].options[3] ?? '',
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          '${mcqsNumber + 1}/${widget.selectedMcqsCount}',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: LinearProgressIndicator(
                          value:
                          (mcqsNumber + 1) /
                              int.parse(widget.selectedMcqsCount),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "What does '${data[mcqsNumber].question}' mean?",
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      OptionsContainer(
                        text: data[mcqsNumber].options[0] ?? '',
                        color:
                        data[mcqsNumber].correctAnswer ==
                            data[mcqsNumber].options[0]
                            ? Colors.green
                            : Colors.red,
                      ),
                      OptionsContainer(
                        text: data[mcqsNumber].options[1] ?? '',
                        color:
                        data[mcqsNumber].correctAnswer ==
                            data[mcqsNumber].options[1]
                            ? Colors.green
                            : Colors.red,
                      ),
                      OptionsContainer(
                        text: data[mcqsNumber].options[2] ?? '',
                        color:
                        data[mcqsNumber].correctAnswer ==
                            data?[mcqsNumber].options[2]
                            ? Colors.green
                            : Colors.red,
                      ),
                      OptionsContainer(
                        text: data[mcqsNumber].options[3] ?? '',
                        color:
                        data[mcqsNumber].correctAnswer ==
                            data[mcqsNumber].options[3]
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ),
              );
            }
          else{
            return Container();
          }

        },
      ),
      floatingActionButton: BlocBuilder<GeneralquizBloc, GeneralquizState>(
        builder: (context, state) {
          if (state is GeneralQuizLoadedState && widget.selectedMcqsCount.isNotEmpty) {
            final data = state.mcqs;
            final hasQuestions = (data != null && data.isNotEmpty);
            if (!hasQuestions) return SizedBox.shrink();

            final isLast = (mcqsNumber + 1) >= int.parse(widget.selectedMcqsCount);
            final canProceed = selectedOption != null && selectedOption!.isNotEmpty;

            return Padding(
              padding: const EdgeInsets.only(left: 30, right: 5),
              child: GestureDetector(
                onTap: !canProceed
                    ? null
                    : () async {
                  setState(() {
                    if (selectedOption == correctOption) {
                      correctAnswers++;
                    }
                    selectedOption = null;
                    if (!isLast) {
                      mcqsNumber++;
                    }
                  });
                  if (isLast) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TestResultScreen(
                          correctAnswers: correctAnswers,
                          totalScore: int.parse(widget.selectedMcqsCount),
                        ),
                      ),
                    );
                  }
                },
                child: Opacity(
                  opacity: canProceed ? 1 : 0.6,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 51, 102, 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        isLast ? 'Check Result' : 'Next',
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
          // Hide FAB while loading or on error
          return SizedBox.shrink();
        },
      ),
    );
  }
}
