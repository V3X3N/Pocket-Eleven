import 'dart:math';

class MatchScheduler {
  // Losuje wynik meczu
  static Map<String, int> simulateMatch(String club1, String club2) {
    Random random = Random();
    int score1 = random.nextInt(3); // Wynik od 0 do 2
    int score2 = random.nextInt(3);
    return {club1: score1, club2: score2};
  }

  // Generuje harmonogram meczów
  static List<Map<String, int>> generateMatches(List<String> clubs) {
    List<Map<String, int>> matches = [];
    for (int i = 0; i < clubs.length - 1; i++) {
      for (int j = i + 1; j < clubs.length; j++) {
        matches.add(simulateMatch(clubs[i], clubs[j]));
      }
    }
    return matches;
  }
}
