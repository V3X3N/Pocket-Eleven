import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class StadiumPage extends StatefulWidget {
  const StadiumPage({super.key});

  @override
  State<StadiumPage> createState() => _StadiumPageState();
}

class _StadiumPageState extends State<StadiumPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.hoverColor,
        toolbarHeight: 50,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your club',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Image.asset(
                    'assets/crests/crest_1.png',
                    height: 40,
                    width: 40,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            Container(
              height: 350,
              color: AppColors.primaryColor,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildListItem(
                    color: Colors.blue,
                    text: 'Option 1',
                    onPressed: () {
                      print('Option 1 selected');
                    },
                  ),
                  _buildListItem(
                    color: Colors.red,
                    text: 'Option 2',
                    onPressed: () {
                      print('Option 2 selected');
                    },
                  ),
                  _buildListItem(
                    color: Colors.green,
                    text: 'Option 3',
                    onPressed: () {
                      print('Option 3 selected');
                    },
                  ),
                  _buildListItem(
                    color: Colors.orange,
                    text: 'Option 4',
                    onPressed: () {
                      print('Option 4 selected');
                    },
                  ),
                  _buildListItem(
                    color: Colors.purple,
                    text: 'Option 5',
                    onPressed: () {
                      print('Option 5 selected');
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required Color color,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
