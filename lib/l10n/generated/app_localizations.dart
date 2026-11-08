// SPDX-License-Identifier: AGPL-3.0-or-later
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bg'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'tix'**
  String get appTitle;

  /// No description provided for @connectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to tix'**
  String get connectTitle;

  /// No description provided for @connectAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add an instance'**
  String get connectAddTitle;

  /// No description provided for @connectIntro.
  ///
  /// In en, this message translates to:
  /// **'Connect to a tix server with an API token or by signing in, or open a tix database on this device.'**
  String get connectIntro;

  /// No description provided for @serverUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverUrlLabel;

  /// No description provided for @serverUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://tix.example.com'**
  String get serverUrlHint;

  /// No description provided for @tokenLabel.
  ///
  /// In en, this message translates to:
  /// **'API token'**
  String get tokenLabel;

  /// No description provided for @tokenHelp.
  ///
  /// In en, this message translates to:
  /// **'Create one with tix token create, or under Tokens in the web app.'**
  String get tokenHelp;

  /// No description provided for @contextNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get contextNameLabel;

  /// No description provided for @contextNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Shown in the switcher.'**
  String get contextNameHelp;

  /// No description provided for @connectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectButton;

  /// No description provided for @projectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsTitle;

  /// No description provided for @projectsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No projects yet.'**
  String get projectsEmpty;

  /// No description provided for @tasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this project.'**
  String get tasksEmpty;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskTitle;

  /// No description provided for @fieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get fieldStatus;

  /// No description provided for @fieldAssignee.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get fieldAssignee;

  /// No description provided for @fieldDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get fieldDue;

  /// No description provided for @fieldPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get fieldPriority;

  /// No description provided for @fieldTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get fieldTags;

  /// No description provided for @fieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDate;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description.'**
  String get noDescription;

  /// No description provided for @noTaskSelected.
  ///
  /// In en, this message translates to:
  /// **'Pick a task to see it here.'**
  String get noTaskSelected;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'{priority, select, 1{Highest} 2{High} 3{Normal} 4{Low} 5{Lowest} other{None}}'**
  String priorityLabel(String priority);

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAddTitle;

  /// No description provided for @quickAddHint.
  ///
  /// In en, this message translates to:
  /// **'Fix login !high #auth @raj due:fri'**
  String get quickAddHint;

  /// No description provided for @quickAddHelp.
  ///
  /// In en, this message translates to:
  /// **'!priority  #tag  @assignee  due:date  ^parent'**
  String get quickAddHelp;

  /// No description provided for @quickAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get quickAddButton;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @taskCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {ref}'**
  String taskCreated(String ref);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'This forgets this connection to {server} on this device.'**
  String signOutBody(String server);

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {handle}'**
  String signedInAs(String handle);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loadMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more.'**
  String get loadMoreFailed;

  /// No description provided for @errorInvalid.
  ///
  /// In en, this message translates to:
  /// **'The server refused that: {message}'**
  String errorInvalid(String message);

  /// No description provided for @errorUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'The server did not accept this connection. Check the token, or sign in again.'**
  String get errorUnauthenticated;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'This token is not allowed to do that.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get errorNotFound;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'Someone changed this at the same time. Reload and try again.'**
  String get errorConflict;

  /// No description provided for @errorPrecondition.
  ///
  /// In en, this message translates to:
  /// **'That can\'t be done right now: {message}'**
  String errorPrecondition(String message);

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem. Try again later.'**
  String get errorServer;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server. Check the address and your connection.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to answer.'**
  String get errorTimeout;

  /// No description provided for @errorNotTix.
  ///
  /// In en, this message translates to:
  /// **'That address doesn\'t answer like a tix server.'**
  String get errorNotTix;

  /// No description provided for @errorBadUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a server address, such as https://tix.example.com.'**
  String get errorBadUrl;

  /// No description provided for @errorTokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an API token.'**
  String get errorTokenRequired;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnknown;

  /// No description provided for @errorRequestId.
  ///
  /// In en, this message translates to:
  /// **'Request {id}.'**
  String errorRequestId(String id);

  /// No description provided for @instanceRemote.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get instanceRemote;

  /// No description provided for @instanceLocal.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get instanceLocal;

  /// No description provided for @localUnavailableNote.
  ///
  /// In en, this message translates to:
  /// **'Databases on this device need the tix engine built into the app, and this build was made without it.'**
  String get localUnavailableNote;

  /// No description provided for @methodToken.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get methodToken;

  /// No description provided for @methodSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get methodSignIn;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @signInHelp.
  ///
  /// In en, this message translates to:
  /// **'Sessions last about 12 hours. Use a token for a device that should stay connected.'**
  String get signInHelp;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @localIntro.
  ///
  /// In en, this message translates to:
  /// **'Create a new tix database or open one you already have.'**
  String get localIntro;

  /// No description provided for @dbNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Database name'**
  String get dbNameLabel;

  /// No description provided for @dbNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Created in this app\'s documents folder.'**
  String get dbNameHelp;

  /// No description provided for @localNewFile.
  ///
  /// In en, this message translates to:
  /// **'New database…'**
  String get localNewFile;

  /// No description provided for @localCreate.
  ///
  /// In en, this message translates to:
  /// **'Create database'**
  String get localCreate;

  /// No description provided for @localOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Open a database file…'**
  String get localOpenFile;

  /// No description provided for @localListTenants.
  ///
  /// In en, this message translates to:
  /// **'Show tenants'**
  String get localListTenants;

  /// No description provided for @codeIntro.
  ///
  /// In en, this message translates to:
  /// **'This account has a second factor. Enter the code from your authenticator app.'**
  String get codeIntro;

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeLabel;

  /// No description provided for @codeHelp.
  ///
  /// In en, this message translates to:
  /// **'Six digits, or one of your recovery codes.'**
  String get codeHelp;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @chooseTenantIntro.
  ///
  /// In en, this message translates to:
  /// **'You belong to more than one tenant here. Which one should this connection open?'**
  String get chooseTenantIntro;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'Pin to this tenant'**
  String get pinLabel;

  /// No description provided for @pinOnHelp.
  ///
  /// In en, this message translates to:
  /// **'The connection stays in this tenant. Add another connection for another tenant.'**
  String get pinOnHelp;

  /// No description provided for @pinOffHelp.
  ///
  /// In en, this message translates to:
  /// **'Switch between your tenants from the switcher.'**
  String get pinOffHelp;

  /// No description provided for @openButton.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openButton;

  /// No description provided for @localTenantsIntro.
  ///
  /// In en, this message translates to:
  /// **'Open a tenant of this database.'**
  String get localTenantsIntro;

  /// No description provided for @newTenantTitle.
  ///
  /// In en, this message translates to:
  /// **'New tenant'**
  String get newTenantTitle;

  /// No description provided for @tenantKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get tenantKeyLabel;

  /// No description provided for @tenantNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tenantNameLabel;

  /// No description provided for @createTenantButton.
  ///
  /// In en, this message translates to:
  /// **'Create and open'**
  String get createTenantButton;

  /// No description provided for @servedAt.
  ///
  /// In en, this message translates to:
  /// **'Served at {host}'**
  String servedAt(String host);

  /// No description provided for @addAsInstance.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAsInstance;

  /// No description provided for @instancesTitle.
  ///
  /// In en, this message translates to:
  /// **'Instances'**
  String get instancesTitle;

  /// No description provided for @addInstance.
  ///
  /// In en, this message translates to:
  /// **'Add an instance'**
  String get addInstance;

  /// No description provided for @instancesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No instances yet.'**
  String get instancesEmpty;

  /// No description provided for @removeInstance.
  ///
  /// In en, this message translates to:
  /// **'Remove instance'**
  String get removeInstance;

  /// No description provided for @removeInstanceBody.
  ///
  /// In en, this message translates to:
  /// **'This forgets {name} and every connection to it on this device. Nothing on the server changes.'**
  String removeInstanceBody(String name);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeConnection.
  ///
  /// In en, this message translates to:
  /// **'Remove connection'**
  String get removeConnection;

  /// No description provided for @removeConnectionBody.
  ///
  /// In en, this message translates to:
  /// **'This forgets {name} on this device.'**
  String removeConnectionBody(String name);

  /// No description provided for @openTenant.
  ///
  /// In en, this message translates to:
  /// **'Open a tenant'**
  String get openTenant;

  /// No description provided for @addConnection.
  ///
  /// In en, this message translates to:
  /// **'Add a connection'**
  String get addConnection;

  /// No description provided for @useConnection.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get useConnection;

  /// No description provided for @makeSwitchable.
  ///
  /// In en, this message translates to:
  /// **'Make switchable'**
  String get makeSwitchable;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin to current tenant'**
  String get pin;

  /// No description provided for @signInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get signInAgain;

  /// No description provided for @switchable.
  ///
  /// In en, this message translates to:
  /// **'Switchable'**
  String get switchable;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @switchContext.
  ///
  /// In en, this message translates to:
  /// **'Switch instance or tenant'**
  String get switchContext;

  /// No description provided for @recentContexts.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentContexts;

  /// No description provided for @manageInstances.
  ///
  /// In en, this message translates to:
  /// **'Manage instances'**
  String get manageInstances;

  /// No description provided for @instanceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No instances} =1{1 instance} other{{count} instances}}'**
  String instanceCount(int count);

  /// No description provided for @errorBadCredentials.
  ///
  /// In en, this message translates to:
  /// **'That email and password were not accepted.'**
  String get errorBadCredentials;

  /// No description provided for @errorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get errorEmailRequired;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get errorPasswordRequired;

  /// No description provided for @errorCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your authenticator app.'**
  String get errorCodeRequired;

  /// No description provided for @errorSecondFactorSetup.
  ///
  /// In en, this message translates to:
  /// **'This account must set up a second factor first. Sign in once in the browser to do that.'**
  String get errorSecondFactorSetup;

  /// No description provided for @errorPasswordChange.
  ///
  /// In en, this message translates to:
  /// **'This account must choose a new password first. Sign in once in the browser to do that.'**
  String get errorPasswordChange;

  /// No description provided for @errorTenantRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a key for the tenant.'**
  String get errorTenantRequired;

  /// No description provided for @errorEngineUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Databases on this device are not available: this build was made without the tix engine.'**
  String get errorEngineUnavailable;

  /// No description provided for @localIntroImport.
  ///
  /// In en, this message translates to:
  /// **'Create a new tix database or import one. The app works on its own copy, kept inside the app; export it to take your changes elsewhere.'**
  String get localIntroImport;

  /// No description provided for @localOpenInPlace.
  ///
  /// In en, this message translates to:
  /// **'The file stays where it is, and changes are saved straight to it.'**
  String get localOpenInPlace;

  /// No description provided for @localImportFile.
  ///
  /// In en, this message translates to:
  /// **'Import a database file…'**
  String get localImportFile;

  /// No description provided for @exportDatabase.
  ///
  /// In en, this message translates to:
  /// **'Export database…'**
  String get exportDatabase;

  /// No description provided for @databaseExported.
  ///
  /// In en, this message translates to:
  /// **'Database exported.'**
  String get databaseExported;

  /// No description provided for @localCopyNote.
  ///
  /// In en, this message translates to:
  /// **'Copy kept in the app'**
  String get localCopyNote;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @moreInfo.
  ///
  /// In en, this message translates to:
  /// **'More information'**
  String get moreInfo;

  /// No description provided for @dueOverdue.
  ///
  /// In en, this message translates to:
  /// **'overdue'**
  String get dueOverdue;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'due today'**
  String get dueToday;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'due {date}'**
  String dueOn(String date);

  /// No description provided for @snoozedUntil.
  ///
  /// In en, this message translates to:
  /// **'snoozed until {date}'**
  String snoozedUntil(String date);

  /// No description provided for @blockedByOther.
  ///
  /// In en, this message translates to:
  /// **'Waiting on another task'**
  String get blockedByOther;

  /// No description provided for @starred.
  ///
  /// In en, this message translates to:
  /// **'Starred'**
  String get starred;

  /// No description provided for @star.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get star;

  /// No description provided for @unstar.
  ///
  /// In en, this message translates to:
  /// **'Unstar'**
  String get unstar;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @reopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// No description provided for @snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snooze;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @filterHint.
  ///
  /// In en, this message translates to:
  /// **'Filter, for example status:todo tag:ops'**
  String get filterHint;

  /// No description provided for @shortcutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get shortcutsTitle;

  /// No description provided for @showShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Show keyboard shortcuts'**
  String get showShortcuts;

  /// No description provided for @openCommandPalette.
  ///
  /// In en, this message translates to:
  /// **'Open the command palette'**
  String get openCommandPalette;

  /// No description provided for @commandSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type a command'**
  String get commandSearchHint;

  /// No description provided for @commandNone.
  ///
  /// In en, this message translates to:
  /// **'No command matches.'**
  String get commandNone;

  /// No description provided for @goProjects.
  ///
  /// In en, this message translates to:
  /// **'Go to projects'**
  String get goProjects;

  /// No description provided for @goSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to settings'**
  String get goSettings;

  /// No description provided for @goInstances.
  ///
  /// In en, this message translates to:
  /// **'Go to instances'**
  String get goInstances;

  /// No description provided for @commandsNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get commandsNavigate;

  /// No description provided for @commandsTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get commandsTasks;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @projectsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Projects are created on the server, in the browser or with tix project add.'**
  String get projectsEmptyBody;

  /// No description provided for @tasksEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a task with one line: a title, then !high, #tag, @handle or due:fri.'**
  String get tasksEmptyBody;

  /// No description provided for @instancesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the tix server you work on, or a database on this device.'**
  String get instancesEmptyBody;

  /// No description provided for @projectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every project in {tenant}'**
  String projectsSubtitle(String tenant);

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @appearanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceLabel;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// No description provided for @galleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Components'**
  String get galleryTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bg', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
