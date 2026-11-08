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

  /// No description provided for @boardAllEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet.'**
  String get boardAllEmpty;

  /// No description provided for @boardAllEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks from every project show here.'**
  String get boardAllEmptyBody;

  /// No description provided for @boardArrangement.
  ///
  /// In en, this message translates to:
  /// **'Arrangement'**
  String get boardArrangement;

  /// No description provided for @boardAssignMe.
  ///
  /// In en, this message translates to:
  /// **'Assign to me'**
  String get boardAssignMe;

  /// No description provided for @boardAssignedToMe.
  ///
  /// In en, this message translates to:
  /// **'{ref} assigned to you'**
  String boardAssignedToMe(String ref);

  /// No description provided for @boardCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get boardCollapse;

  /// No description provided for @boardColumnEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get boardColumnEmpty;

  /// No description provided for @boardCompleted.
  ///
  /// In en, this message translates to:
  /// **'{ref} completed'**
  String boardCompleted(String ref);

  /// No description provided for @boardCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1{more} task} other{{count}{more} tasks}}'**
  String boardCount(int count, String more);

  /// No description provided for @boardExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get boardExpand;

  /// No description provided for @boardGroupMenu.
  ///
  /// In en, this message translates to:
  /// **'Arrange {group}'**
  String boardGroupMenu(String group);

  /// No description provided for @boardHiddenCount.
  ///
  /// In en, this message translates to:
  /// **'Hidden: {count}'**
  String boardHiddenCount(int count);

  /// No description provided for @boardHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get boardHide;

  /// No description provided for @boardLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get boardLoadMore;

  /// No description provided for @boardMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get boardMoveDown;

  /// No description provided for @boardMoveLeft.
  ///
  /// In en, this message translates to:
  /// **'Move left'**
  String get boardMoveLeft;

  /// No description provided for @boardMoveRight.
  ///
  /// In en, this message translates to:
  /// **'Move right'**
  String get boardMoveRight;

  /// No description provided for @boardMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move {ref} to'**
  String boardMoveTitle(String ref);

  /// No description provided for @boardMoveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to…'**
  String get boardMoveTo;

  /// No description provided for @boardMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get boardMoveUp;

  /// No description provided for @boardMoved.
  ///
  /// In en, this message translates to:
  /// **'{ref} moved to {status}'**
  String boardMoved(String ref, String status);

  /// No description provided for @boardNext.
  ///
  /// In en, this message translates to:
  /// **'Next task'**
  String get boardNext;

  /// No description provided for @boardNoRoute.
  ///
  /// In en, this message translates to:
  /// **'{ref} has no way there in its workflow'**
  String boardNoRoute(String ref);

  /// No description provided for @boardOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get boardOpen;

  /// No description provided for @boardPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous task'**
  String get boardPrevious;

  /// No description provided for @boardRefused.
  ///
  /// In en, this message translates to:
  /// **'These projects run different workflows, so they cannot share one board. Narrow the filter to one workflow\'s projects to see a board.'**
  String get boardRefused;

  /// No description provided for @boardRefusedGroup.
  ///
  /// In en, this message translates to:
  /// **'{workflow}: {projects}'**
  String boardRefusedGroup(String workflow, String projects);

  /// No description provided for @boardReopened.
  ///
  /// In en, this message translates to:
  /// **'{ref} reopened'**
  String boardReopened(String ref);

  /// No description provided for @boardResetArrangement.
  ///
  /// In en, this message translates to:
  /// **'Reset arrangement'**
  String get boardResetArrangement;

  /// No description provided for @boardShowGroup.
  ///
  /// In en, this message translates to:
  /// **'Show {group}'**
  String boardShowGroup(String group);

  /// No description provided for @boardSnoozeLater.
  ///
  /// In en, this message translates to:
  /// **'Later today'**
  String get boardSnoozeLater;

  /// No description provided for @boardSnoozeTitle.
  ///
  /// In en, this message translates to:
  /// **'Snooze {ref} until'**
  String boardSnoozeTitle(String ref);

  /// No description provided for @boardSnoozeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow morning'**
  String get boardSnoozeTomorrow;

  /// No description provided for @boardSnoozeWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get boardSnoozeWeek;

  /// No description provided for @boardSnoozed.
  ///
  /// In en, this message translates to:
  /// **'{ref} snoozed'**
  String boardSnoozed(String ref);

  /// No description provided for @boardStarred.
  ///
  /// In en, this message translates to:
  /// **'{ref} starred'**
  String boardStarred(String ref);

  /// No description provided for @boardStrays.
  ///
  /// In en, this message translates to:
  /// **'Not on this board\'s columns: {refs}'**
  String boardStrays(String refs);

  /// No description provided for @boardSwitchProject.
  ///
  /// In en, this message translates to:
  /// **'Switch project'**
  String get boardSwitchProject;

  /// No description provided for @boardUnstarred.
  ///
  /// In en, this message translates to:
  /// **'{ref} unstarred'**
  String boardUnstarred(String ref);

  /// No description provided for @boardWake.
  ///
  /// In en, this message translates to:
  /// **'Wake now'**
  String get boardWake;

  /// No description provided for @boardWoken.
  ///
  /// In en, this message translates to:
  /// **'{ref} is awake'**
  String boardWoken(String ref);

  /// No description provided for @bulkClear.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get bulkClear;

  /// No description provided for @bulkCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy to…'**
  String get bulkCopy;

  /// No description provided for @bulkCopyTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copy 1 task to} other{Copy {count} tasks to}}'**
  String bulkCopyTitle(int count);

  /// No description provided for @bulkDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get bulkDelete;

  /// No description provided for @bulkDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'They go to the trash, and Undo brings them back.'**
  String get bulkDeleteBody;

  /// No description provided for @bulkDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 task?} other{Delete {count} tasks?}}'**
  String bulkDeleteTitle(int count);

  /// No description provided for @bulkDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task changed} other{{count} tasks changed}}'**
  String bulkDone(int count);

  /// No description provided for @bulkMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get bulkMove;

  /// No description provided for @bulkMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Move 1 task to} other{Move {count} tasks to}}'**
  String bulkMoveTitle(int count);

  /// No description provided for @bulkPartly.
  ///
  /// In en, this message translates to:
  /// **'{count} changed. Refused: {refused}'**
  String bulkPartly(int count, String refused);

  /// No description provided for @bulkSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get bulkSelect;

  /// No description provided for @bulkSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get bulkSelectAll;

  /// No description provided for @bulkSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String bulkSelected(int count);

  /// No description provided for @bulkTagAdd.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get bulkTagAdd;

  /// No description provided for @bulkTagRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove tag'**
  String get bulkTagRemove;

  /// No description provided for @filterBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get filterBlocked;

  /// No description provided for @filterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filterClear;

  /// No description provided for @filterDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete filter'**
  String get filterDelete;

  /// No description provided for @filterDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Anyone it was shared with loses it too.'**
  String get filterDeleteBody;

  /// No description provided for @filterDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String filterDeleteTitle(String name);

  /// No description provided for @filterDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get filterDueToday;

  /// No description provided for @filterDueWeek.
  ///
  /// In en, this message translates to:
  /// **'Due this week'**
  String get filterDueWeek;

  /// No description provided for @filterFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get filterFinished;

  /// No description provided for @filterFocus.
  ///
  /// In en, this message translates to:
  /// **'Filter tasks'**
  String get filterFocus;

  /// No description provided for @filterMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get filterMine;

  /// No description provided for @filterName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get filterName;

  /// No description provided for @filterNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches this filter.'**
  String get filterNoMatch;

  /// No description provided for @filterNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Change the filter or clear it.'**
  String get filterNoMatchBody;

  /// No description provided for @filterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get filterOverdue;

  /// No description provided for @filterRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get filterRename;

  /// No description provided for @filterSave.
  ///
  /// In en, this message translates to:
  /// **'Save filter'**
  String get filterSave;

  /// No description provided for @filterSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save this filter'**
  String get filterSaveTitle;

  /// No description provided for @filterSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {name}'**
  String filterSaved(String name);

  /// No description provided for @filterShare.
  ///
  /// In en, this message translates to:
  /// **'Share with everyone'**
  String get filterShare;

  /// No description provided for @filterShared.
  ///
  /// In en, this message translates to:
  /// **'Share with everyone in the tenant'**
  String get filterShared;

  /// No description provided for @filterSharedHelp.
  ///
  /// In en, this message translates to:
  /// **'Others see it under their saved filters; only you and administrators can change it.'**
  String get filterSharedHelp;

  /// No description provided for @filterSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed'**
  String get filterSnoozed;

  /// No description provided for @filterUnshare.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing'**
  String get filterUnshare;

  /// No description provided for @goMyWork.
  ///
  /// In en, this message translates to:
  /// **'Go to My work'**
  String get goMyWork;

  /// No description provided for @goTasks.
  ///
  /// In en, this message translates to:
  /// **'Go to Tasks'**
  String get goTasks;

  /// No description provided for @groupNone.
  ///
  /// In en, this message translates to:
  /// **'No grouping'**
  String get groupNone;

  /// No description provided for @groupProject.
  ///
  /// In en, this message translates to:
  /// **'Group by project'**
  String get groupProject;

  /// No description provided for @groupStatus.
  ///
  /// In en, this message translates to:
  /// **'Group by status'**
  String get groupStatus;

  /// No description provided for @lanesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get lanesEmpty;

  /// No description provided for @myWorkEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing assigned to you.'**
  String get myWorkEmpty;

  /// No description provided for @myWorkEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Open tasks assigned to you show here by deadline.'**
  String get myWorkEmptyBody;

  /// No description provided for @myWorkLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get myWorkLater;

  /// No description provided for @myWorkNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get myWorkNoDate;

  /// No description provided for @myWorkOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get myWorkOverdue;

  /// No description provided for @myWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'My work'**
  String get myWorkTitle;

  /// No description provided for @myWorkToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get myWorkToday;

  /// No description provided for @myWorkWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get myWorkWeek;

  /// No description provided for @projectOpenCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 open task} other{{count} open tasks}}'**
  String projectOpenCount(int count);

  /// No description provided for @sortCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get sortCreated;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortDescending;

  /// No description provided for @sortMenu.
  ///
  /// In en, this message translates to:
  /// **'Sort and group'**
  String get sortMenu;

  /// No description provided for @sortNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get sortNumber;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// No description provided for @sortUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get sortUpdated;

  /// No description provided for @sortUrgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get sortUrgency;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @viewBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get viewBoard;

  /// No description provided for @viewLanes.
  ///
  /// In en, this message translates to:
  /// **'Lanes'**
  String get viewLanes;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewList;

  /// No description provided for @viewSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch view'**
  String get viewSwitch;

  /// No description provided for @boardAssigned.
  ///
  /// In en, this message translates to:
  /// **'{ref} assigned'**
  String boardAssigned(String ref);

  /// No description provided for @boardAssignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign to…'**
  String get boardAssignTo;

  /// No description provided for @quickAddProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get quickAddProject;

  /// No description provided for @quickAddPickProject.
  ///
  /// In en, this message translates to:
  /// **'Choose a project'**
  String get quickAddPickProject;

  /// No description provided for @quickAddNoProjects.
  ///
  /// In en, this message translates to:
  /// **'There is no project to add to yet.'**
  String get quickAddNoProjects;

  /// No description provided for @quickAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Add another'**
  String get quickAddAnother;

  /// No description provided for @quickAddAnotherHelp.
  ///
  /// In en, this message translates to:
  /// **'Stay open for the next line'**
  String get quickAddAnotherHelp;

  /// No description provided for @quickAddPreviewRefused.
  ///
  /// In en, this message translates to:
  /// **'The server would refuse this: {reason}'**
  String quickAddPreviewRefused(String reason);

  /// No description provided for @quickAddPreviewOff.
  ///
  /// In en, this message translates to:
  /// **'This connection cannot preview lines; adding still works.'**
  String get quickAddPreviewOff;

  /// No description provided for @quickAddOffline.
  ///
  /// In en, this message translates to:
  /// **'Adding needs a connection to the server. The line is kept; try again when you are online.'**
  String get quickAddOffline;

  /// No description provided for @quickAddChipPriority.
  ///
  /// In en, this message translates to:
  /// **'priority'**
  String get quickAddChipPriority;

  /// No description provided for @quickAddChipTag.
  ///
  /// In en, this message translates to:
  /// **'tag'**
  String get quickAddChipTag;

  /// No description provided for @quickAddChipAssignee.
  ///
  /// In en, this message translates to:
  /// **'assignee'**
  String get quickAddChipAssignee;

  /// No description provided for @quickAddChipDue.
  ///
  /// In en, this message translates to:
  /// **'due'**
  String get quickAddChipDue;

  /// No description provided for @quickAddChipStatus.
  ///
  /// In en, this message translates to:
  /// **'status'**
  String get quickAddChipStatus;

  /// No description provided for @quickAddChipParent.
  ///
  /// In en, this message translates to:
  /// **'parent'**
  String get quickAddChipParent;

  /// No description provided for @quickAddChipTitle.
  ///
  /// In en, this message translates to:
  /// **'title'**
  String get quickAddChipTitle;

  /// No description provided for @quickAddSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get quickAddSuggestions;

  /// No description provided for @quickAddTemplates.
  ///
  /// In en, this message translates to:
  /// **'From a template'**
  String get quickAddTemplates;

  /// No description provided for @quickAddManageTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get quickAddManageTemplates;

  /// No description provided for @quickAddPaste.
  ///
  /// In en, this message translates to:
  /// **'Quick add from the clipboard'**
  String get quickAddPaste;

  /// No description provided for @quickAddClipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'The clipboard holds no text.'**
  String get quickAddClipboardEmpty;

  /// No description provided for @paletteGroupProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get paletteGroupProjects;

  /// No description provided for @paletteGroupRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent tasks'**
  String get paletteGroupRecent;

  /// No description provided for @paletteGroupContexts.
  ///
  /// In en, this message translates to:
  /// **'Switch to'**
  String get paletteGroupContexts;

  /// No description provided for @paletteGroupTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get paletteGroupTheme;

  /// No description provided for @paletteGroupTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get paletteGroupTemplates;

  /// No description provided for @paletteOpenTask.
  ///
  /// In en, this message translates to:
  /// **'Open {ref}'**
  String paletteOpenTask(String ref);

  /// No description provided for @paletteGoInbox.
  ///
  /// In en, this message translates to:
  /// **'Go to inbox'**
  String get paletteGoInbox;

  /// No description provided for @paletteGoMyWork.
  ///
  /// In en, this message translates to:
  /// **'Go to my work'**
  String get paletteGoMyWork;

  /// No description provided for @paletteGoTemplates.
  ///
  /// In en, this message translates to:
  /// **'Go to templates'**
  String get paletteGoTemplates;

  /// No description provided for @paletteThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get paletteThemeLight;

  /// No description provided for @paletteThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get paletteThemeDark;

  /// No description provided for @paletteThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Theme of the system'**
  String get paletteThemeSystem;

  /// No description provided for @paletteUseTemplate.
  ///
  /// In en, this message translates to:
  /// **'New task from {name}'**
  String paletteUseTemplate(String name);

  /// No description provided for @templatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templatesTitle;

  /// No description provided for @templatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks you add often, one tap away'**
  String get templatesSubtitle;

  /// No description provided for @templateNew.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get templateNew;

  /// No description provided for @templatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No templates yet.'**
  String get templatesEmpty;

  /// No description provided for @templatesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Save a task as a template to add it again in one tap.'**
  String get templatesEmptyBody;

  /// No description provided for @templateEveryProject.
  ///
  /// In en, this message translates to:
  /// **'Every project'**
  String get templateEveryProject;

  /// No description provided for @templateUses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Never used} =1{Used once} other{Used {count} times}}'**
  String templateUses(int count);

  /// No description provided for @templateSubtasks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 subtask} other{{count} subtasks}}'**
  String templateSubtasks(int count);

  /// No description provided for @templateUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get templateUse;

  /// No description provided for @templateEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit template'**
  String get templateEdit;

  /// No description provided for @templateDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete template'**
  String get templateDelete;

  /// No description provided for @templateDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String templateDeleteTitle(String name);

  /// No description provided for @templateDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks made from it stay.'**
  String get templateDeleteBody;

  /// No description provided for @templateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}'**
  String templateDeleted(String name);

  /// No description provided for @templateSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {name}'**
  String templateSaved(String name);

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get templateName;

  /// No description provided for @templateNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Unique in the tenant, at most 100 characters.'**
  String get templateNameHelp;

  /// No description provided for @templateFromTask.
  ///
  /// In en, this message translates to:
  /// **'From a task'**
  String get templateFromTask;

  /// No description provided for @templateFromScratch.
  ///
  /// In en, this message translates to:
  /// **'From scratch'**
  String get templateFromScratch;

  /// No description provided for @templateTaskRef.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get templateTaskRef;

  /// No description provided for @templateTaskRefHelp.
  ///
  /// In en, this message translates to:
  /// **'The reference of the task to keep, such as ops-12.'**
  String get templateTaskRefHelp;

  /// No description provided for @templateWithSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Keep its subtasks'**
  String get templateWithSubtasks;

  /// No description provided for @templateTenantWide.
  ///
  /// In en, this message translates to:
  /// **'Share with every project'**
  String get templateTenantWide;

  /// No description provided for @templateDueIn.
  ///
  /// In en, this message translates to:
  /// **'Due after'**
  String get templateDueIn;

  /// No description provided for @templateDueInHelp.
  ///
  /// In en, this message translates to:
  /// **'How long after a use the task falls due, such as 3d or 2w. Empty for none.'**
  String get templateDueInHelp;

  /// No description provided for @templateScratchNote.
  ///
  /// In en, this message translates to:
  /// **'tix keeps templates from tasks, so this also adds the task to the project.'**
  String get templateScratchNote;

  /// No description provided for @templateTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get templateTitle;

  /// No description provided for @templateTitleHelp.
  ///
  /// In en, this message translates to:
  /// **'{date}, {n} and {project} are filled in on each use.'**
  String templateTitleHelp(String date, String n, String project);

  /// No description provided for @templateBody.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get templateBody;

  /// No description provided for @templatePriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get templatePriority;

  /// No description provided for @templateTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get templateTags;

  /// No description provided for @templateTagsHelp.
  ///
  /// In en, this message translates to:
  /// **'Separated by spaces or commas.'**
  String get templateTagsHelp;

  /// No description provided for @templateRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get templateRecurrence;

  /// No description provided for @templateRecurrenceHelp.
  ///
  /// In en, this message translates to:
  /// **'Such as every 2 weeks. Empty for none.'**
  String get templateRecurrenceHelp;

  /// No description provided for @templateSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get templateSave;

  /// No description provided for @templateCreate.
  ///
  /// In en, this message translates to:
  /// **'Save template'**
  String get templateCreate;

  /// No description provided for @templateRecentTasks.
  ///
  /// In en, this message translates to:
  /// **'Recently opened'**
  String get templateRecentTasks;

  /// No description provided for @appShortcutInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get appShortcutInbox;

  /// No description provided for @appShortcutMyWork.
  ///
  /// In en, this message translates to:
  /// **'My work'**
  String get appShortcutMyWork;

  /// No description provided for @templateDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get templateDeleteAction;

  /// No description provided for @templateMore.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get templateMore;

  /// No description provided for @templateGeneralError.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {reason}'**
  String templateGeneralError(String reason);

  /// No description provided for @goInbox.
  ///
  /// In en, this message translates to:
  /// **'Go to inbox'**
  String get goInbox;

  /// No description provided for @inboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inboxTitle;

  /// No description provided for @inboxAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get inboxAll;

  /// No description provided for @inboxUnreadFilter.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get inboxUnreadFilter;

  /// No description provided for @inboxShowUnread.
  ///
  /// In en, this message translates to:
  /// **'Show unread only'**
  String get inboxShowUnread;

  /// No description provided for @inboxUnread.
  ///
  /// In en, this message translates to:
  /// **'unread'**
  String get inboxUnread;

  /// No description provided for @inboxAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get inboxAllCaughtUp;

  /// No description provided for @inboxUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread} other{{count} unread}}'**
  String inboxUnreadCount(int count);

  /// No description provided for @inboxToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get inboxToday;

  /// No description provided for @inboxYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get inboxYesterday;

  /// No description provided for @inboxEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get inboxEarlier;

  /// No description provided for @inboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get inboxEmpty;

  /// No description provided for @inboxEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When somebody mentions you, assigns you a task or comments on one you follow, it shows up here.'**
  String get inboxEmptyBody;

  /// No description provided for @inboxEmptyUnread.
  ///
  /// In en, this message translates to:
  /// **'Nothing unread.'**
  String get inboxEmptyUnread;

  /// No description provided for @inboxEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'Nothing of these kinds.'**
  String get inboxEmptyFiltered;

  /// No description provided for @inboxSomebody.
  ///
  /// In en, this message translates to:
  /// **'Somebody'**
  String get inboxSomebody;

  /// No description provided for @inboxWhatMention.
  ///
  /// In en, this message translates to:
  /// **'{who} mentioned you'**
  String inboxWhatMention(String who);

  /// No description provided for @inboxWhatAssigned.
  ///
  /// In en, this message translates to:
  /// **'{who} assigned you'**
  String inboxWhatAssigned(String who);

  /// No description provided for @inboxWhatComment.
  ///
  /// In en, this message translates to:
  /// **'{who} commented'**
  String inboxWhatComment(String who);

  /// No description provided for @inboxWhatStatus.
  ///
  /// In en, this message translates to:
  /// **'{who} moved it'**
  String inboxWhatStatus(String who);

  /// No description provided for @inboxWhatOther.
  ///
  /// In en, this message translates to:
  /// **'{who} changed it'**
  String inboxWhatOther(String who);

  /// No description provided for @inboxMovedTo.
  ///
  /// In en, this message translates to:
  /// **'moved to'**
  String get inboxMovedTo;

  /// No description provided for @inboxTaskGone.
  ///
  /// In en, this message translates to:
  /// **'A task that has been deleted'**
  String get inboxTaskGone;

  /// No description provided for @inboxNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get inboxNow;

  /// No description provided for @inboxMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String inboxMinutesAgo(int n);

  /// No description provided for @inboxHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} h'**
  String inboxHoursAgo(int n);

  /// No description provided for @inboxItemActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get inboxItemActions;

  /// No description provided for @inboxOpenTask.
  ///
  /// In en, this message translates to:
  /// **'Open task'**
  String get inboxOpenTask;

  /// No description provided for @inboxMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get inboxMarkRead;

  /// No description provided for @inboxMarkUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark unread'**
  String get inboxMarkUnread;

  /// No description provided for @inboxMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get inboxMarkAllRead;

  /// No description provided for @inboxMarkedAll.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Marked 1 item read} other{Marked {count} items read}}'**
  String inboxMarkedAll(int count);

  /// No description provided for @inboxMuteKind.
  ///
  /// In en, this message translates to:
  /// **'Stop {kind} in the inbox'**
  String inboxMuteKind(String kind);

  /// No description provided for @inboxMuted.
  ///
  /// In en, this message translates to:
  /// **'{kind} no longer reach your inbox'**
  String inboxMuted(String kind);

  /// No description provided for @inboxKindMention.
  ///
  /// In en, this message translates to:
  /// **'Mentions'**
  String get inboxKindMention;

  /// No description provided for @inboxKindAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get inboxKindAssigned;

  /// No description provided for @inboxKindComment.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get inboxKindComment;

  /// No description provided for @inboxKindStatus.
  ///
  /// In en, this message translates to:
  /// **'Status changes'**
  String get inboxKindStatus;

  /// No description provided for @inboxKindMentionHelp.
  ///
  /// In en, this message translates to:
  /// **'Somebody writes @you in a comment or a description.'**
  String get inboxKindMentionHelp;

  /// No description provided for @inboxKindAssignedHelp.
  ///
  /// In en, this message translates to:
  /// **'A task is assigned to you.'**
  String get inboxKindAssignedHelp;

  /// No description provided for @inboxKindCommentHelp.
  ///
  /// In en, this message translates to:
  /// **'Somebody comments on a task you are assigned to or starred.'**
  String get inboxKindCommentHelp;

  /// No description provided for @inboxKindStatusHelp.
  ///
  /// In en, this message translates to:
  /// **'A task assigned to you moves to another status.'**
  String get inboxKindStatusHelp;

  /// No description provided for @inboxKindsTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inboxKindsTitle;

  /// No description provided for @inboxKindsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What creates an item in your inbox, on every device.'**
  String get inboxKindsSubtitle;

  /// No description provided for @inboxKindsInfo.
  ///
  /// In en, this message translates to:
  /// **'Stored on the server, as under Settings, Inbox in the web app. Off, a kind creates no item; items already in your inbox stay. Your own changes never appear.'**
  String get inboxKindsInfo;

  /// No description provided for @inboxSummaryOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get inboxSummaryOverdue;

  /// No description provided for @inboxSummaryDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get inboxSummaryDueToday;

  /// No description provided for @inboxSummaryOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get inboxSummaryOpen;

  /// No description provided for @inboxSummaryDoneWeek.
  ///
  /// In en, this message translates to:
  /// **'Done in 7 days'**
  String get inboxSummaryDoneWeek;

  /// No description provided for @inboxCategory.
  ///
  /// In en, this message translates to:
  /// **'{category, select, todo{To do} inProgress{In progress} blocked{Blocked} waiting{Waiting} other{Other}}'**
  String inboxCategory(String category);

  /// No description provided for @inboxChannelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get inboxChannelsTitle;

  /// No description provided for @inboxChannelsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deliver your inbox to Slack, Discord, ntfy or any URL.'**
  String get inboxChannelsSubtitle;

  /// No description provided for @inboxChannelsInfo.
  ///
  /// In en, this message translates to:
  /// **'A channel is yours alone: it receives only your items, of the kinds it lists, and nothing of a kind you stopped above. The server posts each item as it is written.'**
  String get inboxChannelsInfo;

  /// No description provided for @inboxChannelsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No channels yet.'**
  String get inboxChannelsEmpty;

  /// No description provided for @inboxChannelAdd.
  ///
  /// In en, this message translates to:
  /// **'Add channel'**
  String get inboxChannelAdd;

  /// No description provided for @inboxChannelEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit channel'**
  String get inboxChannelEdit;

  /// No description provided for @inboxChannelSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get inboxChannelSave;

  /// No description provided for @inboxChannelSaved.
  ///
  /// In en, this message translates to:
  /// **'Channel saved'**
  String get inboxChannelSaved;

  /// No description provided for @inboxChannelAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {name}'**
  String inboxChannelAdded(String name);

  /// No description provided for @inboxChannelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get inboxChannelName;

  /// No description provided for @inboxChannelNameHint.
  ///
  /// In en, this message translates to:
  /// **'My Slack'**
  String get inboxChannelNameHint;

  /// No description provided for @inboxChannelUrl.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get inboxChannelUrl;

  /// No description provided for @inboxChannelUrlHelp.
  ///
  /// In en, this message translates to:
  /// **'The webhook or topic URL. It must be https.'**
  String get inboxChannelUrlHelp;

  /// No description provided for @inboxChannelFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get inboxChannelFormat;

  /// No description provided for @inboxChannelFormatGeneric.
  ///
  /// In en, this message translates to:
  /// **'Signed JSON'**
  String get inboxChannelFormatGeneric;

  /// No description provided for @inboxChannelKinds.
  ///
  /// In en, this message translates to:
  /// **'Kinds'**
  String get inboxChannelKinds;

  /// No description provided for @inboxChannelAllKinds.
  ///
  /// In en, this message translates to:
  /// **'Every kind'**
  String get inboxChannelAllKinds;

  /// No description provided for @inboxChannelOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get inboxChannelOff;

  /// No description provided for @inboxChannelSecretTitle.
  ///
  /// In en, this message translates to:
  /// **'Signing secret'**
  String get inboxChannelSecretTitle;

  /// No description provided for @inboxChannelSecretBody.
  ///
  /// In en, this message translates to:
  /// **'tix signs every signed JSON message with this secret. Copy it now: it is not shown again.'**
  String get inboxChannelSecretBody;

  /// No description provided for @inboxChannelSecretCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get inboxChannelSecretCopy;

  /// No description provided for @inboxChannelSecretDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get inboxChannelSecretDone;

  /// No description provided for @inboxChannelAbout.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get inboxChannelAbout;

  /// No description provided for @inboxChannelActive.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get inboxChannelActive;

  /// No description provided for @inboxChannelActiveHelp.
  ///
  /// In en, this message translates to:
  /// **'Off, the channel receives nothing.'**
  String get inboxChannelActiveHelp;

  /// No description provided for @inboxChannelTest.
  ///
  /// In en, this message translates to:
  /// **'Send test'**
  String get inboxChannelTest;

  /// No description provided for @inboxChannelTestQueued.
  ///
  /// In en, this message translates to:
  /// **'Test message queued'**
  String get inboxChannelTestQueued;

  /// No description provided for @inboxChannelDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get inboxChannelDeliveries;

  /// No description provided for @inboxChannelDeliveriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Newest first.'**
  String get inboxChannelDeliveriesSubtitle;

  /// No description provided for @inboxChannelNoDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Nothing delivered yet.'**
  String get inboxChannelNoDeliveries;

  /// No description provided for @inboxChannelGone.
  ///
  /// In en, this message translates to:
  /// **'This channel no longer exists.'**
  String get inboxChannelGone;

  /// No description provided for @inboxChannelDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get inboxChannelDangerZone;

  /// No description provided for @inboxChannelDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete channel'**
  String get inboxChannelDelete;

  /// No description provided for @inboxChannelDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String inboxChannelDeleteTitle(String name);

  /// No description provided for @inboxChannelDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The channel and its delivery log are removed. This cannot be undone.'**
  String get inboxChannelDeleteBody;

  /// No description provided for @inboxChannelDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}'**
  String inboxChannelDeleted(String name);

  /// No description provided for @inboxDeliveryDelivered.
  ///
  /// In en, this message translates to:
  /// **'delivered'**
  String get inboxDeliveryDelivered;

  /// No description provided for @inboxDeliveryFailed.
  ///
  /// In en, this message translates to:
  /// **'failed'**
  String get inboxDeliveryFailed;

  /// No description provided for @inboxDeliveryPending.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get inboxDeliveryPending;

  /// No description provided for @inboxDeliveryTest.
  ///
  /// In en, this message translates to:
  /// **'Test message'**
  String get inboxDeliveryTest;

  /// No description provided for @inboxDeliveryItem.
  ///
  /// In en, this message translates to:
  /// **'Inbox item'**
  String get inboxDeliveryItem;

  /// No description provided for @inboxDeliveryAttempts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt} other{{count} attempts}}'**
  String inboxDeliveryAttempts(int count);

  /// No description provided for @inboxDeliveryRedeliver.
  ///
  /// In en, this message translates to:
  /// **'Redeliver'**
  String get inboxDeliveryRedeliver;

  /// No description provided for @inboxDeliveryRequeued.
  ///
  /// In en, this message translates to:
  /// **'Queued again'**
  String get inboxDeliveryRequeued;

  /// No description provided for @liveUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get liveUpdated;

  /// No description provided for @liveChangedElsewhere.
  ///
  /// In en, this message translates to:
  /// **'This changed elsewhere. Your edits are kept.'**
  String get liveChangedElsewhere;

  /// No description provided for @liveChangedElsewhereBy.
  ///
  /// In en, this message translates to:
  /// **'@{handle} changed this. Your edits are kept.'**
  String liveChangedElsewhereBy(String handle);

  /// No description provided for @liveKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get liveKeepEditing;

  /// No description provided for @liveReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get liveReload;

  /// No description provided for @notifSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifSettingsTitle;

  /// No description provided for @notifSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On this device, inbox kinds and channels'**
  String get notifSettingsSubtitle;

  /// No description provided for @notifDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get notifDeviceTitle;

  /// No description provided for @notifDeviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For the active instance and tenant.'**
  String get notifDeviceSubtitle;

  /// No description provided for @notifDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Shown while the app is open or was put away a moment ago. A closed app cannot be told: tix has no push service yet. Channels below deliver everywhere.'**
  String get notifDeviceInfo;

  /// No description provided for @notifEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notify me about new inbox items'**
  String get notifEnabled;

  /// No description provided for @notifEnabledHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap a notification to open the task.'**
  String get notifEnabledHelp;

  /// No description provided for @notifBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked for tix.'**
  String get notifBlocked;

  /// No description provided for @notifBlockedHelp.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications for tix in the system settings, then turn this on again.'**
  String get notifBlockedHelp;

  /// No description provided for @notifNudge.
  ///
  /// In en, this message translates to:
  /// **'Get a notification when something new reaches your inbox.'**
  String get notifNudge;

  /// No description provided for @notifTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get notifTurnOn;

  /// No description provided for @notifNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notifNotNow;

  /// No description provided for @notifMore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more inbox item} other{{count} more inbox items}}'**
  String notifMore(int count);

  /// No description provided for @notifMoreBody.
  ///
  /// In en, this message translates to:
  /// **'Open the inbox to see them.'**
  String get notifMoreBody;

  /// Theme choice: dark on a pure black page, for OLED screens.
  ///
  /// In en, this message translates to:
  /// **'OLED black'**
  String get themeOled;

  /// Switch under the System theme: use the OLED black theme whenever the system is dark.
  ///
  /// In en, this message translates to:
  /// **'Pure black when dark'**
  String get themeSystemBlack;

  /// No description provided for @themeSystemBlackHelp.
  ///
  /// In en, this message translates to:
  /// **'Uses OLED black whenever the system is dark. Saves battery on OLED screens.'**
  String get themeSystemBlackHelp;
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
