class Player {
  final String name;
  final String position;
  final int ovr;
  final int age;
  final String nationality;
  final String imagePath;
  final String flagPath;
  late final String badge;

  Player(
      {required this.name,
      required this.position,
      required this.ovr,
      required this.age,
      required this.nationality,
      required this.imagePath,
      required this.flagPath}) {
    badge = _calculateBadge();
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      position: json['position'],
      ovr: json['ovr'],
      age: json['age'],
      nationality: json['nationality'],
      imagePath: json['imagePath'],
      flagPath: json['flagPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'ovr': ovr,
      'age': age,
      'nationality': nationality,
      'imagePath': imagePath,
      'flagPath': flagPath,
    };
  }

  String _calculateBadge() {
    if (ovr >= 201) {
      return 'purple';
    } else if (ovr >= 151 && ovr < 200) {
      return 'gold';
    } else if (ovr >= 101 && ovr < 150) {
      return 'silver';
    } else {
      return 'bronze';
    }
  }
}
