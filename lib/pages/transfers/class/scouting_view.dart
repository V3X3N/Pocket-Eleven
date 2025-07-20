import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class ScoutingView extends StatelessWidget {
  const ScoutingView({super.key, required this.onCurrencyChange});
  final VoidCallback onCurrencyChange;

  static const _gradientColors = [
    AppColors.primaryColor,
    AppColors.secondaryColor,
    AppColors.accentColor,
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    return RepaintBoundary(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradientColors,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? 500 : size.width * 0.9,
              ),
              child: _DevelopmentCard(size: size),
            ),
          ),
        ),
      ),
    );
  }
}

class _DevelopmentCard extends StatelessWidget {
  const _DevelopmentCard({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.all(size.width * 0.04),
        padding: EdgeInsets.all(size.width * 0.06),
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
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0x1AFFFFFF),
              offset: Offset(0, 1),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            SizedBox(height: size.height * 0.03),
            _buildTitle(),
            SizedBox(height: size.height * 0.02),
            _buildMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return RepaintBoundary(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.warningColor, AppColors.errorColor],
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.warningColor.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: const Icon(
          Icons.construction_rounded,
          color: AppColors.textEnabledColor,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Content under development',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textEnabledColor,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    return Text(
      'This feature is currently being developed.\nPlease check back later.',
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textEnabledColor.withValues(alpha: 0.7),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}
