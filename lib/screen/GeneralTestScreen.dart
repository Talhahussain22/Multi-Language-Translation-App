import 'package:ai_text_to_speech/data/languagedata.dart';
import 'package:ai_text_to_speech/screen/GeneralWordQuizScreen.dart';
import 'package:ai_text_to_speech/screen/components/app_banner_ad.dart';
import 'package:ai_text_to_speech/screen/components/language_picker_sheet.dart';
import 'package:ai_text_to_speech/services/ad_manager.dart';
import 'package:ai_text_to_speech/services/usage_limit_service.dart';
import 'package:ai_text_to_speech/Utils/app_dialogs.dart';
import 'package:flutter/material.dart';

class GeneralTestScreen extends StatefulWidget {
  const GeneralTestScreen({super.key});

  @override
  State<GeneralTestScreen> createState() => _GeneralTestScreenState();
}

class _GeneralTestScreenState extends State<GeneralTestScreen> {
  static const _primary = Color.fromRGBO(0, 51, 102, 1);

  // ── All languages including English for the quiz ──
  final List<Map<String, String>> _allLanguages = LanguageProvider.LANGUAGES;

  late Map<String, String> _selectedLanguage;
  String _difficulty = 'Easy';
  String _count = '10';
  final _adManager   = AdManager();
  final _usageLimits = UsageLimitService();

  final List<Map<String, dynamic>> _difficulties = [
    {'label': 'Easy', 'icon': '🌱', 'desc': 'Common everyday words'},
    {'label': 'Low Medium', 'icon': '📗', 'desc': 'Familiar vocabulary'},
    {'label': 'Medium', 'icon': '📘', 'desc': 'Less common words'},
    {'label': 'High', 'icon': '🎯', 'desc': 'Rare & academic words'},
  ];

  final List<String> _counts = ['5', '10', '15', '20', '30'];

  bool get _isEnglishMode =>
      _selectedLanguage['label']?.toLowerCase() == 'english';

  @override
  void initState() {
    super.initState();
    // Default to first non-English language
    _selectedLanguage = _allLanguages.firstWhere(
      (l) => l['label']?.toLowerCase() != 'english',
      orElse: () => _allLanguages.first,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adManager.ensureAdsPreloaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar: const AppBannerAd(),
      appBar: AppBar(
        backgroundColor: _primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'General Words Quiz',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Language to learn ───────────────────────────────────────────
            _SectionHeader(
              icon: Icons.translate_rounded,
              label: 'Language to Learn',
            ),
            const SizedBox(height: 10),
            _LanguageSelectorCard(
              language: _selectedLanguage,
              onTap: () => _pickLanguage(),
            ),

            const SizedBox(height: 22),

            // ── Difficulty ──────────────────────────────────────────────────
            _SectionHeader(
              icon: Icons.bar_chart_rounded,
              label: 'Difficulty Level',
            ),
            const SizedBox(height: 10),
            ...(_difficulties.map((d) => _DifficultyTile(
                  label: d['label'] as String,
                  icon: d['icon'] as String,
                  desc: d['desc'] as String,
                  selected: _difficulty == d['label'],
                  onTap: () => setState(() => _difficulty = d['label']),
                ))),

            const SizedBox(height: 22),

            // ── Number of questions ─────────────────────────────────────────
            _SectionHeader(
              icon: Icons.quiz_rounded,
              label: 'Number of Questions',
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _counts
                    .map((c) => _CountChip(
                          count: c,
                          selected: _count == c,
                          onTap: () => setState(() => _count = c),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 36),

            // ── Start button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  shadowColor: _primary.withValues(alpha: 0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Start Quiz  ·  ${_selectedLanguage['flag']}  ${_selectedLanguage['label']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLanguage() async {
    final picked = await showLanguagePicker(
      context: context,
      languages: _allLanguages,
      selected: _selectedLanguage,
      title: 'Language to Learn',
    );
    if (picked != null) setState(() => _selectedLanguage = picked);
  }

  void _startQuiz() async {
    final canGenerate = await _usageLimits.canGenerateQuiz();
    if (!canGenerate) {
      if (!mounted) return;
      _showQuizLimitDialog();
      return;
    }
    await _usageLimits.recordQuizGeneration();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneralWordQuizScreen(
          selectedfromLanguage: 'English',
          selectedtoLanguage: _selectedLanguage['label']!,
          selecteddifficultyLevel: _difficulty,
          selectedMcqsCount: _count,
        ),
      ),
    );
  }

  void _showQuizLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock, color: Color(0xFFFF6B35)),
            SizedBox(width: 10),
            Text('Quiz Limit Reached', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have used all ${UsageLimitService.dailyQuizLimit} free quiz generations for today.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Text(
              'Watch a short ad to unlock 1 more quiz, or come back tomorrow.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_circle_fill, size: 18),
            label: const Text('Watch Ad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003366),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _adManager.showRewardedAd(
                onRewardEarned: () => _usageLimits.grantRewardedQuiz(),
                onAdDismissed: () {
                  if (mounted) {
                    AppDialogs.showSnack(context,
                        message: '1 quiz generation unlocked!',
                        background: Colors.green);
                    _startQuiz();
                  }
                },
                onAdFailed: () {
                  if (mounted) {
                    AppDialogs.showSnack(context,
                        message: 'Ad not available. Try again later.',
                        background: Colors.redAccent);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────



class _InfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.75),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color.fromRGBO(0, 51, 102, 0.7)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color.fromRGBO(0, 51, 102, 1),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _LanguageSelectorCard extends StatelessWidget {
  final Map<String, String> language;
  final VoidCallback onTap;
  const _LanguageSelectorCard(
      {required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnglish = language['label']?.toLowerCase() == 'english';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromRGBO(0, 51, 102, 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 51, 102, 0.07),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  language['flag'] ?? '🌐',
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language['label'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 51, 102, 1),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isEnglish
                        ? 'Guess the definition of English words'
                        : 'Guess the ${language['label']} translation',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 51, 102, 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(0, 51, 102, 1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Color.fromRGBO(0, 51, 102, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final String label;
  final String icon;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyTile({
    required this.label,
    required this.icon,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromRGBO(0, 51, 102, 1)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color.fromRGBO(0, 51, 102, 1)
                : Colors.grey.shade200,
            width: selected ? 0 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 51, 102, 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.75)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String count;
  final bool selected;
  final VoidCallback onTap;

  const _CountChip({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromRGBO(0, 51, 102, 1)
              : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? const Color.fromRGBO(0, 51, 102, 1)
                : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 51, 102, 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          count,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
