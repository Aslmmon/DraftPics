import 'package:draftpics/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:reutilizacao/ui/components/AppTextField.dart';

// --- Dummy Data Models ---
// Example of updated Team model in your data models file (e.g., team_model.dart)
// or within your home_screen_ui.dart if currently there.
class Team {
  final String id;
  final String name;
  final int playerCount;
  final String? division; // Added for Team Details
  final String? imageUrl; // Added for team image
  final IconData? icon; // Existing icon if used for list item

  Team({
    required this.id,
    required this.name,
    required this.playerCount,
    this.division,
    this.imageUrl,
    this.icon,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenUIState();
}

class _HomeScreenUIState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy Data for Teams
  final List<Team> _allTeams = [
    Team(
      id: '1',
      name: 'The Eagles',
      playerCount: 12,
      icon: Icons.sports_soccer,
    ),
    Team(
      id: '2',
      name: 'The Lions',
      playerCount: 15,
      icon: Icons.sports_football,
    ),
    Team(
      id: '3',
      name: 'The Tigers',
      playerCount: 10,
      icon: Icons.sports_basketball,
    ),
    Team(
      id: '4',
      name: 'The Bears',
      playerCount: 11,
      icon: Icons.sports_baseball,
    ),
    Team(
      id: '5',
      name: 'The Wolves',
      playerCount: 8,
      icon: Icons.catching_pokemon,
    ),
    Team(id: '6', name: 'The Hawks', playerCount: 14, icon: Icons.flight),
  ];

  List<Team> _filteredTeams = [];

  @override
  void initState() {
    super.initState();
    _filteredTeams = _allTeams; // Initially show all teams
    _searchController.addListener(_filterTeams);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTeams);
    _searchController.dispose();
    super.dispose();
  }

  void _filterTeams() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTeams =
          _allTeams.where((team) {
            return team.name.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the global text theme (with Manrope)
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teams',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold, // Adjust weight
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 30),
            // Plus icon
            onPressed: () {
              print('Add new team button pressed!');
              // Navigate to add team screen
            },
          ),
          const SizedBox(width: 16), // Padding for the icon
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Align "My Teams" to start
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: ReusableTextField(
              controller: _searchController,
              hintText: 'Search teams...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16), // Spacing after search bar

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'My Teams',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, // Make it bold
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16), // Spacing after "My Teams" heading

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: _filteredTeams.length,
              itemBuilder: (context, index) {
                final team = _filteredTeams[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.teamDetails, arguments: team);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, // Card background
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(
                              0,
                              3,
                            ), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Team Icon - Mimicking the rounded square look
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              // Light grey background for icon
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Rounded corners
                            ),
                            child: Icon(
                              team.icon, // Your dummy icon
                              color: Colors.blue[700], // Icon color
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                team.name,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${team.playerCount} players',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
