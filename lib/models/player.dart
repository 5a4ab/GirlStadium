// A simple model representing one player in a team's squad, built
// from the API-Football /players/squads response.
class Player {
  final int id;
  final String name;
  final String? photo;
  final int? age;
  final int? number;
  final String? position;
  final String? nationality;
  final String? team;

  Player({
    required this.id,
    required this.name,
    this.photo,
    this.age,
    this.number,
    this.position,
    this.nationality,
    this.team,
  });

  // Builds a Player from one item in the "players" list inside the
  // /players/squads response (response[0].players[i]).
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Player',
      photo: json['photo'] as String?,
      age: json['age'] as int?,
      number: json['number'] as int?,
      position: json['position'] as String?,
    );
  }

  // Builds a Player from one item in the /players?id=&season=
  // response (response[i]), which nests the player's profile under
  // "player" and their season stats (including current club) under
  // "statistics". Used for the Home Featured Player.
  factory Player.fromProfileJson(Map<String, dynamic> json) {
    final playerJson = json['player'] as Map<String, dynamic>?;
    final statisticsJson = json['statistics'] as List<dynamic>?;
    final firstStats = (statisticsJson != null && statisticsJson.isNotEmpty)
        ? statisticsJson.first as Map<String, dynamic>?
        : null;
    final teamJson = firstStats?['team'] as Map<String, dynamic>?;
    final gamesJson = firstStats?['games'] as Map<String, dynamic>?;

    return Player(
      id: playerJson?['id'] as int? ?? 0,
      name: playerJson?['name'] as String? ?? 'Unknown Player',
      photo: playerJson?['photo'] as String?,
      age: playerJson?['age'] as int?,
      position: gamesJson?['position'] as String?,
      nationality: playerJson?['nationality'] as String?,
      team: teamJson?['name'] as String?,
    );
  }
}