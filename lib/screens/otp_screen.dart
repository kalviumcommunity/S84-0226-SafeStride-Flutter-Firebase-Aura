import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String password;
  final String name;

  /// The code returned by generateAndStoreOtp – shown to the user for demo
  /// purposes. In production this would arrive via email.
  final String demoCode;

  const OtpScreen({
    super.key,
    required this.email,
    required this.password,
    required this.name,
    required this.demoCode,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  int _secondsLeft = 600; // 10 minutes
  Timer? _timer;
  String? _liveCode; // updated on resend

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _liveCode = widget.demoCode;
    _startTimer();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 600);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _animController.dispose();
    super.dispose();
  }

  String get _enteredCode => _controllers.map((c) => c.text).join();

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get _timerExpired => _secondsLeft == 0;

  // ── Verify ─────────────────────────────────────────────────────────────────
  Future<void> _verify() async {
    final code = _enteredCode;
    if (code.length < 6) {
      _showSnack('Please enter all 6 digits.', isError: true);
      return;
    }
    setState(() => _isVerifying = true);
    try {
      // 1. Verify OTP against Firestore
      await AuthService().verifyOtp(widget.email, code);

      // 2. Create Firebase account (OTP confirmed)
      await AuthService().signUp(
        widget.email,
        widget.password,
        displayName: widget.name,
      );

      // 3. Pop all screens back to AuthWrapper (the root home).
      //    AuthWrapper re-renders and shows MainScreen because the user is now
      //    signed in — avoids the stuck loading spinner on web.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(
          e is AuthFailure ? e.message : 'Verification failed. Try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  // ── Resend ─────────────────────────────────────────────────────────────────
  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      final newCode = await AuthService().generateAndStoreOtp(
        widget.email,
        widget.name,
      );
      setState(() => _liveCode = newCode);
      _startTimer();
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
      _showSnack('New code sent! (demo code: $newCode)');
    } catch (e) {
      _showSnack('Could not resend. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError
            ? const Color(0xFFFF5252)
            : const Color(0xFF6EEB5F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F8),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBackButton(),
                  const SizedBox(height: 28),
                  _buildIcon(),
                  const SizedBox(height: 28),
                  _buildTitle(),
                  const SizedBox(height: 36),
                  _buildOtpCard(),
                  const SizedBox(height: 24),
                  _buildDemoHint(),
                  const SizedBox(height: 28),
                  _buildVerifyButton(),
                  const SizedBox(height: 24),
                  _buildResendRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Back ───────────────────────────────────────────────────────────────────
  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF1A2035),
          ),
        ),
      ),
    );
  }

  // ── Icon ───────────────────────────────────────────────────────────────────
  Widget _buildIcon() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF6EEB5F),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6EEB5F).withOpacity(0.50),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.mark_email_read_outlined,
        color: Colors.white,
        size: 44,
      ),
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────
  Widget _buildTitle() {
    final maskedEmail = _maskEmail(widget.email);
    return Column(
      children: [
        const Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A2035),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text: 'We sent a 6-digit code to\n',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8494A9),
              height: 1.6,
            ),
            children: [
              TextSpan(
                text: maskedEmail,
                style: const TextStyle(
                  color: Color(0xFF1A2035),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return email;
    return '${name[0]}${'•' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  // ── OTP Card ───────────────────────────────────────────────────────────────
  Widget _buildOtpCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6EEB5F).withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => _digitBox(i)),
          ),
          const SizedBox(height: 22),
          // Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: _timerExpired
                    ? const Color(0xFFFF5252)
                    : const Color(0xFF8494A9),
              ),
              const SizedBox(width: 6),
              Text(
                _timerExpired ? 'Code expired' : 'Expires in $_timerLabel',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _timerExpired
                      ? const Color(0xFFFF5252)
                      : const Color(0xFF8494A9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _digitBox(int index) {
    return SizedBox(
      width: 48,
      height: 58,
      child: AnimatedBuilder(
        animation: _focusNodes[index],
        builder: (context, _) {
          final isFocused = _focusNodes[index].hasFocus;
          return Container(
            decoration: BoxDecoration(
              color: isFocused
                  ? const Color(0xFF6EEB5F).withOpacity(0.08)
                  : const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFocused
                    ? const Color(0xFF6EEB5F)
                    : const Color(0xFFE4E9F2),
                width: isFocused ? 2 : 1.5,
              ),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6EEB5F).withOpacity(0.25),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A2035),
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
              onChanged: (val) {
                if (val.isNotEmpty) {
                  if (index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else {
                    _focusNodes[index].unfocus();
                    // Auto-verify when last digit entered
                    if (_enteredCode.length == 6) _verify();
                  }
                } else if (val.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              },
            ),
          );
        },
      ),
    );
  }

  // ── Demo hint ──────────────────────────────────────────────────────────────
  Widget _buildDemoHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF6EEB5F).withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF6EEB5F).withOpacity(0.30),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF6EEB5F),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Demo code: ',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A8A3E),
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: _liveCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 2,
                    ),
                  ),
                  const TextSpan(
                    text: '\nIn production this is emailed to you.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8494A9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Verify Button ──────────────────────────────────────────────────────────
  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: _isVerifying
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF6EEB5F).withOpacity(0.50),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _isVerifying || _timerExpired ? null : _verify,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6EEB5F),
            foregroundColor: Colors.white,
            disabledBackgroundColor: _timerExpired
                ? const Color(0xFFE4E9F2)
                : const Color(0xFF6EEB5F).withOpacity(0.6),
            disabledForegroundColor: _timerExpired
                ? const Color(0xFFABB8C9)
                : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: _isVerifying
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _timerExpired
                      ? 'Code Expired — Resend'
                      : 'Verify & Create Account',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Resend ─────────────────────────────────────────────────────────────────
  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Didn't receive the code?  ",
          style: TextStyle(color: Color(0xFF8494A9), fontSize: 14),
        ),
        GestureDetector(
          onTap: _isResending ? null : _resend,
          child: _isResending
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF6EEB5F),
                  ),
                )
              : const Text(
                  'Resend Code',
                  style: TextStyle(
                    color: Color(0xFF6EEB5F),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ],
    );
  }
}
