import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_eleven/pages/main_menu.dart';
import 'image_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(Builder(
    builder: (context) {
      print('preloading images...');
      ImageLoader.precacheImages(context);
      print('all assets loaded, launching the app...');

      return const MyApp();
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: MainMenu(),
      ),
    );
  }
}
