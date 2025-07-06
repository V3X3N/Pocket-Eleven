import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pocket_eleven/pages/loading/loginPage/temp_login_page.dart';
import 'package:pocket_eleven/pages/profile/widget/avatar_selector.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  String _managerName = '';
  String _clubName = '';
  String _email = '';
  int _avatar = 1;
  bool _loading = false;
  String? _errorMessage;

  // Cache for performance optimization
  static final Map<String, UserData> _userDataCache = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserDataOptimized();
  }

  Future<void> _loadUserDataOptimized() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _navigateToLogin();
        return;
      }

      final String userId = user.uid;

      // Check cache first (5 min freshness)
      if (_userDataCache.containsKey(userId)) {
        final cachedData = _userDataCache[userId]!;
        if (DateTime.now().difference(cachedData.timestamp).inMinutes < 5) {
          _loadFromCache(cachedData);
          return;
        }
      }

      // Fetch fresh data with timeout
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;

      if (userDoc.exists) {
        await _processUserData(userDoc, userId);
      } else {
        throw Exception('User document not found');
      }
    } catch (error) {
      _handleError(error);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _loadFromCache(UserData cachedData) {
    setState(() {
      _managerName = cachedData.managerName;
      _clubName = cachedData.clubName;
      _email = cachedData.email;
      _avatar = cachedData.avatar;
      _loading = false;
    });
  }

  Future<void> _processUserData(DocumentSnapshot userDoc, String userId) async {
    final userData = userDoc.data() as Map<String, dynamic>?;

    if (userData == null) {
      throw Exception('User data is null');
    }

    // Handle avatar with validation
    if (!userData.containsKey('avatar')) {
      await _setDefaultAvatar(userId);
    } else {
      _avatar = _validateAvatar(userData['avatar']);
    }

    // Fetch additional data concurrently
    final results = await Future.wait([
      FirebaseFunctions.getManagerName(userId).catchError((_) => 'Unknown'),
      FirebaseFunctions.getClubName(userId).catchError((_) => 'Unknown'),
      FirebaseFunctions.getEmail(userId).catchError((_) => 'Unknown'),
    ]);

    if (!mounted) return;

    setState(() {
      _managerName = results[0];
      _clubName = results[1];
      _email = results[2];
    });

    // Cache the data
    _userDataCache[userId] = UserData(
      managerName: _managerName,
      clubName: _clubName,
      email: _email,
      avatar: _avatar,
      timestamp: DateTime.now(),
    );
  }

  Future<void> _setDefaultAvatar(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'avatar': 1});
    _avatar = 1;
  }

  int _validateAvatar(dynamic avatarValue) {
    if (avatarValue is int && avatarValue >= 1 && avatarValue <= 10) {
      return avatarValue;
    }
    return 1;
  }

  void _handleError(dynamic error) {
    debugPrint('Error loading user data: $error');
    if (mounted) {
      setState(() {
        _errorMessage = error.toString().contains('network')
            ? 'Network error. Please check your connection.'
            : 'An error occurred. Please try again.';
      });
    }
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TempLoginPage()),
        );
      }
    });
  }

  Future<void> _updateAvatarOptimized(int newAvatarIndex) async {
    if (newAvatarIndex < 1 ||
        newAvatarIndex > 10 ||
        newAvatarIndex == _avatar) {
      return;
    }

    // Optimistic update
    final previousAvatar = _avatar;
    setState(() {
      _avatar = newAvatarIndex;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
          {'avatar': newAvatarIndex}).timeout(const Duration(seconds: 5));

      // Update cache
      if (_userDataCache.containsKey(user.uid)) {
        _userDataCache[user.uid] = _userDataCache[user.uid]!.copyWith(
          avatar: newAvatarIndex,
          timestamp: DateTime.now(),
        );
      }
    } catch (error) {
      // Rollback on error
      if (mounted) {
        setState(() {
          _avatar = previousAvatar;
        });
        _showSnackBar('Failed to update avatar');
      }
      debugPrint('Error updating avatar: $error');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout() async {
    setState(() {
      _loading = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      _userDataCache.clear();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TempLoginPage()),
      );
    } catch (error) {
      debugPrint('Error signing out: $error');
      if (mounted) {
        setState(() {
          _loading = false;
        });
        _showSnackBar('Failed to logout');
      }
    }
  }

  void _refreshData() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _userDataCache.remove(userId);
    }
    _loadUserDataOptimized();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 0.3,
      color: Colors.black87,
      progressIndicator: LoadingAnimationWidget.waveDots(
        color: AppColors.textEnabledColor,
        size: 50,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Profile',
        style: TextStyle(
          color: AppColors.textEnabledColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textEnabledColor),
          onPressed: _refreshData,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return RefreshIndicator(
      onRefresh: _loadUserDataOptimized,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileCard(),
            const SizedBox(height: 30),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: AppColors.textEnabledColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.hoverColor,
              foregroundColor: AppColors.textEnabledColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.all(20.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: AppColors.hoverColor,
          border: Border.all(
            width: 1,
            color: AppColors.borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildClubInfo(),
                _buildManagerInfo(),
              ],
            ),
            const SizedBox(height: 20),
            _buildEmailInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildClubInfo() {
    return RepaintBoundary(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => AvatarSelector(
                  updateAvatar: _updateAvatarOptimized,
                ),
              );
            },
            child: Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: DecorationImage(
                  image: AssetImage('assets/crests/crest_$_avatar.png'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  width: 2,
                  color: AppColors.borderColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            _clubName.isNotEmpty ? _clubName : 'Loading...',
            style: const TextStyle(
              color: AppColors.textEnabledColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildManagerInfo() {
    return Column(
      children: [
        Text(
          _managerName.isNotEmpty ? _managerName : 'Loading...',
          style: const TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Manager',
          style: TextStyle(
            color: AppColors.textEnabledColor.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.email,
            color: AppColors.textEnabledColor.withValues(alpha: 0.7),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _email.isNotEmpty ? _email : 'Loading...',
            style: const TextStyle(
              color: AppColors.textEnabledColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: _logout,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.hoverColor,
        foregroundColor: AppColors.textEnabledColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: const Text(
        'Logout',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Data class for efficient caching
class UserData {
  final String managerName;
  final String clubName;
  final String email;
  final int avatar;
  final DateTime timestamp;

  UserData({
    required this.managerName,
    required this.clubName,
    required this.email,
    required this.avatar,
    required this.timestamp,
  });

  UserData copyWith({
    String? managerName,
    String? clubName,
    String? email,
    int? avatar,
    DateTime? timestamp,
  }) {
    return UserData(
      managerName: managerName ?? this.managerName,
      clubName: clubName ?? this.clubName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
