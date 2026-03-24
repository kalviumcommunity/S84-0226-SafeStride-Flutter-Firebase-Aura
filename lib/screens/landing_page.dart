import 'package:flutter/material.dart';
import 'login/login_screen.dart';
import 'signup_screen.dart';

// ═══════════════════════════════════════════════════════════════
//  SAFE STRIDE — LANDING PAGE
// ═══════════════════════════════════════════════════════════════

const _kGreen = Color(0xFF6EEB5F);
const _kGreenDark = Color(0xFF5EDC4A);
const _kBg = Color(0xFFF5F7FA);
const _kBg2 = Color(0xFFE8EEF5);
const _kDark = Color(0xFF1A2035);
const _kGrey = Color(0xFF8494A9);
const _kCard = Colors.white;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  int _selectedMode = 0; // 0=Runner, 1=Cyclist
  bool _navScrolled = false;

  // staggered entry animations
  late AnimationController _heroAnim;
  late AnimationController _featAnim;
  late AnimationController _howAnim;
  late AnimationController _proofAnim;
  late AnimationController _ctaAnim;

  // map grid animation
  late AnimationController _gridAnim;

  @override
  void initState() {
    super.initState();

    _heroAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _featAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _howAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _proofAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ctaAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _gridAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final y = _scrollController.offset;
    if (y > 20 && !_navScrolled) setState(() => _navScrolled = true);
    if (y < 20 && _navScrolled) setState(() => _navScrolled = false);

    // Trigger section animations based on scroll position
    if (y > 350 && !_featAnim.isCompleted) _featAnim.forward();
    if (y > 850 && !_howAnim.isCompleted) _howAnim.forward();
    if (y > 1350 && !_proofAnim.isCompleted) _proofAnim.forward();
    if (y > 1800 && !_ctaAnim.isCompleted) _ctaAnim.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroAnim.dispose();
    _featAnim.dispose();
    _howAnim.dispose();
    _proofAnim.dispose();
    _ctaAnim.dispose();
    _gridAnim.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  Widget _buildNav() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: _navScrolled
            ? Colors.white.withOpacity(0.88)
            : Colors.transparent,
        boxShadow: _navScrolled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kGreen,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _kGreen.withOpacity(0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_run_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Safe Stride',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kDark,
                ),
              ),
            ],
          ),
          // Nav links (hidden on small screens)
          LayoutBuilder(
            builder: (context, constraints) {
              if (MediaQuery.of(context).size.width < 600) {
                return _buildNavCta();
              }
              return Row(
                children: [
                  _navLink('Features'),
                  _navLink('How It Works'),
                  _navLink('Community'),
                  const SizedBox(width: 20),
                  _buildNavCta(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navLink(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Text(
      label,
      style: const TextStyle(
        color: _kGrey,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _buildNavCta() => GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withOpacity(0.40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'Get Started',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    ),
  );

  // ── Hero ───────────────────────────────────────────────────────────────────
  Widget _buildHero() {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(28, isMobile ? 80 : 100, 28, 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kBg, _kBg2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Animated grid background
          Positioned.fill(child: _AnimatedGrid(animation: _gridAnim)),

          // Content
          if (isMobile)
            _heroMobile()
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: _heroText()),
                const SizedBox(width: 40),
                Expanded(flex: 4, child: _heroMockup()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _heroMobile() {
    return Column(
      children: [_heroText(), const SizedBox(height: 40), _heroMockup()],
    );
  }

  Widget _heroText() {
    final a = _heroAnim;
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToggle(),
            const SizedBox(height: 32),
            const Text(
              'Run Safe.\nRide Smart.',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: _kDark,
                height: 1.12,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Discover safer routes with real-time\nsafety insights on every stride.',
              style: TextStyle(
                fontSize: 17,
                color: _kGrey,
                height: 1.65,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 36),
            Wrap(
              spacing: 14,
              runSpacing: 12,
              children: [
                _primaryBtn('Get Started', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }),
                _secondaryBtn('Create Account', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                }),
              ],
            ),
            const SizedBox(height: 28),
            _buildTrustBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_pill('🏃 Runner', 0), _pill('🚴 Cyclist', 1)],
      ),
    );
  }

  Widget _pill(String label, int index) {
    final active = _selectedMode == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _kGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _kGreen.withOpacity(0.40),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: active ? Colors.white : _kGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge() {
    return Row(
      children: [
        _starRow(5),
        const SizedBox(width: 10),
        const Text(
          '10,000+ safe striders',
          style: TextStyle(
            color: _kGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _starRow(int count) => Row(
    children: List.generate(
      count,
      (_) => const Icon(Icons.star_rounded, color: Color(0xFFFFAA00), size: 16),
    ),
  );

  Widget _heroMockup() {
    return FadeTransition(
      opacity: _heroAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _heroAnim, curve: Curves.easeOut)),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            child: _buildRouteCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withOpacity(0.14),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini map placeholder
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFECF0F8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                const _MiniMapLines(),
                Positioned(
                  top: 24,
                  left: 24,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.place_rounded,
                      color: _kGreen,
                      size: 18,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _kGreen,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: _kGreen.withOpacity(0.45),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Text(
                      '95% Safe',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.directions_run_rounded,
                color: _kGreen,
                size: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                'Riverside Trail',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _kDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _kGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Runner',
                  style: TextStyle(
                    color: _kGreenDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _safeChip(Icons.wb_twilight_rounded, 'Excellent Lighting'),
              _safeChip(Icons.people_outline_rounded, 'Low Crowd'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _safeChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F6FB),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: const Color(0xFFE4E9F2), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _kGreen),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _kGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  // ── Features ───────────────────────────────────────────────────────────────
  Widget _buildFeatures() {
    return _FadeInSection(
      animation: _featAnim,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 28),
        child: Column(
          children: [
            _sectionLabel('Why Safe Stride?'),
            const SizedBox(height: 12),
            const Text(
              'Everything you need\nto stride with confidence.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: _kDark,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                final cards = [
                  _FeatureCard(
                    icon: Icons.verified_user_rounded,
                    title: 'Safety Score',
                    body:
                        'Instant route safety rating based on lighting, traffic, and crowd data.',
                    delay: 0,
                    animation: _featAnim,
                  ),
                  _FeatureCard(
                    icon: Icons.nights_stay_rounded,
                    title: 'Smart Lighting',
                    body:
                        'Find well-lit routes for early morning or night workouts.',
                    delay: 100,
                    animation: _featAnim,
                  ),
                  _FeatureCard(
                    icon: Icons.location_on_rounded,
                    title: 'Live Route Discovery',
                    body:
                        'Live crowd & traffic indicators powered by community data.',
                    delay: 200,
                    animation: _featAnim,
                  ),
                ];
                if (isMobile) {
                  return Column(
                    children: cards
                        .map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: c,
                          ),
                        )
                        .toList(),
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cards
                      .map(
                        (c) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: c,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── How It Works ───────────────────────────────────────────────────────────
  Widget _buildHowItWorks() {
    return _FadeInSection(
      animation: _howAnim,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kBg, _kBg2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _sectionLabel('Simple Process'),
            const SizedBox(height: 12),
            const Text(
              'Up and running in\nthree easy steps.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: _kDark,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 56),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                final steps = [
                  _StepCard(
                    number: '01',
                    icon: '🏃',
                    title: 'Choose Mode',
                    body:
                        'Pick Runner or Cyclist — we tailor routes to your pace.',
                  ),
                  _StepCard(
                    number: '02',
                    icon: '🗺️',
                    title: 'Discover Safe Routes',
                    body:
                        'Browse routes scored by lighting, traffic & crowd levels.',
                  ),
                  _StepCard(
                    number: '03',
                    icon: '🛡️',
                    title: 'Track & Stay Safe',
                    body:
                        'Follow your route with live safety alerts along the way.',
                  ),
                ];
                if (isMobile) {
                  return Column(
                    children: steps
                        .map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: s,
                          ),
                        )
                        .toList(),
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: steps[0]),
                    _StepConnector(animation: _howAnim),
                    Expanded(child: steps[1]),
                    _StepConnector(animation: _howAnim),
                    Expanded(child: steps[2]),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Social Proof ───────────────────────────────────────────────────────────
  Widget _buildSocialProof() {
    return _FadeInSection(
      animation: _proofAnim,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 28),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: _kGreen.withOpacity(0.10),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _starRow(5),
                  const SizedBox(width: 10),
                  const Text(
                    'Trusted by 10,000+ active users',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _kDark,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                final cards = [
                  _TestimonialCard(
                    name: 'Alex R.',
                    role: 'Marathon Runner',
                    emoji: '🏃',
                    text:
                        '"Safe Stride changed how I train. I never run blind at night anymore — the lighting scores are spot-on."',
                    animation: _proofAnim,
                    delay: 0,
                  ),
                  _TestimonialCard(
                    name: 'Maya T.',
                    role: 'Cyclist',
                    emoji: '🚴',
                    text:
                        '"The crowd and traffic data is incredibly accurate. My morning rides feel so much safer now."',
                    animation: _proofAnim,
                    delay: 150,
                  ),
                  _TestimonialCard(
                    name: 'Jordan K.',
                    role: 'Trail Runner',
                    emoji: '🛡️',
                    text:
                        '"95% safety score on my favourite trail — it is now my go-to app before every long run."',
                    animation: _proofAnim,
                    delay: 300,
                  ),
                ];
                if (isMobile) {
                  return Column(
                    children: cards
                        .map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: c,
                          ),
                        )
                        .toList(),
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cards
                      .expand(
                        (c) => [
                          Expanded(child: c),
                          if (c != cards.last) const SizedBox(width: 16),
                        ],
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Final CTA ──────────────────────────────────────────────────────────────
  Widget _buildFinalCta() {
    return _FadeInSection(
      animation: _ctaAnim,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _kGreen.withOpacity(0.15),
              _kGreen.withOpacity(0.05),
              _kBg,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _kGreen.withOpacity(0.50),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Your Safety Should\nNever Be a Guess.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: _kDark,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Join thousands of runners and cyclists who stride smarter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: _kGrey, height: 1.6),
            ),
            const SizedBox(height: 36),
            _primaryBtn('Start Your Safe Journey', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              );
            }, large: true),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text(
                'Already have an account? Sign in →',
                style: TextStyle(
                  color: _kGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 28),
      color: _kDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _kGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_run_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Safe Stride',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Text(
            '© 2026 Safe Stride. All rights reserved.',
            style: TextStyle(color: Color(0xFF8494A9), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: _kGreen.withOpacity(0.12),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: _kGreenDark,
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _primaryBtn(String label, VoidCallback onTap, {bool large = false}) {
    return GestureDetector(
      onTap: onTap,
      child: _HoverButton(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: large ? 36 : 28,
            vertical: large ? 18 : 14,
          ),
          decoration: BoxDecoration(
            color: _kGreen,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: _kGreen.withOpacity(0.50),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: large ? 17 : 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFFE4E9F2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: _kDark,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHero(),
                _buildFeatures(),
                _buildHowItWorks(),
                _buildSocialProof(),
                _buildFinalCta(),
                _buildFooter(),
              ],
            ),
          ),
          // Sticky nav overlay
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: _buildNav(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SUB-WIDGETS
// ═══════════════════════════════════════════════════════════════

// ── Animated Background Grid ───────────────────────────────────
class _AnimatedGrid extends StatelessWidget {
  final Animation<double> animation;
  const _AnimatedGrid({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) => CustomPaint(painter: _GridPainter(animation.value)),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double t;
  _GridPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6EEB5F).withOpacity(0.06)
      ..strokeWidth = 1;

    const spacing = 44.0;
    final offsetX = (t * spacing) % spacing;
    final offsetY = (t * spacing * 0.6) % spacing;

    for (
      double x = -spacing + offsetX;
      x < size.width + spacing;
      x += spacing
    ) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (
      double y = -spacing + offsetY;
      y < size.height + spacing;
      y += spacing
    ) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw tiny route dots
    final dotPaint = Paint()..color = const Color(0xFF6EEB5F).withOpacity(0.18);
    for (int i = 0; i < 6; i++) {
      final x = (i * 80.0 + offsetX * 2) % size.width;
      final y = (i * 60.0 + offsetY * 1.5) % size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.t != t;
}

// ── Mini Map Lines ─────────────────────────────────────────────
class _MiniMapLines extends StatelessWidget {
  const _MiniMapLines();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MapLinePainter());
  }
}

class _MapLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final route = Paint()
      ..color = const Color(0xFF6EEB5F)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Background roads
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.35, size.height),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, 0),
      Offset(size.width * 0.65, size.height),
      road,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.65),
      Offset(size.width, size.height * 0.65),
      road,
    );

    // Highlighted safe route
    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.4)
      ..lineTo(size.width * 0.35, size.height * 0.4)
      ..lineTo(size.width * 0.35, size.height * 0.65)
      ..lineTo(size.width * 0.65, size.height * 0.65);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Feature Card ───────────────────────────────────────────────
class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String body;
  final int delay;
  final Animation<double> animation;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.delay,
    required this.animation,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (_, child) {
        final delayed = CurvedAnimation(
          parent: widget.animation,
          curve: Interval(widget.delay / 1000, 1.0, curve: Curves.easeOut),
        );
        return FadeTransition(
          opacity: delayed,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(delayed),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? _kGreen.withOpacity(0.18)
                    : Colors.black.withOpacity(0.06),
                blurRadius: _hovered ? 30 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _kGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: _kGreen, size: 26),
              ),
              const SizedBox(height: 18),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _kDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.body,
                style: const TextStyle(
                  fontSize: 14,
                  color: _kGrey,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step Card ──────────────────────────────────────────────────
class _StepCard extends StatelessWidget {
  final String number;
  final String icon;
  final String title;
  final String body;

  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _kGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: _kGreenDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(icon, style: const TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _kDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(fontSize: 13, color: _kGrey, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── Step Connector ─────────────────────────────────────────────
class _StepConnector extends StatelessWidget {
  final Animation<double> animation;
  const _StepConnector({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, _) => SizedBox(
          width: 40,
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: animation.value,
              backgroundColor: const Color(0xFFE4E9F2),
              valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Testimonial Card ───────────────────────────────────────────
class _TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String emoji;
  final String text;
  final Animation<double> animation;
  final int delay;

  const _TestimonialCard({
    required this.name,
    required this.role,
    required this.emoji,
    required this.text,
    required this.animation,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) {
        final delayed = CurvedAnimation(
          parent: animation,
          curve: Interval(delay / 1000, 1.0, curve: Curves.easeOut),
        );
        return FadeTransition(
          opacity: delayed,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(delayed),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                5,
                (_) => const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFAA00),
                  size: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: _kGrey,
                height: 1.7,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _kGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _kDark,
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(fontSize: 12, color: _kGrey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hover Button ───────────────────────────────────────────────
class _HoverButton extends StatefulWidget {
  final Widget child;
  const _HoverButton({required this.child});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        child: widget.child,
      ),
    );
  }
}

// ── Fade-in Section ────────────────────────────────────────────
class _FadeInSection extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _FadeInSection({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }
}
