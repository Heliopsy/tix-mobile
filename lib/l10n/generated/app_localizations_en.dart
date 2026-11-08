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
  String get connectAddTitle => 'Add an instance';

  @override
  String get connectIntro =>
      'Connect to a tix server with an API token or by signing in, or open a tix database on this device.';

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
  String get contextNameHelp => 'Shown in the switcher.';

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
  String get signOut => 'Sign out';

  @override
  String signOutBody(String server) {
    return 'This forgets this connection to $server on this device.';
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
      'The server did not accept this connection. Check the token, or sign in again.';

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

  @override
  String get instanceRemote => 'Server';

  @override
  String get instanceLocal => 'This device';

  @override
  String get localUnavailableNote =>
      'Databases on this device need the tix engine built into the app, and this build was made without it.';

  @override
  String get methodToken => 'Token';

  @override
  String get methodSignIn => 'Sign in';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInHelp =>
      'Sessions last about 12 hours. Use a token for a device that should stay connected.';

  @override
  String get signInButton => 'Sign in';

  @override
  String get localIntro =>
      'Create a new tix database or open one you already have.';

  @override
  String get dbNameLabel => 'Database name';

  @override
  String get dbNameHelp => 'Created in this app\'s documents folder.';

  @override
  String get localNewFile => 'New database…';

  @override
  String get localCreate => 'Create database';

  @override
  String get localOpenFile => 'Open a database file…';

  @override
  String get localListTenants => 'Show tenants';

  @override
  String get codeIntro =>
      'This account has a second factor. Enter the code from your authenticator app.';

  @override
  String get codeLabel => 'Code';

  @override
  String get codeHelp => 'Six digits, or one of your recovery codes.';

  @override
  String get verifyButton => 'Verify';

  @override
  String get chooseTenantIntro =>
      'You belong to more than one tenant here. Which one should this connection open?';

  @override
  String get pinLabel => 'Pin to this tenant';

  @override
  String get pinOnHelp =>
      'The connection stays in this tenant. Add another connection for another tenant.';

  @override
  String get pinOffHelp => 'Switch between your tenants from the switcher.';

  @override
  String get openButton => 'Open';

  @override
  String get localTenantsIntro => 'Open a tenant of this database.';

  @override
  String get newTenantTitle => 'New tenant';

  @override
  String get tenantKeyLabel => 'Key';

  @override
  String get tenantNameLabel => 'Name';

  @override
  String get createTenantButton => 'Create and open';

  @override
  String servedAt(String host) {
    return 'Served at $host';
  }

  @override
  String get addAsInstance => 'Add';

  @override
  String get instancesTitle => 'Instances';

  @override
  String get addInstance => 'Add an instance';

  @override
  String get instancesEmpty => 'No instances yet.';

  @override
  String get removeInstance => 'Remove instance';

  @override
  String removeInstanceBody(String name) {
    return 'This forgets $name and every connection to it on this device. Nothing on the server changes.';
  }

  @override
  String get remove => 'Remove';

  @override
  String get removeConnection => 'Remove connection';

  @override
  String removeConnectionBody(String name) {
    return 'This forgets $name on this device.';
  }

  @override
  String get openTenant => 'Open a tenant';

  @override
  String get addConnection => 'Add a connection';

  @override
  String get useConnection => 'Use';

  @override
  String get makeSwitchable => 'Make switchable';

  @override
  String get pin => 'Pin to current tenant';

  @override
  String get signInAgain => 'Sign in again';

  @override
  String get switchable => 'Switchable';

  @override
  String get pinned => 'Pinned';

  @override
  String get switchContext => 'Switch instance or tenant';

  @override
  String get recentContexts => 'Recent';

  @override
  String get manageInstances => 'Manage instances';

  @override
  String instanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instances',
      one: '1 instance',
      zero: 'No instances',
    );
    return '$_temp0';
  }

  @override
  String get errorBadCredentials =>
      'That email and password were not accepted.';

  @override
  String get errorEmailRequired => 'Enter your email.';

  @override
  String get errorPasswordRequired => 'Enter your password.';

  @override
  String get errorCodeRequired => 'Enter the code from your authenticator app.';

  @override
  String get errorSecondFactorSetup =>
      'This account must set up a second factor first. Sign in once in the browser to do that.';

  @override
  String get errorPasswordChange =>
      'This account must choose a new password first. Sign in once in the browser to do that.';

  @override
  String get errorTenantRequired => 'Enter a key for the tenant.';

  @override
  String get errorEngineUnavailable =>
      'Databases on this device are not available: this build was made without the tix engine.';

  @override
  String get localIntroImport =>
      'Create a new tix database or import one. The app works on its own copy, kept inside the app; export it to take your changes elsewhere.';

  @override
  String get localOpenInPlace =>
      'The file stays where it is, and changes are saved straight to it.';

  @override
  String get localImportFile => 'Import a database file…';

  @override
  String get exportDatabase => 'Export database…';

  @override
  String get databaseExported => 'Database exported.';

  @override
  String get localCopyNote => 'Copy kept in the app';
}
