// A simple model representing one football fixture.
// This only holds the information currently needed by FixtureCard:
// id, date/time, home team, away team, league, and status.
class Fixture {
  final int id;
  final DateTime? dateTime;
  final String homeTeam;
  final String awayTeam;
  final String league;
  final String? status;
  final int? homeScore;
  final int? awayScore;
  final int? elapsed;

  Fixture({
    required this.id,
    required this.dateTime,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    this.status,
    this.homeScore,
    this.awayScore,
    this.elapsed,
  });

  // Builds a Fixture from one item in the API-Football /fixtures response.
  // Uses nullable/defaulted values since the API may not always provide
  // every field.
  factory Fixture.fromJson(Map<String, dynamic> json) {
    final fixtureJson = json['fixture'] as Map<String, dynamic>?;
    final leagueJson = json['league'] as Map<String, dynamic>?;
    final teamsJson = json['teams'] as Map<String, dynamic>?;
    final homeTeamJson = teamsJson?['home'] as Map<String, dynamic>?;
    final awayTeamJson = teamsJson?['away'] as Map<String, dynamic>?;
    final statusJson = fixtureJson?['status'] as Map<String, dynamic>?;
    final goalsJson = json['goals'] as Map<String, dynamic>?;

    DateTime? parsedDate;
    final dateString = fixtureJson?['date'] as String?;
    if (dateString != null) {
      parsedDate = DateTime.tryParse(dateString);
    }

    return Fixture(
      id: fixtureJson?['id'] as int? ?? 0,
      dateTime: parsedDate,
      homeTeam: homeTeamJson?['name'] as String? ?? 'TBD',
      awayTeam: awayTeamJson?['name'] as String? ?? 'TBD',
      league: leagueJson?['name'] as String? ?? 'Unknown League',
      status: statusJson?['short'] as String?,
      homeScore: goalsJson?['home'] as int?,
      awayScore: goalsJson?['away'] as int?,
      elapsed: statusJson?['elapsed'] as int?,
    );
  }

  // Formats the kickoff time as HH:mm for display in FixtureCard.
  // Returns a placeholder if the date is missing.
  String get formattedTime {
    if (dateTime == null) return '--:--';
    final local = dateTime!.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // True while this fixture is currently being played. Matches the
  // same status codes used by MatchDetails.isLive.
  bool get isLive =>
      status == '1H' || status == '2H' || status == 'HT' || status == 'ET' || status == 'P';

  // True while this fixture hasn't started yet.
  bool get isUpcoming => status == 'NS';

  // Score values as display-ready strings. Shows "-" instead of
  // inventing a 0 when the match hasn't started yet.
  String get homeScoreDisplay => homeScore?.toString() ?? '-';
  String get awayScoreDisplay => awayScore?.toString() ?? '-';

  // A short label for the current match minute, used on live match
  // cards (e.g. "45'" or "HT").
  String get minuteLabel {
    if (status == 'HT') return 'HT';
    return elapsed != null ? "$elapsed'" : '';
  }
}