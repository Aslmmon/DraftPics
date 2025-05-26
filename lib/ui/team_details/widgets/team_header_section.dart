// lib/ui/team_details/widgets/team_header_section.dart
import 'package:flutter/material.dart';
import '../../../../../data/model/TeamModel.dart'; // Adjust path if needed

class TeamHeaderSection extends StatelessWidget {
  final Team team;
  final TextTheme textTheme;

  const TeamHeaderSection({
    super.key,
    required this.team,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          Container(
            color: Colors.grey,

            width: double.infinity,
            child: Image.asset("assets/images/logo.png", fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(
            team.name,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
