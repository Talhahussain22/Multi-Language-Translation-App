import 'dart:async';
import 'package:ai_text_to_speech/screen/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────────────
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _progressController;

  // ── Logo animations ────────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoY;

  // ── Text animations ────────────────────────────────────────────────
  late final Animation<double> _textOpacity;
  late final Animation<double> _textY;

  // ── Progress bar ───────────────────────────────────────────────────
  late final Animation<double> _progress;

  // ── Color constants ────────────────────────────────────────────────
  static const _bgTop    = Color(0xFF001A40);   // deep navy
  static const _bgBottom = Color(0xFF003366);   // rich blue
  static const _accent   = Color(0xFFFF6B35);   // vibrant orange
  static const _gold     = Color(0xFFFFD700);   // gold highlight

  Timer? _textDelayTimer;
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();

    // Make status bar transparent to blend with gradient
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // ── Logo: scale + fade + slide up ─────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _logoY = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // ── Text: fade + slide up (delayed) ───────────────────────────────
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textY = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // ── Progress bar ───────────────────────────────────────────────────
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // ── Sequence ───────────────────────────────────────────────────────
    _logoController.forward();
    _textDelayTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
        _progressController.forward();
      }
    });

    // Navigate after animations complete
    _navigateTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => Dashboard(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _textDelayTimer?.cancel();
    _navigateTimer?.cancel();
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgTop, _bgBottom],
            stops: [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative circles (ambient glow) ──────────────────────────
            Positioned(
              top: -size.width * 0.3,
              right: -size.width * 0.2,
              child: _GlowCircle(
                size: size.width * 0.75,
                color: _accent.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.2,
              left: -size.width * 0.25,
              child: _GlowCircle(
                size: size.width * 0.65,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
            Positioned(
              top: size.height * 0.35,
              left: -size.width * 0.15,
              child: _GlowCircle(
                size: size.width * 0.35,
                color: _gold.withValues(alpha: 0.05),
              ),
            ),

            // ── Main content ────────────────────────────────────────────────
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Logo icon
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _logoY.value),
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: _LogoWidget(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // App name + tagline
                AnimatedBuilder(
                  animation: _textController,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _textY.value),
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: Column(
                        children: [
                          // App name
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Lang',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                    height: 1,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Rush',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: _accent,
                                    letterSpacing: -1,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Tagline
                          Text(
                            'Master languages. One word at a time.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Progress bar ──────────────────────────────────────────────
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (_, __) => Opacity(
                    opacity: _textOpacity.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _progress.value,
                              minHeight: 3,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.lerp(_accent, _gold, _progress.value)!,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium logo widget — globe + translate icon layered
// ─────────────────────────────────────────────────────────────────────────────
class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B35), Color(0xFFFF3D00)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.45),
            blurRadius: 35,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.translate_rounded,
        size: 54,
        color: Colors.white,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Decorative ambient glow circle
// ─────────────────────────────────────────────────────────────────────────────
class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
