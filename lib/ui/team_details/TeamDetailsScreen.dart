import 'package:draftpics/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';
import 'package:flutter/material.dart';



class TeamDetailsScreen extends StatelessWidget {
  const TeamDetailsScreen({super.key});

  List<Player> get _dummyPlayers {
    return [
      Player(
        id: 'p1', firstName: 'Ethan', lastName: 'Carter', position: 'Forward',
        avatarUrl: 'https://i.pravatar.cc/150?img=1', // More realistic dummy image
      ),
      Player(
        id: 'p2', firstName: 'Liam', lastName: 'Harper', position: 'Midfielder',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
      ),
      Player(
        id: 'p3', firstName: 'Noah', lastName: 'Bennett', position: 'Defender',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
      ),
      Player(
        id: 'p4', firstName: 'Oliver', lastName: 'Hayes', position: 'Goalkeeper',
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
      ),
      Player(
        id: 'p5', firstName: 'Sophia', lastName: 'Martinez', position: 'Winger',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 1. Retrieve the Team object using Get.arguments
    final Team? team = Get.arguments as Team?;

    // Handle case where no team or wrong type is passed (shouldn't happen if navigation is correct)
    if (team == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Error: Team data not found. Please navigate from a team list.'),
        ),
      );
    }

    // Now you can use the 'team' object retrieved from arguments
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back(); // Use Get.back() for GetX navigation
          },
        ),
        title: Text(
          'Team Details',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.network(
                          team.imageUrl ?? 'https://via.placeholder.com/150x100?text=Team+Image',
                          width: 150,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
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
                      Text(
                        team.division ?? 'Division N/A',
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Players',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Player List
                ..._dummyPlayers.map((player) =>
                    PlayerListItem(player: player, textTheme: textTheme),
                ).toList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton.icon(
              onPressed: () {
                print('Add Player button pressed for ${team.name}!');
                Get.toNamed(AppRoutes.playerScreen);

              },
              icon: const Icon(Icons.add),
              label: const Text('Add Player'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// PlayerListItem (unchanged)
class PlayerListItem extends StatelessWidget {
  final Player player;
  final TextTheme textTheme;

  const PlayerListItem({
    super.key,
    required this.player,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[200],
            backgroundImage: player.avatarUrl != null
                ? NetworkImage(player.avatarUrl!)
                : null,
            child: player.avatarUrl == null
                ? Icon(Icons.person, size: 30, color: Colors.blue[700])
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${player.firstName} ${player.lastName}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  player.position,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey),
            onPressed: () {
              print('Edit player ${player.firstName} pressed!');
            },
          ),
        ],
      ),
    );
  }
}
