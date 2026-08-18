// Centralized, non-secret configuration for the API-Football
// integration. The actual API key and base URL come from the local
// .env file (loaded via flutter_dotenv in main.dart and read by
// ApiService) - they must never be hardcoded here.
class ApiConstants {
  // The leagues currently supported across the app, mapped to their
  // API-Football league IDs. Shared by FixturesScreen and
  // StandingsScreen so the mapping only lives in one place.
  static const Map<String, int> supportedLeagues = {
    'Premier League': 39,
    'La Liga': 140,
    'Champions League': 2,
    'Serie A': 135,
    'Bundesliga': 78,
  };

  // The season used for Standings requests. This is a fixed value
  // (not calculated from the current date) because the API-Football
  // Free plan only returns standings data for this season. Do not
  // change this without confirming Free-plan access to a newer
  // season.
  static const int standingsSeason = 2024;
}
