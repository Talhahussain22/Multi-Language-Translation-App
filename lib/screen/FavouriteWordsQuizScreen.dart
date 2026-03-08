import 'package:ai_text_to_speech/bloc/favouritequizBloc/favourite_quiz_bloc.dart';
import 'package:ai_text_to_speech/model/gemini_response_model.dart';
import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'TestResultScreen.dart';
import 'components/quiz_option_tile.dart';

class FavouriteWordsQuizScreen extends StatefulWidget {
  final List<FavoriteWord> words;
  const FavouriteWordsQuizScreen({super.key, required this.words});

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
  bool _submitted = false;

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Favourite Quiz',
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
            if (data == null || data.isEmpty) {
              return const Center(child: Text('No questions available.'));
            }

            // Keep total in sync with generated list.
            totalMcqs = data.length;
            final question = data[mcqsNumber];
            correctOption = question.correctAnswer;

            final progress = totalMcqs == 0 ? 0.0 : (mcqsNumber + 1) / totalMcqs!;

            return Column(
              children: [
                _buildTopProgress(progress),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 14),
                        _buildScorePill(),
                        const SizedBox(height: 12),
                        _buildQuestionCard(question),
                        const SizedBox(height: 6),
                        if (_submitted)
                          _buildFeedbackBanner(
                            isCorrect: selectedOption == question.correctAnswer,
                            correctAnswer: question.correctAnswer,
                          ),
                        const SizedBox(height: 6),
                        ...question.options.map((opt) {
                          final optValue = opt.native;
                          final isSelected = selectedOption == optValue;

                          final bool isCorrect = _submitted && optValue == question.correctAnswer;
                          final bool isWrong = _submitted && isSelected && optValue != question.correctAnswer;

                          return QuizOptionTile(
                            text: _optionLabel(opt),
                            isSelected: isSelected,
                            isCorrect: isCorrect,
                            isWrong: isWrong,
                            onTap: _submitted
                                ? null
                                : () {
                                    setState(() {
                                      selectedOption = optValue;
                                    });
                                  },
                          );
                        }),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<FavouriteQuizBloc, FavouriteQuizState>(
        builder: (context, state) {
          if (state is! FavouriteQuizLoadedState) return const SizedBox.shrink();
          final data = state.mcqs;
          if (data == null || data.isEmpty) return const SizedBox.shrink();

          totalMcqs = data.length;
          final isLast = (mcqsNumber + 1) >= totalMcqs!;
          final canSubmit = selectedOption != null && selectedOption!.isNotEmpty && !_submitted;
          final canNext = _submitted;

          return SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedOption = null;
                          _submitted = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: canSubmit
                          ? () {
                              setState(() {
                                _submitted = true;
                                if (selectedOption == correctOption) {
                                  correctAnswers++;
                                }
                              });
                            }
                          : canNext
                              ? () {
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
                                    return;
                                  }
                                  setState(() {
                                    mcqsNumber++;
                                    selectedOption = null;
                                    _submitted = false;
                                  });
                                }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        canSubmit
                            ? 'Submit'
                            : isLast
                                ? 'Finish'
                                : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopProgress(double value) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Question ${mcqsNumber + 1}/${totalMcqs ?? 0}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              color: const Color.fromRGBO(0, 51, 102, 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 51, 102, 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color.fromRGBO(0, 51, 102, 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars,
              size: 18, color: Color.fromRGBO(0, 51, 102, 1)),
          const SizedBox(width: 8),
          Text(
            'Score: $correctAnswers',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color.fromRGBO(0, 51, 102, 1),
            ),
          ),
          const Spacer(),
          Text(
            _submitted
                ? 'Answer checked'
                : (selectedOption == null ? 'Pick an option' : 'Ready to submit'),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(MCQQuestion question) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'What does this mean?',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Color.fromRGBO(0, 51, 102, 1),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner({
    required bool isCorrect,
    required String correctAnswer,
  }) {
    final bg = isCorrect ? Colors.green.shade50 : Colors.red.shade50;
    final border = isCorrect ? Colors.green.shade200 : Colors.red.shade200;
    final icon = isCorrect ? Icons.check_circle : Icons.info;
    final title = isCorrect ? 'Correct!' : 'Not quite';
    final subtitle = isCorrect ? 'Nice work.' : 'Correct answer: $correctAnswer';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: isCorrect ? Colors.green : Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
