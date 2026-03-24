import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../services/user_preferences_service.dart';

/// Full-screen editor for the user's profile and personalization settings.
class EditProfileScreen extends StatefulWidget {
  final UserModel userModel;

  const EditProfileScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late String _activityType;
  late double _preferredDistance;
  late bool _notificationsEnabled;

  final _prefsSvc = UserPreferencesService();
  bool _isSaving = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.userModel.displayName);
    _bioCtrl = TextEditingController(text: widget.userModel.bio);
    _activityType = widget.userModel.activityType;
    _preferredDistance = widget.userModel.preferredDistance;
    _notificationsEnabled = widget.userModel.notificationsEnabled;

    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      await _prefsSvc.updatePreferences(uid, {
        'displayName': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'activityType': _activityType,
        'preferredDistance': _preferredDistance,
        'notificationsEnabled': _notificationsEnabled,
      });

      // Also update Firebase Auth display name to keep it in sync
      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(_nameCtrl.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated!',
                style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.of(context).pop(true); // signal refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final dark = (Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBlue : AppColors.lightBackground,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor:
                  dark ? AppColors.mediumBlue : AppColors.primaryBlue,
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Edit Profile',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.skyBlue,
                        AppColors.neonGreen
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),

            // Body
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Avatar placeholder
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.neonGreen, width: 3),
                            color:
                                dark ? AppColors.mediumBlue : AppColors.skyBlue,
                          ),
                          child: const Icon(Icons.person,
                              size: 48, color: Colors.white),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.neonGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Display Name ──
                  _sectionTitle('Display Name', dark),
                  const SizedBox(height: 8),
                  _textField(_nameCtrl, 'Your name', Icons.person_outline, dark),

                  const SizedBox(height: 24),

                  // ── Bio ──
                  _sectionTitle('Bio', dark),
                  const SizedBox(height: 8),
                  _textField(
                      _bioCtrl, 'Tell us about yourself...', Icons.edit, dark,
                      maxLines: 3),

                  const SizedBox(height: 32),

                  // ── Activity Type ──
                  _sectionTitle('Activity Type', dark),
                  const SizedBox(height: 12),
                  _activityToggle(dark),

                  const SizedBox(height: 32),

                  // ── Preferred Distance ──
                  _sectionTitle(
                      'Preferred Max Distance: ${_preferredDistance.toStringAsFixed(0)} km',
                      dark),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.neonGreen,
                      inactiveTrackColor:
                          dark ? AppColors.lightBlue : Colors.grey[300],
                      thumbColor: AppColors.neonGreen,
                      overlayColor: AppColors.neonGreen.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _preferredDistance,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: '${_preferredDistance.toStringAsFixed(0)} km',
                      onChanged: (v) =>
                          setState(() => _preferredDistance = v),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Notifications ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: dark ? AppColors.mediumBlue : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_active,
                            color: _notificationsEnabled
                                ? AppColors.neonGreen
                                : Colors.grey,
                            size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Push Notifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: dark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          onChanged: (v) =>
                              setState(() => _notificationsEnabled = v),
                          activeThumbColor: AppColors.neonGreen,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Save Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primaryGreen.withOpacity(0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 20),
                                SizedBox(width: 8),
                                Text('Save Changes',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────────────────

  Widget _sectionTitle(String title, bool dark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: dark ? Colors.grey[300] : AppColors.textGray,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint, IconData icon,
      bool dark,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.mediumBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: dark ? AppColors.lightBlue : const Color(0xFFE4E9F2)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 15,
          color: dark ? Colors.white : AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: dark ? Colors.grey[600] : const Color(0xFFABB8C9),
              fontSize: 14),
          prefixIcon: Icon(icon,
              color: dark ? Colors.grey[500] : const Color(0xFFABB8C9),
              size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _activityToggle(bool dark) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: dark ? AppColors.mediumBlue : const Color(0xFFD9E0EC),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          _modePill('🏃 Runner', 'runner', dark),
          _modePill('🚴 Cyclist', 'cyclist', dark),
        ],
      ),
    );
  }

  Widget _modePill(String label, String value, bool dark) {
    final active = _activityType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activityType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.45),
                        blurRadius: 12,
                        spreadRadius: 1),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: active
                  ? Colors.white
                  : dark
                      ? Colors.grey[400]
                      : const Color(0xFF8494A9),
            ),
          ),
        ),
      ),
    );
  }
}
