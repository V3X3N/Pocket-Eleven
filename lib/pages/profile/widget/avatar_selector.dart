import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class AvatarSelector extends StatelessWidget {
  final Future<void> Function(int avatarIndex) updateAvatar;

  const AvatarSelector({super.key, required this.updateAvatar});

  Future<void> _updateAvatar(int avatarIndex) async {
    await updateAvatar(avatarIndex);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: AppColors.hoverColor,
            border: Border.all(color: AppColors.borderColor, width: 1),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Select Avatar',
                  style: TextStyle(
                      color: AppColors.textEnabledColor, fontSize: 18),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  final avatarIndex = index + 1;
                  return GestureDetector(
                    onTap: () {
                      _updateAvatar(avatarIndex);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/crests/crest_$avatarIndex.png'),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          width: 1,
                          color: AppColors.borderColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
