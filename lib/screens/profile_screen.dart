import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/mock_data.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_preferences_service.dart';
import 'edit_profile_screen.dart';

/// Profile tab — streams the user's Firestore profile in real time and renders
/// stats, settings, and saved routes.
class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  const ProfileScreen({
    Key? key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _prefsSvc = UserPreferencesService();

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return StreamBuilder<UserModel?>(
      stream: _prefsSvc.userStream(firebaseUser.uid),
      builder: (context, snapshot) {
        // While loading, show a skeleton-ish progress indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: widget.isDarkMode
                ? AppColors.darkBlue
                : AppColors.lightBackground,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Build a UserModel — either from Firestore or a sensible default.
        final userModel = snapshot.data ??
            UserModel(
              uid: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              displayName: firebaseUser.displayName ?? 'SafeStride User',
            );

        return _buildBody(context, userModel);
      },
    );
  }

  // ── Main Body ────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, UserModel user) {
    final dark = widget.isDarkMode;
    final displayName =
        user.displayName.isNotEmpty ? user.displayName : 'SafeStride User';
    final bio = user.bio.isNotEmpty ? user.bio : 'No bio yet';
    final activityLabel =
        user.activityType == 'cyclist' ? '🚴 Cyclist' : '🏃 Runner';

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBlue : AppColors.lightBackground,
      body: Column(
        children: [
          // ── Header with Gradient ──
          Container(
            height: 290,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.skyBlue,
                  AppColors.neonGreen,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 56),
                // Settings / Edit button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Activity badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          activityLabel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ),
                      // Edit profile icon
                      GestureDetector(
                        onTap: () => _openEditProfile(user),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Profile Avatar
                Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Container(
                          color: AppColors.skyBlue,
                          child: const Icon(Icons.person,
                              size: 48, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: const Icon(Icons.emoji_events,
                            size: 16, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                      fontSize: 13, color: Colors.white.withOpacity(0.75)),
                ),
                const SizedBox(height: 4),
                Text(
                  bio,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          // ── Stats Cards ──
          Transform.translate(
            offset: const Offset(0, -48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                      child: _buildStatCard(Icons.map,
                          '${user.savedRoutesCount}', 'Saved Routes')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatCard(
                          Icons.star, '${user.reviewsCount}', 'Reviews')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatCard(Icons.favorite,
                          '${user.favoritesCount}', 'Favorites')),
                ],
              ),
            ),
          ),

          // ── Settings + Saved Routes list ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: MockData.routes.length + 4,
              itemBuilder: (context, index) {
                // Settings header
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  );
                }

                // Settings card
                if (index == 1) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Container(
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
                      child: Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.edit,
                            title: 'Edit Profile',
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openEditProfile(user),
                          ),
                          _buildDivider(),
                          _buildSettingItem(
                            icon: Icons.logout,
                            title: 'Sign Out',
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              await AuthService().logout();
                            },
                          ),
                          _buildDivider(),
                          _buildSettingItem(
                            icon: dark ? Icons.dark_mode : Icons.light_mode,
                            title: dark ? 'Dark Mode' : 'Light Mode',
                            trailing: Switch(
                              value: dark,
                              onChanged: (_) => widget.onToggleDarkMode(),
                              activeColor: AppColors.neonGreen,
                            ),
                            onTap: widget.onToggleDarkMode,
                          ),
                          _buildDivider(),
                          _buildSettingItem(
                            icon: Icons.notifications,
                            title: 'Notifications',
                            trailing: Switch(
                              value: user.notificationsEnabled,
                              onChanged: (v) async {
                                await _prefsSvc.toggleNotifications(
                                    user.uid, v);
                              },
                              activeColor: AppColors.neonGreen,
                            ),
                          ),
                          _buildDivider(),
                          _buildSettingItem(
                            icon: Icons.speed,
                            title:
                                'Max Distance: ${user.preferredDistance.toStringAsFixed(0)} km',
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openEditProfile(user),
                          ),
                          _buildDivider(),
                          _buildSettingItem(
                            icon: Icons.shield,
                            title: 'Privacy & Safety',
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Saved Routes header
                if (index == 2) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Saved Routes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  );
                }

                // Bottom spacing
                if (index == MockData.routes.length + 3) {
                  return const SizedBox(height: 100);
                }

                // Saved route cards
                final route = MockData.routes[index - 3];
                return _buildSavedRouteCard(route);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Navigation ───────────────────────────────────────────────────────────
  void _openEditProfile(UserModel user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          userModel: user,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  // ── Helper Widgets ───────────────────────────────────────────────────────
  Widget _buildStatCard(IconData icon, String value, String label) {
    final dark = widget.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.mediumBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon,
              color: dark ? AppColors.neonGreen : AppColors.primaryBlue,
              size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: dark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final dark = widget.isDarkMode;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon,
                color: dark ? Colors.grey[400] : Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: widget.isDarkMode ? AppColors.lightBlue : Colors.grey[100],
    );
  }

  Widget _buildSavedRouteCard(route) {
    final dark = widget.isDarkMode;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.mediumBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: AppColors.blueGradient,
            ),
            child: Center(
              child: Text(route.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      route.distance,
                      style: TextStyle(
                        fontSize: 14,
                        color: dark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('•',
                        style: TextStyle(
                            color:
                                dark ? Colors.grey[400] : Colors.grey[600])),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: dark ? AppColors.lightBlue : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        route.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: dark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.getSafetyColor(route.safety).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield,
                    color: AppColors.getSafetyColor(route.safety), size: 20),
                Text(
                  '${route.safety}%',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getSafetyColor(route.safety),
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
