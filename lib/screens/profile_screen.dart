import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_preferences_service.dart';
import 'edit_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/route_model.dart';
import '../providers/theme_provider.dart';

/// Profile tab — streams the user's Firestore profile in real time and renders
/// stats, settings, and saved routes.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBlue
                : AppColors.lightBackground,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Build a UserModel — either from Firestore or a sensible default.
        final userModel =
            snapshot.data ??
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final activityLabel = user.activityType == 'cyclist'
        ? '🚴 Cyclist'
        : '🏃 Runner';

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBlue : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // ── Premium Sliver Header ──
          _buildSliverHeader(context, user, activityLabel, dark),

          // ── Stats Cards Row ──
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        Icons.map,
                        '${user.savedRoutesCount}',
                        'Saved Routes',
                        dark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        Icons.star,
                        '${user.reviewsCount}',
                        'Reviews',
                        dark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        Icons.favorite,
                        '${user.favoritesCount}',
                        'Favorites',
                        dark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Settings Section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dark ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? AppColors.mediumBlue : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.3 : 0.05),
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
                      dark: dark,
                    ),
                    _buildDivider(dark),
                    _buildSettingItem(
                      icon: Icons.logout,
                      title: 'Sign Out',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await AuthService().signOutGoogle();
                      },
                      dark: dark,
                    ),
                    _buildDivider(dark),
                    _buildSettingItem(
                      icon: dark ? Icons.dark_mode : Icons.light_mode,
                      title: dark ? 'Dark Mode' : 'Light Mode',
                      trailing: Switch(
                        value: dark,
                        onChanged: (_) {
                          if (user.uid.isNotEmpty) {
                            context.read<ThemeProvider>().toggle(user.uid);
                          }
                        },
                        activeThumbColor: AppColors.neonGreen,
                      ),
                      onTap: () {
                        if (user.uid.isNotEmpty) {
                          context.read<ThemeProvider>().toggle(user.uid);
                        }
                      },
                      dark: dark,
                    ),
                    _buildDivider(dark),
                    _buildSettingItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      trailing: Switch(
                        value: user.notificationsEnabled,
                        onChanged: (v) async {
                          await _prefsSvc.toggleNotifications(user.uid, v);
                        },
                        activeThumbColor: AppColors.neonGreen,
                      ),
                      dark: dark,
                    ),
                    _buildDivider(dark),
                    _buildSettingItem(
                      icon: Icons.speed,
                      title:
                          'Max Distance: ${user.preferredDistance.toStringAsFixed(0)} km',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openEditProfile(user),
                      dark: dark,
                    ),
                    _buildDivider(dark),
                    _buildSettingItem(
                      icon: Icons.shield,
                      title: 'Privacy & Safety',
                      trailing: const Icon(Icons.chevron_right),
                      dark: dark,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Saved Routes Header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                'Saved Routes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dark ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ),

          // ── Saved Routes Dynamic List ──
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: _prefsSvc.savedRoutesStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Center(
                      child: Text(
                        'No saved routes yet. Explore the map to save some!',
                        style: TextStyle(
                          color: dark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    try {
                      final route = RouteModel.fromMap(data);
                      return _buildSavedRouteCard(route, dark);
                    } catch (e) {
                      return const SizedBox.shrink();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(
    BuildContext context,
    UserModel user,
    String activityLabel,
    bool dark,
  ) {
    final displayName = user.displayName.isNotEmpty
        ? user.displayName
        : 'SafeStride User';
    final bio = user.bio.isNotEmpty ? user.bio : 'No bio yet';

    return SliverAppBar(
      expandedHeight: 290.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: LayoutBuilder(
          builder: (context, constraints) {
            // When completely collapsed, max height is toolbarHeight + topPadding
            // AppBar's default height is 56. Let's approximate based on constraints.
            final top = constraints.biggest.height;
            final isCollapsed = top <= MediaQuery.of(context).padding.top + 70;
            return isCollapsed
                ? Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
        background: Container(
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
              SizedBox(height: MediaQuery.of(context).padding.top + 32),
              // Settings / Edit button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Activity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        activityLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
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
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
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
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white,
                        ),
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
                      child: const Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: AppColors.textDark,
                      ),
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
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bio,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Navigation ───────────────────────────────────────────────────────────
  void _openEditProfile(UserModel user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(userModel: user)),
    );
  }

  // ── Helper Widgets ───────────────────────────────────────────────────────
  Widget _buildStatCard(IconData icon, String value, String label, bool dark) {
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
          Icon(
            icon,
            color: dark ? AppColors.neonGreen : AppColors.primaryBlue,
            size: 24,
          ),
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
    required bool dark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: dark ? Colors.grey[400] : Colors.grey[600],
              size: 20,
            ),
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
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool dark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: dark ? AppColors.lightBlue : Colors.grey[100],
    );
  }

  Widget _buildSavedRouteCard(RouteModel route, bool dark) {
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
                    Text(
                      '•',
                      style: TextStyle(
                        color: dark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
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
                Icon(
                  Icons.shield,
                  color: AppColors.getSafetyColor(route.safety),
                  size: 20,
                ),
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
