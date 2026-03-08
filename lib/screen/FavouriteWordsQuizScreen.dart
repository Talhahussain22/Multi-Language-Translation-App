import 'package:ai_text_to_speech/bloc/favouritequizBloc/favourite_quiz_bloc.dart';
import 'package:ai_text_to_speech/model/gemini_response_model.dart';
import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'TestResultScreen.dart';
import 'components/optioncontainer.dart';

class FavouriteWordsQuizScreen extends StatefulWidget {
  List<FavoriteWord> words;
  FavouriteWordsQuizScreen({super.key, required this.words});

  @override
  State<FavouriteWordsQuizScreen> createState() =>
      _FavouriteWordsQuizScreenState();
}

class _FavouriteWordsQuizScreenState extends State<FavouriteWordsQuizScreen> {
  /// Stores the native-script value of the selected option (or the plain string
  /// for the legacy flat-format favourites quiz).
  String? selectedOption;
  List<MCQQuestion>? mcqs;
  int mcqsNumber = 0;
  int correctAnswers = 0;
  String? correctOption;
  int? totalMcqs;

  @override
  void initState() {
    totalMcqs = widget.words.length;
    context
        .read<FavouriteQuizBloc>()
        .add(OnFavouriteQuizStartButtonPressed(words: widget.words));
    super.initState();
  }

  // ──────────────────────────────────────────────
  // Helper: display label for an MCQOption
  // ──────────────────────────────────────────────
  String _optionLabel(MCQOption opt) => opt.label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Quiz',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text(
                    'Are you sure you want to quit test?',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
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
                        child: const Center(
                          child: Text(
                            'Yes',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 100,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: const Center(
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
      body: BlocBuilder<FavouriteQuizBloc, FavouriteQuizState>(
        builder: (context, state) {
          if (state is FavouriteQuizErrorState) {
            Fluttertoast.showToast(
              msg: state.error.toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
              textColor: Colors.white,
              fontSize: 16.0,
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) Navigator.pop(context);
              });
            });
          } else if (state is FavouriteQuizLoadingState) {
            return Center(
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  TyperAnimatedText(
                    'Generating Quiz',
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                    ),
                  ),
                ],
                pause: const Duration(milliseconds: 300),
              ),
            );
          } else if (state is FavouriteQuizLoadedState) {
            final data = state.mcqs;
            if (data == null) return Container();

            correctOption = data[mcqsNumber].correctAnswer;

            return SingleChildScrollView(
              child: Center(
                child: selectedOption == null
                    ? _buildQuestionColumn(data, null)
                    : selectedOption == data[mcqsNumber].correctAnswer
                        ? _buildQuestionColumn(data, true)
                        : _buildQuestionColumn(data, false),
              ),
            );
          }

          return Container();
        },
      ),
      floatingActionButton: BlocBuilder<FavouriteQuizBloc, FavouriteQuizState>(
        builder: (context, state) {
          if (state is FavouriteQuizLoadedState && totalMcqs != null) {
            final data = state.mcqs;
            final hasQuestions = (data != null && data.isNotEmpty);
            if (!hasQuestions) return const SizedBox.shrink();

            final isLast = (mcqsNumber + 1) >= totalMcqs!;
            final canProceed =
                selectedOption != null && selectedOption!.isNotEmpty;

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
                                totalScore: totalMcqs!,
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
                      color: const Color.fromRGBO(0, 51, 102, 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        isLast ? 'Check Result' : 'Next',
                        style: const TextStyle(
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
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Build question column
  // answerRevealed: null = not answered, true = correct, false = wrong
  // ──────────────────────────────────────────────
  Widget _buildQuestionColumn(List<MCQQuestion> data, bool? answerRevealed) {
    final question = data[mcqsNumber];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text('${mcqsNumber + 1}/$totalMcqs'),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: LinearProgressIndicator(
            value: (mcqsNumber + 1) / totalMcqs!,
            minHeight: 10,
            borderRadius: BorderRadius.circular(30),
            color: const Color.fromRGBO(0, 51, 102, 1),
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "What does '${question.question}' mean?",
            style: TextStyle(
              color: Colors.grey.shade900,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Options
        ...question.options.map((opt) {
          final Color color;
          if (answerRevealed == null) {
            color = const Color.fromRGBO(0, 51, 102, 1);
          } else if (answerRevealed) {
            // correct answer chosen
            color = opt.native == selectedOption ? Colors.green : const Color.fromRGBO(0, 51, 102, 1);
          } else {
            // wrong answer chosen
            color = opt.native == question.correctAnswer
                ? Colors.green
                : Colors.red;
          }

          return answerRevealed == null
              ? GestureDetector(
                  onTap: () => setState(() => selectedOption = opt.native),
                  child: OptionsContainer(
                    text: _optionLabel(opt),
                    color: color,
                  ),
                )
              : OptionsContainer(
                  text: _optionLabel(opt),
                  color: color,
                );
        }),
      ],
    );
  }
}
