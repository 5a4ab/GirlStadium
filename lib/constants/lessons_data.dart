import 'package:flutter/material.dart';
import '../models/lesson.dart';

// The complete local list of football lessons shown on the Learn
// Screen. This is static content - no API or database is used.
final List<Lesson> lessons = [
  Lesson(
    id: 'offside',
    title: 'What is Offside?',
    description: 'Understand the offside rule in simple terms.',
    readTime: '2 min read',
    category: 'Rules',
    icon: Icons.sports_soccer,
    content: [
      "Football's offside rule prevents attacking players from gaining "
          "an unfair advantage by waiting near the opponent's goal.",
      "A player is in an offside position if they are nearer to the "
          "opponent's goal line than both the ball and the second-last "
          "defender when the ball is played.",
      'Being in an offside position is not always an offence.',
      'A player is only penalized if they become actively involved '
          'in play.',
    ],
    tips: [
      'Stay behind the second-last defender.',
      'Offside is judged when the pass is made.',
      'Goalkeepers are not always the last defender.',
    ],
  ),
  Lesson(
    id: 'cards',
    title: 'Red Card vs Yellow Card',
    description: 'Learn the difference between football cards.',
    readTime: '2 min read',
    category: 'Rules',
    icon: Icons.square,
    content: [
      'Referees use colored cards to manage player discipline during '
          'a match.',
      "A yellow card is a warning. It's shown for reckless fouls, "
          'unsporting behavior, or delaying the game.',
      'Two yellow cards in the same match automatically result in a '
          'red card, sending the player off.',
      'A red card sends a player off immediately, and their team must '
          'continue with one fewer player for the rest of the match.',
    ],
    tips: [
      'A second yellow card always becomes a red card.',
      'A sent-off player cannot be replaced by a substitute.',
      'Serious fouls can result in a direct red card.',
    ],
  ),
  Lesson(
    id: 'champions-league',
    title: 'What is the Champions League?',
    description: "Europe's top club football competition.",
    readTime: '3 min read',
    category: 'Competitions',
    icon: Icons.emoji_events,
    content: [
      'The UEFA Champions League is the top European club competition, '
          'bringing together the best teams from each country.',
      "Teams qualify by finishing near the top of their domestic "
          "league the previous season.",
      'The competition starts with a league phase, followed by '
          'knockout rounds, and ends with a single final match.',
      'Winning the Champions League is considered one of the biggest '
          'achievements in club football.',
    ],
    tips: [
      'Only top-performing clubs from each league qualify.',
      'The final is played at a different neutral stadium each year.',
      'It runs alongside domestic league competitions.',
    ],
  ),
  Lesson(
    id: 'hat-trick',
    title: 'What is a Hat-trick?',
    description: 'When a player scores three goals in one match.',
    readTime: '1 min read',
    category: 'Players',
    icon: Icons.sports_soccer,
    content: [
      'A hat-trick happens when a single player scores three goals in '
          'one match.',
      "The goals don't need to be scored in a row, but they must all "
          'come from the same player in the same game.',
      'Scoring a hat-trick is seen as a standout individual '
          'performance.',
      "Some matches also feature a 'perfect hat-trick' - scoring with "
          'the left foot, right foot, and head.',
    ],
    tips: [
      'All three goals must be scored by the same player.',
      'They can happen at any point during the match.',
      'Hat-tricks are often celebrated by fans with a special cheer.',
    ],
  ),
  Lesson(
    id: 'var',
    title: 'What is VAR?',
    description: 'How video technology helps referees decide.',
    readTime: '3 min read',
    category: 'Referees',
    icon: Icons.tv,
    content: [
      'VAR stands for Video Assistant Referee, a team of officials who '
          'review key decisions using video replays.',
      'VAR can review goals, penalties, red cards, and cases of '
          'mistaken identity.',
      'The main referee can check the pitchside monitor before making '
          'a final decision.',
      'VAR is used to correct clear and obvious errors, not to review '
          'every decision in the match.',
    ],
    tips: [
      'VAR only steps in for clear, obvious mistakes.',
      'The final decision is always made by the on-field referee.',
      'VAR checks happen for goals, penalties, and red cards.',
    ],
  ),
  Lesson(
    id: 'extra-time-penalties',
    title: 'Extra Time vs Penalties',
    description: 'What happens when a match ends in a draw.',
    readTime: '2 min read',
    category: 'Rules',
    icon: Icons.timer_outlined,
    content: [
      'When a knockout match ends in a draw, some competitions use '
          'extra time to decide a winner.',
      'Extra time consists of two additional periods, usually 15 '
          'minutes each.',
      'If the score is still level after extra time, the match is '
          'decided by a penalty shootout.',
      'In a penalty shootout, each team takes turns taking penalty '
          'kicks until a winner is determined.',
    ],
    tips: [
      'Extra time only applies to knockout matches, not league games.',
      'Away goals or replays may apply depending on the competition.',
      'Penalty shootouts start with five kicks per team.',
    ],
  ),
];
