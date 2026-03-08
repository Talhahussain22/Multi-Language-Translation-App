// import 'package:ai_text_to_speech/bloc/summary_fetch/summary_fetch_bloc.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// class SummaryDisplayScreen extends StatefulWidget {
//   final String topic;
//   final List<String> words;
//   final String targetLanguage;
//
//   const SummaryDisplayScreen({
//     super.key,
//     required this.topic,
//     required this.words,
//     required this.targetLanguage,
//   });
//
//   @override
//   State<SummaryDisplayScreen> createState() => _SummaryDisplayScreenState();
// }
//
// class _SummaryDisplayScreenState extends State<SummaryDisplayScreen> {
//
//
//   @override
//   void initState() {
//
//     context.read<SummaryFetchBloc>().add(
//       SummaryFetchButtonPressed(
//         topic: widget.topic,
//         words: widget.words,
//         targetLanguage: widget.targetLanguage,
//       ),
//     );
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromRGBO(0, 51, 102, 1),
//         title: Text('Summary', style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: BlocBuilder<SummaryFetchBloc, SummaryFetchState>(
//         builder: (context, state) {
//           if (state is SummaryFetchLoadingState) {
//             return Center(
//               child: AnimatedTextKit(
//                 repeatForever: true,
//                 animatedTexts: [
//                   TyperAnimatedText(
//                     'Generating Summary',
//                     textStyle: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       fontSize: 25,
//                     ),
//                   ),
//                 ],
//                 pause: Duration(milliseconds: 300),
//               ),
//             );
//           }
//           else if (state is SummaryFetchErrorState) {
//             Fluttertoast.showToast(
//               msg: state.error.toString(),
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.CENTER,
//               timeInSecForIosWeb: 1,
//               backgroundColor: Color.fromRGBO(0, 51, 102, 1),
//               textColor: Colors.white,
//               fontSize: 16.0,
//             );
//
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               Future.delayed(Duration(seconds: 2), () {
//                 Navigator.pop(context);
//               });
//             });
//           }
//           else if (state is SummaryFetchLoadedState) {
//             final data = state.text;
//
//             if (data != null) {
//               return Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     // Header with word count
//                     Container(
//                       padding: EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Color.fromRGBO(0, 51, 102, 0.1),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Color.fromRGBO(0, 51, 102, 0.3)),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.star, color: Colors.amber, size: 24),
//                           SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               '${widget.words.length} favorite words highlighted below',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color.fromRGBO(0, 51, 102, 1),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     // Summary content
//                     Expanded(
//                       child: Container(
//                         padding: EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(color: Colors.grey.shade300),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withValues(alpha: 0.05),
//                               blurRadius: 10,
//                               offset: Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: SingleChildScrollView(
//                           child: _buildHighlightedText(data, widget.words),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     // Legend
//                     Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.yellow.shade50,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.yellow.shade300),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: Colors.yellow.shade300,
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               'word',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w900,
//                                 fontSize: 15,
//                                 color: Color.fromRGBO(0, 51, 102, 1),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade600),
//                           SizedBox(width: 10),
//                           Text(
//                             'Your favorite words',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.grey.shade700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             } else {
//               return Container();
//             }
//           }
//           return Container();
//
//
//         },
//
//       ),
//     );
//   }
//
//   Widget _buildHighlightedText(String text, List<String> highlightWords) {
//     List<TextSpan> spans = [];
//
//     // Convert highlight words to lowercase for matching
//     final highlightWordsLower = highlightWords.map((w) => w.toLowerCase()).toSet();
//
//     // Split text by spaces and newlines
//     final words = text.split(RegExp(r'(\s+)'));
//
//     for (final word in words) {
//       if (word.trim().isEmpty) {
//         // Keep whitespace
//         spans.add(TextSpan(text: word));
//         continue;
//       }
//
//       // Clean word for comparison (remove punctuation)
//       final cleanWord = word.replaceAll(RegExp(r'[.,!?;:()"\'\[\]]'), '').toLowerCase();
//
//       bool isHighlighted = highlightWordsLower.contains(cleanWord);
//
//       if (isHighlighted) {
//         // Highlighted word - BOLD and YELLOW background
//         spans.add(TextSpan(
//           text: word,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w900,  // Extra bold
//             color: Color.fromRGBO(0, 51, 102, 1),  // Dark blue text
//             backgroundColor: Colors.yellow.shade300,  // Bright yellow background
//             height: 1.8,
//             letterSpacing: 0.3,
//           ),
//         ));
//       } else {
//         // Normal word
//         spans.add(TextSpan(
//           text: word,
//           style: TextStyle(
//             fontSize: 18,
//             color: Colors.grey.shade800,
//             height: 1.8,
//             fontWeight: FontWeight.w400,
//           ),
//         ));
//       }
//     }
//
//     return RichText(
//       text: TextSpan(children: spans),
//       textAlign: TextAlign.left,
//     );
//   }
// }
