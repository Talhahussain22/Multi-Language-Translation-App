import 'package:ai_text_to_speech/bloc/grammarTestBloc/grammar_test_bloc.dart';
import 'package:ai_text_to_speech/screen/GrammarQuizScreen.dart';
import 'package:ai_text_to_speech/services/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GrammarTestScreen extends StatefulWidget {
  const GrammarTestScreen({super.key});

  @override
  State<GrammarTestScreen> createState() => _GrammarTestScreenState();
}

class _GrammarTestScreenState extends State<GrammarTestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedPracticeMode = 'Identify Part of Speech';
  String _selectedSpecificType = 'Nouns';
  final _adManager = AdManager();

  // Practice Modes
  final List<Map<String, dynamic>> _practiceModes = [
    {
      'name': 'Identify Part of Speech',
      'description': 'See a marked word in a sentence and identify which part of speech it is',
      'icon': Icons.search,
      'color': Color(0xFF2196F3),
    },
    {
      'name': 'Fill Correct Part of Speech',
      'description': 'Fill in the blank with the correct part of speech word',
      'icon': Icons.edit_note,
      'color': Color(0xFF4CAF50),
    },
  ];

  // Specific Parts of Speech
  final List<Map<String, dynamic>> _specificTypes = [
    {'name': 'Nouns', 'icon': Icons.person, 'color': Color(0xFFE91E63)},
    {'name': 'Verbs', 'icon': Icons.directions_run, 'color': Color(0xFF9C27B0)},
    {'name': 'Adjectives', 'icon': Icons.palette, 'color': Color(0xFF3F51B5)},
    {'name': 'Adverbs', 'icon': Icons.speed, 'color': Color(0xFF00BCD4)},
    {'name': 'Pronouns', 'icon': Icons.people, 'color': Color(0xFF009688)},
    {'name': 'Prepositions', 'icon': Icons.compare_arrows, 'color': Color(0xFF8BC34A)},
    {'name': 'Conjunctions', 'icon': Icons.link, 'color': Color(0xFFFF5722)},
    {'name': 'Interjections', 'icon': Icons.chat_bubble, 'color': Color(0xFF795548)},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Preload ads when user enters this screen to prepare for test completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adManager.ensureAdsPreloaded();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Grammar Practice',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: const [
            Tab(text: 'General Practice'),
            Tab(text: 'Focused Practice'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralPracticeTab(),
          _buildFocusedPracticeTab(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _startPractice,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(0, 51, 102, 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text(
                  'Start Practice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _startPractice() {
    final isGeneralTab = _tabController.index == 0;
    final testType = isGeneralTab ? _selectedPracticeMode : 'Focused: $_selectedSpecificType';

    context.read<GrammarTestBloc>().add(GrammarTestStarted(
      language: 'English',  // Always English
      testType: testType,
      count: '15',  // Always 15 questions
    ));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrammarQuizScreen(
          language: 'English',
          testType: testType,
          totalQuestions: 15,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // General Practice Tab - Mixed practice modes
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGeneralPracticeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(0, 51, 102, 0.1),
                  const Color.fromRGBO(0, 51, 102, 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color.fromRGBO(0, 51, 102, 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 51, 102, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Practice Grammar Skills',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(0, 51, 102, 1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose your practice mode and start learning',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Practice Mode Selection
          _label('Select Practice Mode'),
          const SizedBox(height: 12),
          ...List.generate(_practiceModes.length, (index) {
            final mode = _practiceModes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPracticeModeCard(
                name: mode['name'],
                description: mode['description'],
                icon: mode['icon'],
                color: mode['color'],
                isSelected: _selectedPracticeMode == mode['name'],
                onTap: () => setState(() => _selectedPracticeMode = mode['name']),
              ),
            );
          }),


          const SizedBox(height: 24),

          // Info Box
          _buildInfoBox(_selectedPracticeMode),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Focused Practice Tab - Specific parts of speech
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFocusedPracticeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF9800).withValues(alpha: 0.1),
                  const Color(0xFFFF9800).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.track_changes, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Master Specific Types',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Focus on one part of speech at a time',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Part of Speech Grid
          _label('Choose Part of Speech'),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: _specificTypes.length,
            itemBuilder: (context, index) {
              final type = _specificTypes[index];
              final isSelected = _selectedSpecificType == type['name'];
              return _buildSpecificTypeCard(
                name: type['name'],
                icon: type['icon'],
                color: type['color'],
                isSelected: isSelected,
                onTap: () => setState(() => _selectedSpecificType = type['name']),
              );
            },
          ),


          const SizedBox(height: 24),

          // Info about selected type
          _buildSpecificTypeInfo(_selectedSpecificType),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // UI Helper Widgets
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPracticeModeCard({
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color.fromRGBO(0, 51, 102, 1) : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 51, 102, 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color.fromRGBO(0, 51, 102, 1)
                          : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(0, 51, 102, 1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificTypeCard({
    required String name,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 40),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String practiceMode) {
    final infoMap = {
      'Identify Part of Speech': {
        'icon': Icons.info_outline,
        'color': const Color(0xFF2196F3),
        'points': [
          'See a sentence with a highlighted word',
          'Identify which part of speech it is',
          'Options: Noun, Verb, Adjective, Adverb, etc.',
          'Learn with educational hints',
          '15 questions in English',
        ],
      },
      'Fill Correct Part of Speech': {
        'icon': Icons.info_outline,
        'color': const Color(0xFF4CAF50),
        'points': [
          'Read sentences with a blank space',
          'Choose the correct part of speech word',
          'Options: 4 words of the same type',
          'Practice grammar in context',
          '15 questions in English',
        ],
      },
    };

    final info = infoMap[practiceMode]!;
    final Color infoColor = info['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: infoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: infoColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(info['icon'] as IconData, color: infoColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'What to Expect',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(info['points'] as List<String>).map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: infoColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSpecificTypeInfo(String type) {
    final infoMap = {
      'Nouns': 'Person, place, thing, or idea. Examples: teacher, city, book, happiness',
      'Verbs': 'Action or state of being. Examples: run, think, is, become',
      'Adjectives': 'Describes nouns. Examples: beautiful, large, happy, red',
      'Adverbs': 'Modifies verbs, adjectives, or other adverbs. Examples: quickly, very, often',
      'Pronouns': 'Replaces nouns. Examples: he, she, it, they, who',
      'Prepositions': 'Shows relationships. Examples: in, on, at, under, between',
      'Conjunctions': 'Connects words or phrases. Examples: and, but, or, because',
      'Interjections': 'Expresses emotion. Examples: wow, ouch, hey, hurray',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              Text(
                type,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            infoMap[type] ?? '',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.3,
        ),
      );
}
