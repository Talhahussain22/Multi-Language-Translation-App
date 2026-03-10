import 'package:ai_text_to_speech/screen/FavouriteWordTestScreen.dart';
import 'package:ai_text_to_speech/screen/GeneralTestScreen.dart';
import 'package:ai_text_to_speech/screen/GrammarTestScreen.dart';
import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  static const _primary = Color.fromRGBO(0, 51, 102, 1);
  static const _accent  = Color(0xFFFF6B35);

  final List<_TestCardData> _tests = const [
    _TestCardData(
      icon: Icons.menu_book_rounded,
      emoji: '⭐',
      title: 'Favourite Words',
      subtitle: 'Quiz yourself on words you\'ve saved',
      tag: 'Personalized',
      gradientStart: Color(0xFF667EEA),
      gradientEnd: Color(0xFF764BA2),
    ),
    _TestCardData(
      icon: Icons.travel_explore_rounded,
      emoji: '🌍',
      title: 'General Words',
      subtitle: 'Translate English words into your target language',
      tag: 'Vocabulary',
      gradientStart: Color(0xFF003366),
      gradientEnd: Color(0xFF005599),
    ),
    _TestCardData(
      icon: Icons.spellcheck_rounded,
      emoji: '✏️',
      title: 'Grammar Test',
      subtitle: 'Fill in the blank and master grammar rules',
      tag: 'Grammar',
      gradientStart: Color(0xFF11998E),
      gradientEnd: Color(0xFF38EF7D),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ── Premium SliverAppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: _primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF001A40), Color(0xFF003366)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Ambient circles
                    Positioned(
                      top: -30, right: -30,
                      child: Container(
                        width: 160, height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20, left: -20,
                      child: Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _accent.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60, right: 20,
                      child: Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.03),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Icon + label row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _accent.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.psychology_rounded,
                                    color: _accent, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'VOCABULARY & GRAMMAR',
                                style: TextStyle(
                                  color: _accent.withValues(alpha: 0.9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Bold headline
                          const Text(
                            'Test Your\nLanguage Skills',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Stat chips row
                          Wrap(
                            spacing: 8,
                            children: [
                              _StatChip(label: '3 Test Types', icon: Icons.category_rounded),
                              _StatChip(label: 'AI Powered', icon: Icons.auto_awesome_rounded),
                              _StatChip(label: 'Multi-Language', icon: Icons.language_rounded),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Section label
                  Row(
                    children: [
                      Container(
                        width: 3, height: 20,
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Available Tests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Test cards
                  _buildCard(context, _tests[0], () {
                    Navigator.push(context, _route(FavouriteWordTestScreen()));
                  }),
                  const SizedBox(height: 12),
                  _buildCard(context, _tests[1], () {
                    Navigator.push(context, _route(GeneralTestScreen()));
                  }),
                  const SizedBox(height: 12),
                  _buildCard(context, _tests[2], () {
                    Navigator.push(context, _route(GrammarTestScreen()));
                  }),

                  const SizedBox(height: 20),

                  // Ad notice
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'An ad may appear after you finish a test. We never show ads before starting.',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _TestCardData data, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [data.gradientStart, data.gradientEnd],
          ),
          boxShadow: [
            BoxShadow(
              color: data.gradientStart.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Decorative circle
              Positioned(
                right: -20, top: -20,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                right: 20, bottom: -30,
                child: Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Emoji icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(data.emoji,
                            style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              // Tag pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  data.tag,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            data.subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withValues(alpha: 0.7), size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PageRoute _route(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
}

class _TestCardData {
  final IconData icon;
  final String emoji;
  final String title;
  final String subtitle;
  final String tag;
  final Color gradientStart;
  final Color gradientEnd;

  const _TestCardData({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.gradientStart,
    required this.gradientEnd,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Small pill chip used in the hero banner
// ─────────────────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.85)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

