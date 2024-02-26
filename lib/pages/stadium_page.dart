import 'package:flutter/material.dart';

class StadiumPage extends StatefulWidget {
  const StadiumPage({super.key});

  @override
  State<StadiumPage> createState() => _StadiumPageState();
}

class _StadiumPageState extends State<StadiumPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Stadium")
    );
  }
}