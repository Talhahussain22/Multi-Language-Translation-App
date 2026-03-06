import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:ai_text_to_speech/screen/SummaryDisplayScreen.dart';
import 'package:ai_text_to_speech/screen/components/CustomDropDown.dart';
import 'package:ai_text_to_speech/screen/components/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import '../services/preferences_service.dart';
import '../services/ad_manager.dart';

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
  final _prefs = PreferencesService();
  final _adManager = AdManager();
  String? _errorTopic;
  String? _errorCount;

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

  Future<void> _attemptGenerateSummary(List<String> finalwords) async {
    // Guard: validate before ads/generation
    if ((topiccontroller.text.trim().isEmpty)) {
      setState(() { _errorTopic = 'Please enter a topic'; });
      Fluttertoast.showToast(msg: 'Enter a topic before generating summary');
      return;
    }
    if (numberController.text.trim().isEmpty) {
      setState(() { _errorCount = 'Enter number of words'; });
      Fluttertoast.showToast(msg: 'Enter how many favourite words to use');
      return;
    }
    final int? count = int.tryParse(numberController.text.trim());
    if (count == null || count <= 0) {
      setState(() { _errorCount = 'Enter a positive number'; });
      Fluttertoast.showToast(msg: 'Number of words must be a positive integer');
      return;
    }
    if ((favouritewords?.length ?? 0) < count) {
      setState(() { _errorCount = 'You have only ${favouritewords?.length ?? 0} words'; });
      Fluttertoast.showToast(
          msg: 'You have only ${(favouritewords?.length ?? 0)} words for $selectedLanguage');
      return;
    }
    if (selectedLanguage == null || (languages?.isEmpty ?? true)) {
      Fluttertoast.showToast(msg: 'Please select a language');
      return;
    }

    final freeUsed = await _prefs.isFreeSummaryUsed();
    final rewardGranted = await _prefs.isSummaryRewardGranted();

    if (!freeUsed) {
      await _prefs.setFreeSummaryUsed(true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryDisplayScreen(
            topic: topiccontroller.text.toString(),
            words: finalwords,
            targetLanguage: selectedLanguage!,
          ),
        ),
      );
      return;
    }

    if (rewardGranted) {
      await _prefs.resetSummaryGating();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryDisplayScreen(
            topic: topiccontroller.text.toString(),
            words: finalwords,
            targetLanguage: selectedLanguage!,
          ),
        ),
      );
      return;
    }

    // Ask user to watch ad
    final shouldWatch = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Watch Ad'),
        content: const Text('To generate summary, please watch an ad.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Watch Ad')),
        ],
      ),
    );

    if (shouldWatch != true) return;

    await _adManager.loadRewardedAd(onAdFailed: () {
      Fluttertoast.showToast(msg: 'Ad failed to load. Try again later.');
    });

    _adManager.showRewardedAd(
      onRewardEarned: () async {
        await _prefs.setSummaryRewardGranted(true);
      },
      onAdDismissed: () async {
        final granted = await _prefs.isSummaryRewardGranted();
        if (granted) {
          await _prefs.resetSummaryGating();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SummaryDisplayScreen(
                topic: topiccontroller.text.toString(),
                words: finalwords,
                targetLanguage: selectedLanguage!,
              ),
            ),
          );
        }
      },
      onAdFailed: () {
        Fluttertoast.showToast(msg: 'Ad unavailable at the moment.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets; // keyboard
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
        title: const Text('Summary', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: viewInsets.bottom + 16),
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
                if (_errorTopic != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(_errorTopic!, style: TextStyle(color: Colors.red[700], fontSize: 12)),
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
                if (_errorCount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(_errorCount!, style: TextStyle(color: Colors.red[700], fontSize: 12)),
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
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 12 + viewInsets.bottom),
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.summarize),
            label: const Text('Generate Summary'),
            onPressed: () async {
              setState(() { _errorTopic = null; _errorCount = null; });
              if (topiccontroller.text.trim().isEmpty) {
                setState(() { _errorTopic = 'Please enter a topic'; });
                Fluttertoast.showToast(msg: 'Enter a topic');
                return;
              }
              if (numberController.text.trim().isEmpty) {
                setState(() { _errorCount = 'Enter number of words'; });
                Fluttertoast.showToast(msg: 'Enter how many favourite words to use');
                return;
              }
              final int? fieldvalue = int.tryParse(numberController.text.trim());
              if (fieldvalue == null || fieldvalue <= 0) {
                setState(() { _errorCount = 'Enter a positive number'; });
                Fluttertoast.showToast(msg: 'Number of words must be positive');
                return;
              }
              final tempfav = words
                  ?.where((word) => word.fromLanguage == selectedLanguage)
                  .map((e) => e.word)
                  .toList() ?? [];
              await _attemptGenerateSummary(tempfav.take(fieldvalue).toList());
            },
          ),
        ),
      ),
    );
  }
}
