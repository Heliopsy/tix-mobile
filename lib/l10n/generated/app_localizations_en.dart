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
      'Projects are created on the server, in the browser or with tix project add.';

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
}
