// lib/utils/app_constants.dart

class AppConstants {
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
  static const String playerDetailsHeading = 'Player Details';
  static const String capturedStatusHeading = 'Captured Status';

  // Hint Texts
  static const String searchTeamsHint = 'Search teams...';
  static const String enterTeamNameHint = 'Enter team name';
  static const String firstNameHint = 'firstname';
  static const String lastNameHint = 'lastname';
  static const String enterPositionHint = 'Enter position';
  static const String selectGenderHint = 'Select Gender';
  static const String selectStatusHint = 'Select Status';

  // Validation Messages
  static const String teamNameEmptyError = 'Team name cannot be empty.';
  static const String allFieldsRequiredError = 'All fields are required!';
  static const String teamIdMissingError =
      'Team ID is missing. Cannot save player.';

  // Success Messages
  static const String teamAddedSuccess = 'Team added successfully!';
  static const String teamDeletedSuccess = 'Team deleted successfully!';
  static const String playerAddedSuccess = 'Player added successfully!';
  static const String playerUpdatedSuccess = 'Player updated successfully!';

  // Error Messages
  static const String failedToAddTeam = 'Failed to add team:';
  static const String failedToDeleteTeam = 'Failed to delete team:';
  static const String failedToSavePlayer = 'Failed to save player:';

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
  static const String playerGenderMale = 'Male';
  static const String playerGender = 'Gender';

  static const String playerGenderFemale = 'Female';
  static const String playerCapturedYes = 'Yes (Captured)';
  static const String playerCapturedNo = 'No (Not Captured)';
}
