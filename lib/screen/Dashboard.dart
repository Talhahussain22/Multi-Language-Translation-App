import 'package:ai_text_to_speech/screen/FavouritePage.dart';
import 'package:ai_text_to_speech/screen/Homepage.dart';
import 'package:ai_text_to_speech/screen/SettingsScreen.dart';
import 'package:ai_text_to_speech/screen/DailyWordScreen.dart';
import 'package:ai_text_to_speech/screen/TestPage.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int selectedIndex = 2;

  static const _primary = Color.fromRGBO(0, 51, 102, 1);
  static const _accent  = Color(0xFFFF6B35);

  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.psychology_rounded,    activeIcon: Icons.psychology,          label: 'Test'),
    _NavItem(icon: Icons.auto_stories_outlined, activeIcon: Icons.auto_stories,        label: 'Daily'),
    _NavItem(icon: Icons.translate_rounded,     activeIcon: Icons.translate_rounded,   label: ''),
    _NavItem(icon: Icons.favorite_border,       activeIcon: Icons.favorite,            label: 'Saved'),
    _NavItem(icon: Icons.settings_outlined,     activeIcon: Icons.settings,            label: 'Settings'),
  ];

  final List<Widget> _pages = [
    TestPage(),
    DailyWordScreen(),
    HomePage(),
    Favouritepage(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: IndexedStack(index: selectedIndex, children: _pages),
        bottomNavigationBar: _PremiumNavBar(
          items: _items,
          selectedIndex: selectedIndex,
          onTap: (i) => setState(() => selectedIndex = i),
          primary: _primary,
          accent: _accent,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class for nav items
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium floating bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color primary;
  final Color accent;

  const _PremiumNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    required this.primary,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isCenter = i == 2;
              final isSelected = i == selectedIndex;

              if (isCenter) {
                return _CenterButton(
                  icon: item.activeIcon,
                  isSelected: isSelected,
                  primary: primary,
                  accent: accent,
                  onTap: () => onTap(i),
                );
              }

              return _NavButton(
                item: item,
                isSelected: isSelected,
                primary: primary,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final Color primary;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 6 : 0),
                decoration: isSelected
                    ? BoxDecoration(
                        color: primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      )
                    : null,
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: isSelected ? primary : Colors.grey.shade400,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? primary : Colors.grey.shade400,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color primary;
  final Color accent;
  final VoidCallback onTap;

  const _CenterButton({
    required this.icon,
    required this.isSelected,
    required this.primary,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [accent, const Color(0xFFFF3D00)]
                  : [primary, const Color(0xFF005599)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isSelected ? accent : primary).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}