// text_formatters.dart
String formatPlayerName(String fullName) {
  List<String> nameParts = fullName.split(' ');

  // Sprawdzenie, czy imię zawiera przynajmniej dwa wyrazy
  if (nameParts.length >= 2) {
    String firstName = nameParts[0]; // Pierwszy wyraz
    String lastName = nameParts[1]; // Drugi wyraz

    // Zwracamy pierwszy wyraz jako inicjał + kropka + drugi wyraz
    return '${firstName[0]}. $lastName';
  }

  // Jeżeli imię ma tylko jeden wyraz, zwracamy je bez zmian
  return fullName;
}
