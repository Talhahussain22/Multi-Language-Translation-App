import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/daily_word/daily_word_bloc.dart';
import '../model/daily_word_model.dart';
import '../services/ad_manager.dart';
import 'GeneralTestScreen.dart';
import '../data/languagedata.dart';

class DailyWordScreen extends StatefulWidget {
  const DailyWordScreen({super.key});

  @override
  State<DailyWordScreen> createState() => _DailyWordScreenState();
}

class _DailyWordScreenState extends State<DailyWordScreen> {
  final _adManager = AdManager();
  String? _learningLanguage;

  @override
  void initState() {
    super.initState();
    _loadLanguageAndFetchWord();

    // Preload ads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adManager.ensureAdsPreloaded();
    });
  }

  Future<void> _loadLanguageAndFetchWord() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('daily_word_learning_language');

    if (savedLang != null && savedLang.isNotEmpty) {
      setState(() => _learningLanguage = savedLang);
      if (mounted) {
        context.read<DailyWordBloc>().add(LoadDailyWord(savedLang));
      }
    } else {
      _showLanguageSelectionDialog();
    }
  }

  Future<void> _showLanguageSelectionDialog() async {
    // Use the app's canonical language list.
    final allLanguages = LanguageProvider.LANGUAGES;

    // We store the selected *label* as the learning language.
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _LanguagePickerSheet(
          title: 'Choose learning language',
          subtitle: 'Pick the language you want to practice daily. You can change it anytime.',
          currentSelection: _learningLanguage,
          languages: allLanguages,
          primaryColor: const Color.fromRGBO(0, 51, 102, 1),
        );
      },
    );

    if (selected != null && selected.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('daily_word_learning_language', selected);
      setState(() => _learningLanguage = selected);
      if (mounted) {
        context.read<DailyWordBloc>().add(LoadDailyWord(selected));
      }
    } else {
      // First-time entry: require selection.
      if (_learningLanguage == null) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        if (mounted) {
          _showLanguageSelectionDialog();
        }
      }
    }
  }

  String _getStreakMessage(int streak) {
    if (streak >= 30) return 'Amazing dedication! 🌟';
    if (streak >= 7) return 'One week streak! 🔥';
    if (streak >= 3) return 'Nice start! 💪';
    return 'Keep it up! 📚';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
        title: const Text('Daily Word', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showLanguageSelectionDialog,
            tooltip: 'Change Language',
          ),
        ],
      ),
      body: BlocBuilder<DailyWordBloc, DailyWordState>(
        builder: (context, state) {
          if (state is DailyWordLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color.fromRGBO(0, 51, 102, 1)),
                  SizedBox(height: 16),
                  Text('Loading today\'s word...', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          if (state is DailyWordError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_learningLanguage != null) {
                          context.read<DailyWordBloc>().add(LoadDailyWord(_learningLanguage!));
                        }
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DailyWordLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                if (_learningLanguage != null) {
                  context.read<DailyWordBloc>().add(RefreshDailyWord(_learningLanguage!));
                }
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStreakCard(state.currentStreak, state.longestStreak),
                    SizedBox(height: 20),
                    _buildDailyWordCard(state.currentWord, state.isSaved),
                    SizedBox(height: 20),
                    _buildActionButtons(state.currentWord, state.isSaved),
                    SizedBox(height: 32),
                    if (state.previousWords.isNotEmpty) ...[
                      _buildPreviousWordsSection(state.previousWords),
                    ],
                  ],
                ),
              ),
            );
          }

          return Center(child: Text('Welcome to Daily Word!'));
        },
      ),
    );
  }

  Widget _buildStreakCard(int currentStreak, int longestStreak) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF6B35).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('🔥', style: TextStyle(fontSize: 32)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak Day Streak',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _getStreakMessage(currentStreak),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                ),
                if (longestStreak > currentStreak) ...[
                  SizedBox(height: 4),
                  Text(
                    'Best: $longestStreak days',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyWordCard(DailyWordModel word, bool isSaved) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(0, 51, 102, 1),
                      ),
                    ),
                    if (word.pronunciation != null) ...[
                      SizedBox(height: 4),
                      Text(
                        word.pronunciation!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSaved)
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star, color: Colors.amber, size: 24),
                ),
            ],
          ),

          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 16),

          // Translation
          _buildSection(
            icon: Icons.translate,
            title: 'Translation',
            content: word.translation,
            color: Color.fromRGBO(0, 51, 102, 1),
          ),

          // English Meaning / Definition
          if (word.englishMeaning.trim().isNotEmpty) ...[
            SizedBox(height: 20),
            _buildSection(
              icon: Icons.menu_book_outlined,
              title: 'Meaning in English',
              content: word.englishMeaning,
              color: Colors.purple.shade700,
            ),
          ],

          SizedBox(height: 20),

          // Example Sentence
          _buildSection(
            icon: Icons.format_quote,
            title: 'Example',
            content: word.exampleSentenceEnglish,
            color: Colors.blue.shade700,
          ),

          SizedBox(height: 20),

          // Synonyms
          if (word.synonyms.isNotEmpty) ...[
            _buildListSection(
              icon: Icons.thumb_up_outlined,
              title: 'Synonyms',
              items: word.synonyms,
              color: Colors.green.shade700,
            ),
            SizedBox(height: 20),
          ],

          // Antonyms
          if (word.antonyms.isNotEmpty) ...[
            _buildListSection(
              icon: Icons.thumb_down_outlined,
              title: 'Antonyms',
              items: word.antonyms,
              color: Colors.red.shade700,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 17,
            height: 1.5,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildListSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(DailyWordModel word, bool isSaved) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isSaved
                ? null
                : () {
                    context.read<DailyWordBloc>().add(SaveDailyWordToFavorites(
                          word: word.word,
                          translation: word.translation,
                          fromLanguage: word.language,
                        ));
                  },
            icon: Icon(isSaved ? Icons.star : Icons.star_outline),
            label: Text(isSaved ? 'Saved' : 'Save to Favorites'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSaved ? Colors.grey.shade300 : Color.fromRGBO(0, 51, 102, 1),
              foregroundColor: isSaved ? Colors.grey.shade600 : Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildPreviousWordsSection(List<DailyWordModel> previousWords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Previous Daily Words',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: previousWords.length > 10 ? 10 : previousWords.length,
          itemBuilder: (context, index) {
            final word = previousWords[index];
            return _buildPreviousWordCard(word);
          },
        ),
      ],
    );
  }

  Widget _buildPreviousWordCard(DailyWordModel word) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  word.word,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(0, 51, 102, 1),
                  ),
                ),
              ),
              Text(
                '${word.dateShown.month}/${word.dateShown.day}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            word.translation,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
          if (word.pronunciation != null) ...[
            SizedBox(height: 4),
            Text(
              word.pronunciation!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguagePickerSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? currentSelection;
  final List<Map<String, String>> languages;
  final Color primaryColor;

  const _LanguagePickerSheet({
    required this.title,
    required this.subtitle,
    required this.currentSelection,
    required this.languages,
    required this.primaryColor,
  });

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  late final TextEditingController _search;
  late List<Map<String, String>> _filtered;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _filtered = List<Map<String, String>>.from(widget.languages);
    _search.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _search.removeListener(_applyFilter);
    _search.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = List<Map<String, String>>.from(widget.languages);
      } else {
        _filtered = widget.languages
            .where((m) => (m['label'] ?? '').toLowerCase().contains(q))
            .toList(growable: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            // 80% height max so it never overflows
            maxHeight: media.size.height * 0.82,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.primaryColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.language, color: widget.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search language',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isNotEmpty
                        ? IconButton(
                            onPressed: () => _search.clear(),
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: widget.primaryColor, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No languages found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (ctx, index) {
                          final langMap = _filtered[index];
                          final label = langMap['label'] ?? '';
                          final flag = langMap['flag'] ?? '🏳️';
                          final selected = widget.currentSelection == label;

                          return Material(
                            color: selected
                                ? widget.primaryColor.withValues(alpha: 0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => Navigator.pop(context, label),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 36,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: widget.primaryColor.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        flag,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    if (selected)
                                      Icon(Icons.check_circle, color: widget.primaryColor)
                                    else
                                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
