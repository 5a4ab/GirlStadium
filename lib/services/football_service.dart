import '../models/fixture.dart';
import '../models/standing.dart';
import '../models/match_details.dart';
import '../models/team.dart';
import '../models/player.dart';
import 'api_service.dart';

// This class holds all football-specific API calls.
// It knows how to talk to specific football endpoints (status,
// fixtures, standings, match details, teams, and later players), and
// turns the raw JSON response into simple Dart objects for the UI
// to use.
class FootballService {
  final ApiService _apiService = ApiService();

  // Calls GET /status to check that the API key and connection
  // are working correctly. Returns the decoded JSON response.
  Future<Map<String, dynamic>> getStatus() {
    return _apiService.get('/status');
  }

  // Calls GET /fixtures and returns a list of parsed Fixture objects.
  //
  // You can request fixtures either for a single day (using [date])
  // or for a range of days (using [from] and [to]). Dates must be
  // formatted as 'YYYY-MM-DD'.
  //
  // [leagueId] and [season] are optional. The API-Football fixtures
  // endpoint requires both together when filtering by league.
  Future<List<Fixture>> getFixtures({
    String? date,
    String? from,
    String? to,
    int? leagueId,
    int? season,
  }) async {
    final Map<String, String> queryParams = {};

    if (date != null) queryParams['date'] = date;
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (leagueId != null) queryParams['league'] = leagueId.toString();
    if (season != null) queryParams['season'] = season.toString();

    final response = await _apiService.get(
      '/fixtures',
      queryParams: queryParams,
    );

    final fixturesJson = response['response'] as List<dynamic>? ?? [];

    return fixturesJson
        .map((item) => Fixture.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Calls GET /standings for the given league and season, and returns
  // a list of parsed Standing objects (one per team in the table).
  Future<List<Standing>> getStandings({
    required int leagueId,
    required int season,
  }) async {
    final response = await _apiService.get(
      '/standings',
      queryParams: {
        'league': leagueId.toString(),
        'season': season.toString(),
      },
    );

    // The standings table is nested fairly deeply in the API response:
    // response -> [0] -> league -> standings -> [0] -> [ ...rows ]
    final responseList = response['response'] as List<dynamic>? ?? [];
    if (responseList.isEmpty) return [];

    final firstEntry = responseList.first as Map<String, dynamic>?;
    final leagueJson = firstEntry?['league'] as Map<String, dynamic>?;
    final standingsGroups = leagueJson?['standings'] as List<dynamic>?;
    if (standingsGroups == null || standingsGroups.isEmpty) return [];

    // Most leagues have a single group (one flat table). Some
    // competitions (like group-stage tournaments) return multiple
    // groups; we combine them here to keep this simple.
    final List<Standing> allStandings = [];
    for (final group in standingsGroups) {
      final rows = group as List<dynamic>;
      allStandings.addAll(
        rows.map((row) => Standing.fromJson(row as Map<String, dynamic>)),
      );
    }

    return allStandings;
  }

  // Calls GET /fixtures?id=FIXTURE_ID to retrieve everything needed
  // for the Match Details screen (match info, events, and
  // statistics) in a single request.
  //
  // Returns null if the API reports zero results for this fixture ID,
  // so the screen can show a friendly "unavailable" message instead
  // of treating it as an error.
  Future<MatchDetails?> getMatchDetails(int fixtureId) async {
    final response = await _apiService.get(
      '/fixtures',
      queryParams: {'id': fixtureId.toString()},
    );

    final results = response['results'] as int? ?? 0;
    final responseList = response['response'] as List<dynamic>? ?? [];

    if (results == 0 || responseList.isEmpty) {
      return null;
    }

    return MatchDetails.fromJson(responseList.first as Map<String, dynamic>);
  }

  // Calls GET /teams?id=TEAM_ID to retrieve information about a
  // single team. Makes exactly one request.
  //
  // Returns null if the API reports zero results for this team ID,
  // so the screen can show a friendly "unavailable" message instead
  // of treating it as an error.
  Future<Team?> getTeamDetails(int teamId) async {
    final response = await _apiService.get(
      '/teams',
      queryParams: {'id': teamId.toString()},
    );

    final results = response['results'] as int? ?? 0;
    final responseList = response['response'] as List<dynamic>? ?? [];

    if (results == 0 || responseList.isEmpty) {
      return null;
    }

    final teamJson = responseList.first as Map<String, dynamic>;
    return Team.fromJson(teamJson);
  }

  // Calls GET /players?id=PLAYER_ID&season=SEASON to retrieve one
  // player's profile and current club for the given season. Makes
  // exactly one request. Used for the Home Featured Player.
  //
  // Returns null if the API reports zero results for this player ID,
  // so the screen can show a friendly "unavailable" message instead
  // of treating it as an error.
  Future<Player?> getPlayerProfile({
    required int playerId,
    required int season,
  }) async {
    final response = await _apiService.get(
      '/players',
      queryParams: {
        'id': playerId.toString(),
        'season': season.toString(),
      },
    );

    final results = response['results'] as int? ?? 0;
    final responseList = response['response'] as List<dynamic>? ?? [];

    if (results == 0 || responseList.isEmpty) {
      return null;
    }

    return Player.fromProfileJson(responseList.first as Map<String, dynamic>);
  }

  // Calls GET /players/squads?team=TEAM_ID to retrieve the current
  // squad for a team. Makes exactly one request.
  //
  // Returns an empty list if the API reports zero results, so the
  // screen can show a friendly "no squad" message instead of
  // treating it as an error.
  Future<List<Player>> getTeamSquad(int teamId) async {
    final response = await _apiService.get(
      '/players/squads',
      queryParams: {'team': teamId.toString()},
    );

    final results = response['results'] as int? ?? 0;
    final responseList = response['response'] as List<dynamic>? ?? [];

    if (results == 0 || responseList.isEmpty) {
      return [];
    }

    final firstEntry = responseList.first as Map<String, dynamic>?;
    final playersJson = firstEntry?['players'] as List<dynamic>? ?? [];

    return playersJson
        .map((item) => Player.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}