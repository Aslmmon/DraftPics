// lib/ui/team_details/widgets/players_heading_section.dart
import 'package:flutter/material.dart';
import '../../../../../utils/app_constants.dart'; // Import constants

class PlayersHeadingSection extends StatelessWidget {
  final TextTheme textTheme;

  const PlayersHeadingSection({
    super.key,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        AppConstants.playersHeading, // Use constant
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}