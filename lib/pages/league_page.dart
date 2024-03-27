import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class LeaguePage extends StatefulWidget {
  const LeaguePage({super.key});

  @override
  State<LeaguePage> createState() => _LeaguePageState();
}

class _LeaguePageState extends State<LeaguePage> {
  bool _isLoading = true; // Flaga do śledzenia stanu ładowania
  late Image _leagueBackgroundImage; // Zmienna przechowująca wczytane tło ligi

  @override
  void initState() {
    super.initState();
    _loadLeagueBackgroundImage(); // Rozpoczęcie procesu ładowania tła ligi w momencie inicjalizacji widoku
  }

  // Synchroniczna funkcja wczytująca obraz tła ligi z lokalnej ścieżki
  void _loadLeagueBackgroundImage() {
    // Wczytanie obrazu z lokalnej ścieżki
    _leagueBackgroundImage = Image.asset('assets/background/league_bg.png');

    // Ustawienie flagi na false po wczytaniu obrazu
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'L E A G U E   1',
          style: TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.hoverColor,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Warunkowe wyświetlanie CircularProgressIndicator w zależności od stanu ładowania
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _leagueBackgroundImage != null
                  ? Image(
                      image: _leagueBackgroundImage.image, fit: BoxFit.cover)
                  : const Text('Błąd ładowania tła ligi'),
        ],
      ),
    );
  }
}
