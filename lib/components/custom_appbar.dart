import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:unicons/unicons.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/design/colors.dart';

class ReusableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;

  const ReusableAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = showBackButton && Navigator.canPop(context);

    return Container(
      decoration: _buildGradientDecoration(),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: kToolbarHeight,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    if (canPop) const _BackButton(),
                    if (title != null) ...[
                      const Spacer(),
                      Flexible(child: _TitleWidget(title: title!)),
                      const Spacer(),
                    ] else if (!canPop)
                      const Spacer(),
                    const _MoneyDisplay(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.hoverColor,
          AppColors.hoverColor.withValues(alpha: 0.85),
          AppColors.hoverColor.withValues(alpha: 0.7),
        ],
        stops: const [0.0, 0.6, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          offset: const Offset(0, 4),
          blurRadius: 16,
          spreadRadius: -2,
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: _buildButtonDecoration(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                UniconsLine.arrow_left,
                color: AppColors.textEnabledColor,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildButtonDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0.08),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ],
    );
  }
}

class _TitleWidget extends StatelessWidget {
  final String title;

  const _TitleWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            AppColors.textEnabledColor,
            AppColors.textEnabledColor.withValues(alpha: 0.9),
          ],
        ).createShader(bounds),
        child: Text(
          title,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _MoneyDisplay extends StatelessWidget {
  const _MoneyDisplay();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirebaseFunctions.getUserDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingIndicator();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const _ErrorDisplay();
        }

        final money = ((snapshot.data?['money'] ?? 0) as num).toDouble();
        return _MoneyContainer(money: money);
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: 8,
        ),
        decoration: _buildContainerDecoration(),
        child: LoadingAnimationWidget.threeArchedCircle(
          color: AppColors.textEnabledColor,
          size: 16,
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.08),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  const _ErrorDisplay();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              UniconsLine.exclamation_triangle,
              color: Colors.red.shade300,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'Error',
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyContainer extends StatelessWidget {
  final double money;

  const _MoneyContainer({required this.money});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03,
          vertical: 6,
        ),
        decoration: _buildMoneyDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMoneyIcon(),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            Text(
              _formatMoney(money),
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.w800,
                color: AppColors.textEnabledColor,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildMoneyDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.05),
        ],
        stops: const [0.0, 0.6, 1.0],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.08),
          offset: const Offset(0, -1),
          blurRadius: 6,
        ),
      ],
    );
  }

  Widget _buildMoneyIcon() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.25),
            Colors.green.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        UniconsLine.usd_circle,
        color: Colors.green.shade200,
        size: 16,
      ),
    );
  }

  String _formatMoney(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
    }
    return amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1);
  }
}
