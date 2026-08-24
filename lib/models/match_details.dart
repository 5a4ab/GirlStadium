// A simple model representing one event during a match
// (a goal, a card, or a substitution).
class MatchEvent {
  final int? minute;
  final String? type; // e.g. "Goal", "Card", "subst"
  final String? detail; // e.g. "Normal Goal", "Yellow Card"
  final String? playerName;
  final String? assistName;
  final String? teamName;

  MatchEvent({
    this.minute,
    this.type,
    this.detail,
    this.playerName,
    this.assistName,
    this.teamName,
  });

  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    final timeJson = json['time'] as Map<String, dynamic>?;
    final teamJson = json['team'] as Map<String, dynamic>?;
    final playerJson = json['player'] as Map<String, dynamic>?;
    final assistJson = json['assist'] as Map<String, dynamic>?;

    return MatchEvent(
      minute: timeJson?['elapsed'] as int?,
      type: json['type'] as String?,
      detail: json['detail'] as String?,
      playerName: playerJson?['name'] as String?,
      assistName: assistJson?['name'] as String?,
      teamName: teamJson?['name'] as String?,
    );
  }
}

// A simple model representing one statistic row (e.g. Ball
// Possession) with a value for the home team and the away team.
class MatchStatistic {
  final String name;
  final String homeValue;
  final String awayValue;

  MatchStatistic({
    required this.name,
    required this.homeValue,
    required this.awayValue,
  });

  // Safely converts a raw API value (which may be null, a number,
  // or a string like "58%") into a display-ready string.
  static String formatValue(dynamic value) {
    if (value == null) return '-';
    return value.toString();
  }
}

// A model representing the full details of one match, built from
// the API-Football /fixtures?id=FIXTURE_ID response. This includes
// the match info, events, and statistics all in one place, since
// they all come from the same API call.
class MatchDetails {
  final int fixtureId;
  final String leagueName;
  final String? leagueLogo;
  final String? round;
  final int? homeTeamId;
  final String homeTeamName;
  final String? homeTeamLogo;
  final int? awayTeamId;
  final String awayTeamName;
  final String? awayTeamLogo;
  final int? homeScore;
  final int? awayScore;
  final String? status; // short status code, e.g. "NS", "1H", "FT"
  final int? elapsed;
  final String? venue;
  final DateTime? date;
  final List<MatchEvent> events;
  final List<MatchStatistic> statistics;

  MatchDetails({
    required this.fixtureId,
    required this.leagueName,
    this.leagueLogo,
    this.round,
    this.homeTeamId,
    required this.homeTeamName,
    this.homeTeamLogo,
    this.awayTeamId,
    required this.awayTeamName,
    this.awayTeamLogo,
    this.homeScore,
    this.awayScore,
    this.status,
    this.elapsed,
    this.venue,
    this.date,
    this.events = const [],
    this.statistics = const [],
  });

  // Builds a MatchDetails from one item in the API-Football
  // /fixtures response (response[0]).
  factory MatchDetails.fromJson(Map<String, dynamic> json) {
    final fixtureJson = json['fixture'] as Map<String, dynamic>?;
    final leagueJson = json['league'] as Map<String, dynamic>?;
    final teamsJson = json['teams'] as Map<String, dynamic>?;
    final homeTeamJson = teamsJson?['home'] as Map<String, dynamic>?;
    final awayTeamJson = teamsJson?['away'] as Map<String, dynamic>?;
    final goalsJson = json['goals'] as Map<String, dynamic>?;
    final statusJson = fixtureJson?['status'] as Map<String, dynamic>?;
    final venueJson = fixtureJson?['venue'] as Map<String, dynamic>?;

    DateTime? parsedDate;
    final dateString = fixtureJson?['date'] as String?;
    if (dateString != null) {
      parsedDate = DateTime.tryParse(dateString);
    }

    // Parse events (goals, cards, substitutions).
    final eventsJson = json['events'] as List<dynamic>? ?? [];
    final events = eventsJson
        .map((e) => MatchEvent.fromJson(e as Map<String, dynamic>))
        .toList();

    // Parse statistics. The API returns one entry per team, each
    // holding its own list of {type, value} statistics. We combine
    // them into a single list of MatchStatistic rows.
    final statisticsJson = json['statistics'] as List<dynamic>? ?? [];
    final List<MatchStatistic> statistics = [];

    if (statisticsJson.length >= 2) {
      final homeStats =
          (statisticsJson[0] as Map<String, dynamic>?)?['statistics']
          as List<dynamic>? ??
              [];
      final awayStats =
          (statisticsJson[1] as Map<String, dynamic>?)?['statistics']
          as List<dynamic>? ??
              [];

      for (final rawHomeStat in homeStats) {
        final homeStat = rawHomeStat as Map<String, dynamic>;
        final type = homeStat['type'] as String? ?? 'Unknown';

        // Find the matching away statistic with the same type name.
        Map<String, dynamic>? matchingAwayStat;
        for (final rawAwayStat in awayStats) {
          final awayStat = rawAwayStat as Map<String, dynamic>;
          if (awayStat['type'] == type) {
            matchingAwayStat = awayStat;
            break;
          }
        }

        statistics.add(
          MatchStatistic(
            name: type,
            homeValue: MatchStatistic.formatValue(homeStat['value']),
            awayValue: MatchStatistic.formatValue(matchingAwayStat?['value']),
          ),
        );
      }
    }

    return MatchDetails(
      fixtureId: fixtureJson?['id'] as int? ?? 0,
      leagueName: leagueJson?['name'] as String? ?? 'Unknown League',
      leagueLogo: leagueJson?['logo'] as String?,
      round: leagueJson?['round'] as String?,
      homeTeamId: homeTeamJson?['id'] as int?,
      homeTeamName: homeTeamJson?['name'] as String? ?? 'TBD',
      homeTeamLogo: homeTeamJson?['logo'] as String?,
      awayTeamId: awayTeamJson?['id'] as int?,
      awayTeamName: awayTeamJson?['name'] as String? ?? 'TBD',
      awayTeamLogo: awayTeamJson?['logo'] as String?,
      homeScore: goalsJson?['home'] as int?,
      awayScore: goalsJson?['away'] as int?,
      status: statusJson?['short'] as String?,
      elapsed: statusJson?['elapsed'] as int?,
      venue: venueJson?['name'] as String?,
      date: parsedDate,
      events: events,
      statistics: statistics,
    );
  }

  // Score values as display-ready strings. Shows "-" instead of
  // inventing a 0 when the match hasn't started yet.
  String get homeScoreDisplay => homeScore?.toString() ?? '-';
  String get awayScoreDisplay => awayScore?.toString() ?? '-';

  // True while the match is currently being played.
  bool get isLive =>
      status == '1H' || status == '2H' || status == 'HT' || status == 'ET' || status == 'P';

  // A short, human-friendly label for the current match status.
  String get statusLabel {
    switch (status) {
      case 'NS':
        return _formattedKickoff();
      case '1H':
        return elapsed != null ? "$elapsed'" : 'First Half';
      case 'HT':
        return 'HT';
      case '2H':
        return elapsed != null ? "$elapsed'" : 'Second Half';
      case 'ET':
        return elapsed != null ? "$elapsed'" : 'Extra Time';
      case 'P':
        return 'Penalties';
      case 'FT':
        return 'FT';
      case 'CANC':
        return 'Cancelled';
      case 'PST':
        return 'Postponed';
      default:
        return status ?? '';
    }
  }

  // Formats the kickoff date/time for matches that haven't started.
  String _formattedKickoff() {
    if (date == null) return 'Not Started';
    final local = date!.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month  $hour:$minute';
  }
}