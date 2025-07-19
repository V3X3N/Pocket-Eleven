import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/pages/loading/login_register/temp_login_page.dart';

@immutable
class UserData {
  final String managerName, clubName, email;
  final int avatar;
  final DateTime timestamp;

  const UserData({
    required this.managerName,
    required this.clubName,
    required this.email,
    required this.avatar,
    required this.timestamp,
  });

  UserData copyWith(
          {String? managerName,
          String? clubName,
          String? email,
          int? avatar}) =>
      UserData(
        managerName: managerName ?? this.managerName,
        clubName: clubName ?? this.clubName,
        email: email ?? this.email,
        avatar: avatar ?? this.avatar,
        timestamp: DateTime.now(),
      );

  bool get isStale => DateTime.now().difference(timestamp).inMinutes > 5;
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  UserData? _userData;
  bool _loading = false;
  String? _error;
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  static final Map<String, UserData> _cache = {};
  static const int _maxAvatars = 10;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _fadeIn = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _loadUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return _navigateToLogin();

      final cached = _cache[user.uid];
      if (cached != null && !cached.isStale) {
        _setUserData(cached);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 8));

      if (!mounted || !doc.exists) throw Exception('User not found');

      final data = doc.data() ?? {};
      final avatar = _validateAvatar(data['avatar']);

      if (!data.containsKey('avatar')) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'avatar': 1});
      }

      final results = await Future.wait([
        FirebaseFunctions.getManagerName(user.uid),
        FirebaseFunctions.getClubName(user.uid),
        FirebaseFunctions.getEmail(user.uid),
      ]).timeout(const Duration(seconds: 5));

      final userData = UserData(
        managerName: results[0],
        clubName: results[1],
        email: results[2],
        avatar: avatar,
        timestamp: DateTime.now(),
      );

      _cache[user.uid] = userData;
      if (mounted) _setUserData(userData);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().contains('network')
            ? 'Network error'
            : 'Error loading profile');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _controller.forward();
      }
    }
  }

  void _setUserData(UserData data) => setState(() => _userData = data);

  int _validateAvatar(dynamic value) =>
      (value is int && value >= 1 && value <= _maxAvatars) ? value : 1;

  void _navigateToLogin() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()));
        }
      });

  Future<void> _updateAvatar(int newAvatar) async {
    if (newAvatar < 1 ||
        newAvatar > _maxAvatars ||
        _userData?.avatar == newAvatar) {
      return;
    }

    final prev = _userData;
    if (prev == null) return;

    _setUserData(prev.copyWith(avatar: newAvatar));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'avatar': newAvatar});

      _cache[user.uid] = _userData!;
    } catch (e) {
      if (mounted) {
        _setUserData(prev);
        _showSnackBar('Failed to update avatar');
      }
    }
  }

  void _showSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );

  Future<void> _logout() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signOut();
      _cache.clear();
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showSnackBar('Logout failed');
      }
    }
  }

  void _refresh() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) _cache.remove(userId);
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Stack(
        children: [
          _buildBackground(),
          if (_error != null) _buildErrorView() else _buildMainView(isTablet),
          if (_loading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withValues(alpha: 0.95),
            ],
          ),
        ),
      );

  Widget _buildLoadingOverlay() => Container(
        color: Colors.black26,
        child: Center(
          child: LoadingAnimationWidget.waveDots(
            color: AppColors.textEnabledColor,
            size: 50,
          ),
        ),
      );

  Widget _buildErrorView() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(
                    color: AppColors.textEnabledColor, fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.hoverColor,
                foregroundColor: AppColors.textEnabledColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );

  Widget _buildMainView(bool isTablet) => RefreshIndicator(
        onRefresh: _loadUserData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              title: const Text('Profile',
                  style: TextStyle(
                      color: AppColors.textEnabledColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh,
                      color: AppColors.textEnabledColor),
                  onPressed: _refresh,
                ),
              ],
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: FadeTransition(
                opacity: _fadeIn,
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildProfileCard(isTablet),
                      const SizedBox(height: 40),
                      _buildLogoutButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildProfileCard(bool isTablet) => Container(
        constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.hoverColor.withValues(alpha: 0.9),
              AppColors.hoverColor.withValues(alpha: 0.7),
            ],
          ),
          border:
              Border.all(color: AppColors.borderColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildUserInfo(isTablet),
            const SizedBox(height: 24),
            _buildEmailInfo(),
          ],
        ),
      );

  Widget _buildUserInfo(bool isTablet) => Row(
        children: [
          _buildAvatar(isTablet),
          const SizedBox(width: 32),
          Expanded(child: _buildManagerInfo(isTablet)),
        ],
      );

  Widget _buildAvatar(bool isTablet) {
    final size = isTablet ? 120.0 : 100.0;
    return GestureDetector(
      onTap: () => _showAvatarSelector(isTablet),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image:
                AssetImage('assets/crests/crest_${_userData?.avatar ?? 1}.png'),
            fit: BoxFit.cover,
          ),
          border: Border.all(
              width: 3, color: AppColors.borderColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.1)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManagerInfo(bool isTablet) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _userData?.managerName ?? 'Loading...',
            style: TextStyle(
              color: AppColors.textEnabledColor,
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userData?.clubName ?? 'Loading...',
            style: TextStyle(
              color: AppColors.textEnabledColor.withValues(alpha: 0.8),
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manager',
            style: TextStyle(
              color: AppColors.textEnabledColor.withValues(alpha: 0.6),
              fontSize: isTablet ? 14 : 12,
            ),
          ),
        ],
      );

  Widget _buildEmailInfo() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.borderColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email_outlined,
                color: AppColors.textEnabledColor.withValues(alpha: 0.7),
                size: 20),
            const SizedBox(width: 12),
            Text(
              _userData?.email ?? 'Loading...',
              style: const TextStyle(
                  color: AppColors.textEnabledColor, fontSize: 16),
            ),
          ],
        ),
      );

  Widget _buildLogoutButton() => ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.hoverColor,
          foregroundColor: AppColors.textEnabledColor,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
        ),
        child: const Text('Logout',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      );

  void _showAvatarSelector(bool isTablet) => showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: isTablet ? 500 : 350),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.hoverColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.borderColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Avatar',
                  style: TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 5 : 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _maxAvatars,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      _updateAvatar(index + 1);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/crests/crest_${index + 1}.png'),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                            color:
                                AppColors.borderColor.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
