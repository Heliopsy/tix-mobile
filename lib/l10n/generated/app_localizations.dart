// SPDX-License-Identifier: AGPL-3.0-or-later
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('fr'),
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

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

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
  /// **'Create one with New project, in the browser or with tix project add.'**
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

  /// No description provided for @bulkExit.
  ///
  /// In en, this message translates to:
  /// **'Exit select mode'**
  String get bulkExit;

  /// No description provided for @bulkExtendDown.
  ///
  /// In en, this message translates to:
  /// **'Extend selection down'**
  String get bulkExtendDown;

  /// No description provided for @bulkExtendUp.
  ///
  /// In en, this message translates to:
  /// **'Extend selection up'**
  String get bulkExtendUp;

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

  /// No description provided for @bulkSelectMode.
  ///
  /// In en, this message translates to:
  /// **'Select tasks'**
  String get bulkSelectMode;

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

  /// Command palette entry that opens the About screen.
  ///
  /// In en, this message translates to:
  /// **'About tix'**
  String get goAbout;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'The tix client for phones and desktops'**
  String get aboutTagline;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutIntro.
  ///
  /// In en, this message translates to:
  /// **'tix-mobile is the app for tix, the open source task tracker. It works with any tix server, or runs tix on this device with no server at all. The server decides what happens to your work, so tasks behave exactly as they do in tix\'s web app and on the command line.'**
  String get aboutIntro;

  /// No description provided for @aboutVersions.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get aboutVersions;

  /// No description provided for @aboutAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get aboutAppVersion;

  /// No description provided for @aboutEngineVersion.
  ///
  /// In en, this message translates to:
  /// **'Embedded engine'**
  String get aboutEngineVersion;

  /// No description provided for @aboutEngineNone.
  ///
  /// In en, this message translates to:
  /// **'Not in this build'**
  String get aboutEngineNone;

  /// No description provided for @aboutServerVersion.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get aboutServerVersion;

  /// No description provided for @aboutServerNone.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get aboutServerNone;

  /// No description provided for @aboutServerUnknown.
  ///
  /// In en, this message translates to:
  /// **'Could not be read'**
  String get aboutServerUnknown;

  /// No description provided for @aboutLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get aboutLinks;

  /// No description provided for @aboutWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutWebsite;

  /// No description provided for @aboutSource.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSource;

  /// No description provided for @aboutSourceHelp.
  ///
  /// In en, this message translates to:
  /// **'The complete source of this app, as the AGPL offers it'**
  String get aboutSourceHelp;

  /// No description provided for @aboutRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Roadmap'**
  String get aboutRoadmap;

  /// No description provided for @aboutRoadmapHelp.
  ///
  /// In en, this message translates to:
  /// **'What is planned next'**
  String get aboutRoadmapHelp;

  /// No description provided for @aboutChangelog.
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get aboutChangelog;

  /// No description provided for @aboutChangelogHelp.
  ///
  /// In en, this message translates to:
  /// **'What changed in each release'**
  String get aboutChangelogHelp;

  /// No description provided for @aboutServerProject.
  ///
  /// In en, this message translates to:
  /// **'tix server'**
  String get aboutServerProject;

  /// No description provided for @aboutServerProjectHelp.
  ///
  /// In en, this message translates to:
  /// **'The server, the web app and the command line'**
  String get aboutServerProjectHelp;

  /// No description provided for @aboutSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security policy'**
  String get aboutSecurity;

  /// No description provided for @aboutSecurityHelp.
  ///
  /// In en, this message translates to:
  /// **'How to report a vulnerability privately'**
  String get aboutSecurityHelp;

  /// No description provided for @aboutHelp.
  ///
  /// In en, this message translates to:
  /// **'Something wrong?'**
  String get aboutHelp;

  /// No description provided for @aboutReportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get aboutReportBug;

  /// No description provided for @aboutReportBugHelp.
  ///
  /// In en, this message translates to:
  /// **'Opens a new GitHub issue with the versions above filled in. Never paste an API token.'**
  String get aboutReportBugHelp;

  /// No description provided for @aboutCopyDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Copy diagnostics'**
  String get aboutCopyDiagnostics;

  /// No description provided for @aboutDiagnosticsCopied.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics copied.'**
  String get aboutDiagnosticsCopied;

  /// No description provided for @aboutIncludeServer.
  ///
  /// In en, this message translates to:
  /// **'Include the server address'**
  String get aboutIncludeServer;

  /// No description provided for @aboutIncludeServerHelp.
  ///
  /// In en, this message translates to:
  /// **'Off keeps a private server\'s address out of what you copy.'**
  String get aboutIncludeServerHelp;

  /// No description provided for @aboutLicence.
  ///
  /// In en, this message translates to:
  /// **'Licence'**
  String get aboutLicence;

  /// No description provided for @aboutLicenceBody.
  ///
  /// In en, this message translates to:
  /// **'tix-mobile is free software under the GNU AGPL, version 3 or later. Contributions are accepted under the project\'s contributor licence agreement (CLA).'**
  String get aboutLicenceBody;

  /// No description provided for @aboutLicences.
  ///
  /// In en, this message translates to:
  /// **'Licences'**
  String get aboutLicences;

  /// No description provided for @aboutLicencesHelp.
  ///
  /// In en, this message translates to:
  /// **'The open source software inside this app'**
  String get aboutLicencesHelp;

  /// No description provided for @aboutOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get aboutOpenFailed;

  /// Command palette entry that switches to the OLED black theme.
  ///
  /// In en, this message translates to:
  /// **'OLED black theme'**
  String get paletteThemeOled;

  /// No description provided for @manageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageTitle;

  /// No description provided for @manageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What you can manage in {tenant}'**
  String manageSubtitle(String tenant);

  /// No description provided for @goManage.
  ///
  /// In en, this message translates to:
  /// **'Go to Manage'**
  String get goManage;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @manageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to manage with this credential.'**
  String get manageEmpty;

  /// No description provided for @manageEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Projects, workflows, people and the tenant need scopes this token or role does not hold. Ask an admin for a wider one.'**
  String get manageEmptyBody;

  /// No description provided for @manageGroupProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get manageGroupProjects;

  /// No description provided for @manageGroupWorkflows.
  ///
  /// In en, this message translates to:
  /// **'Workflows'**
  String get manageGroupWorkflows;

  /// No description provided for @manageGroupFields.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get manageGroupFields;

  /// No description provided for @manageGroupPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get manageGroupPeople;

  /// No description provided for @manageGroupAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get manageGroupAccess;

  /// No description provided for @manageGroupTenant.
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get manageGroupTenant;

  /// No description provided for @manageGroupServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get manageGroupServer;

  /// No description provided for @manageProjectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, rename, recolour, archive and delete projects'**
  String get manageProjectsSubtitle;

  /// No description provided for @manageWorkflowsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'States, the moves between them and who may make them'**
  String get manageWorkflowsSubtitle;

  /// No description provided for @manageFieldsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The custom fields each project\'s tasks carry'**
  String get manageFieldsSubtitle;

  /// No description provided for @manageSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get manageSave;

  /// No description provided for @manageSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get manageSaveChanges;

  /// No description provided for @manageDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get manageDelete;

  /// No description provided for @manageClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get manageClear;

  /// No description provided for @manageYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get manageYes;

  /// No description provided for @manageNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get manageNo;

  /// No description provided for @manageDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get manageDangerZone;

  /// No description provided for @manageInherited.
  ///
  /// In en, this message translates to:
  /// **'Inherited'**
  String get manageInherited;

  /// No description provided for @manageDurationHelp.
  ///
  /// In en, this message translates to:
  /// **'A duration such as 30m or 4h. Empty inherits.'**
  String get manageDurationHelp;

  /// No description provided for @manageChanged.
  ///
  /// In en, this message translates to:
  /// **'changed'**
  String get manageChanged;

  /// No description provided for @manageTaskCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}}'**
  String manageTaskCount(int count);

  /// No description provided for @manageDragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get manageDragToReorder;

  /// No description provided for @colourNone.
  ///
  /// In en, this message translates to:
  /// **'No colour'**
  String get colourNone;

  /// No description provided for @colourSlate.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get colourSlate;

  /// No description provided for @colourRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colourRed;

  /// No description provided for @colourAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get colourAmber;

  /// No description provided for @colourGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colourGreen;

  /// No description provided for @colourTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colourTeal;

  /// No description provided for @colourBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colourBlue;

  /// No description provided for @colourViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get colourViolet;

  /// No description provided for @colourPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colourPink;

  /// No description provided for @colourCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom colour'**
  String get colourCustom;

  /// No description provided for @iconNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get iconNone;

  /// No description provided for @iconText.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get iconText;

  /// No description provided for @iconBuiltin.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconBuiltin;

  /// No description provided for @iconImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get iconImage;

  /// No description provided for @iconNoneHelp.
  ///
  /// In en, this message translates to:
  /// **'The first letters of the name stand in.'**
  String get iconNoneHelp;

  /// No description provided for @iconTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Emoji or letters'**
  String get iconTextLabel;

  /// No description provided for @iconTextHelp.
  ///
  /// In en, this message translates to:
  /// **'One emoji, or one or two letters.'**
  String get iconTextHelp;

  /// No description provided for @iconImageHelp.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPEG, WebP or SVG, at most 64 KB.'**
  String get iconImageHelp;

  /// No description provided for @iconUpload.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get iconUpload;

  /// No description provided for @projectNew.
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get projectNew;

  /// No description provided for @projectCreate.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get projectCreate;

  /// No description provided for @projectCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {name}.'**
  String projectCreated(String name);

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get projectName;

  /// No description provided for @projectKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get projectKey;

  /// No description provided for @projectKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'Starts every task reference, such as infra-1. Letters, digits, - and _.'**
  String get projectKeyHelp;

  /// No description provided for @projectKeyChangeHelp.
  ///
  /// In en, this message translates to:
  /// **'Changing it renames every task reference; the old key keeps working.'**
  String get projectKeyChangeHelp;

  /// No description provided for @projectDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get projectDescription;

  /// No description provided for @projectWorkflow.
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get projectWorkflow;

  /// No description provided for @projectWorkflowInfo.
  ///
  /// In en, this message translates to:
  /// **'The states this project\'s tasks move through. tix refuses a switch while a task sits in a state the new workflow lacks.'**
  String get projectWorkflowInfo;

  /// No description provided for @projectColour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get projectColour;

  /// No description provided for @projectIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get projectIcon;

  /// No description provided for @projectSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Project settings'**
  String get projectSettingsTitle;

  /// No description provided for @projectSectionProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get projectSectionProject;

  /// No description provided for @projectSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get projectSectionAppearance;

  /// No description provided for @projectSectionClaims.
  ///
  /// In en, this message translates to:
  /// **'Claims'**
  String get projectSectionClaims;

  /// No description provided for @projectClaimsInfo.
  ///
  /// In en, this message translates to:
  /// **'How long a claim on this project\'s tasks holds. The project\'s value outranks the workflow\'s and the tenant\'s; the longest lease can only be lower than the tenant\'s.'**
  String get projectClaimsInfo;

  /// No description provided for @projectLeaseDefault.
  ///
  /// In en, this message translates to:
  /// **'Lease length'**
  String get projectLeaseDefault;

  /// No description provided for @projectLeaseMax.
  ///
  /// In en, this message translates to:
  /// **'Longest lease'**
  String get projectLeaseMax;

  /// No description provided for @projectLeaseMaxHelp.
  ///
  /// In en, this message translates to:
  /// **'A duration such as 24h, below the tenant\'s ceiling. Empty inherits.'**
  String get projectLeaseMaxHelp;

  /// No description provided for @projectManageFields.
  ///
  /// In en, this message translates to:
  /// **'Custom fields'**
  String get projectManageFields;

  /// No description provided for @projectManageFieldsHelp.
  ///
  /// In en, this message translates to:
  /// **'Define the fields this project\'s tasks carry.'**
  String get projectManageFieldsHelp;

  /// No description provided for @projectReadOnly.
  ///
  /// In en, this message translates to:
  /// **'You can see these settings but not change them: that needs project:write.'**
  String get projectReadOnly;

  /// No description provided for @projectSaved.
  ///
  /// In en, this message translates to:
  /// **'Project saved.'**
  String get projectSaved;

  /// No description provided for @projectRekeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Change the project key?'**
  String get projectRekeyTitle;

  /// No description provided for @projectRekeyBody.
  ///
  /// In en, this message translates to:
  /// **'Every task reference changes with the key:'**
  String get projectRekeyBody;

  /// No description provided for @projectRekeyAlias.
  ///
  /// In en, this message translates to:
  /// **'Links, references and filters that use {old} keep working: the old key stays as an alias, and no other project can take it.'**
  String projectRekeyAlias(String old);

  /// No description provided for @projectRekeyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Change key'**
  String get projectRekeyConfirm;

  /// No description provided for @projectArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive project'**
  String get projectArchive;

  /// No description provided for @projectArchiveHelp.
  ///
  /// In en, this message translates to:
  /// **'Hides it from lists and keeps its tasks and history. tix has no way to unarchive.'**
  String get projectArchiveHelp;

  /// No description provided for @projectArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive {name}?'**
  String projectArchiveTitle(String name);

  /// No description provided for @projectArchiveBody.
  ///
  /// In en, this message translates to:
  /// **'The project leaves the default lists. Its tasks and history stay. tix cannot unarchive a project.'**
  String get projectArchiveBody;

  /// No description provided for @projectArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived {name}.'**
  String projectArchived(String name);

  /// No description provided for @projectArchivedBadge.
  ///
  /// In en, this message translates to:
  /// **'archived'**
  String get projectArchivedBadge;

  /// No description provided for @projectIsArchived.
  ///
  /// In en, this message translates to:
  /// **'This project is archived.'**
  String get projectIsArchived;

  /// No description provided for @projectDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete project'**
  String get projectDelete;

  /// No description provided for @projectDeleteHelp.
  ///
  /// In en, this message translates to:
  /// **'Removes it permanently. Its tasks move to another project or go with it.'**
  String get projectDeleteHelp;

  /// No description provided for @projectDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {key}?'**
  String projectDeleteTitle(String key);

  /// No description provided for @projectDeleteEmpty.
  ///
  /// In en, this message translates to:
  /// **'The project holds no tasks. Deleting it cannot be undone.'**
  String get projectDeleteEmpty;

  /// No description provided for @projectDeleteHolds.
  ///
  /// In en, this message translates to:
  /// **'It holds {live, plural, =1{1 task} other{{live} tasks}} and {trashed, plural, =1{1 in the trash} other{{trashed} in the trash}}. What happens to them?'**
  String projectDeleteHolds(int live, int trashed);

  /// No description provided for @projectDeleteMove.
  ///
  /// In en, this message translates to:
  /// **'Move them to another project'**
  String get projectDeleteMove;

  /// No description provided for @projectDeleteNoTarget.
  ///
  /// In en, this message translates to:
  /// **'There is no other active project to move them to.'**
  String get projectDeleteNoTarget;

  /// No description provided for @projectDeleteTarget.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get projectDeleteTarget;

  /// No description provided for @projectDeleteMapping.
  ///
  /// In en, this message translates to:
  /// **'Status after the move'**
  String get projectDeleteMapping;

  /// No description provided for @projectDeleteTasks.
  ///
  /// In en, this message translates to:
  /// **'Delete them permanently'**
  String get projectDeleteTasks;

  /// No description provided for @projectDeleteType.
  ///
  /// In en, this message translates to:
  /// **'Type {key} to confirm'**
  String projectDeleteType(String key);

  /// No description provided for @projectDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'The project and its tasks are deleted permanently.'**
  String get projectDeleteConfirm;

  /// No description provided for @projectDeleteMoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'The tasks move to {target}, then the project is deleted permanently.'**
  String projectDeleteMoveConfirm(String target);

  /// No description provided for @projectDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {key}.'**
  String projectDeleted(String key);

  /// No description provided for @fieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom fields'**
  String get fieldsTitle;

  /// No description provided for @fieldProjectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'tix defines fields per project. Pick one.'**
  String get fieldProjectsSubtitle;

  /// No description provided for @fieldsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No custom fields yet.'**
  String get fieldsEmpty;

  /// No description provided for @fieldsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'A field adds a value of your choosing to every task in the project, such as an environment or a customer.'**
  String get fieldsEmptyBody;

  /// No description provided for @fieldsReadOnly.
  ///
  /// In en, this message translates to:
  /// **'You can see these fields but not change them: that needs project:write.'**
  String get fieldsReadOnly;

  /// No description provided for @fieldNew.
  ///
  /// In en, this message translates to:
  /// **'New field'**
  String get fieldNew;

  /// No description provided for @fieldEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit {key}'**
  String fieldEdit(String key);

  /// No description provided for @fieldKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get fieldKey;

  /// No description provided for @fieldKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'How tasks and filters name the field, such as env.'**
  String get fieldKeyHelp;

  /// No description provided for @fieldKeyFixed.
  ///
  /// In en, this message translates to:
  /// **'The key names the field; define a new field to change it.'**
  String get fieldKeyFixed;

  /// No description provided for @fieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get fieldLabel;

  /// No description provided for @fieldLabelHelp.
  ///
  /// In en, this message translates to:
  /// **'What people see. Empty shows the key.'**
  String get fieldLabelHelp;

  /// No description provided for @fieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fieldType;

  /// No description provided for @fieldOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get fieldOptions;

  /// No description provided for @fieldOptionsHelp.
  ///
  /// In en, this message translates to:
  /// **'The allowed values, separated by commas.'**
  String get fieldOptionsHelp;

  /// No description provided for @fieldDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get fieldDefault;

  /// No description provided for @fieldNoDefault.
  ///
  /// In en, this message translates to:
  /// **'No default'**
  String get fieldNoDefault;

  /// No description provided for @fieldPickDefault.
  ///
  /// In en, this message translates to:
  /// **'Pick a default'**
  String get fieldPickDefault;

  /// No description provided for @fieldActorHint.
  ///
  /// In en, this message translates to:
  /// **'A handle, such as raj'**
  String get fieldActorHint;

  /// No description provided for @fieldDefaultIs.
  ///
  /// In en, this message translates to:
  /// **'default {value}'**
  String fieldDefaultIs(String value);

  /// No description provided for @fieldDefaultUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This default cannot be read as the field\'s type.'**
  String get fieldDefaultUnreadable;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @fieldRequiredHelp.
  ///
  /// In en, this message translates to:
  /// **'A new task without a value is refused, unless there is a default.'**
  String get fieldRequiredHelp;

  /// No description provided for @fieldSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {key}.'**
  String fieldSaved(String key);

  /// No description provided for @fieldDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the field {key}?'**
  String fieldDeleteTitle(String key);

  /// No description provided for @fieldDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks stop showing this field.'**
  String get fieldDeleteBody;

  /// No description provided for @fieldDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {key}.'**
  String fieldDeleted(String key);

  /// No description provided for @fieldTypeString.
  ///
  /// In en, this message translates to:
  /// **'Text, one line'**
  String get fieldTypeString;

  /// No description provided for @fieldTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text, several lines'**
  String get fieldTypeText;

  /// No description provided for @fieldTypeInt.
  ///
  /// In en, this message translates to:
  /// **'Whole number'**
  String get fieldTypeInt;

  /// No description provided for @fieldTypeFloat.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get fieldTypeFloat;

  /// No description provided for @fieldTypeBool.
  ///
  /// In en, this message translates to:
  /// **'Yes or no'**
  String get fieldTypeBool;

  /// No description provided for @fieldTypeDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldTypeDate;

  /// No description provided for @fieldTypeDatetime.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get fieldTypeDatetime;

  /// No description provided for @fieldTypeEnum.
  ///
  /// In en, this message translates to:
  /// **'Choice'**
  String get fieldTypeEnum;

  /// No description provided for @fieldTypeActor.
  ///
  /// In en, this message translates to:
  /// **'Person or agent'**
  String get fieldTypeActor;

  /// No description provided for @fieldTypeJson.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get fieldTypeJson;

  /// No description provided for @fieldTypeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get fieldTypeUnknown;

  /// No description provided for @categoryTodo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get categoryTodo;

  /// No description provided for @categoryInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get categoryInProgress;

  /// No description provided for @categoryBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get categoryBlocked;

  /// No description provided for @categoryWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get categoryWaiting;

  /// No description provided for @categoryDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get categoryDone;

  /// No description provided for @categoryCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get categoryCancelled;

  /// No description provided for @categoryDerived.
  ///
  /// In en, this message translates to:
  /// **'From the state (tix decides)'**
  String get categoryDerived;

  /// No description provided for @workflowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workflows'**
  String get workflowsTitle;

  /// No description provided for @workflowsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The states tasks move through, and how'**
  String get workflowsSubtitle;

  /// No description provided for @workflowsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No workflows.'**
  String get workflowsEmpty;

  /// No description provided for @workflowTitle.
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get workflowTitle;

  /// No description provided for @workflowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Key {key}'**
  String workflowSubtitle(String key);

  /// No description provided for @workflowBuiltin.
  ///
  /// In en, this message translates to:
  /// **'builtin'**
  String get workflowBuiltin;

  /// No description provided for @workflowStateCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 state} other{{count} states}}'**
  String workflowStateCount(int count);

  /// No description provided for @workflowNew.
  ///
  /// In en, this message translates to:
  /// **'New workflow'**
  String get workflowNew;

  /// No description provided for @workflowCreate.
  ///
  /// In en, this message translates to:
  /// **'Create workflow'**
  String get workflowCreate;

  /// No description provided for @workflowCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {name}.'**
  String workflowCreated(String name);

  /// No description provided for @workflowKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get workflowKey;

  /// No description provided for @workflowKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'Letters, digits, - and _, starting with a letter.'**
  String get workflowKeyHelp;

  /// No description provided for @workflowKeyTaken.
  ///
  /// In en, this message translates to:
  /// **'A workflow with this key exists; saving would replace it.'**
  String get workflowKeyTaken;

  /// No description provided for @workflowName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get workflowName;

  /// No description provided for @workflowStartFrom.
  ///
  /// In en, this message translates to:
  /// **'Start from'**
  String get workflowStartFrom;

  /// No description provided for @workflowMinimal.
  ///
  /// In en, this message translates to:
  /// **'Open and done'**
  String get workflowMinimal;

  /// No description provided for @workflowCopyOf.
  ///
  /// In en, this message translates to:
  /// **'A copy of {name}'**
  String workflowCopyOf(String name);

  /// No description provided for @workflowReadOnly.
  ///
  /// In en, this message translates to:
  /// **'You can see this workflow but not change it: that needs workflow:write.'**
  String get workflowReadOnly;

  /// No description provided for @workflowRefused.
  ///
  /// In en, this message translates to:
  /// **'tix refused the change'**
  String get workflowRefused;

  /// No description provided for @workflowSaved.
  ///
  /// In en, this message translates to:
  /// **'Workflow saved.'**
  String get workflowSaved;

  /// No description provided for @workflowSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get workflowSectionGeneral;

  /// No description provided for @workflowInitial.
  ///
  /// In en, this message translates to:
  /// **'Initial state'**
  String get workflowInitial;

  /// No description provided for @workflowInitialHelp.
  ///
  /// In en, this message translates to:
  /// **'Where a new task starts.'**
  String get workflowInitialHelp;

  /// No description provided for @workflowDefaultLease.
  ///
  /// In en, this message translates to:
  /// **'Lease length'**
  String get workflowDefaultLease;

  /// No description provided for @workflowSectionStates.
  ///
  /// In en, this message translates to:
  /// **'States'**
  String get workflowSectionStates;

  /// No description provided for @workflowStatesHelp.
  ///
  /// In en, this message translates to:
  /// **'Drag the handle to reorder. Tap a state to edit it.'**
  String get workflowStatesHelp;

  /// No description provided for @workflowAddState.
  ///
  /// In en, this message translates to:
  /// **'Add state'**
  String get workflowAddState;

  /// No description provided for @workflowEditState.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String workflowEditState(String name);

  /// No description provided for @workflowStateKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get workflowStateKey;

  /// No description provided for @workflowStateKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'What a task\'s status holds, such as review.'**
  String get workflowStateKeyHelp;

  /// No description provided for @workflowStateKeyRename.
  ///
  /// In en, this message translates to:
  /// **'Renaming moves this state\'s tasks to the new key when you save.'**
  String get workflowStateKeyRename;

  /// No description provided for @workflowStateKeyTaken.
  ///
  /// In en, this message translates to:
  /// **'Another state has this key.'**
  String get workflowStateKeyTaken;

  /// No description provided for @workflowStateLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get workflowStateLabel;

  /// No description provided for @workflowStateCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get workflowStateCategory;

  /// No description provided for @workflowStateCategoryInfo.
  ///
  /// In en, this message translates to:
  /// **'Groups the state for colours, boards and reports. Left to tix: done when terminal, to do for the initial state, in progress otherwise.'**
  String get workflowStateCategoryInfo;

  /// No description provided for @workflowStateInitial.
  ///
  /// In en, this message translates to:
  /// **'Initial state'**
  String get workflowStateInitial;

  /// No description provided for @workflowTerminal.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get workflowTerminal;

  /// No description provided for @workflowTerminalHelp.
  ///
  /// In en, this message translates to:
  /// **'Reaching it completes the task and satisfies what depends on it.'**
  String get workflowTerminalHelp;

  /// No description provided for @workflowRevert.
  ///
  /// In en, this message translates to:
  /// **'Revert when a claim runs out'**
  String get workflowRevert;

  /// No description provided for @workflowRevertHelp.
  ///
  /// In en, this message translates to:
  /// **'A claimed task here goes back when its lease expires.'**
  String get workflowRevertHelp;

  /// No description provided for @workflowRevertTo.
  ///
  /// In en, this message translates to:
  /// **'Go back to'**
  String get workflowRevertTo;

  /// No description provided for @workflowRevertsTo.
  ///
  /// In en, this message translates to:
  /// **'reverts to {state}'**
  String workflowRevertsTo(String state);

  /// No description provided for @workflowInitialBadge.
  ///
  /// In en, this message translates to:
  /// **'initial'**
  String get workflowInitialBadge;

  /// No description provided for @workflowSectionTransitions.
  ///
  /// In en, this message translates to:
  /// **'Transitions'**
  String get workflowSectionTransitions;

  /// No description provided for @workflowTransitionsHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap a state to allow the move. The rules button on a chosen move asks for a comment or a scope.'**
  String get workflowTransitionsHelp;

  /// No description provided for @workflowCanMoveTo.
  ///
  /// In en, this message translates to:
  /// **'From {name}, a task can move to'**
  String workflowCanMoveTo(String name);

  /// No description provided for @workflowNoMoves.
  ///
  /// In en, this message translates to:
  /// **'No move leaves this state.'**
  String get workflowNoMoves;

  /// No description provided for @workflowMoveRules.
  ///
  /// In en, this message translates to:
  /// **'Rules for this move'**
  String get workflowMoveRules;

  /// No description provided for @workflowRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'{from} to {to}'**
  String workflowRulesTitle(String from, String to);

  /// No description provided for @workflowNeedsComment.
  ///
  /// In en, this message translates to:
  /// **'Needs a comment'**
  String get workflowNeedsComment;

  /// No description provided for @workflowNeedsCommentHelp.
  ///
  /// In en, this message translates to:
  /// **'The move is refused unless it carries a comment.'**
  String get workflowNeedsCommentHelp;

  /// No description provided for @workflowNeedsScope.
  ///
  /// In en, this message translates to:
  /// **'Needs {scope}'**
  String workflowNeedsScope(String scope);

  /// No description provided for @workflowRequiredScope.
  ///
  /// In en, this message translates to:
  /// **'Required scope'**
  String get workflowRequiredScope;

  /// No description provided for @workflowRequiredScopeHelp.
  ///
  /// In en, this message translates to:
  /// **'Only someone holding it may make this move.'**
  String get workflowRequiredScopeHelp;

  /// No description provided for @workflowNoScope.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get workflowNoScope;

  /// No description provided for @workflowSectionRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get workflowSectionRoutes;

  /// No description provided for @workflowRoutesInfo.
  ///
  /// In en, this message translates to:
  /// **'How many moves each state is from the initial one. A move to a state further away passes through the states between, one transition at a time.'**
  String get workflowRoutesInfo;

  /// No description provided for @workflowSteps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String workflowSteps(int count);

  /// No description provided for @workflowUnreachable.
  ///
  /// In en, this message translates to:
  /// **'No route reaches it'**
  String get workflowUnreachable;

  /// No description provided for @workflowSectionRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed states'**
  String get workflowSectionRemoved;

  /// No description provided for @workflowRemovedHelp.
  ///
  /// In en, this message translates to:
  /// **'Tasks still in a removed state need somewhere to go, or tix refuses the save.'**
  String get workflowRemovedHelp;

  /// No description provided for @workflowMigrate.
  ///
  /// In en, this message translates to:
  /// **'Move tasks in {state} to'**
  String workflowMigrate(String state);

  /// No description provided for @workflowMigrateNone.
  ///
  /// In en, this message translates to:
  /// **'Nowhere (refused if it holds tasks)'**
  String get workflowMigrateNone;

  /// No description provided for @workflowDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete workflow'**
  String get workflowDelete;

  /// No description provided for @workflowDeleteHelp.
  ///
  /// In en, this message translates to:
  /// **'Only a workflow no project uses can be deleted.'**
  String get workflowDeleteHelp;

  /// No description provided for @workflowDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {key}?'**
  String workflowDeleteTitle(String key);

  /// No description provided for @workflowDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The workflow is deleted permanently.'**
  String get workflowDeleteBody;

  /// No description provided for @workflowDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {key}.'**
  String workflowDeleted(String key);

  /// No description provided for @manageUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get manageUsersTitle;

  /// No description provided for @manageUsersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'People in the tenant, their roles and invites'**
  String get manageUsersSubtitle;

  /// No description provided for @manageTokensTitle.
  ///
  /// In en, this message translates to:
  /// **'API tokens'**
  String get manageTokensTitle;

  /// No description provided for @manageTokensSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tokens for agents and scripts, and what each may do'**
  String get manageTokensSubtitle;

  /// No description provided for @manageTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Import and export'**
  String get manageTransferTitle;

  /// No description provided for @manageTransferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move tasks and whole tenants in and out'**
  String get manageTransferSubtitle;

  /// No description provided for @localInstanceAdvancedBody.
  ///
  /// In en, this message translates to:
  /// **'Use a database where it is, for example in a folder that Nextcloud, Syncthing or iCloud Drive keeps in sync, instead of a copy kept inside the app.'**
  String get localInstanceAdvancedBody;

  /// No description provided for @localInstanceAdvancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced: open in place'**
  String get localInstanceAdvancedTitle;

  /// No description provided for @localInstanceBrowseCreate.
  ///
  /// In en, this message translates to:
  /// **'Create here'**
  String get localInstanceBrowseCreate;

  /// No description provided for @localInstanceBrowseEmpty.
  ///
  /// In en, this message translates to:
  /// **'No folders or databases here.'**
  String get localInstanceBrowseEmpty;

  /// No description provided for @localInstanceBrowseNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New database in this folder'**
  String get localInstanceBrowseNewLabel;

  /// No description provided for @localInstanceBrowseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a database'**
  String get localInstanceBrowseTitle;

  /// No description provided for @localInstanceBrowseUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get localInstanceBrowseUp;

  /// No description provided for @localInstanceConflicts.
  ///
  /// In en, this message translates to:
  /// **'Sync conflict copies next to this file: {names}. Check which one holds your latest work before you go on.'**
  String localInstanceConflicts(String names);

  /// No description provided for @localInstanceDesktopIntro.
  ///
  /// In en, this message translates to:
  /// **'Create a new tix database. To use one you already have, open it in place below.'**
  String get localInstanceDesktopIntro;

  /// No description provided for @localInstanceEngineResting.
  ///
  /// In en, this message translates to:
  /// **'Stopped, starts again when needed'**
  String get localInstanceEngineResting;

  /// No description provided for @localInstanceEngineRunning.
  ///
  /// In en, this message translates to:
  /// **'Running at {address}'**
  String localInstanceEngineRunning(String address);

  /// No description provided for @localInstanceEngineStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get localInstanceEngineStarting;

  /// No description provided for @localInstanceEngineStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get localInstanceEngineStop;

  /// No description provided for @localInstanceEngineStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get localInstanceEngineStopped;

  /// No description provided for @localInstanceErrorAccess.
  ///
  /// In en, this message translates to:
  /// **'tix can no longer reach this file. Allow access again, or remove the instance and open the file again.'**
  String get localInstanceErrorAccess;

  /// No description provided for @localInstanceErrorFolder.
  ///
  /// In en, this message translates to:
  /// **'tix cannot create files in this folder, and SQLite needs to keep two files beside the database. Pick a folder you can write to.'**
  String get localInstanceErrorFolder;

  /// No description provided for @localInstanceErrorLock.
  ///
  /// In en, this message translates to:
  /// **'This file cannot be locked, so SQLite cannot keep it safe here. It may be on a cloud provider that does not offer real files.'**
  String get localInstanceErrorLock;

  /// No description provided for @localInstanceErrorNotDatabase.
  ///
  /// In en, this message translates to:
  /// **'This file is not a tix database on this device. If it is in a cloud folder, it may not be downloaded yet.'**
  String get localInstanceErrorNotDatabase;

  /// No description provided for @localInstanceErrorNotDownloaded.
  ///
  /// In en, this message translates to:
  /// **'This file is not downloaded to this device yet. Open it in the Files app to download it, then try again.'**
  String get localInstanceErrorNotDownloaded;

  /// No description provided for @localInstanceIdleHelp.
  ///
  /// In en, this message translates to:
  /// **'An engine that has served nothing for this long stops to save battery, and starts again the next time the app needs it.'**
  String get localInstanceIdleHelp;

  /// No description provided for @localInstanceIdleLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop an idle engine after'**
  String get localInstanceIdleLabel;

  /// No description provided for @localInstanceIdleMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String localInstanceIdleMinutes(int minutes);

  /// No description provided for @localInstanceIdleNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get localInstanceIdleNever;

  /// No description provided for @localInstanceIdleTitle.
  ///
  /// In en, this message translates to:
  /// **'Local databases'**
  String get localInstanceIdleTitle;

  /// No description provided for @localInstanceImportInstead.
  ///
  /// In en, this message translates to:
  /// **'Import a copy'**
  String get localInstanceImportInstead;

  /// No description provided for @localInstanceInPlaceNote.
  ///
  /// In en, this message translates to:
  /// **'Used in place'**
  String get localInstanceInPlaceNote;

  /// No description provided for @localInstanceOpenInPlace.
  ///
  /// In en, this message translates to:
  /// **'Open in place…'**
  String get localInstanceOpenInPlace;

  /// No description provided for @localInstancePermissionBody.
  ///
  /// In en, this message translates to:
  /// **'To open a database where it is, Android has to give tix \"All files access\". tix reads and writes only the database you pick and the files SQLite keeps beside it.'**
  String get localInstancePermissionBody;

  /// No description provided for @localInstancePermissionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get localInstancePermissionContinue;

  /// No description provided for @localInstancePermissionRefused.
  ///
  /// In en, this message translates to:
  /// **'All files access was not granted, so tix cannot open files in place. You can import a copy instead.'**
  String get localInstancePermissionRefused;

  /// No description provided for @localInstancePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow access to your files'**
  String get localInstancePermissionTitle;

  /// No description provided for @localInstanceSyncWarning.
  ///
  /// In en, this message translates to:
  /// **'A synced database must be open on one device at a time. Close tix on your other devices and let the sync finish first. tix stops the database whenever it goes to the background, so the sync client always finds a whole file.'**
  String get localInstanceSyncWarning;

  /// No description provided for @localInstanceWalLeftOver.
  ///
  /// In en, this message translates to:
  /// **'A write-ahead log was already beside this file. Another program may have it open, or a sync client copied one from another device.'**
  String get localInstanceWalLeftOver;

  /// Widget title: the reader's open assigned tasks.
  ///
  /// In en, this message translates to:
  /// **'My work'**
  String get widgetMyWork;

  /// Widget title: the inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get widgetInbox;

  /// Widget title: one button that opens quick add.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get widgetQuickAdd;

  /// The Quick add widget's button.
  ///
  /// In en, this message translates to:
  /// **'Add a task'**
  String get widgetAddTask;

  /// My work widget with no open tasks.
  ///
  /// In en, this message translates to:
  /// **'Nothing assigned to you'**
  String get widgetNothingDue;

  /// Inbox widget with nothing unread.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get widgetAllRead;

  /// Project widget whose project has no open tasks.
  ///
  /// In en, this message translates to:
  /// **'No open tasks'**
  String get widgetNoOpenTasks;

  /// Widget footer before how long ago the data was read, as in 'Updated 5 min ago'.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get widgetUpdated;

  /// A widget with no data yet.
  ///
  /// In en, this message translates to:
  /// **'Open tix to load this widget'**
  String get widgetOpenApp;

  /// Footer of a widget showing a local database, which never refreshes in the background.
  ///
  /// In en, this message translates to:
  /// **'Refreshes when tix is open'**
  String get widgetLocalStale;

  /// A task's due date has passed.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get widgetOverdue;

  /// A task is due today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get widgetToday;

  /// Accessibility label of the tick on a widget row.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get widgetComplete;

  /// Project widget whose project is not in the context it follows.
  ///
  /// In en, this message translates to:
  /// **'Not in this context'**
  String get widgetProjectMissing;

  /// A widget while no context is active.
  ///
  /// In en, this message translates to:
  /// **'Sign in to tix'**
  String get widgetSignedOut;

  /// My work widget: how many tasks did not fit.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String widgetMore(int count);

  /// Inbox widget: the unread count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing unread} =1{1 unread} other{{count} unread}}'**
  String widgetUnread(int count);

  /// Settings section about the home screen widgets.
  ///
  /// In en, this message translates to:
  /// **'Home screen widgets'**
  String get settingsWidgets;

  /// Settings switch: widgets on the lock screen show counts and no titles.
  ///
  /// In en, this message translates to:
  /// **'Counts only on the lock screen'**
  String get settingsWidgetLockCounts;

  /// Help under the lock screen counts switch.
  ///
  /// In en, this message translates to:
  /// **'Widgets on the lock screen say how many, not what.'**
  String get settingsWidgetLockCountsHelp;

  /// Explanation at the top of the widgets settings section.
  ///
  /// In en, this message translates to:
  /// **'Add tix widgets from your home screen. They show what the app last read, and a tick waits for the app if it cannot reach the server.'**
  String get settingsWidgetsHelp;

  /// A widget whose data is newer than it can read.
  ///
  /// In en, this message translates to:
  /// **'Open tix to update'**
  String get widgetOpenUpdate;

  /// Project widget with no project chosen yet.
  ///
  /// In en, this message translates to:
  /// **'Pick a project'**
  String get widgetPickProject;

  /// No description provided for @liveStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Live updates: {state}'**
  String liveStatusLabel(String state);

  /// No description provided for @liveStatusLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveStatusLive;

  /// No description provided for @liveStatusLiveInfo.
  ///
  /// In en, this message translates to:
  /// **'Changes made elsewhere show up here as they happen.'**
  String get liveStatusLiveInfo;

  /// No description provided for @liveStatusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get liveStatusConnecting;

  /// No description provided for @liveStatusConnectingInfo.
  ///
  /// In en, this message translates to:
  /// **'Connecting to live updates. Changes show up once it is through.'**
  String get liveStatusConnectingInfo;

  /// No description provided for @liveStatusPolling.
  ///
  /// In en, this message translates to:
  /// **'Polling'**
  String get liveStatusPolling;

  /// No description provided for @liveStatusPollingInfo.
  ///
  /// In en, this message translates to:
  /// **'The live connection keeps failing on this network, so updates come over plain HTTP instead. They can take a few seconds longer.'**
  String get liveStatusPollingInfo;

  /// No description provided for @liveStatusRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing'**
  String get liveStatusRefreshing;

  /// No description provided for @liveStatusRefreshingInfo.
  ///
  /// In en, this message translates to:
  /// **'Live updates do not get through and this server is too old to poll, so the screen reloads every {seconds} seconds.'**
  String liveStatusRefreshingInfo(int seconds);

  /// No description provided for @liveStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get liveStatusOffline;

  /// No description provided for @liveStatusOfflineInfo.
  ///
  /// In en, this message translates to:
  /// **'The server cannot be reached. The app keeps trying and catches up when it is back.'**
  String get liveStatusOfflineInfo;

  /// No description provided for @liveStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get liveStatusUnavailable;

  /// No description provided for @liveStatusUnavailableInfo.
  ///
  /// In en, this message translates to:
  /// **'This connection may not follow live updates (it needs the event:subscribe scope). Pull down to refresh instead.'**
  String get liveStatusUnavailableInfo;

  /// No description provided for @liveDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap for connection details'**
  String get liveDetailsHint;

  /// No description provided for @liveDetailsLongPressHint.
  ///
  /// In en, this message translates to:
  /// **'Long press for connection details'**
  String get liveDetailsLongPressHint;

  /// No description provided for @liveDetailsShow.
  ///
  /// In en, this message translates to:
  /// **'show connection details'**
  String get liveDetailsShow;

  /// No description provided for @liveDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection details'**
  String get liveDetailsTitle;

  /// No description provided for @liveDetailsNone.
  ///
  /// In en, this message translates to:
  /// **'There is no live connection for this context.'**
  String get liveDetailsNone;

  /// No description provided for @liveDetailsPausedInfo.
  ///
  /// In en, this message translates to:
  /// **'Live updates are paused while the local instance\'s engine is stopped. They start again with it.'**
  String get liveDetailsPausedInfo;

  /// No description provided for @liveDetailsModePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get liveDetailsModePaused;

  /// No description provided for @liveDetailsModeClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get liveDetailsModeClosed;

  /// No description provided for @liveDetailsServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get liveDetailsServer;

  /// No description provided for @liveDetailsMode.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get liveDetailsMode;

  /// No description provided for @liveDetailsTransport.
  ///
  /// In en, this message translates to:
  /// **'Carried over'**
  String get liveDetailsTransport;

  /// No description provided for @liveTransportWebsocket.
  ///
  /// In en, this message translates to:
  /// **'WebSocket'**
  String get liveTransportWebsocket;

  /// No description provided for @liveTransportPoll.
  ///
  /// In en, this message translates to:
  /// **'Long polling over HTTP'**
  String get liveTransportPoll;

  /// No description provided for @liveTransportRefresh.
  ///
  /// In en, this message translates to:
  /// **'Reloading on a timer'**
  String get liveTransportRefresh;

  /// No description provided for @liveTransportNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get liveTransportNone;

  /// No description provided for @liveSourceProbe.
  ///
  /// In en, this message translates to:
  /// **'Background WebSocket try'**
  String get liveSourceProbe;

  /// No description provided for @liveSourcePoll.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get liveSourcePoll;

  /// No description provided for @liveDetailsSince.
  ///
  /// In en, this message translates to:
  /// **'Since'**
  String get liveDetailsSince;

  /// No description provided for @liveDetailsLastContact.
  ///
  /// In en, this message translates to:
  /// **'Last reached the server'**
  String get liveDetailsLastContact;

  /// No description provided for @liveDetailsLastEvent.
  ///
  /// In en, this message translates to:
  /// **'Last event'**
  String get liveDetailsLastEvent;

  /// No description provided for @liveDetailsNever.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get liveDetailsNever;

  /// No description provided for @liveDetailsFailuresInRow.
  ///
  /// In en, this message translates to:
  /// **'Failures in a row'**
  String get liveDetailsFailuresInRow;

  /// No description provided for @liveDetailsWindowFailures.
  ///
  /// In en, this message translates to:
  /// **'WebSocket failures'**
  String get liveDetailsWindowFailures;

  /// No description provided for @liveDetailsWindowValue.
  ///
  /// In en, this message translates to:
  /// **'{count} of {max} within {minutes} min before switching to polling'**
  String liveDetailsWindowValue(int count, int max, int minutes);

  /// No description provided for @liveDetailsPollEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Poll endpoint'**
  String get liveDetailsPollEndpoint;

  /// No description provided for @liveDetailsPollAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get liveDetailsPollAvailable;

  /// No description provided for @liveDetailsPollMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing on this server (404 or 405)'**
  String get liveDetailsPollMissing;

  /// No description provided for @liveDetailsNextRetry.
  ///
  /// In en, this message translates to:
  /// **'Next try'**
  String get liveDetailsNextRetry;

  /// No description provided for @liveDetailsNextProbe.
  ///
  /// In en, this message translates to:
  /// **'Next WebSocket try'**
  String get liveDetailsNextProbe;

  /// No description provided for @liveDetailsLastError.
  ///
  /// In en, this message translates to:
  /// **'Last error'**
  String get liveDetailsLastError;

  /// No description provided for @liveDetailsNoError.
  ///
  /// In en, this message translates to:
  /// **'Nothing has failed since the app started.'**
  String get liveDetailsNoError;

  /// No description provided for @liveDetailsErrorWhat.
  ///
  /// In en, this message translates to:
  /// **'What'**
  String get liveDetailsErrorWhat;

  /// No description provided for @liveDetailsErrorAt.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get liveDetailsErrorAt;

  /// No description provided for @liveDetailsErrorSource.
  ///
  /// In en, this message translates to:
  /// **'During'**
  String get liveDetailsErrorSource;

  /// No description provided for @liveDetailsErrorType.
  ///
  /// In en, this message translates to:
  /// **'Exception'**
  String get liveDetailsErrorType;

  /// No description provided for @liveDetailsHttpStatus.
  ///
  /// In en, this message translates to:
  /// **'HTTP status'**
  String get liveDetailsHttpStatus;

  /// No description provided for @liveDetailsOsError.
  ///
  /// In en, this message translates to:
  /// **'System error'**
  String get liveDetailsOsError;

  /// No description provided for @liveDetailsOsErrorValue.
  ///
  /// In en, this message translates to:
  /// **'{message} (code {code})'**
  String liveDetailsOsErrorValue(String message, String code);

  /// No description provided for @liveDetailsCloseCode.
  ///
  /// In en, this message translates to:
  /// **'Close code'**
  String get liveDetailsCloseCode;

  /// No description provided for @liveDetailsErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get liveDetailsErrorMessage;

  /// No description provided for @liveErrorUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server'**
  String get liveErrorUnreachable;

  /// No description provided for @liveErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Timed out'**
  String get liveErrorTimeout;

  /// No description provided for @liveErrorTls.
  ///
  /// In en, this message translates to:
  /// **'Secure connection failed'**
  String get liveErrorTls;

  /// No description provided for @liveErrorUpgradeRefused.
  ///
  /// In en, this message translates to:
  /// **'WebSocket upgrade refused'**
  String get liveErrorUpgradeRefused;

  /// No description provided for @liveErrorClosed.
  ///
  /// In en, this message translates to:
  /// **'Connection closed'**
  String get liveErrorClosed;

  /// No description provided for @liveErrorRefused.
  ///
  /// In en, this message translates to:
  /// **'Refused by the server'**
  String get liveErrorRefused;

  /// No description provided for @liveErrorHttp.
  ///
  /// In en, this message translates to:
  /// **'HTTP error'**
  String get liveErrorHttp;

  /// No description provided for @liveErrorOther.
  ///
  /// In en, this message translates to:
  /// **'Other error'**
  String get liveErrorOther;

  /// No description provided for @liveDetailsHints.
  ///
  /// In en, this message translates to:
  /// **'What it may mean'**
  String get liveDetailsHints;

  /// No description provided for @liveHintIdleTimeout.
  ///
  /// In en, this message translates to:
  /// **'A proxy or load balancer may be closing idle connections. Its read timeout should be above 60 s for /api/v1/events and /api/v1/events/poll.'**
  String get liveHintIdleTimeout;

  /// No description provided for @liveHintNoUpgrade.
  ///
  /// In en, this message translates to:
  /// **'The WebSocket fails while plain HTTP works, so the proxy in front of tix may not forward WebSocket upgrades.'**
  String get liveHintNoUpgrade;

  /// No description provided for @liveHintUnreachable.
  ///
  /// In en, this message translates to:
  /// **'The phone could not reach the host. Check the network, the address, and that the server is running.'**
  String get liveHintUnreachable;

  /// No description provided for @liveHintTls.
  ///
  /// In en, this message translates to:
  /// **'The server\'s certificate was not accepted: it may be expired, self-signed, or issued for another name.'**
  String get liveHintTls;

  /// No description provided for @liveHintRefused.
  ///
  /// In en, this message translates to:
  /// **'The server refused live updates to this connection. A token needs the event:subscribe scope.'**
  String get liveHintRefused;

  /// No description provided for @liveHintHttp.
  ///
  /// In en, this message translates to:
  /// **'The server or a proxy answered HTTP {status}. Its logs should say why.'**
  String liveHintHttp(String status);

  /// No description provided for @liveHintPollMissing.
  ///
  /// In en, this message translates to:
  /// **'This server is older than the poll endpoint, so what is on screen is reloaded on a timer instead.'**
  String get liveHintPollMissing;

  /// No description provided for @liveDetailsHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent changes'**
  String get liveDetailsHistory;

  /// No description provided for @liveDetailsHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet.'**
  String get liveDetailsHistoryEmpty;

  /// No description provided for @liveDetailsHistoryError.
  ///
  /// In en, this message translates to:
  /// **'{kind} ({source})'**
  String liveDetailsHistoryError(String kind, String source);

  /// No description provided for @liveDetailsReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect now'**
  String get liveDetailsReconnect;

  /// No description provided for @liveDetailsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy details'**
  String get liveDetailsCopy;

  /// No description provided for @liveDetailsCopied.
  ///
  /// In en, this message translates to:
  /// **'Connection details copied. Tokens and cookies are left out.'**
  String get liveDetailsCopied;

  /// No description provided for @aboutConnectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Connection details'**
  String get aboutConnectionDetails;

  /// No description provided for @aboutConnectionDetailsHelp.
  ///
  /// In en, this message translates to:
  /// **'How live updates reach this context, and what failed last'**
  String get aboutConnectionDetailsHelp;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyToClipboard;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied.'**
  String get copiedToClipboard;

  /// No description provided for @secretShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get secretShare;

  /// No description provided for @secretDone.
  ///
  /// In en, this message translates to:
  /// **'I have kept it'**
  String get secretDone;

  /// No description provided for @roleViewer.
  ///
  /// In en, this message translates to:
  /// **'viewer'**
  String get roleViewer;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'member'**
  String get roleMember;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'admin'**
  String get roleAdmin;

  /// No description provided for @roleViewerHelp.
  ///
  /// In en, this message translates to:
  /// **'Reads tasks, projects and workflows.'**
  String get roleViewerHelp;

  /// No description provided for @roleMemberHelp.
  ///
  /// In en, this message translates to:
  /// **'Also creates, edits, claims and moves tasks, comments and exports.'**
  String get roleMemberHelp;

  /// No description provided for @roleAdminHelp.
  ///
  /// In en, this message translates to:
  /// **'May do everything in this tenant.'**
  String get roleAdminHelp;

  /// No description provided for @peopleTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get peopleTitle;

  /// No description provided for @peopleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add user'**
  String get peopleAdd;

  /// No description provided for @peopleActive.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active} other{{count} active}}'**
  String peopleActive(int count);

  /// No description provided for @peopleDisabledCount.
  ///
  /// In en, this message translates to:
  /// **'{count} disabled'**
  String peopleDisabledCount(int count);

  /// No description provided for @peopleAddMember.
  ///
  /// In en, this message translates to:
  /// **'Add a member'**
  String get peopleAddMember;

  /// No description provided for @peopleAddMemberButton.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get peopleAddMemberButton;

  /// No description provided for @peopleAddMemberHelp.
  ///
  /// In en, this message translates to:
  /// **'Give an existing agent or account a role in this tenant.'**
  String get peopleAddMemberHelp;

  /// No description provided for @peopleNoActors.
  ///
  /// In en, this message translates to:
  /// **'Every actor already belongs to this tenant.'**
  String get peopleNoActors;

  /// No description provided for @peopleAgent.
  ///
  /// In en, this message translates to:
  /// **'agent'**
  String get peopleAgent;

  /// No description provided for @peoplePerson.
  ///
  /// In en, this message translates to:
  /// **'person'**
  String get peoplePerson;

  /// No description provided for @peopleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No users yet.'**
  String get peopleEmpty;

  /// No description provided for @peopleYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get peopleYou;

  /// No description provided for @peopleNoRole.
  ///
  /// In en, this message translates to:
  /// **'no role'**
  String get peopleNoRole;

  /// No description provided for @peopleDisabled.
  ///
  /// In en, this message translates to:
  /// **'disabled'**
  String get peopleDisabled;

  /// No description provided for @peopleInvites.
  ///
  /// In en, this message translates to:
  /// **'Pending invites'**
  String get peopleInvites;

  /// No description provided for @peopleInvitesInfo.
  ///
  /// In en, this message translates to:
  /// **'Links issued and not used yet. Re-issuing stops the old link and gives you a new one to send; revoking stops it.'**
  String get peopleInvitesInfo;

  /// No description provided for @peopleInvited.
  ///
  /// In en, this message translates to:
  /// **'invited'**
  String get peopleInvited;

  /// No description provided for @peopleInvitedBy.
  ///
  /// In en, this message translates to:
  /// **'invited by {handle}'**
  String peopleInvitedBy(String handle);

  /// No description provided for @peopleInviteExpired.
  ///
  /// In en, this message translates to:
  /// **'expired'**
  String get peopleInviteExpired;

  /// No description provided for @peopleInviteExpires.
  ///
  /// In en, this message translates to:
  /// **'expires {day}'**
  String peopleInviteExpires(String day);

  /// No description provided for @peopleReissue.
  ///
  /// In en, this message translates to:
  /// **'Re-issue'**
  String get peopleReissue;

  /// No description provided for @peopleRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get peopleRevoke;

  /// No description provided for @peopleRevokeInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke the invite for {email}?'**
  String peopleRevokeInviteTitle(String email);

  /// No description provided for @peopleRevokeInviteBody.
  ///
  /// In en, this message translates to:
  /// **'The link stops working at once. The account stays, without a password, until you delete it or invite it again.'**
  String get peopleRevokeInviteBody;

  /// No description provided for @peopleInviteRevoked.
  ///
  /// In en, this message translates to:
  /// **'Invite for {email} revoked'**
  String peopleInviteRevoked(String email);

  /// No description provided for @peopleSignInMode.
  ///
  /// In en, this message translates to:
  /// **'How they sign in'**
  String get peopleSignInMode;

  /// No description provided for @peopleSignInModeInfo.
  ///
  /// In en, this message translates to:
  /// **'An invite link lets the person choose their own password. It works once and expires; tix sends no email, so you pass the link on yourself.'**
  String get peopleSignInModeInfo;

  /// No description provided for @peopleModeInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite link'**
  String get peopleModeInvite;

  /// No description provided for @peopleModePassword.
  ///
  /// In en, this message translates to:
  /// **'Set a password'**
  String get peopleModePassword;

  /// No description provided for @peopleDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get peopleDisplayName;

  /// No description provided for @peopleDisplayNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Empty shows the email instead.'**
  String get peopleDisplayNameHelp;

  /// No description provided for @peopleRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get peopleRole;

  /// No description provided for @peopleLinkExpires.
  ///
  /// In en, this message translates to:
  /// **'Link expires after'**
  String get peopleLinkExpires;

  /// No description provided for @peopleDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String peopleDays(int days);

  /// No description provided for @peopleYear.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get peopleYear;

  /// No description provided for @peopleInviteHelp.
  ///
  /// In en, this message translates to:
  /// **'You get a link to send them. It works once, and they choose their own password with it.'**
  String get peopleInviteHelp;

  /// No description provided for @peopleRequireChangeFirst.
  ///
  /// In en, this message translates to:
  /// **'Require a password change at first sign-in'**
  String get peopleRequireChangeFirst;

  /// No description provided for @peopleCreateInvite.
  ///
  /// In en, this message translates to:
  /// **'Create invite link'**
  String get peopleCreateInvite;

  /// No description provided for @peopleCreateUser.
  ///
  /// In en, this message translates to:
  /// **'Create user'**
  String get peopleCreateUser;

  /// No description provided for @peopleCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {email}'**
  String peopleCreated(String email);

  /// No description provided for @peopleInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Invite link'**
  String get peopleInviteLink;

  /// No description provided for @peopleSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send this link to {email}'**
  String peopleSendLink(String email);

  /// No description provided for @peopleLinkOnce.
  ///
  /// In en, this message translates to:
  /// **'It works once. tix does not send email, and the link is not shown again.'**
  String get peopleLinkOnce;

  /// No description provided for @peopleLinkOnceUntil.
  ///
  /// In en, this message translates to:
  /// **'It works once and expires on {day}. tix does not send email, and the link is not shown again.'**
  String peopleLinkOnceUntil(String day);

  /// No description provided for @peopleRename.
  ///
  /// In en, this message translates to:
  /// **'Change display name'**
  String get peopleRename;

  /// No description provided for @peopleNoName.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get peopleNoName;

  /// No description provided for @peopleChangeRole.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get peopleChangeRole;

  /// No description provided for @peopleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Signs in with'**
  String get peopleSignIn;

  /// No description provided for @peopleSso.
  ///
  /// In en, this message translates to:
  /// **'Single sign-on ({provider})'**
  String peopleSso(String provider);

  /// No description provided for @peoplePasswordSignIn.
  ///
  /// In en, this message translates to:
  /// **'A password'**
  String get peoplePasswordSignIn;

  /// No description provided for @peopleSecondFactor.
  ///
  /// In en, this message translates to:
  /// **'Second factor'**
  String get peopleSecondFactor;

  /// No description provided for @peopleTotpOn.
  ///
  /// In en, this message translates to:
  /// **'Enrolled'**
  String get peopleTotpOn;

  /// No description provided for @peopleTotpOff.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get peopleTotpOff;

  /// No description provided for @peopleCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get peopleCreatedAt;

  /// No description provided for @peopleAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get peopleAccess;

  /// No description provided for @peopleDisabledSwitch.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get peopleDisabledSwitch;

  /// No description provided for @peopleDisabledHelp.
  ///
  /// In en, this message translates to:
  /// **'A disabled account cannot sign in: its sessions end and its API tokens are revoked at once. Turning it back on does not bring the tokens back.'**
  String get peopleDisabledHelp;

  /// No description provided for @peopleDisabledToast.
  ///
  /// In en, this message translates to:
  /// **'{name} disabled'**
  String peopleDisabledToast(String name);

  /// No description provided for @peopleEnabledToast.
  ///
  /// In en, this message translates to:
  /// **'{name} can sign in again'**
  String peopleEnabledToast(String name);

  /// No description provided for @peopleRequireChange.
  ///
  /// In en, this message translates to:
  /// **'Ask to change the password at next sign-in'**
  String get peopleRequireChange;

  /// No description provided for @peopleRequireChangeHelp.
  ///
  /// In en, this message translates to:
  /// **'Their next sign-in with a password stops at a page asking for a new one. Open sessions and API tokens are not affected.'**
  String get peopleRequireChangeHelp;

  /// No description provided for @peopleSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get peopleSaved;

  /// No description provided for @peopleSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get peopleSave;

  /// No description provided for @peopleRoleChanged.
  ///
  /// In en, this message translates to:
  /// **'{name} is now {role}'**
  String peopleRoleChanged(String name, String role);

  /// No description provided for @peopleDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get peopleDangerZone;

  /// No description provided for @peopleRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Remove from this tenant'**
  String get peopleRemoveMember;

  /// No description provided for @peopleRemoveMemberHelp.
  ///
  /// In en, this message translates to:
  /// **'Ends the membership and keeps the account.'**
  String get peopleRemoveMemberHelp;

  /// No description provided for @peopleRemoveMemberButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get peopleRemoveMemberButton;

  /// No description provided for @peopleRemoveMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from this tenant?'**
  String peopleRemoveMemberTitle(String name);

  /// No description provided for @peopleRemoveMemberBody.
  ///
  /// In en, this message translates to:
  /// **'They stop acting here at once. The account stays and can be given a role again.'**
  String get peopleRemoveMemberBody;

  /// No description provided for @peopleMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from this tenant'**
  String peopleMemberRemoved(String name);

  /// No description provided for @peopleDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String peopleDelete(String name);

  /// No description provided for @peopleDeleteHelp.
  ///
  /// In en, this message translates to:
  /// **'Deleting removes the account and its membership. Disabling is usually what you want, and can be undone.'**
  String get peopleDeleteHelp;

  /// No description provided for @peopleDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get peopleDeleteButton;

  /// No description provided for @peopleDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String peopleDeleteTitle(String name);

  /// No description provided for @peopleDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Deleting removes the account and its membership. It cannot be undone.'**
  String get peopleDeleteBody;

  /// No description provided for @peopleDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String peopleDeleted(String name);

  /// No description provided for @tokensTitle.
  ///
  /// In en, this message translates to:
  /// **'API tokens'**
  String get tokensTitle;

  /// No description provided for @tokensMine.
  ///
  /// In en, this message translates to:
  /// **'My API tokens'**
  String get tokensMine;

  /// No description provided for @tokensIssue.
  ///
  /// In en, this message translates to:
  /// **'Issue a token'**
  String get tokensIssue;

  /// No description provided for @tokensIssueButton.
  ///
  /// In en, this message translates to:
  /// **'Issue token'**
  String get tokensIssueButton;

  /// No description provided for @tokensWholeTenant.
  ///
  /// In en, this message translates to:
  /// **'Every token of this tenant'**
  String get tokensWholeTenant;

  /// No description provided for @tokensOwn.
  ///
  /// In en, this message translates to:
  /// **'Your tokens'**
  String get tokensOwn;

  /// No description provided for @tokensWholeNote.
  ///
  /// In en, this message translates to:
  /// **'You hold tenant:admin, so this lists every token of the tenant and whose it is. Revoking somebody else\'s is recorded as such.'**
  String get tokensWholeNote;

  /// No description provided for @tokensIntro.
  ///
  /// In en, this message translates to:
  /// **'A token is the credential a script, the CLI or an agent presents instead of signing in. It carries its own scopes, and its value is shown once, when it is issued.'**
  String get tokensIntro;

  /// No description provided for @tokensEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tokens.'**
  String get tokensEmpty;

  /// No description provided for @tokensActive.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get tokensActive;

  /// No description provided for @tokensExpired.
  ///
  /// In en, this message translates to:
  /// **'expired'**
  String get tokensExpired;

  /// No description provided for @tokensRevoked.
  ///
  /// In en, this message translates to:
  /// **'revoked'**
  String get tokensRevoked;

  /// No description provided for @tokensRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get tokensRevoke;

  /// No description provided for @tokensOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner: {name}'**
  String tokensOwner(String name);

  /// No description provided for @tokensOwnerYou.
  ///
  /// In en, this message translates to:
  /// **'Owner: {name} (you)'**
  String tokensOwnerYou(String name);

  /// No description provided for @tokensCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {day}'**
  String tokensCreated(String day);

  /// No description provided for @tokensExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires {day}'**
  String tokensExpires(String day);

  /// No description provided for @tokensNeverExpires.
  ///
  /// In en, this message translates to:
  /// **'Never expires'**
  String get tokensNeverExpires;

  /// No description provided for @tokensNotUsed.
  ///
  /// In en, this message translates to:
  /// **'Not used yet'**
  String get tokensNotUsed;

  /// No description provided for @tokensLastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last used {when}'**
  String tokensLastUsed(String when);

  /// No description provided for @tokensRevokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke {name}?'**
  String tokensRevokeTitle(String name);

  /// No description provided for @tokensRevokeBody.
  ///
  /// In en, this message translates to:
  /// **'Whatever holds this token stops authenticating at once. It cannot be undone, and the value cannot be recovered.'**
  String get tokensRevokeBody;

  /// No description provided for @tokensRevokeOther.
  ///
  /// In en, this message translates to:
  /// **'This token is {name}\'s, not yours, and the trail will record that you ended somebody else\'s.'**
  String tokensRevokeOther(String name);

  /// No description provided for @tokensRevokeNamed.
  ///
  /// In en, this message translates to:
  /// **'Revoke {name}'**
  String tokensRevokeNamed(String name);

  /// No description provided for @tokensRevokedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} revoked'**
  String tokensRevokedToast(String name);

  /// No description provided for @tokensName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tokensName;

  /// No description provided for @tokensNameHelp.
  ///
  /// In en, this message translates to:
  /// **'What you will choose by when you revoke it, such as ci or laptop. No two live tokens share a name.'**
  String get tokensNameHelp;

  /// No description provided for @tokensScopes.
  ///
  /// In en, this message translates to:
  /// **'Scopes'**
  String get tokensScopes;

  /// No description provided for @tokensNotHeld.
  ///
  /// In en, this message translates to:
  /// **'You do not hold this scope, so you cannot grant it.'**
  String get tokensNotHeld;

  /// No description provided for @tokensPresetAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get tokensPresetAgent;

  /// No description provided for @tokensPresetAgentNote.
  ///
  /// In en, this message translates to:
  /// **'Read, create and edit tasks, claim them, move them and comment.'**
  String get tokensPresetAgentNote;

  /// No description provided for @tokensPresetRead.
  ///
  /// In en, this message translates to:
  /// **'Read only'**
  String get tokensPresetRead;

  /// No description provided for @tokensPresetReadNote.
  ///
  /// In en, this message translates to:
  /// **'Read tasks, projects and workflows, and follow the event stream.'**
  String get tokensPresetReadNote;

  /// No description provided for @tokensExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get tokensExpiry;

  /// No description provided for @tokensExpiryInfo.
  ///
  /// In en, this message translates to:
  /// **'An expiry is the one control that limits the damage of a token that leaks without anybody noticing. Prefer the shortest window the work fits in.'**
  String get tokensExpiryInfo;

  /// No description provided for @tokensNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get tokensNever;

  /// No description provided for @tokensIssuedTitle.
  ///
  /// In en, this message translates to:
  /// **'Token {name} issued'**
  String tokensIssuedTitle(String name);

  /// No description provided for @tokensValue.
  ///
  /// In en, this message translates to:
  /// **'Copy this token now'**
  String get tokensValue;

  /// No description provided for @tokensValueWarning.
  ///
  /// In en, this message translates to:
  /// **'Keep it somewhere safe. It is not shown again, and nothing can show it later.'**
  String get tokensValueWarning;

  /// No description provided for @scopeAll.
  ///
  /// In en, this message translates to:
  /// **'Everything but global admin and account history. Only for a credential you trust like yourself.'**
  String get scopeAll;

  /// No description provided for @scopeGroupTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get scopeGroupTasks;

  /// No description provided for @scopeGroupProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get scopeGroupProjects;

  /// No description provided for @scopeGroupWorkflows.
  ///
  /// In en, this message translates to:
  /// **'Workflows'**
  String get scopeGroupWorkflows;

  /// No description provided for @scopeGroupComments.
  ///
  /// In en, this message translates to:
  /// **'Comments and artifacts'**
  String get scopeGroupComments;

  /// No description provided for @scopeGroupEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get scopeGroupEvents;

  /// No description provided for @scopeGroupAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get scopeGroupAdmin;

  /// No description provided for @scopeGroupAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get scopeGroupAccount;

  /// No description provided for @scopeTaskRead.
  ///
  /// In en, this message translates to:
  /// **'Read tasks, their comments and history.'**
  String get scopeTaskRead;

  /// No description provided for @scopeTaskWrite.
  ///
  /// In en, this message translates to:
  /// **'Create and edit tasks.'**
  String get scopeTaskWrite;

  /// No description provided for @scopeTaskTransition.
  ///
  /// In en, this message translates to:
  /// **'Move a task from one state to another.'**
  String get scopeTaskTransition;

  /// No description provided for @scopeTaskClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim tasks, renew the lease and release it.'**
  String get scopeTaskClaim;

  /// No description provided for @scopeTaskDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete tasks and restore them from the trash.'**
  String get scopeTaskDelete;

  /// No description provided for @scopeTaskReclaim.
  ///
  /// In en, this message translates to:
  /// **'End a lease another worker holds.'**
  String get scopeTaskReclaim;

  /// No description provided for @scopeTaskApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve or reject work on a workflow edge that asks for it.'**
  String get scopeTaskApprove;

  /// No description provided for @scopeProjectRead.
  ///
  /// In en, this message translates to:
  /// **'Read projects.'**
  String get scopeProjectRead;

  /// No description provided for @scopeProjectWrite.
  ///
  /// In en, this message translates to:
  /// **'Create and change projects.'**
  String get scopeProjectWrite;

  /// No description provided for @scopeWorkflowRead.
  ///
  /// In en, this message translates to:
  /// **'Read workflows.'**
  String get scopeWorkflowRead;

  /// No description provided for @scopeWorkflowWrite.
  ///
  /// In en, this message translates to:
  /// **'Create and change workflows.'**
  String get scopeWorkflowWrite;

  /// No description provided for @scopeCommentWrite.
  ///
  /// In en, this message translates to:
  /// **'Comment on tasks.'**
  String get scopeCommentWrite;

  /// No description provided for @scopeArtifactWrite.
  ///
  /// In en, this message translates to:
  /// **'Attach artifacts to tasks.'**
  String get scopeArtifactWrite;

  /// No description provided for @scopeEventSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Follow the live event stream.'**
  String get scopeEventSubscribe;

  /// No description provided for @scopeUserAdmin.
  ///
  /// In en, this message translates to:
  /// **'Create, change and remove users.'**
  String get scopeUserAdmin;

  /// No description provided for @scopeTotpAdmin.
  ///
  /// In en, this message translates to:
  /// **'Clear another person\'s second factor.'**
  String get scopeTotpAdmin;

  /// No description provided for @scopeTokenAdmin.
  ///
  /// In en, this message translates to:
  /// **'Issue and revoke API tokens.'**
  String get scopeTokenAdmin;

  /// No description provided for @scopeWebhookAdmin.
  ///
  /// In en, this message translates to:
  /// **'Manage outgoing webhooks.'**
  String get scopeWebhookAdmin;

  /// No description provided for @scopeTenantAdmin.
  ///
  /// In en, this message translates to:
  /// **'Manage the tenant, its members and domains.'**
  String get scopeTenantAdmin;

  /// No description provided for @scopeSyncAdmin.
  ///
  /// In en, this message translates to:
  /// **'Manage and run imports from other trackers.'**
  String get scopeSyncAdmin;

  /// No description provided for @scopeAuditRead.
  ///
  /// In en, this message translates to:
  /// **'Read the audit log.'**
  String get scopeAuditRead;

  /// No description provided for @scopeExport.
  ///
  /// In en, this message translates to:
  /// **'Export tasks and a snapshot of the whole tenant.'**
  String get scopeExport;

  /// No description provided for @scopeImport.
  ///
  /// In en, this message translates to:
  /// **'Import tasks and snapshots into the tenant.'**
  String get scopeImport;

  /// No description provided for @scopeGlobalAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administer every tenant on this server. Only a global admin\'s token can carry it.'**
  String get scopeGlobalAdmin;

  /// No description provided for @scopeAccountRead.
  ///
  /// In en, this message translates to:
  /// **'Read your own account\'s history, which names every tenant you belong to. Only a token for your own account can carry it.'**
  String get scopeAccountRead;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get accountTitle;

  /// No description provided for @accountKind.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get accountKind;

  /// No description provided for @accountKindToken.
  ///
  /// In en, this message translates to:
  /// **'An API token'**
  String get accountKindToken;

  /// No description provided for @accountKindAgent.
  ///
  /// In en, this message translates to:
  /// **'An agent'**
  String get accountKindAgent;

  /// No description provided for @accountKindPerson.
  ///
  /// In en, this message translates to:
  /// **'A person'**
  String get accountKindPerson;

  /// No description provided for @accountGlobalAdmin.
  ///
  /// In en, this message translates to:
  /// **'global admin'**
  String get accountGlobalAdmin;

  /// No description provided for @accountGlobalAdminYes.
  ///
  /// In en, this message translates to:
  /// **'Administers every tenant of this server'**
  String get accountGlobalAdminYes;

  /// No description provided for @accountMemberships.
  ///
  /// In en, this message translates to:
  /// **'Your tenants'**
  String get accountMemberships;

  /// No description provided for @accountMembershipsHelp.
  ///
  /// In en, this message translates to:
  /// **'Every tenant this account belongs to, with its role there.'**
  String get accountMembershipsHelp;

  /// No description provided for @accountCurrent.
  ///
  /// In en, this message translates to:
  /// **'current'**
  String get accountCurrent;

  /// No description provided for @accountHistory.
  ///
  /// In en, this message translates to:
  /// **'Account history'**
  String get accountHistory;

  /// No description provided for @accountHistoryHelp.
  ///
  /// In en, this message translates to:
  /// **'Every change to your password, second factor and memberships, in every tenant. Only you and global admins can read this.'**
  String get accountHistoryHelp;

  /// No description provided for @accountHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing has changed yet.'**
  String get accountHistoryEmpty;

  /// No description provided for @accountHistoryNotReadable.
  ///
  /// In en, this message translates to:
  /// **'This token cannot read your account\'s history: it needs the account:read scope, which only a token minted for your own account carries.'**
  String get accountHistoryNotReadable;

  /// No description provided for @accountBy.
  ///
  /// In en, this message translates to:
  /// **'by {email}'**
  String accountBy(String email);

  /// No description provided for @accountBySystem.
  ///
  /// In en, this message translates to:
  /// **'by the system'**
  String get accountBySystem;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar feed'**
  String get calendarTitle;

  /// No description provided for @calendarLead.
  ///
  /// In en, this message translates to:
  /// **'Your due dates in Google, Apple or Outlook calendar'**
  String get calendarLead;

  /// No description provided for @calendarUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Nothing to manage here'**
  String get calendarUnavailable;

  /// No description provided for @calendarUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'A calendar feed reads tasks as you, and this credential cannot read tasks.'**
  String get calendarUnavailableBody;

  /// No description provided for @calendarCreate.
  ///
  /// In en, this message translates to:
  /// **'Create feed'**
  String get calendarCreate;

  /// No description provided for @calendarNone.
  ///
  /// In en, this message translates to:
  /// **'No calendar feed'**
  String get calendarNone;

  /// No description provided for @calendarNoneBody.
  ///
  /// In en, this message translates to:
  /// **'A private address your calendar subscribes to, so your due dates appear beside the rest of your week.'**
  String get calendarNoneBody;

  /// No description provided for @calendarFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed address'**
  String get calendarFeed;

  /// No description provided for @calendarFeedInfo.
  ///
  /// In en, this message translates to:
  /// **'Each task with a due date is an all-day event that links back here. Anybody holding the address can read what it lists, so treat it like a password. Only a hash of it is kept, so it cannot be shown again.'**
  String get calendarFeedInfo;

  /// No description provided for @calendarActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get calendarActive;

  /// No description provided for @calendarCreatedOn.
  ///
  /// In en, this message translates to:
  /// **'Created {day}. The address was shown once; rotate to get a new one.'**
  String calendarCreatedOn(String day);

  /// No description provided for @calendarShownOnce.
  ///
  /// In en, this message translates to:
  /// **'The address was shown once; rotate to get a new one.'**
  String get calendarShownOnce;

  /// No description provided for @calendarFilter.
  ///
  /// In en, this message translates to:
  /// **'Feed filter'**
  String get calendarFilter;

  /// No description provided for @calendarFilterDefault.
  ///
  /// In en, this message translates to:
  /// **'The tasks assigned to you that are not finished'**
  String get calendarFilterDefault;

  /// No description provided for @calendarFilterHint.
  ///
  /// In en, this message translates to:
  /// **'project:infra tag:ops'**
  String get calendarFilterHint;

  /// No description provided for @calendarFilterHelp.
  ///
  /// In en, this message translates to:
  /// **'The task list\'s filter language. Empty means yours, not finished. Only tasks with a due date are listed.'**
  String get calendarFilterHelp;

  /// No description provided for @calendarEditFilter.
  ///
  /// In en, this message translates to:
  /// **'Change filter'**
  String get calendarEditFilter;

  /// No description provided for @calendarSaveFilter.
  ///
  /// In en, this message translates to:
  /// **'Save filter'**
  String get calendarSaveFilter;

  /// No description provided for @calendarFilterSaved.
  ///
  /// In en, this message translates to:
  /// **'Feed filter saved'**
  String get calendarFilterSaved;

  /// No description provided for @calendarRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate the address'**
  String get calendarRotate;

  /// No description provided for @calendarRotateHelp.
  ///
  /// In en, this message translates to:
  /// **'A new address with the same filter; the old one stops at once.'**
  String get calendarRotateHelp;

  /// No description provided for @calendarRotateButton.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get calendarRotateButton;

  /// No description provided for @calendarRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke the feed'**
  String get calendarRevoke;

  /// No description provided for @calendarRevokeHelp.
  ///
  /// In en, this message translates to:
  /// **'The address stops answering. Subscribed calendars keep what they last fetched.'**
  String get calendarRevokeHelp;

  /// No description provided for @calendarRevokeButton.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get calendarRevokeButton;

  /// No description provided for @calendarRevokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke the calendar feed?'**
  String get calendarRevokeTitle;

  /// No description provided for @calendarRevokeBody.
  ///
  /// In en, this message translates to:
  /// **'The address stops at once. Remove the subscription from your calendar app too.'**
  String get calendarRevokeBody;

  /// No description provided for @calendarRevoked.
  ///
  /// In en, this message translates to:
  /// **'Calendar feed revoked'**
  String get calendarRevoked;

  /// No description provided for @calendarAddress.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to this address'**
  String get calendarAddress;

  /// No description provided for @calendarOnce.
  ///
  /// In en, this message translates to:
  /// **'Add it in your calendar app. It is not shown again, so copy it now.'**
  String get calendarOnce;

  /// No description provided for @calendarRotatedOnce.
  ///
  /// In en, this message translates to:
  /// **'This address replaces the old one, which has stopped. Subscribe to it again wherever the old one was used. It is not shown again.'**
  String get calendarRotatedOnce;

  /// No description provided for @calendarLists.
  ///
  /// In en, this message translates to:
  /// **'Lists: {filter}'**
  String calendarLists(String filter);

  /// No description provided for @calendarListsDefault.
  ///
  /// In en, this message translates to:
  /// **'Lists the tasks assigned to you that are not finished.'**
  String get calendarListsDefault;

  /// No description provided for @calendarHowGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar: Other calendars, then From URL, and paste the address.'**
  String get calendarHowGoogle;

  /// No description provided for @calendarHowApple.
  ///
  /// In en, this message translates to:
  /// **'Apple Calendar: File, then New Calendar Subscription, or use Subscribe on this device.'**
  String get calendarHowApple;

  /// No description provided for @calendarHowOutlook.
  ///
  /// In en, this message translates to:
  /// **'Outlook: Add calendar, then Subscribe from web, and paste the address.'**
  String get calendarHowOutlook;

  /// No description provided for @calendarSubscribeHere.
  ///
  /// In en, this message translates to:
  /// **'Subscribe on this device'**
  String get calendarSubscribeHere;

  /// No description provided for @transferTitle.
  ///
  /// In en, this message translates to:
  /// **'Export and import'**
  String get transferTitle;

  /// No description provided for @transferNoProjects.
  ///
  /// In en, this message translates to:
  /// **'Create a project before exporting or importing tasks.'**
  String get transferNoProjects;

  /// No description provided for @transferExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export tasks'**
  String get transferExportTitle;

  /// No description provided for @transferExportHelp.
  ///
  /// In en, this message translates to:
  /// **'One project\'s tasks, or the ones a filter picks, as a file.'**
  String get transferExportHelp;

  /// No description provided for @transferQuery.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get transferQuery;

  /// No description provided for @transferQueryHelp.
  ///
  /// In en, this message translates to:
  /// **'The task list\'s filter language. Empty exports every task.'**
  String get transferQueryHelp;

  /// No description provided for @transferFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get transferFormat;

  /// No description provided for @transferFormatCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV, for spreadsheets'**
  String get transferFormatCsv;

  /// No description provided for @transferFormatNdjson.
  ///
  /// In en, this message translates to:
  /// **'NDJSON, one task per line'**
  String get transferFormatNdjson;

  /// No description provided for @transferFormatMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Markdown table'**
  String get transferFormatMarkdown;

  /// No description provided for @transferColumns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get transferColumns;

  /// No description provided for @transferDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get transferDates;

  /// No description provided for @transferDatesIso.
  ///
  /// In en, this message translates to:
  /// **'Date and time (ISO)'**
  String get transferDatesIso;

  /// No description provided for @transferDatesDay.
  ///
  /// In en, this message translates to:
  /// **'Day only'**
  String get transferDatesDay;

  /// No description provided for @transferDelimiter.
  ///
  /// In en, this message translates to:
  /// **'Delimiter'**
  String get transferDelimiter;

  /// No description provided for @transferDelimiterComma.
  ///
  /// In en, this message translates to:
  /// **'Comma'**
  String get transferDelimiterComma;

  /// No description provided for @transferDelimiterSemicolon.
  ///
  /// In en, this message translates to:
  /// **'Semicolon'**
  String get transferDelimiterSemicolon;

  /// No description provided for @transferDelimiterTab.
  ///
  /// In en, this message translates to:
  /// **'Tab'**
  String get transferDelimiterTab;

  /// No description provided for @transferDelimiterBar.
  ///
  /// In en, this message translates to:
  /// **'Vertical bar'**
  String get transferDelimiterBar;

  /// No description provided for @transferFinished.
  ///
  /// In en, this message translates to:
  /// **'Include finished tasks'**
  String get transferFinished;

  /// No description provided for @transferSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Include subtasks'**
  String get transferSubtasks;

  /// No description provided for @transferTrashed.
  ///
  /// In en, this message translates to:
  /// **'Include tasks in the trash'**
  String get transferTrashed;

  /// No description provided for @transferExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get transferExportButton;

  /// No description provided for @transferExported.
  ///
  /// In en, this message translates to:
  /// **'Saved {name}'**
  String transferExported(String name);

  /// No description provided for @transferSnapshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get transferSnapshotTitle;

  /// No description provided for @transferSnapshotHelp.
  ///
  /// In en, this message translates to:
  /// **'Everything in this tenant as one NDJSON file, which tix can import elsewhere.'**
  String get transferSnapshotHelp;

  /// No description provided for @transferSnapshotComments.
  ///
  /// In en, this message translates to:
  /// **'Include comments'**
  String get transferSnapshotComments;

  /// No description provided for @transferSnapshotButton.
  ///
  /// In en, this message translates to:
  /// **'Export snapshot'**
  String get transferSnapshotButton;

  /// No description provided for @transferImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import tasks'**
  String get transferImportTitle;

  /// No description provided for @transferImportHelp.
  ///
  /// In en, this message translates to:
  /// **'A CSV, JSON or NDJSON file of tasks, including files Jira, GitHub, Trello and Linear write. You see what would happen before anything changes.'**
  String get transferImportHelp;

  /// No description provided for @transferPick.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get transferPick;

  /// No description provided for @transferDryRun.
  ///
  /// In en, this message translates to:
  /// **'{rows} rows: {created} to create, {updated} to update, {skipped} skipped, {failed} failed.'**
  String transferDryRun(
    int rows,
    int created,
    int updated,
    int skipped,
    int failed,
  );

  /// No description provided for @transferImportError.
  ///
  /// In en, this message translates to:
  /// **'Line {line}: {message}'**
  String transferImportError(int line, String message);

  /// No description provided for @transferImportButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 task} other{Import {count} tasks}}'**
  String transferImportButton(int count);

  /// No description provided for @transferImported.
  ///
  /// In en, this message translates to:
  /// **'Imported: {created} created, {updated} updated'**
  String transferImported(int created, int updated);

  /// No description provided for @columnRef.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get columnRef;

  /// No description provided for @columnTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get columnTitle;

  /// No description provided for @columnParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get columnParent;

  /// No description provided for @columnDependsOn.
  ///
  /// In en, this message translates to:
  /// **'Depends on'**
  String get columnDependsOn;

  /// No description provided for @columnRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get columnRepeat;

  /// No description provided for @columnCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get columnCreated;

  /// No description provided for @columnUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get columnUpdated;

  /// No description provided for @columnStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get columnStarted;

  /// No description provided for @columnCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get columnCompleted;

  /// No description provided for @columnDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get columnDeleted;

  /// No description provided for @columnCreator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get columnCreator;

  /// No description provided for @columnProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get columnProject;

  /// No description provided for @columnId.
  ///
  /// In en, this message translates to:
  /// **'Identifier'**
  String get columnId;

  /// No description provided for @columnComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get columnComments;

  /// No description provided for @columnHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get columnHistory;

  /// No description provided for @settingsAccountHelp.
  ///
  /// In en, this message translates to:
  /// **'Profile, tenants and history'**
  String get settingsAccountHelp;

  /// No description provided for @settingsCalendarHelp.
  ///
  /// In en, this message translates to:
  /// **'Your due dates in your calendar app'**
  String get settingsCalendarHelp;

  /// No description provided for @settingsTokensHelp.
  ///
  /// In en, this message translates to:
  /// **'Credentials for scripts, the CLI and agents'**
  String get settingsTokensHelp;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityTitle;

  /// No description provided for @securitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your second factor and SSH keys'**
  String get securitySubtitle;

  /// No description provided for @totpTitle.
  ///
  /// In en, this message translates to:
  /// **'Second factor'**
  String get totpTitle;

  /// No description provided for @totpInfo.
  ///
  /// In en, this message translates to:
  /// **'A code from an authenticator app, asked for after your password. Recovery codes let you in when the app is not at hand.'**
  String get totpInfo;

  /// No description provided for @totpOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get totpOn;

  /// No description provided for @totpOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get totpOff;

  /// No description provided for @totpPending.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed'**
  String get totpPending;

  /// No description provided for @totpSince.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String totpSince(String date);

  /// No description provided for @totpOnBody.
  ///
  /// In en, this message translates to:
  /// **'Signing in asks for a code from your authenticator app after your password.'**
  String get totpOnBody;

  /// No description provided for @totpOffBody.
  ///
  /// In en, this message translates to:
  /// **'Signing in asks only for your password.'**
  String get totpOffBody;

  /// No description provided for @totpPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Setup was started but never confirmed with a code. Set it up again to finish.'**
  String get totpPendingBody;

  /// No description provided for @totpRequiredOn.
  ///
  /// In en, this message translates to:
  /// **'Your tenant requires a second factor for: {surfaces}.'**
  String totpRequiredOn(String surfaces);

  /// No description provided for @totpSurfaceWeb.
  ///
  /// In en, this message translates to:
  /// **'the browser'**
  String get totpSurfaceWeb;

  /// No description provided for @totpSurfaceCli.
  ///
  /// In en, this message translates to:
  /// **'the command line'**
  String get totpSurfaceCli;

  /// No description provided for @totpSurfaceSsh.
  ///
  /// In en, this message translates to:
  /// **'SSH'**
  String get totpSurfaceSsh;

  /// No description provided for @totpCodesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No recovery codes left} =1{1 recovery code left} other{{count} recovery codes left}}'**
  String totpCodesLeft(int count);

  /// No description provided for @totpLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong codes. Codes are refused until {time}.'**
  String totpLocked(String time);

  /// No description provided for @totpSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get totpSetUp;

  /// No description provided for @totpNewCodes.
  ///
  /// In en, this message translates to:
  /// **'New recovery codes'**
  String get totpNewCodes;

  /// No description provided for @totpNewCodesBody.
  ///
  /// In en, this message translates to:
  /// **'Your current recovery codes stop working at once, used or not, and a new set is shown once.'**
  String get totpNewCodesBody;

  /// No description provided for @totpNewCodesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace codes'**
  String get totpNewCodesConfirm;

  /// No description provided for @totpRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove second factor'**
  String get totpRemove;

  /// No description provided for @totpRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Signing in will ask only for your password, and your recovery codes stop working. If your tenant requires a second factor, you will be asked to set one up again.'**
  String get totpRemoveBody;

  /// No description provided for @totpRemoved.
  ///
  /// In en, this message translates to:
  /// **'Second factor removed.'**
  String get totpRemoved;

  /// No description provided for @totpCodesHeading.
  ///
  /// In en, this message translates to:
  /// **'Save these recovery codes now'**
  String get totpCodesHeading;

  /// No description provided for @totpCodesNote.
  ///
  /// In en, this message translates to:
  /// **'Each one signs you in once without your authenticator. They are shown once and cannot be read again; if you lose them, make a new set.'**
  String get totpCodesNote;

  /// No description provided for @totpCodesSaved.
  ///
  /// In en, this message translates to:
  /// **'I have saved them'**
  String get totpCodesSaved;

  /// No description provided for @totpConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get totpConfirm;

  /// No description provided for @totpStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Add this key to your authenticator app, or open it there from this device.'**
  String get totpStep1;

  /// No description provided for @totpSecretHeading.
  ///
  /// In en, this message translates to:
  /// **'Your authenticator key'**
  String get totpSecretHeading;

  /// No description provided for @totpSecretNote.
  ///
  /// In en, this message translates to:
  /// **'Account {account} at {issuer}. Keep it private: anyone holding it can make your codes.'**
  String totpSecretNote(String account, String issuer);

  /// No description provided for @totpOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open in authenticator app'**
  String get totpOpenApp;

  /// No description provided for @totpStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Enter the six-digit code the app shows.'**
  String get totpStep2;

  /// No description provided for @sshKeysTitle.
  ///
  /// In en, this message translates to:
  /// **'SSH keys'**
  String get sshKeysTitle;

  /// No description provided for @sshKeysInfo.
  ///
  /// In en, this message translates to:
  /// **'A key enrolled here signs you in to tix\'s terminal interface over SSH, in this tenant. Revoked keys stay listed so you can tell why one stopped working.'**
  String get sshKeysInfo;

  /// No description provided for @sshKeysEmpty.
  ///
  /// In en, this message translates to:
  /// **'No SSH keys yet.'**
  String get sshKeysEmpty;

  /// No description provided for @sshKeyAdd.
  ///
  /// In en, this message translates to:
  /// **'Add SSH key'**
  String get sshKeyAdd;

  /// No description provided for @sshKeyAddSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add key'**
  String get sshKeyAddSubmit;

  /// No description provided for @sshKeyAdded.
  ///
  /// In en, this message translates to:
  /// **'SSH key added.'**
  String get sshKeyAdded;

  /// No description provided for @sshKeyUnlabelled.
  ///
  /// In en, this message translates to:
  /// **'Unlabelled key'**
  String get sshKeyUnlabelled;

  /// No description provided for @sshKeyRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get sshKeyRevoked;

  /// No description provided for @sshKeyAddedOn.
  ///
  /// In en, this message translates to:
  /// **'Added {date}'**
  String sshKeyAddedOn(String date);

  /// No description provided for @sshKeyLastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last used {date}'**
  String sshKeyLastUsed(String date);

  /// No description provided for @sshKeyNeverUsed.
  ///
  /// In en, this message translates to:
  /// **'Never used'**
  String get sshKeyNeverUsed;

  /// No description provided for @sshKeyRevokedOn.
  ///
  /// In en, this message translates to:
  /// **'Revoked {date}'**
  String sshKeyRevokedOn(String date);

  /// No description provided for @sshKeyRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get sshKeyRevoke;

  /// No description provided for @sshKeyRevokeBody.
  ///
  /// In en, this message translates to:
  /// **'{name} stops signing in over SSH at once. This cannot be undone; enrol the key again to use it.'**
  String sshKeyRevokeBody(String name);

  /// No description provided for @sshKeyRevokedToast.
  ///
  /// In en, this message translates to:
  /// **'SSH key revoked.'**
  String get sshKeyRevokedToast;

  /// No description provided for @sessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get sessionsTitle;

  /// No description provided for @sessionsInfo.
  ///
  /// In en, this message translates to:
  /// **'Your browser and terminal sign-ins to this tenant that have not expired. Revoke any you do not recognise. API tokens are managed under Tokens.'**
  String get sessionsInfo;

  /// No description provided for @sessionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active sessions.'**
  String get sessionsEmpty;

  /// No description provided for @sessionsNotReadable.
  ///
  /// In en, this message translates to:
  /// **'This token cannot list your sessions: it needs the account:read scope, which \"*\" does not include. Sign in with your password, or use a token minted with account:read.'**
  String get sessionsNotReadable;

  /// No description provided for @sessionsShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get sessionsShowMore;

  /// No description provided for @sessionCurrent.
  ///
  /// In en, this message translates to:
  /// **'This session'**
  String get sessionCurrent;

  /// No description provided for @sessionUnknownAgent.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get sessionUnknownAgent;

  /// No description provided for @sessionMethodPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get sessionMethodPassword;

  /// No description provided for @sessionMethodSshKey.
  ///
  /// In en, this message translates to:
  /// **'SSH key'**
  String get sessionMethodSshKey;

  /// No description provided for @sessionMethodSwitch.
  ///
  /// In en, this message translates to:
  /// **'Tenant switch'**
  String get sessionMethodSwitch;

  /// No description provided for @sessionSecondFactor.
  ///
  /// In en, this message translates to:
  /// **'with second factor'**
  String get sessionSecondFactor;

  /// No description provided for @sessionSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in {when}'**
  String sessionSignedIn(String when);

  /// No description provided for @sessionExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires {when}'**
  String sessionExpires(String when);

  /// No description provided for @sessionRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get sessionRevoke;

  /// No description provided for @sessionRevokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke this session?'**
  String get sessionRevokeTitle;

  /// No description provided for @sessionRevokeBody.
  ///
  /// In en, this message translates to:
  /// **'{agent} is signed out at once and has to sign in again.'**
  String sessionRevokeBody(String agent);

  /// No description provided for @sessionRevokeCurrentBody.
  ///
  /// In en, this message translates to:
  /// **'This is the session this app is signed in with. Revoking it signs you out here, and you will have to sign in again.'**
  String get sessionRevokeCurrentBody;

  /// No description provided for @sessionRevoked.
  ///
  /// In en, this message translates to:
  /// **'Session revoked.'**
  String get sessionRevoked;

  /// No description provided for @sshKeyPublicKey.
  ///
  /// In en, this message translates to:
  /// **'Public key'**
  String get sshKeyPublicKey;

  /// No description provided for @sshKeyPublicKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'The line from your .pub file, as ssh-keygen writes it.'**
  String get sshKeyPublicKeyHelp;

  /// No description provided for @sshKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get sshKeyLabel;

  /// No description provided for @sshKeyLabelHelp.
  ///
  /// In en, this message translates to:
  /// **'Tells this key from your others, such as the machine it lives on.'**
  String get sshKeyLabelHelp;

  /// No description provided for @sshKeyAllTenants.
  ///
  /// In en, this message translates to:
  /// **'Every tenant I belong to'**
  String get sshKeyAllTenants;

  /// No description provided for @sshKeyAllTenantsHelp.
  ///
  /// In en, this message translates to:
  /// **'Enrols the key in each of your tenants, not only this one.'**
  String get sshKeyAllTenantsHelp;

  /// No description provided for @tenantSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tenant settings'**
  String get tenantSettingsTitle;

  /// No description provided for @tenantSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get tenantSaved;

  /// No description provided for @tenantGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get tenantGeneralTitle;

  /// No description provided for @tenantName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tenantName;

  /// No description provided for @tenantKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get tenantKey;

  /// No description provided for @tenantKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'Short and unique: letters, digits, hyphens and underscores, starting with a letter. It cannot change later.'**
  String get tenantKeyHelp;

  /// No description provided for @tenantTimezone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get tenantTimezone;

  /// No description provided for @tenantTimezoneHelp.
  ///
  /// In en, this message translates to:
  /// **'An IANA zone people read dates in unless they chose their own. Empty uses the server\'s.'**
  String get tenantTimezoneHelp;

  /// No description provided for @tenantTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get tenantTimeFormat;

  /// No description provided for @tenantServerDefault.
  ///
  /// In en, this message translates to:
  /// **'Server default'**
  String get tenantServerDefault;

  /// No description provided for @tenantThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get tenantThemeTitle;

  /// No description provided for @tenantThemeInfo.
  ///
  /// In en, this message translates to:
  /// **'The colour the tenant shows on every surface: the web, the terminal and this app. Status and priority colours never change with it.'**
  String get tenantThemeInfo;

  /// No description provided for @tenantThemeDefault.
  ///
  /// In en, this message translates to:
  /// **'default'**
  String get tenantThemeDefault;

  /// No description provided for @tenantThemeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom colour'**
  String get tenantThemeCustom;

  /// No description provided for @tenantThemeCustomHelp.
  ///
  /// In en, this message translates to:
  /// **'#rrggbb. tix adjusts it until text on it and around it stays readable.'**
  String get tenantThemeCustomHelp;

  /// No description provided for @tenantThemeCustomBad.
  ///
  /// In en, this message translates to:
  /// **'Write the colour as #rrggbb, such as #0f766e.'**
  String get tenantThemeCustomBad;

  /// No description provided for @tenantThemePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get tenantThemePreview;

  /// No description provided for @tenantThemeSampleRow.
  ///
  /// In en, this message translates to:
  /// **'A selected row'**
  String get tenantThemeSampleRow;

  /// No description provided for @tenantThemeSampleLink.
  ///
  /// In en, this message translates to:
  /// **'A link'**
  String get tenantThemeSampleLink;

  /// No description provided for @tenantThemeSampleButton.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get tenantThemeSampleButton;

  /// No description provided for @tenantThemeSaved.
  ///
  /// In en, this message translates to:
  /// **'Theme saved.'**
  String get tenantThemeSaved;

  /// No description provided for @tenantTotpTitle.
  ///
  /// In en, this message translates to:
  /// **'Second factor'**
  String get tenantTotpTitle;

  /// No description provided for @tenantTotpInfo.
  ///
  /// In en, this message translates to:
  /// **'Require a code from an authenticator app when people sign in. Someone without one is taken through setting it up at sign-in, so turning this on cannot lock anyone out.'**
  String get tenantTotpInfo;

  /// No description provided for @tenantTotpWeb.
  ///
  /// In en, this message translates to:
  /// **'Require it in the browser'**
  String get tenantTotpWeb;

  /// No description provided for @tenantTotpCli.
  ///
  /// In en, this message translates to:
  /// **'Require it on the command line'**
  String get tenantTotpCli;

  /// No description provided for @tenantTotpSsh.
  ///
  /// In en, this message translates to:
  /// **'Require it over SSH, on top of the key'**
  String get tenantTotpSsh;

  /// No description provided for @tenantTotpNone.
  ///
  /// In en, this message translates to:
  /// **'Not required'**
  String get tenantTotpNone;

  /// No description provided for @tenantTotpBadge.
  ///
  /// In en, this message translates to:
  /// **'Second factor'**
  String get tenantTotpBadge;

  /// No description provided for @tenantLeaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Claims'**
  String get tenantLeaseTitle;

  /// No description provided for @tenantLeaseInfo.
  ///
  /// In en, this message translates to:
  /// **'How long an agent\'s claim on a task lasts. A project, workflow or claim can ask for less; the server\'s ceiling always wins.'**
  String get tenantLeaseInfo;

  /// No description provided for @tenantLeaseDefault.
  ///
  /// In en, this message translates to:
  /// **'Default lease'**
  String get tenantLeaseDefault;

  /// No description provided for @tenantLeaseDefaultHelp.
  ///
  /// In en, this message translates to:
  /// **'A duration such as 30m or 2h. Empty uses the server\'s.'**
  String get tenantLeaseDefaultHelp;

  /// No description provided for @tenantLeaseMax.
  ///
  /// In en, this message translates to:
  /// **'Longest lease'**
  String get tenantLeaseMax;

  /// No description provided for @tenantLeaseMaxHelp.
  ///
  /// In en, this message translates to:
  /// **'Caps every claim in this tenant. It can lower the server\'s ceiling, never raise it.'**
  String get tenantLeaseMaxHelp;

  /// No description provided for @tenantTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get tenantTrashTitle;

  /// No description provided for @tenantTrashKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep deleted tasks in a trash'**
  String get tenantTrashKeep;

  /// No description provided for @tenantTrashOnBody.
  ///
  /// In en, this message translates to:
  /// **'Deleted tasks can be restored until housekeeping empties the trash.'**
  String get tenantTrashOnBody;

  /// No description provided for @tenantTrashOffBody.
  ///
  /// In en, this message translates to:
  /// **'Deleting a task is permanent. Tasks already in the trash stay there.'**
  String get tenantTrashOffBody;

  /// No description provided for @tenantTrashOnShort.
  ///
  /// In en, this message translates to:
  /// **'Deleted tasks go to the trash'**
  String get tenantTrashOnShort;

  /// No description provided for @tenantTrashOffShort.
  ///
  /// In en, this message translates to:
  /// **'Deleting is permanent'**
  String get tenantTrashOffShort;

  /// No description provided for @tenantDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete tenant'**
  String get tenantDelete;

  /// No description provided for @tenantDeleteHelp.
  ///
  /// In en, this message translates to:
  /// **'Its data stops being reachable and its domains stop resolving.'**
  String get tenantDeleteHelp;

  /// No description provided for @tenantDeleteCurrent.
  ///
  /// In en, this message translates to:
  /// **'This is the tenant you are working in. Switch to another one to delete it.'**
  String get tenantDeleteCurrent;

  /// No description provided for @tenantDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{name} ({key}) and everything in it stop being reachable, for everyone, and its domains stop resolving. Only the server\'s operator can bring it back.'**
  String tenantDeleteBody(String name, String key);

  /// No description provided for @tenantDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}.'**
  String tenantDeleted(String name);

  /// No description provided for @tenantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tenants'**
  String get tenantsTitle;

  /// No description provided for @tenantsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every tenant on this server'**
  String get tenantsSubtitle;

  /// No description provided for @tenantsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tenants.'**
  String get tenantsEmpty;

  /// No description provided for @tenantsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create one with its first admin.'**
  String get tenantsEmptyBody;

  /// No description provided for @tenantsPick.
  ///
  /// In en, this message translates to:
  /// **'Pick a tenant to see it here.'**
  String get tenantsPick;

  /// No description provided for @tenantCreate.
  ///
  /// In en, this message translates to:
  /// **'New tenant'**
  String get tenantCreate;

  /// No description provided for @tenantCreateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create tenant'**
  String get tenantCreateSubmit;

  /// No description provided for @tenantCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {name}.'**
  String tenantCreated(String name);

  /// No description provided for @tenantFirstAdmin.
  ///
  /// In en, this message translates to:
  /// **'First admin'**
  String get tenantFirstAdmin;

  /// No description provided for @tenantFirstAdminHelp.
  ///
  /// In en, this message translates to:
  /// **'Becomes an admin of the new tenant. An address that already has an account keeps its password and second factor.'**
  String get tenantFirstAdminHelp;

  /// No description provided for @tenantPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'At least 12 characters. Leave it empty and tix generates one, shown once.'**
  String get tenantPasswordHelp;

  /// No description provided for @tenantCredentialsHeading.
  ///
  /// In en, this message translates to:
  /// **'Copy these passwords now'**
  String get tenantCredentialsHeading;

  /// No description provided for @tenantCredentialsNote.
  ///
  /// In en, this message translates to:
  /// **'tix generated them and shows them once; nothing stores them. Hand each to its admin, who chooses a new one at first sign-in. If one is lost, set a new password.'**
  String get tenantCredentialsNote;

  /// No description provided for @tenantCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get tenantCurrent;

  /// No description provided for @tenantMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get tenantMember;

  /// No description provided for @tenantNoTrash.
  ///
  /// In en, this message translates to:
  /// **'No trash'**
  String get tenantNoTrash;

  /// No description provided for @tenantOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tenantOverview;

  /// No description provided for @tenantCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get tenantCreatedAt;

  /// No description provided for @tenantSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch to this tenant'**
  String get tenantSwitch;

  /// No description provided for @tenantJoinSwitch.
  ///
  /// In en, this message translates to:
  /// **'Join and switch'**
  String get tenantJoinSwitch;

  /// No description provided for @tenantJoinBody.
  ///
  /// In en, this message translates to:
  /// **'You are not a member of {name}. As a global admin you can add yourself as an admin and switch to it. The change is in your account log.'**
  String tenantJoinBody(String name);

  /// No description provided for @tenantJoinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Join as admin'**
  String get tenantJoinConfirm;

  /// No description provided for @tenantSwitchPinned.
  ///
  /// In en, this message translates to:
  /// **'This connection reaches one tenant only. Sign in with a switchable connection to move between tenants.'**
  String get tenantSwitchPinned;

  /// No description provided for @tenantUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get tenantUsersTitle;

  /// No description provided for @tenantDomainsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No domains map to this tenant.'**
  String get tenantDomainsEmpty;

  /// No description provided for @domainsTitle.
  ///
  /// In en, this message translates to:
  /// **'Domains'**
  String get domainsTitle;

  /// No description provided for @domainsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hostnames that open this tenant'**
  String get domainsSubtitle;

  /// No description provided for @domainsBody.
  ///
  /// In en, this message translates to:
  /// **'A request that arrives on one of these hostnames reaches this tenant without naming it.'**
  String get domainsBody;

  /// No description provided for @domainsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No domains yet.'**
  String get domainsEmpty;

  /// No description provided for @domainsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Map a hostname so people reach this tenant at its own address.'**
  String get domainsEmptyBody;

  /// No description provided for @domainAdd.
  ///
  /// In en, this message translates to:
  /// **'Add domain'**
  String get domainAdd;

  /// No description provided for @domainAddSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add domain'**
  String get domainAddSubmit;

  /// No description provided for @domainAdded.
  ///
  /// In en, this message translates to:
  /// **'Domain added.'**
  String get domainAdded;

  /// No description provided for @domainHostname.
  ///
  /// In en, this message translates to:
  /// **'Hostname'**
  String get domainHostname;

  /// No description provided for @domainHostnameHelp.
  ///
  /// In en, this message translates to:
  /// **'Lowercased; any port or trailing dot is dropped.'**
  String get domainHostnameHelp;

  /// No description provided for @domainCertMode.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get domainCertMode;

  /// No description provided for @domainCertNone.
  ///
  /// In en, this message translates to:
  /// **'Terminated elsewhere'**
  String get domainCertNone;

  /// No description provided for @domainCertFile.
  ///
  /// In en, this message translates to:
  /// **'Certificate file'**
  String get domainCertFile;

  /// No description provided for @domainCertNoneHelp.
  ///
  /// In en, this message translates to:
  /// **'A proxy in front of tix holds the certificate, or the host is plain HTTP.'**
  String get domainCertNoneHelp;

  /// No description provided for @domainCertFileHelp.
  ///
  /// In en, this message translates to:
  /// **'tix serves TLS itself from PEM files on the server.'**
  String get domainCertFileHelp;

  /// No description provided for @domainCertPath.
  ///
  /// In en, this message translates to:
  /// **'Certificate path on the server'**
  String get domainCertPath;

  /// No description provided for @domainKeyPath.
  ///
  /// In en, this message translates to:
  /// **'Private key path on the server'**
  String get domainKeyPath;

  /// No description provided for @domainVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get domainVerified;

  /// No description provided for @domainShared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get domainShared;

  /// No description provided for @domainSharedInfo.
  ///
  /// In en, this message translates to:
  /// **'A shared hostname also serves the tenant a credential or the X-Tix-Tenant header names, as a host no domain claims does. Only a global admin sets it.'**
  String get domainSharedInfo;

  /// No description provided for @domainRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove domain'**
  String get domainRemove;

  /// No description provided for @domainRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Requests to {hostname} stop reaching this tenant. People who use that address have to use another one.'**
  String domainRemoveBody(String hostname);

  /// No description provided for @domainRemoved.
  ///
  /// In en, this message translates to:
  /// **'Domain removed.'**
  String get domainRemoved;

  /// No description provided for @serverTitle.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverTitle;

  /// No description provided for @serverVersion.
  ///
  /// In en, this message translates to:
  /// **'tix {version}'**
  String serverVersion(String version);

  /// No description provided for @serverStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get serverStatusTitle;

  /// No description provided for @serverVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get serverVersionLabel;

  /// No description provided for @serverHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get serverHealth;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get serverAddress;

  /// No description provided for @serverId.
  ///
  /// In en, this message translates to:
  /// **'Server process'**
  String get serverId;

  /// No description provided for @serverCountTenant.
  ///
  /// In en, this message translates to:
  /// **'Live connections in this tenant'**
  String get serverCountTenant;

  /// No description provided for @serverCountEvents.
  ///
  /// In en, this message translates to:
  /// **'Live update streams'**
  String get serverCountEvents;

  /// No description provided for @serverCountSsh.
  ///
  /// In en, this message translates to:
  /// **'SSH sessions'**
  String get serverCountSsh;

  /// No description provided for @serverCountProcess.
  ///
  /// In en, this message translates to:
  /// **'Connections on this server'**
  String get serverCountProcess;

  /// No description provided for @serverCountProcessInfo.
  ///
  /// In en, this message translates to:
  /// **'Every connection this server process holds, across all tenants. It is capacity, not a directory, so it names nobody.'**
  String get serverCountProcessInfo;

  /// No description provided for @connectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Live connections'**
  String get connectionsTitle;

  /// No description provided for @connectionsInfo.
  ///
  /// In en, this message translates to:
  /// **'The live update streams and SSH sessions of this tenant that this server process holds. Ending one closes it; the client may connect again.'**
  String get connectionsInfo;

  /// No description provided for @connectionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No live connections.'**
  String get connectionsEmpty;

  /// No description provided for @connectionEvents.
  ///
  /// In en, this message translates to:
  /// **'Live updates'**
  String get connectionEvents;

  /// No description provided for @connectionSsh.
  ///
  /// In en, this message translates to:
  /// **'SSH'**
  String get connectionSsh;

  /// No description provided for @connectionSince.
  ///
  /// In en, this message translates to:
  /// **'since {date}'**
  String connectionSince(String date);

  /// No description provided for @connectionEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get connectionEnd;

  /// No description provided for @connectionEndBody.
  ///
  /// In en, this message translates to:
  /// **'The connection closes at once. A client that is still running may connect again; revoke its token or key to keep it out.'**
  String get connectionEndBody;

  /// No description provided for @connectionEnded.
  ///
  /// In en, this message translates to:
  /// **'Connection ended.'**
  String get connectionEnded;

  /// No description provided for @globalAdminsTitle.
  ///
  /// In en, this message translates to:
  /// **'Global admins'**
  String get globalAdminsTitle;

  /// No description provided for @globalAdminsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'People who administer every tenant on this server'**
  String get globalAdminsSubtitle;

  /// No description provided for @globalAdminsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No global admins.'**
  String get globalAdminsEmpty;

  /// No description provided for @globalAdminGrant.
  ///
  /// In en, this message translates to:
  /// **'Grant global admin'**
  String get globalAdminGrant;

  /// No description provided for @globalAdminGrantSubmit.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get globalAdminGrantSubmit;

  /// No description provided for @globalAdminGrantHelp.
  ///
  /// In en, this message translates to:
  /// **'The account with this email can then create tenants and administer every one of them.'**
  String get globalAdminGrantHelp;

  /// No description provided for @globalAdminGranted.
  ///
  /// In en, this message translates to:
  /// **'Global admin granted.'**
  String get globalAdminGranted;

  /// No description provided for @globalAdminRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get globalAdminRevoke;

  /// No description provided for @globalAdminRevokeBody.
  ///
  /// In en, this message translates to:
  /// **'{email} stops administering every tenant at once. Their memberships stay as they are.'**
  String globalAdminRevokeBody(String email);

  /// No description provided for @globalAdminRevoked.
  ///
  /// In en, this message translates to:
  /// **'Global admin revoked.'**
  String get globalAdminRevoked;

  /// No description provided for @globalAdminBadge.
  ///
  /// In en, this message translates to:
  /// **'Global admin'**
  String get globalAdminBadge;

  /// No description provided for @adminRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRoleAdmin;

  /// No description provided for @adminRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get adminRoleMember;

  /// No description provided for @adminRoleViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get adminRoleViewer;

  /// No description provided for @adminRoleNone.
  ///
  /// In en, this message translates to:
  /// **'No role'**
  String get adminRoleNone;

  /// No description provided for @adminUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No users in this tenant.'**
  String get adminUsersEmpty;

  /// No description provided for @adminUsersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a user, or add an account that already exists.'**
  String get adminUsersEmptyBody;

  /// No description provided for @adminUserCreate.
  ///
  /// In en, this message translates to:
  /// **'New user'**
  String get adminUserCreate;

  /// No description provided for @adminUserCreateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create user'**
  String get adminUserCreateSubmit;

  /// No description provided for @adminUserActions.
  ///
  /// In en, this message translates to:
  /// **'User actions'**
  String get adminUserActions;

  /// No description provided for @adminUserEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminUserEdit;

  /// No description provided for @adminUserEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {email}'**
  String adminUserEditTitle(String email);

  /// No description provided for @adminUserDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete user'**
  String get adminUserDelete;

  /// No description provided for @adminUserDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{email} loses this tenant: their membership is revoked and their sessions and tokens here end. Their account stays for other tenants.'**
  String adminUserDeleteBody(String email);

  /// No description provided for @adminUserClearTotp.
  ///
  /// In en, this message translates to:
  /// **'Clear second factor'**
  String get adminUserClearTotp;

  /// No description provided for @adminUserClearTotpConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear it'**
  String get adminUserClearTotpConfirm;

  /// No description provided for @adminUserClearTotpBody.
  ///
  /// In en, this message translates to:
  /// **'{email} signs in with their password alone until they set up a second factor again. Do this only when they have lost their authenticator and their recovery codes.'**
  String adminUserClearTotpBody(String email);

  /// No description provided for @adminUserEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminUserEmail;

  /// No description provided for @adminUserHandle.
  ///
  /// In en, this message translates to:
  /// **'Handle'**
  String get adminUserHandle;

  /// No description provided for @adminUserHandleHelp.
  ///
  /// In en, this message translates to:
  /// **'Their short name in this tenant. Empty uses the part of the email before the @.'**
  String get adminUserHandleHelp;

  /// No description provided for @adminUserDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get adminUserDisplayName;

  /// No description provided for @adminUserPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminUserPassword;

  /// No description provided for @adminUserPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'At least 12 characters. Leave it empty for a user who signs in another way or is invited later.'**
  String get adminUserPasswordHelp;

  /// No description provided for @adminUserNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get adminUserNewPassword;

  /// No description provided for @adminUserNewPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave it empty to keep the current one.'**
  String get adminUserNewPasswordHelp;

  /// No description provided for @adminUserRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminUserRole;

  /// No description provided for @adminUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get adminUserDisabled;

  /// No description provided for @adminUserDisabledSwitch.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get adminUserDisabledSwitch;

  /// No description provided for @adminUserDisabledHelp.
  ///
  /// In en, this message translates to:
  /// **'A disabled user cannot sign in; their sessions and tokens end at once.'**
  String get adminUserDisabledHelp;

  /// No description provided for @adminUserMustChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Must change password'**
  String get adminUserMustChangePassword;

  /// No description provided for @adminUserMustChangeSwitch.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password at next sign-in'**
  String get adminUserMustChangeSwitch;

  /// No description provided for @adminUserTotp.
  ///
  /// In en, this message translates to:
  /// **'Second factor'**
  String get adminUserTotp;

  /// No description provided for @adminMemberAdd.
  ///
  /// In en, this message translates to:
  /// **'Add existing account'**
  String get adminMemberAdd;

  /// No description provided for @adminMemberAddSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add to tenant'**
  String get adminMemberAddSubmit;

  /// No description provided for @adminMemberAddHelp.
  ///
  /// In en, this message translates to:
  /// **'The person keeps their password and second factor and is not asked to accept.'**
  String get adminMemberAddHelp;

  /// No description provided for @adminAccountLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Account log'**
  String get adminAccountLogTitle;

  /// No description provided for @adminAccountLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged for this account.'**
  String get adminAccountLogEmpty;

  /// No description provided for @adminAccountLogEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Changes to its password, second factor, standing and memberships show here.'**
  String get adminAccountLogEmptyBody;

  /// No description provided for @adminAccountLogBy.
  ///
  /// In en, this message translates to:
  /// **'by {who}'**
  String adminAccountLogBy(String who);

  /// No description provided for @adminAccountLogVia.
  ///
  /// In en, this message translates to:
  /// **'via {channel}'**
  String adminAccountLogVia(String channel);

  /// No description provided for @adminAccountLogSystem.
  ///
  /// In en, this message translates to:
  /// **'the system'**
  String get adminAccountLogSystem;

  /// No description provided for @taskReclaim.
  ///
  /// In en, this message translates to:
  /// **'Force-release claim'**
  String get taskReclaim;

  /// No description provided for @taskReclaimSubmit.
  ///
  /// In en, this message translates to:
  /// **'Release claim'**
  String get taskReclaimSubmit;

  /// No description provided for @taskReclaimBody.
  ///
  /// In en, this message translates to:
  /// **'Ends the lease another actor holds on this task, for when its worker died. That worker\'s next renewal is refused.'**
  String get taskReclaimBody;

  /// No description provided for @taskReclaimReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get taskReclaimReason;

  /// No description provided for @taskReclaimReasonHelp.
  ///
  /// In en, this message translates to:
  /// **'Kept in the task\'s history.'**
  String get taskReclaimReasonHelp;

  /// No description provided for @taskReclaimed.
  ///
  /// In en, this message translates to:
  /// **'Released the claim on {ref}.'**
  String taskReclaimed(String ref);

  /// No description provided for @totpWrongCode.
  ///
  /// In en, this message translates to:
  /// **'That code is not right. Check the time on this device and try the next one.'**
  String get totpWrongCode;

  /// No description provided for @tenantThemeSampleStatus.
  ///
  /// In en, this message translates to:
  /// **'Doing'**
  String get tenantThemeSampleStatus;

  /// No description provided for @tenantSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, theme, second factor, claims and trash'**
  String get tenantSettingsSubtitle;

  /// No description provided for @serverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version and live connections'**
  String get serverSubtitle;

  /// No description provided for @webhooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Webhooks'**
  String get webhooksTitle;

  /// No description provided for @webhooksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'tix posts each event to these addresses, signed with the endpoint\'s secret.'**
  String get webhooksSubtitle;

  /// No description provided for @webhookNew.
  ///
  /// In en, this message translates to:
  /// **'New endpoint'**
  String get webhookNew;

  /// No description provided for @webhookEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit endpoint'**
  String get webhookEdit;

  /// No description provided for @webhookEndpoints.
  ///
  /// In en, this message translates to:
  /// **'Endpoints'**
  String get webhookEndpoints;

  /// No description provided for @webhookEndpointsInfo.
  ///
  /// In en, this message translates to:
  /// **'An endpoint receives every event, or only the types it names. An inactive one receives nothing until it is turned back on.'**
  String get webhookEndpointsInfo;

  /// No description provided for @webhooksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No webhook endpoints yet.'**
  String get webhooksEmpty;

  /// No description provided for @webhooksEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add an https address and tix will post events to it as they happen.'**
  String get webhooksEmptyBody;

  /// No description provided for @webhookEveryEvent.
  ///
  /// In en, this message translates to:
  /// **'Every event'**
  String get webhookEveryEvent;

  /// No description provided for @webhookActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get webhookActive;

  /// No description provided for @webhookInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get webhookInactive;

  /// No description provided for @webhookActiveHelp.
  ///
  /// In en, this message translates to:
  /// **'An inactive endpoint receives nothing.'**
  String get webhookActiveHelp;

  /// No description provided for @webhookShowDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Show its deliveries'**
  String get webhookShowDeliveries;

  /// No description provided for @webhookDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete endpoint'**
  String get webhookDelete;

  /// No description provided for @webhookDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this endpoint?'**
  String get webhookDeleteTitle;

  /// No description provided for @webhookDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{url} stops receiving events, and its pending deliveries are dropped. This cannot be undone.'**
  String webhookDeleteBody(String url);

  /// No description provided for @webhookDeleted.
  ///
  /// In en, this message translates to:
  /// **'Endpoint deleted.'**
  String get webhookDeleted;

  /// No description provided for @webhookUrl.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get webhookUrl;

  /// No description provided for @webhookUrlHelp.
  ///
  /// In en, this message translates to:
  /// **'Must use https, unless it is a loopback address.'**
  String get webhookUrlHelp;

  /// No description provided for @webhookEvents.
  ///
  /// In en, this message translates to:
  /// **'Event types'**
  String get webhookEvents;

  /// No description provided for @webhookEventsHelp.
  ///
  /// In en, this message translates to:
  /// **'Separated by commas; a type may end in *. Empty sends every event.'**
  String get webhookEventsHelp;

  /// No description provided for @webhookSecret.
  ///
  /// In en, this message translates to:
  /// **'Signing secret'**
  String get webhookSecret;

  /// No description provided for @webhookSecretNewHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave it empty and tix generates one, shown here once.'**
  String get webhookSecretNewHelp;

  /// No description provided for @webhookSecretKeepHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave it empty to keep the current secret.'**
  String get webhookSecretKeepHelp;

  /// No description provided for @webhookSave.
  ///
  /// In en, this message translates to:
  /// **'Save endpoint'**
  String get webhookSave;

  /// No description provided for @webhookSaved.
  ///
  /// In en, this message translates to:
  /// **'Endpoint saved.'**
  String get webhookSaved;

  /// No description provided for @webhookSecretHeading.
  ///
  /// In en, this message translates to:
  /// **'Copy this signing secret now'**
  String get webhookSecretHeading;

  /// No description provided for @webhookSecretNote.
  ///
  /// In en, this message translates to:
  /// **'It is shown once and cannot be read back. Configure it on the receiving end; if you lose it, save the endpoint again with a secret of your own.'**
  String get webhookSecretNote;

  /// No description provided for @webhookSecretDone.
  ///
  /// In en, this message translates to:
  /// **'I have copied it'**
  String get webhookSecretDone;

  /// No description provided for @webhookDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get webhookDeliveries;

  /// No description provided for @webhookDeliveriesAll.
  ///
  /// In en, this message translates to:
  /// **'Every endpoint, newest first.'**
  String get webhookDeliveriesAll;

  /// No description provided for @webhookDeliveriesFor.
  ///
  /// In en, this message translates to:
  /// **'For {url}, newest first.'**
  String webhookDeliveriesFor(String url);

  /// No description provided for @webhookDeliveriesShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show every endpoint'**
  String get webhookDeliveriesShowAll;

  /// No description provided for @webhookDeliveriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No deliveries.'**
  String get webhookDeliveriesEmpty;

  /// No description provided for @webhookDeliveriesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Deliveries appear here as events are sent.'**
  String get webhookDeliveriesEmptyBody;

  /// No description provided for @webhookStatusAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get webhookStatusAny;

  /// No description provided for @webhookStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get webhookStatusPending;

  /// No description provided for @webhookStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get webhookStatusDelivered;

  /// No description provided for @webhookStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get webhookStatusFailed;

  /// No description provided for @webhookStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get webhookStatusUnknown;

  /// No description provided for @webhookEvent.
  ///
  /// In en, this message translates to:
  /// **'Event {seq}'**
  String webhookEvent(int seq);

  /// No description provided for @webhookAttempts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt} other{{count} attempts}}'**
  String webhookAttempts(int count);

  /// No description provided for @webhookHttpStatus.
  ///
  /// In en, this message translates to:
  /// **'HTTP {code}'**
  String webhookHttpStatus(int code);

  /// No description provided for @webhookNextAttempt.
  ///
  /// In en, this message translates to:
  /// **'next attempt {when}'**
  String webhookNextAttempt(String when);

  /// No description provided for @webhookRedeliver.
  ///
  /// In en, this message translates to:
  /// **'Redeliver'**
  String get webhookRedeliver;

  /// No description provided for @webhookRedelivered.
  ///
  /// In en, this message translates to:
  /// **'Queued for another attempt.'**
  String get webhookRedelivered;

  /// No description provided for @webhookPing.
  ///
  /// In en, this message translates to:
  /// **'Send test'**
  String get webhookPing;

  /// No description provided for @webhookPingTitle.
  ///
  /// In en, this message translates to:
  /// **'Test event'**
  String get webhookPingTitle;

  /// No description provided for @webhookPingSent.
  ///
  /// In en, this message translates to:
  /// **'tix sent a signed webhook.ping event to {url}.'**
  String webhookPingSent(String url);

  /// No description provided for @webhookPingPending.
  ///
  /// In en, this message translates to:
  /// **'Not attempted yet. The delivery log shows the result once tix tries it.'**
  String get webhookPingPending;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'External sync'**
  String get syncTitle;

  /// No description provided for @syncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import work from Jira, OpenProject or a file. Runs happen on the server.'**
  String get syncSubtitle;

  /// No description provided for @syncNew.
  ///
  /// In en, this message translates to:
  /// **'New source'**
  String get syncNew;

  /// No description provided for @syncSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get syncSources;

  /// No description provided for @syncSourcesInfo.
  ///
  /// In en, this message translates to:
  /// **'Each source keeps a cursor, so a run imports only what changed since the last one. A full run starts again from the beginning.'**
  String get syncSourcesInfo;

  /// No description provided for @syncEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sync sources yet.'**
  String get syncEmpty;

  /// No description provided for @syncEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a source to import tasks from another tracker.'**
  String get syncEmptyBody;

  /// No description provided for @syncStatusOk.
  ///
  /// In en, this message translates to:
  /// **'Last run ok'**
  String get syncStatusOk;

  /// No description provided for @syncStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Last run failed'**
  String get syncStatusFailed;

  /// No description provided for @syncStatusRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get syncStatusRunning;

  /// No description provided for @syncStatusNever.
  ///
  /// In en, this message translates to:
  /// **'Never run'**
  String get syncStatusNever;

  /// No description provided for @syncNeverRun.
  ///
  /// In en, this message translates to:
  /// **'Not run yet.'**
  String get syncNeverRun;

  /// No description provided for @syncLastRun.
  ///
  /// In en, this message translates to:
  /// **'Last run {when}.'**
  String syncLastRun(String when);

  /// No description provided for @syncStoredCredentials.
  ///
  /// In en, this message translates to:
  /// **'Stored credentials: {names}'**
  String syncStoredCredentials(String names);

  /// No description provided for @syncMissing.
  ///
  /// In en, this message translates to:
  /// **'A run is refused until the server has:'**
  String get syncMissing;

  /// No description provided for @syncReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to run.'**
  String get syncReady;

  /// No description provided for @syncRunNow.
  ///
  /// In en, this message translates to:
  /// **'Run now'**
  String get syncRunNow;

  /// No description provided for @syncPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get syncPreview;

  /// No description provided for @syncEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get syncEdit;

  /// No description provided for @syncDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete source'**
  String get syncDelete;

  /// No description provided for @syncDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this source?'**
  String get syncDeleteTitle;

  /// No description provided for @syncDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{name} and how far it had read are removed. Tasks it already imported stay. This cannot be undone.'**
  String syncDeleteBody(String name);

  /// No description provided for @syncDeleted.
  ///
  /// In en, this message translates to:
  /// **'Source deleted.'**
  String get syncDeleted;

  /// No description provided for @syncSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {name}.'**
  String syncSaved(String name);

  /// No description provided for @syncRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Run {name}'**
  String syncRunTitle(String name);

  /// No description provided for @syncRunBody.
  ///
  /// In en, this message translates to:
  /// **'Preview counts what a run would do and changes nothing.'**
  String get syncRunBody;

  /// No description provided for @syncFull.
  ///
  /// In en, this message translates to:
  /// **'Full run'**
  String get syncFull;

  /// No description provided for @syncFullHelp.
  ///
  /// In en, this message translates to:
  /// **'Read everything again from the beginning instead of from where the last run stopped.'**
  String get syncFullHelp;

  /// No description provided for @syncPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get syncPreviewTitle;

  /// No description provided for @syncDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Run finished'**
  String get syncDoneTitle;

  /// No description provided for @syncPreviewNote.
  ///
  /// In en, this message translates to:
  /// **'Nothing was changed.'**
  String get syncPreviewNote;

  /// No description provided for @syncCounts.
  ///
  /// In en, this message translates to:
  /// **'{created} created · {updated} updated · {skipped} skipped · {deleted} deleted'**
  String syncCounts(int created, int updated, int skipped, int deleted);

  /// No description provided for @syncUnmatched.
  ///
  /// In en, this message translates to:
  /// **'People with no match here'**
  String get syncUnmatched;

  /// No description provided for @syncWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get syncWarnings;

  /// No description provided for @syncWarningCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 warning} other{{count} warnings}}'**
  String syncWarningCount(int count);

  /// No description provided for @syncRuns.
  ///
  /// In en, this message translates to:
  /// **'Run history'**
  String get syncRuns;

  /// No description provided for @syncRunsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No finished runs.'**
  String get syncRunsEmpty;

  /// No description provided for @syncRunsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'A run that fails is not listed here; the source shows it.'**
  String get syncRunsEmptyBody;

  /// No description provided for @syncEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String syncEditTitle(String name);

  /// No description provided for @syncFormIntro.
  ///
  /// In en, this message translates to:
  /// **'Settings and the mapping are stored on the server. Credentials are sealed there and never shown again.'**
  String get syncFormIntro;

  /// No description provided for @syncName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get syncName;

  /// No description provided for @syncNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Names the source within its system.'**
  String get syncNameHelp;

  /// No description provided for @syncMapping.
  ///
  /// In en, this message translates to:
  /// **'Mapping document (YAML)'**
  String get syncMapping;

  /// No description provided for @syncMappingHelp.
  ///
  /// In en, this message translates to:
  /// **'Left empty, the stored document is kept.'**
  String get syncMappingHelp;

  /// No description provided for @syncMappingPath.
  ///
  /// In en, this message translates to:
  /// **'Mapping file on the server'**
  String get syncMappingPath;

  /// No description provided for @syncMappingPathHelp.
  ///
  /// In en, this message translates to:
  /// **'Only read from this tenant\'s directory under the server\'s sync.file_root.'**
  String get syncMappingPathHelp;

  /// No description provided for @syncCredentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get syncCredentials;

  /// No description provided for @syncCredentialsHelp.
  ///
  /// In en, this message translates to:
  /// **'Write only. Any of them replaces the stored set; leave all empty to keep it.'**
  String get syncCredentialsHelp;

  /// No description provided for @syncToken.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get syncToken;

  /// No description provided for @syncUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get syncUser;

  /// No description provided for @syncPassword.
  ///
  /// In en, this message translates to:
  /// **'Password or API key'**
  String get syncPassword;

  /// No description provided for @syncClearCredentials.
  ///
  /// In en, this message translates to:
  /// **'Remove the stored credentials'**
  String get syncClearCredentials;

  /// No description provided for @syncCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get syncCheck;

  /// No description provided for @syncSave.
  ///
  /// In en, this message translates to:
  /// **'Save source'**
  String get syncSave;

  /// No description provided for @syncMappingFrom.
  ///
  /// In en, this message translates to:
  /// **'Mapping: {origin}'**
  String syncMappingFrom(String origin);

  /// No description provided for @syncCredentialsFrom.
  ///
  /// In en, this message translates to:
  /// **'Credentials: {origin}'**
  String syncCredentialsFrom(String origin);

  /// No description provided for @syncFromStored.
  ///
  /// In en, this message translates to:
  /// **'stored on the source'**
  String get syncFromStored;

  /// No description provided for @syncFromEnv.
  ///
  /// In en, this message translates to:
  /// **'from the environment'**
  String get syncFromEnv;

  /// No description provided for @syncFromMappingPath.
  ///
  /// In en, this message translates to:
  /// **'file on the server'**
  String get syncFromMappingPath;

  /// No description provided for @syncFromNone.
  ///
  /// In en, this message translates to:
  /// **'not needed'**
  String get syncFromNone;

  /// No description provided for @syncFromMissing.
  ///
  /// In en, this message translates to:
  /// **'missing'**
  String get syncFromMissing;

  /// No description provided for @syncSummaryProject.
  ///
  /// In en, this message translates to:
  /// **'Lands in project {project}'**
  String syncSummaryProject(String project);

  /// No description provided for @syncSummaryIdentity.
  ///
  /// In en, this message translates to:
  /// **'Matched by {field}'**
  String syncSummaryIdentity(String field);

  /// No description provided for @retentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Retention'**
  String get retentionTitle;

  /// No description provided for @retentionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How long this tenant keeps its logs.'**
  String get retentionSubtitle;

  /// No description provided for @retentionWindows.
  ///
  /// In en, this message translates to:
  /// **'Keep for'**
  String get retentionWindows;

  /// No description provided for @retentionWindowsHelp.
  ///
  /// In en, this message translates to:
  /// **'In days. Older records are removed when the log is pruned.'**
  String get retentionWindowsHelp;

  /// No description provided for @retentionEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get retentionEvents;

  /// No description provided for @retentionEventsHelp.
  ///
  /// In en, this message translates to:
  /// **'The live update stream. Default 30 days.'**
  String get retentionEventsHelp;

  /// No description provided for @retentionAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit entries'**
  String get retentionAudit;

  /// No description provided for @retentionAuditHelp.
  ///
  /// In en, this message translates to:
  /// **'Who changed what. Default 365 days.'**
  String get retentionAuditHelp;

  /// No description provided for @retentionDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Webhook deliveries'**
  String get retentionDeliveries;

  /// No description provided for @retentionDeliveriesHelp.
  ///
  /// In en, this message translates to:
  /// **'The delivery log. Default 30 days.'**
  String get retentionDeliveriesHelp;

  /// No description provided for @retentionSave.
  ///
  /// In en, this message translates to:
  /// **'Save retention'**
  String get retentionSave;

  /// No description provided for @retentionSaved.
  ///
  /// In en, this message translates to:
  /// **'Retention saved.'**
  String get retentionSaved;

  /// No description provided for @retentionPruneSection.
  ///
  /// In en, this message translates to:
  /// **'Prune now'**
  String get retentionPruneSection;

  /// No description provided for @retentionPruneHelp.
  ///
  /// In en, this message translates to:
  /// **'Removes everything past its window at once, instead of waiting for the server to do it.'**
  String get retentionPruneHelp;

  /// No description provided for @retentionPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get retentionPreview;

  /// No description provided for @retentionPrune.
  ///
  /// In en, this message translates to:
  /// **'Prune'**
  String get retentionPrune;

  /// No description provided for @retentionPruneTitle.
  ///
  /// In en, this message translates to:
  /// **'Prune old records?'**
  String get retentionPruneTitle;

  /// No description provided for @retentionPruneBody.
  ///
  /// In en, this message translates to:
  /// **'Events, audit entries and webhook deliveries past their window are deleted for good.'**
  String get retentionPruneBody;

  /// No description provided for @retentionPruned.
  ///
  /// In en, this message translates to:
  /// **'Pruned.'**
  String get retentionPruned;

  /// No description provided for @retentionWouldPrune.
  ///
  /// In en, this message translates to:
  /// **'Would remove {events} events, {audit} audit entries and {deliveries} deliveries.'**
  String retentionWouldPrune(int events, int audit, int deliveries);

  /// No description provided for @retentionDidPrune.
  ///
  /// In en, this message translates to:
  /// **'Removed {events} events, {audit} audit entries and {deliveries} deliveries.'**
  String retentionDidPrune(int events, int audit, int deliveries);

  /// No description provided for @retentionKeptForSubscribers.
  ///
  /// In en, this message translates to:
  /// **'{count} events past their window are kept until a subscriber has read them.'**
  String retentionKeptForSubscribers(int count);

  /// No description provided for @housekeepingTitle.
  ///
  /// In en, this message translates to:
  /// **'Housekeeping'**
  String get housekeepingTitle;

  /// No description provided for @housekeepingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clears finished work out of the lists and empties the trash.'**
  String get housekeepingSubtitle;

  /// No description provided for @housekeepingPaused.
  ///
  /// In en, this message translates to:
  /// **'Housekeeping is paused while the trash is off: no rule runs.'**
  String get housekeepingPaused;

  /// No description provided for @housekeepingRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get housekeepingRules;

  /// No description provided for @housekeepingRulesHelp.
  ///
  /// In en, this message translates to:
  /// **'A number of days, or off. Projects can override these.'**
  String get housekeepingRulesHelp;

  /// No description provided for @housekeepingDone.
  ///
  /// In en, this message translates to:
  /// **'Done tasks move to the trash after'**
  String get housekeepingDone;

  /// No description provided for @housekeepingDoneHelp.
  ///
  /// In en, this message translates to:
  /// **'Days since they were done.'**
  String get housekeepingDoneHelp;

  /// No description provided for @housekeepingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled tasks move to the trash after'**
  String get housekeepingCancelled;

  /// No description provided for @housekeepingCancelledHelp.
  ///
  /// In en, this message translates to:
  /// **'Days since they were cancelled.'**
  String get housekeepingCancelledHelp;

  /// No description provided for @housekeepingTrash.
  ///
  /// In en, this message translates to:
  /// **'The trash deletes tasks for good after'**
  String get housekeepingTrash;

  /// No description provided for @housekeepingTrashHelp.
  ///
  /// In en, this message translates to:
  /// **'Days in the trash.'**
  String get housekeepingTrashHelp;

  /// No description provided for @housekeepingPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing due now.} =1{1 task due now.} other{{count} tasks due now.}}'**
  String housekeepingPending(int count);

  /// No description provided for @housekeepingSave.
  ///
  /// In en, this message translates to:
  /// **'Save rules'**
  String get housekeepingSave;

  /// No description provided for @housekeepingSaved.
  ///
  /// In en, this message translates to:
  /// **'Rules saved.'**
  String get housekeepingSaved;

  /// No description provided for @housekeepingRunSection.
  ///
  /// In en, this message translates to:
  /// **'Run now'**
  String get housekeepingRunSection;

  /// No description provided for @housekeepingRunHelp.
  ///
  /// In en, this message translates to:
  /// **'Applies the rules once, in batches, instead of waiting for the server\'s next pass.'**
  String get housekeepingRunHelp;

  /// No description provided for @housekeepingPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get housekeepingPreview;

  /// No description provided for @housekeepingRun.
  ///
  /// In en, this message translates to:
  /// **'Run housekeeping'**
  String get housekeepingRun;

  /// No description provided for @housekeepingRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Run housekeeping now?'**
  String get housekeepingRunTitle;

  /// No description provided for @housekeepingRunBody.
  ///
  /// In en, this message translates to:
  /// **'Finished tasks past their rule move to the trash, and tasks past the trash rule are deleted for good.'**
  String get housekeepingRunBody;

  /// No description provided for @housekeepingWould.
  ///
  /// In en, this message translates to:
  /// **'Would move {done} done and {cancelled} cancelled tasks to the trash, and delete {trash} for good.'**
  String housekeepingWould(int done, int cancelled, int trash);

  /// No description provided for @housekeepingDid.
  ///
  /// In en, this message translates to:
  /// **'Moved {done} done and {cancelled} cancelled tasks to the trash, and deleted {trash} for good.'**
  String housekeepingDid(int done, int cancelled, int trash);

  /// No description provided for @trashTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trashTitle;

  /// No description provided for @trashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deleted tasks, until housekeeping empties them.'**
  String get trashSubtitle;

  /// No description provided for @trashExplain.
  ///
  /// In en, this message translates to:
  /// **'Restore puts a task back where it was. Delete for good removes it and its trashed subtasks permanently, as the housekeeping trash rule does when it expires them.'**
  String get trashExplain;

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'The trash is empty.'**
  String get trashEmpty;

  /// No description provided for @trashEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Deleted tasks wait here and can be restored.'**
  String get trashEmptyBody;

  /// No description provided for @trashRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get trashRestore;

  /// No description provided for @trashRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored {ref}.'**
  String trashRestored(String ref);

  /// No description provided for @trashDeletedAt.
  ///
  /// In en, this message translates to:
  /// **'deleted {when}'**
  String trashDeletedAt(String when);

  /// No description provided for @trashPurge.
  ///
  /// In en, this message translates to:
  /// **'Delete for good'**
  String get trashPurge;

  /// No description provided for @trashPurgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete for good?'**
  String get trashPurgeTitle;

  /// No description provided for @trashPurgeBody.
  ///
  /// In en, this message translates to:
  /// **'{ref} “{title}” and its trashed subtasks are deleted permanently. This cannot be undone.'**
  String trashPurgeBody(String ref, String title);

  /// No description provided for @trashPurged.
  ///
  /// In en, this message translates to:
  /// **'Deleted {ref} for good.'**
  String trashPurged(String ref);

  /// No description provided for @auditTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get auditTitle;

  /// No description provided for @auditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every change in this tenant, newest first.'**
  String get auditSubtitle;

  /// No description provided for @auditSearch.
  ///
  /// In en, this message translates to:
  /// **'Search actions, records and values'**
  String get auditSearch;

  /// No description provided for @auditVia.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get auditVia;

  /// No description provided for @auditSource.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get auditSource;

  /// No description provided for @auditMoreFilters.
  ///
  /// In en, this message translates to:
  /// **'More filters'**
  String get auditMoreFilters;

  /// No description provided for @auditMoreFiltersCount.
  ///
  /// In en, this message translates to:
  /// **'More filters ({count})'**
  String auditMoreFiltersCount(int count);

  /// No description provided for @auditClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get auditClear;

  /// No description provided for @auditFilters.
  ///
  /// In en, this message translates to:
  /// **'Filter the audit log'**
  String get auditFilters;

  /// No description provided for @auditApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get auditApply;

  /// No description provided for @auditActor.
  ///
  /// In en, this message translates to:
  /// **'Actor'**
  String get auditActor;

  /// No description provided for @auditActorHelp.
  ///
  /// In en, this message translates to:
  /// **'The actor\'s id.'**
  String get auditActorHelp;

  /// No description provided for @auditAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get auditAction;

  /// No description provided for @auditToken.
  ///
  /// In en, this message translates to:
  /// **'API token'**
  String get auditToken;

  /// No description provided for @auditTokenHelp.
  ///
  /// In en, this message translates to:
  /// **'The token\'s name.'**
  String get auditTokenHelp;

  /// No description provided for @auditSince.
  ///
  /// In en, this message translates to:
  /// **'From {day}'**
  String auditSince(String day);

  /// No description provided for @auditUntil.
  ///
  /// In en, this message translates to:
  /// **'To {day}'**
  String auditUntil(String day);

  /// No description provided for @auditAnyTime.
  ///
  /// In en, this message translates to:
  /// **'any time'**
  String get auditAnyTime;

  /// No description provided for @auditEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet.'**
  String get auditEmpty;

  /// No description provided for @auditEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Changes appear here as people and agents make them.'**
  String get auditEmptyBody;

  /// No description provided for @auditNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No entries match.'**
  String get auditNoMatch;

  /// No description provided for @auditNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Loosen or clear the filters.'**
  String get auditNoMatchBody;

  /// No description provided for @auditPick.
  ///
  /// In en, this message translates to:
  /// **'Pick an entry'**
  String get auditPick;

  /// No description provided for @auditPickBody.
  ///
  /// In en, this message translates to:
  /// **'Its detail shows here.'**
  String get auditPickBody;

  /// No description provided for @auditSeq.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get auditSeq;

  /// No description provided for @auditWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get auditWhen;

  /// No description provided for @auditSystem.
  ///
  /// In en, this message translates to:
  /// **'the system'**
  String get auditSystem;

  /// No description provided for @auditSubject.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get auditSubject;

  /// No description provided for @auditTokenId.
  ///
  /// In en, this message translates to:
  /// **'Token id'**
  String get auditTokenId;

  /// No description provided for @auditSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get auditSession;

  /// No description provided for @auditKey.
  ///
  /// In en, this message translates to:
  /// **'SSH key'**
  String get auditKey;

  /// No description provided for @auditClient.
  ///
  /// In en, this message translates to:
  /// **'Client address'**
  String get auditClient;

  /// No description provided for @auditOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get auditOrigin;

  /// No description provided for @auditHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get auditHost;

  /// No description provided for @auditOsUser.
  ///
  /// In en, this message translates to:
  /// **'System user'**
  String get auditOsUser;

  /// No description provided for @auditJob.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get auditJob;

  /// No description provided for @auditUserAgent.
  ///
  /// In en, this message translates to:
  /// **'User agent'**
  String get auditUserAgent;

  /// No description provided for @auditBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get auditBefore;

  /// No description provided for @auditAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get auditAfter;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// No description provided for @timeInAMoment.
  ///
  /// In en, this message translates to:
  /// **'in a moment'**
  String get timeInAMoment;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 minute ago} other{{n} minutes ago}}'**
  String timeAgoMinutes(int n);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 hour ago} other{{n} hours ago}}'**
  String timeAgoHours(int n);

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day ago} other{{n} days ago}}'**
  String timeAgoDays(int n);

  /// No description provided for @timeAgoMonths.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 month ago} other{{n} months ago}}'**
  String timeAgoMonths(int n);

  /// No description provided for @timeAgoYears.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 year ago} other{{n} years ago}}'**
  String timeAgoYears(int n);

  /// No description provided for @timeInMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{in 1 minute} other{in {n} minutes}}'**
  String timeInMinutes(int n);

  /// No description provided for @timeInHours.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{in 1 hour} other{in {n} hours}}'**
  String timeInHours(int n);

  /// No description provided for @timeInDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{in 1 day} other{in {n} days}}'**
  String timeInDays(int n);

  /// No description provided for @timeInMonths.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{in 1 month} other{in {n} months}}'**
  String timeInMonths(int n);

  /// No description provided for @timeInYears.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{in 1 year} other{in {n} years}}'**
  String timeInYears(int n);

  /// No description provided for @timeFormatIso.
  ///
  /// In en, this message translates to:
  /// **'ISO'**
  String get timeFormatIso;

  /// No description provided for @timeFormatRfc3339.
  ///
  /// In en, this message translates to:
  /// **'RFC 3339'**
  String get timeFormatRfc3339;

  /// No description provided for @timeFormatShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get timeFormatShort;

  /// No description provided for @timeFormatLong.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get timeFormatLong;

  /// No description provided for @timeFormatDotted.
  ///
  /// In en, this message translates to:
  /// **'Dotted'**
  String get timeFormatDotted;

  /// No description provided for @timeFormatDayfirst.
  ///
  /// In en, this message translates to:
  /// **'Day first'**
  String get timeFormatDayfirst;

  /// No description provided for @timeFormatUs.
  ///
  /// In en, this message translates to:
  /// **'US'**
  String get timeFormatUs;

  /// No description provided for @timeFormatRelative.
  ///
  /// In en, this message translates to:
  /// **'Relative'**
  String get timeFormatRelative;

  /// No description provided for @settingsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get settingsSearchHint;

  /// No description provided for @settingsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No setting matches “{query}”'**
  String settingsNoMatch(String query);

  /// No description provided for @settingsNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try another word, or clear the search.'**
  String get settingsNoMatchBody;

  /// No description provided for @settingsScopeDevice.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get settingsScopeDevice;

  /// No description provided for @settingsScopeAccount.
  ///
  /// In en, this message translates to:
  /// **'Synced to your account'**
  String get settingsScopeAccount;

  /// No description provided for @settingsScopeTenant.
  ///
  /// In en, this message translates to:
  /// **'Whole tenant'**
  String get settingsScopeTenant;

  /// No description provided for @settingsGroupDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get settingsGroupDevice;

  /// No description provided for @settingsGroupDeviceHelp.
  ///
  /// In en, this message translates to:
  /// **'Kept on this device only. Your other devices and the web keep their own.'**
  String get settingsGroupDeviceHelp;

  /// No description provided for @settingsGroupAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account on {tenant}'**
  String settingsGroupAccount(String tenant);

  /// No description provided for @settingsGroupAccountHelp.
  ///
  /// In en, this message translates to:
  /// **'Kept by the server with your account, so they follow you to every device, the web and the command line.'**
  String get settingsGroupAccountHelp;

  /// No description provided for @settingsGroupTenant.
  ///
  /// In en, this message translates to:
  /// **'This tenant'**
  String get settingsGroupTenant;

  /// No description provided for @settingsGroupTenantHelp.
  ///
  /// In en, this message translates to:
  /// **'Settings for everyone in {tenant}. Only administrators see these.'**
  String settingsGroupTenantHelp(String tenant);

  /// No description provided for @settingsReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceMotionHelp.
  ///
  /// In en, this message translates to:
  /// **'Keeps the app still even when the system allows animation.'**
  String get settingsReduceMotionHelp;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Touch feedback'**
  String get settingsHaptics;

  /// No description provided for @settingsHapticsHelp.
  ///
  /// In en, this message translates to:
  /// **'A short buzz on swipes, completed tasks and refusals.'**
  String get settingsHapticsHelp;

  /// No description provided for @settingsLanguageHelp.
  ///
  /// In en, this message translates to:
  /// **'tix keeps no language with your account, so each device and browser picks its own.'**
  String get settingsLanguageHelp;

  /// No description provided for @settingsStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start screen'**
  String get settingsStartTitle;

  /// No description provided for @settingsStartHelp.
  ///
  /// In en, this message translates to:
  /// **'Where the app opens when it starts or after you sign in.'**
  String get settingsStartHelp;

  /// No description provided for @settingsDeviceNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications on this device'**
  String get settingsDeviceNotifTitle;

  /// No description provided for @settingsDeviceNotifSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Whether this device alerts you, and for which kinds'**
  String get settingsDeviceNotifSubtitle;

  /// No description provided for @settingsProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileTitle;

  /// No description provided for @settingsDatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Dates and times'**
  String get settingsDatesTitle;

  /// No description provided for @settingsDatesHelp.
  ///
  /// In en, this message translates to:
  /// **'Kept with your account, so every device, browser and terminal shows dates this way. Inherit follows your tenant’s default, which follows the server\'s.'**
  String get settingsDatesHelp;

  /// No description provided for @settingsDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get settingsDateFormat;

  /// No description provided for @settingsDateFormatHelp.
  ///
  /// In en, this message translates to:
  /// **'How every timestamp in the app is written. tix reads dates you type the same way on the web.'**
  String get settingsDateFormatHelp;

  /// No description provided for @settingsTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get settingsTimeZone;

  /// No description provided for @settingsTimeZoneHelp.
  ///
  /// In en, this message translates to:
  /// **'The zone every time in the app is shown in, and where today ends for due dates.'**
  String get settingsTimeZoneHelp;

  /// No description provided for @settingsInherit.
  ///
  /// In en, this message translates to:
  /// **'Inherit'**
  String get settingsInherit;

  /// No description provided for @settingsInheritValue.
  ///
  /// In en, this message translates to:
  /// **'Inherit: {value}'**
  String settingsInheritValue(String value);

  /// No description provided for @settingsInUse.
  ///
  /// In en, this message translates to:
  /// **'In use: {value}, from {source}'**
  String settingsInUse(String value, String source);

  /// No description provided for @settingsSourceUser.
  ///
  /// In en, this message translates to:
  /// **'your choice'**
  String get settingsSourceUser;

  /// No description provided for @settingsSourceTenant.
  ///
  /// In en, this message translates to:
  /// **'the tenant default'**
  String get settingsSourceTenant;

  /// No description provided for @settingsSourceGlobal.
  ///
  /// In en, this message translates to:
  /// **'the server default'**
  String get settingsSourceGlobal;

  /// No description provided for @settingsDeviceFormat.
  ///
  /// In en, this message translates to:
  /// **'this device’s format'**
  String get settingsDeviceFormat;

  /// No description provided for @settingsDeviceZone.
  ///
  /// In en, this message translates to:
  /// **'this device’s zone ({zone})'**
  String settingsDeviceZone(String zone);

  /// No description provided for @settingsDatesNotPersonal.
  ///
  /// In en, this message translates to:
  /// **'This credential is not a person, so it reads your tenant’s defaults and cannot keep its own.'**
  String get settingsDatesNotPersonal;

  /// No description provided for @settingsDatesLoading.
  ///
  /// In en, this message translates to:
  /// **'Reading your date settings from the server…'**
  String get settingsDatesLoading;

  /// No description provided for @settingsDatesUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This version of tix keeps no date preferences, so dates follow this device. A newer tix server adds them.'**
  String get settingsDatesUnsupported;

  /// No description provided for @settingsDatesFailed.
  ///
  /// In en, this message translates to:
  /// **'The server did not answer, so dates follow this device for now.'**
  String get settingsDatesFailed;

  /// No description provided for @settingsDatesSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved with your account'**
  String get settingsDatesSaved;

  /// No description provided for @settingsZoneSearch.
  ///
  /// In en, this message translates to:
  /// **'Search time zones'**
  String get settingsZoneSearch;

  /// No description provided for @settingsZoneNone.
  ///
  /// In en, this message translates to:
  /// **'No time zone matches.'**
  String get settingsZoneNone;

  /// No description provided for @settingsInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox and channels'**
  String get settingsInboxTitle;

  /// No description provided for @settingsInboxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Which kinds reach your inbox, and your personal channels'**
  String get settingsInboxSubtitle;

  /// No description provided for @settingsFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved filters'**
  String get settingsFiltersTitle;

  /// No description provided for @settingsFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rename, share or delete the filters you keep'**
  String get settingsFiltersSubtitle;

  /// No description provided for @settingsArrangementTitle.
  ///
  /// In en, this message translates to:
  /// **'Board and lanes'**
  String get settingsArrangementTitle;

  /// No description provided for @settingsArrangementHelp.
  ///
  /// In en, this message translates to:
  /// **'The groups you hid, starred, collapsed or moved on the board, in lanes and on My work.'**
  String get settingsArrangementHelp;

  /// No description provided for @settingsArrangementReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsArrangementReset;

  /// No description provided for @settingsArrangementResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset board and lanes'**
  String get settingsArrangementResetTitle;

  /// No description provided for @settingsArrangementResetBody.
  ///
  /// In en, this message translates to:
  /// **'Every group on the board, in lanes and on My work goes back where tix puts it, on every device and on the web. This cannot be undone.'**
  String get settingsArrangementResetBody;

  /// No description provided for @settingsArrangementDone.
  ///
  /// In en, this message translates to:
  /// **'Arrangement reset'**
  String get settingsArrangementDone;

  /// No description provided for @settingsTenantManage.
  ///
  /// In en, this message translates to:
  /// **'Manage {tenant}'**
  String settingsTenantManage(String tenant);

  /// No description provided for @settingsTenantManageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Projects, workflows, fields, people and the tenant’s own settings'**
  String get settingsTenantManageSubtitle;

  /// No description provided for @paletteSettingsItem.
  ///
  /// In en, this message translates to:
  /// **'Settings: {name}'**
  String paletteSettingsItem(String name);

  /// No description provided for @savedFiltersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved filters'**
  String get savedFiltersEmpty;

  /// No description provided for @savedFiltersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Save a filter from the task list and it shows here, on every device.'**
  String get savedFiltersEmptyBody;

  /// No description provided for @savedFilterSharedBadge.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get savedFilterSharedBadge;

  /// No description provided for @savedFilterTheirs.
  ///
  /// In en, this message translates to:
  /// **'Shared with you; only its owner and administrators can change it.'**
  String get savedFilterTheirs;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'{n} d'**
  String durationDays(int n);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{n} h'**
  String durationHours(int n);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String durationMinutes(int n);

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{n} s'**
  String durationSeconds(int n);

  /// No description provided for @errorBadInviteLink.
  ///
  /// In en, this message translates to:
  /// **'That is not an invite link. It looks like https://your-server/invite/tix_inv_…'**
  String get errorBadInviteLink;

  /// No description provided for @methodInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get methodInvite;

  /// No description provided for @inviteLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite link'**
  String get inviteLinkLabel;

  /// No description provided for @inviteLinkHint.
  ///
  /// In en, this message translates to:
  /// **'https://tix.example.com/invite/tix_inv_…'**
  String get inviteLinkHint;

  /// No description provided for @inviteLinkHelp.
  ///
  /// In en, this message translates to:
  /// **'Paste the link from your invite email, or share it to tix from another app. The server is added for you.'**
  String get inviteLinkHelp;

  /// No description provided for @invitePaste.
  ///
  /// In en, this message translates to:
  /// **'Paste the invite link'**
  String get invitePaste;

  /// No description provided for @inviteCheck.
  ///
  /// In en, this message translates to:
  /// **'Check invite'**
  String get inviteCheck;

  /// No description provided for @inviteJoin.
  ///
  /// In en, this message translates to:
  /// **'Join {tenant} on {host}'**
  String inviteJoin(String tenant, String host);

  /// No description provided for @inviteJoinServer.
  ///
  /// In en, this message translates to:
  /// **'Join {host}'**
  String inviteJoinServer(String host);

  /// No description provided for @inviteAs.
  ///
  /// In en, this message translates to:
  /// **'as {email}'**
  String inviteAs(String email);

  /// No description provided for @inviteExpires.
  ///
  /// In en, this message translates to:
  /// **'The link works until {when}.'**
  String inviteExpires(String when);

  /// No description provided for @inviteExistingAccount.
  ///
  /// In en, this message translates to:
  /// **'This address already has a tix account. Enter its password to accept; nothing about the account changes.'**
  String get inviteExistingAccount;

  /// No description provided for @inviteDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get inviteDisplayName;

  /// No description provided for @inviteNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get inviteNewPassword;

  /// No description provided for @inviteNewPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'At least 12 characters. It signs you in everywhere, not only here.'**
  String get inviteNewPasswordHelp;

  /// No description provided for @inviteExistingPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'The password you already sign in to tix with.'**
  String get inviteExistingPasswordHelp;

  /// No description provided for @inviteCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'A code from your authenticator app, which this account already uses.'**
  String get inviteCodeHelp;

  /// No description provided for @inviteAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept invite'**
  String get inviteAccept;

  /// No description provided for @notifHideContent.
  ///
  /// In en, this message translates to:
  /// **'Hide task content in notifications'**
  String get notifHideContent;

  /// No description provided for @notifHideContentHelp.
  ///
  /// In en, this message translates to:
  /// **'Notifications only say “New in your inbox”, for this context.'**
  String get notifHideContentHelp;

  /// No description provided for @notifPrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'New in your inbox'**
  String get notifPrivateTitle;

  /// No description provided for @notifPrivateBody.
  ///
  /// In en, this message translates to:
  /// **'Open tix to read it.'**
  String get notifPrivateBody;

  /// No description provided for @taskDetailLease.
  ///
  /// In en, this message translates to:
  /// **'Claim length'**
  String get taskDetailLease;

  /// No description provided for @taskDetailLeaseInfo.
  ///
  /// In en, this message translates to:
  /// **'How long an agent\'s claim on this task lasts when it asks for no length, and the most any claim may last. The task, project, workflow and tenant can each set it; the nearest one wins.'**
  String get taskDetailLeaseInfo;

  /// No description provided for @taskDetailLeaseValue.
  ///
  /// In en, this message translates to:
  /// **'{length}, from {source}'**
  String taskDetailLeaseValue(String length, String source);

  /// No description provided for @taskDetailLeaseMax.
  ///
  /// In en, this message translates to:
  /// **'At most {length}, from {source}'**
  String taskDetailLeaseMax(String length, String source);

  /// No description provided for @taskDetailLeaseClamped.
  ///
  /// In en, this message translates to:
  /// **'Cut down to the ceiling.'**
  String get taskDetailLeaseClamped;

  /// No description provided for @leaseSourceClaim.
  ///
  /// In en, this message translates to:
  /// **'the claim'**
  String get leaseSourceClaim;

  /// No description provided for @leaseSourceTask.
  ///
  /// In en, this message translates to:
  /// **'the task'**
  String get leaseSourceTask;

  /// No description provided for @leaseSourceProject.
  ///
  /// In en, this message translates to:
  /// **'the project'**
  String get leaseSourceProject;

  /// No description provided for @leaseSourceWorkflow.
  ///
  /// In en, this message translates to:
  /// **'the workflow'**
  String get leaseSourceWorkflow;

  /// No description provided for @leaseSourceTenant.
  ///
  /// In en, this message translates to:
  /// **'the tenant'**
  String get leaseSourceTenant;

  /// No description provided for @leaseSourceDeployment.
  ///
  /// In en, this message translates to:
  /// **'the server'**
  String get leaseSourceDeployment;

  /// No description provided for @leaseSourceBuiltin.
  ///
  /// In en, this message translates to:
  /// **'tix\'s default'**
  String get leaseSourceBuiltin;

  /// No description provided for @statusTitle.
  ///
  /// In en, this message translates to:
  /// **'Server status'**
  String get statusTitle;

  /// No description provided for @statusInstallation.
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get statusInstallation;

  /// No description provided for @statusVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get statusVersion;

  /// No description provided for @statusSchema.
  ///
  /// In en, this message translates to:
  /// **'Schema'**
  String get statusSchema;

  /// No description provided for @statusEngine.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get statusEngine;

  /// No description provided for @statusAnswering.
  ///
  /// In en, this message translates to:
  /// **'Answered by'**
  String get statusAnswering;

  /// No description provided for @statusObserved.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get statusObserved;

  /// No description provided for @statusServers.
  ///
  /// In en, this message translates to:
  /// **'Server processes'**
  String get statusServers;

  /// No description provided for @statusServersInfo.
  ///
  /// In en, this message translates to:
  /// **'Every tix process registered against this database. One that misses three heartbeats is shown as gone quiet.'**
  String get statusServersInfo;

  /// No description provided for @statusNoServers.
  ///
  /// In en, this message translates to:
  /// **'No process has registered. The one answering may run without the registry.'**
  String get statusNoServers;

  /// No description provided for @statusAttached.
  ///
  /// In en, this message translates to:
  /// **'Heartbeating'**
  String get statusAttached;

  /// No description provided for @statusDetached.
  ///
  /// In en, this message translates to:
  /// **'Quiet since {when}'**
  String statusDetached(String when);

  /// No description provided for @statusUptime.
  ///
  /// In en, this message translates to:
  /// **'up {length}'**
  String statusUptime(String length);

  /// No description provided for @statusConnections.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 connection} other{{count} connections}}'**
  String statusConnections(int count);

  /// No description provided for @statusWork.
  ///
  /// In en, this message translates to:
  /// **'This tenant'**
  String get statusWork;

  /// No description provided for @statusProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get statusProjects;

  /// No description provided for @statusTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get statusTasks;

  /// No description provided for @statusClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed now'**
  String get statusClaimed;

  /// No description provided for @statusUnswept.
  ///
  /// In en, this message translates to:
  /// **'Expired claims not yet swept'**
  String get statusUnswept;

  /// No description provided for @statusWebhooksPending.
  ///
  /// In en, this message translates to:
  /// **'Webhook deliveries waiting'**
  String get statusWebhooksPending;

  /// No description provided for @statusWebhooksFailed.
  ///
  /// In en, this message translates to:
  /// **'Webhook deliveries failed'**
  String get statusWebhooksFailed;

  /// No description provided for @statusSecondFactor.
  ///
  /// In en, this message translates to:
  /// **'Second factor'**
  String get statusSecondFactor;

  /// No description provided for @statusKey.
  ///
  /// In en, this message translates to:
  /// **'Sealing key set'**
  String get statusKey;

  /// No description provided for @statusRequireWeb.
  ///
  /// In en, this message translates to:
  /// **'Required in the browser'**
  String get statusRequireWeb;

  /// No description provided for @statusRequireCli.
  ///
  /// In en, this message translates to:
  /// **'Required on the command line and in apps'**
  String get statusRequireCli;

  /// No description provided for @statusRequireSsh.
  ///
  /// In en, this message translates to:
  /// **'Required over SSH'**
  String get statusRequireSsh;

  /// No description provided for @statusAdmins.
  ///
  /// In en, this message translates to:
  /// **'Admins with one'**
  String get statusAdmins;

  /// No description provided for @statusAdminsEnrolled.
  ///
  /// In en, this message translates to:
  /// **'{enrolled} of {total}'**
  String statusAdminsEnrolled(int enrolled, int total);

  /// No description provided for @statusUnrecoverable.
  ///
  /// In en, this message translates to:
  /// **'Some second factors cannot be read: the sealing key is missing. Those people must have theirs cleared and enrol again.'**
  String get statusUnrecoverable;

  /// No description provided for @statusYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get statusYes;

  /// No description provided for @statusNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get statusNo;

  /// No description provided for @bundlesTitle.
  ///
  /// In en, this message translates to:
  /// **'Bundles'**
  String get bundlesTitle;

  /// No description provided for @bundleExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export a bundle'**
  String get bundleExportTitle;

  /// No description provided for @bundleExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reusable setup as one file, for another tenant or server'**
  String get bundleExportSubtitle;

  /// No description provided for @bundleExportInfo.
  ///
  /// In en, this message translates to:
  /// **'A bundle carries workflows, custom field definitions, tags, projects as templates and webhook endpoints, never their tasks. Webhook secrets never travel in one.'**
  String get bundleExportInfo;

  /// No description provided for @bundleKindWorkflow.
  ///
  /// In en, this message translates to:
  /// **'Workflows'**
  String get bundleKindWorkflow;

  /// No description provided for @bundleKindField.
  ///
  /// In en, this message translates to:
  /// **'Custom fields'**
  String get bundleKindField;

  /// No description provided for @bundleKindTag.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get bundleKindTag;

  /// No description provided for @bundleKindProject.
  ///
  /// In en, this message translates to:
  /// **'Project templates'**
  String get bundleKindProject;

  /// No description provided for @bundleKindWebhook.
  ///
  /// In en, this message translates to:
  /// **'Webhooks'**
  String get bundleKindWebhook;

  /// No description provided for @bundleKindsAll.
  ///
  /// In en, this message translates to:
  /// **'Nothing picked: the bundle carries every kind.'**
  String get bundleKindsAll;

  /// No description provided for @bundleKindsSome.
  ///
  /// In en, this message translates to:
  /// **'Only the kinds picked go in.'**
  String get bundleKindsSome;

  /// No description provided for @bundleName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get bundleName;

  /// No description provided for @bundleNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Labels the bundle for whoever receives it. Optional.'**
  String get bundleNameHelp;

  /// No description provided for @bundleExport.
  ///
  /// In en, this message translates to:
  /// **'Export bundle'**
  String get bundleExport;

  /// No description provided for @bundleExported.
  ///
  /// In en, this message translates to:
  /// **'Exported {name}'**
  String bundleExported(String name);

  /// No description provided for @bundleImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import a bundle'**
  String get bundleImportTitle;

  /// No description provided for @bundleImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Previewed first, then applied all at once'**
  String get bundleImportSubtitle;

  /// No description provided for @bundleImportInfo.
  ///
  /// In en, this message translates to:
  /// **'A bundle applies atomically: everything in it lands, or nothing does. The preview writes nothing.'**
  String get bundleImportInfo;

  /// No description provided for @bundlePick.
  ///
  /// In en, this message translates to:
  /// **'Choose a bundle file'**
  String get bundlePick;

  /// No description provided for @bundleCollision.
  ///
  /// In en, this message translates to:
  /// **'When a key is already taken'**
  String get bundleCollision;

  /// No description provided for @bundleCollisionAsk.
  ///
  /// In en, this message translates to:
  /// **'Stop and say'**
  String get bundleCollisionAsk;

  /// No description provided for @bundleCollisionSkip.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get bundleCollisionSkip;

  /// No description provided for @bundleCollisionRename.
  ///
  /// In en, this message translates to:
  /// **'Import under a new key'**
  String get bundleCollisionRename;

  /// No description provided for @bundleCollisionReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace mine'**
  String get bundleCollisionReplace;

  /// No description provided for @bundleProject.
  ///
  /// In en, this message translates to:
  /// **'Project for custom fields'**
  String get bundleProject;

  /// No description provided for @bundleProjectHelp.
  ///
  /// In en, this message translates to:
  /// **'The project key that field definitions land in. Needed only when the bundle carries them.'**
  String get bundleProjectHelp;

  /// No description provided for @bundlePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get bundlePreview;

  /// No description provided for @bundleImport.
  ///
  /// In en, this message translates to:
  /// **'Import bundle'**
  String get bundleImport;

  /// No description provided for @bundleReplaceBody.
  ///
  /// In en, this message translates to:
  /// **'Components with the same key are overwritten with the bundle\'s. This cannot be undone.'**
  String get bundleReplaceBody;

  /// No description provided for @bundleImported.
  ///
  /// In en, this message translates to:
  /// **'Bundle imported.'**
  String get bundleImported;

  /// No description provided for @bundlePlan.
  ///
  /// In en, this message translates to:
  /// **'What the import would do'**
  String get bundlePlan;

  /// No description provided for @bundleDone.
  ///
  /// In en, this message translates to:
  /// **'What the import did'**
  String get bundleDone;

  /// No description provided for @bundleEmpty.
  ///
  /// In en, this message translates to:
  /// **'The bundle carries nothing.'**
  String get bundleEmpty;

  /// No description provided for @bundleActionCreate.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get bundleActionCreate;

  /// No description provided for @bundleActionReplace.
  ///
  /// In en, this message translates to:
  /// **'Replaced'**
  String get bundleActionReplace;

  /// No description provided for @bundleActionRename.
  ///
  /// In en, this message translates to:
  /// **'Renamed'**
  String get bundleActionRename;

  /// No description provided for @bundleActionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get bundleActionSkip;

  /// No description provided for @snapshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Import a snapshot'**
  String get snapshotTitle;

  /// No description provided for @snapshotFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Snapshot file'**
  String get snapshotFileTitle;

  /// No description provided for @snapshotFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A file written by an export of a whole tenant'**
  String get snapshotFileSubtitle;

  /// No description provided for @snapshotInfo.
  ///
  /// In en, this message translates to:
  /// **'A snapshot carries projects, workflows, fields, tasks and comments. Check what it would change with a dry run before importing.'**
  String get snapshotInfo;

  /// No description provided for @snapshotPick.
  ///
  /// In en, this message translates to:
  /// **'Choose a snapshot file'**
  String get snapshotPick;

  /// No description provided for @snapshotMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get snapshotMerge;

  /// No description provided for @snapshotReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get snapshotReplace;

  /// No description provided for @snapshotMergeHelp.
  ///
  /// In en, this message translates to:
  /// **'Adds what is new and updates what changed. Nothing is removed.'**
  String get snapshotMergeHelp;

  /// No description provided for @snapshotReplaceHelp.
  ///
  /// In en, this message translates to:
  /// **'Also removes the tasks and fields of each imported project that the snapshot does not carry.'**
  String get snapshotReplaceHelp;

  /// No description provided for @snapshotDryRun.
  ///
  /// In en, this message translates to:
  /// **'Dry run'**
  String get snapshotDryRun;

  /// No description provided for @snapshotImport.
  ///
  /// In en, this message translates to:
  /// **'Import snapshot'**
  String get snapshotImport;

  /// No description provided for @snapshotMergeBody.
  ///
  /// In en, this message translates to:
  /// **'The snapshot\'s records are added to this tenant and update the ones it already has.'**
  String get snapshotMergeBody;

  /// No description provided for @snapshotReplaceBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks and fields of the imported projects that the snapshot does not carry are deleted. This cannot be undone.'**
  String get snapshotReplaceBody;

  /// No description provided for @snapshotImported.
  ///
  /// In en, this message translates to:
  /// **'Snapshot imported.'**
  String get snapshotImported;

  /// No description provided for @snapshotPlan.
  ///
  /// In en, this message translates to:
  /// **'What the import would do'**
  String get snapshotPlan;

  /// No description provided for @snapshotDone.
  ///
  /// In en, this message translates to:
  /// **'What the import did'**
  String get snapshotDone;

  /// No description provided for @snapshotCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get snapshotCreated;

  /// No description provided for @snapshotUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get snapshotUpdated;

  /// No description provided for @snapshotDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get snapshotDeleted;

  /// No description provided for @snapshotSkipped.
  ///
  /// In en, this message translates to:
  /// **'Left alone'**
  String get snapshotSkipped;

  /// No description provided for @manageInheritedValue.
  ///
  /// In en, this message translates to:
  /// **'Inherited: {value}'**
  String manageInheritedValue(String value);

  /// No description provided for @manageDurationSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved as {value}. Empty inherits.'**
  String manageDurationSaved(String value);

  /// No description provided for @projectsShowArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get projectsShowArchived;

  /// No description provided for @projectStar.
  ///
  /// In en, this message translates to:
  /// **'Star project'**
  String get projectStar;

  /// No description provided for @projectUnstar.
  ///
  /// In en, this message translates to:
  /// **'Remove star'**
  String get projectUnstar;

  /// Toast after starring a project.
  ///
  /// In en, this message translates to:
  /// **'{name} starred'**
  String projectStarred(String name);

  /// Toast after taking the star off a project.
  ///
  /// In en, this message translates to:
  /// **'Star removed from {name}'**
  String projectUnstarred(String name);

  /// No description provided for @projectsStarredHeading.
  ///
  /// In en, this message translates to:
  /// **'Starred'**
  String get projectsStarredHeading;

  /// No description provided for @projectsRestHeading.
  ///
  /// In en, this message translates to:
  /// **'Other projects'**
  String get projectsRestHeading;

  /// No description provided for @syncOpStarProject.
  ///
  /// In en, this message translates to:
  /// **'{key}: star project'**
  String syncOpStarProject(String key);

  /// No description provided for @syncOpUnstarProject.
  ///
  /// In en, this message translates to:
  /// **'{key}: remove project star'**
  String syncOpUnstarProject(String key);

  /// No description provided for @manageBundlesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Workflows, fields, tags and webhooks as one file'**
  String get manageBundlesSubtitle;

  /// No description provided for @manageSnapshotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bring a whole tenant\'s export in'**
  String get manageSnapshotSubtitle;

  /// No description provided for @manageStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version, server processes and the tenant\'s work'**
  String get manageStatusSubtitle;

  /// No description provided for @rotateToken.
  ///
  /// In en, this message translates to:
  /// **'Rotate token'**
  String get rotateToken;

  /// No description provided for @rotateTokenBody.
  ///
  /// In en, this message translates to:
  /// **'{name} gets a new token with the same name, scopes and lifetime, and the app keeps only the new one. Anything else using the old token stops working in a minute.'**
  String rotateTokenBody(String name);

  /// No description provided for @tokenRotated.
  ///
  /// In en, this message translates to:
  /// **'Token rotated. The old one stops in a minute.'**
  String get tokenRotated;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineTitle;

  /// No description provided for @offlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What stays available without a connection'**
  String get offlineSubtitle;

  /// No description provided for @offlineLocal.
  ///
  /// In en, this message translates to:
  /// **'This instance is a database on this device, so it is always available. Offline mode applies to remote instances only.'**
  String get offlineLocal;

  /// No description provided for @offlineAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Available offline'**
  String get offlineAvailableTitle;

  /// No description provided for @offlineAvailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Kept on this device for the active instance and tenant, with each task\'s comments and subtasks.'**
  String get offlineAvailableSubtitle;

  /// No description provided for @offlineStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get offlineStorageTitle;

  /// No description provided for @offlineStorageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved copies of this context, changes waiting to be sent included.'**
  String get offlineStorageSubtitle;

  /// No description provided for @offlineStorageCounting.
  ///
  /// In en, this message translates to:
  /// **'Counting…'**
  String get offlineStorageCounting;

  /// No description provided for @offlineStorageUnknown.
  ///
  /// In en, this message translates to:
  /// **'Size unknown'**
  String get offlineStorageUnknown;

  /// No description provided for @offlineClear.
  ///
  /// In en, this message translates to:
  /// **'Clear saved copies'**
  String get offlineClear;

  /// No description provided for @offlineClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear saved copies?'**
  String get offlineClearTitle;

  /// No description provided for @offlineClearBody.
  ///
  /// In en, this message translates to:
  /// **'Screens load from the server again, and nothing is available offline until the next sync. Changes waiting to be sent are kept.'**
  String get offlineClearBody;

  /// No description provided for @offlineSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get offlineSyncTitle;

  /// No description provided for @offlineSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Runs when this context opens and every 30 minutes. On a phone it waits for Wi-Fi and enough battery; Sync now always runs.'**
  String get offlineSyncSubtitle;

  /// No description provided for @offlineSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get offlineSyncNow;

  /// No description provided for @offlineNeverSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get offlineNeverSynced;

  /// No description provided for @offlineStorageUsed.
  ///
  /// In en, this message translates to:
  /// **'{size} used'**
  String offlineStorageUsed(String size);

  /// No description provided for @offlineLastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String offlineLastSynced(String time);

  /// No description provided for @offlineSavedCopy.
  ///
  /// In en, this message translates to:
  /// **'Offline, showing saved copy from {time}'**
  String offlineSavedCopy(String time);

  /// No description provided for @errorSecretStorage.
  ///
  /// In en, this message translates to:
  /// **'This device’s secure storage is locked or refused the write, so nothing was changed. Unlock it and try again.'**
  String get errorSecretStorage;

  /// No description provided for @tokenUnsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Token rotated but not saved'**
  String get tokenUnsavedTitle;

  /// No description provided for @tokenUnsavedHeading.
  ///
  /// In en, this message translates to:
  /// **'Copy this token now'**
  String get tokenUnsavedHeading;

  /// No description provided for @tokenUnsavedNote.
  ///
  /// In en, this message translates to:
  /// **'Secure storage on this device refused the new token. It is shown only this once, and the old token stops working in a minute. The app uses the new one until it closes; after that, reconnect with it.'**
  String get tokenUnsavedNote;

  /// No description provided for @tokenUnsavedDone.
  ///
  /// In en, this message translates to:
  /// **'I have copied it'**
  String get tokenUnsavedDone;

  /// No description provided for @syncMarkUnsynced.
  ///
  /// In en, this message translates to:
  /// **'Unsynced'**
  String get syncMarkUnsynced;

  /// No description provided for @syncMarkDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get syncMarkDraft;

  /// No description provided for @syncMarkCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get syncMarkCheck;

  /// No description provided for @syncMarkConflict.
  ///
  /// In en, this message translates to:
  /// **'Conflict'**
  String get syncMarkConflict;

  /// No description provided for @syncMarkFailed.
  ///
  /// In en, this message translates to:
  /// **'Refused'**
  String get syncMarkFailed;

  /// No description provided for @syncConflictsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conflicts'**
  String get syncConflictsTitle;

  /// No description provided for @syncConflictsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Changes made offline and how they synced'**
  String get syncConflictsSubtitle;

  /// No description provided for @syncSendNow.
  ///
  /// In en, this message translates to:
  /// **'Send now'**
  String get syncSendNow;

  /// No description provided for @syncEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything is synced'**
  String get syncEmptyTitle;

  /// No description provided for @syncConflictsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Changes you make while offline wait here until the server is back.'**
  String get syncConflictsEmptyBody;

  /// No description provided for @syncConflicts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 conflict} other{{count} conflicts}}'**
  String syncConflicts(int count);

  /// No description provided for @syncConflictsHelp.
  ///
  /// In en, this message translates to:
  /// **'Someone changed the same thing on the server while you were offline.'**
  String get syncConflictsHelp;

  /// No description provided for @syncKeepAllMine.
  ///
  /// In en, this message translates to:
  /// **'Keep all mine'**
  String get syncKeepAllMine;

  /// No description provided for @syncKeepAllTheirs.
  ///
  /// In en, this message translates to:
  /// **'Keep all theirs'**
  String get syncKeepAllTheirs;

  /// No description provided for @syncWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change waiting} other{{count} changes waiting}}'**
  String syncWaiting(int count);

  /// No description provided for @syncHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get syncHistory;

  /// No description provided for @syncHistoryHelp.
  ///
  /// In en, this message translates to:
  /// **'Settled conflicts. Reverse one to send the side that was not kept.'**
  String get syncHistoryHelp;

  /// No description provided for @syncFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get syncFieldTitle;

  /// No description provided for @syncFieldBody.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get syncFieldBody;

  /// No description provided for @syncFieldPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get syncFieldPriority;

  /// No description provided for @syncFieldAssignee.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get syncFieldAssignee;

  /// No description provided for @syncFieldDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get syncFieldDue;

  /// No description provided for @syncFieldTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get syncFieldTags;

  /// No description provided for @syncFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get syncFieldStatus;

  /// No description provided for @syncFieldRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get syncFieldRecurrence;

  /// No description provided for @syncFieldParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get syncFieldParent;

  /// No description provided for @syncValueEmpty.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get syncValueEmpty;

  /// No description provided for @syncMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get syncMine;

  /// No description provided for @syncTheirs.
  ///
  /// In en, this message translates to:
  /// **'Theirs'**
  String get syncTheirs;

  /// No description provided for @syncKeepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get syncKeepMine;

  /// No description provided for @syncKeepTheirs.
  ///
  /// In en, this message translates to:
  /// **'Keep theirs'**
  String get syncKeepTheirs;

  /// No description provided for @syncEditChange.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get syncEditChange;

  /// No description provided for @syncEditChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit before sending'**
  String get syncEditChangeTitle;

  /// No description provided for @syncEditSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get syncEditSend;

  /// No description provided for @syncTheirsWas.
  ///
  /// In en, this message translates to:
  /// **'On the server: {value}'**
  String syncTheirsWas(String value);

  /// No description provided for @syncDeletedBody.
  ///
  /// In en, this message translates to:
  /// **'This task was deleted on the server after you changed it.'**
  String get syncDeletedBody;

  /// No description provided for @syncRestoreApply.
  ///
  /// In en, this message translates to:
  /// **'Restore and apply'**
  String get syncRestoreApply;

  /// No description provided for @syncDiscardMine.
  ///
  /// In en, this message translates to:
  /// **'Discard mine'**
  String get syncDiscardMine;

  /// No description provided for @syncDiscardMineTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get syncDiscardMineTitle;

  /// No description provided for @syncDiscardMineBody.
  ///
  /// In en, this message translates to:
  /// **'Everything you changed on this task while offline is dropped. The task stays deleted.'**
  String get syncDiscardMineBody;

  /// No description provided for @syncMoveRefused.
  ///
  /// In en, this message translates to:
  /// **'Moving to {status} was refused: {reason}'**
  String syncMoveRefused(String status, String reason);

  /// No description provided for @syncMoveElsewhere.
  ///
  /// In en, this message translates to:
  /// **'Move elsewhere'**
  String get syncMoveElsewhere;

  /// No description provided for @syncOpUpdate.
  ///
  /// In en, this message translates to:
  /// **'{ref}: {fields}'**
  String syncOpUpdate(String ref, String fields);

  /// No description provided for @syncOpCheck.
  ///
  /// In en, this message translates to:
  /// **'{ref}: checklist item'**
  String syncOpCheck(String ref);

  /// No description provided for @syncOpMove.
  ///
  /// In en, this message translates to:
  /// **'{ref}: move to {status}'**
  String syncOpMove(String ref, String status);

  /// No description provided for @syncOpStar.
  ///
  /// In en, this message translates to:
  /// **'{ref}: star'**
  String syncOpStar(String ref);

  /// No description provided for @syncOpUnstar.
  ///
  /// In en, this message translates to:
  /// **'{ref}: remove star'**
  String syncOpUnstar(String ref);

  /// No description provided for @syncOpSnooze.
  ///
  /// In en, this message translates to:
  /// **'{ref}: snooze'**
  String syncOpSnooze(String ref);

  /// No description provided for @syncOpCreate.
  ///
  /// In en, this message translates to:
  /// **'New task: {title}'**
  String syncOpCreate(String title);

  /// No description provided for @syncOpComment.
  ///
  /// In en, this message translates to:
  /// **'{ref}: comment'**
  String syncOpComment(String ref);

  /// No description provided for @syncOpTagAdd.
  ///
  /// In en, this message translates to:
  /// **'{ref}: add #{tag}'**
  String syncOpTagAdd(String ref, String tag);

  /// No description provided for @syncOpTagRemove.
  ///
  /// In en, this message translates to:
  /// **'{ref}: remove #{tag}'**
  String syncOpTagRemove(String ref, String tag);

  /// No description provided for @syncOpDependency.
  ///
  /// In en, this message translates to:
  /// **'{ref}: waits for {other}'**
  String syncOpDependency(String ref, String other);

  /// No description provided for @syncOpArtifact.
  ///
  /// In en, this message translates to:
  /// **'{ref}: attachment'**
  String syncOpArtifact(String ref);

  /// No description provided for @syncOpRestore.
  ///
  /// In en, this message translates to:
  /// **'{ref}: restore'**
  String syncOpRestore(String ref);

  /// No description provided for @syncDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this change?'**
  String get syncDiscardTitle;

  /// No description provided for @syncDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get syncDiscard;

  /// No description provided for @syncRefused.
  ///
  /// In en, this message translates to:
  /// **'The server refused it: {reason}'**
  String syncRefused(String reason);

  /// No description provided for @syncCheckBody.
  ///
  /// In en, this message translates to:
  /// **'The answer was lost, so this task may already exist. Look at the project, then send it or drop it.'**
  String get syncCheckBody;

  /// No description provided for @syncSendAnyway.
  ///
  /// In en, this message translates to:
  /// **'Send anyway'**
  String get syncSendAnyway;

  /// No description provided for @syncAlreadyThere.
  ///
  /// In en, this message translates to:
  /// **'It\'s already there'**
  String get syncAlreadyThere;

  /// No description provided for @syncRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get syncRetry;

  /// No description provided for @syncKeptMine.
  ///
  /// In en, this message translates to:
  /// **'Kept mine'**
  String get syncKeptMine;

  /// No description provided for @syncKeptTheirs.
  ///
  /// In en, this message translates to:
  /// **'Kept theirs'**
  String get syncKeptTheirs;

  /// No description provided for @syncKeptEdited.
  ///
  /// In en, this message translates to:
  /// **'Sent an edit'**
  String get syncKeptEdited;

  /// No description provided for @syncKeptRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored and applied'**
  String get syncKeptRestored;

  /// No description provided for @syncKeptDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Discarded mine'**
  String get syncKeptDiscarded;

  /// No description provided for @syncByPolicy.
  ///
  /// In en, this message translates to:
  /// **'{what}, by your setting'**
  String syncByPolicy(String what);

  /// No description provided for @syncReverse.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get syncReverse;

  /// No description provided for @syncBannerWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change waits to sync.} other{{count} changes wait to sync.}}'**
  String syncBannerWaiting(int count);

  /// No description provided for @syncBannerConflict.
  ///
  /// In en, this message translates to:
  /// **'Your offline changes need a decision.'**
  String get syncBannerConflict;

  /// No description provided for @syncBannerDraft.
  ///
  /// In en, this message translates to:
  /// **'Created offline. It gets its reference when it syncs.'**
  String get syncBannerDraft;

  /// No description provided for @syncResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get syncResolve;

  /// No description provided for @syncBadge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 conflict to resolve} other{{count} conflicts to resolve}}'**
  String syncBadge(int count);

  /// No description provided for @syncPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'When a change conflicts'**
  String get syncPolicyLabel;

  /// No description provided for @syncPolicyHelp.
  ///
  /// In en, this message translates to:
  /// **'For changes made offline that someone else also changed. Every conflict is kept under Conflicts, where it can be reversed.'**
  String get syncPolicyHelp;

  /// No description provided for @syncPolicyAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get syncPolicyAsk;

  /// No description provided for @syncPolicyMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get syncPolicyMine;

  /// No description provided for @syncPolicyTheirs.
  ///
  /// In en, this message translates to:
  /// **'Keep theirs'**
  String get syncPolicyTheirs;

  /// No description provided for @syncOpenConflicts.
  ///
  /// In en, this message translates to:
  /// **'Conflicts and unsynced changes'**
  String get syncOpenConflicts;

  /// No description provided for @syncDiscardAll.
  ///
  /// In en, this message translates to:
  /// **'Discard all unsynced changes'**
  String get syncDiscardAll;

  /// No description provided for @syncDiscardAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard every unsynced change?'**
  String get syncDiscardAllTitle;

  /// No description provided for @syncDiscardAllBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change made offline is dropped and never sent. Drafts disappear.} other{{count} changes made offline are dropped and never sent. Drafts disappear.}}'**
  String syncDiscardAllBody(int count);

  /// No description provided for @syncUnsentLost.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change made offline has not been sent yet and will be lost.} other{{count} changes made offline have not been sent yet and will be lost.}}'**
  String syncUnsentLost(int count);

  /// No description provided for @syncStateUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The changes waiting on this device could not be read. They are kept untouched and are not sent.'**
  String get syncStateUnreadable;

  /// Settings group for developer controls
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsAdvanced;

  /// Switch that lets adb shell commands change the app
  ///
  /// In en, this message translates to:
  /// **'Allow control over ADB'**
  String get settingsAdbControl;

  /// Explains the ADB control switch
  ///
  /// In en, this message translates to:
  /// **'Lets a computer connected with USB debugging switch context, add tasks and change settings in tix. Reading the app\'s state and opening tix:// links work without it.'**
  String get settingsAdbControlHelp;

  /// Toast for a tix:// link the app does not know
  ///
  /// In en, this message translates to:
  /// **'Link not recognised'**
  String get linkNotRecognised;

  /// Title of the sheet asking which context a link means
  ///
  /// In en, this message translates to:
  /// **'Open this link in which context?'**
  String get linkPickContextTitle;

  /// Body of the sheet asking which context a link means
  ///
  /// In en, this message translates to:
  /// **'The link fits more than one of your contexts.'**
  String get linkPickContextBody;

  /// Notification action that completes the task
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notifActionDone;

  /// Notification action that snoozes the task until tomorrow morning
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get notifActionSnooze;

  /// Notification action that posts a comment
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get notifActionReply;

  /// Hint in the inline reply field of a notification
  ///
  /// In en, this message translates to:
  /// **'Write a comment'**
  String get notifReplyLabel;

  /// Follow-up notification when Done failed; names no task
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t mark it done'**
  String get notifActionFailedDone;

  /// Follow-up notification when Snooze failed; names no task
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t snooze it'**
  String get notifActionFailedSnooze;

  /// Follow-up notification when Reply failed; names no task
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send your reply'**
  String get notifActionFailedReply;

  /// Body of the follow-up notification after a failed action
  ///
  /// In en, this message translates to:
  /// **'Open tix to try again.'**
  String get notifActionFailedBody;

  /// Puts a shortcut to a project or saved filter on the home screen
  ///
  /// In en, this message translates to:
  /// **'Add to home screen'**
  String get pinToHome;

  /// Toast when the launcher could not be asked to pin a shortcut
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add it to the home screen'**
  String get pinFailed;

  /// Tray menu entry that shows the window
  ///
  /// In en, this message translates to:
  /// **'Open tix'**
  String get trayOpen;

  /// Tray menu entry that opens the inbox, with the unread count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Inbox} =1{Inbox (1 unread)} other{Inbox ({count} unread)}}'**
  String trayInbox(int count);

  /// Tray menu entry that ends the app
  ///
  /// In en, this message translates to:
  /// **'Quit tix'**
  String get trayQuit;

  /// Tray icon hover text while no context is active
  ///
  /// In en, this message translates to:
  /// **'tix · not signed in'**
  String get trayStatusSignedOut;

  /// First line of the tray icon hover text: how many instances are set up
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{tix · 1 instance connected} other{tix · {count} instances connected}}'**
  String trayStatusHeadline(int count);

  /// Tray hover line for one instance: its name, where it is (host or 'local') and its state
  ///
  /// In en, this message translates to:
  /// **'{name} ({place}): {state}'**
  String trayStatusInstance(String name, String place, String state);

  /// Tray hover line for an instance with nothing to report
  ///
  /// In en, this message translates to:
  /// **'{name} ({place})'**
  String trayStatusInstanceQuiet(String name, String place);

  /// Where a local instance is, in the tray hover line, e.g. home (local)
  ///
  /// In en, this message translates to:
  /// **'local'**
  String get trayStatusLocal;

  /// Tray hover: the instance follows live updates
  ///
  /// In en, this message translates to:
  /// **'live'**
  String get trayStatusLive;

  /// Tray hover: connecting to live updates
  ///
  /// In en, this message translates to:
  /// **'connecting'**
  String get trayStatusConnecting;

  /// Tray hover: an offline sync is running
  ///
  /// In en, this message translates to:
  /// **'syncing'**
  String get trayStatusSyncing;

  /// Tray hover: the server cannot be reached
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get trayStatusOffline;

  /// Tray hover: when the last sync finished; ago is e.g. '2 minutes ago'
  ///
  /// In en, this message translates to:
  /// **'synced {ago}'**
  String trayStatusSynced(String ago);

  /// Tray hover: changes waiting in the outbox
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change queued} other{{count} changes queued}}'**
  String trayStatusQueued(int count);

  /// Tray hover: instances not listed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 more} other{+{count} more}}'**
  String trayStatusMore(int count);

  /// Tray hover: unread inbox items of the active context
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread in inbox} other{{count} unread in inbox}}'**
  String trayStatusUnread(int count);

  /// Settings section for the tray, start at login and the global shortcut
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get settingsDesktop;

  /// Explanation at the top of the desktop settings section
  ///
  /// In en, this message translates to:
  /// **'How tix behaves on this computer: the tray icon, starting at login and a shortcut that works in any app.'**
  String get settingsDesktopHelp;

  /// Switch: closing the window hides it to the tray
  ///
  /// In en, this message translates to:
  /// **'Keep running in the tray'**
  String get settingsCloseToTray;

  /// Help under the close to tray switch
  ///
  /// In en, this message translates to:
  /// **'Closing the window hides it, and sync and notifications carry on. Quit from the tray icon\'s menu.'**
  String get settingsCloseToTrayHelp;

  /// Shown instead of the help when the desktop has no tray, e.g. GNOME without an extension
  ///
  /// In en, this message translates to:
  /// **'This desktop shows no tray icons, so closing the window quits tix.'**
  String get settingsCloseToTrayNone;

  /// Switch: start tix when signing in to the computer
  ///
  /// In en, this message translates to:
  /// **'Start at login'**
  String get settingsAutostart;

  /// Help under the start at login switch
  ///
  /// In en, this message translates to:
  /// **'tix starts when you sign in to this computer.'**
  String get settingsAutostartHelp;

  /// Toast when the system refused to change start at login
  ///
  /// In en, this message translates to:
  /// **'Could not change start at login'**
  String get settingsAutostartFailed;

  /// Switch: a global keyboard shortcut opens quick add
  ///
  /// In en, this message translates to:
  /// **'Quick add from any app'**
  String get settingsHotkey;

  /// Help under the global shortcut switch; keys is the shortcut, such as Ctrl+Shift+Space
  ///
  /// In en, this message translates to:
  /// **'{keys} opens quick add, even while tix is in the background.'**
  String settingsHotkeyHelp(String keys);

  /// Toast when the global shortcut could not be registered
  ///
  /// In en, this message translates to:
  /// **'{keys} is taken by another app'**
  String settingsHotkeyTaken(String keys);

  /// Palette command opening the Watch screen
  ///
  /// In en, this message translates to:
  /// **'Go to Watch'**
  String get goWatch;

  /// Title of the screen that shows the tenant's events live
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watchTitle;

  /// Subtitle of the Watch screen and its Manage entry
  ///
  /// In en, this message translates to:
  /// **'The tenant\'s events as they happen, newest first.'**
  String get watchSubtitle;

  /// Button: stop the Watch list moving
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get watchPause;

  /// Button: show held events and follow again
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get watchResume;

  /// Button: forget the events shown on Watch
  ///
  /// In en, this message translates to:
  /// **'Clear the list'**
  String get watchClear;

  /// Notice while Watch is paused and nothing new arrived
  ///
  /// In en, this message translates to:
  /// **'Paused.'**
  String get watchPaused;

  /// Notice while Watch is paused, with how many events arrived
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Paused, 1 new event.} other{Paused, {count} new events.}}'**
  String watchPausedNew(int count);

  /// Button and sheet title: Watch filters
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get watchFilters;

  /// Watch filters button with how many are set
  ///
  /// In en, this message translates to:
  /// **'Filters ({count})'**
  String watchFiltersCount(int count);

  /// Filter chip: no event type filter
  ///
  /// In en, this message translates to:
  /// **'Every type'**
  String get watchAllTypes;

  /// Line under the Watch filters naming what is in force
  ///
  /// In en, this message translates to:
  /// **'Filtering on {filters}'**
  String watchFiltering(String filters);

  /// Part of the Watch filter line
  ///
  /// In en, this message translates to:
  /// **'project {projects}'**
  String watchFilterProject(String projects);

  /// Part of the Watch filter line
  ///
  /// In en, this message translates to:
  /// **'type {types}'**
  String watchFilterType(String types);

  /// Part of the Watch filter line
  ///
  /// In en, this message translates to:
  /// **'actor {actors}'**
  String watchFilterActor(String actors);

  /// Part of the Watch filter line: replaying after a sequence number
  ///
  /// In en, this message translates to:
  /// **'after #{seq}'**
  String watchFilterSince(int seq);

  /// Label of the project choices in the Watch filters
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get watchProjects;

  /// Help under the Watch project choices
  ///
  /// In en, this message translates to:
  /// **'Sent to the server. None picked follows every project.'**
  String get watchProjectsHelp;

  /// Label of the event type field in the Watch filters
  ///
  /// In en, this message translates to:
  /// **'Event types'**
  String get watchTypes;

  /// Help under the event type field
  ///
  /// In en, this message translates to:
  /// **'Comma separated, sent to the server. A trailing * matches a prefix, as in task.*.'**
  String get watchTypesHelp;

  /// Label of the actor field in the Watch filters
  ///
  /// In en, this message translates to:
  /// **'Actors'**
  String get watchActors;

  /// Help under the actor field
  ///
  /// In en, this message translates to:
  /// **'Handles or ids, comma separated. Matched on this device, as tix watch does.'**
  String get watchActorsHelp;

  /// Label of the replay field in the Watch filters
  ///
  /// In en, this message translates to:
  /// **'Replay from sequence number'**
  String get watchReplay;

  /// Help under the replay field
  ///
  /// In en, this message translates to:
  /// **'Shows the events after this number again, then follows live. Empty starts from now.'**
  String get watchReplayHelp;

  /// Tooltip of the button opening an event's details
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get watchDetails;

  /// Button in an event's details: open its task or project
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get watchOpen;

  /// Label: an event's sequence number
  ///
  /// In en, this message translates to:
  /// **'Sequence'**
  String get watchSeq;

  /// Label: an event's type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get watchType;

  /// Label: an event's project
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get watchProject;

  /// Label: an event's id
  ///
  /// In en, this message translates to:
  /// **'Event id'**
  String get watchEventId;

  /// Heading over an event's full payload
  ///
  /// In en, this message translates to:
  /// **'Payload'**
  String get watchPayload;

  /// Watch has no events yet
  ///
  /// In en, this message translates to:
  /// **'Waiting for events'**
  String get watchEmpty;

  /// Body of Watch's empty state
  ///
  /// In en, this message translates to:
  /// **'Changes in this tenant show up here as they happen. Earlier ones are not shown unless you replay from a sequence number.'**
  String get watchEmptyBody;

  /// Watch has events, but none pass the filters
  ///
  /// In en, this message translates to:
  /// **'Nothing matches yet'**
  String get watchNoMatch;

  /// Body when nothing passes the Watch filters
  ///
  /// In en, this message translates to:
  /// **'Events arrive, but none match these filters.'**
  String get watchNoMatchBody;

  /// Watch is subscribing
  ///
  /// In en, this message translates to:
  /// **'Connecting to the event stream'**
  String get watchConnecting;

  /// Watch cannot reach the server
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get watchOffline;

  /// Body when Watch is offline
  ///
  /// In en, this message translates to:
  /// **'The server cannot be reached. Watch carries on from where it stopped once it can.'**
  String get watchOfflineBody;

  /// Watch has no server to follow
  ///
  /// In en, this message translates to:
  /// **'No context is active'**
  String get watchNoContext;

  /// Title when the credential may not follow events
  ///
  /// In en, this message translates to:
  /// **'This connection cannot watch events'**
  String get watchRefused;

  /// Why the credential may not follow events
  ///
  /// In en, this message translates to:
  /// **'Following events needs the event:subscribe scope. Use a token that has it, or ask an administrator for it.'**
  String get watchRefusedBody;

  /// Title of the notice when a Watch filter is refused
  ///
  /// In en, this message translates to:
  /// **'The server refused this filter'**
  String get watchFilterRefused;

  /// Notice when live updates only refresh on a timer
  ///
  /// In en, this message translates to:
  /// **'This server cannot stream events to the app right now, so Watch stays empty. It picks up again once live updates work.'**
  String get watchUnsupported;

  /// Notice when the server refused an expired cursor
  ///
  /// In en, this message translates to:
  /// **'Events after #{seq} are no longer kept on the server. Showing new events from now.'**
  String watchExpired(int seq);

  /// Notice when Watch resubscribed without a cursor
  ///
  /// In en, this message translates to:
  /// **'The connection came back without a cursor, so some events may be missing.'**
  String get watchMissed;

  /// Button hiding a Watch notice
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get watchDismiss;

  /// Footer when Watch reached its cap
  ///
  /// In en, this message translates to:
  /// **'Keeping the latest {count} events; older ones are dropped.'**
  String watchKeeping(int count);

  /// Event summary: claimed on behalf of someone
  ///
  /// In en, this message translates to:
  /// **'for {holder}'**
  String watchFor(String holder);

  /// Event summary: how long a claim's lease runs, such as 30m
  ///
  /// In en, this message translates to:
  /// **'lease {duration}'**
  String watchLease(String duration);

  /// Event summary: who lost an expired lease
  ///
  /// In en, this message translates to:
  /// **'held by {holder}'**
  String watchHeldBy(String holder);

  /// Event summary: the status a task went back to
  ///
  /// In en, this message translates to:
  /// **'reverted to {status}'**
  String watchRevertedTo(String status);

  /// Event summary: which task fields an update changed
  ///
  /// In en, this message translates to:
  /// **'changed {fields}'**
  String watchChanged(String fields);

  /// Event summary: a task came back from the trash
  ///
  /// In en, this message translates to:
  /// **'restored'**
  String get watchRestored;

  /// Event summary
  ///
  /// In en, this message translates to:
  /// **'comment deleted'**
  String get watchCommentDeleted;

  /// Event summary
  ///
  /// In en, this message translates to:
  /// **'lease renewed'**
  String get watchLeaseRenewed;

  /// Event summary
  ///
  /// In en, this message translates to:
  /// **'tag removed: {tag}'**
  String watchTagRemoved(String tag);

  /// Event summary
  ///
  /// In en, this message translates to:
  /// **'dependency removed: {ref}'**
  String watchDependencyRemoved(String ref);

  /// Event summary: an update from an external sync source
  ///
  /// In en, this message translates to:
  /// **'synced from {system}'**
  String watchSyncedFrom(String system);

  /// Settings and About section for app updates
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get settingsUpdates;

  /// Explanation at the top of the updates settings section
  ///
  /// In en, this message translates to:
  /// **'tix looks for new releases on GitHub. Updates are checked before they are installed: the download has to match the checksums the release signed.'**
  String get settingsUpdatesHelp;

  /// Switch: look for new releases automatically
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get settingsUpdateCheck;

  /// Help under the check for updates switch
  ///
  /// In en, this message translates to:
  /// **'When tix starts and every few hours.'**
  String get settingsUpdateCheckHelp;

  /// Switch: install a downloaded update when the app quits
  ///
  /// In en, this message translates to:
  /// **'Install updates automatically'**
  String get settingsUpdateAuto;

  /// Help under the install updates automatically switch
  ///
  /// In en, this message translates to:
  /// **'A downloaded update is installed when you quit tix.'**
  String get settingsUpdateAutoHelp;

  /// Button: check for updates right away
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get updateCheckNow;

  /// Update status before the first check
  ///
  /// In en, this message translates to:
  /// **'Not checked yet.'**
  String get updateIdle;

  /// Update status while checking
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get updateChecking;

  /// Update status when no newer release exists
  ///
  /// In en, this message translates to:
  /// **'tix {version} is the latest version.'**
  String updateCurrent(String version);

  /// Update status when a newer release exists
  ///
  /// In en, this message translates to:
  /// **'Update available: tix {version}'**
  String updateAvailable(String version);

  /// Under an available update that the app does not install itself
  ///
  /// In en, this message translates to:
  /// **'Download it from the release page.'**
  String get updateAvailableHelp;

  /// Update status while downloading
  ///
  /// In en, this message translates to:
  /// **'Downloading tix {version}… {percent}%'**
  String updateDownloading(String version, int percent);

  /// Update status when an update is downloaded and verified
  ///
  /// In en, this message translates to:
  /// **'tix {version} is ready to install.'**
  String updateReady(String version);

  /// Under a ready update when install automatically is on
  ///
  /// In en, this message translates to:
  /// **'It installs when you quit tix, or now with a restart.'**
  String get updateReadyAuto;

  /// Button: install the downloaded update and restart
  ///
  /// In en, this message translates to:
  /// **'Restart to update'**
  String get updateRestart;

  /// Button: open the release page to download the update by hand
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updateDownload;

  /// Button: open the release notes
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get updateWhatsNew;

  /// Update status when the check or download failed on the network
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach GitHub to check for updates.'**
  String get updateFailedNetwork;

  /// Update status when the signature or checksum did not match
  ///
  /// In en, this message translates to:
  /// **'The update couldn\'t be verified, so it wasn\'t installed.'**
  String get updateFailedVerify;

  /// Update status when unpacking or replacing the app failed
  ///
  /// In en, this message translates to:
  /// **'The update couldn\'t be installed.'**
  String get updateFailedInstall;

  /// Under an available update when the release has no archive for this OS or CPU
  ///
  /// In en, this message translates to:
  /// **'There is no download for this system in the release.'**
  String get updateNoAsset;

  /// Tray menu entry while a newer release exists
  ///
  /// In en, this message translates to:
  /// **'Update available ({version})'**
  String trayUpdateAvailable(String version);

  /// Tray menu entry once an update is ready to install
  ///
  /// In en, this message translates to:
  /// **'Restart to update ({version})'**
  String trayRestartToUpdate(String version);

  /// Tray menu entry that opens the Watch screen
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get trayWatch;

  /// Watch row: the channel an event came through
  ///
  /// In en, this message translates to:
  /// **'via {channel}'**
  String watchVia(String channel);

  /// Watch row: the channel and the token or job that made the change
  ///
  /// In en, this message translates to:
  /// **'via {channel} ({name})'**
  String watchViaNamed(String channel, String name);

  /// The channel of a change made with an API token, naming the token
  ///
  /// In en, this message translates to:
  /// **'via token {name}'**
  String viaToken(String name);

  /// The channel of a change a client such as the CLI or MCP made with an API token, naming the token
  ///
  /// In en, this message translates to:
  /// **'via {channel} (token {name})'**
  String viaChannelToken(String channel, String name);

  /// Access channel: the web interface
  ///
  /// In en, this message translates to:
  /// **'web'**
  String get watchChannelWeb;

  /// Access channel: an API token
  ///
  /// In en, this message translates to:
  /// **'API'**
  String get watchChannelApi;

  /// Access channel: the command line
  ///
  /// In en, this message translates to:
  /// **'CLI'**
  String get watchChannelCli;

  /// Access channel: the terminal interface over SSH
  ///
  /// In en, this message translates to:
  /// **'SSH'**
  String get watchChannelSsh;

  /// Access channel: an MCP client
  ///
  /// In en, this message translates to:
  /// **'MCP'**
  String get watchChannelMcp;

  /// Access channel: external sync
  ///
  /// In en, this message translates to:
  /// **'sync'**
  String get watchChannelSync;

  /// Access channel: an import
  ///
  /// In en, this message translates to:
  /// **'import'**
  String get watchChannelImport;

  /// Access channel: background work of the server
  ///
  /// In en, this message translates to:
  /// **'system'**
  String get watchChannelSystem;

  /// Access channel of an entry recorded before channels were
  ///
  /// In en, this message translates to:
  /// **'an unknown channel'**
  String get watchChannelUnknown;

  /// Changed task field in a Watch row
  ///
  /// In en, this message translates to:
  /// **'title'**
  String get watchFieldTitle;

  /// Changed task field in a Watch row
  ///
  /// In en, this message translates to:
  /// **'description'**
  String get watchFieldBody;

  /// Changed task field in a Watch row
  ///
  /// In en, this message translates to:
  /// **'priority'**
  String get watchFieldPriority;

  /// Changed task field in a Watch row
  ///
  /// In en, this message translates to:
  /// **'assignee'**
  String get watchFieldAssignee;

  /// Changed task field in a Watch row
  ///
  /// In en, this message translates to:
  /// **'tags'**
  String get watchFieldTags;

  /// Changed task field in a Watch row
  ///
  /// In en, this message translates to:
  /// **'due date'**
  String get watchFieldDue;

  /// Changed task field in a Watch row
  ///
  /// In en, this message translates to:
  /// **'repeat rule'**
  String get watchFieldRecurrence;

  /// Changed task field in a Watch row
  ///
  /// In en, this message translates to:
  /// **'custom fields'**
  String get watchFieldCustom;

  /// Changed task field in a Watch row
  ///
  /// In en, this message translates to:
  /// **'parent'**
  String get watchFieldParent;

  /// Watch row: the comment was edited, not added
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get watchCommentEdited;

  /// Watch row: a comment's text after its author, when someone else posted it
  ///
  /// In en, this message translates to:
  /// **'{author}: {text}'**
  String watchCommentBy(String author, String text);

  /// No description provided for @boardPriorityTo.
  ///
  /// In en, this message translates to:
  /// **'Priority…'**
  String get boardPriorityTo;

  /// No description provided for @boardDueTo.
  ///
  /// In en, this message translates to:
  /// **'Due date…'**
  String get boardDueTo;

  /// No description provided for @boardTagAdd.
  ///
  /// In en, this message translates to:
  /// **'Add tag…'**
  String get boardTagAdd;

  /// No description provided for @boardPrioritySet.
  ///
  /// In en, this message translates to:
  /// **'{ref} priority changed'**
  String boardPrioritySet(String ref);

  /// No description provided for @boardDueSet.
  ///
  /// In en, this message translates to:
  /// **'{ref} due date set'**
  String boardDueSet(String ref);

  /// No description provided for @boardDueCleared.
  ///
  /// In en, this message translates to:
  /// **'{ref} due date cleared'**
  String boardDueCleared(String ref);

  /// No description provided for @boardTagged.
  ///
  /// In en, this message translates to:
  /// **'{ref} tagged {tag}'**
  String boardTagged(String ref, String tag);

  /// No description provided for @sidebarCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse sidebar'**
  String get sidebarCollapse;

  /// No description provided for @sidebarExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand sidebar'**
  String get sidebarExpand;

  /// No description provided for @sidebarResize.
  ///
  /// In en, this message translates to:
  /// **'Resize sidebar'**
  String get sidebarResize;

  /// No description provided for @paneCollapsed.
  ///
  /// In en, this message translates to:
  /// **'Collapsed'**
  String get paneCollapsed;

  /// No description provided for @paneResizeHint.
  ///
  /// In en, this message translates to:
  /// **'Drag, or use the arrow keys. Enter or a double click resets the width.'**
  String get paneResizeHint;

  /// No description provided for @taskPanelClose.
  ///
  /// In en, this message translates to:
  /// **'Close task'**
  String get taskPanelClose;

  /// No description provided for @taskPanelResize.
  ///
  /// In en, this message translates to:
  /// **'Resize task panel'**
  String get taskPanelResize;

  /// No description provided for @keysNextRow.
  ///
  /// In en, this message translates to:
  /// **'Next row'**
  String get keysNextRow;

  /// No description provided for @keysPreviousRow.
  ///
  /// In en, this message translates to:
  /// **'Previous row'**
  String get keysPreviousRow;

  /// No description provided for @keysFirstRow.
  ///
  /// In en, this message translates to:
  /// **'First row'**
  String get keysFirstRow;

  /// No description provided for @keysLastRow.
  ///
  /// In en, this message translates to:
  /// **'Last row'**
  String get keysLastRow;

  /// No description provided for @keysPageDown.
  ///
  /// In en, this message translates to:
  /// **'Page down'**
  String get keysPageDown;

  /// No description provided for @keysPageUp.
  ///
  /// In en, this message translates to:
  /// **'Page up'**
  String get keysPageUp;

  /// No description provided for @keysOpenRow.
  ///
  /// In en, this message translates to:
  /// **'Open the focused row'**
  String get keysOpenRow;

  /// No description provided for @keysBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get keysBack;

  /// No description provided for @keysLeaveField.
  ///
  /// In en, this message translates to:
  /// **'Leave the text field'**
  String get keysLeaveField;

  /// No description provided for @keysFirstTask.
  ///
  /// In en, this message translates to:
  /// **'First task'**
  String get keysFirstTask;

  /// No description provided for @keysLastTask.
  ///
  /// In en, this message translates to:
  /// **'Last task'**
  String get keysLastTask;

  /// No description provided for @settingsKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get settingsKeyboard;

  /// No description provided for @settingsKeyboardHelp.
  ///
  /// In en, this message translates to:
  /// **'For a hardware keyboard, on any device. Keys typed into a text field always stay in the field.'**
  String get settingsKeyboardHelp;

  /// No description provided for @settingsShortcutsHelp.
  ///
  /// In en, this message translates to:
  /// **'Off turns every shortcut off, Ctrl K for the palette included. Tab, Enter and Esc keep working.'**
  String get settingsShortcutsHelp;

  /// No description provided for @settingsKeymap.
  ///
  /// In en, this message translates to:
  /// **'Key preset'**
  String get settingsKeymap;

  /// No description provided for @keymapDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get keymapDefault;

  /// No description provided for @keymapVim.
  ///
  /// In en, this message translates to:
  /// **'Vim'**
  String get keymapVim;

  /// No description provided for @keymapEmacs.
  ///
  /// In en, this message translates to:
  /// **'Emacs'**
  String get keymapEmacs;

  /// No description provided for @keymapOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get keymapOff;

  /// No description provided for @keymapDefaultHelp.
  ///
  /// In en, this message translates to:
  /// **'The app\'s keys and tix web\'s: j and k move, g p opens Projects, Ctrl 1 to 6 switch destinations.'**
  String get keymapDefaultHelp;

  /// No description provided for @keymapVimHelp.
  ///
  /// In en, this message translates to:
  /// **'Vim reflexes: gg and G jump, o adds, i renames, dd deletes after asking, h goes back.'**
  String get keymapVimHelp;

  /// No description provided for @keymapEmacsHelp.
  ///
  /// In en, this message translates to:
  /// **'Emacs reflexes outside text fields: C-n and C-p move, C-s filters, C-g cancels, M-x opens the palette.'**
  String get keymapEmacsHelp;

  /// No description provided for @keymapOffHelp.
  ///
  /// In en, this message translates to:
  /// **'No single key runs anything. Chords held with Ctrl, Alt or ⌘ still work.'**
  String get keymapOffHelp;

  /// No description provided for @settingsKeyBindings.
  ///
  /// In en, this message translates to:
  /// **'Active bindings'**
  String get settingsKeyBindings;

  /// No description provided for @settingsKeyBindingsOff.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts are off.'**
  String get settingsKeyBindingsOff;
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
      <String>['bg', 'de', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
