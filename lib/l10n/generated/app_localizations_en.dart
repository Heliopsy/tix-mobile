// SPDX-License-Identifier: AGPL-3.0-or-later

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'tix';

  @override
  String get connectTitle => 'Connect to tix';

  @override
  String get connectAddTitle => 'Add a server';

  @override
  String get connectIntro =>
      'Sign in with the address of your tix server and an API token.';

  @override
  String get serverUrlLabel => 'Server address';

  @override
  String get serverUrlHint => 'https://tix.example.com';

  @override
  String get tokenLabel => 'API token';

  @override
  String get tokenHelp =>
      'Create one with tix token create, or under Tokens in the web app.';

  @override
  String get contextNameLabel => 'Name (optional)';

  @override
  String get contextNameHelp => 'Shown when you switch between servers.';

  @override
  String get connectButton => 'Connect';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get projectsEmpty => 'No projects yet.';

  @override
  String get tasksEmpty => 'No tasks in this project.';

  @override
  String get taskTitle => 'Task';

  @override
  String get fieldStatus => 'Status';

  @override
  String get fieldAssignee => 'Assignee';

  @override
  String get fieldDue => 'Due';

  @override
  String get fieldPriority => 'Priority';

  @override
  String get fieldTags => 'Tags';

  @override
  String get fieldDescription => 'Description';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get noDueDate => 'No due date';

  @override
  String get noDescription => 'No description.';

  @override
  String get noTaskSelected => 'Pick a task to see it here.';

  @override
  String priorityLabel(String priority) {
    String _temp0 = intl.Intl.selectLogic(priority, {
      '1': 'Highest',
      '2': 'High',
      '3': 'Normal',
      '4': 'Low',
      '5': 'Lowest',
      'other': 'None',
    });
    return '$_temp0';
  }

  @override
  String get quickAddTitle => 'Quick add';

  @override
  String get quickAddHint => 'Fix login !high #auth @raj due:fri';

  @override
  String get quickAddHelp => '!priority  #tag  @assignee  due:date  ^parent';

  @override
  String get quickAddButton => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String taskCreated(String ref) {
    return 'Created $ref';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get serversLabel => 'Servers';

  @override
  String get addServer => 'Add a server';

  @override
  String get signOut => 'Sign out';

  @override
  String signOutBody(String server) {
    return 'This forgets the token for $server on this device.';
  }

  @override
  String signedInAs(String handle) {
    return 'Signed in as $handle';
  }

  @override
  String get retry => 'Retry';

  @override
  String get loadMoreFailed => 'Couldn\'t load more.';

  @override
  String errorInvalid(String message) {
    return 'The server refused that: $message';
  }

  @override
  String get errorUnauthenticated =>
      'The token was not accepted. Check it, or create a new one.';

  @override
  String get errorForbidden => 'This token is not allowed to do that.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get errorConflict =>
      'Someone changed this at the same time. Reload and try again.';

  @override
  String errorPrecondition(String message) {
    return 'That can\'t be done right now: $message';
  }

  @override
  String get errorServer => 'The server had a problem. Try again later.';

  @override
  String get errorNetwork =>
      'Couldn\'t reach the server. Check the address and your connection.';

  @override
  String get errorTimeout => 'The server took too long to answer.';

  @override
  String get errorNotTix => 'That address doesn\'t answer like a tix server.';

  @override
  String get errorBadUrl =>
      'Enter a server address, such as https://tix.example.com.';

  @override
  String get errorTokenRequired => 'Enter an API token.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String errorRequestId(String id) {
    return 'Request $id.';
  }
}
