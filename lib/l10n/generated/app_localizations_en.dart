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

  @override
  String get back => 'Back';

  @override
  String get undo => 'Undo';

  @override
  String get close => 'Close';

  @override
  String get loading => 'Loading';

  @override
  String get moreInfo => 'More information';

  @override
  String get dueOverdue => 'overdue';

  @override
  String get dueToday => 'due today';

  @override
  String dueOn(String date) {
    return 'due $date';
  }

  @override
  String snoozedUntil(String date) {
    return 'snoozed until $date';
  }

  @override
  String get blockedByOther => 'Waiting on another task';

  @override
  String get starred => 'Starred';

  @override
  String get star => 'Star';

  @override
  String get unstar => 'Unstar';

  @override
  String get complete => 'Complete';

  @override
  String get reopen => 'Reopen';

  @override
  String get snooze => 'Snooze';

  @override
  String get assign => 'Assign';

  @override
  String get filterHint => 'Filter, for example status:todo tag:ops';

  @override
  String get shortcutsTitle => 'Keyboard shortcuts';

  @override
  String get showShortcuts => 'Show keyboard shortcuts';

  @override
  String get openCommandPalette => 'Open the command palette';

  @override
  String get commandSearchHint => 'Type a command';

  @override
  String get commandNone => 'No command matches.';

  @override
  String get goProjects => 'Go to projects';

  @override
  String get goSettings => 'Go to settings';

  @override
  String get goInstances => 'Go to instances';

  @override
  String get commandsNavigate => 'Navigate';

  @override
  String get commandsTasks => 'Tasks';

  @override
  String get newTask => 'New task';

  @override
  String get refresh => 'Refresh';

  @override
  String get projectsEmptyBody =>
      'Create one with New project, in the browser or with tix project add.';

  @override
  String get tasksEmptyBody =>
      'Add a task with one line: a title, then !high, #tag, @handle or due:fri.';

  @override
  String get instancesEmptyBody =>
      'Add the tix server you work on, or a database on this device.';

  @override
  String projectsSubtitle(String tenant) {
    return 'Every project in $tenant';
  }

  @override
  String get aboutTitle => 'About';

  @override
  String get appearanceLabel => 'Appearance';

  @override
  String get accountLabel => 'Account';

  @override
  String get galleryTitle => 'Components';

  @override
  String taskDetailActionsFor(String ref) {
    return 'Actions for $ref';
  }

  @override
  String get taskDetailActorSearch => 'Search by name or handle';

  @override
  String get taskDetailAdd => 'Add';

  @override
  String get taskDetailAddDependency => 'Add dependency';

  @override
  String get taskDetailAddSubtask => 'Add subtask';

  @override
  String get taskDetailAddTag => 'Add tag';

  @override
  String get taskDetailArtifactFile => 'file';

  @override
  String get taskDetailArtifactLog => 'log';

  @override
  String get taskDetailArtifactMetric => 'metric';

  @override
  String get taskDetailArtifactResult => 'result';

  @override
  String get taskDetailArtifacts => 'Artifacts';

  @override
  String get taskDetailArtifactSave => 'Save';

  @override
  String get taskDetailArtifactShow => 'Show';

  @override
  String get taskDetailArtifactUnreadable =>
      'This artifact\'s content cannot be read.';

  @override
  String get taskDetailAssigneeTitle => 'Assign';

  @override
  String taskDetailAttached(String name) {
    return 'Attached $name.';
  }

  @override
  String get taskDetailAttachFile => 'Attach file';

  @override
  String get taskDetailBlocked =>
      'Blocked: it waits for a task that is not finished.';

  @override
  String taskDetailChecklist(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get taskDetailClear => 'Clear';

  @override
  String get taskDetailCommands => 'Task';

  @override
  String get taskDetailCommentActions => 'Comment actions';

  @override
  String get taskDetailCommentAdded => 'Comment added.';

  @override
  String get taskDetailCommentDelete => 'Delete comment';

  @override
  String get taskDetailCommentDeleteBody =>
      'It disappears for everyone. This cannot be undone here.';

  @override
  String get taskDetailCommentDeleted => 'Comment deleted.';

  @override
  String get taskDetailCommentDeleteTitle => 'Delete this comment?';

  @override
  String get taskDetailCommentEdit => 'Edit comment';

  @override
  String get taskDetailCommentHint => 'Markdown works. @ names someone.';

  @override
  String get taskDetailCommentLabel => 'Comment';

  @override
  String get taskDetailComments => 'Comments';

  @override
  String get taskDetailCommentSend => 'Comment';

  @override
  String taskDetailCopied(String ref) {
    return 'Copied as $ref.';
  }

  @override
  String get taskDetailCopiedFrom => 'Copied from';

  @override
  String get taskDetailCopyAction => 'Copy';

  @override
  String get taskDetailCopyComments => 'Copy its comments';

  @override
  String get taskDetailCopyDependencies => 'Copy its dependencies';

  @override
  String get taskDetailCopyKeepStatus => 'Keep its status';

  @override
  String get taskDetailCopyLink => 'Link the copy to this task';

  @override
  String get taskDetailCopyNewTitle => 'Title of the copy';

  @override
  String get taskDetailCopyProject => 'Project';

  @override
  String get taskDetailCopyRef => 'Copy reference';

  @override
  String get taskDetailCopySubtasks => 'Copy its subtasks';

  @override
  String taskDetailCopyTitle(String ref) {
    return 'Copy $ref';
  }

  @override
  String get taskDetailCopyTo => 'Copy to…';

  @override
  String taskDetailCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String get taskDetailCreated => 'Created';

  @override
  String get taskDetailCurrent => 'Current';

  @override
  String get taskDetailDelete => 'Delete';

  @override
  String taskDetailDeleted(String ref) {
    return 'Deleted $ref.';
  }

  @override
  String get taskDetailDeleteForGood => 'Delete permanently';

  @override
  String get taskDetailDeletePermanentBody =>
      'It is removed for good, with its comments and history.';

  @override
  String taskDetailDeleteSubtasksBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Its $count subtasks are deleted with it.',
      one: 'Its subtask is deleted with it.',
    );
    return '$_temp0';
  }

  @override
  String taskDetailDeleteTitle(String ref) {
    return 'Delete $ref?';
  }

  @override
  String get taskDetailDeleteTrashBody =>
      'It goes to the trash and can be restored.';

  @override
  String get taskDetailDependencies => 'Waits for';

  @override
  String get taskDetailDependenciesInfo =>
      'This task counts as blocked until each task listed here reaches a finished state.';

  @override
  String taskDetailDependencyAdded(String ref) {
    return 'Now waits for $ref.';
  }

  @override
  String taskDetailDependencyRemoved(String ref) {
    return 'No longer waits for $ref.';
  }

  @override
  String get taskDetailDependsOn => 'Depends on';

  @override
  String get taskDetailDependsOnHint => 'A reference, for example infra-2';

  @override
  String get taskDetailDescriptionHint =>
      'Markdown. - [ ] makes a checklist item.';

  @override
  String get taskDetailDueClear => 'No due date';

  @override
  String get taskDetailDueNextWeek => 'Next week';

  @override
  String get taskDetailDueTitle => 'Due date';

  @override
  String get taskDetailDueToday => 'Today';

  @override
  String get taskDetailDueTomorrow => 'Tomorrow';

  @override
  String get taskDetailEdit => 'Edit';

  @override
  String get taskDetailEditDescription => 'Edit description';

  @override
  String get taskDetailEdited => 'edited';

  @override
  String taskDetailEditField(String name) {
    return 'Change $name';
  }

  @override
  String get taskDetailFileTooBig => 'Files over 1 MiB cannot be attached.';

  @override
  String get taskDetailHistory => 'History';

  @override
  String taskDetailHistoryChanged(String fields) {
    return 'changed $fields';
  }

  @override
  String get taskDetailHistoryCreated => 'created the task';

  @override
  String get taskDetailHistoryDeleted => 'deleted the task';

  @override
  String get taskDetailHistoryMore => 'Show older';

  @override
  String taskDetailHistoryMoved(String from, String to) {
    return 'moved it from $from to $to';
  }

  @override
  String get taskDetailHistoryRestored => 'restored the task';

  @override
  String get taskDetailJsonHelp =>
      'A JSON value: a number, a string in quotes, a list or an object';

  @override
  String get taskDetailMove => 'Move';

  @override
  String get taskDetailMoveComment => 'Comment';

  @override
  String get taskDetailMoveCommentHelp =>
      'This move needs a comment saying why.';

  @override
  String taskDetailMoved(String ref, String status) {
    return 'Moved $ref to $status.';
  }

  @override
  String get taskDetailMoveFrom => 'From';

  @override
  String get taskDetailMoveNeedsComment => 'Needs a comment';

  @override
  String taskDetailMoveStopped(String state, String reason) {
    return 'Stopped before $state: $reason';
  }

  @override
  String get taskDetailMoveTitle => 'Move';

  @override
  String taskDetailMoveTo(String state) {
    return 'Move to $state';
  }

  @override
  String taskDetailMoveVia(String states) {
    return 'via $states';
  }

  @override
  String get taskDetailNo => 'No';

  @override
  String get taskDetailNoArtifacts => 'No artifacts.';

  @override
  String get taskDetailNoComments => 'No comments yet.';

  @override
  String get taskDetailNoDependencies => 'Waits for nothing.';

  @override
  String get taskDetailNoHistory => 'No history.';

  @override
  String get taskDetailNoMoves => 'The workflow allows no move from here.';

  @override
  String get taskDetailNoRepeat => 'Does not repeat';

  @override
  String get taskDetailNoSubtasks => 'No subtasks.';

  @override
  String get taskDetailOpen => 'Open';

  @override
  String get taskDetailParent => 'Subtask of';

  @override
  String get taskDetailPickDate => 'Pick a date…';

  @override
  String get taskDetailPickDateTime => 'Pick a date and time…';

  @override
  String get taskDetailPreview => 'Preview';

  @override
  String get taskDetailPriorityTitle => 'Priority';

  @override
  String get taskDetailProject => 'Project';

  @override
  String get taskDetailRefCopied => 'Reference copied.';

  @override
  String taskDetailRemoveDependency(String ref) {
    return 'Stop waiting for $ref';
  }

  @override
  String taskDetailRemoveTag(String tag) {
    return 'Remove $tag';
  }

  @override
  String get taskDetailRename => 'Rename';

  @override
  String get taskDetailRepeat => 'Repeats';

  @override
  String get taskDetailRepeatHelp =>
      'every day, every 2 weeks on mon,thu, every month on day 31, 3 days after done';

  @override
  String get taskDetailRepeatHint => 'every week';

  @override
  String get taskDetailRepeatInfo =>
      'Finishing a task with a rule creates the next one at once. Cancelling it does not. Empty stops the repeat.';

  @override
  String get taskDetailRepeats => 'Repeats';

  @override
  String get taskDetailRepeatTitle => 'Repeat rule';

  @override
  String get taskDetailSave => 'Save';

  @override
  String get taskDetailSaved => 'Saved.';

  @override
  String get taskDetailSnooze => 'Snooze';

  @override
  String taskDetailSnoozed(String when) {
    return 'Snoozed until $when.';
  }

  @override
  String get taskDetailSnoozeLater => 'Later today';

  @override
  String get taskDetailSnoozeNextWeek => 'Next week';

  @override
  String get taskDetailSnoozeTitle => 'Snooze until';

  @override
  String get taskDetailSnoozeTomorrow => 'Tomorrow morning';

  @override
  String get taskDetailStar => 'Star';

  @override
  String get taskDetailStarred => 'Starred.';

  @override
  String get taskDetailSubtaskAdded => 'Subtask added.';

  @override
  String get taskDetailSubtasks => 'Subtasks';

  @override
  String get taskDetailSystem => 'tix';

  @override
  String taskDetailTagAdded(String name) {
    return 'Tagged $name.';
  }

  @override
  String get taskDetailTagHint => 'A new name creates the tag';

  @override
  String taskDetailTagRemoved(String name) {
    return 'Removed $name.';
  }

  @override
  String get taskDetailTakePhoto => 'Take photo';

  @override
  String get taskDetailTitleLabel => 'Title';

  @override
  String get taskDetailUnassign => 'Unassign';

  @override
  String get taskDetailUnstar => 'Remove star';

  @override
  String get taskDetailUnstarred => 'Star removed.';

  @override
  String get taskDetailUpdated => 'Updated';

  @override
  String get taskDetailWake => 'Wake now';

  @override
  String get taskDetailWoken => 'Back in the lists.';

  @override
  String get taskDetailWrite => 'Write';

  @override
  String get taskDetailYes => 'Yes';

  @override
  String get boardAllEmpty => 'No tasks yet.';

  @override
  String get boardAllEmptyBody => 'Tasks from every project show here.';

  @override
  String get boardArrangement => 'Arrangement';

  @override
  String get boardAssignMe => 'Assign to me';

  @override
  String boardAssignedToMe(String ref) {
    return '$ref assigned to you';
  }

  @override
  String get boardCollapse => 'Collapse';

  @override
  String get boardColumnEmpty => 'Nothing here';

  @override
  String boardCompleted(String ref) {
    return '$ref completed';
  }

  @override
  String boardCount(int count, String more) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count$more tasks',
      one: '1$more task',
    );
    return '$_temp0';
  }

  @override
  String get boardExpand => 'Expand';

  @override
  String boardGroupMenu(String group) {
    return 'Arrange $group';
  }

  @override
  String boardHiddenCount(int count) {
    return 'Hidden: $count';
  }

  @override
  String get boardHide => 'Hide';

  @override
  String get boardLoadMore => 'Load more';

  @override
  String get boardMoveDown => 'Move down';

  @override
  String get boardMoveLeft => 'Move left';

  @override
  String get boardMoveRight => 'Move right';

  @override
  String boardMoveTitle(String ref) {
    return 'Move $ref to';
  }

  @override
  String get boardMoveTo => 'Move to…';

  @override
  String get boardMoveUp => 'Move up';

  @override
  String boardMoved(String ref, String status) {
    return '$ref moved to $status';
  }

  @override
  String get boardNext => 'Next task';

  @override
  String boardNoRoute(String ref) {
    return '$ref has no way there in its workflow';
  }

  @override
  String get boardOpen => 'Open';

  @override
  String get boardPrevious => 'Previous task';

  @override
  String get boardRefused =>
      'These projects run different workflows, so they cannot share one board. Narrow the filter to one workflow\'s projects to see a board.';

  @override
  String boardRefusedGroup(String workflow, String projects) {
    return '$workflow: $projects';
  }

  @override
  String boardReopened(String ref) {
    return '$ref reopened';
  }

  @override
  String get boardResetArrangement => 'Reset arrangement';

  @override
  String boardShowGroup(String group) {
    return 'Show $group';
  }

  @override
  String get boardSnoozeLater => 'Later today';

  @override
  String boardSnoozeTitle(String ref) {
    return 'Snooze $ref until';
  }

  @override
  String get boardSnoozeTomorrow => 'Tomorrow morning';

  @override
  String get boardSnoozeWeek => 'Next week';

  @override
  String boardSnoozed(String ref) {
    return '$ref snoozed';
  }

  @override
  String boardStarred(String ref) {
    return '$ref starred';
  }

  @override
  String boardStrays(String refs) {
    return 'Not on this board\'s columns: $refs';
  }

  @override
  String get boardSwitchProject => 'Switch project';

  @override
  String boardUnstarred(String ref) {
    return '$ref unstarred';
  }

  @override
  String get boardWake => 'Wake now';

  @override
  String boardWoken(String ref) {
    return '$ref is awake';
  }

  @override
  String get bulkClear => 'Clear selection';

  @override
  String get bulkCopy => 'Copy to…';

  @override
  String bulkCopyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copy $count tasks to',
      one: 'Copy 1 task to',
    );
    return '$_temp0';
  }

  @override
  String get bulkDelete => 'Delete';

  @override
  String get bulkDeleteBody =>
      'They go to the trash, and Undo brings them back.';

  @override
  String bulkDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count tasks?',
      one: 'Delete 1 task?',
    );
    return '$_temp0';
  }

  @override
  String bulkDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks changed',
      one: '1 task changed',
    );
    return '$_temp0';
  }

  @override
  String get bulkMove => 'Move';

  @override
  String bulkMoveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count tasks to',
      one: 'Move 1 task to',
    );
    return '$_temp0';
  }

  @override
  String bulkPartly(int count, String refused) {
    return '$count changed. Refused: $refused';
  }

  @override
  String get bulkSelect => 'Select';

  @override
  String get bulkSelectAll => 'Select all';

  @override
  String bulkSelected(int count) {
    return '$count selected';
  }

  @override
  String get bulkTagAdd => 'Add tag';

  @override
  String get bulkTagRemove => 'Remove tag';

  @override
  String get filterBlocked => 'Blocked';

  @override
  String get filterClear => 'Clear';

  @override
  String get filterDelete => 'Delete filter';

  @override
  String get filterDeleteBody => 'Anyone it was shared with loses it too.';

  @override
  String filterDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get filterDueToday => 'Due today';

  @override
  String get filterDueWeek => 'Due this week';

  @override
  String get filterFinished => 'Finished';

  @override
  String get filterFocus => 'Filter tasks';

  @override
  String get filterMine => 'Mine';

  @override
  String get filterName => 'Name';

  @override
  String get filterNoMatch => 'Nothing matches this filter.';

  @override
  String get filterNoMatchBody => 'Change the filter or clear it.';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterRename => 'Rename';

  @override
  String get filterSave => 'Save filter';

  @override
  String get filterSaveTitle => 'Save this filter';

  @override
  String filterSaved(String name) {
    return 'Saved $name';
  }

  @override
  String get filterShare => 'Share with everyone';

  @override
  String get filterShared => 'Share with everyone in the tenant';

  @override
  String get filterSharedHelp =>
      'Others see it under their saved filters; only you and administrators can change it.';

  @override
  String get filterSnoozed => 'Snoozed';

  @override
  String get filterUnshare => 'Stop sharing';

  @override
  String get goMyWork => 'Go to My work';

  @override
  String get goTasks => 'Go to Tasks';

  @override
  String get groupNone => 'No grouping';

  @override
  String get groupProject => 'Group by project';

  @override
  String get groupStatus => 'Group by status';

  @override
  String get lanesEmpty => 'No tasks';

  @override
  String get myWorkEmpty => 'Nothing assigned to you.';

  @override
  String get myWorkEmptyBody =>
      'Open tasks assigned to you show here by deadline.';

  @override
  String get myWorkLater => 'Later';

  @override
  String get myWorkNoDate => 'No date';

  @override
  String get myWorkOverdue => 'Overdue';

  @override
  String get myWorkTitle => 'My work';

  @override
  String get myWorkToday => 'Today';

  @override
  String get myWorkWeek => 'This week';

  @override
  String projectOpenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open tasks',
      one: '1 open task',
    );
    return '$_temp0';
  }

  @override
  String get sortCreated => 'Created';

  @override
  String get sortDescending => 'Descending';

  @override
  String get sortMenu => 'Sort and group';

  @override
  String get sortNumber => 'Number';

  @override
  String get sortTitle => 'Title';

  @override
  String get sortUpdated => 'Updated';

  @override
  String get sortUrgency => 'Urgency';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get viewBoard => 'Board';

  @override
  String get viewLanes => 'Lanes';

  @override
  String get viewList => 'List';

  @override
  String get viewSwitch => 'Switch view';

  @override
  String boardAssigned(String ref) {
    return '$ref assigned';
  }

  @override
  String get boardAssignTo => 'Assign to…';

  @override
  String get quickAddProject => 'Project';

  @override
  String get quickAddPickProject => 'Choose a project';

  @override
  String get quickAddNoProjects => 'There is no project to add to yet.';

  @override
  String get quickAddAnother => 'Add another';

  @override
  String get quickAddAnotherHelp => 'Stay open for the next line';

  @override
  String quickAddPreviewRefused(String reason) {
    return 'The server would refuse this: $reason';
  }

  @override
  String get quickAddPreviewOff =>
      'This connection cannot preview lines; adding still works.';

  @override
  String get quickAddOffline =>
      'Adding needs a connection to the server. The line is kept; try again when you are online.';

  @override
  String get quickAddChipPriority => 'priority';

  @override
  String get quickAddChipTag => 'tag';

  @override
  String get quickAddChipAssignee => 'assignee';

  @override
  String get quickAddChipDue => 'due';

  @override
  String get quickAddChipStatus => 'status';

  @override
  String get quickAddChipParent => 'parent';

  @override
  String get quickAddChipTitle => 'title';

  @override
  String get quickAddSuggestions => 'Suggestions';

  @override
  String get quickAddTemplates => 'From a template';

  @override
  String get quickAddManageTemplates => 'Templates';

  @override
  String get quickAddPaste => 'Quick add from the clipboard';

  @override
  String get quickAddClipboardEmpty => 'The clipboard holds no text.';

  @override
  String get paletteGroupProjects => 'Projects';

  @override
  String get paletteGroupRecent => 'Recent tasks';

  @override
  String get paletteGroupContexts => 'Switch to';

  @override
  String get paletteGroupTheme => 'Theme';

  @override
  String get paletteGroupTemplates => 'Templates';

  @override
  String paletteOpenTask(String ref) {
    return 'Open $ref';
  }

  @override
  String get paletteGoInbox => 'Go to inbox';

  @override
  String get paletteGoMyWork => 'Go to my work';

  @override
  String get paletteGoTemplates => 'Go to templates';

  @override
  String get paletteThemeLight => 'Light theme';

  @override
  String get paletteThemeDark => 'Dark theme';

  @override
  String get paletteThemeSystem => 'Theme of the system';

  @override
  String paletteUseTemplate(String name) {
    return 'New task from $name';
  }

  @override
  String get templatesTitle => 'Templates';

  @override
  String get templatesSubtitle => 'Tasks you add often, one tap away';

  @override
  String get templateNew => 'New template';

  @override
  String get templatesEmpty => 'No templates yet.';

  @override
  String get templatesEmptyBody =>
      'Save a task as a template to add it again in one tap.';

  @override
  String get templateEveryProject => 'Every project';

  @override
  String templateUses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Used $count times',
      one: 'Used once',
      zero: 'Never used',
    );
    return '$_temp0';
  }

  @override
  String templateSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subtasks',
      one: '1 subtask',
    );
    return '$_temp0';
  }

  @override
  String get templateUse => 'Use';

  @override
  String get templateEdit => 'Edit template';

  @override
  String get templateDelete => 'Delete template';

  @override
  String templateDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get templateDeleteBody => 'Tasks made from it stay.';

  @override
  String templateDeleted(String name) {
    return 'Deleted $name';
  }

  @override
  String templateSaved(String name) {
    return 'Saved $name';
  }

  @override
  String get templateName => 'Name';

  @override
  String get templateNameHelp =>
      'Unique in the tenant, at most 100 characters.';

  @override
  String get templateFromTask => 'From a task';

  @override
  String get templateFromScratch => 'From scratch';

  @override
  String get templateTaskRef => 'Task';

  @override
  String get templateTaskRefHelp =>
      'The reference of the task to keep, such as ops-12.';

  @override
  String get templateWithSubtasks => 'Keep its subtasks';

  @override
  String get templateTenantWide => 'Share with every project';

  @override
  String get templateDueIn => 'Due after';

  @override
  String get templateDueInHelp =>
      'How long after a use the task falls due, such as 3d or 2w. Empty for none.';

  @override
  String get templateScratchNote =>
      'tix keeps templates from tasks, so this also adds the task to the project.';

  @override
  String get templateTitle => 'Title';

  @override
  String templateTitleHelp(String date, String n, String project) {
    return '$date, $n and $project are filled in on each use.';
  }

  @override
  String get templateBody => 'Description';

  @override
  String get templatePriority => 'Priority';

  @override
  String get templateTags => 'Tags';

  @override
  String get templateTagsHelp => 'Separated by spaces or commas.';

  @override
  String get templateRecurrence => 'Repeats';

  @override
  String get templateRecurrenceHelp => 'Such as every 2 weeks. Empty for none.';

  @override
  String get templateSave => 'Save';

  @override
  String get templateCreate => 'Save template';

  @override
  String get templateRecentTasks => 'Recently opened';

  @override
  String get appShortcutInbox => 'Inbox';

  @override
  String get appShortcutMyWork => 'My work';

  @override
  String get templateDeleteAction => 'Delete';

  @override
  String get templateMore => 'More actions';

  @override
  String templateGeneralError(String reason) {
    return 'Could not save: $reason';
  }

  @override
  String get goInbox => 'Go to inbox';

  @override
  String get inboxTitle => 'Inbox';

  @override
  String get inboxAll => 'All';

  @override
  String get inboxUnreadFilter => 'Unread';

  @override
  String get inboxShowUnread => 'Show unread only';

  @override
  String get inboxUnread => 'unread';

  @override
  String get inboxAllCaughtUp => 'All caught up';

  @override
  String inboxUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread',
      one: '1 unread',
    );
    return '$_temp0';
  }

  @override
  String get inboxToday => 'Today';

  @override
  String get inboxYesterday => 'Yesterday';

  @override
  String get inboxEarlier => 'Earlier';

  @override
  String get inboxEmpty => 'Nothing here yet.';

  @override
  String get inboxEmptyBody =>
      'When somebody mentions you, assigns you a task or comments on one you follow, it shows up here.';

  @override
  String get inboxEmptyUnread => 'Nothing unread.';

  @override
  String get inboxEmptyFiltered => 'Nothing of these kinds.';

  @override
  String get inboxSomebody => 'Somebody';

  @override
  String inboxWhatMention(String who) {
    return '$who mentioned you';
  }

  @override
  String inboxWhatAssigned(String who) {
    return '$who assigned you';
  }

  @override
  String inboxWhatComment(String who) {
    return '$who commented';
  }

  @override
  String inboxWhatStatus(String who) {
    return '$who moved it';
  }

  @override
  String inboxWhatOther(String who) {
    return '$who changed it';
  }

  @override
  String get inboxMovedTo => 'moved to';

  @override
  String get inboxTaskGone => 'A task that has been deleted';

  @override
  String get inboxNow => 'now';

  @override
  String inboxMinutesAgo(int n) {
    return '$n min';
  }

  @override
  String inboxHoursAgo(int n) {
    return '$n h';
  }

  @override
  String get inboxItemActions => 'Actions';

  @override
  String get inboxOpenTask => 'Open task';

  @override
  String get inboxMarkRead => 'Mark read';

  @override
  String get inboxMarkUnread => 'Mark unread';

  @override
  String get inboxMarkAllRead => 'Mark all read';

  @override
  String inboxMarkedAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Marked $count items read',
      one: 'Marked 1 item read',
    );
    return '$_temp0';
  }

  @override
  String inboxMuteKind(String kind) {
    return 'Stop $kind in the inbox';
  }

  @override
  String inboxMuted(String kind) {
    return '$kind no longer reach your inbox';
  }

  @override
  String get inboxKindMention => 'Mentions';

  @override
  String get inboxKindAssigned => 'Assignments';

  @override
  String get inboxKindComment => 'Comments';

  @override
  String get inboxKindStatus => 'Status changes';

  @override
  String get inboxKindMentionHelp =>
      'Somebody writes @you in a comment or a description.';

  @override
  String get inboxKindAssignedHelp => 'A task is assigned to you.';

  @override
  String get inboxKindCommentHelp =>
      'Somebody comments on a task you are assigned to or starred.';

  @override
  String get inboxKindStatusHelp =>
      'A task assigned to you moves to another status.';

  @override
  String get inboxKindsTitle => 'Inbox';

  @override
  String get inboxKindsSubtitle =>
      'What creates an item in your inbox, on every device.';

  @override
  String get inboxKindsInfo =>
      'Stored on the server, as under Settings, Inbox in the web app. Off, a kind creates no item; items already in your inbox stay. Your own changes never appear.';

  @override
  String get inboxSummaryOverdue => 'Overdue';

  @override
  String get inboxSummaryDueToday => 'Due today';

  @override
  String get inboxSummaryOpen => 'Open';

  @override
  String get inboxSummaryDoneWeek => 'Done in 7 days';

  @override
  String inboxCategory(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'todo': 'To do',
      'inProgress': 'In progress',
      'blocked': 'Blocked',
      'waiting': 'Waiting',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String get inboxChannelsTitle => 'Channels';

  @override
  String get inboxChannelsSubtitle =>
      'Deliver your inbox to Slack, Discord, ntfy or any URL.';

  @override
  String get inboxChannelsInfo =>
      'A channel is yours alone: it receives only your items, of the kinds it lists, and nothing of a kind you stopped above. The server posts each item as it is written.';

  @override
  String get inboxChannelsEmpty => 'No channels yet.';

  @override
  String get inboxChannelAdd => 'Add channel';

  @override
  String get inboxChannelEdit => 'Edit channel';

  @override
  String get inboxChannelSave => 'Save';

  @override
  String get inboxChannelSaved => 'Channel saved';

  @override
  String inboxChannelAdded(String name) {
    return 'Added $name';
  }

  @override
  String get inboxChannelName => 'Name';

  @override
  String get inboxChannelNameHint => 'My Slack';

  @override
  String get inboxChannelUrl => 'Address';

  @override
  String get inboxChannelUrlHelp =>
      'The webhook or topic URL. It must be https.';

  @override
  String get inboxChannelFormat => 'Format';

  @override
  String get inboxChannelFormatGeneric => 'Signed JSON';

  @override
  String get inboxChannelKinds => 'Kinds';

  @override
  String get inboxChannelAllKinds => 'Every kind';

  @override
  String get inboxChannelOff => 'Off';

  @override
  String get inboxChannelSecretTitle => 'Signing secret';

  @override
  String get inboxChannelSecretBody =>
      'tix signs every signed JSON message with this secret. Copy it now: it is not shown again.';

  @override
  String get inboxChannelSecretCopy => 'Copy';

  @override
  String get inboxChannelSecretDone => 'Done';

  @override
  String get inboxChannelAbout => 'Channel';

  @override
  String get inboxChannelActive => 'On';

  @override
  String get inboxChannelActiveHelp => 'Off, the channel receives nothing.';

  @override
  String get inboxChannelTest => 'Send test';

  @override
  String get inboxChannelTestQueued => 'Test message queued';

  @override
  String get inboxChannelDeliveries => 'Deliveries';

  @override
  String get inboxChannelDeliveriesSubtitle => 'Newest first.';

  @override
  String get inboxChannelNoDeliveries => 'Nothing delivered yet.';

  @override
  String get inboxChannelGone => 'This channel no longer exists.';

  @override
  String get inboxChannelDangerZone => 'Danger zone';

  @override
  String get inboxChannelDelete => 'Delete channel';

  @override
  String inboxChannelDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get inboxChannelDeleteBody =>
      'The channel and its delivery log are removed. This cannot be undone.';

  @override
  String inboxChannelDeleted(String name) {
    return 'Deleted $name';
  }

  @override
  String get inboxDeliveryDelivered => 'delivered';

  @override
  String get inboxDeliveryFailed => 'failed';

  @override
  String get inboxDeliveryPending => 'pending';

  @override
  String get inboxDeliveryTest => 'Test message';

  @override
  String get inboxDeliveryItem => 'Inbox item';

  @override
  String inboxDeliveryAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts',
      one: '1 attempt',
    );
    return '$_temp0';
  }

  @override
  String get inboxDeliveryRedeliver => 'Redeliver';

  @override
  String get inboxDeliveryRequeued => 'Queued again';

  @override
  String get liveUpdated => 'Updated';

  @override
  String get liveChangedElsewhere =>
      'This changed elsewhere. Your edits are kept.';

  @override
  String liveChangedElsewhereBy(String handle) {
    return '@$handle changed this. Your edits are kept.';
  }

  @override
  String get liveKeepEditing => 'Keep editing';

  @override
  String get liveReload => 'Reload';

  @override
  String get notifSettingsTitle => 'Notifications';

  @override
  String get notifSettingsSubtitle =>
      'On this device, inbox kinds and channels';

  @override
  String get notifDeviceTitle => 'On this device';

  @override
  String get notifDeviceSubtitle => 'For the active instance and tenant.';

  @override
  String get notifDeviceInfo =>
      'Shown while the app is open or was put away a moment ago. A closed app cannot be told: tix has no push service yet. Channels below deliver everywhere.';

  @override
  String get notifEnabled => 'Notify me about new inbox items';

  @override
  String get notifEnabledHelp => 'Tap a notification to open the task.';

  @override
  String get notifBlocked => 'Notifications are blocked for tix.';

  @override
  String get notifBlockedHelp =>
      'Allow notifications for tix in the system settings, then turn this on again.';

  @override
  String get notifNudge =>
      'Get a notification when something new reaches your inbox.';

  @override
  String get notifTurnOn => 'Turn on';

  @override
  String get notifNotNow => 'Not now';

  @override
  String notifMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more inbox items',
      one: '1 more inbox item',
    );
    return '$_temp0';
  }

  @override
  String get notifMoreBody => 'Open the inbox to see them.';

  @override
  String get themeOled => 'OLED black';

  @override
  String get themeSystemBlack => 'Pure black when dark';

  @override
  String get themeSystemBlackHelp =>
      'Uses OLED black whenever the system is dark. Saves battery on OLED screens.';

  @override
  String get goAbout => 'About tix';

  @override
  String get aboutTagline => 'The tix client for phones and desktops';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutIntro =>
      'tix-mobile is the app for tix, the open source task tracker. It works with any tix server, or runs tix on this device with no server at all. The server decides what happens to your work, so tasks behave exactly as they do in tix\'s web app and on the command line.';

  @override
  String get aboutVersions => 'Versions';

  @override
  String get aboutAppVersion => 'App';

  @override
  String get aboutEngineVersion => 'Embedded engine';

  @override
  String get aboutEngineNone => 'Not in this build';

  @override
  String get aboutServerVersion => 'Server';

  @override
  String get aboutServerNone => 'Not connected';

  @override
  String get aboutServerUnknown => 'Could not be read';

  @override
  String get aboutLinks => 'Links';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutSource => 'Source code';

  @override
  String get aboutSourceHelp =>
      'The complete source of this app, as the AGPL offers it';

  @override
  String get aboutRoadmap => 'Roadmap';

  @override
  String get aboutRoadmapHelp => 'What is planned next';

  @override
  String get aboutChangelog => 'Changelog';

  @override
  String get aboutChangelogHelp => 'What changed in each release';

  @override
  String get aboutServerProject => 'tix server';

  @override
  String get aboutServerProjectHelp =>
      'The server, the web app and the command line';

  @override
  String get aboutSecurity => 'Security policy';

  @override
  String get aboutSecurityHelp => 'How to report a vulnerability privately';

  @override
  String get aboutHelp => 'Something wrong?';

  @override
  String get aboutReportBug => 'Report a bug';

  @override
  String get aboutReportBugHelp =>
      'Opens a new GitHub issue with the versions above filled in. Never paste an API token.';

  @override
  String get aboutCopyDiagnostics => 'Copy diagnostics';

  @override
  String get aboutDiagnosticsCopied => 'Diagnostics copied.';

  @override
  String get aboutIncludeServer => 'Include the server address';

  @override
  String get aboutIncludeServerHelp =>
      'Off keeps a private server\'s address out of what you copy.';

  @override
  String get aboutLicence => 'Licence';

  @override
  String get aboutLicenceBody =>
      'tix-mobile is free software under the GNU AGPL, version 3 or later. Contributions are accepted under the project\'s contributor licence agreement (CLA).';

  @override
  String get aboutLicences => 'Licences';

  @override
  String get aboutLicencesHelp => 'The open source software inside this app';

  @override
  String get aboutOpenFailed => 'Could not open the link.';

  @override
  String get paletteThemeOled => 'OLED black theme';

  @override
  String get manageTitle => 'Manage';

  @override
  String manageSubtitle(String tenant) {
    return 'What you can manage in $tenant';
  }

  @override
  String get goManage => 'Go to Manage';

  @override
  String get navMore => 'More';

  @override
  String get manageEmpty => 'Nothing to manage with this credential.';

  @override
  String get manageEmptyBody =>
      'Projects, workflows, people and the tenant need scopes this token or role does not hold. Ask an admin for a wider one.';

  @override
  String get manageGroupProjects => 'Projects';

  @override
  String get manageGroupWorkflows => 'Workflows';

  @override
  String get manageGroupFields => 'Fields';

  @override
  String get manageGroupPeople => 'People';

  @override
  String get manageGroupAccess => 'Access';

  @override
  String get manageGroupTenant => 'Tenant';

  @override
  String get manageGroupServer => 'Server';

  @override
  String get manageProjectsSubtitle =>
      'Create, rename, recolour, archive and delete projects';

  @override
  String get manageWorkflowsSubtitle =>
      'States, the moves between them and who may make them';

  @override
  String get manageFieldsSubtitle =>
      'The custom fields each project\'s tasks carry';

  @override
  String get manageSave => 'Save';

  @override
  String get manageSaveChanges => 'Save changes';

  @override
  String get manageDelete => 'Delete';

  @override
  String get manageClear => 'Clear';

  @override
  String get manageYes => 'Yes';

  @override
  String get manageNo => 'No';

  @override
  String get manageDangerZone => 'Danger zone';

  @override
  String get manageInherited => 'Inherited';

  @override
  String get manageDurationHelp =>
      'A duration such as 30m or 4h. Empty inherits.';

  @override
  String get manageChanged => 'changed';

  @override
  String manageTaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String get manageDragToReorder => 'Drag to reorder';

  @override
  String get colourNone => 'No colour';

  @override
  String get colourSlate => 'Slate';

  @override
  String get colourRed => 'Red';

  @override
  String get colourAmber => 'Amber';

  @override
  String get colourGreen => 'Green';

  @override
  String get colourTeal => 'Teal';

  @override
  String get colourBlue => 'Blue';

  @override
  String get colourViolet => 'Violet';

  @override
  String get colourPink => 'Pink';

  @override
  String get colourCustom => 'Custom colour';

  @override
  String get iconNone => 'None';

  @override
  String get iconText => 'Emoji';

  @override
  String get iconBuiltin => 'Icon';

  @override
  String get iconImage => 'Image';

  @override
  String get iconNoneHelp => 'The first letters of the name stand in.';

  @override
  String get iconTextLabel => 'Emoji or letters';

  @override
  String get iconTextHelp => 'One emoji, or one or two letters.';

  @override
  String get iconImageHelp => 'PNG, JPEG, WebP or SVG, at most 64 KB.';

  @override
  String get iconUpload => 'Choose image';

  @override
  String get projectNew => 'New project';

  @override
  String get projectCreate => 'Create project';

  @override
  String projectCreated(String name) {
    return 'Created $name.';
  }

  @override
  String get projectName => 'Name';

  @override
  String get projectKey => 'Key';

  @override
  String get projectKeyHelp =>
      'Starts every task reference, such as infra-1. Letters, digits, - and _.';

  @override
  String get projectKeyChangeHelp =>
      'Changing it renames every task reference; the old key keeps working.';

  @override
  String get projectDescription => 'Description';

  @override
  String get projectWorkflow => 'Workflow';

  @override
  String get projectWorkflowInfo =>
      'The states this project\'s tasks move through. tix refuses a switch while a task sits in a state the new workflow lacks.';

  @override
  String get projectColour => 'Colour';

  @override
  String get projectIcon => 'Icon';

  @override
  String get projectSettingsTitle => 'Project settings';

  @override
  String get projectSectionProject => 'Project';

  @override
  String get projectSectionAppearance => 'Appearance';

  @override
  String get projectSectionClaims => 'Claims';

  @override
  String get projectClaimsInfo =>
      'How long a claim on this project\'s tasks holds. The project\'s value outranks the workflow\'s and the tenant\'s; the longest lease can only be lower than the tenant\'s.';

  @override
  String get projectLeaseDefault => 'Lease length';

  @override
  String get projectLeaseMax => 'Longest lease';

  @override
  String get projectLeaseMaxHelp =>
      'A duration such as 24h, below the tenant\'s ceiling. Empty inherits.';

  @override
  String get projectManageFields => 'Custom fields';

  @override
  String get projectManageFieldsHelp =>
      'Define the fields this project\'s tasks carry.';

  @override
  String get projectReadOnly =>
      'You can see these settings but not change them: that needs project:write.';

  @override
  String get projectSaved => 'Project saved.';

  @override
  String get projectRekeyTitle => 'Change the project key?';

  @override
  String get projectRekeyBody => 'Every task reference changes with the key:';

  @override
  String projectRekeyAlias(String old) {
    return 'Links, references and filters that use $old keep working: the old key stays as an alias, and no other project can take it.';
  }

  @override
  String get projectRekeyConfirm => 'Change key';

  @override
  String get projectArchive => 'Archive project';

  @override
  String get projectArchiveHelp =>
      'Hides it from lists and keeps its tasks and history. tix has no way to unarchive.';

  @override
  String projectArchiveTitle(String name) {
    return 'Archive $name?';
  }

  @override
  String get projectArchiveBody =>
      'The project leaves the default lists. Its tasks and history stay. tix cannot unarchive a project.';

  @override
  String projectArchived(String name) {
    return 'Archived $name.';
  }

  @override
  String get projectArchivedBadge => 'archived';

  @override
  String get projectIsArchived => 'This project is archived.';

  @override
  String get projectDelete => 'Delete project';

  @override
  String get projectDeleteHelp =>
      'Removes it permanently. Its tasks move to another project or go with it.';

  @override
  String projectDeleteTitle(String key) {
    return 'Delete $key?';
  }

  @override
  String get projectDeleteEmpty =>
      'The project holds no tasks. Deleting it cannot be undone.';

  @override
  String projectDeleteHolds(int live, int trashed) {
    String _temp0 = intl.Intl.pluralLogic(
      live,
      locale: localeName,
      other: '$live tasks',
      one: '1 task',
    );
    String _temp1 = intl.Intl.pluralLogic(
      trashed,
      locale: localeName,
      other: '$trashed in the trash',
      one: '1 in the trash',
    );
    return 'It holds $_temp0 and $_temp1. What happens to them?';
  }

  @override
  String get projectDeleteMove => 'Move them to another project';

  @override
  String get projectDeleteNoTarget =>
      'There is no other active project to move them to.';

  @override
  String get projectDeleteTarget => 'Move to';

  @override
  String get projectDeleteMapping => 'Status after the move';

  @override
  String get projectDeleteTasks => 'Delete them permanently';

  @override
  String projectDeleteType(String key) {
    return 'Type $key to confirm';
  }

  @override
  String get projectDeleteConfirm =>
      'The project and its tasks are deleted permanently.';

  @override
  String projectDeleteMoveConfirm(String target) {
    return 'The tasks move to $target, then the project is deleted permanently.';
  }

  @override
  String projectDeleted(String key) {
    return 'Deleted $key.';
  }

  @override
  String get fieldsTitle => 'Custom fields';

  @override
  String get fieldProjectsSubtitle =>
      'tix defines fields per project. Pick one.';

  @override
  String get fieldsEmpty => 'No custom fields yet.';

  @override
  String get fieldsEmptyBody =>
      'A field adds a value of your choosing to every task in the project, such as an environment or a customer.';

  @override
  String get fieldsReadOnly =>
      'You can see these fields but not change them: that needs project:write.';

  @override
  String get fieldNew => 'New field';

  @override
  String fieldEdit(String key) {
    return 'Edit $key';
  }

  @override
  String get fieldKey => 'Key';

  @override
  String get fieldKeyHelp =>
      'How tasks and filters name the field, such as env.';

  @override
  String get fieldKeyFixed =>
      'The key names the field; define a new field to change it.';

  @override
  String get fieldLabel => 'Label';

  @override
  String get fieldLabelHelp => 'What people see. Empty shows the key.';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldOptions => 'Options';

  @override
  String get fieldOptionsHelp => 'The allowed values, separated by commas.';

  @override
  String get fieldDefault => 'Default';

  @override
  String get fieldNoDefault => 'No default';

  @override
  String get fieldPickDefault => 'Pick a default';

  @override
  String get fieldActorHint => 'A handle, such as raj';

  @override
  String fieldDefaultIs(String value) {
    return 'default $value';
  }

  @override
  String get fieldDefaultUnreadable =>
      'This default cannot be read as the field\'s type.';

  @override
  String get fieldRequired => 'Required';

  @override
  String get fieldRequiredHelp =>
      'A new task without a value is refused, unless there is a default.';

  @override
  String fieldSaved(String key) {
    return 'Saved $key.';
  }

  @override
  String fieldDeleteTitle(String key) {
    return 'Delete the field $key?';
  }

  @override
  String get fieldDeleteBody => 'Tasks stop showing this field.';

  @override
  String fieldDeleted(String key) {
    return 'Deleted $key.';
  }

  @override
  String get fieldTypeString => 'Text, one line';

  @override
  String get fieldTypeText => 'Text, several lines';

  @override
  String get fieldTypeInt => 'Whole number';

  @override
  String get fieldTypeFloat => 'Number';

  @override
  String get fieldTypeBool => 'Yes or no';

  @override
  String get fieldTypeDate => 'Date';

  @override
  String get fieldTypeDatetime => 'Date and time';

  @override
  String get fieldTypeEnum => 'Choice';

  @override
  String get fieldTypeActor => 'Person or agent';

  @override
  String get fieldTypeJson => 'JSON';

  @override
  String get fieldTypeUnknown => 'Unknown';

  @override
  String get categoryTodo => 'To do';

  @override
  String get categoryInProgress => 'In progress';

  @override
  String get categoryBlocked => 'Blocked';

  @override
  String get categoryWaiting => 'Waiting';

  @override
  String get categoryDone => 'Done';

  @override
  String get categoryCancelled => 'Cancelled';

  @override
  String get categoryDerived => 'From the state (tix decides)';

  @override
  String get workflowsTitle => 'Workflows';

  @override
  String get workflowsSubtitle => 'The states tasks move through, and how';

  @override
  String get workflowsEmpty => 'No workflows.';

  @override
  String get workflowTitle => 'Workflow';

  @override
  String workflowSubtitle(String key) {
    return 'Key $key';
  }

  @override
  String get workflowBuiltin => 'builtin';

  @override
  String workflowStateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count states',
      one: '1 state',
    );
    return '$_temp0';
  }

  @override
  String get workflowNew => 'New workflow';

  @override
  String get workflowCreate => 'Create workflow';

  @override
  String workflowCreated(String name) {
    return 'Created $name.';
  }

  @override
  String get workflowKey => 'Key';

  @override
  String get workflowKeyHelp =>
      'Letters, digits, - and _, starting with a letter.';

  @override
  String get workflowKeyTaken =>
      'A workflow with this key exists; saving would replace it.';

  @override
  String get workflowName => 'Name';

  @override
  String get workflowStartFrom => 'Start from';

  @override
  String get workflowMinimal => 'Open and done';

  @override
  String workflowCopyOf(String name) {
    return 'A copy of $name';
  }

  @override
  String get workflowReadOnly =>
      'You can see this workflow but not change it: that needs workflow:write.';

  @override
  String get workflowRefused => 'tix refused the change';

  @override
  String get workflowSaved => 'Workflow saved.';

  @override
  String get workflowSectionGeneral => 'Workflow';

  @override
  String get workflowInitial => 'Initial state';

  @override
  String get workflowInitialHelp => 'Where a new task starts.';

  @override
  String get workflowDefaultLease => 'Lease length';

  @override
  String get workflowSectionStates => 'States';

  @override
  String get workflowStatesHelp =>
      'Drag the handle to reorder. Tap a state to edit it.';

  @override
  String get workflowAddState => 'Add state';

  @override
  String workflowEditState(String name) {
    return 'Edit $name';
  }

  @override
  String get workflowStateKey => 'Key';

  @override
  String get workflowStateKeyHelp =>
      'What a task\'s status holds, such as review.';

  @override
  String get workflowStateKeyRename =>
      'Renaming moves this state\'s tasks to the new key when you save.';

  @override
  String get workflowStateKeyTaken => 'Another state has this key.';

  @override
  String get workflowStateLabel => 'Label';

  @override
  String get workflowStateCategory => 'Category';

  @override
  String get workflowStateCategoryInfo =>
      'Groups the state for colours, boards and reports. Left to tix: done when terminal, to do for the initial state, in progress otherwise.';

  @override
  String get workflowStateInitial => 'Initial state';

  @override
  String get workflowTerminal => 'Terminal';

  @override
  String get workflowTerminalHelp =>
      'Reaching it completes the task and satisfies what depends on it.';

  @override
  String get workflowRevert => 'Revert when a claim runs out';

  @override
  String get workflowRevertHelp =>
      'A claimed task here goes back when its lease expires.';

  @override
  String get workflowRevertTo => 'Go back to';

  @override
  String workflowRevertsTo(String state) {
    return 'reverts to $state';
  }

  @override
  String get workflowInitialBadge => 'initial';

  @override
  String get workflowSectionTransitions => 'Transitions';

  @override
  String get workflowTransitionsHelp =>
      'Tap a state to allow the move. The rules button on a chosen move asks for a comment or a scope.';

  @override
  String workflowCanMoveTo(String name) {
    return 'From $name, a task can move to';
  }

  @override
  String get workflowNoMoves => 'No move leaves this state.';

  @override
  String get workflowMoveRules => 'Rules for this move';

  @override
  String workflowRulesTitle(String from, String to) {
    return '$from to $to';
  }

  @override
  String get workflowNeedsComment => 'Needs a comment';

  @override
  String get workflowNeedsCommentHelp =>
      'The move is refused unless it carries a comment.';

  @override
  String workflowNeedsScope(String scope) {
    return 'Needs $scope';
  }

  @override
  String get workflowRequiredScope => 'Required scope';

  @override
  String get workflowRequiredScopeHelp =>
      'Only someone holding it may make this move.';

  @override
  String get workflowNoScope => 'None';

  @override
  String get workflowSectionRoutes => 'Routes';

  @override
  String get workflowRoutesInfo =>
      'How many moves each state is from the initial one. A move to a state further away passes through the states between, one transition at a time.';

  @override
  String workflowSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get workflowUnreachable => 'No route reaches it';

  @override
  String get workflowSectionRemoved => 'Removed states';

  @override
  String get workflowRemovedHelp =>
      'Tasks still in a removed state need somewhere to go, or tix refuses the save.';

  @override
  String workflowMigrate(String state) {
    return 'Move tasks in $state to';
  }

  @override
  String get workflowMigrateNone => 'Nowhere (refused if it holds tasks)';

  @override
  String get workflowDelete => 'Delete workflow';

  @override
  String get workflowDeleteHelp =>
      'Only a workflow no project uses can be deleted.';

  @override
  String workflowDeleteTitle(String key) {
    return 'Delete $key?';
  }

  @override
  String get workflowDeleteBody => 'The workflow is deleted permanently.';

  @override
  String workflowDeleted(String key) {
    return 'Deleted $key.';
  }

  @override
  String get manageUsersTitle => 'Users';

  @override
  String get manageUsersSubtitle =>
      'People in the tenant, their roles and invites';

  @override
  String get manageTokensTitle => 'API tokens';

  @override
  String get manageTokensSubtitle =>
      'Tokens for agents and scripts, and what each may do';

  @override
  String get manageTransferTitle => 'Import and export';

  @override
  String get manageTransferSubtitle =>
      'Move tasks and whole tenants in and out';

  @override
  String get localInstanceAdvancedBody =>
      'Use a database where it is, for example in a folder that Nextcloud, Syncthing or iCloud Drive keeps in sync, instead of a copy kept inside the app.';

  @override
  String get localInstanceAdvancedTitle => 'Advanced: open in place';

  @override
  String get localInstanceBrowseCreate => 'Create here';

  @override
  String get localInstanceBrowseEmpty => 'No folders or databases here.';

  @override
  String get localInstanceBrowseNewLabel => 'New database in this folder';

  @override
  String get localInstanceBrowseTitle => 'Choose a database';

  @override
  String get localInstanceBrowseUp => 'Up';

  @override
  String localInstanceConflicts(String names) {
    return 'Sync conflict copies next to this file: $names. Check which one holds your latest work before you go on.';
  }

  @override
  String get localInstanceDesktopIntro =>
      'Create a new tix database. To use one you already have, open it in place below.';

  @override
  String get localInstanceEngineResting => 'Stopped, starts again when needed';

  @override
  String localInstanceEngineRunning(String address) {
    return 'Running at $address';
  }

  @override
  String get localInstanceEngineStarting => 'Starting';

  @override
  String get localInstanceEngineStop => 'Stop';

  @override
  String get localInstanceEngineStopped => 'Stopped';

  @override
  String get localInstanceErrorAccess =>
      'tix can no longer reach this file. Allow access again, or remove the instance and open the file again.';

  @override
  String get localInstanceErrorFolder =>
      'tix cannot create files in this folder, and SQLite needs to keep two files beside the database. Pick a folder you can write to.';

  @override
  String get localInstanceErrorLock =>
      'This file cannot be locked, so SQLite cannot keep it safe here. It may be on a cloud provider that does not offer real files.';

  @override
  String get localInstanceErrorNotDatabase =>
      'This file is not a tix database on this device. If it is in a cloud folder, it may not be downloaded yet.';

  @override
  String get localInstanceErrorNotDownloaded =>
      'This file is not downloaded to this device yet. Open it in the Files app to download it, then try again.';

  @override
  String get localInstanceIdleHelp =>
      'An engine that has served nothing for this long stops to save battery, and starts again the next time the app needs it.';

  @override
  String get localInstanceIdleLabel => 'Stop an idle engine after';

  @override
  String localInstanceIdleMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get localInstanceIdleNever => 'Never';

  @override
  String get localInstanceIdleTitle => 'Local databases';

  @override
  String get localInstanceImportInstead => 'Import a copy';

  @override
  String get localInstanceInPlaceNote => 'Used in place';

  @override
  String get localInstanceOpenInPlace => 'Open in place…';

  @override
  String get localInstancePermissionBody =>
      'To open a database where it is, Android has to give tix \"All files access\". tix reads and writes only the database you pick and the files SQLite keeps beside it.';

  @override
  String get localInstancePermissionContinue => 'Continue';

  @override
  String get localInstancePermissionRefused =>
      'All files access was not granted, so tix cannot open files in place. You can import a copy instead.';

  @override
  String get localInstancePermissionTitle => 'Allow access to your files';

  @override
  String get localInstanceSyncWarning =>
      'A synced database must be open on one device at a time. Close tix on your other devices and let the sync finish first. tix stops the database whenever it goes to the background, so the sync client always finds a whole file.';

  @override
  String get localInstanceWalLeftOver =>
      'A write-ahead log was already beside this file. Another program may have it open, or a sync client copied one from another device.';

  @override
  String get widgetMyWork => 'My work';

  @override
  String get widgetInbox => 'Inbox';

  @override
  String get widgetQuickAdd => 'Quick add';

  @override
  String get widgetAddTask => 'Add a task';

  @override
  String get widgetNothingDue => 'Nothing assigned to you';

  @override
  String get widgetAllRead => 'All caught up';

  @override
  String get widgetNoOpenTasks => 'No open tasks';

  @override
  String get widgetUpdated => 'Updated';

  @override
  String get widgetOpenApp => 'Open tix to load this widget';

  @override
  String get widgetLocalStale => 'Refreshes when tix is open';

  @override
  String get widgetOverdue => 'Overdue';

  @override
  String get widgetToday => 'Today';

  @override
  String get widgetComplete => 'Complete';

  @override
  String get widgetProjectMissing => 'Not in this context';

  @override
  String get widgetSignedOut => 'Sign in to tix';

  @override
  String widgetMore(int count) {
    return '+$count more';
  }

  @override
  String widgetUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread',
      one: '1 unread',
      zero: 'Nothing unread',
    );
    return '$_temp0';
  }

  @override
  String get settingsWidgets => 'Home screen widgets';

  @override
  String get settingsWidgetLockCounts => 'Counts only on the lock screen';

  @override
  String get settingsWidgetLockCountsHelp =>
      'Widgets on the lock screen say how many, not what.';

  @override
  String get settingsWidgetsHelp =>
      'Add tix widgets from your home screen. They show what the app last read, and a tick waits for the app if it cannot reach the server.';

  @override
  String get widgetOpenUpdate => 'Open tix to update';

  @override
  String get widgetPickProject => 'Pick a project';

  @override
  String liveStatusLabel(String state) {
    return 'Live updates: $state';
  }

  @override
  String get liveStatusLive => 'Live';

  @override
  String get liveStatusLiveInfo =>
      'Changes made elsewhere show up here as they happen.';

  @override
  String get liveStatusConnecting => 'Connecting';

  @override
  String get liveStatusConnectingInfo =>
      'Connecting to live updates. Changes show up once it is through.';

  @override
  String get liveStatusPolling => 'Polling';

  @override
  String get liveStatusPollingInfo =>
      'The live connection keeps failing on this network, so updates come over plain HTTP instead. They can take a few seconds longer.';

  @override
  String get liveStatusRefreshing => 'Refreshing';

  @override
  String liveStatusRefreshingInfo(int seconds) {
    return 'Live updates do not get through and this server is too old to poll, so the screen reloads every $seconds seconds.';
  }

  @override
  String get liveStatusOffline => 'Offline';

  @override
  String get liveStatusOfflineInfo =>
      'The server cannot be reached. The app keeps trying and catches up when it is back.';

  @override
  String get liveStatusUnavailable => 'Not available';

  @override
  String get liveStatusUnavailableInfo =>
      'This connection may not follow live updates (it needs the event:subscribe scope). Pull down to refresh instead.';

  @override
  String get copyToClipboard => 'Copy';

  @override
  String get copiedToClipboard => 'Copied.';

  @override
  String get secretShare => 'Share';

  @override
  String get secretDone => 'I have kept it';

  @override
  String get roleViewer => 'viewer';

  @override
  String get roleMember => 'member';

  @override
  String get roleAdmin => 'admin';

  @override
  String get roleViewerHelp => 'Reads tasks, projects and workflows.';

  @override
  String get roleMemberHelp =>
      'Also creates, edits, claims and moves tasks, comments and exports.';

  @override
  String get roleAdminHelp => 'May do everything in this tenant.';

  @override
  String get peopleTitle => 'Users';

  @override
  String get peopleAdd => 'Add user';

  @override
  String peopleActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active',
      one: '1 active',
    );
    return '$_temp0';
  }

  @override
  String peopleDisabledCount(int count) {
    return '$count disabled';
  }

  @override
  String get peopleAddMember => 'Add a member';

  @override
  String get peopleAddMemberButton => 'Add member';

  @override
  String get peopleAddMemberHelp =>
      'Give an existing agent or account a role in this tenant.';

  @override
  String get peopleNoActors => 'Every actor already belongs to this tenant.';

  @override
  String get peopleAgent => 'agent';

  @override
  String get peoplePerson => 'person';

  @override
  String get peopleEmpty => 'No users yet.';

  @override
  String get peopleYou => 'you';

  @override
  String get peopleNoRole => 'no role';

  @override
  String get peopleDisabled => 'disabled';

  @override
  String get peopleInvites => 'Pending invites';

  @override
  String get peopleInvitesInfo =>
      'Links issued and not used yet. Re-issuing stops the old link and gives you a new one to send; revoking stops it.';

  @override
  String get peopleInvited => 'invited';

  @override
  String peopleInvitedBy(String handle) {
    return 'invited by $handle';
  }

  @override
  String get peopleInviteExpired => 'expired';

  @override
  String peopleInviteExpires(String day) {
    return 'expires $day';
  }

  @override
  String get peopleReissue => 'Re-issue';

  @override
  String get peopleRevoke => 'Revoke';

  @override
  String peopleRevokeInviteTitle(String email) {
    return 'Revoke the invite for $email?';
  }

  @override
  String get peopleRevokeInviteBody =>
      'The link stops working at once. The account stays, without a password, until you delete it or invite it again.';

  @override
  String peopleInviteRevoked(String email) {
    return 'Invite for $email revoked';
  }

  @override
  String get peopleSignInMode => 'How they sign in';

  @override
  String get peopleSignInModeInfo =>
      'An invite link lets the person choose their own password. It works once and expires; tix sends no email, so you pass the link on yourself.';

  @override
  String get peopleModeInvite => 'Invite link';

  @override
  String get peopleModePassword => 'Set a password';

  @override
  String get peopleDisplayName => 'Display name';

  @override
  String get peopleDisplayNameHelp => 'Empty shows the email instead.';

  @override
  String get peopleRole => 'Role';

  @override
  String get peopleLinkExpires => 'Link expires after';

  @override
  String peopleDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get peopleYear => '1 year';

  @override
  String get peopleInviteHelp =>
      'You get a link to send them. It works once, and they choose their own password with it.';

  @override
  String get peopleRequireChangeFirst =>
      'Require a password change at first sign-in';

  @override
  String get peopleCreateInvite => 'Create invite link';

  @override
  String get peopleCreateUser => 'Create user';

  @override
  String peopleCreated(String email) {
    return 'Created $email';
  }

  @override
  String get peopleInviteLink => 'Invite link';

  @override
  String peopleSendLink(String email) {
    return 'Send this link to $email';
  }

  @override
  String get peopleLinkOnce =>
      'It works once. tix does not send email, and the link is not shown again.';

  @override
  String peopleLinkOnceUntil(String day) {
    return 'It works once and expires on $day. tix does not send email, and the link is not shown again.';
  }

  @override
  String get peopleRename => 'Change display name';

  @override
  String get peopleNoName => 'Not set';

  @override
  String get peopleChangeRole => 'Change role';

  @override
  String get peopleSignIn => 'Signs in with';

  @override
  String peopleSso(String provider) {
    return 'Single sign-on ($provider)';
  }

  @override
  String get peoplePasswordSignIn => 'A password';

  @override
  String get peopleSecondFactor => 'Second factor';

  @override
  String get peopleTotpOn => 'Enrolled';

  @override
  String get peopleTotpOff => 'None';

  @override
  String get peopleCreatedAt => 'Created';

  @override
  String get peopleAccess => 'Access';

  @override
  String get peopleDisabledSwitch => 'Disabled';

  @override
  String get peopleDisabledHelp =>
      'A disabled account cannot sign in: its sessions end and its API tokens are revoked at once. Turning it back on does not bring the tokens back.';

  @override
  String peopleDisabledToast(String name) {
    return '$name disabled';
  }

  @override
  String peopleEnabledToast(String name) {
    return '$name can sign in again';
  }

  @override
  String get peopleRequireChange =>
      'Ask to change the password at next sign-in';

  @override
  String get peopleRequireChangeHelp =>
      'Their next sign-in with a password stops at a page asking for a new one. Open sessions and API tokens are not affected.';

  @override
  String get peopleSaved => 'Saved';

  @override
  String get peopleSave => 'Save';

  @override
  String peopleRoleChanged(String name, String role) {
    return '$name is now $role';
  }

  @override
  String get peopleDangerZone => 'Danger zone';

  @override
  String get peopleRemoveMember => 'Remove from this tenant';

  @override
  String get peopleRemoveMemberHelp =>
      'Ends the membership and keeps the account.';

  @override
  String get peopleRemoveMemberButton => 'Remove';

  @override
  String peopleRemoveMemberTitle(String name) {
    return 'Remove $name from this tenant?';
  }

  @override
  String get peopleRemoveMemberBody =>
      'They stop acting here at once. The account stays and can be given a role again.';

  @override
  String peopleMemberRemoved(String name) {
    return '$name removed from this tenant';
  }

  @override
  String peopleDelete(String name) {
    return 'Delete $name';
  }

  @override
  String get peopleDeleteHelp =>
      'Deleting removes the account and its membership. Disabling is usually what you want, and can be undone.';

  @override
  String get peopleDeleteButton => 'Delete';

  @override
  String peopleDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get peopleDeleteBody =>
      'Deleting removes the account and its membership. It cannot be undone.';

  @override
  String peopleDeleted(String name) {
    return '$name deleted';
  }

  @override
  String get tokensTitle => 'API tokens';

  @override
  String get tokensMine => 'My API tokens';

  @override
  String get tokensIssue => 'Issue a token';

  @override
  String get tokensIssueButton => 'Issue token';

  @override
  String get tokensWholeTenant => 'Every token of this tenant';

  @override
  String get tokensOwn => 'Your tokens';

  @override
  String get tokensWholeNote =>
      'You hold tenant:admin, so this lists every token of the tenant and whose it is. Revoking somebody else\'s is recorded as such.';

  @override
  String get tokensIntro =>
      'A token is the credential a script, the CLI or an agent presents instead of signing in. It carries its own scopes, and its value is shown once, when it is issued.';

  @override
  String get tokensEmpty => 'No tokens.';

  @override
  String get tokensActive => 'active';

  @override
  String get tokensExpired => 'expired';

  @override
  String get tokensRevoked => 'revoked';

  @override
  String get tokensRevoke => 'Revoke';

  @override
  String tokensOwner(String name) {
    return 'Owner: $name';
  }

  @override
  String tokensOwnerYou(String name) {
    return 'Owner: $name (you)';
  }

  @override
  String tokensCreated(String day) {
    return 'Created $day';
  }

  @override
  String tokensExpires(String day) {
    return 'Expires $day';
  }

  @override
  String get tokensNeverExpires => 'Never expires';

  @override
  String get tokensNotUsed => 'Not used yet';

  @override
  String tokensLastUsed(String when) {
    return 'Last used $when';
  }

  @override
  String tokensRevokeTitle(String name) {
    return 'Revoke $name?';
  }

  @override
  String get tokensRevokeBody =>
      'Whatever holds this token stops authenticating at once. It cannot be undone, and the value cannot be recovered.';

  @override
  String tokensRevokeOther(String name) {
    return 'This token is $name\'s, not yours, and the trail will record that you ended somebody else\'s.';
  }

  @override
  String tokensRevokeNamed(String name) {
    return 'Revoke $name';
  }

  @override
  String tokensRevokedToast(String name) {
    return '$name revoked';
  }

  @override
  String get tokensName => 'Name';

  @override
  String get tokensNameHelp =>
      'What you will choose by when you revoke it, such as ci or laptop. No two live tokens share a name.';

  @override
  String get tokensScopes => 'Scopes';

  @override
  String get tokensNotHeld =>
      'You do not hold this scope, so you cannot grant it.';

  @override
  String get tokensPresetAgent => 'Agent';

  @override
  String get tokensPresetAgentNote =>
      'Read, create and edit tasks, claim them, move them and comment.';

  @override
  String get tokensPresetRead => 'Read only';

  @override
  String get tokensPresetReadNote =>
      'Read tasks, projects and workflows, and follow the event stream.';

  @override
  String get tokensExpiry => 'Expires';

  @override
  String get tokensExpiryInfo =>
      'An expiry is the one control that limits the damage of a token that leaks without anybody noticing. Prefer the shortest window the work fits in.';

  @override
  String get tokensNever => 'Never';

  @override
  String tokensIssuedTitle(String name) {
    return 'Token $name issued';
  }

  @override
  String get tokensValue => 'Copy this token now';

  @override
  String get tokensValueWarning =>
      'Keep it somewhere safe. It is not shown again, and nothing can show it later.';

  @override
  String get scopeAll =>
      'Everything but global admin and account history. Only for a credential you trust like yourself.';

  @override
  String get scopeGroupTasks => 'Tasks';

  @override
  String get scopeGroupProjects => 'Projects';

  @override
  String get scopeGroupWorkflows => 'Workflows';

  @override
  String get scopeGroupComments => 'Comments and artifacts';

  @override
  String get scopeGroupEvents => 'Events';

  @override
  String get scopeGroupAdmin => 'Administration';

  @override
  String get scopeGroupAccount => 'Your account';

  @override
  String get scopeTaskRead => 'Read tasks, their comments and history.';

  @override
  String get scopeTaskWrite => 'Create and edit tasks.';

  @override
  String get scopeTaskTransition => 'Move a task from one state to another.';

  @override
  String get scopeTaskClaim => 'Claim tasks, renew the lease and release it.';

  @override
  String get scopeTaskDelete => 'Delete tasks and restore them from the trash.';

  @override
  String get scopeTaskReclaim => 'End a lease another worker holds.';

  @override
  String get scopeProjectRead => 'Read projects.';

  @override
  String get scopeProjectWrite => 'Create and change projects.';

  @override
  String get scopeWorkflowRead => 'Read workflows.';

  @override
  String get scopeWorkflowWrite => 'Create and change workflows.';

  @override
  String get scopeCommentWrite => 'Comment on tasks.';

  @override
  String get scopeArtifactWrite => 'Attach artifacts to tasks.';

  @override
  String get scopeEventSubscribe => 'Follow the live event stream.';

  @override
  String get scopeUserAdmin => 'Create, change and remove users.';

  @override
  String get scopeTotpAdmin => 'Clear another person\'s second factor.';

  @override
  String get scopeTokenAdmin => 'Issue and revoke API tokens.';

  @override
  String get scopeWebhookAdmin => 'Manage outgoing webhooks.';

  @override
  String get scopeTenantAdmin => 'Manage the tenant, its members and domains.';

  @override
  String get scopeSyncAdmin => 'Manage and run imports from other trackers.';

  @override
  String get scopeAuditRead => 'Read the audit log.';

  @override
  String get scopeExport => 'Export tasks and a snapshot of the whole tenant.';

  @override
  String get scopeImport => 'Import tasks and snapshots into the tenant.';

  @override
  String get scopeGlobalAdmin =>
      'Administer every tenant on this server. Only a global admin\'s token can carry it.';

  @override
  String get scopeAccountRead =>
      'Read your own account\'s history, which names every tenant you belong to. Only a token for your own account can carry it.';

  @override
  String get accountTitle => 'Your account';

  @override
  String get accountKind => 'Signed in as';

  @override
  String get accountKindToken => 'An API token';

  @override
  String get accountKindAgent => 'An agent';

  @override
  String get accountKindPerson => 'A person';

  @override
  String get accountGlobalAdmin => 'global admin';

  @override
  String get accountGlobalAdminYes => 'Administers every tenant of this server';

  @override
  String get accountMemberships => 'Your tenants';

  @override
  String get accountMembershipsHelp =>
      'Every tenant this account belongs to, with its role there.';

  @override
  String get accountCurrent => 'current';

  @override
  String get accountHistory => 'Account history';

  @override
  String get accountHistoryHelp =>
      'Every change to your password, second factor and memberships, in every tenant. Only you and global admins can read this.';

  @override
  String get accountHistoryEmpty => 'Nothing has changed yet.';

  @override
  String get accountHistoryNotReadable =>
      'This token cannot read your account\'s history: it needs the account:read scope, which only a token minted for your own account carries.';

  @override
  String accountBy(String email) {
    return 'by $email';
  }

  @override
  String get accountBySystem => 'by the system';

  @override
  String get calendarTitle => 'Calendar feed';

  @override
  String get calendarLead =>
      'Your due dates in Google, Apple or Outlook calendar';

  @override
  String get calendarUnavailable => 'Nothing to manage here';

  @override
  String get calendarUnavailableBody =>
      'A calendar feed reads tasks as you, and this credential cannot read tasks.';

  @override
  String get calendarCreate => 'Create feed';

  @override
  String get calendarNone => 'No calendar feed';

  @override
  String get calendarNoneBody =>
      'A private address your calendar subscribes to, so your due dates appear beside the rest of your week.';

  @override
  String get calendarFeed => 'Feed address';

  @override
  String get calendarFeedInfo =>
      'Each task with a due date is an all-day event that links back here. Anybody holding the address can read what it lists, so treat it like a password. Only a hash of it is kept, so it cannot be shown again.';

  @override
  String get calendarActive => 'Active';

  @override
  String calendarCreatedOn(String day) {
    return 'Created $day. The address was shown once; rotate to get a new one.';
  }

  @override
  String get calendarShownOnce =>
      'The address was shown once; rotate to get a new one.';

  @override
  String get calendarFilter => 'Feed filter';

  @override
  String get calendarFilterDefault =>
      'The tasks assigned to you that are not finished';

  @override
  String get calendarFilterHint => 'project:infra tag:ops';

  @override
  String get calendarFilterHelp =>
      'The task list\'s filter language. Empty means yours, not finished. Only tasks with a due date are listed.';

  @override
  String get calendarEditFilter => 'Change filter';

  @override
  String get calendarSaveFilter => 'Save filter';

  @override
  String get calendarFilterSaved => 'Feed filter saved';

  @override
  String get calendarRotate => 'Rotate the address';

  @override
  String get calendarRotateHelp =>
      'A new address with the same filter; the old one stops at once.';

  @override
  String get calendarRotateButton => 'Rotate';

  @override
  String get calendarRevoke => 'Revoke the feed';

  @override
  String get calendarRevokeHelp =>
      'The address stops answering. Subscribed calendars keep what they last fetched.';

  @override
  String get calendarRevokeButton => 'Revoke';

  @override
  String get calendarRevokeTitle => 'Revoke the calendar feed?';

  @override
  String get calendarRevokeBody =>
      'The address stops at once. Remove the subscription from your calendar app too.';

  @override
  String get calendarRevoked => 'Calendar feed revoked';

  @override
  String get calendarAddress => 'Subscribe to this address';

  @override
  String get calendarOnce =>
      'Add it in your calendar app. It is not shown again, so copy it now.';

  @override
  String get calendarRotatedOnce =>
      'This address replaces the old one, which has stopped. Subscribe to it again wherever the old one was used. It is not shown again.';

  @override
  String calendarLists(String filter) {
    return 'Lists: $filter';
  }

  @override
  String get calendarListsDefault =>
      'Lists the tasks assigned to you that are not finished.';

  @override
  String get calendarHowGoogle =>
      'Google Calendar: Other calendars, then From URL, and paste the address.';

  @override
  String get calendarHowApple =>
      'Apple Calendar: File, then New Calendar Subscription, or use Subscribe on this device.';

  @override
  String get calendarHowOutlook =>
      'Outlook: Add calendar, then Subscribe from web, and paste the address.';

  @override
  String get calendarSubscribeHere => 'Subscribe on this device';

  @override
  String get transferTitle => 'Export and import';

  @override
  String get transferNoProjects =>
      'Create a project before exporting or importing tasks.';

  @override
  String get transferExportTitle => 'Export tasks';

  @override
  String get transferExportHelp =>
      'One project\'s tasks, or the ones a filter picks, as a file.';

  @override
  String get transferQuery => 'Filter';

  @override
  String get transferQueryHelp =>
      'The task list\'s filter language. Empty exports every task.';

  @override
  String get transferFormat => 'Format';

  @override
  String get transferFormatCsv => 'CSV, for spreadsheets';

  @override
  String get transferFormatNdjson => 'NDJSON, one task per line';

  @override
  String get transferFormatMarkdown => 'Markdown table';

  @override
  String get transferColumns => 'Columns';

  @override
  String get transferDates => 'Dates';

  @override
  String get transferDatesIso => 'Date and time (ISO)';

  @override
  String get transferDatesDay => 'Day only';

  @override
  String get transferDelimiter => 'Delimiter';

  @override
  String get transferDelimiterComma => 'Comma';

  @override
  String get transferDelimiterSemicolon => 'Semicolon';

  @override
  String get transferDelimiterTab => 'Tab';

  @override
  String get transferDelimiterBar => 'Vertical bar';

  @override
  String get transferFinished => 'Include finished tasks';

  @override
  String get transferSubtasks => 'Include subtasks';

  @override
  String get transferTrashed => 'Include tasks in the trash';

  @override
  String get transferExportButton => 'Export';

  @override
  String transferExported(String name) {
    return 'Saved $name';
  }

  @override
  String get transferSnapshotTitle => 'Snapshot';

  @override
  String get transferSnapshotHelp =>
      'Everything in this tenant as one NDJSON file, which tix can import elsewhere.';

  @override
  String get transferSnapshotComments => 'Include comments';

  @override
  String get transferSnapshotButton => 'Export snapshot';

  @override
  String get transferImportTitle => 'Import tasks';

  @override
  String get transferImportHelp =>
      'A CSV, JSON or NDJSON file of tasks, including files Jira, GitHub, Trello and Linear write. You see what would happen before anything changes.';

  @override
  String get transferPick => 'Choose a file';

  @override
  String transferDryRun(
    int rows,
    int created,
    int updated,
    int skipped,
    int failed,
  ) {
    return '$rows rows: $created to create, $updated to update, $skipped skipped, $failed failed.';
  }

  @override
  String transferImportError(int line, String message) {
    return 'Line $line: $message';
  }

  @override
  String transferImportButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count tasks',
      one: 'Import 1 task',
    );
    return '$_temp0';
  }

  @override
  String transferImported(int created, int updated) {
    return 'Imported: $created created, $updated updated';
  }

  @override
  String get columnRef => 'Reference';

  @override
  String get columnTitle => 'Title';

  @override
  String get columnParent => 'Parent';

  @override
  String get columnDependsOn => 'Depends on';

  @override
  String get columnRepeat => 'Repeat';

  @override
  String get columnCreated => 'Created';

  @override
  String get columnUpdated => 'Updated';

  @override
  String get columnStarted => 'Started';

  @override
  String get columnCompleted => 'Completed';

  @override
  String get columnDeleted => 'Deleted';

  @override
  String get columnCreator => 'Creator';

  @override
  String get columnProject => 'Project';

  @override
  String get columnId => 'Identifier';

  @override
  String get columnComments => 'Comments';

  @override
  String get columnHistory => 'History';

  @override
  String get settingsAccountHelp => 'Profile, tenants and history';

  @override
  String get settingsCalendarHelp => 'Your due dates in your calendar app';

  @override
  String get settingsTokensHelp =>
      'Credentials for scripts, the CLI and agents';

  @override
  String get securityTitle => 'Security';

  @override
  String get securitySubtitle => 'Your second factor and SSH keys';

  @override
  String get totpTitle => 'Second factor';

  @override
  String get totpInfo =>
      'A code from an authenticator app, asked for after your password. Recovery codes let you in when the app is not at hand.';

  @override
  String get totpOn => 'On';

  @override
  String get totpOff => 'Off';

  @override
  String get totpPending => 'Not confirmed';

  @override
  String totpSince(String date) {
    return 'Since $date';
  }

  @override
  String get totpOnBody =>
      'Signing in asks for a code from your authenticator app after your password.';

  @override
  String get totpOffBody => 'Signing in asks only for your password.';

  @override
  String get totpPendingBody =>
      'Setup was started but never confirmed with a code. Set it up again to finish.';

  @override
  String totpRequiredOn(String surfaces) {
    return 'Your tenant requires a second factor for: $surfaces.';
  }

  @override
  String get totpSurfaceWeb => 'the browser';

  @override
  String get totpSurfaceCli => 'the command line';

  @override
  String get totpSurfaceSsh => 'SSH';

  @override
  String totpCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recovery codes left',
      one: '1 recovery code left',
      zero: 'No recovery codes left',
    );
    return '$_temp0';
  }

  @override
  String totpLocked(String time) {
    return 'Too many wrong codes. Codes are refused until $time.';
  }

  @override
  String get totpSetUp => 'Set up';

  @override
  String get totpNewCodes => 'New recovery codes';

  @override
  String get totpNewCodesBody =>
      'Your current recovery codes stop working at once, used or not, and a new set is shown once.';

  @override
  String get totpNewCodesConfirm => 'Replace codes';

  @override
  String get totpRemove => 'Remove second factor';

  @override
  String get totpRemoveBody =>
      'Signing in will ask only for your password, and your recovery codes stop working. If your tenant requires a second factor, you will be asked to set one up again.';

  @override
  String get totpRemoved => 'Second factor removed.';

  @override
  String get totpCodesHeading => 'Save these recovery codes now';

  @override
  String get totpCodesNote =>
      'Each one signs you in once without your authenticator. They are shown once and cannot be read again; if you lose them, make a new set.';

  @override
  String get totpCodesSaved => 'I have saved them';

  @override
  String get totpConfirm => 'Confirm';

  @override
  String get totpStep1 =>
      '1. Add this key to your authenticator app, or open it there from this device.';

  @override
  String get totpSecretHeading => 'Your authenticator key';

  @override
  String totpSecretNote(String account, String issuer) {
    return 'Account $account at $issuer. Keep it private: anyone holding it can make your codes.';
  }

  @override
  String get totpOpenApp => 'Open in authenticator app';

  @override
  String get totpStep2 => '2. Enter the six-digit code the app shows.';

  @override
  String get sshKeysTitle => 'SSH keys';

  @override
  String get sshKeysInfo =>
      'A key enrolled here signs you in to tix\'s terminal interface over SSH, in this tenant. Revoked keys stay listed so you can tell why one stopped working.';

  @override
  String get sshKeysEmpty => 'No SSH keys yet.';

  @override
  String get sshKeyAdd => 'Add SSH key';

  @override
  String get sshKeyAddSubmit => 'Add key';

  @override
  String get sshKeyAdded => 'SSH key added.';

  @override
  String get sshKeyUnlabelled => 'Unlabelled key';

  @override
  String get sshKeyRevoked => 'Revoked';

  @override
  String sshKeyAddedOn(String date) {
    return 'Added $date';
  }

  @override
  String sshKeyLastUsed(String date) {
    return 'Last used $date';
  }

  @override
  String get sshKeyNeverUsed => 'Never used';

  @override
  String sshKeyRevokedOn(String date) {
    return 'Revoked $date';
  }

  @override
  String get sshKeyRevoke => 'Revoke';

  @override
  String sshKeyRevokeBody(String name) {
    return '$name stops signing in over SSH at once. This cannot be undone; enrol the key again to use it.';
  }

  @override
  String get sshKeyRevokedToast => 'SSH key revoked.';

  @override
  String get sshKeyPublicKey => 'Public key';

  @override
  String get sshKeyPublicKeyHelp =>
      'The line from your .pub file, as ssh-keygen writes it.';

  @override
  String get sshKeyLabel => 'Label (optional)';

  @override
  String get sshKeyLabelHelp =>
      'Tells this key from your others, such as the machine it lives on.';

  @override
  String get sshKeyAllTenants => 'Every tenant I belong to';

  @override
  String get sshKeyAllTenantsHelp =>
      'Enrols the key in each of your tenants, not only this one.';

  @override
  String get tenantSettingsTitle => 'Tenant settings';

  @override
  String get tenantSaved => 'Saved.';

  @override
  String get tenantGeneralTitle => 'General';

  @override
  String get tenantName => 'Name';

  @override
  String get tenantKey => 'Key';

  @override
  String get tenantKeyHelp =>
      'Short and unique: letters, digits, hyphens and underscores, starting with a letter. It cannot change later.';

  @override
  String get tenantTimezone => 'Time zone';

  @override
  String get tenantTimezoneHelp =>
      'An IANA zone people read dates in unless they chose their own. Empty uses the server\'s.';

  @override
  String get tenantTimeFormat => 'Date format';

  @override
  String get tenantServerDefault => 'Server default';

  @override
  String get tenantThemeTitle => 'Theme';

  @override
  String get tenantThemeInfo =>
      'The colour the tenant shows on every surface: the web, the terminal and this app. Status and priority colours never change with it.';

  @override
  String get tenantThemeDefault => 'default';

  @override
  String get tenantThemeCustom => 'Custom colour';

  @override
  String get tenantThemeCustomHelp =>
      '#rrggbb. tix adjusts it until text on it and around it stays readable.';

  @override
  String get tenantThemeCustomBad =>
      'Write the colour as #rrggbb, such as #0f766e.';

  @override
  String get tenantThemePreview => 'Preview';

  @override
  String get tenantThemeSampleRow => 'A selected row';

  @override
  String get tenantThemeSampleLink => 'A link';

  @override
  String get tenantThemeSampleButton => 'New task';

  @override
  String get tenantThemeSaved => 'Theme saved.';

  @override
  String get tenantTotpTitle => 'Second factor';

  @override
  String get tenantTotpInfo =>
      'Require a code from an authenticator app when people sign in. Someone without one is taken through setting it up at sign-in, so turning this on cannot lock anyone out.';

  @override
  String get tenantTotpWeb => 'Require it in the browser';

  @override
  String get tenantTotpCli => 'Require it on the command line';

  @override
  String get tenantTotpSsh => 'Require it over SSH, on top of the key';

  @override
  String get tenantTotpNone => 'Not required';

  @override
  String get tenantTotpBadge => 'Second factor';

  @override
  String get tenantLeaseTitle => 'Claims';

  @override
  String get tenantLeaseInfo =>
      'How long an agent\'s claim on a task lasts. A project, workflow or claim can ask for less; the server\'s ceiling always wins.';

  @override
  String get tenantLeaseDefault => 'Default lease';

  @override
  String get tenantLeaseDefaultHelp =>
      'A duration such as 30m or 2h. Empty uses the server\'s.';

  @override
  String get tenantLeaseMax => 'Longest lease';

  @override
  String get tenantLeaseMaxHelp =>
      'Caps every claim in this tenant. It can lower the server\'s ceiling, never raise it.';

  @override
  String get tenantTrashTitle => 'Trash';

  @override
  String get tenantTrashKeep => 'Keep deleted tasks in a trash';

  @override
  String get tenantTrashOnBody =>
      'Deleted tasks can be restored until housekeeping empties the trash.';

  @override
  String get tenantTrashOffBody =>
      'Deleting a task is permanent. Tasks already in the trash stay there.';

  @override
  String get tenantTrashOnShort => 'Deleted tasks go to the trash';

  @override
  String get tenantTrashOffShort => 'Deleting is permanent';

  @override
  String get tenantDelete => 'Delete tenant';

  @override
  String get tenantDeleteHelp =>
      'Its data stops being reachable and its domains stop resolving.';

  @override
  String get tenantDeleteCurrent =>
      'This is the tenant you are working in. Switch to another one to delete it.';

  @override
  String tenantDeleteBody(String name, String key) {
    return '$name ($key) and everything in it stop being reachable, for everyone, and its domains stop resolving. Only the server\'s operator can bring it back.';
  }

  @override
  String tenantDeleted(String name) {
    return 'Deleted $name.';
  }

  @override
  String get tenantsTitle => 'Tenants';

  @override
  String get tenantsSubtitle => 'Every tenant on this server';

  @override
  String get tenantsEmpty => 'No tenants.';

  @override
  String get tenantsEmptyBody => 'Create one with its first admin.';

  @override
  String get tenantsPick => 'Pick a tenant to see it here.';

  @override
  String get tenantCreate => 'New tenant';

  @override
  String get tenantCreateSubmit => 'Create tenant';

  @override
  String tenantCreated(String name) {
    return 'Created $name.';
  }

  @override
  String get tenantFirstAdmin => 'First admin';

  @override
  String get tenantFirstAdminHelp =>
      'Becomes an admin of the new tenant. An address that already has an account keeps its password and second factor.';

  @override
  String get tenantPasswordHelp =>
      'At least 12 characters. Leave it empty and tix generates one, shown once.';

  @override
  String get tenantCredentialsHeading => 'Copy these passwords now';

  @override
  String get tenantCredentialsNote =>
      'tix generated them and shows them once; nothing stores them. Hand each to its admin, who chooses a new one at first sign-in. If one is lost, set a new password.';

  @override
  String get tenantCurrent => 'Current';

  @override
  String get tenantMember => 'Member';

  @override
  String get tenantNoTrash => 'No trash';

  @override
  String get tenantOverview => 'Overview';

  @override
  String get tenantCreatedAt => 'Created';

  @override
  String get tenantSwitch => 'Switch to this tenant';

  @override
  String get tenantJoinSwitch => 'Join and switch';

  @override
  String tenantJoinBody(String name) {
    return 'You are not a member of $name. As a global admin you can add yourself as an admin and switch to it. The change is in your account log.';
  }

  @override
  String get tenantJoinConfirm => 'Join as admin';

  @override
  String get tenantSwitchPinned =>
      'This connection reaches one tenant only. Sign in with a switchable connection to move between tenants.';

  @override
  String get tenantUsersTitle => 'Users';

  @override
  String get tenantDomainsEmpty => 'No domains map to this tenant.';

  @override
  String get domainsTitle => 'Domains';

  @override
  String get domainsSubtitle => 'Hostnames that open this tenant';

  @override
  String get domainsBody =>
      'A request that arrives on one of these hostnames reaches this tenant without naming it.';

  @override
  String get domainsEmpty => 'No domains yet.';

  @override
  String get domainsEmptyBody =>
      'Map a hostname so people reach this tenant at its own address.';

  @override
  String get domainAdd => 'Add domain';

  @override
  String get domainAddSubmit => 'Add domain';

  @override
  String get domainAdded => 'Domain added.';

  @override
  String get domainHostname => 'Hostname';

  @override
  String get domainHostnameHelp =>
      'Lowercased; any port or trailing dot is dropped.';

  @override
  String get domainCertMode => 'Certificate';

  @override
  String get domainCertNone => 'Terminated elsewhere';

  @override
  String get domainCertFile => 'Certificate file';

  @override
  String get domainCertNoneHelp =>
      'A proxy in front of tix holds the certificate, or the host is plain HTTP.';

  @override
  String get domainCertFileHelp =>
      'tix serves TLS itself from PEM files on the server.';

  @override
  String get domainCertPath => 'Certificate path on the server';

  @override
  String get domainKeyPath => 'Private key path on the server';

  @override
  String get domainVerified => 'Verified';

  @override
  String get domainShared => 'Shared';

  @override
  String get domainSharedInfo =>
      'A shared hostname also serves the tenant a credential or the X-Tix-Tenant header names, as a host no domain claims does. Only a global admin sets it.';

  @override
  String get domainRemove => 'Remove domain';

  @override
  String domainRemoveBody(String hostname) {
    return 'Requests to $hostname stop reaching this tenant. People who use that address have to use another one.';
  }

  @override
  String get domainRemoved => 'Domain removed.';

  @override
  String get serverTitle => 'Server';

  @override
  String serverVersion(String version) {
    return 'tix $version';
  }

  @override
  String get serverStatusTitle => 'Status';

  @override
  String get serverVersionLabel => 'Version';

  @override
  String get serverHealth => 'Health';

  @override
  String get serverAddress => 'Address';

  @override
  String get serverId => 'Server process';

  @override
  String get serverCountTenant => 'Live connections in this tenant';

  @override
  String get serverCountEvents => 'Live update streams';

  @override
  String get serverCountSsh => 'SSH sessions';

  @override
  String get serverCountProcess => 'Connections on this server';

  @override
  String get serverCountProcessInfo =>
      'Every connection this server process holds, across all tenants. It is capacity, not a directory, so it names nobody.';

  @override
  String get connectionsTitle => 'Live connections';

  @override
  String get connectionsInfo =>
      'The live update streams and SSH sessions of this tenant that this server process holds. Ending one closes it; the client may connect again.';

  @override
  String get connectionsEmpty => 'No live connections.';

  @override
  String get connectionEvents => 'Live updates';

  @override
  String get connectionSsh => 'SSH';

  @override
  String connectionSince(String date) {
    return 'since $date';
  }

  @override
  String get connectionEnd => 'End';

  @override
  String get connectionEndBody =>
      'The connection closes at once. A client that is still running may connect again; revoke its token or key to keep it out.';

  @override
  String get connectionEnded => 'Connection ended.';

  @override
  String get globalAdminsTitle => 'Global admins';

  @override
  String get globalAdminsSubtitle =>
      'People who administer every tenant on this server';

  @override
  String get globalAdminsEmpty => 'No global admins.';

  @override
  String get globalAdminGrant => 'Grant global admin';

  @override
  String get globalAdminGrantSubmit => 'Grant';

  @override
  String get globalAdminGrantHelp =>
      'The account with this email can then create tenants and administer every one of them.';

  @override
  String get globalAdminGranted => 'Global admin granted.';

  @override
  String get globalAdminRevoke => 'Revoke';

  @override
  String globalAdminRevokeBody(String email) {
    return '$email stops administering every tenant at once. Their memberships stay as they are.';
  }

  @override
  String get globalAdminRevoked => 'Global admin revoked.';

  @override
  String get globalAdminBadge => 'Global admin';

  @override
  String get adminRoleAdmin => 'Admin';

  @override
  String get adminRoleMember => 'Member';

  @override
  String get adminRoleViewer => 'Viewer';

  @override
  String get adminRoleNone => 'No role';

  @override
  String get adminUsersEmpty => 'No users in this tenant.';

  @override
  String get adminUsersEmptyBody =>
      'Create a user, or add an account that already exists.';

  @override
  String get adminUserCreate => 'New user';

  @override
  String get adminUserCreateSubmit => 'Create user';

  @override
  String get adminUserActions => 'User actions';

  @override
  String get adminUserEdit => 'Edit';

  @override
  String adminUserEditTitle(String email) {
    return 'Edit $email';
  }

  @override
  String get adminUserDelete => 'Delete user';

  @override
  String adminUserDeleteBody(String email) {
    return '$email loses this tenant: their membership is revoked and their sessions and tokens here end. Their account stays for other tenants.';
  }

  @override
  String get adminUserClearTotp => 'Clear second factor';

  @override
  String get adminUserClearTotpConfirm => 'Clear it';

  @override
  String adminUserClearTotpBody(String email) {
    return '$email signs in with their password alone until they set up a second factor again. Do this only when they have lost their authenticator and their recovery codes.';
  }

  @override
  String get adminUserEmail => 'Email';

  @override
  String get adminUserHandle => 'Handle';

  @override
  String get adminUserHandleHelp =>
      'Their short name in this tenant. Empty uses the part of the email before the @.';

  @override
  String get adminUserDisplayName => 'Display name';

  @override
  String get adminUserPassword => 'Password';

  @override
  String get adminUserPasswordHelp =>
      'At least 12 characters. Leave it empty for a user who signs in another way or is invited later.';

  @override
  String get adminUserNewPassword => 'New password';

  @override
  String get adminUserNewPasswordHelp =>
      'Leave it empty to keep the current one.';

  @override
  String get adminUserRole => 'Role';

  @override
  String get adminUserDisabled => 'Disabled';

  @override
  String get adminUserDisabledSwitch => 'Disabled';

  @override
  String get adminUserDisabledHelp =>
      'A disabled user cannot sign in; their sessions and tokens end at once.';

  @override
  String get adminUserMustChangePassword => 'Must change password';

  @override
  String get adminUserMustChangeSwitch =>
      'Choose a new password at next sign-in';

  @override
  String get adminUserTotp => 'Second factor';

  @override
  String get adminMemberAdd => 'Add existing account';

  @override
  String get adminMemberAddSubmit => 'Add to tenant';

  @override
  String get adminMemberAddHelp =>
      'The person keeps their password and second factor and is not asked to accept.';

  @override
  String get adminAccountLogTitle => 'Account log';

  @override
  String get adminAccountLogEmpty => 'Nothing logged for this account.';

  @override
  String get adminAccountLogEmptyBody =>
      'Changes to its password, second factor, standing and memberships show here.';

  @override
  String adminAccountLogBy(String who) {
    return 'by $who';
  }

  @override
  String adminAccountLogVia(String channel) {
    return 'via $channel';
  }

  @override
  String get adminAccountLogSystem => 'the system';

  @override
  String get taskReclaim => 'Force-release claim';

  @override
  String get taskReclaimSubmit => 'Release claim';

  @override
  String get taskReclaimBody =>
      'Ends the lease another actor holds on this task, for when its worker died. That worker\'s next renewal is refused.';

  @override
  String get taskReclaimReason => 'Reason (optional)';

  @override
  String get taskReclaimReasonHelp => 'Kept in the task\'s history.';

  @override
  String taskReclaimed(String ref) {
    return 'Released the claim on $ref.';
  }

  @override
  String get totpWrongCode =>
      'That code is not right. Check the time on this device and try the next one.';

  @override
  String get tenantThemeSampleStatus => 'Doing';

  @override
  String get tenantSettingsSubtitle =>
      'Name, theme, second factor, claims and trash';

  @override
  String get serverSubtitle => 'Version and live connections';

  @override
  String get webhooksTitle => 'Webhooks';

  @override
  String get webhooksSubtitle =>
      'tix posts each event to these addresses, signed with the endpoint\'s secret.';

  @override
  String get webhookNew => 'New endpoint';

  @override
  String get webhookEdit => 'Edit endpoint';

  @override
  String get webhookEndpoints => 'Endpoints';

  @override
  String get webhookEndpointsInfo =>
      'An endpoint receives every event, or only the types it names. An inactive one receives nothing until it is turned back on.';

  @override
  String get webhooksEmpty => 'No webhook endpoints yet.';

  @override
  String get webhooksEmptyBody =>
      'Add an https address and tix will post events to it as they happen.';

  @override
  String get webhookEveryEvent => 'Every event';

  @override
  String get webhookActive => 'Active';

  @override
  String get webhookInactive => 'Inactive';

  @override
  String get webhookActiveHelp => 'An inactive endpoint receives nothing.';

  @override
  String get webhookShowDeliveries => 'Show its deliveries';

  @override
  String get webhookDelete => 'Delete endpoint';

  @override
  String get webhookDeleteTitle => 'Delete this endpoint?';

  @override
  String webhookDeleteBody(String url) {
    return '$url stops receiving events, and its pending deliveries are dropped. This cannot be undone.';
  }

  @override
  String get webhookDeleted => 'Endpoint deleted.';

  @override
  String get webhookUrl => 'Address';

  @override
  String get webhookUrlHelp =>
      'Must use https, unless it is a loopback address.';

  @override
  String get webhookEvents => 'Event types';

  @override
  String get webhookEventsHelp =>
      'Separated by commas; a type may end in *. Empty sends every event.';

  @override
  String get webhookSecret => 'Signing secret';

  @override
  String get webhookSecretNewHelp =>
      'Leave it empty and the app generates one and shows it once.';

  @override
  String get webhookSecretKeepHelp =>
      'Leave it empty to keep the current secret.';

  @override
  String get webhookSave => 'Save endpoint';

  @override
  String get webhookSaved => 'Endpoint saved.';

  @override
  String get webhookSecretHeading => 'Copy this signing secret now';

  @override
  String get webhookSecretNote =>
      'It is shown once and cannot be read back. Configure it on the receiving end; if you lose it, save the endpoint again with a secret of your own.';

  @override
  String get webhookSecretDone => 'I have copied it';

  @override
  String get webhookDeliveries => 'Deliveries';

  @override
  String get webhookDeliveriesAll => 'Every endpoint, newest first.';

  @override
  String webhookDeliveriesFor(String url) {
    return 'For $url, newest first.';
  }

  @override
  String get webhookDeliveriesShowAll => 'Show every endpoint';

  @override
  String get webhookDeliveriesEmpty => 'No deliveries.';

  @override
  String get webhookDeliveriesEmptyBody =>
      'Deliveries appear here as events are sent.';

  @override
  String get webhookStatusAny => 'Any';

  @override
  String get webhookStatusPending => 'Pending';

  @override
  String get webhookStatusDelivered => 'Delivered';

  @override
  String get webhookStatusFailed => 'Failed';

  @override
  String get webhookStatusUnknown => 'Unknown';

  @override
  String webhookEvent(int seq) {
    return 'Event $seq';
  }

  @override
  String webhookAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts',
      one: '1 attempt',
    );
    return '$_temp0';
  }

  @override
  String webhookHttpStatus(int code) {
    return 'HTTP $code';
  }

  @override
  String webhookNextAttempt(String when) {
    return 'next attempt $when';
  }

  @override
  String get webhookRedeliver => 'Redeliver';

  @override
  String get webhookRedelivered => 'Queued for another attempt.';

  @override
  String get syncTitle => 'External sync';

  @override
  String get syncSubtitle =>
      'Import work from Jira, OpenProject or a file. Runs happen on the server.';

  @override
  String get syncNew => 'New source';

  @override
  String get syncSources => 'Sources';

  @override
  String get syncSourcesInfo =>
      'Each source keeps a cursor, so a run imports only what changed since the last one. A full run starts again from the beginning.';

  @override
  String get syncEmpty => 'No sync sources yet.';

  @override
  String get syncEmptyBody =>
      'Add a source to import tasks from another tracker.';

  @override
  String get syncStatusOk => 'Last run ok';

  @override
  String get syncStatusFailed => 'Last run failed';

  @override
  String get syncStatusRunning => 'Running';

  @override
  String get syncStatusNever => 'Never run';

  @override
  String get syncNeverRun => 'Not run yet.';

  @override
  String syncLastRun(String when) {
    return 'Last run $when.';
  }

  @override
  String syncStoredCredentials(String names) {
    return 'Stored credentials: $names';
  }

  @override
  String get syncMissing => 'A run is refused until the server has:';

  @override
  String get syncReady => 'Ready to run.';

  @override
  String get syncRunNow => 'Run now';

  @override
  String get syncPreview => 'Preview';

  @override
  String get syncEdit => 'Edit';

  @override
  String get syncDelete => 'Delete source';

  @override
  String get syncDeleteTitle => 'Delete this source?';

  @override
  String syncDeleteBody(String name) {
    return '$name and how far it had read are removed. Tasks it already imported stay. This cannot be undone.';
  }

  @override
  String get syncDeleted => 'Source deleted.';

  @override
  String syncSaved(String name) {
    return 'Saved $name.';
  }

  @override
  String syncRunTitle(String name) {
    return 'Run $name';
  }

  @override
  String get syncRunBody =>
      'Preview counts what a run would do and changes nothing.';

  @override
  String get syncFull => 'Full run';

  @override
  String get syncFullHelp =>
      'Read everything again from the beginning instead of from where the last run stopped.';

  @override
  String get syncPreviewTitle => 'Preview';

  @override
  String get syncDoneTitle => 'Run finished';

  @override
  String get syncPreviewNote => 'Nothing was changed.';

  @override
  String syncCounts(int created, int updated, int skipped, int deleted) {
    return '$created created · $updated updated · $skipped skipped · $deleted deleted';
  }

  @override
  String get syncUnmatched => 'People with no match here';

  @override
  String get syncWarnings => 'Warnings';

  @override
  String syncWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count warnings',
      one: '1 warning',
    );
    return '$_temp0';
  }

  @override
  String get syncRuns => 'Run history';

  @override
  String get syncRunsEmpty => 'No finished runs.';

  @override
  String get syncRunsEmptyBody =>
      'A run that fails is not listed here; the source shows it.';

  @override
  String syncEditTitle(String name) {
    return 'Edit $name';
  }

  @override
  String get syncFormIntro =>
      'Settings and the mapping are stored on the server. Credentials are sealed there and never shown again.';

  @override
  String get syncName => 'Name';

  @override
  String get syncNameHelp => 'Names the source within its system.';

  @override
  String get syncMapping => 'Mapping document (YAML)';

  @override
  String get syncMappingHelp => 'Left empty, the stored document is kept.';

  @override
  String get syncMappingPath => 'Mapping file on the server';

  @override
  String get syncMappingPathHelp =>
      'Only read from this tenant\'s directory under the server\'s sync.file_root.';

  @override
  String get syncCredentials => 'Credentials';

  @override
  String get syncCredentialsHelp =>
      'Write only. Any of them replaces the stored set; leave all empty to keep it.';

  @override
  String get syncToken => 'Token';

  @override
  String get syncUser => 'User';

  @override
  String get syncPassword => 'Password or API key';

  @override
  String get syncClearCredentials => 'Remove the stored credentials';

  @override
  String get syncCheck => 'Check';

  @override
  String get syncSave => 'Save source';

  @override
  String syncMappingFrom(String origin) {
    return 'Mapping: $origin';
  }

  @override
  String syncCredentialsFrom(String origin) {
    return 'Credentials: $origin';
  }

  @override
  String get syncFromStored => 'stored on the source';

  @override
  String get syncFromEnv => 'from the environment';

  @override
  String get syncFromMappingPath => 'file on the server';

  @override
  String get syncFromNone => 'not needed';

  @override
  String get syncFromMissing => 'missing';

  @override
  String syncSummaryProject(String project) {
    return 'Lands in project $project';
  }

  @override
  String syncSummaryIdentity(String field) {
    return 'Matched by $field';
  }

  @override
  String get retentionTitle => 'Retention';

  @override
  String get retentionSubtitle => 'How long this tenant keeps its logs.';

  @override
  String get retentionWindows => 'Keep for';

  @override
  String get retentionWindowsHelp =>
      'In days. Older records are removed when the log is pruned.';

  @override
  String get retentionEvents => 'Events';

  @override
  String get retentionEventsHelp => 'The live update stream. Default 30 days.';

  @override
  String get retentionAudit => 'Audit entries';

  @override
  String get retentionAuditHelp => 'Who changed what. Default 365 days.';

  @override
  String get retentionDeliveries => 'Webhook deliveries';

  @override
  String get retentionDeliveriesHelp => 'The delivery log. Default 30 days.';

  @override
  String get retentionSave => 'Save retention';

  @override
  String get retentionSaved => 'Retention saved.';

  @override
  String get retentionPruneSection => 'Prune now';

  @override
  String get retentionPruneHelp =>
      'Removes everything past its window at once, instead of waiting for the server to do it.';

  @override
  String get retentionPreview => 'Preview';

  @override
  String get retentionPrune => 'Prune';

  @override
  String get retentionPruneTitle => 'Prune old records?';

  @override
  String get retentionPruneBody =>
      'Events, audit entries and webhook deliveries past their window are deleted for good.';

  @override
  String get retentionPruned => 'Pruned.';

  @override
  String retentionWouldPrune(int events, int audit, int deliveries) {
    return 'Would remove $events events, $audit audit entries and $deliveries deliveries.';
  }

  @override
  String retentionDidPrune(int events, int audit, int deliveries) {
    return 'Removed $events events, $audit audit entries and $deliveries deliveries.';
  }

  @override
  String retentionKeptForSubscribers(int count) {
    return '$count events past their window are kept until a subscriber has read them.';
  }

  @override
  String get housekeepingTitle => 'Housekeeping';

  @override
  String get housekeepingSubtitle =>
      'Clears finished work out of the lists and empties the trash.';

  @override
  String get housekeepingPaused =>
      'Housekeeping is paused while the trash is off: no rule runs.';

  @override
  String get housekeepingRules => 'Rules';

  @override
  String get housekeepingRulesHelp =>
      'A number of days, or off. Projects can override these.';

  @override
  String get housekeepingDone => 'Done tasks move to the trash after';

  @override
  String get housekeepingDoneHelp => 'Days since they were done.';

  @override
  String get housekeepingCancelled => 'Cancelled tasks move to the trash after';

  @override
  String get housekeepingCancelledHelp => 'Days since they were cancelled.';

  @override
  String get housekeepingTrash => 'The trash deletes tasks for good after';

  @override
  String get housekeepingTrashHelp => 'Days in the trash.';

  @override
  String housekeepingPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks due now.',
      one: '1 task due now.',
      zero: 'Nothing due now.',
    );
    return '$_temp0';
  }

  @override
  String get housekeepingSave => 'Save rules';

  @override
  String get housekeepingSaved => 'Rules saved.';

  @override
  String get housekeepingRunSection => 'Run now';

  @override
  String get housekeepingRunHelp =>
      'Applies the rules once, in batches, instead of waiting for the server\'s next pass.';

  @override
  String get housekeepingPreview => 'Preview';

  @override
  String get housekeepingRun => 'Run housekeeping';

  @override
  String get housekeepingRunTitle => 'Run housekeeping now?';

  @override
  String get housekeepingRunBody =>
      'Finished tasks past their rule move to the trash, and tasks past the trash rule are deleted for good.';

  @override
  String housekeepingWould(int done, int cancelled, int trash) {
    return 'Would move $done done and $cancelled cancelled tasks to the trash, and delete $trash for good.';
  }

  @override
  String housekeepingDid(int done, int cancelled, int trash) {
    return 'Moved $done done and $cancelled cancelled tasks to the trash, and deleted $trash for good.';
  }

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashSubtitle => 'Deleted tasks, until housekeeping empties them.';

  @override
  String get trashExplain =>
      'Restore puts a task back where it was. tix deletes trashed tasks for good only through the housekeeping trash rule.';

  @override
  String get trashEmpty => 'The trash is empty.';

  @override
  String get trashEmptyBody => 'Deleted tasks wait here and can be restored.';

  @override
  String get trashRestore => 'Restore';

  @override
  String trashRestored(String ref) {
    return 'Restored $ref.';
  }

  @override
  String trashDeletedAt(String when) {
    return 'deleted $when';
  }

  @override
  String get auditTitle => 'Audit log';

  @override
  String get auditSubtitle => 'Every change in this tenant, newest first.';

  @override
  String get auditSearch => 'Search actions, records and values';

  @override
  String get auditVia => 'Channel';

  @override
  String get auditSource => 'Surface';

  @override
  String get auditMoreFilters => 'More filters';

  @override
  String auditMoreFiltersCount(int count) {
    return 'More filters ($count)';
  }

  @override
  String get auditClear => 'Clear filters';

  @override
  String get auditFilters => 'Filter the audit log';

  @override
  String get auditApply => 'Apply';

  @override
  String get auditActor => 'Actor';

  @override
  String get auditActorHelp => 'The actor\'s id.';

  @override
  String get auditAction => 'Action';

  @override
  String get auditToken => 'API token';

  @override
  String get auditTokenHelp => 'The token\'s name.';

  @override
  String auditSince(String day) {
    return 'From $day';
  }

  @override
  String auditUntil(String day) {
    return 'To $day';
  }

  @override
  String get auditAnyTime => 'any time';

  @override
  String get auditEmpty => 'Nothing recorded yet.';

  @override
  String get auditEmptyBody =>
      'Changes appear here as people and agents make them.';

  @override
  String get auditNoMatch => 'No entries match.';

  @override
  String get auditNoMatchBody => 'Loosen or clear the filters.';

  @override
  String get auditPick => 'Pick an entry';

  @override
  String get auditPickBody => 'Its detail shows here.';

  @override
  String get auditSeq => 'Entry';

  @override
  String get auditWhen => 'When';

  @override
  String get auditSystem => 'the system';

  @override
  String get auditSubject => 'Record';

  @override
  String get auditTokenId => 'Token id';

  @override
  String get auditSession => 'Session';

  @override
  String get auditKey => 'SSH key';

  @override
  String get auditClient => 'Client address';

  @override
  String get auditOrigin => 'Origin';

  @override
  String get auditHost => 'Host';

  @override
  String get auditOsUser => 'System user';

  @override
  String get auditJob => 'Job';

  @override
  String get auditUserAgent => 'User agent';

  @override
  String get auditBefore => 'Before';

  @override
  String get auditAfter => 'After';

  @override
  String get timeJustNow => 'just now';

  @override
  String get timeInAMoment => 'in a moment';

  @override
  String timeAgoMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String timeAgoYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'in $n minutes',
      one: 'in 1 minute',
    );
    return '$_temp0';
  }

  @override
  String timeInHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'in $n hours',
      one: 'in 1 hour',
    );
    return '$_temp0';
  }

  @override
  String timeInDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'in $n days',
      one: 'in 1 day',
    );
    return '$_temp0';
  }

  @override
  String timeInMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'in $n months',
      one: 'in 1 month',
    );
    return '$_temp0';
  }

  @override
  String timeInYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'in $n years',
      one: 'in 1 year',
    );
    return '$_temp0';
  }

  @override
  String get timeFormatIso => 'ISO';

  @override
  String get timeFormatRfc3339 => 'RFC 3339';

  @override
  String get timeFormatShort => 'Short';

  @override
  String get timeFormatLong => 'Long';

  @override
  String get timeFormatDotted => 'Dotted';

  @override
  String get timeFormatDayfirst => 'Day first';

  @override
  String get timeFormatUs => 'US';

  @override
  String get timeFormatRelative => 'Relative';

  @override
  String get settingsSearchHint => 'Search settings';

  @override
  String settingsNoMatch(String query) {
    return 'No setting matches “$query”';
  }

  @override
  String get settingsNoMatchBody => 'Try another word, or clear the search.';

  @override
  String get settingsScopeDevice => 'On this device';

  @override
  String get settingsScopeAccount => 'Synced to your account';

  @override
  String get settingsScopeTenant => 'Whole tenant';

  @override
  String get settingsGroupDevice => 'This device';

  @override
  String get settingsGroupDeviceHelp =>
      'Kept on this device only. Your other devices and the web keep their own.';

  @override
  String settingsGroupAccount(String tenant) {
    return 'Your account on $tenant';
  }

  @override
  String get settingsGroupAccountHelp =>
      'Kept by the server with your account, so they follow you to every device, the web and the command line.';

  @override
  String get settingsGroupTenant => 'This tenant';

  @override
  String settingsGroupTenantHelp(String tenant) {
    return 'Settings for everyone in $tenant. Only administrators see these.';
  }

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionHelp =>
      'Keeps the app still even when the system allows animation.';

  @override
  String get settingsHaptics => 'Touch feedback';

  @override
  String get settingsHapticsHelp =>
      'A short buzz on swipes, completed tasks and refusals.';

  @override
  String get settingsLanguageHelp =>
      'tix keeps no language with your account, so each device and browser picks its own.';

  @override
  String get settingsStartTitle => 'Start screen';

  @override
  String get settingsStartHelp =>
      'Where the app opens when it starts or after you sign in.';

  @override
  String get settingsDeviceNotifTitle => 'Notifications on this device';

  @override
  String get settingsDeviceNotifSubtitle =>
      'Whether this device alerts you, and for which kinds';

  @override
  String get settingsProfileTitle => 'Profile';

  @override
  String get settingsDatesTitle => 'Dates and times';

  @override
  String get settingsDatesHelp =>
      'Kept with your account, so every device, browser and terminal shows dates this way. Inherit follows your tenant’s default, which follows the server’s.';

  @override
  String get settingsDateFormat => 'Date format';

  @override
  String get settingsDateFormatHelp =>
      'How every timestamp in the app is written. tix reads dates you type the same way on the web.';

  @override
  String get settingsTimeZone => 'Time zone';

  @override
  String get settingsTimeZoneHelp =>
      'The zone every time in the app is shown in, and where today ends for due dates.';

  @override
  String get settingsInherit => 'Inherit';

  @override
  String settingsInheritValue(String value) {
    return 'Inherit: $value';
  }

  @override
  String settingsInUse(String value, String source) {
    return 'In use: $value, from $source';
  }

  @override
  String get settingsSourceUser => 'your choice';

  @override
  String get settingsSourceTenant => 'the tenant default';

  @override
  String get settingsSourceGlobal => 'the server default';

  @override
  String get settingsDeviceFormat => 'this device’s format';

  @override
  String settingsDeviceZone(String zone) {
    return 'this device’s zone ($zone)';
  }

  @override
  String get settingsDatesNotPersonal =>
      'This credential is not a person, so it reads your tenant’s defaults and cannot keep its own.';

  @override
  String get settingsDatesLoading =>
      'Reading your date settings from the server…';

  @override
  String get settingsDatesUnsupported =>
      'This version of tix keeps no date preferences, so dates follow this device. A newer tix server adds them.';

  @override
  String get settingsDatesFailed =>
      'The server did not answer, so dates follow this device for now.';

  @override
  String get settingsDatesSaved => 'Saved with your account';

  @override
  String get settingsZoneSearch => 'Search time zones';

  @override
  String get settingsZoneNone => 'No time zone matches.';

  @override
  String get settingsInboxTitle => 'Inbox and channels';

  @override
  String get settingsInboxSubtitle =>
      'Which kinds reach your inbox, and your personal channels';

  @override
  String get settingsFiltersTitle => 'Saved filters';

  @override
  String get settingsFiltersSubtitle =>
      'Rename, share or delete the filters you keep';

  @override
  String get settingsArrangementTitle => 'Board and lanes';

  @override
  String get settingsArrangementHelp =>
      'The groups you hid, starred, collapsed or moved on the board, in lanes and on My work.';

  @override
  String get settingsArrangementReset => 'Reset';

  @override
  String get settingsArrangementResetTitle => 'Reset board and lanes';

  @override
  String get settingsArrangementResetBody =>
      'Every group on the board, in lanes and on My work goes back where tix puts it, on every device and on the web. This cannot be undone.';

  @override
  String get settingsArrangementDone => 'Arrangement reset';

  @override
  String settingsTenantManage(String tenant) {
    return 'Manage $tenant';
  }

  @override
  String get settingsTenantManageSubtitle =>
      'Projects, workflows, fields, people and the tenant’s own settings';

  @override
  String paletteSettingsItem(String name) {
    return 'Settings: $name';
  }

  @override
  String get savedFiltersEmpty => 'No saved filters';

  @override
  String get savedFiltersEmptyBody =>
      'Save a filter from the task list and it shows here, on every device.';

  @override
  String get savedFilterSharedBadge => 'Shared';

  @override
  String get savedFilterTheirs =>
      'Shared with you; only its owner and administrators can change it.';

  @override
  String durationDays(int n) {
    return '$n d';
  }

  @override
  String durationHours(int n) {
    return '$n h';
  }

  @override
  String durationMinutes(int n) {
    return '$n min';
  }

  @override
  String durationSeconds(int n) {
    return '$n s';
  }

  @override
  String get errorBadInviteLink =>
      'That is not an invite link. It looks like https://your-server/invite/tix_inv_…';

  @override
  String get methodInvite => 'Invite';

  @override
  String get inviteLinkLabel => 'Invite link';

  @override
  String get inviteLinkHint => 'https://tix.example.com/invite/tix_inv_…';

  @override
  String get inviteLinkHelp =>
      'Paste the link from your invite email, or share it to tix from another app. The server is added for you.';

  @override
  String get invitePaste => 'Paste the invite link';

  @override
  String get inviteCheck => 'Check invite';

  @override
  String inviteJoin(String tenant, String host) {
    return 'Join $tenant on $host';
  }

  @override
  String inviteJoinServer(String host) {
    return 'Join $host';
  }

  @override
  String inviteAs(String email) {
    return 'as $email';
  }

  @override
  String inviteExpires(String when) {
    return 'The link works until $when.';
  }

  @override
  String get inviteExistingAccount =>
      'This address already has a tix account. Enter its password to accept; nothing about the account changes.';

  @override
  String get inviteDisplayName => 'Your name';

  @override
  String get inviteNewPassword => 'New password';

  @override
  String get inviteNewPasswordHelp =>
      'At least 12 characters. It signs you in everywhere, not only here.';

  @override
  String get inviteExistingPasswordHelp =>
      'The password you already sign in to tix with.';

  @override
  String get inviteCodeHelp =>
      'A code from your authenticator app, which this account already uses.';

  @override
  String get inviteAccept => 'Accept invite';

  @override
  String get notifHideContent => 'Hide task content in notifications';

  @override
  String get notifHideContentHelp =>
      'Notifications only say “New in your inbox”, for this context.';

  @override
  String get notifPrivateTitle => 'New in your inbox';

  @override
  String get notifPrivateBody => 'Open tix to read it.';

  @override
  String get taskDetailLease => 'Claim length';

  @override
  String get taskDetailLeaseInfo =>
      'How long an agent\'s claim on this task lasts when it asks for no length, and the most any claim may last. The task, project, workflow and tenant can each set it; the nearest one wins.';

  @override
  String taskDetailLeaseValue(String length, String source) {
    return '$length, from $source';
  }

  @override
  String taskDetailLeaseMax(String length, String source) {
    return 'At most $length, from $source';
  }

  @override
  String get taskDetailLeaseClamped => 'Cut down to the ceiling.';

  @override
  String get leaseSourceClaim => 'the claim';

  @override
  String get leaseSourceTask => 'the task';

  @override
  String get leaseSourceProject => 'the project';

  @override
  String get leaseSourceWorkflow => 'the workflow';

  @override
  String get leaseSourceTenant => 'the tenant';

  @override
  String get leaseSourceDeployment => 'the server';

  @override
  String get leaseSourceBuiltin => 'tix\'s default';

  @override
  String get statusTitle => 'Server status';

  @override
  String get statusInstallation => 'Installation';

  @override
  String get statusVersion => 'Version';

  @override
  String get statusSchema => 'Schema';

  @override
  String get statusEngine => 'Database';

  @override
  String get statusAnswering => 'Answered by';

  @override
  String get statusObserved => 'Checked';

  @override
  String get statusServers => 'Server processes';

  @override
  String get statusServersInfo =>
      'Every tix process registered against this database. One that misses three heartbeats is shown as gone quiet.';

  @override
  String get statusNoServers =>
      'No process has registered. The one answering may run without the registry.';

  @override
  String get statusAttached => 'Heartbeating';

  @override
  String statusDetached(String when) {
    return 'Quiet since $when';
  }

  @override
  String statusUptime(String length) {
    return 'up $length';
  }

  @override
  String statusConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count connections',
      one: '1 connection',
    );
    return '$_temp0';
  }

  @override
  String get statusWork => 'This tenant';

  @override
  String get statusProjects => 'Projects';

  @override
  String get statusTasks => 'Tasks';

  @override
  String get statusClaimed => 'Claimed now';

  @override
  String get statusUnswept => 'Expired claims not yet swept';

  @override
  String get statusWebhooksPending => 'Webhook deliveries waiting';

  @override
  String get statusWebhooksFailed => 'Webhook deliveries failed';

  @override
  String get statusSecondFactor => 'Second factor';

  @override
  String get statusKey => 'Sealing key set';

  @override
  String get statusRequireWeb => 'Required in the browser';

  @override
  String get statusRequireCli => 'Required on the command line and in apps';

  @override
  String get statusRequireSsh => 'Required over SSH';

  @override
  String get statusAdmins => 'Admins with one';

  @override
  String statusAdminsEnrolled(int enrolled, int total) {
    return '$enrolled of $total';
  }

  @override
  String get statusUnrecoverable =>
      'Some second factors cannot be read: the sealing key is missing. Those people must have theirs cleared and enrol again.';

  @override
  String get statusYes => 'Yes';

  @override
  String get statusNo => 'No';

  @override
  String get bundlesTitle => 'Bundles';

  @override
  String get bundleExportTitle => 'Export a bundle';

  @override
  String get bundleExportSubtitle =>
      'Reusable setup as one file, for another tenant or server';

  @override
  String get bundleExportInfo =>
      'A bundle carries workflows, custom field definitions, tags, projects as templates and webhook endpoints, never their tasks. Webhook secrets never travel in one.';

  @override
  String get bundleKindWorkflow => 'Workflows';

  @override
  String get bundleKindField => 'Custom fields';

  @override
  String get bundleKindTag => 'Tags';

  @override
  String get bundleKindProject => 'Project templates';

  @override
  String get bundleKindWebhook => 'Webhooks';

  @override
  String get bundleKindsAll => 'Nothing picked: the bundle carries every kind.';

  @override
  String get bundleKindsSome => 'Only the kinds picked go in.';

  @override
  String get bundleName => 'Name';

  @override
  String get bundleNameHelp =>
      'Labels the bundle for whoever receives it. Optional.';

  @override
  String get bundleExport => 'Export bundle';

  @override
  String bundleExported(String name) {
    return 'Exported $name';
  }

  @override
  String get bundleImportTitle => 'Import a bundle';

  @override
  String get bundleImportSubtitle =>
      'Previewed first, then applied all at once';

  @override
  String get bundleImportInfo =>
      'A bundle applies atomically: everything in it lands, or nothing does. The preview writes nothing.';

  @override
  String get bundlePick => 'Choose a bundle file';

  @override
  String get bundleCollision => 'When a key is already taken';

  @override
  String get bundleCollisionAsk => 'Stop and say';

  @override
  String get bundleCollisionSkip => 'Keep mine';

  @override
  String get bundleCollisionRename => 'Import under a new key';

  @override
  String get bundleCollisionReplace => 'Replace mine';

  @override
  String get bundleProject => 'Project for custom fields';

  @override
  String get bundleProjectHelp =>
      'The project key that field definitions land in. Needed only when the bundle carries them.';

  @override
  String get bundlePreview => 'Preview';

  @override
  String get bundleImport => 'Import bundle';

  @override
  String get bundleReplaceBody =>
      'Components with the same key are overwritten with the bundle\'s. This cannot be undone.';

  @override
  String get bundleImported => 'Bundle imported.';

  @override
  String get bundlePlan => 'What the import would do';

  @override
  String get bundleDone => 'What the import did';

  @override
  String get bundleEmpty => 'The bundle carries nothing.';

  @override
  String get bundleActionCreate => 'New';

  @override
  String get bundleActionReplace => 'Replaced';

  @override
  String get bundleActionRename => 'Renamed';

  @override
  String get bundleActionSkip => 'Skipped';

  @override
  String get snapshotTitle => 'Import a snapshot';

  @override
  String get snapshotFileTitle => 'Snapshot file';

  @override
  String get snapshotFileSubtitle =>
      'A file written by an export of a whole tenant';

  @override
  String get snapshotInfo =>
      'A snapshot carries projects, workflows, fields, tasks and comments. Check what it would change with a dry run before importing.';

  @override
  String get snapshotPick => 'Choose a snapshot file';

  @override
  String get snapshotMerge => 'Merge';

  @override
  String get snapshotReplace => 'Replace';

  @override
  String get snapshotMergeHelp =>
      'Adds what is new and updates what changed. Nothing is removed.';

  @override
  String get snapshotReplaceHelp =>
      'Also removes the tasks and fields of each imported project that the snapshot does not carry.';

  @override
  String get snapshotDryRun => 'Dry run';

  @override
  String get snapshotImport => 'Import snapshot';

  @override
  String get snapshotMergeBody =>
      'The snapshot\'s records are added to this tenant and update the ones it already has.';

  @override
  String get snapshotReplaceBody =>
      'Tasks and fields of the imported projects that the snapshot does not carry are deleted. This cannot be undone.';

  @override
  String get snapshotImported => 'Snapshot imported.';

  @override
  String get snapshotPlan => 'What the import would do';

  @override
  String get snapshotDone => 'What the import did';

  @override
  String get snapshotCreated => 'Created';

  @override
  String get snapshotUpdated => 'Updated';

  @override
  String get snapshotDeleted => 'Deleted';

  @override
  String get snapshotSkipped => 'Left alone';

  @override
  String manageInheritedValue(String value) {
    return 'Inherited: $value';
  }

  @override
  String manageDurationSaved(String value) {
    return 'Saved as $value. Empty inherits.';
  }

  @override
  String get projectsShowArchived => 'Show archived';

  @override
  String get manageBundlesSubtitle =>
      'Workflows, fields, tags and webhooks as one file';

  @override
  String get manageSnapshotSubtitle => 'Bring a whole tenant\'s export in';

  @override
  String get manageStatusSubtitle =>
      'Version, server processes and the tenant\'s work';

  @override
  String get rotateToken => 'Rotate token';

  @override
  String rotateTokenBody(String name) {
    return '$name gets a new token with the same name, scopes and lifetime, and the app keeps only the new one. Anything else using the old token stops working in a minute.';
  }

  @override
  String get tokenRotated => 'Token rotated. The old one stops in a minute.';

  @override
  String get offlineTitle => 'Offline';

  @override
  String get offlineSubtitle => 'What stays available without a connection';

  @override
  String get offlineLocal =>
      'This instance is a database on this device, so it is always available. Offline mode applies to remote instances only.';

  @override
  String get offlineAvailableTitle => 'Available offline';

  @override
  String get offlineAvailableSubtitle =>
      'Kept on this device for the active instance and tenant, with each task\'s comments and subtasks.';

  @override
  String get offlineStorageTitle => 'Storage';

  @override
  String get offlineStorageSubtitle =>
      'Saved copies of this context, changes waiting to be sent included.';

  @override
  String get offlineStorageCounting => 'Counting…';

  @override
  String get offlineStorageUnknown => 'Size unknown';

  @override
  String get offlineClear => 'Clear saved copies';

  @override
  String get offlineClearTitle => 'Clear saved copies?';

  @override
  String get offlineClearBody =>
      'Screens load from the server again, and nothing is available offline until the next sync. Changes waiting to be sent are kept.';

  @override
  String get offlineSyncTitle => 'Sync';

  @override
  String get offlineSyncSubtitle =>
      'Runs when this context opens and every 30 minutes. On a phone it waits for Wi-Fi and enough battery; Sync now always runs.';

  @override
  String get offlineSyncNow => 'Sync now';

  @override
  String get offlineNeverSynced => 'Not synced yet';

  @override
  String offlineStorageUsed(String size) {
    return '$size used';
  }

  @override
  String offlineLastSynced(String time) {
    return 'Last synced $time';
  }

  @override
  String offlineSavedCopy(String time) {
    return 'Offline, showing saved copy from $time';
  }

  @override
  String get errorSecretStorage =>
      'This device’s secure storage is locked or refused the write, so nothing was changed. Unlock it and try again.';

  @override
  String get tokenUnsavedTitle => 'Token rotated but not saved';

  @override
  String get tokenUnsavedHeading => 'Copy this token now';

  @override
  String get tokenUnsavedNote =>
      'Secure storage on this device refused the new token. It is shown only this once, and the old token stops working in a minute. The app uses the new one until it closes; after that, reconnect with it.';

  @override
  String get tokenUnsavedDone => 'I have copied it';

  @override
  String get syncMarkUnsynced => 'Unsynced';

  @override
  String get syncMarkDraft => 'Draft';

  @override
  String get syncMarkCheck => 'Check';

  @override
  String get syncMarkConflict => 'Conflict';

  @override
  String get syncMarkFailed => 'Refused';

  @override
  String get syncConflictsTitle => 'Conflicts';

  @override
  String get syncConflictsSubtitle =>
      'Changes made offline and how they synced';

  @override
  String get syncSendNow => 'Send now';

  @override
  String get syncEmptyTitle => 'Everything is synced';

  @override
  String get syncConflictsEmptyBody =>
      'Changes you make while offline wait here until the server is back.';

  @override
  String syncConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflicts',
      one: '1 conflict',
    );
    return '$_temp0';
  }

  @override
  String get syncConflictsHelp =>
      'Someone changed the same thing on the server while you were offline.';

  @override
  String get syncKeepAllMine => 'Keep all mine';

  @override
  String get syncKeepAllTheirs => 'Keep all theirs';

  @override
  String syncWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting',
      one: '1 change waiting',
    );
    return '$_temp0';
  }

  @override
  String get syncHistory => 'History';

  @override
  String get syncHistoryHelp =>
      'Settled conflicts. Reverse one to send the side that was not kept.';

  @override
  String get syncFieldTitle => 'Title';

  @override
  String get syncFieldBody => 'Description';

  @override
  String get syncFieldPriority => 'Priority';

  @override
  String get syncFieldAssignee => 'Assignee';

  @override
  String get syncFieldDue => 'Due';

  @override
  String get syncFieldTags => 'Tags';

  @override
  String get syncFieldStatus => 'Status';

  @override
  String get syncFieldRecurrence => 'Repeat';

  @override
  String get syncFieldParent => 'Parent';

  @override
  String get syncValueEmpty => '(empty)';

  @override
  String get syncMine => 'Mine';

  @override
  String get syncTheirs => 'Theirs';

  @override
  String get syncKeepMine => 'Keep mine';

  @override
  String get syncKeepTheirs => 'Keep theirs';

  @override
  String get syncEditChange => 'Edit';

  @override
  String get syncEditChangeTitle => 'Edit before sending';

  @override
  String get syncEditSend => 'Send';

  @override
  String syncTheirsWas(String value) {
    return 'On the server: $value';
  }

  @override
  String get syncDeletedBody =>
      'This task was deleted on the server after you changed it.';

  @override
  String get syncRestoreApply => 'Restore and apply';

  @override
  String get syncDiscardMine => 'Discard mine';

  @override
  String get syncDiscardMineTitle => 'Discard your changes?';

  @override
  String get syncDiscardMineBody =>
      'Everything you changed on this task while offline is dropped. The task stays deleted.';

  @override
  String syncMoveRefused(String status, String reason) {
    return 'Moving to $status was refused: $reason';
  }

  @override
  String get syncMoveElsewhere => 'Move elsewhere';

  @override
  String syncOpUpdate(String ref, String fields) {
    return '$ref: $fields';
  }

  @override
  String syncOpCheck(String ref) {
    return '$ref: checklist item';
  }

  @override
  String syncOpMove(String ref, String status) {
    return '$ref: move to $status';
  }

  @override
  String syncOpStar(String ref) {
    return '$ref: star';
  }

  @override
  String syncOpUnstar(String ref) {
    return '$ref: remove star';
  }

  @override
  String syncOpSnooze(String ref) {
    return '$ref: snooze';
  }

  @override
  String syncOpCreate(String title) {
    return 'New task: $title';
  }

  @override
  String syncOpComment(String ref) {
    return '$ref: comment';
  }

  @override
  String syncOpTagAdd(String ref, String tag) {
    return '$ref: add #$tag';
  }

  @override
  String syncOpTagRemove(String ref, String tag) {
    return '$ref: remove #$tag';
  }

  @override
  String syncOpDependency(String ref, String other) {
    return '$ref: waits for $other';
  }

  @override
  String syncOpArtifact(String ref) {
    return '$ref: attachment';
  }

  @override
  String syncOpRestore(String ref) {
    return '$ref: restore';
  }

  @override
  String get syncDiscardTitle => 'Discard this change?';

  @override
  String get syncDiscard => 'Discard';

  @override
  String syncRefused(String reason) {
    return 'The server refused it: $reason';
  }

  @override
  String get syncCheckBody =>
      'The answer was lost, so this task may already exist. Look at the project, then send it or drop it.';

  @override
  String get syncSendAnyway => 'Send anyway';

  @override
  String get syncAlreadyThere => 'It\'s already there';

  @override
  String get syncRetry => 'Try again';

  @override
  String get syncKeptMine => 'Kept mine';

  @override
  String get syncKeptTheirs => 'Kept theirs';

  @override
  String get syncKeptEdited => 'Sent an edit';

  @override
  String get syncKeptRestored => 'Restored and applied';

  @override
  String get syncKeptDiscarded => 'Discarded mine';

  @override
  String syncByPolicy(String what) {
    return '$what, by your setting';
  }

  @override
  String get syncReverse => 'Reverse';

  @override
  String syncBannerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes wait to sync.',
      one: '1 change waits to sync.',
    );
    return '$_temp0';
  }

  @override
  String get syncBannerConflict => 'Your offline changes need a decision.';

  @override
  String get syncBannerDraft =>
      'Created offline. It gets its reference when it syncs.';

  @override
  String get syncResolve => 'Resolve';

  @override
  String syncBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflicts to resolve',
      one: '1 conflict to resolve',
    );
    return '$_temp0';
  }

  @override
  String get syncPolicyLabel => 'When a change conflicts';

  @override
  String get syncPolicyHelp =>
      'For changes made offline that someone else also changed. Every conflict is kept under Conflicts, where it can be reversed.';

  @override
  String get syncPolicyAsk => 'Ask';

  @override
  String get syncPolicyMine => 'Keep mine';

  @override
  String get syncPolicyTheirs => 'Keep theirs';

  @override
  String get syncOpenConflicts => 'Conflicts and unsynced changes';

  @override
  String get syncDiscardAll => 'Discard all unsynced changes';

  @override
  String get syncDiscardAllTitle => 'Discard every unsynced change?';

  @override
  String syncDiscardAllBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count changes made offline are dropped and never sent. Drafts disappear.',
      one: '1 change made offline is dropped and never sent. Drafts disappear.',
    );
    return '$_temp0';
  }
}
