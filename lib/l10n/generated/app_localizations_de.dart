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
  String get noTaskSelected => 'Wählen Sie eine Aufgabe, um sie hier zu sehen.';

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
      'Projekte werden auf dem Server angelegt, im Browser oder mit tix project add.';

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
}
