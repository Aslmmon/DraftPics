// lib/utils/app_constants.dart

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class AppConstants {
  // Button Texts
  static const String addPlayerButtonForm =
      'Add Player'; // Renamed to avoid clash if needed

  static const double smallDeviceBreakpoint = 600.0; // Adjust as needed

  static const String csvUploadResultTitle = 'CSV Upload Result';
  static const String csvUploadCancelledTitle = 'CSV Upload Cancelled';
  static const String csvUploadCancelledMessage = 'No CSV file selected.';
  static const String failedToUploadCsv = 'Failed to upload CSV:';

  // Section Headings / Field Labels
  static const String firstNameLabel = 'First Name';
  static const String lastNameLabel = 'Last Name';
  static const String teamLabel = 'Team';

  static const String positionLabel = 'Jersey Number';
  static const String genderLabel = 'Gender';
  static const String capturedStatusLabel = 'Photography Status';

  // Hint Texts
  static const String firstNameHint = 'firstname';
  static const String lastNameHint = 'lastname';
  static const String enterPositionHint = 'Enter position';
  static const String selectGenderHint = 'Select Gender';
  static const String selectStatusHint = 'Select Status';

  // Validation Messages
  static const String allFieldsRequiredError = 'All fields are required!';
  static const String teamIdMissingError =
      'Team ID is missing. Cannot save player.';
  static const String error = 'error';

  // Success Messages
  static const String playerAddedSuccess = 'Player added successfully!';
  static const String playerUpdatedSuccess = 'Player updated successfully!';

  // Error Messages
  static const String failedToSavePlayer = 'Failed to save player:';

  // Player Details Display (for dropdowns)
  static const String playerGenderMale = 'Male';
  static const String playerGenderFemale = 'Female';
  static const String playerCapturedYes = 'Yes (Photographed)';
  static const String playerCapturedNo = 'No (Not Photographed)';

  // App Titles
  static const String appName = 'DraftPicks';
  static const String teamsScreenTitle = 'Teams';
  static const String teamDetailsScreenTitle = 'Team Details';
  static const String addPlayerScreenTitle = 'Add Player';
  static const String editPlayerScreenTitle = 'Edit Player';
  static const String addTeamScreenTitle = 'Add New Team';

  // Button Texts
  static const String addPlayerButton = 'Add Player';
  static const String saveChangesButton = 'Save Changes';
  static const String addTeamButton = 'Add Team';
  static const String deleteButton = 'Delete';
  static const String cancelButton = 'Cancel';
  static const String yesButton = 'Yes';
  static const String noButton = 'No';

  // Section Headings
  static const String myTeamsHeading = 'My Teams';
  static const String playersHeading = 'Players';
  static const String playerDetailsHeading = 'Jersey Details';
  static const String capturedStatusHeading = 'Photography Status';

  // Hint Texts
  static const String searchTeamsHint = 'Search teams...';
  static const String enterTeamNameHint = 'Enter team name';

  // Validation Messages
  static const String teamNameEmptyError = 'Team name cannot be empty.';

  // Success Messages
  static const String teamAddedSuccess = 'Team added successfully!';
  static const String teamDeletedSuccess = 'Team deleted successfully!';

  // Error Messages
  static const String failedToAddTeam = 'Failed to add team:';
  static const String failedToDeleteTeam = 'Failed to delete team:';

  // Empty/Search State Messages
  static const String noTeamsFoundSearch =
      'No teams found matching your search.';
  static const String noTeamsAddedYet =
      'No teams added yet! Tap the + icon to add your first team.';
  static const String noPlayersFoundForTeam =
      'No players found for this team. Add some!';
  static const String noPlayersFoundSearch =
      'No players found matching your search.'; // If you add player search later

  // Alert Dialog Messages
  static const String deleteTeamTitle = 'Delete Team?';
  static const String deleteTeamContent =
      'Are you sure you want to delete '; // Append team name and confirmation
  static const String deletePlayerTitle = 'Delete Player?';
  static const String deletePlayerContent =
      'Are you sure you want to delete '; // Append player name and confirmation

  // Player Details Display
  static const String playerGender = 'Gender';
  static const String playerName = 'Name';

  static const String appsScriptWebAppUrl =
      "https://script.google.com/macros/s/AKfycbw8H4NfGum1eeLhwUSZfa4e_wB1iVm3gaCUKf3DAGxbaxvqYg5TrBCWJ30Rr_dUAf0T/exec";


}

// old one 21/05/2026 :       "https://script.google.com/macros/s/AKfycbwqXd7kr09ek7f88XYhSmhjqBxsIYDKjFZ0bdXyj3JQTL2sFF0nSM3bSvXxyrxK115H/exec";


class ReusableAlertDialog extends StatefulWidget {
  final String title;
  final String content;
  final Future<void> Function() onYesPressed;
  final Future<void> Function()? onNoPressed;
  final String yesText;
  final String noText;
  final bool dismissible;

  const ReusableAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onYesPressed,
    this.onNoPressed,
    this.yesText = 'Yes',
    this.noText = 'No',
    this.dismissible = true,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    required Future<void> Function() onYesPressed,
    Future<void> Function()? onNoPressed,
    String yesText = 'Yes',
    String noText = 'No',
    bool dismissible = true,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder:
          (_) => ReusableAlertDialog(
            title: title,
            content: content,
            onYesPressed: onYesPressed,
            onNoPressed: onNoPressed,
            yesText: yesText,
            noText: noText,
            dismissible: dismissible,
          ),
    );
  }

  @override
  State<ReusableAlertDialog> createState() => _ReusableAlertDialogState();
}

class _ReusableAlertDialogState extends State<ReusableAlertDialog> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      title: Text(
        widget.title,
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),

      content: Text(
        widget.content,
        style: textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),

      actionsAlignment: MainAxisAlignment.spaceEvenly,

      actions: [
        TextButton(
          onPressed:
              isLoading
                  ? null
                  : () async {
                    if (widget.onNoPressed != null) {
                      await widget.onNoPressed!();
                    }

                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
          child: Text(
            widget.noText,
            style: textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
          ),
        ),

        ElevatedButton(
          onPressed:
              isLoading
                  ? null
                  : () async {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      await widget.onYesPressed();
                    } finally {
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },

          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),

          child:
              isLoading
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Text(
                    widget.yesText,
                    style: textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
        ),
      ],
    );
  }
}
// class ReusableAlertDialog extends StatelessWidget {
//
//
//
//
//   final String title;
//   final String content;
//   final Future<void> Function() onYesPressed;
//   final Future<void> Function()?
//   onNoPressed; // Nullable, as 'No' might just close the dialog
//   final String yesText;
//   final String noText;
//   final bool
//   dismissible; // Whether the dialog can be dismissed by tapping outside or back button
//
//   const ReusableAlertDialog({
//     super.key,
//     required this.title,
//     required this.content,
//     required this.onYesPressed,
//     this.onNoPressed,
//     this.yesText = 'Yes',
//     this.noText = 'No',
//     this.dismissible = true, // Defaults to true
//   });
//
//
//
//
//
//   // Static method to easily show the dialog using GetX
//   static Future<void> show({
//     required String title,
//     required String content,
//     required Future<void> Function() onYesPressed,
//     Future<void> Function()? onNoPressed,
//     String yesText = 'Yes',
//     String noText = 'No',
//     bool dismissible = true,
//   }) async {
//     return Get.dialog(
//       ReusableAlertDialog(
//         title: title,
//         content: content,
//         onYesPressed: onYesPressed,
//         onNoPressed: onNoPressed,
//         yesText: yesText,
//         noText: noText,
//         dismissible: dismissible,
//       ),
//       barrierDismissible: dismissible, // Controls dismissal by tapping outside
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Text(
//         title,
//         style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//         textAlign: TextAlign.center,
//       ),
//       content: Text(
//         content,
//         style: Get.textTheme.bodyMedium,
//         textAlign: TextAlign.center,
//       ),
//       actionsAlignment: MainAxisAlignment.spaceEvenly,
//       // Distribute buttons horizontally
//       actions: <Widget>[
//         TextButton(
//           onPressed: () {
//             if (onNoPressed != null) {
//               onNoPressed!();
//             } else {
//               Get.back(); // Just close the dialog if no specific 'No' action is provided
//             }
//           },
//           child: Text(
//             noText,
//             style: Get.textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
//           ),
//         ),
//         ElevatedButton(
//           // Using ElevatedButton for the primary action
//           onPressed: () async {
//             Get.back(); // Always pop the dialog first
//             onYesPressed(); // Then execute the 'Yes' action
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor:
//                 Theme.of(context).primaryColor, // Use primary color
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           ),
//           child: Text(
//             yesText,
//             style: Get.textTheme.titleMedium?.copyWith(color: Colors.white),
//           ),
//         ),
//       ],
//     );
//   }
// }
