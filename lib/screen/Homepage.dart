import 'package:ai_text_to_speech/bloc/on_favourite/on_favourite_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_translate/on_translate_bloc.dart';
import 'package:ai_text_to_speech/data/languagedata.dart';
import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:ai_text_to_speech/model/saved_language.dart';
import 'package:ai_text_to_speech/model/translation_result.dart';
import 'package:ai_text_to_speech/screen/components/CustomTextFeild.dart';
import 'package:ai_text_to_speech/screen/components/language_picker_sheet.dart';
import 'package:ai_text_to_speech/screen/HistoryPage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  IconData icon = Icons.favorite_border;
  Map<String, String>? fromselectedLanguage;
  Map<String, String>? toselectedLanguage;
  final TextEditingController fromfeildcontroller = TextEditingController();
  String? fromLanguage;
  String? toLanguage;

  /// Holds the latest parsed translation result for rendering.
  TranslationResult? _currentResult;

  void setLanguages() {
    final hivebox = Hive.box<SavedLanguage>('saved_lang');
    fromLanguage = hivebox.get('from')?.fromLanguage?['label'] ??
        LanguageProvider.LANGUAGES[20]['label'];
    fromselectedLanguage = LanguageProvider.LANGUAGES
        .firstWhere((item) => item['label'] == fromLanguage);

    toLanguage = hivebox.get('to')?.toLanguage?['label'] ??
        LanguageProvider.LANGUAGES[86]['label'];
    toselectedLanguage = LanguageProvider.LANGUAGES
        .firstWhere((item) => item['label'] == toLanguage);
  }

  @override
  void initState() {
    setLanguages();
    super.initState();
  }

  @override
  void dispose() {
    fromfeildcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        title: Text(
          'Language Translator',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HistoryPage()),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'history',
                child: Text('History'),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<OnTranslateBloc, OnTranslateState>(
        listener: (context, state) {
          if (state is OnTranslateFailureState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is OnTranslateSuccessState) {
            setState(() {
              _currentResult = state.result;
              icon = state.isfavourite! ? Icons.favorite : Icons.favorite_outline;
            });
          }
        },
        builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: state is OnTranslateLoadingState,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Language selector bar ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(40),
                        shadowColor: Colors.black12,
                        child: Container(
                          height: 56,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: const Color.fromRGBO(0, 51, 102, 0.12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: [
                                // FROM language chip
                                Expanded(
                                  child: _LanguageChip(
                                    flag: fromselectedLanguage?['flag'] ?? '',
                                    label: fromLanguage ?? '',
                                    onTap: () async {
                                      final picked = await showLanguagePicker(
                                        context: context,
                                        languages: LanguageProvider.LANGUAGES,
                                        selected: fromselectedLanguage,
                                        title: 'From Language',
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          final hivebox = Hive.box<SavedLanguage>('saved_lang');
                                          hivebox.put('from', SavedLanguage(fromLanguage: picked));
                                          setLanguages();
                                        });
                                      }
                                    },
                                  ),
                                ),

                                // Swap button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      final hivebox = Hive.box<SavedLanguage>('saved_lang');
                                      hivebox.put('from', SavedLanguage(fromLanguage: toselectedLanguage));
                                      hivebox.put('to', SavedLanguage(toLanguage: fromselectedLanguage));
                                      fromfeildcontroller.text = '';
                                      _currentResult = null;
                                      setLanguages();
                                    });
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(0, 51, 102, 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.swap_horiz_rounded,
                                      color: Color.fromRGBO(0, 51, 102, 1),
                                      size: 20,
                                    ),
                                  ),
                                ),

                                // TO language chip
                                Expanded(
                                  child: _LanguageChip(
                                    flag: toselectedLanguage?['flag'] ?? '',
                                    label: toLanguage ?? '',
                                    onTap: () async {
                                      final picked = await showLanguagePicker(
                                        context: context,
                                        languages: LanguageProvider.LANGUAGES,
                                        selected: toselectedLanguage,
                                        title: 'To Language',
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          final hivebox = Hive.box<SavedLanguage>('saved_lang');
                                          hivebox.put('to', SavedLanguage(toLanguage: picked));
                                          setLanguages();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // ── Input card ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(103, 80, 164, 0.05),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.shade100)
                          ],
                        ),
                        foregroundDecoration: BoxDecoration(
                          color: Color(0x0D6750A4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  fromLanguage!,
                                  style: TextStyle(
                                    color: Color.fromRGBO(0, 51, 102, 1),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      fromfeildcontroller.text = '';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Customtextfield_Homepage(
                              controller: fromfeildcontroller,
                              hintext: 'Enter to Translate',
                              onChanged: _currentResult == null
                                  ? null
                                  : (_) {
                                      setState(() {
                                        _currentResult = null;
                                      });
                                    },
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    context.read<OnTranslateBloc>().add(
                                          OnTranslateButtonClicked(
                                            text: fromfeildcontroller.text
                                                .toString(),
                                            fromLanguage: fromLanguage!,
                                            toLanguage: toLanguage!,
                                          ),
                                        );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(255, 102, 0, 1),
                                      borderRadius:
                                          BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      'Translate',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // ── Translation result card ───────────────────────────
                    BlocConsumer<OnFavouriteBloc, OnFavouriteState>(
                      listener: (context, state) {
                        if (state is OnFavouriteSuccess) {
                          setState(() {
                            icon = state.isFavourited
                                ? Icons.favorite
                                : Icons.favorite_outline;
                          });
                        }
                      },
                      builder: (context, favState) {
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(103, 80, 164, 0.05),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.shade100)
                              ],
                            ),
                            foregroundDecoration: BoxDecoration(
                              color: Color(0x0D6750A4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Language label
                                Text(
                                  toLanguage!,
                                  style: TextStyle(
                                    color: Color.fromRGBO(0, 51, 102, 1),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 12),

                                // ── Dynamic result body ──────────────────
                                _buildResultBody(_currentResult),

                                // ── Action buttons ───────────────────────
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          final copyText =
                                              _currentResult?.nativeTranslation ??
                                                  '';
                                          if (copyText.isEmpty) return;
                                          Clipboard.setData(
                                              ClipboardData(text: copyText));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Copied to clipboard'),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.copy_rounded,
                                          color: Color.fromRGBO(
                                              0, 51, 102, 1),
                                          size: 25,
                                        ),
                                      ),
                                      SizedBox(width: 3),
                                      IconButton(
                                        onPressed: () {
                                          final inputText =
                                              fromfeildcontroller.text;
                                          final translation =
                                              _currentResult
                                                  ?.historyString ??
                                                  '';
                                          if (inputText.isEmpty ||
                                              translation.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'error: Either Word or Translation is Empty')));
                                            return;
                                          }
                                          if (inputText.trim().contains(' ')) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Only words can be added to Favourites (not sentences)')));
                                            return;
                                          }
                                          context
                                              .read<OnFavouriteBloc>()
                                              .add(
                                                OnFavouriteButtonClicked(
                                                  favoriteWord: FavoriteWord(
                                                    word: inputText,
                                                    translation: translation,
                                                    fromLanguage:
                                                        fromLanguage!,
                                                    toLanguage: toLanguage!,
                                                  ),
                                                ),
                                              );
                                        },
                                        icon: Icon(
                                          icon,
                                          color: Colors.red,
                                          size: 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the dynamic translation result body based on what fields exist.
  Widget _buildResultBody(TranslationResult? result) {
    // No result yet — show placeholder hint
    if (result == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Translation will appear here',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final native = result.nativeTranslation;
    final romanized = result.romanizedTranslation;

    // Guard: if somehow both are empty show fallback
    if ((native == null || native.isEmpty) &&
        (romanized == null || romanized.isEmpty)) {
      return Text(
        'Translation unavailable',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Main translation + part-of-speech chip ────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (native != null && native.isNotEmpty)
              Expanded(
                child: Text(
                  native,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            if (result.partOfSpeech != null &&
                result.partOfSpeech!.isNotEmpty) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 51, 102, 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color.fromRGBO(0, 51, 102, 0.18),
                    width: 1,
                  ),
                ),
                child: Text(
                  result.partOfSpeech!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(0, 51, 102, 1),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (romanized != null && romanized.isNotEmpty) ...[
          SizedBox(height: 4),
          Text(
            romanized,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],

        // ── 2. Definition ────────────────────────────────────────────
        if (result.definition != null && result.definition!.isNotEmpty) ...[
          SizedBox(height: 12),
          _sectionLabel('Definition'),
          SizedBox(height: 4),
          Text(
            result.definition!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],

        // ── 3. Pronunciation ─────────────────────────────────────────
        if (result.pronunciation != null &&
            result.pronunciation!.isNotEmpty) ...[
          SizedBox(height: 14),
          _sectionLabel('Pronunciation'),
          SizedBox(height: 4),
          Text(
            result.pronunciation!,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],

        // ── 4. Synonyms ──────────────────────────────────────────────
        if (result.synonyms.isNotEmpty) ...[
          SizedBox(height: 14),
          _sectionLabel('Synonyms'),
          SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: result.synonyms.map((syn) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 102, 0, 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color.fromRGBO(255, 102, 0, 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  syn,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromRGBO(200, 75, 0, 1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        // ── 5. Example sentence ──────────────────────────────────────
        if (result.exampleNative != null &&
            result.exampleNative!.isNotEmpty) ...[
          SizedBox(height: 16),
          _sectionLabel('Example'),
          SizedBox(height: 6),
          Text(
            result.exampleNative!,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (result.exampleRomanized != null &&
              result.exampleRomanized!.isNotEmpty) ...[
            SizedBox(height: 3),
            Text(
              result.exampleRomanized!,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
          if (result.exampleMeaning != null &&
              result.exampleMeaning!.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 51, 102, 0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meaning  ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(0, 51, 102, 1),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      result.exampleMeaning!,
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: Color.fromRGBO(255, 102, 0, 1),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────
// Reusable language chip for the translation bar
// ───────────────────────────────────────────────────────────────────
class _LanguageChip extends StatelessWidget {
  final String flag;
  final String label;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.flag,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(0, 51, 102, 1),
                ),
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Color.fromRGBO(0, 51, 102, 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
