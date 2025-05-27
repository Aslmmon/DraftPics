// lib/ui/team_details/widgets/player_list_item.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/model/PlayerModel.dart'; // Ensure correct PlayerModel import
import '../../../utils/app_constants.dart'; // Import constants
import 'full_screen_qr_dialog.dart'; // Your QR dialog widget

class PlayerListItem extends StatelessWidget {
  final Player player;
  final TextTheme textTheme;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed; // Add a callback for delete

  const PlayerListItem({
    super.key,
    required this.player,
    required this.textTheme,
    this.onEditPressed,
    this.onDeletePressed, // Initialize delete callback
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
      child: Row(
        children: [
          // Player Image (Male/Female)
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            // Smaller radius for player image
            child: Image.asset(
              "assets/images/player_image.png",
              width: 50, // Example size
              height: 50, // Example size
              fit: BoxFit.cover,
            ),
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
                  "${AppConstants.playerDetailsHeading.split(' ').first} : ${player.jerseyNumber}",
                  // Use constant and split
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                // Text(
                //   "${AppConstants.playerGender} : ${player.gender == Gender.male ? AppConstants.playerGenderMale : AppConstants.playerGenderFemale}",
                //   style: textTheme.bodyMedium?.copyWith(
                //     color: Colors.grey[600],
                //   ),
                // ),
                Text(
                  "${AppConstants.capturedStatusHeading} : ${player.isCaptured ? "✅" : "❌"}", // Use constant
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // QR Code Button
          GestureDetector(
            onTap: () {
              Get.dialog(
                FullScreenQrDialog(
                  qrData: player.toString(), // Pass the data you want to encode
                ),
              );
            },
            child: QrImageView(
              data: player.toString(),
              version: QrVersions.auto,
              size: 55.0, // Adjust size for list item
            ),
          ),
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey),
            onPressed: onEditPressed,
          ),
          // Delete Button (New)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDeletePressed, // Use the new callback
          ),
        ],
      ),
    );
  }
}
