String formatPlayerName(String fullName) {
  List<String> nameParts = fullName.split(' ');

  if (nameParts.length >= 2) {
    String firstName = nameParts[0];
    String lastName = nameParts[1];

    return '${firstName[0]}. $lastName';
  }

  return fullName;
}
