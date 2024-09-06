import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/design/colors.dart';

class ReusableAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double appBarHeight;

  const ReusableAppBar({
    super.key,
    required this.appBarHeight,
  });

  @override
  State<ReusableAppBar> createState() => _ReusableAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

class _ReusableAppBarState extends State<ReusableAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.textEnabledColor),
      backgroundColor: AppColors.hoverColor,
      centerTitle: true,
      title: StreamBuilder<Map<String, dynamic>>(
        stream: FirebaseFunctions.getUserDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data ?? {};
          final money = (userData['money'] ?? 0).toDouble();

          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoRow(
                        UniconsLine.usd_circle, money.toStringAsFixed(0)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textEnabledColor),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            color: AppColors.textEnabledColor,
          ),
        ),
      ],
    );
  }
}
