import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class StadiumPage extends StatefulWidget {
  const StadiumPage({super.key});

  @override
  State<StadiumPage> createState() => _StadiumPageState();
}

class _StadiumPageState extends State<StadiumPage> {
  bool _isLoading = true; // Flaga do śledzenia stanu ładowania
  late Image _stadiumImage; // Zmienna przechowująca wczytane zdjęcie stadionu

  @override
  void initState() {
    super.initState();
    _loadStadiumImage(); // Rozpoczęcie procesu ładowania zdjęcia w momencie inicjalizacji widoku
  }

  // Synchroniczna funkcja wczytująca obraz z lokalnej ścieżki
  void _loadStadiumImage() {
    // Wczytanie obrazu z lokalnej ścieżki
    _stadiumImage = Image.asset('assets/background/stadium_bg.png');

    // Ustawienie flagi na false po wczytaniu obrazu
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.hoverColor,
        toolbarHeight: 1,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Warunkowe wyświetlanie CircularProgressIndicator w zależności od stanu ładowania
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _stadiumImage != null
                  ? Image(image: _stadiumImage.image, fit: BoxFit.cover)
                  : const Text('Błąd ładowania obrazu'),
        ],
      ),
    );
  }
}
