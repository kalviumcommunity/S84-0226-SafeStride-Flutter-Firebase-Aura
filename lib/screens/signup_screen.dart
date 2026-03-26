import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login/login_screen.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _selectedMode = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showSnack('Please fill in all fields.', isError: true);
      return;
    }
    if (!email.contains('@')) {
      _showSnack('Enter a valid email address.', isError: true);
      return;
    }
    if (pass != confirm) {
      _showSnack('Passwords do not match.', isError: true);
      return;
    }
    if (pass.length < 6) {
      _showSnack('Password must be at least 6 characters.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Store OTP in Firestore â€“ returns the 6-digit code for demo display
      final code =
          await AuthService().generateAndStoreOtp(email, name);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              email: email,
              password: pass,
              name: name,
              activityType: _selectedMode == 0 ? 'runner' : 'cyclist',
              demoCode: code,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnack(
            e is AuthFailure ? e.message : 'Error: ${e.toString()}',
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.white)),
      backgroundColor:
          isError ? const Color(0xFFFF5252) : const Color(0xFF6EEB5F),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildToggle(),
                  const SizedBox(height: 36),
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  _buildContinueButton(),
                  const SizedBox(height: 28),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€ Toggle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E0EC),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_pill('ðŸƒ Runner', 0), _pill('ðŸš´ Cyclist', 1)],
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
        padding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6EEB5F) : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: const Color(0xFF6EEB5F).withOpacity(0.45),
                      blurRadius: 12,
                      spreadRadius: 1),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: active ? Colors.white : const Color(0xFF8494A9),
          ),
        ),
      ),
    );
  }

  // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF6EEB5F),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF6EEB5F).withOpacity(0.50),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: const Icon(Icons.person_add_alt_1_rounded,
              color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        const Text(
          'Create Account',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2035),
              letterSpacing: -0.3),
        ),
        const SizedBox(height: 5),
        const Text(
          'Join thousands of safe striders',
          style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8494A9),
              fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  // â”€â”€ Form Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6EEB5F).withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, 10)),
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildInput(
            controller: _nameController,
            hint: 'Full name',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 14),
          _buildInput(
            controller: _emailController,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _buildInput(
            controller: _passwordController,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            suffix: IconButton(
              icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFFABB8C9),
                  size: 20),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 14),
          _buildInput(
            controller: _confirmPasswordController,
            hint: 'Confirm password',
            icon: Icons.lock_reset_outlined,
            obscure: _obscureConfirm,
            suffix: IconButton(
              icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFFABB8C9),
                  size: 20),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          const SizedBox(height: 16),
          // Step indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stepDot(active: true, label: '1'),
              _stepLine(),
              _stepDot(active: false, label: '2'),
              _stepLine(),
              _stepDot(active: false, label: '3'),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Step 1 of 3 Â· Next: Email Verification',
            style:
                TextStyle(fontSize: 12, color: Color(0xFFABB8C9)),
          ),
        ],
      ),
    );
  }

  Widget _stepDot({required bool active, required String label}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6EEB5F) : const Color(0xFFE4E9F2),
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                    color: const Color(0xFF6EEB5F).withOpacity(0.40),
                    blurRadius: 8,
                    spreadRadius: 1)
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: active ? Colors.white : const Color(0xFFABB8C9))),
    );
  }

  Widget _stepLine() => Container(
        width: 32,
        height: 2,
        color: const Color(0xFFE4E9F2),
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E9F2), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1A2035),
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: Color(0xFFABB8C9), fontSize: 14),
          prefixIcon:
              Icon(icon, color: const Color(0xFFABB8C9), size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // â”€â”€ Continue Button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                      color: const Color(0xFF6EEB5F).withOpacity(0.50),
                      blurRadius: 18,
                      offset: const Offset(0, 6))
                ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _continue,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6EEB5F),
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                const Color(0xFF6EEB5F).withOpacity(0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Continue',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account?  ',
            style: TextStyle(color: Color(0xFF8494A9), fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const LoginScreen())),
          child: const Text('Sign In',
              style: TextStyle(
                  color: Color(0xFF6EEB5F),
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
