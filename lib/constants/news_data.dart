import 'package:flutter/material.dart';
import '../models/article.dart';

// The complete local list of football news articles shown on the
// News Screen and Home Screen. This is static content - News is not
// connected to a real source yet (see lib/services/news_service.dart).
final List<Article> articles = [
  Article(
    id: 'salah-contract-extension',
    title: 'Salah signs contract extension',
    description:
        'Liverpool confirm the Egyptian star will stay for two more years.',
    category: 'Transfers',
    icon: Icons.description_outlined,
    timeAgo: '5 min ago',
    content: [
      'Liverpool have confirmed that Mohamed Salah has signed a new '
          'two-year contract extension, keeping him at Anfield until 2028.',
      "The Egyptian forward has been one of the club's most important "
          'players since joining in 2017, scoring goals consistently '
          'across every competition.',
      'Manager and teammates welcomed the news, calling it a big boost '
          'for the squad heading into the new season.',
      'Salah said he was "happy to continue the journey" with the club '
          'and its supporters.',
    ],
  ),
  Article(
    id: 'arsenal-new-signing',
    title: 'Arsenal complete new signing',
    description: 'The Gunners strengthen their midfield ahead of the new season.',
    category: 'Transfers',
    icon: Icons.person_add_alt_1,
    timeAgo: '20 min ago',
    content: [
      'Arsenal have completed the signing of a new midfielder to '
          'strengthen their squad ahead of the new season.',
      'The move is expected to add more creativity and control in '
          'midfield for the Gunners.',
      "The club's manager said the new signing fits perfectly into the "
          "team's style of play.",
      'Fans have reacted positively to the news, with many excited to '
          'see the new player in action.',
    ],
  ),
  Article(
    id: 'barcelona-new-kit',
    title: 'Barcelona unveil new kit',
    description: 'The club revealed its home jersey for the upcoming campaign.',
    category: 'La Liga',
    icon: Icons.checkroom,
    timeAgo: '1 hour ago',
    content: [
      'Barcelona have officially revealed their new home kit for the '
          'upcoming season.',
      "The design includes a modern take on the club's traditional blue "
          'and red stripes.',
      "The new jersey will be worn for the first time in the team's "
          'opening match of the season.',
      'The club says the kit blends heritage with a fresh, modern look.',
    ],
  ),
  Article(
    id: 'haaland-hat-trick',
    title: 'Haaland scores another hat-trick',
    description: 'The striker continues his incredible scoring form this season.',
    category: 'Premier League',
    icon: Icons.sports_soccer,
    timeAgo: '3 hours ago',
    content: [
      'Erling Haaland continued his remarkable scoring form by netting '
          "a hat-trick in Manchester City's latest match.",
      'The Norwegian striker has now scored in almost every match so '
          'far this season.',
      'Teammates and coaching staff praised his movement and finishing '
          'in the box.',
      'Haaland said he is simply focused on helping the team win '
          'matches.',
    ],
  ),
  Article(
    id: 'champions-league-draw',
    title: 'Champions League draw announced',
    description: 'Clubs now know their opponents for the group stage.',
    category: 'Champions League',
    icon: Icons.emoji_events_outlined,
    timeAgo: '4 hours ago',
    content: [
      "The draw for this season's Champions League group stage has "
          'been announced.',
      "Several exciting matchups have been set up between Europe's "
          'biggest clubs.',
      'Fans are already looking forward to some standout fixtures in '
          'the coming months.',
      'The competition will run over several months before reaching '
          'the final in the new year.',
    ],
  ),
  Article(
    id: 'man-united-new-manager',
    title: 'Manchester United appoint new manager',
    description: 'The club confirms its new head coach ahead of the season.',
    category: 'Premier League',
    icon: Icons.groups_outlined,
    timeAgo: '6 hours ago',
    content: [
      'Manchester United have officially confirmed their new head '
          'coach ahead of the new season.',
      "The appointment comes after a thorough search by the club's "
          'board.',
      'The new manager said he is excited to work with the squad and '
          'build for the future.',
      'Supporters are hopeful the change will bring a new sense of '
          'direction to the club.',
    ],
  ),
];
