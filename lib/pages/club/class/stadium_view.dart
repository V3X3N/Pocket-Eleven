import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/club/widget/stadium_build.dart';

class StadiumView extends StatefulWidget {
  const StadiumView({super.key});

  @override
  StadiumViewState createState() => StadiumViewState();
}

class StadiumViewState extends State<StadiumView> {
  static const _gradientColors = [
    AppColors.primaryColor,
    AppColors.secondaryColor,
    AppColors.accentColor,
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Load any necessary data here if needed
      // For now, just simulate loading completion
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildModernContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.hoverColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 8),
            blurRadius: 32,
          ),
          BoxShadow(
            color: Color(0x1AFFFFFF),
            offset: Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradientColors,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(AppColors.textEnabledColor),
                  ),
                )
              : Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  child: _buildModernContainer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: const StadiumBuild(),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
