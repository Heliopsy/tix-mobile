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

  /// No description provided for @taskDetailActionsFor.
  ///
  /// In en, this message translates to:
  /// **'Actions for {ref}'**
  String taskDetailActionsFor(String ref);

  /// No description provided for @taskDetailActorSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name or handle'**
  String get taskDetailActorSearch;

  /// No description provided for @taskDetailAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get taskDetailAdd;

  /// No description provided for @taskDetailAddDependency.
  ///
  /// In en, this message translates to:
  /// **'Add dependency'**
  String get taskDetailAddDependency;

  /// No description provided for @taskDetailAddSubtask.
  ///
  /// In en, this message translates to:
  /// **'Add subtask'**
  String get taskDetailAddSubtask;

  /// No description provided for @taskDetailAddTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get taskDetailAddTag;

  /// No description provided for @taskDetailArtifactFile.
  ///
  /// In en, this message translates to:
  /// **'file'**
  String get taskDetailArtifactFile;

  /// No description provided for @taskDetailArtifactLog.
  ///
  /// In en, this message translates to:
  /// **'log'**
  String get taskDetailArtifactLog;

  /// No description provided for @taskDetailArtifactMetric.
  ///
  /// In en, this message translates to:
  /// **'metric'**
  String get taskDetailArtifactMetric;

  /// No description provided for @taskDetailArtifactResult.
  ///
  /// In en, this message translates to:
  /// **'result'**
  String get taskDetailArtifactResult;

  /// No description provided for @taskDetailArtifacts.
  ///
  /// In en, this message translates to:
  /// **'Artifacts'**
  String get taskDetailArtifacts;

  /// No description provided for @taskDetailArtifactSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get taskDetailArtifactSave;

  /// No description provided for @taskDetailArtifactShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get taskDetailArtifactShow;

  /// No description provided for @taskDetailArtifactUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This artifact\'s content cannot be read.'**
  String get taskDetailArtifactUnreadable;

  /// No description provided for @taskDetailAssigneeTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get taskDetailAssigneeTitle;

  /// No description provided for @taskDetailAttached.
  ///
  /// In en, this message translates to:
  /// **'Attached {name}.'**
  String taskDetailAttached(String name);

  /// No description provided for @taskDetailAttachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get taskDetailAttachFile;

  /// No description provided for @taskDetailBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked: it waits for a task that is not finished.'**
  String get taskDetailBlocked;

  /// No description provided for @taskDetailChecklist.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String taskDetailChecklist(int done, int total);

  /// No description provided for @taskDetailClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get taskDetailClear;

  /// No description provided for @taskDetailCommands.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskDetailCommands;

  /// No description provided for @taskDetailCommentActions.
  ///
  /// In en, this message translates to:
  /// **'Comment actions'**
  String get taskDetailCommentActions;

  /// No description provided for @taskDetailCommentAdded.
  ///
  /// In en, this message translates to:
  /// **'Comment added.'**
  String get taskDetailCommentAdded;

  /// No description provided for @taskDetailCommentDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get taskDetailCommentDelete;

  /// No description provided for @taskDetailCommentDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It disappears for everyone. This cannot be undone here.'**
  String get taskDetailCommentDeleteBody;

  /// No description provided for @taskDetailCommentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Comment deleted.'**
  String get taskDetailCommentDeleted;

  /// No description provided for @taskDetailCommentDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this comment?'**
  String get taskDetailCommentDeleteTitle;

  /// No description provided for @taskDetailCommentEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit comment'**
  String get taskDetailCommentEdit;

  /// No description provided for @taskDetailCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Markdown works. @ names someone.'**
  String get taskDetailCommentHint;

  /// No description provided for @taskDetailCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get taskDetailCommentLabel;

  /// No description provided for @taskDetailComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get taskDetailComments;

  /// No description provided for @taskDetailCommentSend.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get taskDetailCommentSend;

  /// No description provided for @taskDetailCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied as {ref}.'**
  String taskDetailCopied(String ref);

  /// No description provided for @taskDetailCopiedFrom.
  ///
  /// In en, this message translates to:
  /// **'Copied from'**
  String get taskDetailCopiedFrom;

  /// No description provided for @taskDetailCopyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get taskDetailCopyAction;

  /// No description provided for @taskDetailCopyComments.
  ///
  /// In en, this message translates to:
  /// **'Copy its comments'**
  String get taskDetailCopyComments;

  /// No description provided for @taskDetailCopyDependencies.
  ///
  /// In en, this message translates to:
  /// **'Copy its dependencies'**
  String get taskDetailCopyDependencies;

  /// No description provided for @taskDetailCopyKeepStatus.
  ///
  /// In en, this message translates to:
  /// **'Keep its status'**
  String get taskDetailCopyKeepStatus;

  /// No description provided for @taskDetailCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Link the copy to this task'**
  String get taskDetailCopyLink;

  /// No description provided for @taskDetailCopyNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Title of the copy'**
  String get taskDetailCopyNewTitle;

  /// No description provided for @taskDetailCopyProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get taskDetailCopyProject;

  /// No description provided for @taskDetailCopyRef.
  ///
  /// In en, this message translates to:
  /// **'Copy reference'**
  String get taskDetailCopyRef;

  /// No description provided for @taskDetailCopySubtasks.
  ///
  /// In en, this message translates to:
  /// **'Copy its subtasks'**
  String get taskDetailCopySubtasks;

  /// No description provided for @taskDetailCopyTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy {ref}'**
  String taskDetailCopyTitle(String ref);

  /// No description provided for @taskDetailCopyTo.
  ///
  /// In en, this message translates to:
  /// **'Copy to…'**
  String get taskDetailCopyTo;

  /// No description provided for @taskDetailCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}}'**
  String taskDetailCount(int count);

  /// No description provided for @taskDetailCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get taskDetailCreated;

  /// No description provided for @taskDetailCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get taskDetailCurrent;

  /// No description provided for @taskDetailDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get taskDetailDelete;

  /// No description provided for @taskDetailDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {ref}.'**
  String taskDetailDeleted(String ref);

  /// No description provided for @taskDetailDeleteForGood.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get taskDetailDeleteForGood;

  /// No description provided for @taskDetailDeletePermanentBody.
  ///
  /// In en, this message translates to:
  /// **'It is removed for good, with its comments and history.'**
  String get taskDetailDeletePermanentBody;

  /// No description provided for @taskDetailDeleteSubtasksBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Its subtask is deleted with it.} other{Its {count} subtasks are deleted with it.}}'**
  String taskDetailDeleteSubtasksBody(int count);

  /// No description provided for @taskDetailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {ref}?'**
  String taskDetailDeleteTitle(String ref);

  /// No description provided for @taskDetailDeleteTrashBody.
  ///
  /// In en, this message translates to:
  /// **'It goes to the trash and can be restored.'**
  String get taskDetailDeleteTrashBody;

  /// No description provided for @taskDetailDependencies.
  ///
  /// In en, this message translates to:
  /// **'Waits for'**
  String get taskDetailDependencies;

  /// No description provided for @taskDetailDependenciesInfo.
  ///
  /// In en, this message translates to:
  /// **'This task counts as blocked until each task listed here reaches a finished state.'**
  String get taskDetailDependenciesInfo;

  /// No description provided for @taskDetailDependencyAdded.
  ///
  /// In en, this message translates to:
  /// **'Now waits for {ref}.'**
  String taskDetailDependencyAdded(String ref);

  /// No description provided for @taskDetailDependencyRemoved.
  ///
  /// In en, this message translates to:
  /// **'No longer waits for {ref}.'**
  String taskDetailDependencyRemoved(String ref);

  /// No description provided for @taskDetailDependsOn.
  ///
  /// In en, this message translates to:
  /// **'Depends on'**
  String get taskDetailDependsOn;

  /// No description provided for @taskDetailDependsOnHint.
  ///
  /// In en, this message translates to:
  /// **'A reference, for example infra-2'**
  String get taskDetailDependsOnHint;

  /// No description provided for @taskDetailDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Markdown. - [ ] makes a checklist item.'**
  String get taskDetailDescriptionHint;

  /// No description provided for @taskDetailDueClear.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get taskDetailDueClear;

  /// No description provided for @taskDetailDueNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get taskDetailDueNextWeek;

  /// No description provided for @taskDetailDueTitle.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get taskDetailDueTitle;

  /// No description provided for @taskDetailDueToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get taskDetailDueToday;

  /// No description provided for @taskDetailDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get taskDetailDueTomorrow;

  /// No description provided for @taskDetailEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get taskDetailEdit;

  /// No description provided for @taskDetailEditDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit description'**
  String get taskDetailEditDescription;

  /// No description provided for @taskDetailEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get taskDetailEdited;

  /// No description provided for @taskDetailEditField.
  ///
  /// In en, this message translates to:
  /// **'Change {name}'**
  String taskDetailEditField(String name);

  /// No description provided for @taskDetailFileTooBig.
  ///
  /// In en, this message translates to:
  /// **'Files over 1 MiB cannot be attached.'**
  String get taskDetailFileTooBig;

  /// No description provided for @taskDetailHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get taskDetailHistory;

  /// No description provided for @taskDetailHistoryChanged.
  ///
  /// In en, this message translates to:
  /// **'changed {fields}'**
  String taskDetailHistoryChanged(String fields);

  /// No description provided for @taskDetailHistoryCreated.
  ///
  /// In en, this message translates to:
  /// **'created the task'**
  String get taskDetailHistoryCreated;

  /// No description provided for @taskDetailHistoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'deleted the task'**
  String get taskDetailHistoryDeleted;

  /// No description provided for @taskDetailHistoryMore.
  ///
  /// In en, this message translates to:
  /// **'Show older'**
  String get taskDetailHistoryMore;

  /// No description provided for @taskDetailHistoryMoved.
  ///
  /// In en, this message translates to:
  /// **'moved it from {from} to {to}'**
  String taskDetailHistoryMoved(String from, String to);

  /// No description provided for @taskDetailHistoryRestored.
  ///
  /// In en, this message translates to:
  /// **'restored the task'**
  String get taskDetailHistoryRestored;

  /// No description provided for @taskDetailJsonHelp.
  ///
  /// In en, this message translates to:
  /// **'A JSON value: a number, a string in quotes, a list or an object'**
  String get taskDetailJsonHelp;

  /// No description provided for @taskDetailMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get taskDetailMove;

  /// No description provided for @taskDetailMoveComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get taskDetailMoveComment;

  /// No description provided for @taskDetailMoveCommentHelp.
  ///
  /// In en, this message translates to:
  /// **'This move needs a comment saying why.'**
  String get taskDetailMoveCommentHelp;

  /// No description provided for @taskDetailMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved {ref} to {status}.'**
  String taskDetailMoved(String ref, String status);

  /// No description provided for @taskDetailMoveFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get taskDetailMoveFrom;

  /// No description provided for @taskDetailMoveNeedsComment.
  ///
  /// In en, this message translates to:
  /// **'Needs a comment'**
  String get taskDetailMoveNeedsComment;

  /// No description provided for @taskDetailMoveStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped before {state}: {reason}'**
  String taskDetailMoveStopped(String state, String reason);

  /// No description provided for @taskDetailMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get taskDetailMoveTitle;

  /// No description provided for @taskDetailMoveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to {state}'**
  String taskDetailMoveTo(String state);

  /// No description provided for @taskDetailMoveVia.
  ///
  /// In en, this message translates to:
  /// **'via {states}'**
  String taskDetailMoveVia(String states);

  /// No description provided for @taskDetailNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get taskDetailNo;

  /// No description provided for @taskDetailNoArtifacts.
  ///
  /// In en, this message translates to:
  /// **'No artifacts.'**
  String get taskDetailNoArtifacts;

  /// No description provided for @taskDetailNoComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get taskDetailNoComments;

  /// No description provided for @taskDetailNoDependencies.
  ///
  /// In en, this message translates to:
  /// **'Waits for nothing.'**
  String get taskDetailNoDependencies;

  /// No description provided for @taskDetailNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No history.'**
  String get taskDetailNoHistory;

  /// No description provided for @taskDetailNoMoves.
  ///
  /// In en, this message translates to:
  /// **'The workflow allows no move from here.'**
  String get taskDetailNoMoves;

  /// No description provided for @taskDetailNoRepeat.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get taskDetailNoRepeat;

  /// No description provided for @taskDetailNoSubtasks.
  ///
  /// In en, this message translates to:
  /// **'No subtasks.'**
  String get taskDetailNoSubtasks;

  /// No description provided for @taskDetailOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get taskDetailOpen;

  /// No description provided for @taskDetailParent.
  ///
  /// In en, this message translates to:
  /// **'Subtask of'**
  String get taskDetailParent;

  /// No description provided for @taskDetailPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date…'**
  String get taskDetailPickDate;

  /// No description provided for @taskDetailPickDateTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a date and time…'**
  String get taskDetailPickDateTime;

  /// No description provided for @taskDetailPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get taskDetailPreview;

  /// No description provided for @taskDetailPriorityTitle.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskDetailPriorityTitle;

  /// No description provided for @taskDetailProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get taskDetailProject;

  /// No description provided for @taskDetailRefCopied.
  ///
  /// In en, this message translates to:
  /// **'Reference copied.'**
  String get taskDetailRefCopied;

  /// No description provided for @taskDetailRemoveDependency.
  ///
  /// In en, this message translates to:
  /// **'Stop waiting for {ref}'**
  String taskDetailRemoveDependency(String ref);

  /// No description provided for @taskDetailRemoveTag.
  ///
  /// In en, this message translates to:
  /// **'Remove {tag}'**
  String taskDetailRemoveTag(String tag);

  /// No description provided for @taskDetailRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get taskDetailRename;

  /// No description provided for @taskDetailRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get taskDetailRepeat;

  /// No description provided for @taskDetailRepeatHelp.
  ///
  /// In en, this message translates to:
  /// **'every day, every 2 weeks on mon,thu, every month on day 31, 3 days after done'**
  String get taskDetailRepeatHelp;

  /// No description provided for @taskDetailRepeatHint.
  ///
  /// In en, this message translates to:
  /// **'every week'**
  String get taskDetailRepeatHint;

  /// No description provided for @taskDetailRepeatInfo.
  ///
  /// In en, this message translates to:
  /// **'Finishing a task with a rule creates the next one at once. Cancelling it does not. Empty stops the repeat.'**
  String get taskDetailRepeatInfo;

  /// No description provided for @taskDetailRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get taskDetailRepeats;

  /// No description provided for @taskDetailRepeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeat rule'**
  String get taskDetailRepeatTitle;

  /// No description provided for @taskDetailSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get taskDetailSave;

  /// No description provided for @taskDetailSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get taskDetailSaved;

  /// No description provided for @taskDetailSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get taskDetailSnooze;

  /// No description provided for @taskDetailSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed until {when}.'**
  String taskDetailSnoozed(String when);

  /// No description provided for @taskDetailSnoozeLater.
  ///
  /// In en, this message translates to:
  /// **'Later today'**
  String get taskDetailSnoozeLater;

  /// No description provided for @taskDetailSnoozeNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get taskDetailSnoozeNextWeek;

  /// No description provided for @taskDetailSnoozeTitle.
  ///
  /// In en, this message translates to:
  /// **'Snooze until'**
  String get taskDetailSnoozeTitle;

  /// No description provided for @taskDetailSnoozeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow morning'**
  String get taskDetailSnoozeTomorrow;

  /// No description provided for @taskDetailStar.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get taskDetailStar;

  /// No description provided for @taskDetailStarred.
  ///
  /// In en, this message translates to:
  /// **'Starred.'**
  String get taskDetailStarred;

  /// No description provided for @taskDetailSubtaskAdded.
  ///
  /// In en, this message translates to:
  /// **'Subtask added.'**
  String get taskDetailSubtaskAdded;

  /// No description provided for @taskDetailSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get taskDetailSubtasks;

  /// No description provided for @taskDetailSystem.
  ///
  /// In en, this message translates to:
  /// **'tix'**
  String get taskDetailSystem;

  /// No description provided for @taskDetailTagAdded.
  ///
  /// In en, this message translates to:
  /// **'Tagged {name}.'**
  String taskDetailTagAdded(String name);

  /// No description provided for @taskDetailTagHint.
  ///
  /// In en, this message translates to:
  /// **'A new name creates the tag'**
  String get taskDetailTagHint;

  /// No description provided for @taskDetailTagRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}.'**
  String taskDetailTagRemoved(String name);

  /// No description provided for @taskDetailTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get taskDetailTakePhoto;

  /// No description provided for @taskDetailTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskDetailTitleLabel;

  /// No description provided for @taskDetailUnassign.
  ///
  /// In en, this message translates to:
  /// **'Unassign'**
  String get taskDetailUnassign;

  /// No description provided for @taskDetailUnstar.
  ///
  /// In en, this message translates to:
  /// **'Remove star'**
  String get taskDetailUnstar;

  /// No description provided for @taskDetailUnstarred.
  ///
  /// In en, this message translates to:
  /// **'Star removed.'**
  String get taskDetailUnstarred;

  /// No description provided for @taskDetailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get taskDetailUpdated;

  /// No description provided for @taskDetailWake.
  ///
  /// In en, this message translates to:
  /// **'Wake now'**
  String get taskDetailWake;

  /// No description provided for @taskDetailWoken.
  ///
  /// In en, this message translates to:
  /// **'Back in the lists.'**
  String get taskDetailWoken;

  /// No description provided for @taskDetailWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get taskDetailWrite;

  /// No description provided for @taskDetailYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get taskDetailYes;
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
