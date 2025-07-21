import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:unicons/unicons.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/design/colors.dart';

class ReusableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double appBarHeight;

  const ReusableAppBar({
    super.key,
    required this.appBarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.textEnabledColor),
      backgroundColor: AppColors.hoverColor,
      centerTitle: true,
      title: const _MoneyDisplay(),
    );
  }
}

// Separate widget for money display to isolate rebuilds
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

        if (snapshot.hasError) {
          return _ErrorDisplay(error: snapshot.error.toString());
        }

        final userData = snapshot.data ?? {};
        final money = (userData['money'] ?? 0).toDouble();

        return _MoneyRow(money: money);
      },
    );
  }
}

// Separate loading widget to avoid rebuilding
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: LoadingAnimationWidget.waveDots(
          color: AppColors.textEnabledColor,
          size: 50,
        ),
      ),
    );
  }
}

// Separate error widget
class _ErrorDisplay extends StatelessWidget {
  final String error;

  const _ErrorDisplay({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Error: $error',
        style: const TextStyle(
          color: AppColors.textEnabledColor,
          fontSize: 14,
        ),
      ),
    );
  }
}

// Optimized money display with RepaintBoundary
class _MoneyRow extends StatelessWidget {
  final double money;

  const _MoneyRow({required this.money});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min, // Optimize layout
        children: [
          _InfoRow(
            icon: UniconsLine.usd_circle,
            text: money.toStringAsFixed(0),
          ),
        ],
      ),
    );
  }
}

// Optimized info row widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.textEnabledColor,
          size: 20, // Explicit size for better performance
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: _textStyle, // Use cached style
        ),
      ],
    );
  }

  // Cache the TextStyle to avoid recreation
  static const TextStyle _textStyle = TextStyle(
    fontSize: 20,
    color: AppColors.textEnabledColor,
  );
}

// Optional: Add a memoized version for high-frequency updates
class _MemoizedMoneyDisplay extends StatefulWidget {
  const _MemoizedMoneyDisplay();

  @override
  State<_MemoizedMoneyDisplay> createState() => _MemoizedMoneyDisplayState();
}

class _MemoizedMoneyDisplayState extends State<_MemoizedMoneyDisplay> {
  double? _lastMoney;
  Widget? _cachedWidget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirebaseFunctions.getUserDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingIndicator();
        }

        if (snapshot.hasError) {
          return _ErrorDisplay(error: snapshot.error.toString());
        }

        final userData = snapshot.data ?? {};
        final money = (userData['money'] ?? 0).toDouble();

        // Only rebuild if money value actually changed
        if (_lastMoney != money) {
          _lastMoney = money;
          _cachedWidget = _MoneyRow(money: money);
        }

        return _cachedWidget!;
      },
    );
  }
}
