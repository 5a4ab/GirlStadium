// A simple model representing one football team, built from the
// API-Football /teams?team=TEAM_ID response.
class Team {
  final int id;
  final String name;
  final String? logo;
  final String? country;
  final int? founded;
  final bool national;
  final String? venueName;
  final String? venueAddress;
  final String? venueCity;
  final int? venueCapacity;

  Team({
    required this.id,
    required this.name,
    this.logo,
    this.country,
    this.founded,
    this.national = false,
    this.venueName,
    this.venueAddress,
    this.venueCity,
    this.venueCapacity,
  });

  // Builds a Team from one item in the API-Football /teams response
  // (response[0]), which contains a "team" object and a "venue"
  // object side by side.
  factory Team.fromJson(Map<String, dynamic> json) {
    final teamJson = json['team'] as Map<String, dynamic>?;
    final venueJson = json['venue'] as Map<String, dynamic>?;

    return Team(
      id: teamJson?['id'] as int? ?? 0,
      name: teamJson?['name'] as String? ?? 'Unknown Team',
      logo: teamJson?['logo'] as String?,
      country: teamJson?['country'] as String?,
      founded: teamJson?['founded'] as int?,
      national: teamJson?['national'] as bool? ?? false,
      venueName: venueJson?['name'] as String?,
      venueAddress: venueJson?['address'] as String?,
      venueCity: venueJson?['city'] as String?,
      venueCapacity: venueJson?['capacity'] as int?,
    );
  }
}