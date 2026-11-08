// SPDX-License-Identifier: AGPL-3.0-or-later

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'tix';

  @override
  String get connectTitle => 'Se connecter à tix';

  @override
  String get connectAddTitle => 'Ajouter une instance';

  @override
  String get connectIntro =>
      'Connectez-vous à un serveur tix avec un jeton d’API ou en vous identifiant, ou ouvrez une base de données tix sur cet appareil.';

  @override
  String get serverUrlLabel => 'Adresse du serveur';

  @override
  String get serverUrlHint => 'https://tix.example.com';

  @override
  String get tokenLabel => 'Jeton d’API';

  @override
  String get tokenHelp =>
      'Créez-en un avec tix token create, ou dans Jetons dans l’application web.';

  @override
  String get contextNameLabel => 'Nom (facultatif)';

  @override
  String get contextNameHelp => 'Affiché dans le sélecteur.';

  @override
  String get connectButton => 'Se connecter';

  @override
  String get projectsTitle => 'Projets';

  @override
  String get projectsEmpty => 'Aucun projet pour l’instant.';

  @override
  String get tasksEmpty => 'Aucune tâche dans ce projet.';

  @override
  String get taskTitle => 'Tâche';

  @override
  String get fieldStatus => 'Statut';

  @override
  String get fieldAssignee => 'Responsable';

  @override
  String get fieldDue => 'Échéance';

  @override
  String get fieldPriority => 'Priorité';

  @override
  String get fieldTags => 'Tags';

  @override
  String get fieldDescription => 'Description';

  @override
  String get unassigned => 'Non assignée';

  @override
  String get noDueDate => 'Pas d’échéance';

  @override
  String get noDescription => 'Aucune description.';

  @override
  String get noTaskSelected => 'Choisissez une tâche pour l’afficher ici.';

  @override
  String priorityLabel(String priority) {
    String _temp0 = intl.Intl.selectLogic(priority, {
      '1': 'Maximale',
      '2': 'Haute',
      '3': 'Normale',
      '4': 'Basse',
      '5': 'Minimale',
      'other': 'Aucune',
    });
    return '$_temp0';
  }

  @override
  String get quickAddTitle => 'Ajout rapide';

  @override
  String get quickAddHint => 'Corriger la connexion !high #auth @raj due:fri';

  @override
  String get quickAddHelp => '!priority  #tag  @assignee  due:date  ^parent';

  @override
  String get quickAddButton => 'Ajouter';

  @override
  String get cancel => 'Annuler';

  @override
  String taskCreated(String ref) {
    return '$ref créée';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get themeLabel => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get languageLabel => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String signOutBody(String server) {
    return 'Cette connexion à $server sera oubliée sur cet appareil.';
  }

  @override
  String signedInAs(String handle) {
    return 'Connecté en tant que $handle';
  }

  @override
  String get retry => 'Réessayer';

  @override
  String get loadMoreFailed => 'Impossible d’en charger plus.';

  @override
  String errorInvalid(String message) {
    return 'Le serveur a refusé : $message';
  }

  @override
  String get errorUnauthenticated =>
      'Le serveur n’a pas accepté cette connexion. Vérifiez le jeton ou reconnectez-vous.';

  @override
  String get errorForbidden => 'Ce jeton n’a pas l’autorisation de faire cela.';

  @override
  String get errorNotFound => 'Introuvable.';

  @override
  String get errorConflict =>
      'Quelqu’un a modifié cet élément en même temps. Rechargez et réessayez.';

  @override
  String errorPrecondition(String message) {
    return 'Impossible pour le moment : $message';
  }

  @override
  String get errorServer =>
      'Le serveur a rencontré un problème. Réessayez plus tard.';

  @override
  String get errorNetwork =>
      'Impossible de joindre le serveur. Vérifiez l’adresse et votre connexion.';

  @override
  String get errorTimeout => 'Le serveur a mis trop de temps à répondre.';

  @override
  String get errorNotTix => 'Cette adresse ne répond pas comme un serveur tix.';

  @override
  String get errorBadUrl =>
      'Saisissez une adresse de serveur, par exemple https://tix.example.com.';

  @override
  String get errorTokenRequired => 'Saisissez un jeton d’API.';

  @override
  String get errorUnknown => 'Une erreur s’est produite.';

  @override
  String errorRequestId(String id) {
    return 'Requête $id.';
  }

  @override
  String get instanceRemote => 'Serveur';

  @override
  String get instanceLocal => 'Cet appareil';

  @override
  String get localUnavailableNote =>
      'Les bases de données sur cet appareil nécessitent le moteur tix intégré à l’application, et cette version a été compilée sans lui.';

  @override
  String get methodToken => 'Jeton';

  @override
  String get methodSignIn => 'Identifiants';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get signInHelp =>
      'Les sessions durent environ 12 heures. Utilisez un jeton pour un appareil qui doit rester connecté.';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get localIntro =>
      'Créez une base de données tix ou ouvrez-en une existante.';

  @override
  String get dbNameLabel => 'Nom de la base de données';

  @override
  String get dbNameHelp => 'Créée dans le dossier Documents de l’application.';

  @override
  String get localNewFile => 'Nouvelle base de données…';

  @override
  String get localCreate => 'Créer la base de données';

  @override
  String get localOpenFile => 'Ouvrir un fichier de base de données…';

  @override
  String get localListTenants => 'Afficher les espaces';

  @override
  String get codeIntro =>
      'Ce compte utilise un second facteur. Saisissez le code de votre application d’authentification.';

  @override
  String get codeLabel => 'Code';

  @override
  String get codeHelp => 'Six chiffres, ou l’un de vos codes de récupération.';

  @override
  String get verifyButton => 'Vérifier';

  @override
  String get chooseTenantIntro =>
      'Vous appartenez à plusieurs espaces ici. Lequel cette connexion doit-elle ouvrir ?';

  @override
  String get pinLabel => 'Épingler à cet espace';

  @override
  String get pinOnHelp =>
      'La connexion reste dans cet espace. Ajoutez une autre connexion pour un autre espace.';

  @override
  String get pinOffHelp => 'Passez d’un espace à l’autre depuis le sélecteur.';

  @override
  String get openButton => 'Ouvrir';

  @override
  String get localTenantsIntro => 'Ouvrez un espace de cette base de données.';

  @override
  String get newTenantTitle => 'Nouvel espace';

  @override
  String get tenantKeyLabel => 'Clé';

  @override
  String get tenantNameLabel => 'Nom';

  @override
  String get createTenantButton => 'Créer et ouvrir';

  @override
  String servedAt(String host) {
    return 'Servi sur $host';
  }

  @override
  String get addAsInstance => 'Ajouter';

  @override
  String get instancesTitle => 'Instances';

  @override
  String get addInstance => 'Ajouter une instance';

  @override
  String get instancesEmpty => 'Aucune instance pour l’instant.';

  @override
  String get removeInstance => 'Supprimer l’instance';

  @override
  String removeInstanceBody(String name) {
    return '$name et toutes ses connexions seront oubliées sur cet appareil. Rien ne change sur le serveur.';
  }

  @override
  String get remove => 'Supprimer';

  @override
  String get removeConnection => 'Supprimer la connexion';

  @override
  String removeConnectionBody(String name) {
    return '$name sera oubliée sur cet appareil.';
  }

  @override
  String get openTenant => 'Ouvrir un espace';

  @override
  String get addConnection => 'Ajouter une connexion';

  @override
  String get useConnection => 'Utiliser';

  @override
  String get makeSwitchable => 'Rendre commutable';

  @override
  String get pin => 'Épingler à l’espace actuel';

  @override
  String get signInAgain => 'Se reconnecter';

  @override
  String get switchable => 'Commutable';

  @override
  String get pinned => 'Épinglée';

  @override
  String get switchContext => 'Changer d’instance ou d’espace';

  @override
  String get recentContexts => 'Récents';

  @override
  String get manageInstances => 'Gérer les instances';

  @override
  String instanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instances',
      one: '1 instance',
      zero: 'Aucune instance',
    );
    return '$_temp0';
  }

  @override
  String get errorBadCredentials =>
      'Cet e-mail et ce mot de passe n’ont pas été acceptés.';

  @override
  String get errorEmailRequired => 'Saisissez votre e-mail.';

  @override
  String get errorPasswordRequired => 'Saisissez votre mot de passe.';

  @override
  String get errorCodeRequired =>
      'Saisissez le code de votre application d’authentification.';

  @override
  String get errorSecondFactorSetup =>
      'Ce compte doit d’abord configurer un second facteur. Connectez-vous une fois dans le navigateur pour le faire.';

  @override
  String get errorPasswordChange =>
      'Ce compte doit d’abord choisir un nouveau mot de passe. Connectez-vous une fois dans le navigateur pour le faire.';

  @override
  String get errorTenantRequired => 'Saisissez une clé pour l’espace.';

  @override
  String get errorEngineUnavailable =>
      'Les bases de données sur cet appareil ne sont pas disponibles : cette version a été compilée sans le moteur tix.';

  @override
  String get localIntroImport =>
      'Créez une base de données tix ou importez-en une. L’application travaille sur sa propre copie, conservée dans l’application ; exportez-la pour emporter vos modifications ailleurs.';

  @override
  String get localOpenInPlace =>
      'Le fichier reste à sa place et les modifications y sont enregistrées directement.';

  @override
  String get localImportFile => 'Importer un fichier de base de données…';

  @override
  String get exportDatabase => 'Exporter la base de données…';

  @override
  String get databaseExported => 'Base de données exportée.';

  @override
  String get localCopyNote => 'Copie conservée dans l’application';

  @override
  String get back => 'Retour';

  @override
  String get undo => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get loading => 'Chargement';

  @override
  String get moreInfo => 'Plus d’informations';

  @override
  String get dueOverdue => 'en retard';

  @override
  String get dueToday => 'échéance aujourd’hui';

  @override
  String dueOn(String date) {
    return 'échéance $date';
  }

  @override
  String snoozedUntil(String date) {
    return 'reportée jusqu’au $date';
  }

  @override
  String get blockedByOther => 'En attente d’une autre tâche';

  @override
  String get starred => 'Favori';

  @override
  String get star => 'Ajouter aux favoris';

  @override
  String get unstar => 'Retirer des favoris';

  @override
  String get complete => 'Terminer';

  @override
  String get reopen => 'Rouvrir';

  @override
  String get snooze => 'Reporter';

  @override
  String get assign => 'Assigner';

  @override
  String get filterHint => 'Filtrer, par exemple status:todo tag:ops';

  @override
  String get shortcutsTitle => 'Raccourcis clavier';

  @override
  String get showShortcuts => 'Afficher les raccourcis clavier';

  @override
  String get openCommandPalette => 'Ouvrir la palette de commandes';

  @override
  String get commandSearchHint => 'Saisissez une commande';

  @override
  String get commandNone => 'Aucune commande ne correspond.';

  @override
  String get goProjects => 'Aller aux projets';

  @override
  String get goSettings => 'Aller aux paramètres';

  @override
  String get goInstances => 'Aller aux instances';

  @override
  String get commandsNavigate => 'Navigation';

  @override
  String get commandsTasks => 'Tâches';

  @override
  String get newTask => 'Nouvelle tâche';

  @override
  String get refresh => 'Actualiser';

  @override
  String get projectsEmptyBody =>
      'Les projets se créent sur le serveur, dans le navigateur ou avec tix project add.';

  @override
  String get tasksEmptyBody =>
      'Ajoutez une tâche en une ligne : un titre, puis !high, #tag, @handle ou due:fri.';

  @override
  String get instancesEmptyBody =>
      'Ajoutez le serveur tix sur lequel vous travaillez, ou une base de données sur cet appareil.';

  @override
  String projectsSubtitle(String tenant) {
    return 'Tous les projets de $tenant';
  }

  @override
  String get aboutTitle => 'À propos';

  @override
  String get appearanceLabel => 'Apparence';

  @override
  String get accountLabel => 'Compte';

  @override
  String get galleryTitle => 'Composants';

  @override
  String taskDetailActionsFor(String ref) {
    return 'Actions pour $ref';
  }

  @override
  String get taskDetailActorSearch => 'Rechercher par nom ou identifiant';

  @override
  String get taskDetailAdd => 'Ajouter';

  @override
  String get taskDetailAddDependency => 'Ajouter une dépendance';

  @override
  String get taskDetailAddSubtask => 'Ajouter une sous-tâche';

  @override
  String get taskDetailAddTag => 'Ajouter un tag';

  @override
  String get taskDetailArtifactFile => 'fichier';

  @override
  String get taskDetailArtifactLog => 'journal';

  @override
  String get taskDetailArtifactMetric => 'métrique';

  @override
  String get taskDetailArtifactResult => 'résultat';

  @override
  String get taskDetailArtifacts => 'Artefacts';

  @override
  String get taskDetailArtifactSave => 'Enregistrer';

  @override
  String get taskDetailArtifactShow => 'Afficher';

  @override
  String get taskDetailArtifactUnreadable =>
      'Le contenu de cet artefact est illisible.';

  @override
  String get taskDetailAssigneeTitle => 'Assigner';

  @override
  String taskDetailAttached(String name) {
    return '$name joint.';
  }

  @override
  String get taskDetailAttachFile => 'Joindre un fichier';

  @override
  String get taskDetailBlocked =>
      'Bloquée : elle attend une tâche qui n’est pas terminée.';

  @override
  String taskDetailChecklist(int done, int total) {
    return '$done sur $total faits';
  }

  @override
  String get taskDetailClear => 'Effacer';

  @override
  String get taskDetailCommands => 'Tâche';

  @override
  String get taskDetailCommentActions => 'Actions du commentaire';

  @override
  String get taskDetailCommentAdded => 'Commentaire ajouté.';

  @override
  String get taskDetailCommentDelete => 'Supprimer le commentaire';

  @override
  String get taskDetailCommentDeleteBody =>
      'Il disparaît pour tout le monde. Impossible d’annuler ici.';

  @override
  String get taskDetailCommentDeleted => 'Commentaire supprimé.';

  @override
  String get taskDetailCommentDeleteTitle => 'Supprimer ce commentaire ?';

  @override
  String get taskDetailCommentEdit => 'Modifier le commentaire';

  @override
  String get taskDetailCommentHint =>
      'Markdown accepté. @ pour mentionner quelqu’un.';

  @override
  String get taskDetailCommentLabel => 'Commentaire';

  @override
  String get taskDetailComments => 'Commentaires';

  @override
  String get taskDetailCommentSend => 'Commenter';

  @override
  String taskDetailCopied(String ref) {
    return 'Copiée sous $ref.';
  }

  @override
  String get taskDetailCopiedFrom => 'Copiée depuis';

  @override
  String get taskDetailCopyAction => 'Copier';

  @override
  String get taskDetailCopyComments => 'Copier ses commentaires';

  @override
  String get taskDetailCopyDependencies => 'Copier ses dépendances';

  @override
  String get taskDetailCopyKeepStatus => 'Conserver son statut';

  @override
  String get taskDetailCopyLink => 'Lier la copie à cette tâche';

  @override
  String get taskDetailCopyNewTitle => 'Titre de la copie';

  @override
  String get taskDetailCopyProject => 'Projet';

  @override
  String get taskDetailCopyRef => 'Copier la référence';

  @override
  String get taskDetailCopySubtasks => 'Copier ses sous-tâches';

  @override
  String taskDetailCopyTitle(String ref) {
    return 'Copier $ref';
  }

  @override
  String get taskDetailCopyTo => 'Copier vers…';

  @override
  String taskDetailCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches',
      one: '1 tâche',
    );
    return '$_temp0';
  }

  @override
  String get taskDetailCreated => 'Créée';

  @override
  String get taskDetailCurrent => 'Actuel';

  @override
  String get taskDetailDelete => 'Supprimer';

  @override
  String taskDetailDeleted(String ref) {
    return '$ref supprimée.';
  }

  @override
  String get taskDetailDeleteForGood => 'Supprimer définitivement';

  @override
  String get taskDetailDeletePermanentBody =>
      'Elle est supprimée pour de bon, avec ses commentaires et son historique.';

  @override
  String taskDetailDeleteSubtasksBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ses $count sous-tâches sont supprimées avec elle.',
      one: 'Sa sous-tâche est supprimée avec elle.',
    );
    return '$_temp0';
  }

  @override
  String taskDetailDeleteTitle(String ref) {
    return 'Supprimer $ref ?';
  }

  @override
  String get taskDetailDeleteTrashBody =>
      'Elle va dans la corbeille et peut être restaurée.';

  @override
  String get taskDetailDependencies => 'Attend';

  @override
  String get taskDetailDependenciesInfo =>
      'Cette tâche est considérée comme bloquée tant que chaque tâche listée ici n’a pas atteint un état terminé.';

  @override
  String taskDetailDependencyAdded(String ref) {
    return 'Attend désormais $ref.';
  }

  @override
  String taskDetailDependencyRemoved(String ref) {
    return 'N’attend plus $ref.';
  }

  @override
  String get taskDetailDependsOn => 'Dépend de';

  @override
  String get taskDetailDependsOnHint => 'Une référence, par exemple infra-2';

  @override
  String get taskDetailDescriptionHint =>
      'Markdown. - [ ] crée un élément de checklist.';

  @override
  String get taskDetailDueClear => 'Pas d’échéance';

  @override
  String get taskDetailDueNextWeek => 'La semaine prochaine';

  @override
  String get taskDetailDueTitle => 'Échéance';

  @override
  String get taskDetailDueToday => 'Aujourd’hui';

  @override
  String get taskDetailDueTomorrow => 'Demain';

  @override
  String get taskDetailEdit => 'Modifier';

  @override
  String get taskDetailEditDescription => 'Modifier la description';

  @override
  String get taskDetailEdited => 'modifié';

  @override
  String taskDetailEditField(String name) {
    return 'Modifier $name';
  }

  @override
  String get taskDetailFileTooBig =>
      'Les fichiers de plus de 1 Mio ne peuvent pas être joints.';

  @override
  String get taskDetailHistory => 'Historique';

  @override
  String taskDetailHistoryChanged(String fields) {
    return 'a modifié $fields';
  }

  @override
  String get taskDetailHistoryCreated => 'a créé la tâche';

  @override
  String get taskDetailHistoryDeleted => 'a supprimé la tâche';

  @override
  String get taskDetailHistoryMore => 'Afficher plus ancien';

  @override
  String taskDetailHistoryMoved(String from, String to) {
    return 'l’a déplacée de $from à $to';
  }

  @override
  String get taskDetailHistoryRestored => 'a restauré la tâche';

  @override
  String get taskDetailJsonHelp =>
      'Une valeur JSON : un nombre, une chaîne entre guillemets, une liste ou un objet';

  @override
  String get taskDetailMove => 'Déplacer';

  @override
  String get taskDetailMoveComment => 'Commentaire';

  @override
  String get taskDetailMoveCommentHelp =>
      'Ce déplacement nécessite un commentaire expliquant pourquoi.';

  @override
  String taskDetailMoved(String ref, String status) {
    return '$ref déplacée vers $status.';
  }

  @override
  String get taskDetailMoveFrom => 'De';

  @override
  String get taskDetailMoveNeedsComment => 'Commentaire requis';

  @override
  String taskDetailMoveStopped(String state, String reason) {
    return 'Arrêté avant $state : $reason';
  }

  @override
  String get taskDetailMoveTitle => 'Déplacer';

  @override
  String taskDetailMoveTo(String state) {
    return 'Déplacer vers $state';
  }

  @override
  String taskDetailMoveVia(String states) {
    return 'via $states';
  }

  @override
  String get taskDetailNo => 'Non';

  @override
  String get taskDetailNoArtifacts => 'Aucun artefact.';

  @override
  String get taskDetailNoComments => 'Aucun commentaire pour l’instant.';

  @override
  String get taskDetailNoDependencies => 'N’attend rien.';

  @override
  String get taskDetailNoHistory => 'Aucun historique.';

  @override
  String get taskDetailNoMoves =>
      'Le workflow n’autorise aucun déplacement depuis cet état.';

  @override
  String get taskDetailNoRepeat => 'Ne se répète pas';

  @override
  String get taskDetailNoSubtasks => 'Aucune sous-tâche.';

  @override
  String get taskDetailOpen => 'Ouvrir';

  @override
  String get taskDetailParent => 'Sous-tâche de';

  @override
  String get taskDetailPickDate => 'Choisir une date…';

  @override
  String get taskDetailPickDateTime => 'Choisir une date et une heure…';

  @override
  String get taskDetailPreview => 'Aperçu';

  @override
  String get taskDetailPriorityTitle => 'Priorité';

  @override
  String get taskDetailProject => 'Projet';

  @override
  String get taskDetailRefCopied => 'Référence copiée.';

  @override
  String taskDetailRemoveDependency(String ref) {
    return 'Ne plus attendre $ref';
  }

  @override
  String taskDetailRemoveTag(String tag) {
    return 'Retirer $tag';
  }

  @override
  String get taskDetailRename => 'Renommer';

  @override
  String get taskDetailRepeat => 'Répétition';

  @override
  String get taskDetailRepeatHelp =>
      'every day, every 2 weeks on mon,thu, every month on day 31, 3 days after done';

  @override
  String get taskDetailRepeatHint => 'every week';

  @override
  String get taskDetailRepeatInfo =>
      'Terminer une tâche qui a une règle crée aussitôt la suivante. L’annuler, non. Laisser vide arrête la répétition.';

  @override
  String get taskDetailRepeats => 'Répétition';

  @override
  String get taskDetailRepeatTitle => 'Règle de répétition';

  @override
  String get taskDetailSave => 'Enregistrer';

  @override
  String get taskDetailSaved => 'Enregistré.';

  @override
  String get taskDetailSnooze => 'Reporter';

  @override
  String taskDetailSnoozed(String when) {
    return 'Reportée jusqu’à $when.';
  }

  @override
  String get taskDetailSnoozeLater => 'Plus tard aujourd’hui';

  @override
  String get taskDetailSnoozeNextWeek => 'La semaine prochaine';

  @override
  String get taskDetailSnoozeTitle => 'Reporter jusqu’à';

  @override
  String get taskDetailSnoozeTomorrow => 'Demain matin';

  @override
  String get taskDetailStar => 'Ajouter aux favoris';

  @override
  String get taskDetailStarred => 'Ajoutée aux favoris.';

  @override
  String get taskDetailSubtaskAdded => 'Sous-tâche ajoutée.';

  @override
  String get taskDetailSubtasks => 'Sous-tâches';

  @override
  String get taskDetailSystem => 'tix';

  @override
  String taskDetailTagAdded(String name) {
    return 'Tag $name ajouté.';
  }

  @override
  String get taskDetailTagHint => 'Un nouveau nom crée le tag';

  @override
  String taskDetailTagRemoved(String name) {
    return '$name retiré.';
  }

  @override
  String get taskDetailTakePhoto => 'Prendre une photo';

  @override
  String get taskDetailTitleLabel => 'Titre';

  @override
  String get taskDetailUnassign => 'Retirer l’assignation';

  @override
  String get taskDetailUnstar => 'Retirer des favoris';

  @override
  String get taskDetailUnstarred => 'Retirée des favoris.';

  @override
  String get taskDetailUpdated => 'Mise à jour';

  @override
  String get taskDetailWake => 'Réactiver maintenant';

  @override
  String get taskDetailWoken => 'De retour dans les listes.';

  @override
  String get taskDetailWrite => 'Écrire';

  @override
  String get taskDetailYes => 'Oui';

  @override
  String get themeOled => 'Noir OLED';

  @override
  String get themeSystemBlack => 'Noir pur en mode sombre';

  @override
  String get themeSystemBlackHelp =>
      'Utilise le noir OLED dès que le système est en mode sombre. Économise la batterie sur les écrans OLED.';

  @override
  String get goAbout => 'À propos de tix';

  @override
  String get aboutTagline => 'Le client tix pour mobile et ordinateur';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutIntro =>
      'tix-mobile est l’application de tix, le gestionnaire de tâches open source. Elle fonctionne avec n’importe quel serveur tix, ou fait tourner tix sur cet appareil, sans serveur du tout. C’est le serveur qui décide de ce qu’il advient de votre travail : les tâches se comportent exactement comme dans l’application web et la ligne de commande de tix.';

  @override
  String get aboutVersions => 'Versions';

  @override
  String get aboutAppVersion => 'Application';

  @override
  String get aboutEngineVersion => 'Moteur intégré';

  @override
  String get aboutEngineNone => 'Absent de cette version';

  @override
  String get aboutServerVersion => 'Serveur';

  @override
  String get aboutServerNone => 'Non connecté';

  @override
  String get aboutServerUnknown => 'Illisible';

  @override
  String get aboutLinks => 'Liens';

  @override
  String get aboutWebsite => 'Site web';

  @override
  String get aboutSource => 'Code source';

  @override
  String get aboutSourceHelp =>
      'Le code source complet de l’application, tel que l’AGPL le propose';

  @override
  String get aboutRoadmap => 'Feuille de route';

  @override
  String get aboutRoadmapHelp => 'Ce qui est prévu';

  @override
  String get aboutChangelog => 'Journal des modifications';

  @override
  String get aboutChangelogHelp => 'Les nouveautés de chaque version';

  @override
  String get aboutServerProject => 'Serveur tix';

  @override
  String get aboutServerProjectHelp =>
      'Le serveur, l’application web et la ligne de commande';

  @override
  String get aboutSecurity => 'Politique de sécurité';

  @override
  String get aboutSecurityHelp => 'Signaler une vulnérabilité en privé';

  @override
  String get aboutHelp => 'Un problème ?';

  @override
  String get aboutReportBug => 'Signaler un bug';

  @override
  String get aboutReportBugHelp =>
      'Ouvre un nouveau ticket GitHub avec les versions ci-dessus déjà remplies. Ne collez jamais de jeton d’API.';

  @override
  String get aboutCopyDiagnostics => 'Copier le diagnostic';

  @override
  String get aboutDiagnosticsCopied => 'Diagnostic copié.';

  @override
  String get aboutIncludeServer => 'Inclure l’adresse du serveur';

  @override
  String get aboutIncludeServerHelp =>
      'Désactivé, l’adresse d’un serveur privé reste hors de ce que vous copiez.';

  @override
  String get aboutLicence => 'Licence';

  @override
  String get aboutLicenceBody =>
      'tix-mobile est un logiciel libre sous GNU AGPL, version 3 ou ultérieure. Les contributions sont acceptées selon l’accord de licence de contributeur du projet (CLA).';

  @override
  String get aboutLicences => 'Licences';

  @override
  String get aboutLicencesHelp =>
      'Les logiciels open source inclus dans l’application';

  @override
  String get aboutOpenFailed => 'Impossible d’ouvrir le lien.';
}
