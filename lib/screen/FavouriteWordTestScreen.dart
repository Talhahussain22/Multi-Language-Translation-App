import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:ai_text_to_speech/screen/FavouriteWordsQuizScreen.dart';
import 'package:ai_text_to_speech/services/ad_manager.dart';
import 'package:ai_text_to_speech/Utils/app_dialogs.dart';
import 'package:flutter/material.dart';
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
  final _adManager = AdManager();
  int _quizCount = 10;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    final hivebox = Hive.box<FavoriteWord>('favourites');
    favouritewords = hivebox.values.toList();
    hinttextval = favouritewords.length;

    // Default quiz size
    if (hinttextval > 0) {
      _quizCount = hinttextval >= 10 ? 10 : hinttextval;
    }

    if (hinttextval == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppDialogs.showSnack(
            context,
            message: 'Please save some words before starting the quiz',
            background: Colors.teal,
            duration: const Duration(seconds: 3),
          );
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adManager.ensureAdsPreloaded();
    });
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final maxCount = hinttextval;
    final canStart = maxCount > 0 && _quizCount > 0 && _quizCount <= maxCount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
        title: const Text(
          'Favourite Quiz',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 51, 102, 0.06),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: const Color.fromRGBO(0, 51, 102, 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bookmark,
                      color: Color.fromRGBO(0, 51, 102, 1)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You have $maxCount saved words',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(0, 51, 102, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'How many questions?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final v in <int>[5, 10, 15, 20])
                  if (maxCount >= v)
                    ChoiceChip(
                      label: Text('$v'),
                      selected: _quizCount == v,
                      onSelected: (_) => setState(() => _quizCount = v),
                      selectedColor: const Color.fromRGBO(0, 51, 102, 0.18),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _quizCount == v
                            ? const Color.fromRGBO(0, 51, 102, 1)
                            : Colors.grey.shade800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
              ],
            ),

            const SizedBox(height: 16),

            if (maxCount > 0) ...[
              Text(
                'Custom: $_quizCount',
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _quizCount.toDouble().clamp(1, maxCount.toDouble()),
                min: 1,
                max: maxCount.toDouble(),
                divisions: (maxCount - 1).clamp(1, 9999),
                label: '$_quizCount',
                onChanged: (v) => setState(() => _quizCount = v.round()),
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'Start Quiz',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: !canStart
                    ? null
                    : () {
                        favouritewords.shuffle();
                        finalselectedwords = favouritewords
                            .take(_quizCount.clamp(1, maxCount))
                            .toList(growable: false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavouriteWordsQuizScreen(
                              words: finalselectedwords!,
                            ),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
