import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/app_dialogs.dart';
import '../bloc/daily_word/daily_word_bloc.dart';
import '../model/daily_word_model.dart';
import '../services/ad_manager.dart';
import '../data/languagedata.dart';

class DailyWordScreen extends StatefulWidget {
  const DailyWordScreen({super.key});

  @override
  State<DailyWordScreen> createState() => _DailyWordScreenState();
}

class _DailyWordScreenState extends State<DailyWordScreen> {
  final _adManager = AdManager();
  String? _nativeLanguage;
  String? _learningLanguage;

  @override
  void initState() {
    super.initState();
    _loadLanguagesAndFetchWord();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adManager.ensureAdsPreloaded();
    });
  }

  // ───────────────── Load / Save Prefs ─────────────────

  Future<void> _loadLanguagesAndFetchWord() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNative = prefs.getString('daily_word_native_language');
    final savedLearning = prefs.getString('daily_word_learning_language');

    if (savedNative != null &&
        savedNative.isNotEmpty &&
        savedLearning != null &&
        savedLearning.isNotEmpty) {
      setState(() {
        _nativeLanguage = savedNative;
        _learningLanguage = savedLearning;
      });
      _dispatchLoad();
    } else {
      _showLanguageSetupDialog();
    }
  }

  void _dispatchLoad() {
    if (_nativeLanguage != null && _learningLanguage != null && mounted) {
      context.read<DailyWordBloc>().add(LoadDailyWord(
            nativeLanguage: _nativeLanguage!,
            learningLanguage: _learningLanguage!,
          ));
    }
  }

  Future<void> _saveLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    if (_nativeLanguage != null) {
      await prefs.setString('daily_word_native_language', _nativeLanguage!);
    }
    if (_learningLanguage != null) {
      await prefs.setString('daily_word_learning_language', _learningLanguage!);
    }
  }

  // ───────────────── Language Setup Dialog ─────────────────

  Future<void> _showLanguageSetupDialog() async {
    final allLanguages = LanguageProvider.LANGUAGES;

    final result = await showModalBottomSheet<_LangPair>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _LanguageSetupWizardSheet(
          languages: allLanguages,
          initialNative: _nativeLanguage,
          initialLearning: _learningLanguage,
        );
      },
    );

    if (!mounted) return;

    if (result == null) {
      // If first-time setup isn't complete, keep prompting.
      if (_nativeLanguage == null || _learningLanguage == null) {
        await Future<void>.delayed(const Duration(milliseconds: 80));
        if (mounted) _showLanguageSetupDialog();
      }
      return;
    }

    setState(() {
      _nativeLanguage = result.native;
      _learningLanguage = result.learning;
    });

    await _saveLanguages();
    _dispatchLoad();
  }

  // ───────────────── Streak helpers ─────────────────

  String _getStreakMessage(int streak) {
    if (streak >= 30) return 'Amazing dedication! 🌟';
    if (streak >= 14) return 'Two weeks strong! 💎';
    if (streak >= 7) return 'One week streak! 🔥';
    if (streak >= 3) return 'Nice start! 💪';
    if (streak == 1) return 'Great beginning! 🚀';
    return 'Keep it up! 📚';
  }

  // ───────────────── Build ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
        title: const Text('Daily Word',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageSetupDialog,
            tooltip: 'Change Languages',
          ),
        ],
      ),
      body: BlocConsumer<DailyWordBloc, DailyWordState>(
        listener: (context, state) {
          if (state is DailyWordError) {
            AppDialogs.showApiError(
              context,
              title: 'Daily Word failed to load',
              error: state.message,
              onRetry: _dispatchLoad,
            );
          }
        },
        builder: (context, state) {
          if (state is DailyWordLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: Color.fromRGBO(0, 51, 102, 1)),
                  SizedBox(height: 16),
                  Text('Loading today\'s word…',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          if (state is DailyWordError) {
            // Keep a lightweight fallback UI; dialog is shown via listener.
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    const Text('Can’t load Daily Word',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(AppDialogs.prettyError(state.message),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _dispatchLoad,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DailyWordLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                if (_nativeLanguage != null && _learningLanguage != null) {
                  context.read<DailyWordBloc>().add(RefreshDailyWord(
                        nativeLanguage: _nativeLanguage!,
                        learningLanguage: _learningLanguage!,
                      ));
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Language badge
                    _buildLanguageBadge(),
                    const SizedBox(height: 12),
                    _buildStreakCard(
                        state.currentStreak, state.longestStreak),
                    const SizedBox(height: 20),
                    _buildDailyWordCard(state.currentWord, state.isSaved),
                    const SizedBox(height: 20),
                    _buildActionButtons(state.currentWord, state.isSaved),
                    const SizedBox(height: 32),
                    if (state.previousWords.isNotEmpty)
                      _buildPreviousWordsSection(state.previousWords),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Welcome to Daily Word!'));
        },
      ),
    );
  }

  // ───────────────── Language Badge ─────────────────

  Widget _buildLanguageBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 51, 102, 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color.fromRGBO(0, 51, 102, 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz,
              size: 20, color: Color.fromRGBO(0, 51, 102, 1)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_nativeLanguage ?? '?'} → ${_learningLanguage ?? '?'}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(0, 51, 102, 1),
              ),
            ),
          ),
          GestureDetector(
            onTap: _showLanguageSetupDialog,
            child: Text(
              'Change',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── Streak Card ─────────────────

  Widget _buildStreakCard(int currentStreak, int longestStreak) {
    final dayLabel = currentStreak == 1 ? 'Day' : 'Days';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: currentStreak >= 7
              ? [const Color(0xFFFF6B35), const Color(0xFFF7931E)]
              : currentStreak >= 3
                  ? [const Color(0xFF43A047), const Color(0xFF66BB6A)]
                  : [const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (currentStreak >= 7
                    ? const Color(0xFFFF6B35)
                    : currentStreak >= 3
                        ? const Color(0xFF43A047)
                        : const Color(0xFF1E88E5))
                .withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              currentStreak >= 7
                  ? '🔥'
                  : currentStreak >= 3
                      ? '⚡'
                      : '📖',
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak $dayLabel Streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStreakMessage(currentStreak),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14),
                ),
                if (longestStreak > currentStreak) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Best: $longestStreak days',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── Daily Word Card ─────────────────

  Widget _buildDailyWordCard(DailyWordModel word, bool isSaved) {
    final native = _nativeLanguage ?? ((word.nativeLanguage ?? '').trim().isNotEmpty ? word.nativeLanguage!.trim() : 'English');
    final learning = _learningLanguage ?? word.language;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word Header — word is in the LEARNING language
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        learning,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      word.word,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(0, 51, 102, 1),
                      ),
                    ),
                    if (word.pronunciation != null &&
                        word.pronunciation!.isNotEmpty) ...[
                      const SizedBox(height: 4),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Meaning in native language
          _buildSection(
            icon: Icons.translate,
            title: 'Meaning in $native',
            content: word.translation,
            color: const Color.fromRGBO(0, 51, 102, 1),
          ),

          // Definition in native language
          if (word.englishMeaning.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSection(
              icon: Icons.menu_book_outlined,
              title: 'Definition ($native)',
              content: word.englishMeaning,
              color: Colors.purple.shade700,
            ),
          ],

          const SizedBox(height: 20),

          // Example in learning language
          _buildSection(
            icon: Icons.format_quote,
            title: 'Example ($learning)',
            content: word.exampleSentenceEnglish,
            color: Colors.blue.shade700,
          ),

          // Meaning of the example in native language
          if (word.exampleSentenceLearning.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.subdirectory_arrow_right,
                      color: Colors.teal.shade600, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meaning ($native)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          word.exampleSentenceLearning,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.teal.shade900,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Synonyms (in learning language)
          if (word.synonyms.isNotEmpty) ...[
            _buildListSection(
              icon: Icons.thumb_up_outlined,
              title: 'Synonyms ($learning)',
              items: word.synonyms,
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 20),
          ],

          // Antonyms (in learning language)
          if (word.antonyms.isNotEmpty)
            _buildListSection(
              icon: Icons.thumb_down_outlined,
              title: 'Antonyms ($learning)',
              items: word.antonyms,
              color: Colors.red.shade700,
            ),
        ],
      ),
    );
  }

  // ───────────────── Reusable section widgets ─────────────────

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
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((item) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ───────────────── Action Buttons ─────────────────

  Widget _buildActionButtons(DailyWordModel word, bool isSaved) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isSaved
                ? null
                : () {
                    context
                        .read<DailyWordBloc>()
                        .add(SaveDailyWordToFavorites(
                          word: word.word,
                          translation: word.translation,
                          fromLanguage: word.language,
                        ));
                  },
            icon: Icon(isSaved ? Icons.star : Icons.star_outline),
            label: Text(isSaved ? 'Saved' : 'Save to Favorites'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSaved
                  ? Colors.grey.shade300
                  : const Color.fromRGBO(0, 51, 102, 1),
              foregroundColor:
                  isSaved ? Colors.grey.shade600 : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────── Previous Words ─────────────────

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
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
    final native = _nativeLanguage ?? ((word.nativeLanguage ?? '').trim().isNotEmpty ? word.nativeLanguage!.trim() : 'English');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(0, 51, 102, 1),
                  ),
                ),
              ),
              Text(
                '${word.dateShown.month}/${word.dateShown.day}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          if (word.pronunciation != null &&
              word.pronunciation!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              word.pronunciation!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (word.englishMeaning.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              word.englishMeaning,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$native: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromRGBO(0, 51, 102, 0.8),
                ),
              ),
              Expanded(
                child: Text(
                  word.translation,
                  style:
                      TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Reusable Language Picker Bottom Sheet
// ═══════════════════════════════════════════════════════════════

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
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: media.size.height * 0.82),
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
                        color: widget.primaryColor
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.language,
                          color: widget.primaryColor),
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
                      icon: Icon(Icons.close,
                          color: Colors.grey.shade700),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: widget.primaryColor, width: 2),
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
                          style:
                              TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            8, 6, 8, 16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 6),
                        itemBuilder: (ctx, index) {
                          final langMap = _filtered[index];
                          final label = langMap['label'] ?? '';
                          final flag = langMap['flag'] ?? '🏳️';
                          final selected =
                              widget.currentSelection == label;

                          return Material(
                            color: selected
                                ? widget.primaryColor
                                    .withValues(alpha: 0.08)
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(14),
                              onTap: () =>
                                  Navigator.pop(context, label),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 36,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: widget.primaryColor
                                            .withValues(
                                                alpha: 0.10),
                                        borderRadius:
                                            BorderRadius.circular(
                                                12),
                                      ),
                                      child: Text(flag,
                                          style:
                                              const TextStyle(
                                                  fontSize: 18)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: selected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: Colors
                                              .grey.shade800,
                                        ),
                                      ),
                                    ),
                                    if (selected)
                                      Icon(Icons.check_circle,
                                          color: widget
                                              .primaryColor)
                                    else
                                      Icon(Icons.chevron_right,
                                          color: Colors
                                              .grey.shade400),
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
      ));
  }
}

// ──────────────────────────────────────────────────────────────────────────────────────
// New Language Setup Wizard Sheet (Stepper)
// ──────────────────────────────────────────────────────────────────────────────────────

class _LanguageSetupWizardSheet extends StatefulWidget {
  final List<Map<String, String>> languages;
  final String? initialNative;
  final String? initialLearning;

  const _LanguageSetupWizardSheet({
    required this.languages,
    this.initialNative,
    this.initialLearning,
  });

  @override
  State<_LanguageSetupWizardSheet> createState() =>
      _LanguageSetupWizardSheetState();
}

class _LanguageSetupWizardSheetState
    extends State<_LanguageSetupWizardSheet> {
  late String _nativeLanguage;
  late String _learningLanguage;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _nativeLanguage = widget.initialNative ?? '';
    _learningLanguage = widget.initialLearning ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;

    final canGoNext = _currentStep == 0
        ? _nativeLanguage.trim().isNotEmpty
        : _learningLanguage.trim().isNotEmpty;

    final isLastStep = _currentStep == 1;

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
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: media.size.height * 0.86),
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
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.language, color: Color(0xFF2E7D32)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Set up your learning',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This helps us show meanings in the language you know and words in the language you want to learn.',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.2),
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
                const SizedBox(height: 8),

                // Stepper area
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context)
                          .colorScheme
                          .copyWith(primary: const Color(0xFF2E7D32)),
                    ),
                    child: Stepper(
                      type: StepperType.vertical,
                      currentStep: _currentStep,
                      controlsBuilder: (_, __) => const SizedBox.shrink(),
                      onStepTapped: (step) => setState(() => _currentStep = step),
                      steps: [
                        Step(
                          title: const Text('I already know'),
                          subtitle: Text(_nativeLanguage.isEmpty ? 'Choose your comfortable language' : _nativeLanguage),
                          content: _buildPickTile(
                            title: 'Native language',
                            value: _nativeLanguage.isEmpty ? 'Tap to choose' : _nativeLanguage,
                            icon: Icons.person,
                            color: const Color.fromRGBO(0, 51, 102, 1),
                            onTap: () async {
                              final picked = await _pickLanguage(
                                context,
                                title: 'Native language',
                                subtitle: 'Meanings and explanations will be shown in this language.',
                                current: _nativeLanguage.isEmpty ? null : _nativeLanguage,
                                exclude: const [],
                                primaryColor: const Color.fromRGBO(0, 51, 102, 1),
                              );
                              if (picked != null) {
                                setState(() {
                                  _nativeLanguage = picked;
                                  if (_learningLanguage == picked) {
                                    _learningLanguage = '';
                                  }
                                });
                              }
                            },
                          ),
                          isActive: _currentStep == 0,
                          state: _nativeLanguage.isNotEmpty ? StepState.complete : StepState.indexed,
                        ),
                        Step(
                          title: const Text('I want to learn'),
                          subtitle: Text(_learningLanguage.isEmpty ? 'Choose your target language' : _learningLanguage),
                          content: _buildPickTile(
                            title: 'Learning language',
                            value: _learningLanguage.isEmpty ? 'Tap to choose' : _learningLanguage,
                            icon: Icons.school,
                            color: const Color(0xFF2E7D32),
                            onTap: () async {
                              final picked = await _pickLanguage(
                                context,
                                title: 'Learning language',
                                subtitle: 'Daily words, examples, synonyms & antonyms will be in this language.',
                                current: _learningLanguage.isEmpty ? null : _learningLanguage,
                                exclude: _nativeLanguage.isEmpty ? const [] : <String>[_nativeLanguage],
                                primaryColor: const Color(0xFF2E7D32),
                              );
                              if (picked != null) {
                                setState(() {
                                  _learningLanguage = picked;
                                });
                              }
                            },
                          ),
                          isActive: _currentStep == 1,
                          state: _learningLanguage.isNotEmpty ? StepState.complete : StepState.indexed,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom action bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: _currentStep == 0
                            ? () => Navigator.pop(context)
                            : () => setState(() => _currentStep--),
                        child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: canGoNext
                            ? () {
                                if (!isLastStep) {
                                  setState(() => _currentStep++);
                                  return;
                                }
                                if (_nativeLanguage.trim().isEmpty || _learningLanguage.trim().isEmpty) return;
                                Navigator.pop(
                                  context,
                                  _LangPair(_nativeLanguage.trim(), _learningLanguage.trim()),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isLastStep ? 'Save' : 'Next'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.22)),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _pickLanguage(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String? current,
    required List<String> exclude,
    required Color primaryColor,
  }) async {
    final list = widget.languages
        .where((m) => !exclude.contains(m['label']))
        .toList(growable: false);

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LanguagePickerSheet(
        title: title,
        subtitle: subtitle,
        currentSelection: current,
        languages: list,
        primaryColor: primaryColor,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────────────
// Language Pair Class for Returning from Bottom Sheet
// ──────────────────────────────────────────────────────────────────────────────────────

class _LangPair {
  final String native;
  final String learning;

  _LangPair(this.native, this.learning);
}
