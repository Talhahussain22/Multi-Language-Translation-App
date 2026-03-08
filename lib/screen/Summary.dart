// import 'package:ai_text_to_speech/model/hive_model.dart';
// import 'package:ai_text_to_speech/screen/SummaryDisplayScreen.dart';
// import 'package:ai_text_to_speech/screen/components/CustomDropDown.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:hive/hive.dart';
// import '../services/preferences_service.dart';
// import '../services/ad_manager.dart';
//
// class SummaryPage extends StatefulWidget {
//   const SummaryPage({super.key});
//
//   @override
//   State<SummaryPage> createState() => _SummaryPageState();
// }
//
// class _SummaryPageState extends State<SummaryPage> with SingleTickerProviderStateMixin {
//   late TextEditingController topicController;
//   late AnimationController _animationController;
//
//   List<String>? languages;
//   String? selectedLanguage;
//   List<FavoriteWord>? allWords;
//   List<FavoriteWord>? filteredWords;
//   Set<String> selectedWords = {};
//
//   final _prefs = PreferencesService();
//   final _adManager = AdManager();
//   String? _errorTopic;
//
//   @override
//   void initState() {
//     super.initState();
//     topicController = TextEditingController();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//
//     final hivebox = Hive.box<FavoriteWord>('favourites');
//     allWords = hivebox.values.toList();
//     languages = allWords?.map((word) => word.fromLanguage).toSet().toList();
//
//     if (languages != null && languages!.isNotEmpty) {
//       selectedLanguage = languages![0];
//       _updateFilteredWords();
//     }
//
//     if (languages == null || languages!.isEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _showEmptyFavoritesDialog();
//       });
//     }
//
//     // Preload ads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _adManager.ensureAdsPreloaded();
//     });
//   }
//
//   void _updateFilteredWords() {
//     setState(() {
//       filteredWords = allWords
//           ?.where((word) => word.fromLanguage == selectedLanguage)
//           .toList();
//
//       // Limit to maximum 15 words to prevent UI clutter
//       if (filteredWords != null && filteredWords!.length > 15) {
//         filteredWords = filteredWords!.take(15).toList();
//       }
//
//       // Auto-select first 5 words by default
//       if (filteredWords != null && filteredWords!.isNotEmpty) {
//         selectedWords = filteredWords!
//             .take(5)
//             .map((w) => w.word)
//             .toSet();
//       }
//     });
//   }
//
//   void _showEmptyFavoritesDialog() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Icon(Icons.info_outline, color: Colors.orange, size: 28),
//             SizedBox(width: 12),
//             Text('No Favorite Words'),
//           ],
//         ),
//         content: Text(
//           'Please add some words to your favorites first to generate summaries.',
//           style: TextStyle(fontSize: 15),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     topicController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _generateSummary() async {
//     if (topicController.text.trim().isEmpty) {
//       setState(() { _errorTopic = 'Please enter a topic'; });
//       Fluttertoast.showToast(
//         msg: 'Enter a topic for your summary',
//         backgroundColor: Colors.red,
//       );
//       return;
//     }
//
//     if (selectedWords.isEmpty) {
//       Fluttertoast.showToast(
//         msg: 'Please select at least one word',
//         backgroundColor: Colors.red,
//       );
//       return;
//     }
//
//     final freeUsed = await _prefs.isFreeSummaryUsed();
//     final rewardGranted = await _prefs.isSummaryRewardGranted();
//
//     if (!freeUsed) {
//       await _prefs.setFreeSummaryUsed(true);
//       _navigateToSummary();
//       return;
//     }
//
//     if (rewardGranted) {
//       await _prefs.resetSummaryGating();
//       _navigateToSummary();
//       return;
//     }
//
//     // Ask user to watch ad
//     final shouldWatch = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Icon(Icons.play_circle_outline, color: Color.fromRGBO(0, 51, 102, 1), size: 28),
//             SizedBox(width: 12),
//             Text('Watch Ad'),
//           ],
//         ),
//         content: Text('Watch a short ad to generate your summary.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Color.fromRGBO(0, 51, 102, 1),
//             ),
//             child: Text('Watch Ad'),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldWatch != true) return;
//
//     _adManager.showRewardedAd(
//       onRewardEarned: () async {
//         await _prefs.setSummaryRewardGranted(true);
//       },
//       onAdDismissed: () async {
//         final granted = await _prefs.isSummaryRewardGranted();
//         if (granted) {
//           await _prefs.resetSummaryGating();
//           _navigateToSummary();
//         }
//       },
//       onAdFailed: () {
//         Fluttertoast.showToast(msg: 'Ad unavailable at the moment.');
//       },
//     );
//   }
//
//   void _navigateToSummary() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SummaryDisplayScreen(
//           topic: topicController.text.toString(),
//           words: selectedWords.toList(),
//           targetLanguage: selectedLanguage!,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
//         title: const Text('Create Summary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         centerTitle: true,
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Card
//               _buildHeaderCard(),
//
//               const SizedBox(height: 24),
//
//               // Topic Input
//               _buildTopicInput(),
//
//               const SizedBox(height: 24),
//
//               // Language Selection
//               _buildLanguageSelector(),
//
//               const SizedBox(height: 24),
//
//               // Word Selection Section
//               _buildWordSelectionSection(),
//
//               const SizedBox(height: 100),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: _buildGenerateButton(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
//
//   Widget _buildHeaderCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color.fromRGBO(0, 51, 102, 0.1),
//             const Color.fromRGBO(0, 51, 102, 0.05),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color.fromRGBO(0, 51, 102, 0.2)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: const Color.fromRGBO(0, 51, 102, 1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(Icons.auto_stories, color: Colors.white, size: 32),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Smart Summary',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromRGBO(0, 51, 102, 1),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Select your favorite words and see them in action!',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade700,
//                     height: 1.3,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTopicInput() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.topic, color: Color.fromRGBO(0, 51, 102, 1), size: 20),
//             SizedBox(width: 8),
//             Text(
//               'Topic',
//               style: TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade800,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         TextField(
//           controller: topicController,
//           decoration: InputDecoration(
//             hintText: 'e.g., How to stay healthy, Daily routine, etc.',
//             hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
//             filled: true,
//             fillColor: Colors.grey.shade50,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Color.fromRGBO(0, 51, 102, 1), width: 2),
//             ),
//             prefixIcon: Icon(Icons.edit, color: Color.fromRGBO(0, 51, 102, 1)),
//             errorText: _errorTopic,
//           ),
//           onChanged: (_) => setState(() => _errorTopic = null),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLanguageSelector() {
//     if (languages == null || languages!.isEmpty) return Container();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.language, color: Color.fromRGBO(0, 51, 102, 1), size: 20),
//             SizedBox(width: 8),
//             Text(
//               'Language',
//               style: TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade800,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         CustomDropDown(
//           color: const Color.fromRGBO(0, 51, 102, 1),
//           dropdowniconcolor: Colors.white,
//           textcolor: Colors.white,
//           dropdownColor: const Color(0xFF2C2C3C),
//           items: languages!,
//           onChanged: (String? val) {
//             setState(() {
//               selectedLanguage = val!;
//               _updateFilteredWords();
//             });
//           },
//           selectedValue: selectedLanguage,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildWordSelectionSection() {
//     if (filteredWords == null || filteredWords!.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.orange.shade50,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.orange.shade200),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
//             SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 'No favorite words found for this language',
//                 style: TextStyle(color: Colors.orange.shade900),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.star, color: Colors.amber, size: 20),
//                 SizedBox(width: 8),
//                 Text(
//                   'Select Words (${selectedWords.length})',
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 TextButton.icon(
//                   onPressed: () {
//                     setState(() {
//                       if (selectedWords.length == filteredWords!.length) {
//                         selectedWords.clear();
//                       } else {
//                         selectedWords = filteredWords!.map((w) => w.word).toSet();
//                       }
//                     });
//                   },
//                   icon: Icon(
//                     selectedWords.length == filteredWords!.length
//                         ? Icons.deselect
//                         : Icons.select_all,
//                     size: 18,
//                   ),
//                   label: Text(
//                     selectedWords.length == filteredWords!.length
//                         ? 'Clear All'
//                         : 'Select All',
//                     style: TextStyle(fontSize: 13),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: filteredWords!.map((favoriteWord) {
//               final word = favoriteWord.word;
//               final isSelected = selectedWords.contains(word);
//
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     if (isSelected) {
//                       selectedWords.remove(word);
//                     } else {
//                       selectedWords.add(word);
//                     }
//                   });
//                 },
//                 child: AnimatedContainer(
//                   duration: Duration(milliseconds: 200),
//                   padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? Color.fromRGBO(0, 51, 102, 1)
//                         : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: isSelected
//                           ? Color.fromRGBO(0, 51, 102, 1)
//                           : Colors.grey.shade300,
//                       width: isSelected ? 2 : 1,
//                     ),
//                     boxShadow: isSelected ? [
//                       BoxShadow(
//                         color: Color.fromRGBO(0, 51, 102, 0.3),
//                         blurRadius: 8,
//                         offset: Offset(0, 2),
//                       ),
//                     ] : [],
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (isSelected)
//                         Icon(Icons.check_circle,
//                           color: Colors.white,
//                           size: 16,
//                         ),
//                       if (isSelected) SizedBox(width: 6),
//                       Text(
//                         word,
//                         style: TextStyle(
//                           color: isSelected ? Colors.white : Colors.grey.shade800,
//                           fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.blue.shade200),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
//               SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   'Tap words to select. Selected words will be highlighted in your summary!',
//                   style: TextStyle(
//                     color: Colors.blue.shade900,
//                     fontSize: 13,
//                     height: 1.3,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildGenerateButton() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: SizedBox(
//         width: double.infinity,
//         height: 54,
//         child: ElevatedButton(
//           onPressed: selectedWords.isEmpty ? null : _generateSummary,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
//             disabledBackgroundColor: Colors.grey.shade300,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             elevation: selectedWords.isEmpty ? 0 : 3,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.auto_awesome,
//                 color: selectedWords.isEmpty ? Colors.grey.shade500 : Colors.white,
//                 size: 24,
//               ),
//               SizedBox(width: 10),
//               Text(
//                 'Generate Summary',
//                 style: TextStyle(
//                   color: selectedWords.isEmpty ? Colors.grey.shade500 : Colors.white,
//                   fontSize: 17,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
