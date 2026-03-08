import 'package:ai_text_to_speech/bloc/generalquizBloc/generalquiz_bloc.dart';
import 'package:ai_text_to_speech/model/gemini_response_model.dart';
import 'package:ai_text_to_speech/screen/TestResultScreen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Utils/app_dialogs.dart';

class GeneralWordQuizScreen extends StatefulWidget {
  final String selectedfromLanguage;
  final String selectedtoLanguage;
  final String selecteddifficultyLevel;
  final String selectedMcqsCount;
  const GeneralWordQuizScreen({
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
  /// The native-script value of the option the user tapped.
  String? selectedOptionNative;
  List<MCQQuestion>? mcqs;
  int mcqsNumber = 0;
  int correctAnswers = 0;

  // ──────────────────────────────────────────────
  // Colours
  // ──────────────────────────────────────────────
  static const _primary = Color.fromRGBO(0, 51, 102, 1);
  static const _correct = Color(0xFF2E7D32);
  static const _wrong   = Color(0xFFC62828);

  @override
  void initState() {
    context.read<GeneralquizBloc>().add(
          GeneralQuizStartButtonPressesd(
            fromLang: widget.selectedfromLanguage,
            toLang: widget.selectedtoLanguage,
            difficulty: widget.selecteddifficultyLevel,
            numberofQuiz: widget.selectedMcqsCount,
          ),
        );
    super.initState();
  }

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────

  /// Returns null when no option is selected, true when correct, false when wrong.
  bool? _optionResult(String optionNative, String correctAnswer) {
    if (selectedOptionNative == null) return null;
    if (optionNative == correctAnswer) return true;      // always highlight correct
    if (optionNative == selectedOptionNative) return false; // highlight wrong pick
    return null; // dim other options
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: _primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Vocabulary Quiz',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _confirmQuit,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<GeneralquizBloc, GeneralquizState>(
        builder: (context, state) {
          if (state is GeneralQuizErrorState) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              bool retried = false;
              await AppDialogs.showErrorDialog(
                context,
                title: 'Quiz couldn’t load',
                message: AppDialogs.prettyError(state.error.toString()),
                onRetry: () {
                  retried = true;
                  context.read<GeneralquizBloc>().add(
                        GeneralQuizStartButtonPressesd(
                          fromLang: widget.selectedfromLanguage,
                          toLang: widget.selectedtoLanguage,
                          difficulty: widget.selecteddifficultyLevel,
                          numberofQuiz: widget.selectedMcqsCount,
                        ),
                      );
                },
                showExit: true,
                exitLabel: 'Exit',
                retryLabel: 'Retry',
              );

              // If user didn't retry, exit the quiz screen.
              if (!retried && mounted) {
                Navigator.pop(context);
              }
            });
            return const SizedBox.shrink();
          }

          if (state is GeneralQuizLoadingState) {
            return Center(
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  TyperAnimatedText(
                    'Generating Quiz…',
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                      color: _primary,
                    ),
                  ),
                ],
                pause: const Duration(milliseconds: 300),
              ),
            );
          }

          if (state is GeneralQuizLoadedState) {
            final data = state.mcqs;
            if (data == null || data.isEmpty) return const SizedBox.shrink();

            final question = data[mcqsNumber];

            return _buildQuizBody(data, question);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<GeneralquizBloc, GeneralquizState>(
        builder: (context, state) {
          if (state is GeneralQuizLoadedState) {
            final data = state.mcqs;
            if (data == null || data.isEmpty) return const SizedBox.shrink();

            final isLast = (mcqsNumber + 1) >= int.parse(widget.selectedMcqsCount);
            final canProceed = selectedOptionNative != null;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: canProceed ? () => _onNext(data, isLast) : null,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: canProceed ? 1.0 : 0.45,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: canProceed
                          ? [
                              BoxShadow(
                                color: _primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        isLast ? 'Check Result' : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
  // Quiz body
  // ──────────────────────────────────────────────

  Widget _buildQuizBody(List<MCQQuestion> data, MCQQuestion question) {
    final total = int.parse(widget.selectedMcqsCount);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${mcqsNumber + 1} / $total',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _primary,
                  fontSize: 14,
                ),
              ),
              Text(
                '✓ $correctAnswers correct',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: (mcqsNumber + 1) / total,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              color: _primary,
            ),
          ),
          const SizedBox(height: 32),

          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'How do you say this in ${widget.selectedtoLanguage}?',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  question.question,
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Options – shown as "native (romanized)"
          ...question.options.asMap().entries.map((entry) {
            final opt    = entry.value;
            final result = _optionResult(opt.native, question.correctAnswer);
            final bgColor = result == null
                ? Colors.white
                : (result ? _correct : _wrong);
            final textColor = result == null ? const Color(0xFF1A1A2E) : Colors.white;
            final isSelected = (selectedOptionNative == opt.native);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: selectedOptionNative == null
                    ? () => setState(() => selectedOptionNative = opt.native)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: result == null
                          ? (isSelected
                              ? _primary
                              : Colors.grey.shade200)
                          : bgColor,
                      width: isSelected && result == null ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Native script – large
                      Text(
                        opt.native,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Romanized – smaller subtitle (only when available)
                      if (opt.romanized.isNotEmpty &&
                          opt.romanized.trim() != opt.native.trim()) ...[
                        const SizedBox(height: 4),
                        Text(
                          opt.romanized,
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: result == null
                                ? Colors.grey.shade500
                                : Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Actions
  // ──────────────────────────────────────────────

  void _onNext(List<MCQQuestion> data, bool isLast) {
    final correctAnswer = data[mcqsNumber].correctAnswer;
    if (selectedOptionNative == correctAnswer) {
      correctAnswers++;
    }

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
    } else {
      setState(() {
        selectedOptionNative = null;
        mcqsNumber++;
      });
    }
  }

  void _confirmQuit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text(
          'Are you sure you want to quit the quiz?',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        backgroundColor: Colors.grey.shade800,
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          _dialogButton('Yes', () {
            Navigator.pop(context);
            Navigator.pop(context);
          }),
          _dialogButton('No', () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _dialogButton(String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          width: 100,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
}
