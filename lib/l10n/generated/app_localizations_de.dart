// SPDX-License-Identifier: AGPL-3.0-or-later

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'tix';

  @override
  String get connectTitle => 'Mit tix verbinden';

  @override
  String get connectAddTitle => 'Instanz hinzufügen';

  @override
  String get connectIntro =>
      'Verbinden Sie sich per API-Token oder Anmeldung mit einem tix-Server, oder öffnen Sie eine tix-Datenbank auf diesem Gerät.';

  @override
  String get serverUrlLabel => 'Serveradresse';

  @override
  String get serverUrlHint => 'https://tix.example.com';

  @override
  String get tokenLabel => 'API-Token';

  @override
  String get tokenHelp =>
      'Mit tix token create erstellen oder in der Web-App unter „Tokens“.';

  @override
  String get contextNameLabel => 'Name (optional)';

  @override
  String get contextNameHelp => 'Wird im Umschalter angezeigt.';

  @override
  String helpAbout(String topic) {
    return 'Hilfe: $topic';
  }

  @override
  String get helpServerBody =>
      'Ein tix-Server ist der Rechner, auf dem das tix Ihres Teams läuft. Seine Adresse ist die, mit der Sie tix im Webbrowser öffnen, etwa https://tix.example.com.\n\nSie kennen sie nicht? Fragen Sie die Person, die tix für Sie betreibt. https:// und den Schrägstrich am Ende können Sie weglassen.';

  @override
  String get helpKindTitle => 'Server oder dieses Gerät';

  @override
  String get helpKindBody =>
      'Server: Verbinden Sie sich mit einem tix, das jemand für Sie oder Ihr Team betreibt, und arbeiten Sie an denselben Aufgaben wie alle anderen dort.\n\nDieses Gerät: tix läuft in dieser App, mit einer Datenbank auf diesem Gerät. Kein Server und kein Konto nötig, und nichts wird mit anderen geteilt.';

  @override
  String get helpMethodTitle => 'Wie verbinden';

  @override
  String get helpMethodSignIn =>
      'Anmelden: mit der E-Mail-Adresse und dem Passwort, mit denen Sie sich bei tix im Web anmelden.';

  @override
  String get helpMethodToken =>
      'Token: Fügen Sie statt eines Passworts ein API-Token ein. Es bleibt verbunden, bis es widerrufen wird, und passt daher zu einem Gerät, das Sie behalten.';

  @override
  String get helpMethodInvite =>
      'Einladung: Sie haben eine Einladung per E-Mail bekommen? Fügen Sie den Link ein, der Server wird dann für Sie eingetragen.';

  @override
  String get helpTokenBody =>
      'Ein API-Token ist ein langer Code, mit dem diese App ohne Ihr Passwort hineinkommt.\n\nErstellen Sie eines auf der Seite „API-Tokens“ von tix im Web, oder führen Sie tix token create dort aus, wo der Befehl tix funktioniert. Kopieren Sie es, sobald es angezeigt wird: Sie sehen es nur einmal.';

  @override
  String get helpEmailBody =>
      'Die E-Mail-Adresse Ihres tix-Kontos, mit der Sie sich bei tix im Web anmelden.';

  @override
  String get helpPasswordBody =>
      'Ihr tix-Passwort, dasselbe wie im Web. Vergessen? Die Person, die Ihr tix betreibt, kann es zurücksetzen.';

  @override
  String get helpInviteBody =>
      'Wenn Sie jemand zu tix einlädt, bekommen Sie eine E-Mail mit einem Link. Fügen Sie den Link hier ein, oder teilen Sie ihn aus Ihrer Mail-App mit tix.\n\nDie Adresse des Servers steckt im Link, Sie müssen sie also nicht eintippen.';

  @override
  String get helpNameBody =>
      'Ein Name für diese Verbindung, nur in dieser App sichtbar. Praktisch, wenn Sie mehr als einen Server oder ein Konto nutzen. Leer lassen, um die Adresse des Servers zu verwenden.';

  @override
  String get helpTenantTitle => 'Mandanten';

  @override
  String get helpTenantBody =>
      'Ein tix kann mehrere getrennte Arbeitsbereiche enthalten, sogenannte Mandanten, etwa einen pro Firma oder Team. Jeder hat eigene Projekte und Personen.\n\nWählen Sie den, der geöffnet werden soll. Die anderen können Sie später hinzufügen.';

  @override
  String get connectButton => 'Verbinden';

  @override
  String get projectsTitle => 'Projekte';

  @override
  String get projectsEmpty => 'Noch keine Projekte.';

  @override
  String get tasksEmpty => 'Keine Aufgaben in diesem Projekt.';

  @override
  String get taskTitle => 'Aufgabe';

  @override
  String get fieldStatus => 'Status';

  @override
  String get fieldAssignee => 'Zuständig';

  @override
  String get fieldDue => 'Fällig';

  @override
  String get fieldPriority => 'Priorität';

  @override
  String get fieldTags => 'Tags';

  @override
  String get fieldDescription => 'Beschreibung';

  @override
  String get unassigned => 'Nicht zugewiesen';

  @override
  String get noDueDate => 'Kein Fälligkeitsdatum';

  @override
  String get noDescription => 'Keine Beschreibung.';

  @override
  String priorityLabel(String priority) {
    String _temp0 = intl.Intl.selectLogic(priority, {
      '1': 'Sehr hoch',
      '2': 'Hoch',
      '3': 'Normal',
      '4': 'Niedrig',
      '5': 'Sehr niedrig',
      'other': 'Keine',
    });
    return '$_temp0';
  }

  @override
  String get quickAddTitle => 'Schnell hinzufügen';

  @override
  String get quickAddHint => 'Login reparieren !high #auth @raj due:fri';

  @override
  String get quickAddHelp => '!priority  #tag  @assignee  due:date  ^parent';

  @override
  String get quickAddButton => 'Hinzufügen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String taskCreated(String ref) {
    return '$ref erstellt';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get themeLabel => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get signOut => 'Abmelden';

  @override
  String signOutBody(String server) {
    return 'Die Verbindung zu $server wird auf diesem Gerät entfernt.';
  }

  @override
  String signedInAs(String handle) {
    return 'Angemeldet als $handle';
  }

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get loadMoreFailed => 'Weitere Einträge konnten nicht geladen werden.';

  @override
  String errorInvalid(String message) {
    return 'Der Server hat das abgelehnt: $message';
  }

  @override
  String get errorUnauthenticated =>
      'Der Server hat diese Verbindung nicht akzeptiert. Prüfen Sie den Token oder melden Sie sich erneut an.';

  @override
  String get errorForbidden => 'Dieser Token ist dafür nicht berechtigt.';

  @override
  String get errorNotFound => 'Nicht gefunden.';

  @override
  String get errorConflict =>
      'Jemand hat das gleichzeitig geändert. Neu laden und erneut versuchen.';

  @override
  String errorPrecondition(String message) {
    return 'Das ist gerade nicht möglich: $message';
  }

  @override
  String get errorServer =>
      'Auf dem Server ist ein Problem aufgetreten. Versuchen Sie es später erneut.';

  @override
  String get errorNetwork =>
      'Server nicht erreichbar. Prüfen Sie die Adresse und Ihre Verbindung.';

  @override
  String get errorTimeout => 'Der Server hat zu lange nicht geantwortet.';

  @override
  String get errorNotTix => 'Unter dieser Adresse antwortet kein tix-Server.';

  @override
  String get errorBadUrl =>
      'Geben Sie eine Serveradresse ein, z. B. https://tix.example.com.';

  @override
  String get errorTokenRequired => 'Geben Sie einen API-Token ein.';

  @override
  String get errorUnknown => 'Etwas ist schiefgelaufen.';

  @override
  String errorRequestId(String id) {
    return 'Anfrage $id.';
  }

  @override
  String get instanceRemote => 'Server';

  @override
  String get instanceLocal => 'Dieses Gerät';

  @override
  String get localUnavailableNote =>
      'Datenbanken auf diesem Gerät benötigen die in die App integrierte tix-Engine, und dieser Build enthält sie nicht.';

  @override
  String get methodToken => 'Token';

  @override
  String get methodSignIn => 'Anmelden';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get signInHelp =>
      'Sitzungen gelten etwa 12 Stunden. Für ein Gerät, das verbunden bleiben soll, einen Token verwenden.';

  @override
  String get signInButton => 'Anmelden';

  @override
  String get localIntro =>
      'Erstellen Sie eine neue tix-Datenbank oder öffnen Sie eine vorhandene.';

  @override
  String get dbNameLabel => 'Datenbankname';

  @override
  String get dbNameHelp => 'Wird im Dokumentordner dieser App erstellt.';

  @override
  String get localNewFile => 'Neue Datenbank…';

  @override
  String get localCreate => 'Datenbank erstellen';

  @override
  String get localOpenFile => 'Datenbankdatei öffnen…';

  @override
  String get localListTenants => 'Mandanten anzeigen';

  @override
  String get codeIntro =>
      'Dieses Konto nutzt einen zweiten Faktor. Geben Sie den Code aus Ihrer Authenticator-App ein.';

  @override
  String get codeLabel => 'Code';

  @override
  String get codeHelp =>
      'Sechs Ziffern oder einer Ihrer Wiederherstellungscodes.';

  @override
  String get verifyButton => 'Bestätigen';

  @override
  String get chooseTenantIntro =>
      'Sie gehören hier zu mehreren Mandanten. Welchen soll diese Verbindung öffnen?';

  @override
  String get pinLabel => 'An diesen Mandanten anheften';

  @override
  String get pinOnHelp =>
      'Die Verbindung bleibt bei diesem Mandanten. Für einen anderen Mandanten eine weitere Verbindung hinzufügen.';

  @override
  String get pinOffHelp =>
      'Über den Umschalter zwischen Ihren Mandanten wechseln.';

  @override
  String get openButton => 'Öffnen';

  @override
  String get localTenantsIntro => 'Einen Mandanten dieser Datenbank öffnen.';

  @override
  String get newTenantTitle => 'Neuer Mandant';

  @override
  String get tenantKeyLabel => 'Schlüssel';

  @override
  String get tenantNameLabel => 'Name';

  @override
  String get createTenantButton => 'Erstellen und öffnen';

  @override
  String servedAt(String host) {
    return 'Bereitgestellt unter $host';
  }

  @override
  String get addAsInstance => 'Hinzufügen';

  @override
  String get instancesTitle => 'Instanzen';

  @override
  String get addInstance => 'Instanz hinzufügen';

  @override
  String get instancesEmpty => 'Noch keine Instanzen.';

  @override
  String get removeInstance => 'Instanz entfernen';

  @override
  String removeInstanceBody(String name) {
    return '$name und alle Verbindungen dazu werden von diesem Gerät entfernt. Auf dem Server ändert sich nichts.';
  }

  @override
  String get remove => 'Entfernen';

  @override
  String get removeConnection => 'Verbindung entfernen';

  @override
  String removeConnectionBody(String name) {
    return '$name wird von diesem Gerät entfernt.';
  }

  @override
  String get openTenant => 'Mandant öffnen';

  @override
  String get addConnection => 'Verbindung hinzufügen';

  @override
  String get useConnection => 'Verwenden';

  @override
  String get makeSwitchable => 'Umschaltbar machen';

  @override
  String get pin => 'An aktuellen Mandanten anheften';

  @override
  String get signInAgain => 'Erneut anmelden';

  @override
  String get switchable => 'Umschaltbar';

  @override
  String get pinned => 'Angeheftet';

  @override
  String get switchContext => 'Instanz oder Mandant wechseln';

  @override
  String get recentContexts => 'Zuletzt verwendet';

  @override
  String get manageInstances => 'Instanzen verwalten';

  @override
  String instanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Instanzen',
      one: '1 Instanz',
      zero: 'Keine Instanzen',
    );
    return '$_temp0';
  }

  @override
  String get errorBadCredentials =>
      'E-Mail oder Passwort wurden nicht akzeptiert.';

  @override
  String get errorEmailRequired => 'Geben Sie Ihre E-Mail-Adresse ein.';

  @override
  String get errorPasswordRequired => 'Geben Sie Ihr Passwort ein.';

  @override
  String get errorCodeRequired =>
      'Geben Sie den Code aus Ihrer Authenticator-App ein.';

  @override
  String get errorSecondFactorSetup =>
      'Für dieses Konto muss zuerst ein zweiter Faktor eingerichtet werden. Melden Sie sich dazu einmal im Browser an.';

  @override
  String get errorPasswordChange =>
      'Für dieses Konto muss zuerst ein neues Passwort gewählt werden. Melden Sie sich dazu einmal im Browser an.';

  @override
  String get errorTenantRequired =>
      'Geben Sie einen Schlüssel für den Mandanten ein.';

  @override
  String get errorEngineUnavailable =>
      'Datenbanken auf diesem Gerät sind nicht verfügbar: Dieser Build enthält die tix-Engine nicht.';

  @override
  String get localIntroImport =>
      'Erstellen Sie eine neue tix-Datenbank oder importieren Sie eine. Die App arbeitet mit einer eigenen Kopie innerhalb der App; exportieren Sie sie, um Ihre Änderungen woanders zu nutzen.';

  @override
  String get localOpenInPlace =>
      'Die Datei bleibt, wo sie ist, und Änderungen werden direkt darin gespeichert.';

  @override
  String get localImportFile => 'Datenbankdatei importieren…';

  @override
  String get exportDatabase => 'Datenbank exportieren…';

  @override
  String get databaseExported => 'Datenbank exportiert.';

  @override
  String get localCopyNote => 'Kopie in der App';

  @override
  String get back => 'Zurück';

  @override
  String get undo => 'Rückgängig';

  @override
  String get close => 'Schließen';

  @override
  String get loading => 'Wird geladen';

  @override
  String get moreInfo => 'Weitere Informationen';

  @override
  String get dueOverdue => 'überfällig';

  @override
  String get dueToday => 'heute fällig';

  @override
  String dueOn(String date) {
    return 'fällig $date';
  }

  @override
  String snoozedUntil(String date) {
    return 'zurückgestellt bis $date';
  }

  @override
  String get blockedByOther => 'Wartet auf eine andere Aufgabe';

  @override
  String get starred => 'Favorit';

  @override
  String get star => 'Zu Favoriten';

  @override
  String get unstar => 'Aus Favoriten';

  @override
  String get complete => 'Erledigen';

  @override
  String get reopen => 'Wieder öffnen';

  @override
  String get markDone => 'Als erledigt markieren';

  @override
  String get snooze => 'Zurückstellen';

  @override
  String get assign => 'Zuweisen';

  @override
  String get filterHint => 'Filtern, z. B. status:todo tag:ops';

  @override
  String get shortcutsTitle => 'Tastenkürzel';

  @override
  String get showShortcuts => 'Tastenkürzel anzeigen';

  @override
  String get openCommandPalette => 'Befehlspalette öffnen';

  @override
  String get commandSearchHint => 'Befehl eingeben';

  @override
  String get commandNone => 'Kein passender Befehl.';

  @override
  String get goProjects => 'Zu Projekten';

  @override
  String get goSettings => 'Zu Einstellungen';

  @override
  String get goInstances => 'Zu Instanzen';

  @override
  String get commandsNavigate => 'Navigieren';

  @override
  String get commandsTasks => 'Aufgaben';

  @override
  String get newTask => 'Neue Aufgabe';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get projectsEmptyBody =>
      'Legen Sie eines mit „Neues Projekt“ an, im Browser oder mit tix project add.';

  @override
  String get tasksEmptyBody =>
      'Eine Aufgabe in einer Zeile hinzufügen: ein Titel, dann !high, #tag, @handle oder due:fri.';

  @override
  String get instancesEmptyBody =>
      'Fügen Sie den tix-Server hinzu, mit dem Sie arbeiten, oder eine Datenbank auf diesem Gerät.';

  @override
  String projectsSubtitle(String tenant) {
    return 'Alle Projekte in $tenant';
  }

  @override
  String get aboutTitle => 'Über';

  @override
  String get appearanceLabel => 'Darstellung';

  @override
  String get accountLabel => 'Konto';

  @override
  String get galleryTitle => 'Komponenten';

  @override
  String taskDetailActionsFor(String ref) {
    return 'Aktionen für $ref';
  }

  @override
  String get taskDetailActorSearch => 'Nach Name oder Handle suchen';

  @override
  String get taskDetailAdd => 'Hinzufügen';

  @override
  String get taskDetailAddDependency => 'Abhängigkeit hinzufügen';

  @override
  String get taskDetailAddSubtask => 'Unteraufgabe hinzufügen';

  @override
  String get taskDetailAddTag => 'Tag hinzufügen';

  @override
  String get taskDetailArtifactFile => 'Datei';

  @override
  String get taskDetailArtifactLog => 'Log';

  @override
  String get taskDetailArtifactMetric => 'Metrik';

  @override
  String get taskDetailArtifactResult => 'Ergebnis';

  @override
  String get taskDetailArtifacts => 'Artefakte';

  @override
  String get taskDetailArtifactSave => 'Speichern';

  @override
  String get taskDetailArtifactShow => 'Anzeigen';

  @override
  String get taskDetailArtifactUnreadable =>
      'Der Inhalt dieses Artefakts kann nicht gelesen werden.';

  @override
  String get taskDetailAssigneeTitle => 'Zuweisen';

  @override
  String taskDetailAttached(String name) {
    return '$name angehängt.';
  }

  @override
  String get taskDetailAttachFile => 'Datei anhängen';

  @override
  String get taskDetailBlocked =>
      'Blockiert: wartet auf eine Aufgabe, die noch nicht abgeschlossen ist.';

  @override
  String taskDetailChecklist(int done, int total) {
    return '$done von $total erledigt';
  }

  @override
  String get taskDetailClear => 'Leeren';

  @override
  String get taskDetailCommands => 'Aufgabe';

  @override
  String get taskDetailCommentActions => 'Kommentaraktionen';

  @override
  String get taskDetailCommentAdded => 'Kommentar hinzugefügt.';

  @override
  String get taskDetailCommentDelete => 'Kommentar löschen';

  @override
  String get taskDetailCommentDeleteBody =>
      'Er verschwindet für alle. Das kann hier nicht rückgängig gemacht werden.';

  @override
  String get taskDetailCommentDeleted => 'Kommentar gelöscht.';

  @override
  String get taskDetailCommentDeleteTitle => 'Diesen Kommentar löschen?';

  @override
  String get taskDetailCommentEdit => 'Kommentar bearbeiten';

  @override
  String get taskDetailCommentHint =>
      'Markdown wird unterstützt. Mit @ jemanden erwähnen.';

  @override
  String get taskDetailCommentLabel => 'Kommentar';

  @override
  String get taskDetailComments => 'Kommentare';

  @override
  String get taskDetailCommentSend => 'Kommentieren';

  @override
  String taskDetailCopied(String ref) {
    return 'Kopiert als $ref.';
  }

  @override
  String get taskDetailCopiedFrom => 'Kopiert von';

  @override
  String get taskDetailCopyAction => 'Kopieren';

  @override
  String get taskDetailCopyComments => 'Kommentare mitkopieren';

  @override
  String get taskDetailCopyDependencies => 'Abhängigkeiten mitkopieren';

  @override
  String get taskDetailCopyKeepStatus => 'Status beibehalten';

  @override
  String get taskDetailCopyLink => 'Kopie mit dieser Aufgabe verknüpfen';

  @override
  String get taskDetailCopyNewTitle => 'Titel der Kopie';

  @override
  String get taskDetailCopyProject => 'Projekt';

  @override
  String get taskDetailCopyRef => 'Referenz kopieren';

  @override
  String get taskDetailCopySubtasks => 'Unteraufgaben mitkopieren';

  @override
  String taskDetailCopyTitle(String ref) {
    return '$ref kopieren';
  }

  @override
  String get taskDetailCopyTo => 'Kopieren nach…';

  @override
  String get taskMoveToProject => 'In Projekt verschieben…';

  @override
  String taskMoveToProjectTitle(String ref) {
    return '$ref in ein anderes Projekt verschieben';
  }

  @override
  String taskMoveToProjectBody(String ref, String project) {
    return '$ref bekommt die nächste Nummer in $project, und $ref führt weiterhin zu ihr. Kommentare, Verlauf, Verknüpfungen, Tags und die Zuweisung gehen mit. Der Status bleibt, wenn der Workflow von $project einen gleichnamigen hat, sonst beginnt sie im ersten Status. Benutzerdefinierte Felder, die $project nicht kennt, bleiben zurück.';
  }

  @override
  String get taskMoveToProjectPick => 'Wähle das Projekt, in das sie wandert.';

  @override
  String get taskMoveToProjectAction => 'Verschieben';

  @override
  String get taskMoveToProjectNone =>
      'Es gibt kein anderes Projekt, in das verschoben werden kann.';

  @override
  String taskMovedToProject(String from, String to) {
    return '$from ist jetzt $to.';
  }

  @override
  String get taskMovedToProjectStatus =>
      'Sie beginnt im ersten Status des Projekts.';

  @override
  String taskMovedToProjectDropped(String fields) {
    return 'Zurückgelassen: $fields.';
  }

  @override
  String get taskMoveUnsupported =>
      'Dieser Server kann Aufgaben nicht in ein anderes Projekt verschieben.';

  @override
  String get taskMoveKeywords => 'verschieben projekt übertragen move project';

  @override
  String bulkMoveProjectTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben in ein anderes Projekt verschieben',
      one: '1 Aufgabe in ein anderes Projekt verschieben',
    );
    return '$_temp0';
  }

  @override
  String bulkMoveProjectBody(String project) {
    return 'Jede Aufgabe bekommt die nächste Nummer in $project, und ihre alte Referenz führt weiterhin zu ihr. Ein Status, den der Workflow von $project nicht kennt, beginnt im ersten Status, und Felder, die $project nicht kennt, bleiben zurück. Rückgängig gibt es nicht.';
  }

  @override
  String taskDetailCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben',
      one: '1 Aufgabe',
    );
    return '$_temp0';
  }

  @override
  String get taskDetailCreated => 'Erstellt';

  @override
  String get taskDetailCurrent => 'Aktuell';

  @override
  String get taskDetailDelete => 'Löschen';

  @override
  String taskDetailDeleted(String ref) {
    return '$ref gelöscht.';
  }

  @override
  String get taskDetailDeleteForGood => 'Endgültig löschen';

  @override
  String get taskDetailDeletePermanentBody =>
      'Sie wird endgültig entfernt, samt Kommentaren und Verlauf.';

  @override
  String taskDetailDeleteSubtasksBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ihre $count Unteraufgaben werden mitgelöscht.',
      one: 'Ihre Unteraufgabe wird mitgelöscht.',
    );
    return '$_temp0';
  }

  @override
  String taskDetailDeleteTitle(String ref) {
    return '$ref löschen?';
  }

  @override
  String get taskDetailDeleteTrashBody =>
      'Sie kommt in den Papierkorb und kann wiederhergestellt werden.';

  @override
  String get taskDetailDependencies => 'Wartet auf';

  @override
  String get taskDetailDependenciesInfo =>
      'Diese Aufgabe gilt als blockiert, bis jede hier aufgeführte Aufgabe einen abgeschlossenen Status erreicht.';

  @override
  String taskDetailDependencyAdded(String ref) {
    return 'Wartet jetzt auf $ref.';
  }

  @override
  String taskDetailDependencyRemoved(String ref) {
    return 'Wartet nicht mehr auf $ref.';
  }

  @override
  String get taskDetailDependsOn => 'Hängt ab von';

  @override
  String get taskDetailDependsOnHint => 'Eine Referenz, z. B. infra-2';

  @override
  String get taskDetailDescriptionHint =>
      'Markdown. - [ ] erzeugt einen Checklisteneintrag.';

  @override
  String get taskDetailDueClear => 'Kein Fälligkeitsdatum';

  @override
  String get taskDetailDueNextWeek => 'Nächste Woche';

  @override
  String get taskDetailDueTitle => 'Fälligkeitsdatum';

  @override
  String get taskDetailDueToday => 'Heute';

  @override
  String get taskDetailDueTomorrow => 'Morgen';

  @override
  String get taskDetailEdit => 'Bearbeiten';

  @override
  String get taskDetailEditDescription => 'Beschreibung bearbeiten';

  @override
  String get taskDetailEdited => 'bearbeitet';

  @override
  String taskDetailEditField(String name) {
    return '$name ändern';
  }

  @override
  String get taskDetailFileTooBig =>
      'Dateien über 1 MiB können nicht angehängt werden.';

  @override
  String get taskDetailHistory => 'Verlauf';

  @override
  String taskDetailHistoryChanged(String fields) {
    return 'hat $fields geändert';
  }

  @override
  String get taskDetailHistoryCreated => 'hat die Aufgabe erstellt';

  @override
  String get taskDetailHistoryDeleted => 'hat die Aufgabe gelöscht';

  @override
  String get taskDetailHistoryMore => 'Ältere anzeigen';

  @override
  String taskDetailHistoryMoved(String from, String to) {
    return 'hat sie von $from nach $to verschoben';
  }

  @override
  String get taskDetailHistoryRestored => 'hat die Aufgabe wiederhergestellt';

  @override
  String get taskDetailJsonHelp =>
      'Ein JSON-Wert: eine Zahl, ein String in Anführungszeichen, eine Liste oder ein Objekt';

  @override
  String get taskDetailMove => 'Verschieben';

  @override
  String get taskDetailMoveComment => 'Kommentar';

  @override
  String get taskDetailMoveCommentHelp =>
      'Für diesen Statuswechsel ist ein Kommentar mit Begründung nötig.';

  @override
  String taskDetailMoved(String ref, String status) {
    return '$ref nach $status verschoben.';
  }

  @override
  String get taskDetailMoveFrom => 'Von';

  @override
  String get taskDetailMoveNeedsComment => 'Kommentar erforderlich';

  @override
  String taskDetailMoveStopped(String state, String reason) {
    return 'Vor $state angehalten: $reason';
  }

  @override
  String get taskDetailMoveTitle => 'Verschieben';

  @override
  String taskDetailMoveTo(String state) {
    return 'Nach $state verschieben';
  }

  @override
  String taskDetailMoveVia(String states) {
    return 'über $states';
  }

  @override
  String get taskDetailNo => 'Nein';

  @override
  String get taskDetailNoArtifacts => 'Keine Artefakte.';

  @override
  String get taskDetailNoComments => 'Noch keine Kommentare.';

  @override
  String get taskDetailNoDependencies => 'Wartet auf nichts.';

  @override
  String get taskDetailNoHistory => 'Kein Verlauf.';

  @override
  String get taskDetailNoMoves =>
      'Der Workflow erlaubt von hier aus keinen Wechsel.';

  @override
  String get taskDetailNoRepeat => 'Keine Wiederholung';

  @override
  String get taskDetailNoSubtasks => 'Keine Unteraufgaben.';

  @override
  String get taskDetailOpen => 'Öffnen';

  @override
  String get taskDetailParent => 'Unteraufgabe von';

  @override
  String get taskDetailPickDate => 'Datum wählen…';

  @override
  String get taskDetailPickDateTime => 'Datum und Uhrzeit wählen…';

  @override
  String get taskDetailPreview => 'Vorschau';

  @override
  String get taskDetailPriorityTitle => 'Priorität';

  @override
  String get taskDetailProject => 'Projekt';

  @override
  String get taskDetailRefCopied => 'Referenz kopiert.';

  @override
  String taskDetailRemoveDependency(String ref) {
    return 'Nicht mehr auf $ref warten';
  }

  @override
  String taskDetailRemoveTag(String tag) {
    return '$tag entfernen';
  }

  @override
  String get taskDetailRename => 'Umbenennen';

  @override
  String get taskDetailRepeat => 'Wiederholung';

  @override
  String get taskDetailRepeatHelp =>
      'every day, every 2 weeks on mon,thu, every month on day 31, 3 days after done';

  @override
  String get taskDetailRepeatHint => 'every week';

  @override
  String get taskDetailRepeatInfo =>
      'Wird eine Aufgabe mit Regel abgeschlossen, entsteht sofort die nächste. Beim Abbrechen nicht. Leer beendet die Wiederholung.';

  @override
  String get taskDetailRepeats => 'Wiederholung';

  @override
  String get taskDetailRepeatTitle => 'Wiederholungsregel';

  @override
  String get taskDetailSave => 'Speichern';

  @override
  String get taskDetailSaved => 'Gespeichert.';

  @override
  String get taskDetailSnooze => 'Zurückstellen';

  @override
  String taskDetailSnoozed(String when) {
    return 'Zurückgestellt bis $when.';
  }

  @override
  String get taskDetailSnoozeLater => 'Später heute';

  @override
  String get taskDetailSnoozeNextWeek => 'Nächste Woche';

  @override
  String get taskDetailSnoozeTitle => 'Zurückstellen bis';

  @override
  String get taskDetailSnoozeTomorrow => 'Morgen früh';

  @override
  String get taskDetailStar => 'Zu Favoriten';

  @override
  String get taskDetailStarred => 'Zu Favoriten hinzugefügt.';

  @override
  String get taskDetailSubtaskAdded => 'Unteraufgabe hinzugefügt.';

  @override
  String get taskDetailSubtasks => 'Unteraufgaben';

  @override
  String get taskDetailSystem => 'tix';

  @override
  String taskDetailTagAdded(String name) {
    return 'Tag $name hinzugefügt.';
  }

  @override
  String get taskDetailTagHint => 'Ein neuer Name legt den Tag an';

  @override
  String taskDetailTagRemoved(String name) {
    return '$name entfernt.';
  }

  @override
  String get taskDetailTakePhoto => 'Foto aufnehmen';

  @override
  String get taskDetailTitleLabel => 'Titel';

  @override
  String get taskDetailUnassign => 'Zuweisung aufheben';

  @override
  String get taskDetailUnstar => 'Aus Favoriten entfernen';

  @override
  String get taskDetailUnstarred => 'Aus Favoriten entfernt.';

  @override
  String get taskDetailUpdated => 'Aktualisiert';

  @override
  String get taskDetailWake => 'Jetzt aufwecken';

  @override
  String get taskDetailWoken => 'Wieder in den Listen.';

  @override
  String get taskDetailWrite => 'Schreiben';

  @override
  String get taskDetailYes => 'Ja';

  @override
  String get boardAllEmpty => 'Noch keine Aufgaben.';

  @override
  String get boardAllEmptyBody =>
      'Hier erscheinen Aufgaben aus allen Projekten.';

  @override
  String get boardArrangement => 'Anordnung';

  @override
  String get boardAssignMe => 'Mir zuweisen';

  @override
  String boardAssignedToMe(String ref) {
    return '$ref Ihnen zugewiesen';
  }

  @override
  String get boardCollapse => 'Einklappen';

  @override
  String get boardColumnEmpty => 'Hier ist nichts';

  @override
  String boardCompleted(String ref) {
    return '$ref erledigt';
  }

  @override
  String tasksHeldByAgent(int count) {
    return '$count von einem Agenten gehalten';
  }

  @override
  String boardCount(int count, String more) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count$more Aufgaben',
      one: '1$more Aufgabe',
    );
    return '$_temp0';
  }

  @override
  String get boardExpand => 'Ausklappen';

  @override
  String boardGroupMenu(String group) {
    return '$group anordnen';
  }

  @override
  String boardHiddenCount(int count) {
    return 'Ausgeblendet: $count';
  }

  @override
  String get boardHide => 'Ausblenden';

  @override
  String get boardLoadMore => 'Mehr laden';

  @override
  String get boardMoveDown => 'Nach unten';

  @override
  String get boardMoveLeft => 'Nach links';

  @override
  String get boardMoveRight => 'Nach rechts';

  @override
  String boardMoveTitle(String ref) {
    return '$ref verschieben nach';
  }

  @override
  String get boardMoveTo => 'Verschieben nach…';

  @override
  String get boardMoveUp => 'Nach oben';

  @override
  String boardMoved(String ref, String status) {
    return '$ref nach $status verschoben';
  }

  @override
  String get boardNext => 'Nächste Aufgabe';

  @override
  String boardNoRoute(String ref) {
    return 'Für $ref gibt es in ihrem Workflow keinen Weg dorthin';
  }

  @override
  String get boardOpen => 'Öffnen';

  @override
  String get boardPrevious => 'Vorherige Aufgabe';

  @override
  String get boardRefused =>
      'Diese Projekte nutzen unterschiedliche Workflows und können daher kein gemeinsames Board haben. Grenzen Sie den Filter auf Projekte eines Workflows ein, um ein Board zu sehen.';

  @override
  String boardRefusedGroup(String workflow, String projects) {
    return '$workflow: $projects';
  }

  @override
  String boardReopened(String ref) {
    return '$ref wieder geöffnet';
  }

  @override
  String get boardResetArrangement => 'Anordnung zurücksetzen';

  @override
  String boardShowGroup(String group) {
    return '$group anzeigen';
  }

  @override
  String get boardSnoozeLater => 'Später heute';

  @override
  String boardSnoozeTitle(String ref) {
    return '$ref zurückstellen bis';
  }

  @override
  String get boardSnoozeTomorrow => 'Morgen früh';

  @override
  String get boardSnoozeWeek => 'Nächste Woche';

  @override
  String boardSnoozed(String ref) {
    return '$ref zurückgestellt';
  }

  @override
  String boardStarred(String ref) {
    return '$ref als Favorit markiert';
  }

  @override
  String boardStrays(String refs) {
    return 'Nicht in den Spalten dieses Boards: $refs';
  }

  @override
  String get boardSwitchProject => 'Projekt wechseln';

  @override
  String boardUnstarred(String ref) {
    return '$ref aus Favoriten entfernt';
  }

  @override
  String get boardWake => 'Jetzt aufwecken';

  @override
  String boardWoken(String ref) {
    return '$ref ist wieder aktiv';
  }

  @override
  String get bulkClear => 'Auswahl aufheben';

  @override
  String get bulkCopy => 'Kopieren nach…';

  @override
  String bulkCopyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben kopieren nach',
      one: '1 Aufgabe kopieren nach',
    );
    return '$_temp0';
  }

  @override
  String get bulkDelete => 'Löschen';

  @override
  String get bulkDeleteBody =>
      'Sie kommen in den Papierkorb, mit „Rückgängig“ holen Sie sie zurück.';

  @override
  String bulkDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben löschen?',
      one: '1 Aufgabe löschen?',
    );
    return '$_temp0';
  }

  @override
  String bulkDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben geändert',
      one: '1 Aufgabe geändert',
    );
    return '$_temp0';
  }

  @override
  String get bulkExit => 'Auswahlmodus beenden';

  @override
  String get bulkExtendDown => 'Auswahl nach unten erweitern';

  @override
  String get bulkExtendUp => 'Auswahl nach oben erweitern';

  @override
  String get bulkMove => 'Verschieben';

  @override
  String bulkMoveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben verschieben nach',
      one: '1 Aufgabe verschieben nach',
    );
    return '$_temp0';
  }

  @override
  String bulkPartly(int count, String refused) {
    return '$count geändert. Abgelehnt: $refused';
  }

  @override
  String get bulkSelect => 'Auswählen';

  @override
  String get bulkSelectAll => 'Alle auswählen';

  @override
  String get bulkSelectMode => 'Aufgaben auswählen';

  @override
  String bulkSelected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get bulkTagAdd => 'Tag hinzufügen';

  @override
  String get bulkTagRemove => 'Tag entfernen';

  @override
  String get filterBlocked => 'Blockiert';

  @override
  String get filterClear => 'Leeren';

  @override
  String get filterDelete => 'Filter löschen';

  @override
  String get filterDeleteBody =>
      'Alle, mit denen er geteilt wurde, verlieren ihn ebenfalls.';

  @override
  String filterDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get filterDueToday => 'Heute fällig';

  @override
  String get filterDueWeek => 'Diese Woche fällig';

  @override
  String get filterFinished => 'Abgeschlossen';

  @override
  String get filterFocus => 'Aufgaben filtern';

  @override
  String get filterMine => 'Meine';

  @override
  String get filterName => 'Name';

  @override
  String get filterNoMatch => 'Nichts passt zu diesem Filter.';

  @override
  String get filterNoMatchBody => 'Ändern oder leeren Sie den Filter.';

  @override
  String get filterOverdue => 'Überfällig';

  @override
  String get filterRename => 'Umbenennen';

  @override
  String get filterSave => 'Filter speichern';

  @override
  String get filterSaveTitle => 'Diesen Filter speichern';

  @override
  String filterSaved(String name) {
    return '$name gespeichert';
  }

  @override
  String get filterShare => 'Mit allen teilen';

  @override
  String get filterShared => 'Mit allen im Mandanten teilen';

  @override
  String get filterSharedHelp =>
      'Andere sehen ihn unter ihren gespeicherten Filtern; nur Sie und Administratoren können ihn ändern.';

  @override
  String get filterSnoozed => 'Zurückgestellt';

  @override
  String get filterUnshare => 'Nicht mehr teilen';

  @override
  String get goMyWork => 'Zu „Meine Arbeit“';

  @override
  String get goTasks => 'Zu „Aufgaben“';

  @override
  String get groupNone => 'Keine Gruppierung';

  @override
  String get groupProject => 'Nach Projekt gruppieren';

  @override
  String get groupStatus => 'Nach Status gruppieren';

  @override
  String get lanesEmpty => 'Keine Aufgaben';

  @override
  String get lanesGroupBy => 'Bahnen gruppieren nach';

  @override
  String get lanesByProject => 'Projekt';

  @override
  String get lanesByTag => 'Tag';

  @override
  String get lanesNoTag => 'Ohne Tag';

  @override
  String lanesOnly(String name) {
    return 'Nur Aufgaben in $name';
  }

  @override
  String get myWorkEmpty => 'Ihnen ist nichts zugewiesen.';

  @override
  String get myWorkEmptyBody =>
      'Offene Aufgaben, die Ihnen zugewiesen sind, erscheinen hier nach Frist sortiert.';

  @override
  String get myWorkLater => 'Später';

  @override
  String get myWorkNoDate => 'Kein Datum';

  @override
  String get myWorkOverdue => 'Überfällig';

  @override
  String get myWorkTitle => 'Meine Arbeit';

  @override
  String get myWorkToday => 'Heute';

  @override
  String get myWorkWeek => 'Diese Woche';

  @override
  String projectOpenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offene Aufgaben',
      one: '1 offene Aufgabe',
    );
    return '$_temp0';
  }

  @override
  String get sortCreated => 'Erstellt';

  @override
  String get sortDescending => 'Absteigend';

  @override
  String get sortMenu => 'Sortieren und gruppieren';

  @override
  String get sortNumber => 'Nummer';

  @override
  String get sortTitle => 'Titel';

  @override
  String get sortUpdated => 'Aktualisiert';

  @override
  String get sortUrgency => 'Dringlichkeit';

  @override
  String get tasksTitle => 'Aufgaben';

  @override
  String get viewBoard => 'Board';

  @override
  String get viewLanes => 'Bahnen';

  @override
  String get viewList => 'Liste';

  @override
  String get viewSwitch => 'Ansicht wechseln';

  @override
  String boardAssigned(String ref) {
    return '$ref zugewiesen';
  }

  @override
  String get boardAssignTo => 'Zuweisen an…';

  @override
  String get quickAddProject => 'Projekt';

  @override
  String get quickAddPickProject => 'Projekt wählen';

  @override
  String get quickAddNoProjects =>
      'Es gibt noch kein Projekt, zu dem Sie etwas hinzufügen können.';

  @override
  String get quickAddAnother => 'Weitere hinzufügen';

  @override
  String get quickAddAnotherHelp => 'Für die nächste Zeile geöffnet lassen';

  @override
  String quickAddPreviewRefused(String reason) {
    return 'Der Server würde das ablehnen: $reason';
  }

  @override
  String get quickAddPreviewOff =>
      'Diese Verbindung kann keine Vorschau anzeigen; Hinzufügen funktioniert trotzdem.';

  @override
  String get quickAddOffline =>
      'Zum Hinzufügen ist eine Verbindung zum Server nötig. Die Zeile bleibt erhalten; versuchen Sie es erneut, wenn Sie online sind.';

  @override
  String get quickAddChipPriority => 'Priorität';

  @override
  String get quickAddChipTag => 'Tag';

  @override
  String get quickAddChipAssignee => 'zuständig';

  @override
  String get quickAddChipDue => 'fällig';

  @override
  String get quickAddChipStatus => 'Status';

  @override
  String get quickAddChipParent => 'übergeordnet';

  @override
  String get quickAddChipTitle => 'Titel';

  @override
  String get quickAddSuggestions => 'Vorschläge';

  @override
  String get quickAddTemplates => 'Aus Vorlage';

  @override
  String get quickAddManageTemplates => 'Vorlagen';

  @override
  String get quickAddPaste => 'Aus Zwischenablage hinzufügen';

  @override
  String get quickAddClipboardEmpty =>
      'Die Zwischenablage enthält keinen Text.';

  @override
  String get paletteGroupProjects => 'Projekte';

  @override
  String get paletteGroupRecent => 'Letzte Aufgaben';

  @override
  String get paletteGroupContexts => 'Wechseln zu';

  @override
  String get paletteGroupTheme => 'Design';

  @override
  String get paletteGroupTemplates => 'Vorlagen';

  @override
  String paletteOpenTask(String ref) {
    return '$ref öffnen';
  }

  @override
  String get paletteGoInbox => 'Zum Posteingang';

  @override
  String get paletteGoMyWork => 'Zu „Meine Arbeit“';

  @override
  String get paletteGoTemplates => 'Zu Vorlagen';

  @override
  String get paletteThemeLight => 'Helles Design';

  @override
  String get paletteThemeDark => 'Dunkles Design';

  @override
  String get paletteThemeSystem => 'Systemdesign';

  @override
  String paletteUseTemplate(String name) {
    return 'Neue Aufgabe aus $name';
  }

  @override
  String get templatesTitle => 'Vorlagen';

  @override
  String get templatesSubtitle => 'Häufige Aufgaben, nur einen Tipp entfernt';

  @override
  String get templateNew => 'Neue Vorlage';

  @override
  String get templatesEmpty => 'Noch keine Vorlagen.';

  @override
  String get templatesEmptyBody =>
      'Speichern Sie eine Aufgabe als Vorlage, um sie mit einem Tipp erneut hinzuzufügen.';

  @override
  String get templateEveryProject => 'Alle Projekte';

  @override
  String templateUses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-mal verwendet',
      one: 'Einmal verwendet',
      zero: 'Nie verwendet',
    );
    return '$_temp0';
  }

  @override
  String templateSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Unteraufgaben',
      one: '1 Unteraufgabe',
    );
    return '$_temp0';
  }

  @override
  String get templateUse => 'Verwenden';

  @override
  String get templateEdit => 'Vorlage bearbeiten';

  @override
  String get templateDelete => 'Vorlage löschen';

  @override
  String templateDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get templateDeleteBody =>
      'Daraus erstellte Aufgaben bleiben erhalten.';

  @override
  String templateDeleted(String name) {
    return '$name gelöscht';
  }

  @override
  String templateSaved(String name) {
    return '$name gespeichert';
  }

  @override
  String get templateName => 'Name';

  @override
  String get templateNameHelp =>
      'Eindeutig im Mandanten, höchstens 100 Zeichen.';

  @override
  String get templateFromTask => 'Aus Aufgabe';

  @override
  String get templateFromScratch => 'Neu erstellen';

  @override
  String get templateTaskRef => 'Aufgabe';

  @override
  String get templateTaskRefHelp =>
      'Die Referenz der Aufgabe, die als Vorlage dient, z. B. ops-12.';

  @override
  String get templateWithSubtasks => 'Unteraufgaben übernehmen';

  @override
  String get templateTenantWide => 'Für alle Projekte freigeben';

  @override
  String get templateDueIn => 'Fällig nach';

  @override
  String get templateDueInHelp =>
      'Wie lange nach der Verwendung die Aufgabe fällig wird, z. B. 3d oder 2w. Leer für keine Frist.';

  @override
  String get templateScratchNote =>
      'tix speichert Vorlagen als Aufgaben, daher wird die Aufgabe auch dem Projekt hinzugefügt.';

  @override
  String get templateTitle => 'Titel';

  @override
  String templateTitleHelp(String date, String n, String project) {
    return '$date, $n und $project werden bei jeder Verwendung ausgefüllt.';
  }

  @override
  String get templateBody => 'Beschreibung';

  @override
  String get templatePriority => 'Priorität';

  @override
  String get templateTags => 'Tags';

  @override
  String get templateTagsHelp => 'Durch Leerzeichen oder Kommas getrennt.';

  @override
  String get templateRecurrence => 'Wiederholung';

  @override
  String get templateRecurrenceHelp =>
      'Z. B. every 2 weeks. Leer für keine Wiederholung.';

  @override
  String get templateSave => 'Speichern';

  @override
  String get templateCreate => 'Vorlage speichern';

  @override
  String get templateRecentTasks => 'Zuletzt geöffnet';

  @override
  String get appShortcutInbox => 'Posteingang';

  @override
  String get appShortcutMyWork => 'Meine Arbeit';

  @override
  String get templateDeleteAction => 'Löschen';

  @override
  String get templateMore => 'Weitere Aktionen';

  @override
  String templateGeneralError(String reason) {
    return 'Speichern fehlgeschlagen: $reason';
  }

  @override
  String get goInbox => 'Zum Posteingang';

  @override
  String get inboxTitle => 'Posteingang';

  @override
  String get inboxAll => 'Alle';

  @override
  String get inboxUnreadFilter => 'Ungelesen';

  @override
  String get inboxShowUnread => 'Nur ungelesene anzeigen';

  @override
  String get inboxUnread => 'ungelesen';

  @override
  String get inboxAllCaughtUp => 'Alles erledigt';

  @override
  String inboxUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesen',
      one: '1 ungelesen',
    );
    return '$_temp0';
  }

  @override
  String get inboxToday => 'Heute';

  @override
  String get inboxYesterday => 'Gestern';

  @override
  String get inboxEarlier => 'Früher';

  @override
  String get inboxEmpty => 'Noch nichts da.';

  @override
  String get inboxEmptyBody =>
      'Wenn jemand Sie erwähnt, Ihnen eine Aufgabe zuweist oder eine Aufgabe kommentiert, der Sie folgen, erscheint das hier.';

  @override
  String get inboxEmptyUnread => 'Nichts Ungelesenes.';

  @override
  String get inboxEmptyFiltered => 'Nichts von diesen Arten.';

  @override
  String get inboxSomebody => 'Jemand';

  @override
  String inboxWhatMention(String who) {
    return '$who hat Sie erwähnt';
  }

  @override
  String inboxWhatAssigned(String who) {
    return '$who hat Ihnen etwas zugewiesen';
  }

  @override
  String inboxWhatComment(String who) {
    return '$who hat kommentiert';
  }

  @override
  String inboxWhatStatus(String who) {
    return '$who hat sie verschoben';
  }

  @override
  String inboxWhatOther(String who) {
    return '$who hat sie geändert';
  }

  @override
  String get inboxMovedTo => 'verschoben nach';

  @override
  String get inboxTaskGone => 'Eine gelöschte Aufgabe';

  @override
  String get inboxNow => 'jetzt';

  @override
  String inboxMinutesAgo(int n) {
    return '$n Min.';
  }

  @override
  String inboxHoursAgo(int n) {
    return '$n Std.';
  }

  @override
  String get inboxItemActions => 'Aktionen';

  @override
  String get inboxOpenTask => 'Aufgabe öffnen';

  @override
  String get inboxMarkRead => 'Als gelesen markieren';

  @override
  String get inboxMarkUnread => 'Als ungelesen markieren';

  @override
  String get inboxMarkAllRead => 'Alle als gelesen markieren';

  @override
  String inboxMarkedAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge als gelesen markiert',
      one: '1 Eintrag als gelesen markiert',
    );
    return '$_temp0';
  }

  @override
  String inboxMuteKind(String kind) {
    return '„$kind“ nicht mehr im Posteingang';
  }

  @override
  String inboxMuted(String kind) {
    return '„$kind“ erscheinen nicht mehr in Ihrem Posteingang';
  }

  @override
  String get inboxKindMention => 'Erwähnungen';

  @override
  String get inboxKindAssigned => 'Zuweisungen';

  @override
  String get inboxKindComment => 'Kommentare';

  @override
  String get inboxKindStatus => 'Statusänderungen';

  @override
  String get inboxKindMentionHelp =>
      'Jemand erwähnt Sie mit @ in einem Kommentar oder einer Beschreibung.';

  @override
  String get inboxKindAssignedHelp => 'Ihnen wird eine Aufgabe zugewiesen.';

  @override
  String get inboxKindCommentHelp =>
      'Jemand kommentiert eine Aufgabe, die Ihnen zugewiesen ist oder die Sie als Favorit markiert haben.';

  @override
  String get inboxKindStatusHelp =>
      'Eine Ihnen zugewiesene Aufgabe wechselt den Status.';

  @override
  String get inboxKindsTitle => 'Posteingang';

  @override
  String get inboxKindsSubtitle =>
      'Was einen Eintrag in Ihrem Posteingang erzeugt, auf allen Geräten.';

  @override
  String get inboxKindsInfo =>
      'Auf dem Server gespeichert, wie in der Web-App unter „Einstellungen“, „Posteingang“. Eine ausgeschaltete Art erzeugt keine Einträge; vorhandene Einträge bleiben. Eigene Änderungen erscheinen nie.';

  @override
  String get inboxSummaryOverdue => 'Überfällig';

  @override
  String get inboxSummaryDueToday => 'Heute fällig';

  @override
  String get inboxSummaryOpen => 'Offen';

  @override
  String get inboxSummaryDoneWeek => 'Erledigt in 7 Tagen';

  @override
  String inboxCategory(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'todo': 'Zu erledigen',
      'inProgress': 'In Arbeit',
      'blocked': 'Blockiert',
      'waiting': 'Wartend',
      'other': 'Sonstige',
    });
    return '$_temp0';
  }

  @override
  String get inboxChannelsTitle => 'Kanäle';

  @override
  String get inboxChannelsSubtitle =>
      'Posteingang an Slack, Discord, ntfy oder eine beliebige URL senden.';

  @override
  String get inboxChannelsInfo =>
      'Ein Kanal gehört nur Ihnen: Er erhält nur Ihre Einträge der aufgeführten Arten und nichts von einer Art, die Sie oben ausgeschaltet haben. Der Server sendet jeden Eintrag, sobald er entsteht.';

  @override
  String get inboxChannelsEmpty => 'Noch keine Kanäle.';

  @override
  String get inboxChannelAdd => 'Kanal hinzufügen';

  @override
  String get inboxChannelEdit => 'Kanal bearbeiten';

  @override
  String get inboxChannelSave => 'Speichern';

  @override
  String get inboxChannelSaved => 'Kanal gespeichert';

  @override
  String inboxChannelAdded(String name) {
    return '$name hinzugefügt';
  }

  @override
  String get inboxChannelName => 'Name';

  @override
  String get inboxChannelNameHint => 'Mein Slack';

  @override
  String get inboxChannelUrl => 'Adresse';

  @override
  String get inboxChannelUrlHelp =>
      'Die Webhook- oder Topic-URL. Sie muss https verwenden.';

  @override
  String get inboxChannelFormat => 'Format';

  @override
  String get inboxChannelFormatGeneric => 'Signiertes JSON';

  @override
  String get inboxChannelKinds => 'Arten';

  @override
  String get inboxChannelAllKinds => 'Alle Arten';

  @override
  String get inboxChannelOff => 'Aus';

  @override
  String get inboxChannelSecretTitle => 'Signaturschlüssel';

  @override
  String get inboxChannelSecretBody =>
      'tix signiert jede signierte JSON-Nachricht mit diesem Schlüssel. Kopieren Sie ihn jetzt: Er wird nicht erneut angezeigt.';

  @override
  String get inboxChannelSecretCopy => 'Kopieren';

  @override
  String get inboxChannelSecretDone => 'Fertig';

  @override
  String get inboxChannelAbout => 'Kanal';

  @override
  String get inboxChannelActive => 'An';

  @override
  String get inboxChannelActiveHelp => 'Ausgeschaltet erhält der Kanal nichts.';

  @override
  String get inboxChannelTest => 'Test senden';

  @override
  String get inboxChannelTestQueued => 'Testnachricht eingereiht';

  @override
  String get inboxChannelDeliveries => 'Zustellungen';

  @override
  String get inboxChannelDeliveriesSubtitle => 'Neueste zuerst.';

  @override
  String get inboxChannelNoDeliveries => 'Noch nichts zugestellt.';

  @override
  String get inboxChannelGone => 'Dieser Kanal existiert nicht mehr.';

  @override
  String get inboxChannelDangerZone => 'Gefahrenbereich';

  @override
  String get inboxChannelDelete => 'Kanal löschen';

  @override
  String inboxChannelDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get inboxChannelDeleteBody =>
      'Der Kanal und sein Zustellprotokoll werden entfernt. Das kann nicht rückgängig gemacht werden.';

  @override
  String inboxChannelDeleted(String name) {
    return '$name gelöscht';
  }

  @override
  String get inboxDeliveryDelivered => 'zugestellt';

  @override
  String get inboxDeliveryFailed => 'fehlgeschlagen';

  @override
  String get inboxDeliveryPending => 'ausstehend';

  @override
  String get inboxDeliveryTest => 'Testnachricht';

  @override
  String get inboxDeliveryItem => 'Posteingangseintrag';

  @override
  String inboxDeliveryAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Versuche',
      one: '1 Versuch',
    );
    return '$_temp0';
  }

  @override
  String get inboxDeliveryRedeliver => 'Erneut zustellen';

  @override
  String get inboxDeliveryRequeued => 'Erneut eingereiht';

  @override
  String get liveUpdated => 'Aktualisiert';

  @override
  String get liveChangedElsewhere =>
      'Das wurde anderswo geändert. Ihre Bearbeitungen bleiben erhalten.';

  @override
  String liveChangedElsewhereBy(String handle) {
    return '@$handle hat das geändert. Ihre Bearbeitungen bleiben erhalten.';
  }

  @override
  String get liveKeepEditing => 'Weiter bearbeiten';

  @override
  String get liveReload => 'Neu laden';

  @override
  String get notifSettingsTitle => 'Benachrichtigungen';

  @override
  String get notifSettingsSubtitle =>
      'Auf diesem Gerät, Posteingangsarten und Kanäle';

  @override
  String get notifDeviceTitle => 'Auf diesem Gerät';

  @override
  String get notifDeviceSubtitle =>
      'Für die aktive Instanz und den aktiven Mandanten.';

  @override
  String get notifDeviceInfo =>
      'Werden angezeigt, solange die App geöffnet ist oder gerade erst in den Hintergrund ging. Eine geschlossene App kann nicht benachrichtigt werden: tix hat noch keinen Push-Dienst. Die Kanäle unten stellen überall zu.';

  @override
  String get notifEnabled => 'Bei neuen Posteingangseinträgen benachrichtigen';

  @override
  String get notifEnabledHelp =>
      'Tippen Sie auf eine Benachrichtigung, um die Aufgabe zu öffnen.';

  @override
  String get notifBlocked => 'Benachrichtigungen für tix sind blockiert.';

  @override
  String get notifBlockedHelp =>
      'Erlauben Sie Benachrichtigungen für tix in den Systemeinstellungen und schalten Sie dies dann wieder ein.';

  @override
  String get notifNudge =>
      'Lassen Sie sich benachrichtigen, wenn etwas Neues in Ihrem Posteingang ankommt.';

  @override
  String get notifTurnOn => 'Einschalten';

  @override
  String get notifNotNow => 'Nicht jetzt';

  @override
  String notifMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weitere Posteingangseinträge',
      one: '1 weiterer Posteingangseintrag',
    );
    return '$_temp0';
  }

  @override
  String get notifMoreBody => 'Öffnen Sie den Posteingang, um sie zu sehen.';

  @override
  String get themeOled => 'OLED-Schwarz';

  @override
  String get themeSystemBlack => 'Reines Schwarz im Dunkelmodus';

  @override
  String get themeSystemBlackHelp =>
      'Verwendet OLED-Schwarz, wenn das System dunkel ist. Spart Akku auf OLED-Bildschirmen.';

  @override
  String get goAbout => 'Über tix';

  @override
  String get aboutTagline => 'Der tix-Client für Smartphone und Desktop';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutIntro =>
      'tix-mobile ist die App zu tix, der Open-Source-Aufgabenverwaltung. Sie arbeitet mit jedem tix-Server oder führt tix direkt auf diesem Gerät aus, ganz ohne Server. Was mit Ihrer Arbeit passiert, entscheidet der Server: Aufgaben verhalten sich genau wie in der Web-App und auf der Kommandozeile von tix.';

  @override
  String get aboutVersions => 'Versionen';

  @override
  String get aboutAppVersion => 'App';

  @override
  String get aboutEngineVersion => 'Eingebaute Engine';

  @override
  String get aboutEngineNone => 'Nicht in diesem Build';

  @override
  String get aboutServerVersion => 'Server';

  @override
  String get aboutServerNone => 'Nicht verbunden';

  @override
  String get aboutServerUnknown => 'Nicht lesbar';

  @override
  String get aboutLinks => 'Links';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutSource => 'Quellcode';

  @override
  String get aboutSourceHelp =>
      'Der vollständige Quellcode dieser App, wie ihn die AGPL anbietet';

  @override
  String get aboutRoadmap => 'Roadmap';

  @override
  String get aboutRoadmapHelp => 'Was als Nächstes geplant ist';

  @override
  String get aboutChangelog => 'Änderungen';

  @override
  String get aboutChangelogHelp => 'Was sich in jeder Version geändert hat';

  @override
  String get aboutServerProject => 'tix-Server';

  @override
  String get aboutServerProjectHelp =>
      'Der Server, die Web-App und die Kommandozeile';

  @override
  String get aboutSecurity => 'Sicherheitsrichtlinie';

  @override
  String get aboutSecurityHelp =>
      'Wie Sie eine Schwachstelle vertraulich melden';

  @override
  String get aboutHelp => 'Etwas stimmt nicht?';

  @override
  String get aboutReportBug => 'Fehler melden';

  @override
  String get aboutReportBugHelp =>
      'Öffnet ein neues GitHub-Issue mit den Versionen oben schon ausgefüllt. Fügen Sie nie ein API-Token ein.';

  @override
  String get aboutCopyDiagnostics => 'Diagnose kopieren';

  @override
  String get aboutDiagnosticsCopied => 'Diagnose kopiert.';

  @override
  String get aboutIncludeServer => 'Serveradresse einschließen';

  @override
  String get aboutIncludeServerHelp =>
      'Aus: Die Adresse eines privaten Servers bleibt aus dem Kopierten heraus.';

  @override
  String get aboutLicence => 'Lizenz';

  @override
  String get aboutLicenceBody =>
      'tix-mobile ist freie Software unter der GNU AGPL, Version 3 oder neuer. Beiträge werden unter dem Contributor License Agreement (CLA) des Projekts angenommen.';

  @override
  String get aboutLicences => 'Lizenzen';

  @override
  String get aboutLicencesHelp => 'Die Open-Source-Software in dieser App';

  @override
  String get aboutOpenFailed => 'Der Link lässt sich nicht öffnen.';

  @override
  String get paletteThemeOled => 'Design OLED-Schwarz';

  @override
  String get manageTitle => 'Verwaltung';

  @override
  String manageSubtitle(String tenant) {
    return 'Was Sie in $tenant verwalten können';
  }

  @override
  String get goManage => 'Zur Verwaltung';

  @override
  String get navMore => 'Mehr';

  @override
  String get manageEmpty =>
      'Mit diesen Zugangsdaten gibt es nichts zu verwalten.';

  @override
  String get manageEmptyBody =>
      'Projekte, Workflows, Personen und der Mandant brauchen Berechtigungen, die dieser Token oder diese Rolle nicht hat. Bitten Sie einen Admin um weitere.';

  @override
  String get manageGroupProjects => 'Projekte';

  @override
  String get manageGroupWorkflows => 'Workflows';

  @override
  String get manageGroupFields => 'Felder';

  @override
  String get manageGroupPeople => 'Personen';

  @override
  String get manageGroupAccess => 'Zugriff';

  @override
  String get manageGroupTenant => 'Mandant';

  @override
  String get manageGroupServer => 'Server';

  @override
  String get manageProjectsSubtitle =>
      'Projekte anlegen, umbenennen, umfärben, archivieren und löschen';

  @override
  String get manageWorkflowsSubtitle =>
      'Zustände, die Übergänge dazwischen und wer sie ausführen darf';

  @override
  String get manageFieldsSubtitle =>
      'Die benutzerdefinierten Felder der Aufgaben jedes Projekts';

  @override
  String get manageSave => 'Speichern';

  @override
  String get manageSaveChanges => 'Änderungen speichern';

  @override
  String get manageDelete => 'Löschen';

  @override
  String get manageClear => 'Leeren';

  @override
  String get manageYes => 'Ja';

  @override
  String get manageNo => 'Nein';

  @override
  String get manageDangerZone => 'Gefahrenzone';

  @override
  String get manageInherited => 'Geerbt';

  @override
  String get manageDurationHelp =>
      'Eine Dauer wie 30m oder 4h. Leer erbt den Wert.';

  @override
  String get manageChanged => 'geändert';

  @override
  String manageTaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben',
      one: '1 Aufgabe',
    );
    return '$_temp0';
  }

  @override
  String get manageDragToReorder => 'Zum Umsortieren ziehen';

  @override
  String get colourNone => 'Keine Farbe';

  @override
  String get colourSlate => 'Schiefer';

  @override
  String get colourRed => 'Rot';

  @override
  String get colourAmber => 'Bernstein';

  @override
  String get colourGreen => 'Grün';

  @override
  String get colourTeal => 'Petrol';

  @override
  String get colourBlue => 'Blau';

  @override
  String get colourViolet => 'Violett';

  @override
  String get colourPink => 'Rosa';

  @override
  String get colourCustom => 'Eigene Farbe';

  @override
  String get iconNone => 'Keins';

  @override
  String get iconText => 'Emoji';

  @override
  String get iconBuiltin => 'Symbol';

  @override
  String get iconImage => 'Bild';

  @override
  String get iconNoneHelp =>
      'Stattdessen erscheinen die ersten Buchstaben des Namens.';

  @override
  String get iconTextLabel => 'Emoji oder Buchstaben';

  @override
  String get iconTextHelp => 'Ein Emoji oder ein bis zwei Buchstaben.';

  @override
  String get iconImageHelp => 'PNG, JPEG, WebP oder SVG, höchstens 64 KB.';

  @override
  String get iconUpload => 'Bild auswählen';

  @override
  String get projectNew => 'Neues Projekt';

  @override
  String get projectCreate => 'Projekt anlegen';

  @override
  String projectCreated(String name) {
    return '$name wurde angelegt.';
  }

  @override
  String get projectName => 'Name';

  @override
  String get projectKey => 'Schlüssel';

  @override
  String get projectKeyHelp =>
      'Beginnt jede Aufgabenreferenz, etwa infra-1. Buchstaben, Ziffern, - und _.';

  @override
  String get projectKeyChangeHelp =>
      'Eine Änderung benennt alle Aufgabenreferenzen um; der alte Schlüssel funktioniert weiter.';

  @override
  String get projectDescription => 'Beschreibung';

  @override
  String get projectWorkflow => 'Workflow';

  @override
  String get projectWorkflowInfo =>
      'Die Zustände, die die Aufgaben dieses Projekts durchlaufen. tix lehnt einen Wechsel ab, solange eine Aufgabe in einem Zustand steht, den der neue Workflow nicht hat.';

  @override
  String get projectColour => 'Farbe';

  @override
  String get projectIcon => 'Symbol';

  @override
  String get projectSettingsTitle => 'Projekteinstellungen';

  @override
  String get projectSectionProject => 'Projekt';

  @override
  String get projectSectionAppearance => 'Darstellung';

  @override
  String get projectSectionClaims => 'Übernahmen';

  @override
  String get projectClaimsInfo =>
      'Wie lange eine Übernahme der Aufgaben dieses Projekts gilt. Der Wert des Projekts hat Vorrang vor dem des Workflows und des Mandanten; die längste Dauer kann nur kürzer sein als die des Mandanten.';

  @override
  String get projectLeaseDefault => 'Übernahmedauer';

  @override
  String get projectLeaseMax => 'Längste Dauer';

  @override
  String get projectLeaseMaxHelp =>
      'Eine Dauer wie 24h, unter der Obergrenze des Mandanten. Leer erbt den Wert.';

  @override
  String get projectManageFields => 'Benutzerdefinierte Felder';

  @override
  String get projectManageFieldsHelp =>
      'Legen Sie die Felder der Aufgaben dieses Projekts fest.';

  @override
  String get projectReadOnly =>
      'Sie können diese Einstellungen sehen, aber nicht ändern: Dafür ist project:write nötig.';

  @override
  String get projectSaved => 'Projekt gespeichert.';

  @override
  String get projectRekeyTitle => 'Projektschlüssel ändern?';

  @override
  String get projectRekeyBody =>
      'Jede Aufgabenreferenz ändert sich mit dem Schlüssel:';

  @override
  String projectRekeyAlias(String old) {
    return 'Links, Referenzen und Filter mit $old funktionieren weiter: Der alte Schlüssel bleibt als Alias, und kein anderes Projekt kann ihn übernehmen.';
  }

  @override
  String get projectRekeyConfirm => 'Schlüssel ändern';

  @override
  String get projectArchive => 'Projekt archivieren';

  @override
  String get projectArchiveHelp =>
      'Blendet es in Listen aus und behält Aufgaben und Verlauf. tix kann nicht wieder dearchivieren.';

  @override
  String projectArchiveTitle(String name) {
    return '$name archivieren?';
  }

  @override
  String get projectArchiveBody =>
      'Das Projekt verschwindet aus den Standardlisten. Aufgaben und Verlauf bleiben. tix kann ein Projekt nicht dearchivieren.';

  @override
  String projectArchived(String name) {
    return '$name wurde archiviert.';
  }

  @override
  String get projectArchivedBadge => 'archiviert';

  @override
  String get projectIsArchived => 'Dieses Projekt ist archiviert.';

  @override
  String get projectDelete => 'Projekt löschen';

  @override
  String get projectDeleteHelp =>
      'Entfernt es endgültig. Seine Aufgaben wandern in ein anderes Projekt oder werden mitgelöscht.';

  @override
  String projectDeleteTitle(String key) {
    return '$key löschen?';
  }

  @override
  String get projectDeleteEmpty =>
      'Das Projekt enthält keine Aufgaben. Das Löschen lässt sich nicht rückgängig machen.';

  @override
  String projectDeleteHolds(int live, int trashed) {
    String _temp0 = intl.Intl.pluralLogic(
      live,
      locale: localeName,
      other: '$live Aufgaben',
      one: '1 Aufgabe',
    );
    String _temp1 = intl.Intl.pluralLogic(
      trashed,
      locale: localeName,
      other: '$trashed im Papierkorb',
      one: '1 im Papierkorb',
    );
    return 'Es enthält $_temp0 und $_temp1. Was soll damit geschehen?';
  }

  @override
  String get projectDeleteMove => 'In ein anderes Projekt verschieben';

  @override
  String get projectDeleteNoTarget =>
      'Es gibt kein anderes aktives Projekt als Ziel.';

  @override
  String get projectDeleteTarget => 'Verschieben nach';

  @override
  String get projectDeleteMapping => 'Status nach dem Verschieben';

  @override
  String get projectDeleteTasks => 'Endgültig löschen';

  @override
  String projectDeleteType(String key) {
    return 'Zur Bestätigung $key eingeben';
  }

  @override
  String get projectDeleteConfirm =>
      'Das Projekt und seine Aufgaben werden endgültig gelöscht.';

  @override
  String projectDeleteMoveConfirm(String target) {
    return 'Die Aufgaben wandern nach $target, dann wird das Projekt endgültig gelöscht.';
  }

  @override
  String projectDeleted(String key) {
    return '$key wurde gelöscht.';
  }

  @override
  String get fieldsTitle => 'Benutzerdefinierte Felder';

  @override
  String get fieldProjectsSubtitle =>
      'tix legt Felder pro Projekt fest. Wählen Sie eines.';

  @override
  String get fieldsEmpty => 'Noch keine benutzerdefinierten Felder.';

  @override
  String get fieldsEmptyBody =>
      'Ein Feld fügt jeder Aufgabe im Projekt einen Wert Ihrer Wahl hinzu, etwa eine Umgebung oder einen Kunden.';

  @override
  String get fieldsReadOnly =>
      'Sie können diese Felder sehen, aber nicht ändern: Dafür ist project:write nötig.';

  @override
  String get fieldNew => 'Neues Feld';

  @override
  String fieldEdit(String key) {
    return '$key bearbeiten';
  }

  @override
  String get fieldKey => 'Schlüssel';

  @override
  String get fieldKeyHelp =>
      'So nennen Aufgaben und Filter das Feld, etwa env.';

  @override
  String get fieldKeyFixed =>
      'Der Schlüssel benennt das Feld; für einen anderen legen Sie ein neues Feld an.';

  @override
  String get fieldLabel => 'Bezeichnung';

  @override
  String get fieldLabelHelp => 'Was Menschen sehen. Leer zeigt den Schlüssel.';

  @override
  String get fieldType => 'Typ';

  @override
  String get fieldOptions => 'Optionen';

  @override
  String get fieldOptionsHelp => 'Die erlaubten Werte, durch Kommas getrennt.';

  @override
  String get fieldDefault => 'Standardwert';

  @override
  String get fieldNoDefault => 'Kein Standardwert';

  @override
  String get fieldPickDefault => 'Wert wählen';

  @override
  String get fieldActorHint => 'Ein Handle, etwa raj';

  @override
  String fieldDefaultIs(String value) {
    return 'Standard $value';
  }

  @override
  String get fieldDefaultUnreadable =>
      'Dieser Wert passt nicht zum Typ des Felds.';

  @override
  String get fieldRequired => 'Pflichtfeld';

  @override
  String get fieldRequiredHelp =>
      'Eine neue Aufgabe ohne Wert wird abgelehnt, außer es gibt einen Standardwert.';

  @override
  String fieldSaved(String key) {
    return '$key wurde gespeichert.';
  }

  @override
  String fieldDeleteTitle(String key) {
    return 'Feld $key löschen?';
  }

  @override
  String get fieldDeleteBody => 'Aufgaben zeigen dieses Feld nicht mehr.';

  @override
  String fieldDeleted(String key) {
    return '$key wurde gelöscht.';
  }

  @override
  String get fieldTypeString => 'Text, einzeilig';

  @override
  String get fieldTypeText => 'Text, mehrzeilig';

  @override
  String get fieldTypeInt => 'Ganzzahl';

  @override
  String get fieldTypeFloat => 'Zahl';

  @override
  String get fieldTypeBool => 'Ja oder nein';

  @override
  String get fieldTypeDate => 'Datum';

  @override
  String get fieldTypeDatetime => 'Datum und Uhrzeit';

  @override
  String get fieldTypeEnum => 'Auswahl';

  @override
  String get fieldTypeActor => 'Person oder Agent';

  @override
  String get fieldTypeJson => 'JSON';

  @override
  String get fieldTypeUnknown => 'Unbekannt';

  @override
  String get categoryTodo => 'Zu erledigen';

  @override
  String get categoryInProgress => 'In Arbeit';

  @override
  String get categoryBlocked => 'Blockiert';

  @override
  String get categoryWaiting => 'Wartend';

  @override
  String get categoryDone => 'Erledigt';

  @override
  String get categoryCancelled => 'Abgebrochen';

  @override
  String get categoryDerived => 'Aus dem Zustand (tix entscheidet)';

  @override
  String get workflowsTitle => 'Workflows';

  @override
  String get workflowsSubtitle =>
      'Die Zustände, die Aufgaben durchlaufen, und wie';

  @override
  String get workflowsEmpty => 'Keine Workflows.';

  @override
  String get workflowTitle => 'Workflow';

  @override
  String workflowSubtitle(String key) {
    return 'Schlüssel $key';
  }

  @override
  String get workflowBuiltin => 'eingebaut';

  @override
  String workflowStateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zustände',
      one: '1 Zustand',
    );
    return '$_temp0';
  }

  @override
  String get workflowNew => 'Neuer Workflow';

  @override
  String get workflowCreate => 'Workflow anlegen';

  @override
  String workflowCreated(String name) {
    return '$name wurde angelegt.';
  }

  @override
  String get workflowKey => 'Schlüssel';

  @override
  String get workflowKeyHelp =>
      'Buchstaben, Ziffern, - und _, beginnend mit einem Buchstaben.';

  @override
  String get workflowKeyTaken =>
      'Ein Workflow mit diesem Schlüssel existiert; Speichern würde ihn ersetzen.';

  @override
  String get workflowName => 'Name';

  @override
  String get workflowStartFrom => 'Ausgehend von';

  @override
  String get workflowMinimal => 'Offen und erledigt';

  @override
  String workflowCopyOf(String name) {
    return 'Eine Kopie von $name';
  }

  @override
  String get workflowReadOnly =>
      'Sie können diesen Workflow sehen, aber nicht ändern: Dafür ist workflow:write nötig.';

  @override
  String get workflowRefused => 'tix hat die Änderung abgelehnt';

  @override
  String get workflowSaved => 'Workflow gespeichert.';

  @override
  String get workflowSectionGeneral => 'Workflow';

  @override
  String get workflowInitial => 'Anfangszustand';

  @override
  String get workflowInitialHelp => 'Hier beginnt eine neue Aufgabe.';

  @override
  String get workflowDefaultLease => 'Übernahmedauer';

  @override
  String get workflowSectionStates => 'Zustände';

  @override
  String get workflowStatesHelp =>
      'Zum Umsortieren am Griff ziehen. Einen Zustand antippen, um ihn zu bearbeiten.';

  @override
  String get workflowAddState => 'Zustand hinzufügen';

  @override
  String workflowEditState(String name) {
    return '$name bearbeiten';
  }

  @override
  String get workflowStateKey => 'Schlüssel';

  @override
  String get workflowStateKeyHelp =>
      'Was der Status einer Aufgabe enthält, etwa review.';

  @override
  String get workflowStateKeyRename =>
      'Beim Speichern wandern die Aufgaben dieses Zustands zum neuen Schlüssel.';

  @override
  String get workflowStateKeyTaken =>
      'Ein anderer Zustand hat diesen Schlüssel.';

  @override
  String get workflowStateLabel => 'Bezeichnung';

  @override
  String get workflowStateCategory => 'Kategorie';

  @override
  String get workflowStateCategoryInfo =>
      'Gruppiert den Zustand für Farben, Boards und Berichte. Wenn tix entscheidet: erledigt bei Endzuständen, zu erledigen beim Anfangszustand, sonst in Arbeit.';

  @override
  String get workflowStateInitial => 'Anfangszustand';

  @override
  String get workflowTerminal => 'Endzustand';

  @override
  String get workflowTerminalHelp =>
      'Erreicht eine Aufgabe ihn, ist sie erledigt und erfüllt, was von ihr abhängt.';

  @override
  String get workflowRevert => 'Zurück, wenn die Übernahme abläuft';

  @override
  String get workflowRevertHelp =>
      'Eine hier übernommene Aufgabe geht zurück, wenn die Übernahme abläuft.';

  @override
  String get workflowRevertTo => 'Zurück zu';

  @override
  String workflowRevertsTo(String state) {
    return 'zurück zu $state';
  }

  @override
  String get workflowInitialBadge => 'Anfang';

  @override
  String get workflowSectionTransitions => 'Übergänge';

  @override
  String get workflowTransitionsHelp =>
      'Einen Zustand antippen, um den Übergang zu erlauben. Die Regel-Schaltfläche eines gewählten Übergangs verlangt einen Kommentar oder eine Berechtigung.';

  @override
  String workflowCanMoveTo(String name) {
    return 'Von $name kann eine Aufgabe wechseln zu';
  }

  @override
  String get workflowNoMoves => 'Kein Übergang verlässt diesen Zustand.';

  @override
  String get workflowMoveRules => 'Regeln für diesen Übergang';

  @override
  String workflowRulesTitle(String from, String to) {
    return '$from zu $to';
  }

  @override
  String get workflowNeedsComment => 'Kommentar erforderlich';

  @override
  String get workflowNeedsCommentHelp =>
      'Der Übergang wird ohne Kommentar abgelehnt.';

  @override
  String workflowNeedsScope(String scope) {
    return 'Erfordert $scope';
  }

  @override
  String get workflowRequiredScope => 'Erforderliche Berechtigung';

  @override
  String get workflowRequiredScopeHelp =>
      'Nur wer sie hat, darf diesen Übergang ausführen.';

  @override
  String get workflowNoScope => 'Keine';

  @override
  String get workflowSectionRoutes => 'Wege';

  @override
  String get workflowRoutesInfo =>
      'Wie viele Übergänge jeden Zustand vom Anfangszustand trennen. Ein Wechsel zu einem entfernteren Zustand durchläuft die Zustände dazwischen, einen Übergang nach dem anderen.';

  @override
  String workflowSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schritte',
      one: '1 Schritt',
    );
    return '$_temp0';
  }

  @override
  String get workflowUnreachable => 'Kein Weg führt hierher';

  @override
  String get workflowSectionRemoved => 'Entfernte Zustände';

  @override
  String get workflowRemovedHelp =>
      'Aufgaben in einem entfernten Zustand brauchen ein Ziel, sonst lehnt tix das Speichern ab.';

  @override
  String workflowMigrate(String state) {
    return 'Aufgaben aus $state verschieben nach';
  }

  @override
  String get workflowMigrateNone =>
      'Nirgendwohin (abgelehnt, wenn Aufgaben darin sind)';

  @override
  String get workflowDelete => 'Workflow löschen';

  @override
  String get workflowDeleteHelp =>
      'Nur ein Workflow, den kein Projekt nutzt, lässt sich löschen.';

  @override
  String workflowDeleteTitle(String key) {
    return '$key löschen?';
  }

  @override
  String get workflowDeleteBody => 'Der Workflow wird endgültig gelöscht.';

  @override
  String workflowDeleted(String key) {
    return '$key wurde gelöscht.';
  }

  @override
  String get manageUsersTitle => 'Benutzer';

  @override
  String get manageUsersSubtitle =>
      'Personen im Mandanten, ihre Rollen und Einladungen';

  @override
  String get manageTokensTitle => 'API-Tokens';

  @override
  String get manageTokensSubtitle =>
      'Tokens für Agenten und Skripte und was jeder darf';

  @override
  String get manageTransferTitle => 'Import und Export';

  @override
  String get manageTransferSubtitle =>
      'Aufgaben und ganze Mandanten hinein- und herausbringen';

  @override
  String get localInstanceAdvancedBody =>
      'Eine Datenbank dort verwenden, wo sie liegt, zum Beispiel in einem Ordner, den Nextcloud, Syncthing oder iCloud Drive synchronisiert, statt einer Kopie in der App.';

  @override
  String get localInstanceAdvancedTitle => 'Erweitert: direkt öffnen';

  @override
  String get localInstanceBrowseCreate => 'Hier erstellen';

  @override
  String get localInstanceBrowseEmpty =>
      'Hier gibt es keine Ordner oder Datenbanken.';

  @override
  String get localInstanceBrowseNewLabel => 'Neue Datenbank in diesem Ordner';

  @override
  String get localInstanceBrowseTitle => 'Datenbank auswählen';

  @override
  String get localInstanceBrowseUp => 'Übergeordneter Ordner';

  @override
  String localInstanceConflicts(String names) {
    return 'Konfliktkopien der Synchronisation neben dieser Datei: $names. Prüfen Sie, welche Ihren neuesten Stand enthält, bevor Sie fortfahren.';
  }

  @override
  String get localInstanceDesktopIntro =>
      'Eine neue tix-Datenbank erstellen. Um eine vorhandene zu verwenden, öffnen Sie sie unten direkt.';

  @override
  String get localInstanceEngineResting => 'Gestoppt, startet bei Bedarf neu';

  @override
  String localInstanceEngineRunning(String address) {
    return 'Läuft auf $address';
  }

  @override
  String get localInstanceEngineStarting => 'Startet';

  @override
  String get localInstanceEngineStop => 'Stoppen';

  @override
  String get localInstanceEngineStopped => 'Gestoppt';

  @override
  String get localInstanceErrorAccess =>
      'tix kann diese Datei nicht mehr erreichen. Erlauben Sie den Zugriff erneut, oder entfernen Sie die Instanz und öffnen Sie die Datei noch einmal.';

  @override
  String get localInstanceErrorFolder =>
      'tix kann in diesem Ordner keine Dateien anlegen, SQLite braucht aber zwei Dateien neben der Datenbank. Wählen Sie einen Ordner, in den geschrieben werden darf.';

  @override
  String get localInstanceErrorLock =>
      'Diese Datei lässt sich nicht sperren, daher kann SQLite sie hier nicht schützen. Sie liegt vielleicht bei einem Cloud-Anbieter, der keine echten Dateien bereitstellt.';

  @override
  String get localInstanceErrorNotDatabase =>
      'Diese Datei ist auf diesem Gerät keine tix-Datenbank. Liegt sie in einem Cloud-Ordner, ist sie vielleicht noch nicht heruntergeladen.';

  @override
  String get localInstanceErrorNotDownloaded =>
      'Diese Datei ist noch nicht auf dieses Gerät heruntergeladen. Öffnen Sie sie in der Dateien-App, damit sie geladen wird, und versuchen Sie es dann erneut.';

  @override
  String get localInstanceIdleHelp =>
      'Eine Engine, die so lange nichts bedient hat, stoppt, um Akku zu sparen, und startet wieder, sobald die App sie braucht.';

  @override
  String get localInstanceIdleLabel => 'Unbenutzte Engine stoppen nach';

  @override
  String localInstanceIdleMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get localInstanceIdleNever => 'Nie';

  @override
  String get localInstanceIdleTitle => 'Lokale Datenbanken';

  @override
  String get localInstanceImportInstead => 'Kopie importieren';

  @override
  String get localInstanceInPlaceNote => 'Direkt verwendet';

  @override
  String get localInstanceOpenInPlace => 'Direkt öffnen…';

  @override
  String get localInstancePermissionBody =>
      'Um eine Datenbank dort zu öffnen, wo sie liegt, muss Android tix „Zugriff auf alle Dateien“ geben. tix liest und schreibt nur die Datenbank, die Sie auswählen, und die Dateien, die SQLite daneben ablegt.';

  @override
  String get localInstancePermissionContinue => 'Weiter';

  @override
  String get localInstancePermissionRefused =>
      'Der Zugriff auf alle Dateien wurde nicht erlaubt, daher kann tix keine Dateien direkt öffnen. Sie können stattdessen eine Kopie importieren.';

  @override
  String get localInstancePermissionTitle =>
      'Zugriff auf Ihre Dateien erlauben';

  @override
  String get localInstanceSyncWarning =>
      'Eine synchronisierte Datenbank darf nur auf einem Gerät gleichzeitig geöffnet sein. Schließen Sie tix zuerst auf Ihren anderen Geräten und warten Sie, bis die Synchronisation fertig ist. tix stoppt die Datenbank, sobald die App in den Hintergrund geht, damit der Sync-Client immer eine vollständige Datei vorfindet.';

  @override
  String get localInstanceWalLeftOver =>
      'Neben dieser Datei lag bereits ein Write-Ahead-Log. Ein anderes Programm hat sie vielleicht geöffnet, oder ein Sync-Client hat eines von einem anderen Gerät kopiert.';

  @override
  String get widgetMyWork => 'Meine Arbeit';

  @override
  String get widgetInbox => 'Posteingang';

  @override
  String get widgetQuickAdd => 'Schnell hinzufügen';

  @override
  String get widgetAddTask => 'Aufgabe hinzufügen';

  @override
  String get widgetNothingDue => 'Nichts ist Ihnen zugewiesen';

  @override
  String get widgetAllRead => 'Alles gelesen';

  @override
  String get widgetNoOpenTasks => 'Keine offenen Aufgaben';

  @override
  String get widgetUpdated => 'Aktualisiert';

  @override
  String get widgetOpenApp => 'Öffnen Sie tix, um dieses Widget zu laden';

  @override
  String get widgetLocalStale => 'Wird aktualisiert, wenn tix geöffnet ist';

  @override
  String get widgetOverdue => 'Überfällig';

  @override
  String get widgetToday => 'Heute';

  @override
  String get widgetComplete => 'Erledigen';

  @override
  String get widgetProjectMissing => 'Nicht in diesem Kontext';

  @override
  String get widgetSignedOut => 'Melden Sie sich bei tix an';

  @override
  String widgetMore(int count) {
    return '+$count weitere';
  }

  @override
  String widgetUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesen',
      one: '1 ungelesen',
      zero: 'Nichts ungelesen',
    );
    return '$_temp0';
  }

  @override
  String get settingsWidgets => 'Startbildschirm-Widgets';

  @override
  String get settingsWidgetLockCounts => 'Nur Anzahlen auf dem Sperrbildschirm';

  @override
  String get settingsWidgetLockCountsHelp =>
      'Widgets auf dem Sperrbildschirm zeigen, wie viele, nicht was.';

  @override
  String get settingsWidgetsHelp =>
      'Fügen Sie tix-Widgets auf Ihrem Startbildschirm hinzu. Sie zeigen, was die App zuletzt gelesen hat, und ein Haken wartet auf die App, wenn der Server nicht erreichbar ist.';

  @override
  String get widgetOpenUpdate => 'Öffnen Sie tix zum Aktualisieren';

  @override
  String get widgetPickProject => 'Projekt wählen';

  @override
  String liveStatusLabel(String state) {
    return 'Live-Aktualisierungen: $state';
  }

  @override
  String get liveStatusLive => 'Live';

  @override
  String get liveStatusLiveInfo =>
      'Änderungen von anderswo erscheinen hier, sobald sie passieren.';

  @override
  String get liveStatusConnecting => 'Verbinden';

  @override
  String get liveStatusConnectingInfo =>
      'Verbindung zu Live-Aktualisierungen wird aufgebaut. Änderungen erscheinen, sobald sie steht.';

  @override
  String get liveStatusPolling => 'Abfrage';

  @override
  String get liveStatusPollingInfo =>
      'Die Live-Verbindung bricht in diesem Netz immer wieder ab, daher kommen Aktualisierungen über einfaches HTTP. Sie können einige Sekunden später eintreffen.';

  @override
  String get liveStatusRefreshing => 'Aktualisierung';

  @override
  String liveStatusRefreshingInfo(int seconds) {
    return 'Live-Aktualisierungen kommen nicht durch und dieser Server ist zu alt für Abfragen, daher lädt der Bildschirm alle $seconds Sekunden neu.';
  }

  @override
  String get liveStatusOffline => 'Offline';

  @override
  String get liveStatusOfflineInfo =>
      'Der Server ist nicht erreichbar. Die App versucht es weiter und holt auf, sobald er wieder da ist.';

  @override
  String get liveStatusUnavailable => 'Nicht verfügbar';

  @override
  String get liveStatusUnavailableInfo =>
      'Diese Verbindung darf keine Live-Aktualisierungen verfolgen (sie braucht den Scope event:subscribe). Zum Aktualisieren nach unten ziehen.';

  @override
  String get liveDetailsHint => 'Tippen für Verbindungsdetails';

  @override
  String get liveDetailsLongPressHint => 'Lange drücken für Verbindungsdetails';

  @override
  String get liveDetailsShow => 'Verbindungsdetails anzeigen';

  @override
  String get liveDetailsTitle => 'Verbindungsdetails';

  @override
  String get liveDetailsNone =>
      'Für diesen Kontext besteht keine Live-Verbindung.';

  @override
  String get liveDetailsPausedInfo =>
      'Live-Aktualisierungen pausieren, solange die Engine der lokalen Instanz gestoppt ist. Sie starten mit ihr wieder.';

  @override
  String get liveDetailsModePaused => 'Pausiert';

  @override
  String get liveDetailsModeClosed => 'Geschlossen';

  @override
  String get liveDetailsServer => 'Server';

  @override
  String get liveDetailsMode => 'Zustand';

  @override
  String get liveDetailsTransport => 'Übertragung';

  @override
  String get liveTransportWebsocket => 'WebSocket';

  @override
  String get liveTransportPoll => 'Long Polling über HTTP';

  @override
  String get liveTransportRefresh => 'Neu laden in Intervallen';

  @override
  String get liveTransportNone => 'Keine';

  @override
  String get liveSourceProbe => 'WebSocket-Versuch im Hintergrund';

  @override
  String get liveSourcePoll => 'Abfrage';

  @override
  String get liveDetailsSince => 'Seit';

  @override
  String get liveDetailsLastContact => 'Server zuletzt erreicht';

  @override
  String get liveDetailsLastEvent => 'Letztes Ereignis';

  @override
  String get liveDetailsNever => 'Noch nicht';

  @override
  String get liveDetailsFailuresInRow => 'Fehlschläge in Folge';

  @override
  String get liveDetailsWindowFailures => 'WebSocket-Fehlschläge';

  @override
  String liveDetailsWindowValue(int count, int max, int minutes) {
    return '$count von $max innerhalb von $minutes Min., bevor auf Abfragen umgestellt wird';
  }

  @override
  String get liveDetailsPollEndpoint => 'Abfrage-Endpunkt';

  @override
  String get liveDetailsPollAvailable => 'Verfügbar';

  @override
  String get liveDetailsPollMissing => 'Fehlt auf diesem Server (404 oder 405)';

  @override
  String get liveDetailsNextRetry => 'Nächster Versuch';

  @override
  String get liveDetailsNextProbe => 'Nächster WebSocket-Versuch';

  @override
  String get liveDetailsLastError => 'Letzter Fehler';

  @override
  String get liveDetailsNoError =>
      'Seit dem Start der App ist nichts fehlgeschlagen.';

  @override
  String get liveDetailsErrorWhat => 'Was';

  @override
  String get liveDetailsErrorAt => 'Wann';

  @override
  String get liveDetailsErrorSource => 'Bei';

  @override
  String get liveDetailsErrorType => 'Ausnahme';

  @override
  String get liveDetailsHttpStatus => 'HTTP-Status';

  @override
  String get liveDetailsOsError => 'Systemfehler';

  @override
  String liveDetailsOsErrorValue(String message, String code) {
    return '$message (Code $code)';
  }

  @override
  String get liveDetailsCloseCode => 'Schließcode';

  @override
  String get liveDetailsErrorMessage => 'Meldung';

  @override
  String get liveErrorUnreachable => 'Server nicht erreichbar';

  @override
  String get liveErrorTimeout => 'Zeitüberschreitung';

  @override
  String get liveErrorTls => 'Sichere Verbindung fehlgeschlagen';

  @override
  String get liveErrorUpgradeRefused => 'WebSocket-Upgrade abgelehnt';

  @override
  String get liveErrorClosed => 'Verbindung geschlossen';

  @override
  String get liveErrorRefused => 'Vom Server abgelehnt';

  @override
  String get liveErrorHttp => 'HTTP-Fehler';

  @override
  String get liveErrorOther => 'Anderer Fehler';

  @override
  String get liveDetailsHints => 'Was es bedeuten kann';

  @override
  String get liveHintIdleTimeout =>
      'Ein Proxy oder Load Balancer schließt möglicherweise inaktive Verbindungen. Sein Lese-Timeout sollte für /api/v1/events und /api/v1/events/poll über 60 s liegen.';

  @override
  String get liveHintNoUpgrade =>
      'Der WebSocket schlägt fehl, während einfaches HTTP funktioniert. Der Proxy vor tix leitet WebSocket-Upgrades möglicherweise nicht weiter.';

  @override
  String get liveHintUnreachable =>
      'Das Telefon konnte den Host nicht erreichen. Prüfen Sie das Netzwerk, die Adresse und ob der Server läuft.';

  @override
  String get liveHintTls =>
      'Das Zertifikat des Servers wurde nicht akzeptiert: Es ist vielleicht abgelaufen, selbst signiert oder für einen anderen Namen ausgestellt.';

  @override
  String get liveHintRefused =>
      'Der Server hat dieser Verbindung Live-Aktualisierungen verweigert. Ein Token braucht den Scope event:subscribe.';

  @override
  String liveHintHttp(String status) {
    return 'Der Server oder ein Proxy antwortete mit HTTP $status. Seine Protokolle sollten den Grund nennen.';
  }

  @override
  String get liveHintPollMissing =>
      'Dieser Server ist älter als der Abfrage-Endpunkt, daher wird die Anzeige stattdessen in Intervallen neu geladen.';

  @override
  String get liveDetailsHistory => 'Letzte Änderungen';

  @override
  String get liveDetailsHistoryEmpty => 'Noch nichts.';

  @override
  String liveDetailsHistoryError(String kind, String source) {
    return '$kind ($source)';
  }

  @override
  String get liveDetailsReconnect => 'Jetzt neu verbinden';

  @override
  String get liveDetailsCopy => 'Details kopieren';

  @override
  String get liveDetailsCopied =>
      'Verbindungsdetails kopiert. Tokens und Cookies sind nicht enthalten.';

  @override
  String get aboutConnectionDetails => 'Verbindungsdetails';

  @override
  String get aboutConnectionDetailsHelp =>
      'Wie Live-Aktualisierungen diesen Kontext erreichen und was zuletzt fehlschlug';

  @override
  String get copyToClipboard => 'Kopieren';

  @override
  String get copiedToClipboard => 'Kopiert.';

  @override
  String get copyJson => 'JSON kopieren';

  @override
  String get copyJsonDone => 'JSON kopiert.';

  @override
  String get secretShare => 'Teilen';

  @override
  String get secretDone => 'Ich habe es gesichert';

  @override
  String get roleViewer => 'Betrachter';

  @override
  String get roleMember => 'Mitglied';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleViewerHelp => 'Liest Aufgaben, Projekte und Workflows.';

  @override
  String get roleMemberHelp =>
      'Erstellt, bearbeitet, übernimmt und verschiebt außerdem Aufgaben, kommentiert und exportiert.';

  @override
  String get roleAdminHelp => 'Darf in diesem Mandanten alles.';

  @override
  String get peopleTitle => 'Benutzer';

  @override
  String get peopleAdd => 'Benutzer hinzufügen';

  @override
  String peopleActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktiv',
      one: '1 aktiv',
    );
    return '$_temp0';
  }

  @override
  String peopleDisabledCount(int count) {
    return '$count deaktiviert';
  }

  @override
  String get peopleAddMember => 'Mitglied hinzufügen';

  @override
  String get peopleAddMemberButton => 'Hinzufügen';

  @override
  String get peopleAddMemberHelp =>
      'Geben Sie einem vorhandenen Agenten oder Konto eine Rolle in diesem Mandanten.';

  @override
  String get peopleNoActors =>
      'Alle Akteure gehören bereits zu diesem Mandanten.';

  @override
  String get peopleAgent => 'Agent';

  @override
  String get peoplePerson => 'Person';

  @override
  String get peopleEmpty => 'Noch keine Benutzer.';

  @override
  String get peopleYou => 'Sie';

  @override
  String get peopleNoRole => 'ohne Rolle';

  @override
  String get peopleDisabled => 'deaktiviert';

  @override
  String get peopleInvites => 'Offene Einladungen';

  @override
  String get peopleInvitesInfo =>
      'Ausgestellte, noch nicht genutzte Links. Neu ausstellen beendet den alten Link und gibt Ihnen einen neuen zum Versenden; Widerrufen beendet ihn.';

  @override
  String get peopleInvited => 'eingeladen';

  @override
  String peopleInvitedBy(String handle) {
    return 'eingeladen von $handle';
  }

  @override
  String get peopleInviteExpired => 'abgelaufen';

  @override
  String peopleInviteExpires(String day) {
    return 'läuft am $day ab';
  }

  @override
  String get peopleReissue => 'Neu ausstellen';

  @override
  String get peopleRevoke => 'Widerrufen';

  @override
  String peopleRevokeInviteTitle(String email) {
    return 'Einladung für $email widerrufen?';
  }

  @override
  String get peopleRevokeInviteBody =>
      'Der Link funktioniert sofort nicht mehr. Das Konto bleibt ohne Passwort bestehen, bis Sie es löschen oder erneut einladen.';

  @override
  String peopleInviteRevoked(String email) {
    return 'Einladung für $email widerrufen';
  }

  @override
  String get peopleSignInMode => 'Wie sie sich anmelden';

  @override
  String get peopleSignInModeInfo =>
      'Mit einem Einladungslink wählt die Person ihr Passwort selbst. Er funktioniert einmal und läuft ab; tix verschickt keine E-Mails, Sie geben den Link selbst weiter.';

  @override
  String get peopleModeInvite => 'Einladungslink';

  @override
  String get peopleModePassword => 'Passwort festlegen';

  @override
  String get peopleDisplayName => 'Anzeigename';

  @override
  String get peopleDisplayNameHelp =>
      'Leer zeigt stattdessen die E-Mail-Adresse.';

  @override
  String get peopleRole => 'Rolle';

  @override
  String get peopleLinkExpires => 'Link läuft ab nach';

  @override
  String peopleDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tagen',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get peopleYear => '1 Jahr';

  @override
  String get peopleInviteHelp =>
      'Sie erhalten einen Link zum Weitergeben. Er funktioniert einmal, und damit wählen sie ihr eigenes Passwort.';

  @override
  String get peopleRequireChangeFirst =>
      'Passwortänderung bei der ersten Anmeldung verlangen';

  @override
  String get peopleCreateInvite => 'Einladungslink erstellen';

  @override
  String get peopleCreateUser => 'Benutzer erstellen';

  @override
  String peopleCreated(String email) {
    return '$email erstellt';
  }

  @override
  String get peopleInviteLink => 'Einladungslink';

  @override
  String peopleSendLink(String email) {
    return 'Senden Sie diesen Link an $email';
  }

  @override
  String get peopleLinkOnce =>
      'Er funktioniert einmal. tix verschickt keine E-Mails, und der Link wird nicht erneut angezeigt.';

  @override
  String peopleLinkOnceUntil(String day) {
    return 'Er funktioniert einmal und läuft am $day ab. tix verschickt keine E-Mails, und der Link wird nicht erneut angezeigt.';
  }

  @override
  String get peopleRename => 'Anzeigenamen ändern';

  @override
  String get peopleNoName => 'Nicht festgelegt';

  @override
  String get peopleChangeRole => 'Rolle ändern';

  @override
  String get peopleSignIn => 'Meldet sich an mit';

  @override
  String peopleSso(String provider) {
    return 'Single Sign-on ($provider)';
  }

  @override
  String get peoplePasswordSignIn => 'Einem Passwort';

  @override
  String get peopleSecondFactor => 'Zweiter Faktor';

  @override
  String get peopleTotpOn => 'Eingerichtet';

  @override
  String get peopleTotpOff => 'Keiner';

  @override
  String get peopleCreatedAt => 'Erstellt';

  @override
  String get peopleAccess => 'Zugang';

  @override
  String get peopleDisabledSwitch => 'Deaktiviert';

  @override
  String get peopleDisabledHelp =>
      'Ein deaktiviertes Konto kann sich nicht anmelden: Seine Sitzungen enden und seine API-Token werden sofort widerrufen. Erneutes Aktivieren bringt die Token nicht zurück.';

  @override
  String peopleDisabledToast(String name) {
    return '$name deaktiviert';
  }

  @override
  String peopleEnabledToast(String name) {
    return '$name kann sich wieder anmelden';
  }

  @override
  String get peopleRequireChange =>
      'Bei der nächsten Anmeldung eine Passwortänderung verlangen';

  @override
  String get peopleRequireChangeHelp =>
      'Die nächste Anmeldung mit Passwort hält auf einer Seite an, die ein neues verlangt. Offene Sitzungen und API-Token sind nicht betroffen.';

  @override
  String get peopleSaved => 'Gespeichert';

  @override
  String get peopleSave => 'Speichern';

  @override
  String peopleRoleChanged(String name, String role) {
    return '$name ist jetzt $role';
  }

  @override
  String get peopleDangerZone => 'Gefahrenbereich';

  @override
  String get peopleRemoveMember => 'Aus diesem Mandanten entfernen';

  @override
  String get peopleRemoveMemberHelp =>
      'Beendet die Mitgliedschaft und behält das Konto.';

  @override
  String get peopleRemoveMemberButton => 'Entfernen';

  @override
  String peopleRemoveMemberTitle(String name) {
    return '$name aus diesem Mandanten entfernen?';
  }

  @override
  String get peopleRemoveMemberBody =>
      'Die Person kann hier sofort nicht mehr handeln. Das Konto bleibt und kann wieder eine Rolle erhalten.';

  @override
  String peopleMemberRemoved(String name) {
    return '$name aus diesem Mandanten entfernt';
  }

  @override
  String peopleDelete(String name) {
    return '$name löschen';
  }

  @override
  String get peopleDeleteHelp =>
      'Löschen entfernt das Konto und seine Mitgliedschaft. Meist ist Deaktivieren gemeint, und das lässt sich rückgängig machen.';

  @override
  String get peopleDeleteButton => 'Löschen';

  @override
  String peopleDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get peopleDeleteBody =>
      'Löschen entfernt das Konto und seine Mitgliedschaft. Das lässt sich nicht rückgängig machen.';

  @override
  String peopleDeleted(String name) {
    return '$name gelöscht';
  }

  @override
  String get tokensTitle => 'API-Token';

  @override
  String get tokensMine => 'Meine API-Token';

  @override
  String get tokensIssue => 'Token ausstellen';

  @override
  String get tokensIssueButton => 'Ausstellen';

  @override
  String get tokensWholeTenant => 'Alle Token dieses Mandanten';

  @override
  String get tokensOwn => 'Ihre Token';

  @override
  String get tokensWholeNote =>
      'Sie haben tenant:admin, daher zeigt diese Liste alle Token des Mandanten und wem sie gehören. Das Widerrufen fremder Token wird als solches protokolliert.';

  @override
  String get tokensIntro =>
      'Ein Token ist die Anmeldeinformation, die ein Skript, die CLI oder ein Agent statt einer Anmeldung vorlegt. Es trägt eigene Berechtigungen, und sein Wert wird nur einmal angezeigt, beim Ausstellen.';

  @override
  String get tokensEmpty => 'Keine Token.';

  @override
  String get tokensActive => 'aktiv';

  @override
  String get tokensExpired => 'abgelaufen';

  @override
  String get tokensRevoked => 'widerrufen';

  @override
  String get tokensRevoke => 'Widerrufen';

  @override
  String tokensOwner(String name) {
    return 'Inhaber: $name';
  }

  @override
  String tokensOwnerYou(String name) {
    return 'Inhaber: $name (Sie)';
  }

  @override
  String tokensCreated(String day) {
    return 'Erstellt am $day';
  }

  @override
  String tokensExpires(String day) {
    return 'Läuft am $day ab';
  }

  @override
  String get tokensNeverExpires => 'Läuft nie ab';

  @override
  String get tokensNotUsed => 'Noch nicht verwendet';

  @override
  String tokensLastUsed(String when) {
    return 'Zuletzt verwendet $when';
  }

  @override
  String tokensRevokeTitle(String name) {
    return '$name widerrufen?';
  }

  @override
  String get tokensRevokeBody =>
      'Was dieses Token verwendet, kann sich sofort nicht mehr anmelden. Das lässt sich nicht rückgängig machen, und der Wert ist nicht wiederherstellbar.';

  @override
  String tokensRevokeOther(String name) {
    return 'Dieses Token gehört $name, nicht Ihnen, und das Protokoll hält fest, dass Sie ein fremdes Token beendet haben.';
  }

  @override
  String tokensRevokeNamed(String name) {
    return '$name widerrufen';
  }

  @override
  String tokensRevokedToast(String name) {
    return '$name widerrufen';
  }

  @override
  String get tokensName => 'Name';

  @override
  String get tokensNameHelp =>
      'Daran erkennen Sie es beim Widerrufen, etwa ci oder laptop. Zwei aktive Token dürfen nicht gleich heißen.';

  @override
  String get tokensScopes => 'Berechtigungen';

  @override
  String get tokensNotHeld =>
      'Sie haben diese Berechtigung nicht und können sie daher nicht vergeben.';

  @override
  String get tokensPresetAgent => 'Agent';

  @override
  String get tokensPresetAgentNote =>
      'Aufgaben lesen, erstellen und bearbeiten, übernehmen, verschieben und kommentieren.';

  @override
  String get tokensPresetRead => 'Nur lesen';

  @override
  String get tokensPresetReadNote =>
      'Aufgaben, Projekte und Workflows lesen und den Ereignisstrom verfolgen.';

  @override
  String get tokensExpiry => 'Läuft ab';

  @override
  String get tokensExpiryInfo =>
      'Ein Ablaufdatum ist das einzige Mittel, den Schaden eines unbemerkt geleakten Tokens zu begrenzen. Wählen Sie die kürzeste Dauer, die reicht.';

  @override
  String get tokensNever => 'Nie';

  @override
  String tokensIssuedTitle(String name) {
    return 'Token $name ausgestellt';
  }

  @override
  String get tokensValue => 'Kopieren Sie dieses Token jetzt';

  @override
  String get tokensValueWarning =>
      'Bewahren Sie es sicher auf. Es wird nicht erneut angezeigt, und nichts kann es später zeigen.';

  @override
  String get scopeAll =>
      'Alles außer globaler Administration und Kontoverlauf. Nur für eine Anmeldeinformation, der Sie wie sich selbst vertrauen.';

  @override
  String get scopeGroupTasks => 'Aufgaben';

  @override
  String get scopeGroupProjects => 'Projekte';

  @override
  String get scopeGroupWorkflows => 'Workflows';

  @override
  String get scopeGroupComments => 'Kommentare und Artefakte';

  @override
  String get scopeGroupEvents => 'Ereignisse';

  @override
  String get scopeGroupAdmin => 'Administration';

  @override
  String get scopeGroupAccount => 'Ihr Konto';

  @override
  String get scopeTaskRead =>
      'Aufgaben, ihre Kommentare und ihren Verlauf lesen.';

  @override
  String get scopeTaskWrite => 'Aufgaben erstellen und bearbeiten.';

  @override
  String get scopeTaskTransition =>
      'Eine Aufgabe von einem Status in einen anderen verschieben.';

  @override
  String get scopeTaskClaim =>
      'Aufgaben übernehmen, die Sperre verlängern und freigeben.';

  @override
  String get scopeTaskDelete =>
      'Aufgaben löschen und aus dem Papierkorb wiederherstellen.';

  @override
  String get scopeTaskReclaim =>
      'Die Sperre eines anderen Bearbeiters beenden.';

  @override
  String get scopeTaskApprove =>
      'Arbeit an einem Workflow-Übergang, der es verlangt, freigeben oder ablehnen.';

  @override
  String get scopeProjectRead => 'Projekte lesen.';

  @override
  String get scopeProjectWrite => 'Projekte erstellen und ändern.';

  @override
  String get scopeWorkflowRead => 'Workflows lesen.';

  @override
  String get scopeWorkflowWrite => 'Workflows erstellen und ändern.';

  @override
  String get scopeCommentWrite => 'Aufgaben kommentieren.';

  @override
  String get scopeArtifactWrite => 'Artefakte an Aufgaben anhängen.';

  @override
  String get scopeEventSubscribe => 'Den Live-Ereignisstrom verfolgen.';

  @override
  String get scopeUserAdmin => 'Benutzer erstellen, ändern und entfernen.';

  @override
  String get scopeTotpAdmin =>
      'Den zweiten Faktor einer anderen Person zurücksetzen.';

  @override
  String get scopeTokenAdmin => 'API-Token ausstellen und widerrufen.';

  @override
  String get scopeWebhookAdmin => 'Ausgehende Webhooks verwalten.';

  @override
  String get scopeTenantAdmin =>
      'Den Mandanten, seine Mitglieder und Domains verwalten.';

  @override
  String get scopeSyncAdmin =>
      'Importe aus anderen Trackern verwalten und starten.';

  @override
  String get scopeAuditRead => 'Das Audit-Protokoll lesen.';

  @override
  String get scopeExport =>
      'Aufgaben und einen Snapshot des ganzen Mandanten exportieren.';

  @override
  String get scopeImport =>
      'Aufgaben und Snapshots in den Mandanten importieren.';

  @override
  String get scopeGlobalAdmin =>
      'Alle Mandanten dieses Servers verwalten. Nur das Token eines globalen Admins kann sie tragen.';

  @override
  String get scopeAccountRead =>
      'Den Verlauf Ihres eigenen Kontos lesen, der jeden Ihrer Mandanten nennt. Nur ein Token für Ihr eigenes Konto kann sie tragen.';

  @override
  String get accountTitle => 'Ihr Konto';

  @override
  String get accountKind => 'Angemeldet als';

  @override
  String get accountKindToken => 'Ein API-Token';

  @override
  String get accountKindAgent => 'Ein Agent';

  @override
  String get accountKindPerson => 'Eine Person';

  @override
  String get accountGlobalAdmin => 'globaler Admin';

  @override
  String get accountGlobalAdminYes => 'Verwaltet alle Mandanten dieses Servers';

  @override
  String get accountMemberships => 'Ihre Mandanten';

  @override
  String get accountMembershipsHelp =>
      'Jeder Mandant, zu dem dieses Konto gehört, mit seiner Rolle dort.';

  @override
  String get accountCurrent => 'aktuell';

  @override
  String get accountHistory => 'Kontoverlauf';

  @override
  String get accountHistoryHelp =>
      'Jede Änderung an Passwort, zweitem Faktor und Mitgliedschaften, in jedem Mandanten. Nur Sie und globale Admins können ihn lesen.';

  @override
  String get accountHistoryEmpty => 'Noch nichts geändert.';

  @override
  String get accountHistoryNotReadable =>
      'Dieses Token kann Ihren Kontoverlauf nicht lesen: Dafür ist die Berechtigung account:read nötig, die nur ein für Ihr eigenes Konto ausgestelltes Token trägt.';

  @override
  String accountBy(String email) {
    return 'von $email';
  }

  @override
  String get accountBySystem => 'vom System';

  @override
  String get calendarTitle => 'Kalender-Feed';

  @override
  String get calendarLead => 'Ihre Fälligkeiten in Google, Apple oder Outlook';

  @override
  String get calendarUnavailable => 'Hier gibt es nichts zu verwalten';

  @override
  String get calendarUnavailableBody =>
      'Ein Kalender-Feed liest Aufgaben in Ihrem Namen, und diese Anmeldeinformation kann keine Aufgaben lesen.';

  @override
  String get calendarCreate => 'Feed erstellen';

  @override
  String get calendarNone => 'Kein Kalender-Feed';

  @override
  String get calendarNoneBody =>
      'Eine private Adresse, die Ihr Kalender abonniert, damit Ihre Fälligkeiten neben dem Rest Ihrer Woche erscheinen.';

  @override
  String get calendarFeed => 'Feed-Adresse';

  @override
  String get calendarFeedInfo =>
      'Jede Aufgabe mit Fälligkeit ist ein ganztägiger Termin mit Link hierher. Wer die Adresse hat, kann lesen, was sie auflistet: Behandeln Sie sie wie ein Passwort. Gespeichert wird nur ein Hash, daher kann sie nicht erneut angezeigt werden.';

  @override
  String get calendarActive => 'Aktiv';

  @override
  String calendarCreatedOn(String day) {
    return 'Erstellt am $day. Die Adresse wurde einmal angezeigt; erneuern Sie sie für eine neue.';
  }

  @override
  String get calendarShownOnce =>
      'Die Adresse wurde einmal angezeigt; erneuern Sie sie für eine neue.';

  @override
  String get calendarFilter => 'Feed-Filter';

  @override
  String get calendarFilterDefault =>
      'Die Ihnen zugewiesenen, nicht erledigten Aufgaben';

  @override
  String get calendarFilterHint => 'project:infra tag:ops';

  @override
  String get calendarFilterHelp =>
      'Die Filtersprache der Aufgabenliste. Leer heißt: Ihre, nicht erledigten. Aufgeführt werden nur Aufgaben mit Fälligkeit.';

  @override
  String get calendarEditFilter => 'Filter ändern';

  @override
  String get calendarSaveFilter => 'Filter speichern';

  @override
  String get calendarFilterSaved => 'Feed-Filter gespeichert';

  @override
  String get calendarRotate => 'Adresse erneuern';

  @override
  String get calendarRotateHelp =>
      'Eine neue Adresse mit demselben Filter; die alte endet sofort.';

  @override
  String get calendarRotateButton => 'Erneuern';

  @override
  String get calendarRevoke => 'Feed widerrufen';

  @override
  String get calendarRevokeHelp =>
      'Die Adresse antwortet nicht mehr. Abonnierte Kalender behalten den zuletzt abgerufenen Stand.';

  @override
  String get calendarRevokeButton => 'Widerrufen';

  @override
  String get calendarRevokeTitle => 'Kalender-Feed widerrufen?';

  @override
  String get calendarRevokeBody =>
      'Die Adresse endet sofort. Entfernen Sie das Abo auch in Ihrer Kalender-App.';

  @override
  String get calendarRevoked => 'Kalender-Feed widerrufen';

  @override
  String get calendarAddress => 'Abonnieren Sie diese Adresse';

  @override
  String get calendarOnce =>
      'Fügen Sie sie in Ihrer Kalender-App hinzu. Sie wird nicht erneut angezeigt, kopieren Sie sie jetzt.';

  @override
  String get calendarRotatedOnce =>
      'Diese Adresse ersetzt die alte, die nicht mehr funktioniert. Abonnieren Sie sie überall dort neu, wo die alte verwendet wurde. Sie wird nicht erneut angezeigt.';

  @override
  String calendarLists(String filter) {
    return 'Listet: $filter';
  }

  @override
  String get calendarListsDefault =>
      'Listet die Ihnen zugewiesenen, nicht erledigten Aufgaben.';

  @override
  String get calendarHowGoogle =>
      'Google Kalender: Weitere Kalender, dann Per URL, und die Adresse einfügen.';

  @override
  String get calendarHowApple =>
      'Apple Kalender: Ablage, dann Neues Kalenderabonnement, oder Auf diesem Gerät abonnieren verwenden.';

  @override
  String get calendarHowOutlook =>
      'Outlook: Kalender hinzufügen, dann Aus dem Internet abonnieren, und die Adresse einfügen.';

  @override
  String get calendarSubscribeHere => 'Auf diesem Gerät abonnieren';

  @override
  String get transferTitle => 'Export und Import';

  @override
  String get transferNoProjects =>
      'Legen Sie ein Projekt an, bevor Sie Aufgaben exportieren oder importieren.';

  @override
  String get transferExportTitle => 'Aufgaben exportieren';

  @override
  String get transferExportHelp =>
      'Die Aufgaben eines Projekts oder die per Filter gewählten als Datei.';

  @override
  String get transferQuery => 'Filter';

  @override
  String get transferQueryHelp =>
      'Die Filtersprache der Aufgabenliste. Leer exportiert alle Aufgaben.';

  @override
  String get transferFormat => 'Format';

  @override
  String get transferFormatCsv => 'CSV, für Tabellen';

  @override
  String get transferFormatNdjson => 'NDJSON, eine Aufgabe pro Zeile';

  @override
  String get transferFormatMarkdown => 'Markdown-Tabelle';

  @override
  String get transferColumns => 'Spalten';

  @override
  String get transferDates => 'Datumsangaben';

  @override
  String get transferDatesIso => 'Datum und Uhrzeit (ISO)';

  @override
  String get transferDatesDay => 'Nur Tag';

  @override
  String get transferDelimiter => 'Trennzeichen';

  @override
  String get transferDelimiterComma => 'Komma';

  @override
  String get transferDelimiterSemicolon => 'Semikolon';

  @override
  String get transferDelimiterTab => 'Tabulator';

  @override
  String get transferDelimiterBar => 'Senkrechter Strich';

  @override
  String get transferFinished => 'Erledigte Aufgaben einbeziehen';

  @override
  String get transferSubtasks => 'Unteraufgaben einbeziehen';

  @override
  String get transferTrashed => 'Aufgaben im Papierkorb einbeziehen';

  @override
  String get transferExportButton => 'Exportieren';

  @override
  String transferExported(String name) {
    return '$name gespeichert';
  }

  @override
  String get transferSnapshotTitle => 'Snapshot';

  @override
  String get transferSnapshotHelp =>
      'Alles in diesem Mandanten als eine NDJSON-Datei, die tix anderswo importieren kann.';

  @override
  String get transferSnapshotComments => 'Kommentare einbeziehen';

  @override
  String get transferSnapshotButton => 'Snapshot exportieren';

  @override
  String get transferImportTitle => 'Aufgaben importieren';

  @override
  String get transferImportHelp =>
      'Eine CSV-, JSON- oder NDJSON-Datei mit Aufgaben, auch aus Jira, GitHub, Trello und Linear. Sie sehen, was passieren würde, bevor sich etwas ändert.';

  @override
  String get transferPick => 'Datei wählen';

  @override
  String transferDryRun(
    int rows,
    int created,
    int updated,
    int skipped,
    int failed,
  ) {
    return '$rows Zeilen: $created neu, $updated aktualisiert, $skipped übersprungen, $failed fehlgeschlagen.';
  }

  @override
  String transferImportError(int line, String message) {
    return 'Zeile $line: $message';
  }

  @override
  String transferImportButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben importieren',
      one: '1 Aufgabe importieren',
    );
    return '$_temp0';
  }

  @override
  String transferImported(int created, int updated) {
    return 'Importiert: $created erstellt, $updated aktualisiert';
  }

  @override
  String get columnRef => 'Referenz';

  @override
  String get columnTitle => 'Titel';

  @override
  String get columnParent => 'Übergeordnet';

  @override
  String get columnDependsOn => 'Hängt ab von';

  @override
  String get columnRepeat => 'Wiederholung';

  @override
  String get columnCreated => 'Erstellt';

  @override
  String get columnUpdated => 'Aktualisiert';

  @override
  String get columnStarted => 'Begonnen';

  @override
  String get columnCompleted => 'Abgeschlossen';

  @override
  String get columnDeleted => 'Gelöscht';

  @override
  String get columnCreator => 'Ersteller';

  @override
  String get columnProject => 'Projekt';

  @override
  String get columnId => 'Kennung';

  @override
  String get columnComments => 'Kommentare';

  @override
  String get columnHistory => 'Verlauf';

  @override
  String get settingsAccountHelp => 'Profil, Mandanten und Verlauf';

  @override
  String get settingsCalendarHelp => 'Ihre Fälligkeiten in Ihrer Kalender-App';

  @override
  String get settingsTokensHelp =>
      'Zugangsdaten für Skripte, die CLI und Agenten';

  @override
  String get securityTitle => 'Sicherheit';

  @override
  String get securitySubtitle => 'Ihr zweiter Faktor und Ihre SSH-Schlüssel';

  @override
  String get totpTitle => 'Zweiter Faktor';

  @override
  String get totpInfo =>
      'Ein Code aus einer Authentifizierungs-App, der nach Ihrem Passwort abgefragt wird. Mit Wiederherstellungscodes kommen Sie hinein, wenn die App nicht zur Hand ist.';

  @override
  String get totpOn => 'Aktiv';

  @override
  String get totpOff => 'Aus';

  @override
  String get totpPending => 'Nicht bestätigt';

  @override
  String totpSince(String date) {
    return 'Seit $date';
  }

  @override
  String get totpOnBody =>
      'Die Anmeldung fragt nach Ihrem Passwort einen Code aus Ihrer Authentifizierungs-App ab.';

  @override
  String get totpOffBody => 'Die Anmeldung fragt nur nach Ihrem Passwort.';

  @override
  String get totpPendingBody =>
      'Die Einrichtung wurde begonnen, aber nie mit einem Code bestätigt. Richten Sie ihn erneut ein, um sie abzuschließen.';

  @override
  String totpRequiredOn(String surfaces) {
    return 'Ihr Mandant verlangt einen zweiten Faktor für: $surfaces.';
  }

  @override
  String get totpSurfaceWeb => 'den Browser';

  @override
  String get totpSurfaceCli => 'die Kommandozeile';

  @override
  String get totpSurfaceSsh => 'SSH';

  @override
  String totpCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wiederherstellungscodes übrig',
      one: '1 Wiederherstellungscode übrig',
      zero: 'Keine Wiederherstellungscodes mehr',
    );
    return '$_temp0';
  }

  @override
  String totpLocked(String time) {
    return 'Zu viele falsche Codes. Codes werden bis $time abgelehnt.';
  }

  @override
  String get totpSetUp => 'Einrichten';

  @override
  String get totpNewCodes => 'Neue Wiederherstellungscodes';

  @override
  String get totpNewCodesBody =>
      'Ihre bisherigen Wiederherstellungscodes funktionieren sofort nicht mehr, ob benutzt oder nicht, und ein neuer Satz wird einmal angezeigt.';

  @override
  String get totpNewCodesConfirm => 'Codes ersetzen';

  @override
  String get totpRemove => 'Zweiten Faktor entfernen';

  @override
  String get totpRemoveBody =>
      'Die Anmeldung fragt dann nur noch nach Ihrem Passwort, und Ihre Wiederherstellungscodes funktionieren nicht mehr. Verlangt Ihr Mandant einen zweiten Faktor, müssen Sie ihn erneut einrichten.';

  @override
  String get totpRemoved => 'Zweiter Faktor entfernt.';

  @override
  String get totpCodesHeading =>
      'Speichern Sie diese Wiederherstellungscodes jetzt';

  @override
  String get totpCodesNote =>
      'Jeder meldet Sie einmal ohne Ihre Authentifizierungs-App an. Sie werden nur einmal angezeigt und lassen sich nicht erneut abrufen; wenn Sie sie verlieren, erzeugen Sie einen neuen Satz.';

  @override
  String get totpCodesSaved => 'Ich habe sie gespeichert';

  @override
  String get totpConfirm => 'Bestätigen';

  @override
  String get totpStep1 =>
      '1. Fügen Sie diesen Schlüssel Ihrer Authentifizierungs-App hinzu oder öffnen Sie ihn dort von diesem Gerät aus.';

  @override
  String get totpSecretHeading => 'Ihr Authentifizierungsschlüssel';

  @override
  String totpSecretNote(String account, String issuer) {
    return 'Konto $account bei $issuer. Halten Sie ihn geheim: Wer ihn hat, kann Ihre Codes erzeugen.';
  }

  @override
  String get totpOpenApp => 'In der App öffnen';

  @override
  String get totpStep2 =>
      '2. Geben Sie den sechsstelligen Code ein, den die App anzeigt.';

  @override
  String get sshKeysTitle => 'SSH-Schlüssel';

  @override
  String get sshKeysInfo =>
      'Ein hier hinterlegter Schlüssel meldet Sie in diesem Mandanten per SSH an der Terminaloberfläche von tix an. Widerrufene Schlüssel bleiben aufgeführt, damit man sieht, warum einer nicht mehr funktioniert.';

  @override
  String get sshKeysEmpty => 'Noch keine SSH-Schlüssel.';

  @override
  String get sshKeyAdd => 'SSH-Schlüssel hinzufügen';

  @override
  String get sshKeyAddSubmit => 'Schlüssel hinzufügen';

  @override
  String get sshKeyAdded => 'SSH-Schlüssel hinzugefügt.';

  @override
  String get sshKeyUnlabelled => 'Schlüssel ohne Bezeichnung';

  @override
  String get sshKeyRevoked => 'Widerrufen';

  @override
  String sshKeyAddedOn(String date) {
    return 'Hinzugefügt am $date';
  }

  @override
  String sshKeyLastUsed(String date) {
    return 'Zuletzt verwendet am $date';
  }

  @override
  String get sshKeyNeverUsed => 'Nie verwendet';

  @override
  String sshKeyRevokedOn(String date) {
    return 'Widerrufen am $date';
  }

  @override
  String get sshKeyRevoke => 'Widerrufen';

  @override
  String sshKeyRevokeBody(String name) {
    return '$name meldet ab sofort nicht mehr per SSH an. Das lässt sich nicht rückgängig machen; hinterlegen Sie den Schlüssel erneut, um ihn zu nutzen.';
  }

  @override
  String get sshKeyRevokedToast => 'SSH-Schlüssel widerrufen.';

  @override
  String get sessionsTitle => 'Aktive Sitzungen';

  @override
  String get sessionsInfo =>
      'Ihre Anmeldungen per Browser und Terminal bei diesem Mandanten, die noch nicht abgelaufen sind. Widerrufen Sie jede, die Sie nicht kennen. API-Token verwalten Sie unter Token.';

  @override
  String get sessionsEmpty => 'Keine aktiven Sitzungen.';

  @override
  String get sessionsNotReadable =>
      'Dieses Token kann Ihre Sitzungen nicht auflisten: Es braucht den Bereich account:read, den „*“ nicht einschließt. Melden Sie sich mit Ihrem Passwort an oder verwenden Sie ein Token, das mit account:read erstellt wurde.';

  @override
  String get sessionsShowMore => 'Mehr anzeigen';

  @override
  String get sessionCurrent => 'Diese Sitzung';

  @override
  String get sessionUnknownAgent => 'Unbekanntes Gerät';

  @override
  String get sessionMethodPassword => 'Passwort';

  @override
  String get sessionMethodSshKey => 'SSH-Schlüssel';

  @override
  String get sessionMethodSwitch => 'Mandantenwechsel';

  @override
  String get sessionSecondFactor => 'mit zweitem Faktor';

  @override
  String sessionSignedIn(String when) {
    return 'Angemeldet $when';
  }

  @override
  String sessionExpires(String when) {
    return 'Läuft ab $when';
  }

  @override
  String get sessionRevoke => 'Widerrufen';

  @override
  String get sessionRevokeTitle => 'Diese Sitzung widerrufen?';

  @override
  String sessionRevokeBody(String agent) {
    return '$agent wird sofort abgemeldet und muss sich neu anmelden.';
  }

  @override
  String get sessionRevokeCurrentBody =>
      'Mit dieser Sitzung ist die App angemeldet. Wenn Sie sie widerrufen, werden Sie hier abgemeldet und müssen sich neu anmelden.';

  @override
  String get sessionRevoked => 'Sitzung widerrufen.';

  @override
  String get sshKeyPublicKey => 'Öffentlicher Schlüssel';

  @override
  String get sshKeyPublicKeyHelp =>
      'Die Zeile aus Ihrer .pub-Datei, wie ssh-keygen sie schreibt.';

  @override
  String get sshKeyLabel => 'Bezeichnung (optional)';

  @override
  String get sshKeyLabelHelp =>
      'Unterscheidet diesen Schlüssel von Ihren anderen, etwa nach dem Rechner, auf dem er liegt.';

  @override
  String get sshKeyAllTenants => 'Alle meine Mandanten';

  @override
  String get sshKeyAllTenantsHelp =>
      'Hinterlegt den Schlüssel in jedem Ihrer Mandanten, nicht nur in diesem.';

  @override
  String get tenantSettingsTitle => 'Mandanteneinstellungen';

  @override
  String get tenantSaved => 'Gespeichert.';

  @override
  String get tenantGeneralTitle => 'Allgemein';

  @override
  String get tenantName => 'Name';

  @override
  String get tenantKey => 'Schlüssel';

  @override
  String get tenantKeyHelp =>
      'Kurz und eindeutig: Buchstaben, Ziffern, Binde- und Unterstriche, beginnend mit einem Buchstaben. Er lässt sich später nicht ändern.';

  @override
  String get tenantTimezone => 'Zeitzone';

  @override
  String get tenantTimezoneHelp =>
      'Eine IANA-Zone, in der Daten angezeigt werden, sofern niemand eine eigene wählt. Leer übernimmt die des Servers.';

  @override
  String get tenantTimeFormat => 'Datumsformat';

  @override
  String get tenantServerDefault => 'Serverstandard';

  @override
  String get tenantThemeTitle => 'Design';

  @override
  String get tenantThemeInfo =>
      'Die Farbe des Mandanten auf allen Oberflächen: im Web, im Terminal und in dieser App. Status- und Prioritätsfarben ändern sich nie mit.';

  @override
  String get tenantThemeDefault => 'Standard';

  @override
  String get tenantThemeCustom => 'Eigene Farbe';

  @override
  String get tenantThemeCustomHelp =>
      '#rrggbb. tix passt sie an, bis Text darauf und daneben lesbar bleibt.';

  @override
  String get tenantThemeCustomBad =>
      'Schreiben Sie die Farbe als #rrggbb, etwa #0f766e.';

  @override
  String get tenantThemePreview => 'Vorschau';

  @override
  String get tenantThemeSampleRow => 'Eine ausgewählte Zeile';

  @override
  String get tenantThemeSampleLink => 'Ein Link';

  @override
  String get tenantThemeSampleButton => 'Neue Aufgabe';

  @override
  String get tenantThemeSaved => 'Design gespeichert.';

  @override
  String get tenantTotpTitle => 'Zweiter Faktor';

  @override
  String get tenantTotpInfo =>
      'Verlangt bei der Anmeldung einen Code aus einer Authentifizierungs-App. Wer keinen hat, wird bei der Anmeldung durch die Einrichtung geführt, daher sperrt das Einschalten niemanden aus.';

  @override
  String get tenantTotpWeb => 'Im Browser verlangen';

  @override
  String get tenantTotpCli => 'In der Kommandozeile verlangen';

  @override
  String get tenantTotpSsh => 'Per SSH zusätzlich zum Schlüssel verlangen';

  @override
  String get tenantTotpNone => 'Nicht verlangt';

  @override
  String get tenantTotpBadge => 'Zweiter Faktor';

  @override
  String get tenantLeaseTitle => 'Reservierungen';

  @override
  String get tenantLeaseInfo =>
      'Wie lange die Reservierung einer Aufgabe durch einen Agenten gilt. Ein Projekt, ein Workflow oder die Reservierung kann weniger verlangen; die Obergrenze des Servers gilt immer.';

  @override
  String get tenantLeaseDefault => 'Standarddauer';

  @override
  String get tenantLeaseDefaultHelp =>
      'Eine Dauer wie 30m oder 2h. Leer übernimmt die des Servers.';

  @override
  String get tenantLeaseMax => 'Höchstdauer';

  @override
  String get tenantLeaseMaxHelp =>
      'Begrenzt jede Reservierung in diesem Mandanten. Sie kann die Obergrenze des Servers senken, nie anheben.';

  @override
  String get tenantTrashTitle => 'Papierkorb';

  @override
  String get tenantTrashKeep => 'Gelöschte Aufgaben im Papierkorb behalten';

  @override
  String get tenantTrashOnBody =>
      'Gelöschte Aufgaben lassen sich wiederherstellen, bis die Aufräumregeln den Papierkorb leeren.';

  @override
  String get tenantTrashOffBody =>
      'Das Löschen einer Aufgabe ist endgültig. Aufgaben, die schon im Papierkorb liegen, bleiben dort.';

  @override
  String get tenantTrashOnShort =>
      'Gelöschte Aufgaben kommen in den Papierkorb';

  @override
  String get tenantTrashOffShort => 'Löschen ist endgültig';

  @override
  String get tenantDelete => 'Mandanten löschen';

  @override
  String get tenantDeleteHelp =>
      'Seine Daten sind nicht mehr erreichbar und seine Domains lösen nicht mehr auf.';

  @override
  String get tenantDeleteCurrent =>
      'Das ist der Mandant, in dem Sie arbeiten. Wechseln Sie zu einem anderen, um ihn zu löschen.';

  @override
  String tenantDeleteBody(String name, String key) {
    return '$name ($key) und alles darin ist für alle nicht mehr erreichbar, und seine Domains lösen nicht mehr auf. Nur der Betreiber des Servers kann ihn zurückholen.';
  }

  @override
  String tenantDeleted(String name) {
    return '$name gelöscht.';
  }

  @override
  String get tenantsTitle => 'Mandanten';

  @override
  String get tenantsSubtitle => 'Alle Mandanten auf diesem Server';

  @override
  String get tenantsEmpty => 'Keine Mandanten.';

  @override
  String get tenantsEmptyBody =>
      'Legen Sie einen mit seinem ersten Administrator an.';

  @override
  String get tenantsPick => 'Wählen Sie einen Mandanten, um ihn hier zu sehen.';

  @override
  String get tenantCreate => 'Neuer Mandant';

  @override
  String get tenantCreateSubmit => 'Mandanten anlegen';

  @override
  String tenantCreated(String name) {
    return '$name angelegt.';
  }

  @override
  String get tenantFirstAdmin => 'Erster Administrator';

  @override
  String get tenantFirstAdminHelp =>
      'Wird Administrator des neuen Mandanten. Eine Adresse mit bestehendem Konto behält ihr Passwort und ihren zweiten Faktor.';

  @override
  String get tenantPasswordHelp =>
      'Mindestens 12 Zeichen. Leer lassen, dann erzeugt tix eines und zeigt es einmal an.';

  @override
  String get tenantCredentialsHeading => 'Kopieren Sie diese Passwörter jetzt';

  @override
  String get tenantCredentialsNote =>
      'tix hat sie erzeugt und zeigt sie nur einmal; nirgends werden sie gespeichert. Geben Sie jedes seinem Administrator, der bei der ersten Anmeldung ein neues wählt. Geht eines verloren, setzen Sie ein neues Passwort.';

  @override
  String get tenantCurrent => 'Aktuell';

  @override
  String get tenantMember => 'Mitglied';

  @override
  String get tenantNoTrash => 'Kein Papierkorb';

  @override
  String get tenantOverview => 'Überblick';

  @override
  String get tenantCreatedAt => 'Angelegt';

  @override
  String get tenantSwitch => 'Zu diesem Mandanten wechseln';

  @override
  String get tenantJoinSwitch => 'Beitreten und wechseln';

  @override
  String tenantJoinBody(String name) {
    return 'Sie sind nicht Mitglied von $name. Als globaler Administrator können Sie sich als Administrator hinzufügen und wechseln. Die Änderung steht im Protokoll Ihres Kontos.';
  }

  @override
  String get tenantJoinConfirm => 'Als Administrator beitreten';

  @override
  String get tenantSwitchPinned =>
      'Diese Verbindung erreicht nur einen Mandanten. Melden Sie sich mit einer wechselbaren Verbindung an, um zwischen Mandanten zu wechseln.';

  @override
  String get tenantUsersTitle => 'Benutzer';

  @override
  String get tenantDomainsEmpty => 'Keine Domain führt zu diesem Mandanten.';

  @override
  String get domainsTitle => 'Domains';

  @override
  String get domainsSubtitle => 'Hostnamen, die diesen Mandanten öffnen';

  @override
  String get domainsBody =>
      'Eine Anfrage an einen dieser Hostnamen erreicht diesen Mandanten, ohne ihn zu nennen.';

  @override
  String get domainsEmpty => 'Noch keine Domains.';

  @override
  String get domainsEmptyBody =>
      'Ordnen Sie einen Hostnamen zu, damit man diesen Mandanten unter einer eigenen Adresse erreicht.';

  @override
  String get domainAdd => 'Domain hinzufügen';

  @override
  String get domainAddSubmit => 'Domain hinzufügen';

  @override
  String get domainAdded => 'Domain hinzugefügt.';

  @override
  String get domainHostname => 'Hostname';

  @override
  String get domainHostnameHelp =>
      'Wird kleingeschrieben; ein Port oder Punkt am Ende fällt weg.';

  @override
  String get domainCertMode => 'Zertifikat';

  @override
  String get domainCertNone => 'Woanders terminiert';

  @override
  String get domainCertFile => 'Zertifikatsdatei';

  @override
  String get domainCertNoneHelp =>
      'Ein Proxy vor tix hält das Zertifikat, oder der Host ist reines HTTP.';

  @override
  String get domainCertFileHelp =>
      'tix liefert TLS selbst aus PEM-Dateien auf dem Server.';

  @override
  String get domainCertPath => 'Pfad zum Zertifikat auf dem Server';

  @override
  String get domainKeyPath => 'Pfad zum privaten Schlüssel auf dem Server';

  @override
  String get domainVerified => 'Bestätigt';

  @override
  String get domainShared => 'Geteilt';

  @override
  String get domainSharedInfo =>
      'Ein geteilter Hostname bedient auch den Mandanten, den die Anmeldedaten oder der Header X-Tix-Tenant nennen, wie ein Host ohne Domain. Nur ein globaler Administrator stellt das ein.';

  @override
  String get domainRemove => 'Domain entfernen';

  @override
  String domainRemoveBody(String hostname) {
    return 'Anfragen an $hostname erreichen diesen Mandanten nicht mehr. Wer diese Adresse nutzt, braucht eine andere.';
  }

  @override
  String get domainRemoved => 'Domain entfernt.';

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
  String get serverHealth => 'Zustand';

  @override
  String get serverAddress => 'Adresse';

  @override
  String get serverId => 'Serverprozess';

  @override
  String get serverCountTenant => 'Aktive Verbindungen in diesem Mandanten';

  @override
  String get serverCountEvents => 'Live-Aktualisierungsströme';

  @override
  String get serverCountSsh => 'SSH-Sitzungen';

  @override
  String get serverCountProcess => 'Verbindungen auf diesem Server';

  @override
  String get serverCountProcessInfo =>
      'Alle Verbindungen dieses Serverprozesses über alle Mandanten. Das ist Kapazität, kein Verzeichnis, daher wird niemand genannt.';

  @override
  String get connectionsTitle => 'Aktive Verbindungen';

  @override
  String get connectionsInfo =>
      'Die Live-Aktualisierungsströme und SSH-Sitzungen dieses Mandanten, die dieser Serverprozess hält. Beenden schließt sie; der Client kann sich neu verbinden.';

  @override
  String get connectionsEmpty => 'Keine aktiven Verbindungen.';

  @override
  String get connectionEvents => 'Live-Aktualisierungen';

  @override
  String get connectionSsh => 'SSH';

  @override
  String connectionSince(String date) {
    return 'seit $date';
  }

  @override
  String get connectionEnd => 'Beenden';

  @override
  String get connectionEndBody =>
      'Die Verbindung wird sofort geschlossen. Ein laufender Client kann sich neu verbinden; widerrufen Sie seinen Token oder Schlüssel, um ihn auszusperren.';

  @override
  String get connectionEnded => 'Verbindung beendet.';

  @override
  String get globalAdminsTitle => 'Globale Administratoren';

  @override
  String get globalAdminsSubtitle =>
      'Personen, die alle Mandanten auf diesem Server verwalten';

  @override
  String get globalAdminsEmpty => 'Keine globalen Administratoren.';

  @override
  String get globalAdminGrant => 'Zum globalen Administrator machen';

  @override
  String get globalAdminGrantSubmit => 'Ernennen';

  @override
  String get globalAdminGrantHelp =>
      'Das Konto mit dieser E-Mail kann dann Mandanten anlegen und jeden davon verwalten.';

  @override
  String get globalAdminGranted => 'Globaler Administrator ernannt.';

  @override
  String get globalAdminRevoke => 'Entziehen';

  @override
  String globalAdminRevokeBody(String email) {
    return '$email verwaltet ab sofort nicht mehr alle Mandanten. Die Mitgliedschaften bleiben bestehen.';
  }

  @override
  String get globalAdminRevoked => 'Globale Administration entzogen.';

  @override
  String get globalAdminBadge => 'Globaler Administrator';

  @override
  String get adminRoleAdmin => 'Administrator';

  @override
  String get adminRoleMember => 'Mitglied';

  @override
  String get adminRoleViewer => 'Betrachter';

  @override
  String get adminRoleNone => 'Keine Rolle';

  @override
  String get adminUsersEmpty => 'Keine Benutzer in diesem Mandanten.';

  @override
  String get adminUsersEmptyBody =>
      'Legen Sie einen Benutzer an oder fügen Sie ein bestehendes Konto hinzu.';

  @override
  String get adminUserCreate => 'Neuer Benutzer';

  @override
  String get adminUserCreateSubmit => 'Benutzer anlegen';

  @override
  String get adminUserActions => 'Aktionen für den Benutzer';

  @override
  String get adminUserEdit => 'Bearbeiten';

  @override
  String adminUserEditTitle(String email) {
    return '$email bearbeiten';
  }

  @override
  String get adminUserDelete => 'Benutzer löschen';

  @override
  String adminUserDeleteBody(String email) {
    return '$email verliert diesen Mandanten: Die Mitgliedschaft wird entzogen, Sitzungen und Tokens hier enden. Das Konto bleibt für andere Mandanten bestehen.';
  }

  @override
  String get adminUserClearTotp => 'Zweiten Faktor zurücksetzen';

  @override
  String get adminUserClearTotpConfirm => 'Zurücksetzen';

  @override
  String adminUserClearTotpBody(String email) {
    return '$email meldet sich nur mit dem Passwort an, bis wieder ein zweiter Faktor eingerichtet ist. Tun Sie das nur, wenn App und Wiederherstellungscodes verloren sind.';
  }

  @override
  String get adminUserEmail => 'E-Mail';

  @override
  String get adminUserHandle => 'Kürzel';

  @override
  String get adminUserHandleHelp =>
      'Der Kurzname in diesem Mandanten. Leer übernimmt den Teil der E-Mail vor dem @.';

  @override
  String get adminUserDisplayName => 'Anzeigename';

  @override
  String get adminUserPassword => 'Passwort';

  @override
  String get adminUserPasswordHelp =>
      'Mindestens 12 Zeichen. Leer lassen für jemanden, der sich anders anmeldet oder später eingeladen wird.';

  @override
  String get adminUserNewPassword => 'Neues Passwort';

  @override
  String get adminUserNewPasswordHelp =>
      'Leer lassen, um das aktuelle zu behalten.';

  @override
  String get adminUserRole => 'Rolle';

  @override
  String get adminUserDisabled => 'Deaktiviert';

  @override
  String get adminUserDisabledSwitch => 'Deaktiviert';

  @override
  String get adminUserDisabledHelp =>
      'Ein deaktivierter Benutzer kann sich nicht anmelden; Sitzungen und Tokens enden sofort.';

  @override
  String get adminUserMustChangePassword => 'Muss das Passwort ändern';

  @override
  String get adminUserMustChangeSwitch =>
      'Bei der nächsten Anmeldung ein neues Passwort wählen';

  @override
  String get adminUserTotp => 'Zweiter Faktor';

  @override
  String get adminMemberAdd => 'Bestehendes Konto hinzufügen';

  @override
  String get adminMemberAddSubmit => 'Zum Mandanten hinzufügen';

  @override
  String get adminMemberAddHelp =>
      'Die Person behält Passwort und zweiten Faktor und muss nichts bestätigen.';

  @override
  String get adminAccountLogTitle => 'Kontoprotokoll';

  @override
  String get adminAccountLogEmpty =>
      'Für dieses Konto ist nichts protokolliert.';

  @override
  String get adminAccountLogEmptyBody =>
      'Änderungen an Passwort, zweitem Faktor, Status und Mitgliedschaften erscheinen hier.';

  @override
  String adminAccountLogBy(String who) {
    return 'von $who';
  }

  @override
  String adminAccountLogVia(String channel) {
    return 'über $channel';
  }

  @override
  String get adminAccountLogSystem => 'dem System';

  @override
  String get taskReclaim => 'Reservierung zwangsweise lösen';

  @override
  String get taskReclaimSubmit => 'Reservierung lösen';

  @override
  String get taskReclaimBody =>
      'Beendet die Reservierung, die ein anderer Akteur auf diese Aufgabe hält, wenn dessen Agent ausgefallen ist. Seine nächste Verlängerung wird abgelehnt.';

  @override
  String get taskReclaimReason => 'Grund (optional)';

  @override
  String get taskReclaimReasonHelp =>
      'Wird im Verlauf der Aufgabe festgehalten.';

  @override
  String taskReclaimed(String ref) {
    return 'Reservierung von $ref gelöst.';
  }

  @override
  String get totpWrongCode =>
      'Der Code stimmt nicht. Prüfen Sie die Uhrzeit dieses Geräts und versuchen Sie den nächsten.';

  @override
  String get tenantThemeSampleStatus => 'In Arbeit';

  @override
  String get tenantSettingsSubtitle =>
      'Name, Design, zweiter Faktor, Reservierungen und Papierkorb';

  @override
  String get serverSubtitle => 'Version und aktive Verbindungen';

  @override
  String get webhooksTitle => 'Webhooks';

  @override
  String get webhooksSubtitle =>
      'tix sendet jedes Ereignis an diese Adressen, signiert mit dem Geheimnis des Endpunkts.';

  @override
  String get webhookNew => 'Neuer Endpunkt';

  @override
  String get webhookEdit => 'Endpunkt bearbeiten';

  @override
  String get webhookEndpoints => 'Endpunkte';

  @override
  String get webhookEndpointsInfo =>
      'Ein Endpunkt erhält jedes Ereignis oder nur die Typen, die er nennt. Ein inaktiver erhält nichts, bis er wieder eingeschaltet wird.';

  @override
  String get webhooksEmpty => 'Noch keine Webhook-Endpunkte.';

  @override
  String get webhooksEmptyBody =>
      'Fügen Sie eine https-Adresse hinzu, und tix sendet Ereignisse dorthin, sobald sie geschehen.';

  @override
  String get webhookEveryEvent => 'Jedes Ereignis';

  @override
  String get webhookActive => 'Aktiv';

  @override
  String get webhookInactive => 'Inaktiv';

  @override
  String get webhookActiveHelp => 'Ein inaktiver Endpunkt erhält nichts.';

  @override
  String get webhookShowDeliveries => 'Zustellungen anzeigen';

  @override
  String get webhookDelete => 'Endpunkt löschen';

  @override
  String get webhookDeleteTitle => 'Diesen Endpunkt löschen?';

  @override
  String webhookDeleteBody(String url) {
    return '$url erhält keine Ereignisse mehr, und ausstehende Zustellungen werden verworfen. Das lässt sich nicht rückgängig machen.';
  }

  @override
  String get webhookDeleted => 'Endpunkt gelöscht.';

  @override
  String get webhookUrl => 'Adresse';

  @override
  String get webhookUrlHelp =>
      'Muss https verwenden, außer bei einer Loopback-Adresse.';

  @override
  String get webhookEvents => 'Ereignistypen';

  @override
  String get webhookEventsHelp =>
      'Durch Kommas getrennt; ein Typ darf auf * enden. Leer sendet jedes Ereignis.';

  @override
  String get webhookSecret => 'Signaturgeheimnis';

  @override
  String get webhookSecretNewHelp =>
      'Leer lassen, dann erzeugt tix eines und es wird hier einmal angezeigt.';

  @override
  String get webhookSecretKeepHelp =>
      'Leer lassen, um das aktuelle Geheimnis zu behalten.';

  @override
  String get webhookSave => 'Endpunkt speichern';

  @override
  String get webhookSaved => 'Endpunkt gespeichert.';

  @override
  String get webhookSecretHeading =>
      'Kopieren Sie dieses Signaturgeheimnis jetzt';

  @override
  String get webhookSecretNote =>
      'Es wird nur einmal angezeigt und lässt sich nicht erneut lesen. Hinterlegen Sie es beim Empfänger; geht es verloren, speichern Sie den Endpunkt erneut mit einem eigenen Geheimnis.';

  @override
  String get webhookSecretDone => 'Ich habe es kopiert';

  @override
  String get webhookDeliveries => 'Zustellungen';

  @override
  String get webhookDeliveriesAll => 'Alle Endpunkte, neueste zuerst.';

  @override
  String webhookDeliveriesFor(String url) {
    return 'Für $url, neueste zuerst.';
  }

  @override
  String get webhookDeliveriesShowAll => 'Alle Endpunkte anzeigen';

  @override
  String get webhookDeliveriesEmpty => 'Keine Zustellungen.';

  @override
  String get webhookDeliveriesEmptyBody =>
      'Zustellungen erscheinen hier, sobald Ereignisse gesendet werden.';

  @override
  String get webhookStatusAny => 'Alle';

  @override
  String get webhookStatusPending => 'Ausstehend';

  @override
  String get webhookStatusDelivered => 'Zugestellt';

  @override
  String get webhookStatusFailed => 'Fehlgeschlagen';

  @override
  String get webhookStatusUnknown => 'Unbekannt';

  @override
  String webhookEvent(int seq) {
    return 'Ereignis $seq';
  }

  @override
  String webhookAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Versuche',
      one: '1 Versuch',
    );
    return '$_temp0';
  }

  @override
  String webhookHttpStatus(int code) {
    return 'HTTP $code';
  }

  @override
  String webhookNextAttempt(String when) {
    return 'nächster Versuch $when';
  }

  @override
  String get webhookRedeliver => 'Erneut zustellen';

  @override
  String get webhookRedelivered => 'Für einen weiteren Versuch eingereiht.';

  @override
  String get webhookPing => 'Test senden';

  @override
  String get webhookPingTitle => 'Testereignis';

  @override
  String webhookPingSent(String url) {
    return 'tix hat ein signiertes webhook.ping-Ereignis an $url gesendet.';
  }

  @override
  String get webhookPingPending =>
      'Noch nicht versucht. Das Zustellprotokoll zeigt das Ergebnis, sobald tix es versucht hat.';

  @override
  String get syncTitle => 'Externe Synchronisierung';

  @override
  String get syncSubtitle =>
      'Arbeit aus Jira, OpenProject oder einer Datei importieren. Die Läufe finden auf dem Server statt.';

  @override
  String get syncNew => 'Neue Quelle';

  @override
  String get syncSources => 'Quellen';

  @override
  String get syncSourcesInfo =>
      'Jede Quelle merkt sich einen Cursor, sodass ein Lauf nur importiert, was sich seit dem letzten geändert hat. Ein vollständiger Lauf beginnt von vorn.';

  @override
  String get syncEmpty => 'Noch keine Synchronisierungsquellen.';

  @override
  String get syncEmptyBody =>
      'Fügen Sie eine Quelle hinzu, um Aufgaben aus einem anderen Tracker zu importieren.';

  @override
  String get syncStatusOk => 'Letzter Lauf erfolgreich';

  @override
  String get syncStatusFailed => 'Letzter Lauf fehlgeschlagen';

  @override
  String get syncStatusRunning => 'Läuft';

  @override
  String get syncStatusNever => 'Nie gelaufen';

  @override
  String get syncNeverRun => 'Noch nicht gelaufen.';

  @override
  String syncLastRun(String when) {
    return 'Letzter Lauf $when.';
  }

  @override
  String syncStoredCredentials(String names) {
    return 'Gespeicherte Zugangsdaten: $names';
  }

  @override
  String get syncMissing =>
      'Ein Lauf wird abgelehnt, bis der Server Folgendes hat:';

  @override
  String get syncReady => 'Bereit zum Ausführen.';

  @override
  String get syncRunNow => 'Jetzt ausführen';

  @override
  String get syncPreview => 'Vorschau';

  @override
  String get syncEdit => 'Bearbeiten';

  @override
  String get syncDelete => 'Quelle löschen';

  @override
  String get syncDeleteTitle => 'Diese Quelle löschen?';

  @override
  String syncDeleteBody(String name) {
    return '$name und der bisherige Lesestand werden entfernt. Bereits importierte Aufgaben bleiben. Das lässt sich nicht rückgängig machen.';
  }

  @override
  String get syncDeleted => 'Quelle gelöscht.';

  @override
  String syncSaved(String name) {
    return '$name gespeichert.';
  }

  @override
  String syncRunTitle(String name) {
    return '$name ausführen';
  }

  @override
  String get syncRunBody =>
      'Die Vorschau zählt, was ein Lauf tun würde, und ändert nichts.';

  @override
  String get syncFull => 'Vollständiger Lauf';

  @override
  String get syncFullHelp =>
      'Alles von vorn lesen, statt dort weiterzumachen, wo der letzte Lauf aufgehört hat.';

  @override
  String get syncPreviewTitle => 'Vorschau';

  @override
  String get syncDoneTitle => 'Lauf abgeschlossen';

  @override
  String get syncPreviewNote => 'Es wurde nichts geändert.';

  @override
  String syncCounts(int created, int updated, int skipped, int deleted) {
    return '$created angelegt · $updated aktualisiert · $skipped übersprungen · $deleted gelöscht';
  }

  @override
  String get syncUnmatched => 'Personen ohne Entsprechung hier';

  @override
  String get syncWarnings => 'Warnungen';

  @override
  String syncWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Warnungen',
      one: '1 Warnung',
    );
    return '$_temp0';
  }

  @override
  String get syncRuns => 'Laufverlauf';

  @override
  String get syncRunsEmpty => 'Keine abgeschlossenen Läufe.';

  @override
  String get syncRunsEmptyBody =>
      'Ein fehlgeschlagener Lauf steht nicht hier; die Quelle zeigt ihn an.';

  @override
  String syncEditTitle(String name) {
    return '$name bearbeiten';
  }

  @override
  String get syncFormIntro =>
      'Einstellungen und Zuordnung werden auf dem Server gespeichert. Zugangsdaten werden dort versiegelt und nie wieder angezeigt.';

  @override
  String get syncName => 'Name';

  @override
  String get syncNameHelp => 'Benennt die Quelle innerhalb ihres Systems.';

  @override
  String get syncMapping => 'Zuordnungsdokument (YAML)';

  @override
  String get syncMappingHelp =>
      'Bleibt es leer, wird das gespeicherte Dokument behalten.';

  @override
  String get syncMappingPath => 'Zuordnungsdatei auf dem Server';

  @override
  String get syncMappingPathHelp =>
      'Wird nur aus dem Verzeichnis dieses Mandanten unter sync.file_root des Servers gelesen.';

  @override
  String get syncCredentials => 'Zugangsdaten';

  @override
  String get syncCredentialsHelp =>
      'Nur schreibbar. Jedes Feld ersetzt den gespeicherten Satz; alle leer lassen, um ihn zu behalten.';

  @override
  String get syncToken => 'Token';

  @override
  String get syncUser => 'Benutzer';

  @override
  String get syncPassword => 'Passwort oder API-Schlüssel';

  @override
  String get syncClearCredentials => 'Gespeicherte Zugangsdaten entfernen';

  @override
  String get syncCheck => 'Prüfen';

  @override
  String get syncSave => 'Quelle speichern';

  @override
  String syncMappingFrom(String origin) {
    return 'Zuordnung: $origin';
  }

  @override
  String syncCredentialsFrom(String origin) {
    return 'Zugangsdaten: $origin';
  }

  @override
  String get syncFromStored => 'in der Quelle gespeichert';

  @override
  String get syncFromEnv => 'aus der Umgebung';

  @override
  String get syncFromMappingPath => 'Datei auf dem Server';

  @override
  String get syncFromNone => 'nicht nötig';

  @override
  String get syncFromMissing => 'fehlt';

  @override
  String syncSummaryProject(String project) {
    return 'Landet im Projekt $project';
  }

  @override
  String syncSummaryIdentity(String field) {
    return 'Zugeordnet über $field';
  }

  @override
  String get retentionTitle => 'Aufbewahrung';

  @override
  String get retentionSubtitle =>
      'Wie lange dieser Mandant seine Protokolle behält.';

  @override
  String get retentionWindows => 'Aufbewahren für';

  @override
  String get retentionWindowsHelp =>
      'In Tagen. Ältere Einträge werden beim Bereinigen entfernt.';

  @override
  String get retentionEvents => 'Ereignisse';

  @override
  String get retentionEventsHelp =>
      'Der Live-Aktualisierungsstrom. Standard 30 Tage.';

  @override
  String get retentionAudit => 'Audit-Einträge';

  @override
  String get retentionAuditHelp => 'Wer was geändert hat. Standard 365 Tage.';

  @override
  String get retentionDeliveries => 'Webhook-Zustellungen';

  @override
  String get retentionDeliveriesHelp =>
      'Das Zustellprotokoll. Standard 30 Tage.';

  @override
  String get retentionSave => 'Aufbewahrung speichern';

  @override
  String get retentionSaved => 'Aufbewahrung gespeichert.';

  @override
  String get retentionPruneSection => 'Jetzt bereinigen';

  @override
  String get retentionPruneHelp =>
      'Entfernt sofort alles, was seine Frist überschritten hat, statt auf den Server zu warten.';

  @override
  String get retentionPreview => 'Vorschau';

  @override
  String get retentionPrune => 'Bereinigen';

  @override
  String get retentionPruneTitle => 'Alte Einträge bereinigen?';

  @override
  String get retentionPruneBody =>
      'Ereignisse, Audit-Einträge und Webhook-Zustellungen jenseits ihrer Frist werden endgültig gelöscht.';

  @override
  String get retentionPruned => 'Bereinigt.';

  @override
  String retentionWouldPrune(int events, int audit, int deliveries) {
    return 'Würde $events Ereignisse, $audit Audit-Einträge und $deliveries Zustellungen entfernen.';
  }

  @override
  String retentionDidPrune(int events, int audit, int deliveries) {
    return '$events Ereignisse, $audit Audit-Einträge und $deliveries Zustellungen entfernt.';
  }

  @override
  String retentionKeptForSubscribers(int count) {
    return '$count Ereignisse jenseits ihrer Frist bleiben, bis ein Abonnent sie gelesen hat.';
  }

  @override
  String get housekeepingTitle => 'Aufräumen';

  @override
  String get housekeepingSubtitle =>
      'Räumt erledigte Arbeit aus den Listen und leert den Papierkorb.';

  @override
  String get housekeepingPaused =>
      'Das Aufräumen pausiert, solange der Papierkorb aus ist: Keine Regel läuft.';

  @override
  String get housekeepingRules => 'Regeln';

  @override
  String get housekeepingRulesHelp =>
      'Eine Anzahl Tage oder aus. Projekte können sie überschreiben.';

  @override
  String get housekeepingDone =>
      'Erledigte Aufgaben kommen in den Papierkorb nach';

  @override
  String get housekeepingDoneHelp => 'Tage seit dem Erledigen.';

  @override
  String get housekeepingCancelled =>
      'Abgebrochene Aufgaben kommen in den Papierkorb nach';

  @override
  String get housekeepingCancelledHelp => 'Tage seit dem Abbrechen.';

  @override
  String get housekeepingTrash =>
      'Der Papierkorb löscht Aufgaben endgültig nach';

  @override
  String get housekeepingTrashHelp => 'Tage im Papierkorb.';

  @override
  String housekeepingPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben jetzt fällig.',
      one: '1 Aufgabe jetzt fällig.',
      zero: 'Derzeit nichts fällig.',
    );
    return '$_temp0';
  }

  @override
  String get housekeepingSave => 'Regeln speichern';

  @override
  String get housekeepingSaved => 'Regeln gespeichert.';

  @override
  String get housekeepingRunSection => 'Jetzt ausführen';

  @override
  String get housekeepingRunHelp =>
      'Wendet die Regeln einmal in Stapeln an, statt auf den nächsten Durchlauf des Servers zu warten.';

  @override
  String get housekeepingPreview => 'Vorschau';

  @override
  String get housekeepingRun => 'Aufräumen ausführen';

  @override
  String get housekeepingRunTitle => 'Jetzt aufräumen?';

  @override
  String get housekeepingRunBody =>
      'Erledigte Aufgaben jenseits ihrer Regel kommen in den Papierkorb, und Aufgaben jenseits der Papierkorbregel werden endgültig gelöscht.';

  @override
  String housekeepingWould(int done, int cancelled, int trash) {
    return 'Würde $done erledigte und $cancelled abgebrochene Aufgaben in den Papierkorb verschieben und $trash endgültig löschen.';
  }

  @override
  String housekeepingDid(int done, int cancelled, int trash) {
    return '$done erledigte und $cancelled abgebrochene Aufgaben in den Papierkorb verschoben, $trash endgültig gelöscht.';
  }

  @override
  String get trashTitle => 'Papierkorb';

  @override
  String get trashSubtitle =>
      'Gelöschte Aufgaben, bis das Aufräumen sie entfernt.';

  @override
  String get trashExplain =>
      'Wiederherstellen legt eine Aufgabe dorthin zurück, wo sie war. Endgültig löschen entfernt sie samt ihren Unteraufgaben im Papierkorb dauerhaft, wie es die Papierkorbregel des Aufräumens bei Ablauf tut.';

  @override
  String get trashEmpty => 'Der Papierkorb ist leer.';

  @override
  String get trashEmptyBody =>
      'Gelöschte Aufgaben warten hier und lassen sich wiederherstellen.';

  @override
  String get trashRestore => 'Wiederherstellen';

  @override
  String trashRestored(String ref) {
    return '$ref wiederhergestellt.';
  }

  @override
  String trashDeletedAt(String when) {
    return 'gelöscht $when';
  }

  @override
  String get trashPurge => 'Endgültig löschen';

  @override
  String get trashPurgeTitle => 'Endgültig löschen?';

  @override
  String trashPurgeBody(String ref, String title) {
    return '$ref „$title“ und seine Unteraufgaben im Papierkorb werden endgültig gelöscht. Das lässt sich nicht rückgängig machen.';
  }

  @override
  String trashPurged(String ref) {
    return '$ref endgültig gelöscht.';
  }

  @override
  String get auditTitle => 'Audit-Protokoll';

  @override
  String get auditSubtitle =>
      'Jede Änderung in diesem Mandanten, neueste zuerst.';

  @override
  String get auditSearch => 'Aktionen, Datensätze und Werte durchsuchen';

  @override
  String get auditVia => 'Kanal';

  @override
  String get auditSource => 'Oberfläche';

  @override
  String get auditMoreFilters => 'Weitere Filter';

  @override
  String auditMoreFiltersCount(int count) {
    return 'Weitere Filter ($count)';
  }

  @override
  String get auditClear => 'Filter löschen';

  @override
  String get auditFilters => 'Audit-Protokoll filtern';

  @override
  String get auditApply => 'Anwenden';

  @override
  String get auditActor => 'Akteur';

  @override
  String get auditActorHelp => 'Die ID des Akteurs.';

  @override
  String get auditAction => 'Aktion';

  @override
  String get auditToken => 'API-Token';

  @override
  String get auditTokenHelp => 'Der Name des Tokens.';

  @override
  String auditSince(String day) {
    return 'Ab $day';
  }

  @override
  String auditUntil(String day) {
    return 'Bis $day';
  }

  @override
  String get auditAnyTime => 'jederzeit';

  @override
  String get auditEmpty => 'Noch nichts protokolliert.';

  @override
  String get auditEmptyBody =>
      'Änderungen erscheinen hier, sobald Personen und Agenten sie vornehmen.';

  @override
  String get auditNoMatch => 'Keine passenden Einträge.';

  @override
  String get auditNoMatchBody => 'Lockern oder löschen Sie die Filter.';

  @override
  String get auditPick => 'Wählen Sie einen Eintrag';

  @override
  String get auditPickBody => 'Die Details erscheinen hier.';

  @override
  String get auditSeq => 'Eintrag';

  @override
  String get auditWhen => 'Wann';

  @override
  String get auditSystem => 'das System';

  @override
  String get auditSubject => 'Datensatz';

  @override
  String get auditTokenId => 'Token-ID';

  @override
  String get auditSession => 'Sitzung';

  @override
  String get auditKey => 'SSH-Schlüssel';

  @override
  String get auditClient => 'Client-Adresse';

  @override
  String get auditOrigin => 'Herkunft';

  @override
  String get auditHost => 'Host';

  @override
  String get auditOsUser => 'Systembenutzer';

  @override
  String get auditJob => 'Hintergrundjob';

  @override
  String get auditUserAgent => 'User-Agent';

  @override
  String get auditBefore => 'Vorher';

  @override
  String get auditAfter => 'Nachher';

  @override
  String get timeJustNow => 'gerade eben';

  @override
  String get timeInAMoment => 'gleich';

  @override
  String timeAgoMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'vor $n Minuten',
      one: 'vor 1 Minute',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'vor $n Stunden',
      one: 'vor 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'vor $n Tagen',
      one: 'vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'vor $n Monaten',
      one: 'vor 1 Monat',
    );
    return '$_temp0';
  }

  @override
  String timeAgoYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'vor $n Jahren',
      one: 'vor 1 Jahr',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'in $n Minuten',
      one: 'in 1 Minute',
    );
    return '$_temp0';
  }

  @override
  String timeInHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'in $n Stunden',
      one: 'in 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String timeInDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'in $n Tagen',
      one: 'in 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String timeInMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'in $n Monaten',
      one: 'in 1 Monat',
    );
    return '$_temp0';
  }

  @override
  String timeInYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'in $n Jahren',
      one: 'in 1 Jahr',
    );
    return '$_temp0';
  }

  @override
  String get timeFormatIso => 'ISO';

  @override
  String get timeFormatRfc3339 => 'RFC 3339';

  @override
  String get timeFormatShort => 'Kurz';

  @override
  String get timeFormatLong => 'Lang';

  @override
  String get timeFormatDotted => 'Mit Punkten';

  @override
  String get timeFormatDayfirst => 'Tag zuerst';

  @override
  String get timeFormatUs => 'USA';

  @override
  String get timeFormatRelative => 'Relativ';

  @override
  String get settingsSearchHint => 'Einstellungen durchsuchen';

  @override
  String settingsNoMatch(String query) {
    return 'Keine Einstellung passt zu „$query“';
  }

  @override
  String get settingsNoMatchBody =>
      'Versuchen Sie ein anderes Wort oder leeren Sie die Suche.';

  @override
  String get settingsScopeDevice => 'Auf diesem Gerät';

  @override
  String get settingsScopeAccount => 'Mit Ihrem Konto synchronisiert';

  @override
  String get settingsScopeTenant => 'Ganzer Mandant';

  @override
  String get settingsGroupDevice => 'Dieses Gerät';

  @override
  String get settingsGroupDeviceHelp =>
      'Nur auf diesem Gerät gespeichert. Ihre anderen Geräte und das Web haben eigene.';

  @override
  String settingsGroupAccount(String tenant) {
    return 'Ihr Konto in $tenant';
  }

  @override
  String get settingsGroupAccountHelp =>
      'Vom Server mit Ihrem Konto gespeichert, sie folgen Ihnen also auf jedes Gerät, ins Web und in die Kommandozeile.';

  @override
  String get settingsGroupTenant => 'Dieser Mandant';

  @override
  String settingsGroupTenantHelp(String tenant) {
    return 'Einstellungen für alle in $tenant. Nur Administratoren sehen sie.';
  }

  @override
  String get settingsReduceMotion => 'Bewegung reduzieren';

  @override
  String get settingsReduceMotionHelp =>
      'Die App bleibt ruhig, auch wenn das System Animationen erlaubt.';

  @override
  String get settingsHaptics => 'Haptisches Feedback';

  @override
  String get settingsHapticsHelp =>
      'Ein kurzes Vibrieren bei Wischgesten, erledigten Aufgaben und Ablehnungen.';

  @override
  String get settingsLanguageHelp =>
      'tix speichert keine Sprache mit Ihrem Konto, daher wählt jedes Gerät und jeder Browser seine eigene.';

  @override
  String get settingsStartTitle => 'Startbildschirm';

  @override
  String get settingsStartHelp =>
      'Wo sich die App beim Start oder nach der Anmeldung öffnet.';

  @override
  String get settingsDeviceNotifTitle => 'Benachrichtigungen auf diesem Gerät';

  @override
  String get settingsDeviceNotifSubtitle =>
      'Ob dieses Gerät Sie benachrichtigt und bei welchen Arten';

  @override
  String get settingsProfileTitle => 'Profil';

  @override
  String get settingsDatesTitle => 'Datum und Uhrzeit';

  @override
  String get settingsDatesHelp =>
      'Mit Ihrem Konto gespeichert, sodass jedes Gerät, jeder Browser und jedes Terminal Daten so zeigt. „Erben“ folgt der Vorgabe des Mandanten, die der des Servers folgt.';

  @override
  String get settingsDateFormat => 'Datumsformat';

  @override
  String get settingsDateFormatHelp =>
      'Wie jeder Zeitstempel in der App geschrieben wird. Im Web liest tix eingegebene Daten genauso.';

  @override
  String get settingsTimeZone => 'Zeitzone';

  @override
  String get settingsTimeZoneHelp =>
      'Die Zone, in der jede Uhrzeit angezeigt wird und in der der Tag für Fälligkeiten endet.';

  @override
  String get settingsInherit => 'Erben';

  @override
  String settingsInheritValue(String value) {
    return 'Erben: $value';
  }

  @override
  String settingsInUse(String value, String source) {
    return 'Aktiv: $value, aus $source';
  }

  @override
  String get settingsSourceUser => 'Ihrer Wahl';

  @override
  String get settingsSourceTenant => 'der Mandantenvorgabe';

  @override
  String get settingsSourceGlobal => 'der Servervorgabe';

  @override
  String get settingsDeviceFormat => 'das Format dieses Geräts';

  @override
  String settingsDeviceZone(String zone) {
    return 'die Zone dieses Geräts ($zone)';
  }

  @override
  String get settingsDatesNotPersonal =>
      'Diese Anmeldung gehört keiner Person, sie nutzt daher die Vorgaben des Mandanten und kann keine eigenen haben.';

  @override
  String get settingsDatesLoading =>
      'Ihre Datumseinstellungen werden vom Server gelesen…';

  @override
  String get settingsDatesUnsupported =>
      'Diese tix-Version speichert keine Datumseinstellungen, daher folgen Daten diesem Gerät. Ein neuerer tix-Server bringt sie mit.';

  @override
  String get settingsDatesFailed =>
      'Der Server hat nicht geantwortet, daher folgen Daten vorerst diesem Gerät.';

  @override
  String get settingsDatesSaved => 'Mit Ihrem Konto gespeichert';

  @override
  String get settingsZoneSearch => 'Zeitzonen durchsuchen';

  @override
  String get settingsZoneNone => 'Keine Zeitzone passt.';

  @override
  String get settingsInboxTitle => 'Posteingang und Kanäle';

  @override
  String get settingsInboxSubtitle =>
      'Was in Ihrem Posteingang landet, und Ihre persönlichen Kanäle';

  @override
  String get settingsFiltersTitle => 'Gespeicherte Filter';

  @override
  String get settingsFiltersSubtitle =>
      'Ihre Filter umbenennen, teilen oder löschen';

  @override
  String get settingsArrangementTitle => 'Board und Bahnen';

  @override
  String get settingsArrangementHelp =>
      'Die Gruppen, die Sie auf dem Board, in Bahnen und in Meine Arbeit ausgeblendet, markiert, eingeklappt oder verschoben haben.';

  @override
  String get settingsArrangementReset => 'Zurücksetzen';

  @override
  String get settingsArrangementResetTitle => 'Board und Bahnen zurücksetzen';

  @override
  String get settingsArrangementResetBody =>
      'Jede Gruppe auf dem Board, in Bahnen und in Meine Arbeit kehrt an ihren Standardplatz zurück, auf jedem Gerät und im Web. Das lässt sich nicht rückgängig machen.';

  @override
  String get settingsArrangementDone => 'Anordnung zurückgesetzt';

  @override
  String settingsTenantManage(String tenant) {
    return '$tenant verwalten';
  }

  @override
  String get settingsTenantManageSubtitle =>
      'Projekte, Workflows, Felder, Personen und die Einstellungen des Mandanten';

  @override
  String paletteSettingsItem(String name) {
    return 'Einstellungen: $name';
  }

  @override
  String get savedFiltersEmpty => 'Keine gespeicherten Filter';

  @override
  String get savedFiltersEmptyBody =>
      'Speichern Sie einen Filter in der Aufgabenliste, dann erscheint er hier, auf jedem Gerät.';

  @override
  String get savedFilterSharedBadge => 'Geteilt';

  @override
  String get savedFilterTheirs =>
      'Mit Ihnen geteilt; nur der Eigentümer und Administratoren können ihn ändern.';

  @override
  String durationDays(int n) {
    return '$n T.';
  }

  @override
  String durationHours(int n) {
    return '$n Std.';
  }

  @override
  String durationMinutes(int n) {
    return '$n Min.';
  }

  @override
  String durationSeconds(int n) {
    return '$n Sek.';
  }

  @override
  String get errorBadInviteLink =>
      'Das ist kein Einladungslink. Er sieht so aus: https://ihr-server/invite/tix_inv_…';

  @override
  String get methodInvite => 'Einladung';

  @override
  String get inviteLinkLabel => 'Einladungslink';

  @override
  String get inviteLinkHint => 'https://tix.example.com/invite/tix_inv_…';

  @override
  String get inviteLinkHelp =>
      'Fügen Sie den Link aus Ihrer Einladungs-E-Mail ein oder teilen Sie ihn aus einer anderen App mit tix. Der Server wird für Sie hinzugefügt.';

  @override
  String get invitePaste => 'Einladungslink einfügen';

  @override
  String get inviteCheck => 'Einladung prüfen';

  @override
  String inviteJoin(String tenant, String host) {
    return '$tenant auf $host beitreten';
  }

  @override
  String inviteJoinServer(String host) {
    return '$host beitreten';
  }

  @override
  String inviteAs(String email) {
    return 'als $email';
  }

  @override
  String inviteExpires(String when) {
    return 'Der Link gilt bis $when.';
  }

  @override
  String get inviteExistingAccount =>
      'Diese Adresse hat bereits ein tix-Konto. Geben Sie dessen Passwort ein, um anzunehmen; am Konto ändert sich nichts.';

  @override
  String get inviteDisplayName => 'Ihr Name';

  @override
  String get inviteNewPassword => 'Neues Passwort';

  @override
  String get inviteNewPasswordHelp =>
      'Mindestens 12 Zeichen. Damit melden Sie sich überall an, nicht nur hier.';

  @override
  String get inviteExistingPasswordHelp =>
      'Das Passwort, mit dem Sie sich bereits bei tix anmelden.';

  @override
  String get inviteCodeHelp =>
      'Ein Code aus Ihrer Authenticator-App, die dieses Konto bereits nutzt.';

  @override
  String get inviteAccept => 'Einladung annehmen';

  @override
  String get notifHideContent =>
      'Aufgabeninhalte in Benachrichtigungen ausblenden';

  @override
  String get notifHideContentHelp =>
      'Benachrichtigungen zeigen nur „Neu in Ihrem Posteingang“, für diesen Kontext.';

  @override
  String get notifPrivateTitle => 'Neu in Ihrem Posteingang';

  @override
  String get notifPrivateBody => 'Öffnen Sie tix, um es zu lesen.';

  @override
  String get taskDetailLease => 'Reservierungsdauer';

  @override
  String get taskDetailLeaseInfo =>
      'Wie lange die Reservierung eines Agenten für diese Aufgabe gilt, wenn er keine Dauer angibt, und wie lange eine Reservierung höchstens gelten darf. Aufgabe, Projekt, Workflow und Mandant können sie festlegen; die nächste Ebene gewinnt.';

  @override
  String taskDetailLeaseValue(String length, String source) {
    return '$length (Quelle: $source)';
  }

  @override
  String taskDetailLeaseMax(String length, String source) {
    return 'Höchstens $length (Quelle: $source)';
  }

  @override
  String get taskDetailLeaseClamped => 'Auf die Obergrenze gekürzt.';

  @override
  String get leaseSourceClaim => 'Reservierung';

  @override
  String get leaseSourceTask => 'Aufgabe';

  @override
  String get leaseSourceProject => 'Projekt';

  @override
  String get leaseSourceWorkflow => 'Workflow';

  @override
  String get leaseSourceTenant => 'Mandant';

  @override
  String get leaseSourceDeployment => 'Server';

  @override
  String get leaseSourceBuiltin => 'tix-Standard';

  @override
  String get statusTitle => 'Serverstatus';

  @override
  String get statusInstallation => 'Installation';

  @override
  String get statusVersion => 'Version';

  @override
  String get statusSchema => 'Schema';

  @override
  String get statusEngine => 'Datenbank';

  @override
  String get statusAnswering => 'Beantwortet von';

  @override
  String get statusObserved => 'Geprüft';

  @override
  String get statusServers => 'Serverprozesse';

  @override
  String get statusServersInfo =>
      'Jeder bei dieser Datenbank registrierte tix-Prozess. Wer drei Lebenszeichen verpasst, wird als verstummt angezeigt.';

  @override
  String get statusNoServers =>
      'Kein Prozess registriert. Der antwortende läuft womöglich ohne Registry.';

  @override
  String get statusAttached => 'Sendet Lebenszeichen';

  @override
  String statusDetached(String when) {
    return 'Still seit $when';
  }

  @override
  String statusUptime(String length) {
    return 'läuft seit $length';
  }

  @override
  String statusConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Verbindungen',
      one: '1 Verbindung',
    );
    return '$_temp0';
  }

  @override
  String get statusWork => 'Dieser Mandant';

  @override
  String get statusProjects => 'Projekte';

  @override
  String get statusTasks => 'Aufgaben';

  @override
  String get statusClaimed => 'Reserviert';

  @override
  String get statusUnswept => 'Abgelaufene, nicht bereinigte Reservierungen';

  @override
  String get statusWebhooksPending => 'Wartende Webhook-Zustellungen';

  @override
  String get statusWebhooksFailed => 'Fehlgeschlagene Webhook-Zustellungen';

  @override
  String get statusSecondFactor => 'Zweiter Faktor';

  @override
  String get statusKey => 'Versiegelungsschlüssel gesetzt';

  @override
  String get statusRequireWeb => 'Im Browser erforderlich';

  @override
  String get statusRequireCli =>
      'In der Kommandozeile und in Apps erforderlich';

  @override
  String get statusRequireSsh => 'Über SSH erforderlich';

  @override
  String get statusAdmins => 'Admins mit zweitem Faktor';

  @override
  String statusAdminsEnrolled(int enrolled, int total) {
    return '$enrolled von $total';
  }

  @override
  String get statusUnrecoverable =>
      'Einige zweite Faktoren sind unlesbar: Der Versiegelungsschlüssel fehlt. Diese Personen müssen ihren löschen lassen und sich neu registrieren.';

  @override
  String get statusYes => 'Ja';

  @override
  String get statusNo => 'Nein';

  @override
  String get bundlesTitle => 'Pakete';

  @override
  String get bundleExportTitle => 'Paket exportieren';

  @override
  String get bundleExportSubtitle =>
      'Wiederverwendbare Einrichtung als eine Datei, für einen anderen Mandanten oder Server';

  @override
  String get bundleExportInfo =>
      'Ein Paket enthält Workflows, Felddefinitionen, Tags, Projekte als Vorlagen und Webhook-Endpunkte, nie deren Aufgaben. Webhook-Geheimnisse sind nie enthalten.';

  @override
  String get bundleKindWorkflow => 'Workflows';

  @override
  String get bundleKindField => 'Eigene Felder';

  @override
  String get bundleKindTag => 'Tags';

  @override
  String get bundleKindProject => 'Projektvorlagen';

  @override
  String get bundleKindWebhook => 'Webhooks';

  @override
  String get bundleKindsAll =>
      'Nichts ausgewählt: Das Paket enthält alle Arten.';

  @override
  String get bundleKindsSome => 'Nur die ausgewählten Arten kommen hinein.';

  @override
  String get bundleName => 'Name';

  @override
  String get bundleNameHelp =>
      'Beschriftet das Paket für die Empfänger. Optional.';

  @override
  String get bundleExport => 'Paket exportieren';

  @override
  String bundleExported(String name) {
    return '$name exportiert';
  }

  @override
  String get bundleImportTitle => 'Paket importieren';

  @override
  String get bundleImportSubtitle =>
      'Erst Vorschau, dann auf einmal angewendet';

  @override
  String get bundleImportInfo =>
      'Ein Paket wird atomar angewendet: Alles kommt an oder nichts. Die Vorschau schreibt nichts.';

  @override
  String get bundlePick => 'Paketdatei wählen';

  @override
  String get bundleCollision => 'Wenn ein Schlüssel schon vergeben ist';

  @override
  String get bundleCollisionAsk => 'Anhalten und melden';

  @override
  String get bundleCollisionSkip => 'Meinen behalten';

  @override
  String get bundleCollisionRename => 'Unter neuem Schlüssel importieren';

  @override
  String get bundleCollisionReplace => 'Meinen ersetzen';

  @override
  String get bundleProject => 'Projekt für eigene Felder';

  @override
  String get bundleProjectHelp =>
      'Der Projektschlüssel, in dem Felddefinitionen landen. Nur nötig, wenn das Paket welche enthält.';

  @override
  String get bundlePreview => 'Vorschau';

  @override
  String get bundleImport => 'Paket importieren';

  @override
  String get bundleReplaceBody =>
      'Komponenten mit demselben Schlüssel werden mit denen des Pakets überschrieben. Das lässt sich nicht rückgängig machen.';

  @override
  String get bundleImported => 'Paket importiert.';

  @override
  String get bundlePlan => 'Was der Import tun würde';

  @override
  String get bundleDone => 'Was der Import getan hat';

  @override
  String get bundleEmpty => 'Das Paket enthält nichts.';

  @override
  String get bundleActionCreate => 'Neu';

  @override
  String get bundleActionReplace => 'Ersetzt';

  @override
  String get bundleActionRename => 'Umbenannt';

  @override
  String get bundleActionSkip => 'Übersprungen';

  @override
  String get snapshotTitle => 'Snapshot importieren';

  @override
  String get snapshotFileTitle => 'Snapshot-Datei';

  @override
  String get snapshotFileSubtitle =>
      'Eine Datei aus dem Export eines ganzen Mandanten';

  @override
  String get snapshotInfo =>
      'Ein Snapshot enthält Projekte, Workflows, Felder, Aufgaben und Kommentare. Prüfen Sie mit einem Probelauf, was er ändern würde, bevor Sie importieren.';

  @override
  String get snapshotPick => 'Snapshot-Datei wählen';

  @override
  String get snapshotMerge => 'Zusammenführen';

  @override
  String get snapshotReplace => 'Ersetzen';

  @override
  String get snapshotMergeHelp =>
      'Fügt Neues hinzu und aktualisiert Geändertes. Nichts wird entfernt.';

  @override
  String get snapshotReplaceHelp =>
      'Entfernt außerdem Aufgaben und Felder jedes importierten Projekts, die der Snapshot nicht enthält.';

  @override
  String get snapshotDryRun => 'Probelauf';

  @override
  String get snapshotImport => 'Snapshot importieren';

  @override
  String get snapshotMergeBody =>
      'Die Datensätze des Snapshots werden diesem Mandanten hinzugefügt und aktualisieren vorhandene.';

  @override
  String get snapshotReplaceBody =>
      'Aufgaben und Felder der importierten Projekte, die der Snapshot nicht enthält, werden gelöscht. Das lässt sich nicht rückgängig machen.';

  @override
  String get snapshotImported => 'Snapshot importiert.';

  @override
  String get snapshotPlan => 'Was der Import tun würde';

  @override
  String get snapshotDone => 'Was der Import getan hat';

  @override
  String get snapshotCreated => 'Erstellt';

  @override
  String get snapshotUpdated => 'Aktualisiert';

  @override
  String get snapshotDeleted => 'Gelöscht';

  @override
  String get snapshotSkipped => 'Unverändert';

  @override
  String manageInheritedValue(String value) {
    return 'Geerbt: $value';
  }

  @override
  String manageDurationSaved(String value) {
    return 'Gespeichert als $value. Leer erbt.';
  }

  @override
  String get projectsShowArchived => 'Archivierte anzeigen';

  @override
  String get projectStar => 'Projekt zu Favoriten';

  @override
  String get projectUnstar => 'Aus Favoriten';

  @override
  String projectStarred(String name) {
    return '$name als Favorit markiert';
  }

  @override
  String projectUnstarred(String name) {
    return '$name aus Favoriten entfernt';
  }

  @override
  String get projectsStarredHeading => 'Favoriten';

  @override
  String get projectsRestHeading => 'Weitere Projekte';

  @override
  String syncOpStarProject(String key) {
    return '$key: Projekt als Favorit';
  }

  @override
  String syncOpUnstarProject(String key) {
    return '$key: Projekt aus Favoriten';
  }

  @override
  String get manageBundlesSubtitle =>
      'Workflows, Felder, Tags und Webhooks als eine Datei';

  @override
  String get manageSnapshotSubtitle =>
      'Den Export eines ganzen Mandanten einspielen';

  @override
  String get manageStatusSubtitle =>
      'Version, Serverprozesse und Arbeit des Mandanten';

  @override
  String get rotateToken => 'Token erneuern';

  @override
  String rotateTokenBody(String name) {
    return '$name erhält ein neues Token mit demselben Namen, denselben Berechtigungen und derselben Laufzeit, und die App behält nur das neue. Alles andere, das das alte Token nutzt, funktioniert in einer Minute nicht mehr.';
  }

  @override
  String get tokenRotated => 'Token erneuert. Das alte endet in einer Minute.';

  @override
  String get offlineTitle => 'Offline';

  @override
  String get offlineSubtitle => 'Was ohne Verbindung verfügbar bleibt';

  @override
  String get offlineLocal =>
      'Diese Instanz ist eine Datenbank auf diesem Gerät und daher immer verfügbar. Der Offlinemodus gilt nur für entfernte Instanzen.';

  @override
  String get offlineAvailableTitle => 'Offline verfügbar';

  @override
  String get offlineAvailableSubtitle =>
      'Auf diesem Gerät für die aktive Instanz und den aktiven Mandanten gespeichert, mit den Kommentaren und Unteraufgaben jeder Aufgabe.';

  @override
  String get offlineStorageTitle => 'Speicher';

  @override
  String get offlineStorageSubtitle =>
      'Gespeicherte Kopien dieses Kontexts, einschließlich Änderungen, die noch gesendet werden.';

  @override
  String get offlineStorageCounting => 'Wird berechnet…';

  @override
  String get offlineStorageUnknown => 'Größe unbekannt';

  @override
  String get offlineClear => 'Kopien löschen';

  @override
  String get offlineClearTitle => 'Gespeicherte Kopien löschen?';

  @override
  String get offlineClearBody =>
      'Ansichten laden wieder vom Server, und bis zur nächsten Synchronisierung ist nichts offline verfügbar. Noch nicht gesendete Änderungen bleiben erhalten.';

  @override
  String get offlineSyncTitle => 'Synchronisierung';

  @override
  String get offlineSyncSubtitle =>
      'Läuft beim Öffnen dieses Kontexts und alle 30 Minuten. Auf einem Telefon wartet sie auf WLAN und genug Akku; „Jetzt synchronisieren“ läuft immer.';

  @override
  String get offlineSyncNow => 'Jetzt synchronisieren';

  @override
  String get offlineNeverSynced => 'Noch nicht synchronisiert';

  @override
  String offlineStorageUsed(String size) {
    return '$size belegt';
  }

  @override
  String offlineLastSynced(String time) {
    return 'Zuletzt synchronisiert $time';
  }

  @override
  String offlineSavedCopy(String time) {
    return 'Offline, gespeicherte Kopie vom $time';
  }

  @override
  String get errorSecretStorage =>
      'Der sichere Speicher dieses Geräts ist gesperrt oder hat das Schreiben abgelehnt, daher wurde nichts geändert. Entsperren Sie ihn und versuchen Sie es erneut.';

  @override
  String get tokenUnsavedTitle => 'Token erneuert, aber nicht gespeichert';

  @override
  String get tokenUnsavedHeading => 'Kopieren Sie dieses Token jetzt';

  @override
  String get tokenUnsavedNote =>
      'Der sichere Speicher dieses Geräts hat das neue Token abgelehnt. Es wird nur dieses eine Mal angezeigt, und das alte Token funktioniert in einer Minute nicht mehr. Die App nutzt das neue, bis sie geschlossen wird; verbinden Sie sich danach damit neu.';

  @override
  String get tokenUnsavedDone => 'Ich habe es kopiert';

  @override
  String get syncMarkUnsynced => 'Nicht synchronisiert';

  @override
  String get syncMarkDraft => 'Entwurf';

  @override
  String get syncMarkCheck => 'Prüfen';

  @override
  String get syncMarkConflict => 'Konflikt';

  @override
  String get syncMarkFailed => 'Abgelehnt';

  @override
  String get syncConflictsTitle => 'Konflikte';

  @override
  String get syncConflictsSubtitle =>
      'Offline gemachte Änderungen und wie sie synchronisiert wurden';

  @override
  String get syncSendNow => 'Jetzt senden';

  @override
  String get syncEmptyTitle => 'Alles ist synchronisiert';

  @override
  String get syncConflictsEmptyBody =>
      'Änderungen, die du offline machst, warten hier, bis der Server wieder erreichbar ist.';

  @override
  String syncConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Konflikte',
      one: '1 Konflikt',
    );
    return '$_temp0';
  }

  @override
  String get syncConflictsHelp =>
      'Jemand hat dasselbe auf dem Server geändert, während du offline warst.';

  @override
  String get syncKeepAllMine => 'Alle meine behalten';

  @override
  String get syncKeepAllTheirs => 'Alle ihre behalten';

  @override
  String syncWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wartende Änderungen',
      one: '1 wartende Änderung',
    );
    return '$_temp0';
  }

  @override
  String get syncHistory => 'Verlauf';

  @override
  String get syncHistoryHelp =>
      'Gelöste Konflikte. Kehre einen um, um die nicht behaltene Seite zu senden.';

  @override
  String get syncFieldTitle => 'Titel';

  @override
  String get syncFieldBody => 'Beschreibung';

  @override
  String get syncFieldPriority => 'Priorität';

  @override
  String get syncFieldAssignee => 'Zuständig';

  @override
  String get syncFieldDue => 'Fällig';

  @override
  String get syncFieldTags => 'Tags';

  @override
  String get syncFieldStatus => 'Status';

  @override
  String get syncFieldRecurrence => 'Wiederholung';

  @override
  String get syncFieldParent => 'Übergeordnet';

  @override
  String get syncValueEmpty => '(leer)';

  @override
  String get syncMine => 'Meins';

  @override
  String get syncTheirs => 'Ihres';

  @override
  String get syncKeepMine => 'Meins behalten';

  @override
  String get syncKeepTheirs => 'Ihres behalten';

  @override
  String get syncEditChange => 'Bearbeiten';

  @override
  String get syncEditChangeTitle => 'Vor dem Senden bearbeiten';

  @override
  String get syncEditSend => 'Senden';

  @override
  String syncTheirsWas(String value) {
    return 'Auf dem Server: $value';
  }

  @override
  String get syncDeletedBody =>
      'Diese Aufgabe wurde auf dem Server gelöscht, nachdem du sie geändert hast.';

  @override
  String get syncRestoreApply => 'Wiederherstellen und anwenden';

  @override
  String get syncDiscardMine => 'Meins verwerfen';

  @override
  String get syncDiscardMineTitle => 'Deine Änderungen verwerfen?';

  @override
  String get syncDiscardMineBody =>
      'Alles, was du offline an dieser Aufgabe geändert hast, wird verworfen. Die Aufgabe bleibt gelöscht.';

  @override
  String syncMoveRefused(String status, String reason) {
    return 'Das Verschieben nach $status wurde abgelehnt: $reason';
  }

  @override
  String get syncMoveElsewhere => 'Woandershin verschieben';

  @override
  String syncOpUpdate(String ref, String fields) {
    return '$ref: $fields';
  }

  @override
  String syncOpCheck(String ref) {
    return '$ref: Checklistenpunkt';
  }

  @override
  String syncOpMove(String ref, String status) {
    return '$ref: nach $status verschieben';
  }

  @override
  String syncOpStar(String ref) {
    return '$ref: Stern';
  }

  @override
  String syncOpUnstar(String ref) {
    return '$ref: Stern entfernen';
  }

  @override
  String syncOpSnooze(String ref) {
    return '$ref: zurückstellen';
  }

  @override
  String syncOpCreate(String title) {
    return 'Neue Aufgabe: $title';
  }

  @override
  String syncOpComment(String ref) {
    return '$ref: Kommentar';
  }

  @override
  String syncOpTagAdd(String ref, String tag) {
    return '$ref: #$tag hinzufügen';
  }

  @override
  String syncOpTagRemove(String ref, String tag) {
    return '$ref: #$tag entfernen';
  }

  @override
  String syncOpDependency(String ref, String other) {
    return '$ref: wartet auf $other';
  }

  @override
  String syncOpArtifact(String ref) {
    return '$ref: Anhang';
  }

  @override
  String syncOpRestore(String ref) {
    return '$ref: wiederherstellen';
  }

  @override
  String get syncDiscardTitle => 'Diese Änderung verwerfen?';

  @override
  String get syncDiscard => 'Verwerfen';

  @override
  String syncRefused(String reason) {
    return 'Der Server hat abgelehnt: $reason';
  }

  @override
  String get syncCheckBody =>
      'Die Antwort ging verloren, die Aufgabe gibt es vielleicht schon. Sieh im Projekt nach und sende sie oder verwirf sie.';

  @override
  String get syncSendAnyway => 'Trotzdem senden';

  @override
  String get syncAlreadyThere => 'Ist schon da';

  @override
  String get syncRetry => 'Erneut versuchen';

  @override
  String get syncKeptMine => 'Meins behalten';

  @override
  String get syncKeptTheirs => 'Ihres behalten';

  @override
  String get syncKeptEdited => 'Bearbeitung gesendet';

  @override
  String get syncKeptRestored => 'Wiederhergestellt und angewendet';

  @override
  String get syncKeptDiscarded => 'Meins verworfen';

  @override
  String syncByPolicy(String what) {
    return '$what, laut deiner Einstellung';
  }

  @override
  String get syncReverse => 'Umkehren';

  @override
  String syncBannerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Änderungen warten auf die Synchronisierung.',
      one: '1 Änderung wartet auf die Synchronisierung.',
    );
    return '$_temp0';
  }

  @override
  String get syncBannerConflict =>
      'Deine Offline-Änderungen brauchen eine Entscheidung.';

  @override
  String get syncBannerDraft =>
      'Offline erstellt. Sie bekommt ihre Referenz bei der Synchronisierung.';

  @override
  String get syncResolve => 'Lösen';

  @override
  String syncBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Konflikte zu lösen',
      one: '1 Konflikt zu lösen',
    );
    return '$_temp0';
  }

  @override
  String get syncPolicyLabel => 'Bei einem Konflikt';

  @override
  String get syncPolicyHelp =>
      'Für offline gemachte Änderungen, die auch jemand anderes geändert hat. Jeder Konflikt bleibt unter Konflikte, wo er umgekehrt werden kann.';

  @override
  String get syncPolicyAsk => 'Fragen';

  @override
  String get syncPolicyMine => 'Meins behalten';

  @override
  String get syncPolicyTheirs => 'Ihres behalten';

  @override
  String get syncOpenConflicts =>
      'Konflikte und nicht synchronisierte Änderungen';

  @override
  String get syncDiscardAll =>
      'Alle nicht synchronisierten Änderungen verwerfen';

  @override
  String get syncDiscardAllTitle =>
      'Alle nicht synchronisierten Änderungen verwerfen?';

  @override
  String syncDiscardAllBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count offline gemachte Änderungen werden verworfen und nie gesendet. Entwürfe verschwinden.',
      one: '1 offline gemachte Änderung wird verworfen und nie gesendet. Entwürfe verschwinden.',
    );
    return '$_temp0';
  }

  @override
  String syncUnsentLost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count offline gemachte Änderungen wurden noch nicht gesendet und gehen verloren.',
      one: '1 offline gemachte Änderung wurde noch nicht gesendet und geht verloren.',
    );
    return '$_temp0';
  }

  @override
  String get syncStateUnreadable =>
      'Die auf diesem Gerät wartenden Änderungen konnten nicht gelesen werden. Sie bleiben unverändert erhalten und werden nicht gesendet.';

  @override
  String get settingsAdvanced => 'Erweitert';

  @override
  String get settingsAdbControl => 'Steuerung über ADB erlauben';

  @override
  String get settingsAdbControlHelp =>
      'Erlaubt einem per USB-Debugging verbundenen Computer, in tix den Kontext zu wechseln, Aufgaben anzulegen und Einstellungen zu ändern. Den Zustand der App lesen und tix://-Links öffnen geht auch ohne.';

  @override
  String get linkNotRecognised => 'Link nicht erkannt';

  @override
  String get linkPickContextTitle => 'In welchem Kontext soll der Link öffnen?';

  @override
  String get linkPickContextBody =>
      'Der Link passt zu mehreren Ihrer Kontexte.';

  @override
  String get notifActionDone => 'Erledigt';

  @override
  String get notifActionSnooze => 'Zurückstellen';

  @override
  String get notifActionReply => 'Antworten';

  @override
  String get notifReplyLabel => 'Kommentar schreiben';

  @override
  String get notifActionFailedDone =>
      'Konnte nicht als erledigt markiert werden';

  @override
  String get notifActionFailedSnooze => 'Konnte nicht zurückgestellt werden';

  @override
  String get notifActionFailedReply =>
      'Ihre Antwort konnte nicht gesendet werden';

  @override
  String get notifActionFailedBody =>
      'Öffnen Sie tix, um es erneut zu versuchen.';

  @override
  String get pinToHome => 'Zum Startbildschirm hinzufügen';

  @override
  String get pinFailed => 'Konnte nicht zum Startbildschirm hinzugefügt werden';

  @override
  String get trayOpen => 'tix öffnen';

  @override
  String trayInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Posteingang ($count ungelesen)',
      one: 'Posteingang (1 ungelesen)',
      zero: 'Posteingang',
    );
    return '$_temp0';
  }

  @override
  String get trayQuit => 'tix beenden';

  @override
  String get trayStatusSignedOut => 'tix · nicht angemeldet';

  @override
  String trayStatusHeadline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tix · $count Instanzen verbunden',
      one: 'tix · 1 Instanz verbunden',
    );
    return '$_temp0';
  }

  @override
  String trayStatusInstance(String name, String place, String state) {
    return '$name ($place): $state';
  }

  @override
  String trayStatusInstanceQuiet(String name, String place) {
    return '$name ($place)';
  }

  @override
  String get trayStatusLocal => 'lokal';

  @override
  String get trayStatusLive => 'live';

  @override
  String get trayStatusConnecting => 'verbindet';

  @override
  String get trayStatusSyncing => 'synchronisiert gerade';

  @override
  String get trayStatusOffline => 'offline';

  @override
  String trayStatusSynced(String ago) {
    return 'synchronisiert $ago';
  }

  @override
  String trayStatusQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Änderungen warten',
      one: '1 Änderung wartet',
    );
    return '$_temp0';
  }

  @override
  String trayStatusMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count weitere',
      one: '+1 weitere',
    );
    return '$_temp0';
  }

  @override
  String trayStatusUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesen im Posteingang',
      one: '1 ungelesen im Posteingang',
    );
    return '$_temp0';
  }

  @override
  String get settingsDesktop => 'Desktop';

  @override
  String get settingsDesktopHelp =>
      'Wie sich tix auf diesem Computer verhält: das Symbol im Infobereich, der Start bei der Anmeldung und ein Tastenkürzel, das in jeder App funktioniert.';

  @override
  String get settingsCloseToTray => 'Im Infobereich weiterlaufen';

  @override
  String get settingsCloseToTrayHelp =>
      'Das Schließen blendet das Fenster nur aus, Synchronisierung und Benachrichtigungen laufen weiter. Beenden über das Menü des Symbols.';

  @override
  String get settingsCloseToTrayNone =>
      'Dieser Desktop zeigt keine Symbole im Infobereich, daher beendet das Schließen des Fensters tix.';

  @override
  String get settingsAutostart => 'Bei der Anmeldung starten';

  @override
  String get settingsAutostartHelp =>
      'tix startet, wenn Sie sich an diesem Computer anmelden.';

  @override
  String get settingsAutostartFailed =>
      'Start bei der Anmeldung konnte nicht geändert werden';

  @override
  String get settingsHotkey => 'Schnell hinzufügen aus jeder App';

  @override
  String settingsHotkeyHelp(String keys) {
    return '$keys öffnet „Schnell hinzufügen“, auch wenn tix im Hintergrund läuft.';
  }

  @override
  String settingsHotkeyTaken(String keys) {
    return '$keys wird bereits von einer anderen App verwendet';
  }

  @override
  String get goWatch => 'Zu Aktivität';

  @override
  String get watchTitle => 'Aktivität';

  @override
  String get watchSubtitle =>
      'Die Ereignisse des Mandanten, sobald sie passieren, neueste zuerst.';

  @override
  String get watchPause => 'Anhalten';

  @override
  String get watchResume => 'Fortsetzen';

  @override
  String get watchClear => 'Liste leeren';

  @override
  String get watchPaused => 'Angehalten.';

  @override
  String watchPausedNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Angehalten, $count neue Ereignisse.',
      one: 'Angehalten, 1 neues Ereignis.',
    );
    return '$_temp0';
  }

  @override
  String get watchFilters => 'Filter';

  @override
  String watchFiltersCount(int count) {
    return 'Filter ($count)';
  }

  @override
  String get watchAllTypes => 'Alle Typen';

  @override
  String watchFiltering(String filters) {
    return 'Gefiltert nach $filters';
  }

  @override
  String watchFilterProject(String projects) {
    return 'Projekt $projects';
  }

  @override
  String watchFilterType(String types) {
    return 'Typ $types';
  }

  @override
  String watchFilterActor(String actors) {
    return 'Akteur $actors';
  }

  @override
  String watchFilterSince(int seq) {
    return 'nach #$seq';
  }

  @override
  String get watchProjects => 'Projekte';

  @override
  String get watchProjectsHelp =>
      'Wird an den Server gesendet. Ohne Auswahl werden alle Projekte verfolgt.';

  @override
  String get watchTypes => 'Ereignistypen';

  @override
  String get watchTypesHelp =>
      'Durch Kommas getrennt, an den Server gesendet. Ein * am Ende passt auf einen Anfang, etwa task.*.';

  @override
  String get watchActors => 'Akteure';

  @override
  String get watchActorsHelp =>
      'Handles oder IDs, durch Kommas getrennt. Wird auf diesem Gerät verglichen, wie bei tix watch.';

  @override
  String get watchReplay => 'Ab Sequenznummer wiederholen';

  @override
  String get watchReplayHelp =>
      'Zeigt die Ereignisse nach dieser Nummer erneut und folgt dann live. Leer beginnt ab jetzt.';

  @override
  String get watchDetails => 'Details';

  @override
  String get watchOpen => 'Öffnen';

  @override
  String get watchSeq => 'Sequenz';

  @override
  String get watchType => 'Typ';

  @override
  String get watchProject => 'Projekt';

  @override
  String get watchEventId => 'Ereignis-ID';

  @override
  String get watchPayload => 'Nutzdaten';

  @override
  String get watchEmpty => 'Warten auf Ereignisse';

  @override
  String get watchEmptyBody =>
      'Änderungen in diesem Mandanten erscheinen hier, sobald sie passieren. Frühere werden nur angezeigt, wenn Sie ab einer Sequenznummer wiederholen.';

  @override
  String get watchNoMatch => 'Noch keine Treffer';

  @override
  String get watchNoMatchBody =>
      'Ereignisse kommen an, aber keines passt zu diesen Filtern.';

  @override
  String get watchConnecting => 'Verbindung zum Ereignisstrom wird aufgebaut';

  @override
  String get watchOffline => 'Offline';

  @override
  String get watchOfflineBody =>
      'Der Server ist nicht erreichbar. Aktivität macht dort weiter, wo sie aufgehört hat, sobald er wieder erreichbar ist.';

  @override
  String get watchNoContext => 'Kein Kontext aktiv';

  @override
  String get watchRefused => 'Diese Verbindung kann keine Ereignisse verfolgen';

  @override
  String get watchRefusedBody =>
      'Zum Verfolgen von Ereignissen ist der Bereich event:subscribe nötig. Verwenden Sie ein Token damit oder fragen Sie einen Administrator.';

  @override
  String get watchFilterRefused => 'Der Server hat diesen Filter abgelehnt';

  @override
  String get watchUnsupported =>
      'Dieser Server kann gerade keine Ereignisse an die App senden, daher bleibt Aktivität leer. Sie setzt wieder ein, sobald Live-Updates funktionieren.';

  @override
  String watchExpired(int seq) {
    return 'Ereignisse nach #$seq werden auf dem Server nicht mehr aufbewahrt. Neue Ereignisse werden ab jetzt angezeigt.';
  }

  @override
  String get watchMissed =>
      'Die Verbindung kam ohne Cursor zurück, daher fehlen möglicherweise Ereignisse.';

  @override
  String get watchDismiss => 'Ausblenden';

  @override
  String watchKeeping(int count) {
    return 'Die letzten $count Ereignisse werden behalten, ältere entfallen.';
  }

  @override
  String watchFor(String holder) {
    return 'für $holder';
  }

  @override
  String watchLease(String duration) {
    return 'Lease $duration';
  }

  @override
  String watchHeldBy(String holder) {
    return 'gehalten von $holder';
  }

  @override
  String watchRevertedTo(String status) {
    return 'zurück auf $status';
  }

  @override
  String watchChanged(String fields) {
    return 'geändert: $fields';
  }

  @override
  String get watchRestored => 'wiederhergestellt';

  @override
  String get watchCommentDeleted => 'Kommentar gelöscht';

  @override
  String get watchLeaseRenewed => 'Lease verlängert';

  @override
  String watchTagRemoved(String tag) {
    return 'Tag entfernt: $tag';
  }

  @override
  String watchDependencyRemoved(String ref) {
    return 'Abhängigkeit entfernt: $ref';
  }

  @override
  String watchSyncedFrom(String system) {
    return 'synchronisiert von $system';
  }

  @override
  String get settingsUpdates => 'Updates';

  @override
  String get settingsUpdatesHelp =>
      'tix sucht auf GitHub nach neuen Versionen. Updates werden vor der Installation geprüft: Der Download muss zu den signierten Prüfsummen der Version passen.';

  @override
  String get settingsUpdateCheck => 'Nach Updates suchen';

  @override
  String get settingsUpdateCheckHelp =>
      'Beim Start von tix und alle paar Stunden.';

  @override
  String get settingsUpdateAuto => 'Updates automatisch installieren';

  @override
  String get settingsUpdateAutoHelp =>
      'Ein heruntergeladenes Update wird installiert, wenn Sie tix beenden.';

  @override
  String get updateCheckNow => 'Jetzt prüfen';

  @override
  String get updateIdle => 'Noch nicht geprüft.';

  @override
  String get updateChecking => 'Suche nach Updates…';

  @override
  String updateCurrent(String version) {
    return 'tix $version ist die neueste Version.';
  }

  @override
  String updateAvailable(String version) {
    return 'Update verfügbar: tix $version';
  }

  @override
  String get updateAvailableHelp =>
      'Laden Sie es von der Release-Seite herunter.';

  @override
  String updateDownloading(String version, int percent) {
    return 'tix $version wird heruntergeladen… $percent %';
  }

  @override
  String updateReady(String version) {
    return 'tix $version ist bereit zur Installation.';
  }

  @override
  String get updateReadyAuto =>
      'Es wird beim Beenden von tix installiert, oder jetzt mit einem Neustart.';

  @override
  String get updateRestart => 'Neu starten und aktualisieren';

  @override
  String get updateDownload => 'Herunterladen';

  @override
  String get updateWhatsNew => 'Neuigkeiten';

  @override
  String get updateFailedNetwork =>
      'GitHub war nicht erreichbar, um nach Updates zu suchen.';

  @override
  String get updateFailedVerify =>
      'Das Update konnte nicht geprüft werden und wurde daher nicht installiert.';

  @override
  String get updateFailedInstall =>
      'Das Update konnte nicht installiert werden.';

  @override
  String get updateNoAsset =>
      'Das Release enthält keinen Download für dieses System.';

  @override
  String trayUpdateAvailable(String version) {
    return 'Update verfügbar ($version)';
  }

  @override
  String trayRestartToUpdate(String version) {
    return 'Neu starten für Update ($version)';
  }

  @override
  String get trayWatch => 'Aktivität';

  @override
  String watchVia(String channel) {
    return 'über $channel';
  }

  @override
  String watchViaNamed(String channel, String name) {
    return 'über $channel ($name)';
  }

  @override
  String viaToken(String name) {
    return 'über Token $name';
  }

  @override
  String viaChannelToken(String channel, String name) {
    return 'über $channel (Token $name)';
  }

  @override
  String get watchChannelWeb => 'Web';

  @override
  String get watchChannelApi => 'API';

  @override
  String get watchChannelCli => 'CLI';

  @override
  String get watchChannelSsh => 'SSH';

  @override
  String get watchChannelMcp => 'MCP';

  @override
  String get watchChannelSync => 'Sync';

  @override
  String get watchChannelImport => 'Import';

  @override
  String get watchChannelSystem => 'System';

  @override
  String get watchChannelUnknown => 'einen unbekannten Kanal';

  @override
  String get watchFieldTitle => 'Titel';

  @override
  String get watchFieldBody => 'Beschreibung';

  @override
  String get watchFieldPriority => 'Priorität';

  @override
  String get watchFieldAssignee => 'Zuständige Person';

  @override
  String get watchFieldTags => 'Tags';

  @override
  String get watchFieldDue => 'Fälligkeit';

  @override
  String get watchFieldRecurrence => 'Wiederholung';

  @override
  String get watchFieldCustom => 'eigene Felder';

  @override
  String get watchFieldParent => 'übergeordnete Aufgabe';

  @override
  String get watchCommentEdited => 'bearbeitet';

  @override
  String watchCommentBy(String author, String text) {
    return '$author: $text';
  }

  @override
  String get boardPriorityTo => 'Priorität…';

  @override
  String get boardDueTo => 'Fälligkeitsdatum…';

  @override
  String get boardTagAdd => 'Tag hinzufügen…';

  @override
  String boardPrioritySet(String ref) {
    return 'Priorität von $ref geändert';
  }

  @override
  String boardDueSet(String ref) {
    return 'Fälligkeitsdatum von $ref gesetzt';
  }

  @override
  String boardDueCleared(String ref) {
    return 'Fälligkeitsdatum von $ref entfernt';
  }

  @override
  String boardTagged(String ref, String tag) {
    return '$ref mit $tag getaggt';
  }

  @override
  String get sidebarCollapse => 'Seitenleiste einklappen';

  @override
  String get sidebarExpand => 'Seitenleiste ausklappen';

  @override
  String get sidebarResize => 'Größe der Seitenleiste ändern';

  @override
  String get paneCollapsed => 'Eingeklappt';

  @override
  String get paneResizeHint =>
      'Ziehen oder die Pfeiltasten verwenden. Eingabe oder ein Doppelklick setzt die Breite zurück.';

  @override
  String get taskPanelClose => 'Aufgabe schließen';

  @override
  String get taskPanelResize => 'Größe des Aufgabenbereichs ändern';

  @override
  String get keysNextRow => 'Nächste Zeile';

  @override
  String get keysPreviousRow => 'Vorherige Zeile';

  @override
  String get keysFirstRow => 'Erste Zeile';

  @override
  String get keysLastRow => 'Letzte Zeile';

  @override
  String get keysPageDown => 'Seite nach unten';

  @override
  String get keysPageUp => 'Seite nach oben';

  @override
  String get keysOpenRow => 'Fokussierte Zeile öffnen';

  @override
  String get keysBack => 'Zurück';

  @override
  String get keysLeaveField => 'Textfeld verlassen';

  @override
  String get keysFirstTask => 'Erste Aufgabe';

  @override
  String get keysLastTask => 'Letzte Aufgabe';

  @override
  String get settingsKeyboard => 'Tastatur';

  @override
  String get settingsKeyboardHelp =>
      'Für eine Hardwaretastatur, auf jedem Gerät. In ein Textfeld getippte Tasten bleiben immer im Feld.';

  @override
  String get settingsShortcutsHelp =>
      'Aus schaltet jedes Tastenkürzel ab, auch Strg K für die Befehlspalette. Tab, Eingabe und Esc funktionieren weiter.';

  @override
  String get settingsKeymap => 'Tastenbelegung';

  @override
  String get keymapDefault => 'Standard';

  @override
  String get keymapVim => 'Vim';

  @override
  String get keymapEmacs => 'Emacs';

  @override
  String get keymapOff => 'Aus';

  @override
  String get keymapDefaultHelp =>
      'Die Tasten der App und von tix web: j und k bewegen, g p öffnet Projekte, Strg 1 bis 6 wechseln den Bereich.';

  @override
  String get keymapVimHelp =>
      'Vim-Reflexe: gg und G springen, o fügt hinzu, i benennt um, dd löscht nach Rückfrage, h geht zurück.';

  @override
  String get keymapEmacsHelp =>
      'Emacs-Reflexe außerhalb von Textfeldern: C-n und C-p bewegen, C-s filtert, C-g bricht ab, M-x öffnet die Befehlspalette.';

  @override
  String get keymapOffHelp =>
      'Keine einzelne Taste löst etwas aus. Kombinationen mit Strg, Alt oder ⌘ funktionieren weiter.';

  @override
  String get settingsKeyBindings => 'Aktive Belegung';

  @override
  String get settingsKeyBindingsOff => 'Tastenkürzel sind aus.';

  @override
  String get taskHandoff => 'An einen Agenten übergeben';

  @override
  String get taskHandoffNote =>
      'Der Agent muss zuerst mit tix verbunden sein: über die tix-CLI oder die tix-MCP-Werkzeuge, mit einem eigenen Token. Nichts hier enthält ein Token. Einrichtung: docs/agents.md';

  @override
  String get taskHandoffPrompt => 'Prompt';

  @override
  String get taskHandoffClient => 'Aus Ihrem Client starten';

  @override
  String get taskHandoffRunHere =>
      'Führen Sie das im Repository aus, in dem die Arbeit liegt. Es ist für sh, bash und zsh gequotet.';

  @override
  String taskHandoffPasteInto(String client) {
    return '$client hat keinen Befehl, der ihn mit einem Prompt startet. Fügen Sie das in seinen Chat ein; es nutzt die tix-MCP-Werkzeuge:';
  }

  @override
  String get taskHandoffMcp => 'Mit den tix-MCP-Werkzeugen';

  @override
  String get taskHandoffKeywords =>
      'agent ki übergeben delegieren ai claude codex prompt mcp';

  @override
  String get taskShare => 'Teilen';

  @override
  String taskShareTitle(String ref) {
    return '$ref teilen';
  }

  @override
  String get taskShareNative => 'Teilen…';

  @override
  String get taskShareCopyLink => 'Link kopieren';

  @override
  String get taskShareCopyMarkdown => 'Als Markdown kopieren';

  @override
  String get taskShareCopyText => 'Schlüssel und Titel kopieren';

  @override
  String get taskShareLinkCopied => 'Link kopiert';

  @override
  String get taskShareMarkdownCopied => 'Markdown-Link kopiert';

  @override
  String get taskShareTextCopied => 'Schlüssel und Titel kopiert';

  @override
  String get taskShareKeywords =>
      'teilen link adresse kopieren share url markdown';

  @override
  String get taskDetailHistoryRaw => 'Rohdaten';

  @override
  String get taskDetailHistoryRawTitle => 'Roheintrag';

  @override
  String get taskDetailHistoryCopyAll => 'Alles als JSON kopieren';

  @override
  String get taskDetailHistoryCopyTip => 'Diesen Eintrag als JSON kopieren';

  @override
  String get taskDetailReactionAdd => 'Reaktion hinzufügen';

  @override
  String get taskDetailReactionPick => 'Reagieren';

  @override
  String taskDetailReactionLabel(String emoji, String count) {
    return 'Reaktion $emoji, $count';
  }

  @override
  String taskDetailReactionWho(String emoji) {
    return 'Reagiert mit $emoji';
  }

  @override
  String taskDetailReactionLabelMine(String emoji, String count) {
    return 'Reaktion $emoji, $count, Sie haben reagiert';
  }

  @override
  String get taskDetailReactionUnsupported =>
      'Dieser Server unterstützt keine Reaktionen.';

  @override
  String get taskDetailReactionOther => 'Beliebiges Emoji';

  @override
  String get taskDetailReactionOtherHelp => 'Ein Emoji eingeben oder einfügen.';

  @override
  String get taskDetailReactionOneEmoji => 'Geben Sie genau ein Emoji ein.';

  @override
  String get rowHeld => 'gehalten';

  @override
  String rowHeldBy(String holder) {
    return 'gehalten · $holder';
  }

  @override
  String rowHeldTip(String holder) {
    return 'Gehalten von $holder';
  }

  @override
  String rowHeldUntil(String holder, String time) {
    return 'Gehalten von $holder bis $time';
  }

  @override
  String get rowClaimSomeone => 'jemand';

  @override
  String get rowClaimExpired => 'Anspruch abgelaufen';

  @override
  String rowAgo(String span) {
    return 'vor $span';
  }

  @override
  String rowClaims(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ansprüche',
      one: '1 Anspruch',
    );
    return '$_temp0';
  }

  @override
  String rowClaimExpiredTip(String holder, String span, String time) {
    return '$holder hat den Anspruch vor $span um $time ablaufen lassen; die Aufgabe kann wieder beansprucht werden';
  }

  @override
  String rowRepeats(String rule) {
    return 'Wiederholt sich $rule';
  }

  @override
  String rowChecklist(int done, int total) {
    return '$done von $total Checklistenpunkten erledigt';
  }

  @override
  String rowWaitingOn(String ref) {
    return 'wartet auf $ref';
  }

  @override
  String rowWaitingOnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'wartet auf $count Aufgaben',
      one: 'wartet auf 1 Aufgabe',
    );
    return '$_temp0';
  }

  @override
  String rowWaitingTip(String refs) {
    return 'Wartet auf $refs';
  }
}
