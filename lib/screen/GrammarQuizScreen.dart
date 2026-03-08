import 'package:ai_text_to_speech/bloc/grammarTestBloc/grammar_test_bloc.dart';
import 'package:ai_text_to_speech/screen/TestResultScreen.dart';
import 'package:ai_text_to_speech/screen/components/optioncontainer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Utils/app_dialogs.dart';

class GrammarQuizScreen extends StatefulWidget {
  final String language;
  final String testType;
  final int totalQuestions;

  const GrammarQuizScreen({
    super.key,
    required this.language,
    required this.testType,
    required this.totalQuestions,
  });

  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen> {
  String? selectedOption;
  int mcqsNumber = 0;
  int correctAnswers = 0;
  String? correctOption;
  bool showHint = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Grammar Quiz (${widget.language})',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
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
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Back to GrammarTestScreen
                        Navigator.pop(context); // Back to TestPage
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
      body: BlocConsumer<GrammarTestBloc, GrammarTestState>(
        listener: (context, state) {
          if (state is GrammarTestError) {
            AppDialogs.showApiError(
              context,
              title: 'Practice couldn\'t load',
              error: state.error,
              onRetry: () {
                context.read<GrammarTestBloc>().add(
                      GrammarTestStarted(
                        language: widget.language,
                        testType: widget.testType,
                        count: widget.totalQuestions.toString(),
                      ),
                    );
              },
            );
          }
        },
        builder: (context, state) {
          if (state is GrammarTestError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    const Text('Practice failed to load',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(AppDialogs.prettyError(state.error),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<GrammarTestBloc>().add(GrammarTestStarted(
                              language: widget.language,
                              testType: widget.testType,
                              count: widget.totalQuestions.toString(),
                            ));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is GrammarTestLoading) {
            return Center(
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  TyperAnimatedText(
                    'Generating Quiz...',
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                    ),
                  ),
                ],
                pause: const Duration(milliseconds: 300),
              ),
            );
          }
          if (state is GrammarTestLoaded) {
            final data = state.questions;
            if (data.isEmpty) return const SizedBox();

            correctOption = data[mcqsNumber].correctAnswer;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100), // Space for FAB
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${mcqsNumber + 1}/${widget.totalQuestions}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.deepOrange.withValues(alpha: 0.3)),
                            ),
                            child: const Text('Grammar',
                                style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: LinearProgressIndicator(
                        value: (mcqsNumber + 1) / widget.totalQuestions,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(30),
                        color: const Color.fromRGBO(0, 51, 102, 1),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Question Sentence display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const Text(
                            "Fill in the blank:",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(0, 51, 102, 0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color.fromRGBO(0, 51, 102, 0.1),
                              ),
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: _buildSentenceSpans(
                                    data[mcqsNumber].sentence),
                                style: TextStyle(
                                  color: Colors.grey.shade900,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Options
                    ...List.generate(4, (index) {
                      final option = data[mcqsNumber].options[index];
                      // Determine color logic
                      Color containerColor =
                          const Color.fromRGBO(0, 51, 102, 1);
                      if (selectedOption != null) {
                        if (option == correctOption) {
                          containerColor = Colors.green; // Correct answer
                        } else if (option == selectedOption) {
                          containerColor = Colors.red; // Selected wrong answer
                        } else {
                          containerColor = Colors.grey.shade400; // Other options
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          if (selectedOption == null) {
                            setState(() {
                              selectedOption = option;
                              showHint = true;
                            });
                          }
                        },
                        child: OptionsContainer(
                          text: option,
                          color: containerColor,
                        ),
                      );
                    }),
                    
                    // Grammar Hint
                    if (showHint && data[mcqsNumber].hint.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline,
                                  color: Colors.orange, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Grammar Rule',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data[mcqsNumber].hint,
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 14,
                                          height: 1.3),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: BlocBuilder<GrammarTestBloc, GrammarTestState>(
        builder: (context, state) {
          if (state is GrammarTestLoaded) {
            final isLast = (mcqsNumber + 1) >= widget.totalQuestions;
            final canProceed = selectedOption != null;

            return Padding(
              padding: const EdgeInsets.only(left: 30, right: 5),
              child: GestureDetector(
                onTap: !canProceed
                    ? null
                    : () {
                        setState(() {
                          if (selectedOption == correctOption) {
                            correctAnswers++;
                          }

                          if (!isLast) {
                            mcqsNumber++;
                            selectedOption = null;
                            showHint = false;
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestResultScreen(
                                  correctAnswers: correctAnswers,
                                  totalScore: widget.totalQuestions,
                                ),
                              ),
                            );
                          }
                        });
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
                        isLast ? 'Check Result' : 'Next Question',
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
          return const SizedBox();
        },
      ),
    );
  }

  // Parses the sentence string and replaces "____" or "______" with a colored blank
  List<TextSpan> _buildSentenceSpans(String fullSentence) {
    // Basic regex: match 3 or more underscores
    final regex = RegExp(r'_{3,}');
    final matches = regex.allMatches(fullSentence);

    if (matches.isEmpty) {
      return [TextSpan(text: fullSentence)];
    }

    final spans = <TextSpan>[];
    int currentPos = 0;

    for (final match in matches) {
      if (match.start > currentPos) {
        spans.add(TextSpan(text: fullSentence.substring(currentPos, match.start)));
      }
      // Add the blank styling
      String blankText = " ________ ";
      if (selectedOption != null) {
        blankText = " $selectedOption ";
      }
      
      spans.add(TextSpan(
        text: blankText,
        style: TextStyle(
          color: selectedOption == null
              ? Colors.deepOrange
              : (selectedOption == correctOption ? Colors.green : Colors.red),
          decoration: TextDecoration.underline,
        ),
      ));
      currentPos = match.end;
    }

    if (currentPos < fullSentence.length) {
      spans.add(TextSpan(text: fullSentence.substring(currentPos)));
    }

    return spans;
  }
}
