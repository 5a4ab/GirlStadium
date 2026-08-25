// A simple model representing one team's row in a league standings
// table. This only holds the information currently needed by the
// Standings Screen and StandingRow widget.
class Standing {
  final int position;
  final int? teamId;
  final String teamName;
  final String? teamLogo;
  final int played;
  final int goalDifference;
  final int points;
  final String? form;

  Standing({
    required this.position,
    required this.teamId,
    required this.teamName,
    this.teamLogo,
    required this.played,
    required this.goalDifference,
    required this.points,
    this.form,
  });

  // Builds a Standing from one item in the API-Football /standings
  // response (one entry inside league.standings[0]).
  factory Standing.fromJson(Map<String, dynamic> json) {
    final teamJson = json['team'] as Map<String, dynamic>?;
    final allJson = json['all'] as Map<String, dynamic>?;

    return Standing(
      position: json['rank'] as int? ?? 0,
      teamId: teamJson?['id'] as int?,
      teamName: teamJson?['name'] as String? ?? 'Unknown Team',
      teamLogo: teamJson?['logo'] as String?,
      played: allJson?['played'] as int? ?? 0,
      goalDifference: json['goalsDiff'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      form: json['form'] as String?,
    );
  }

  // Formats the goal difference with a leading "+" for positive values,
  // matching the existing UI style (e.g. "+45", "-1").
  String get formattedGoalDifference {
    if (goalDifference > 0) return '+$goalDifference';
    return '$goalDifference';
  }
}