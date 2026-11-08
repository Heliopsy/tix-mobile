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
  /// **'Add a server'**
  String get connectAddTitle;

  /// No description provided for @connectIntro.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the address of your tix server and an API token.'**
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
  /// **'Shown when you switch between servers.'**
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

  /// No description provided for @serversLabel.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get serversLabel;

  /// No description provided for @addServer.
  ///
  /// In en, this message translates to:
  /// **'Add a server'**
  String get addServer;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'This forgets the token for {server} on this device.'**
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
  /// **'The token was not accepted. Check it, or create a new one.'**
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
