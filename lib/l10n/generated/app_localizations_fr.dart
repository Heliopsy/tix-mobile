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
      'Créez-en un avec Nouveau projet, dans le navigateur ou avec tix project add.';

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
  String get boardAllEmpty => 'Aucune tâche pour l’instant.';

  @override
  String get boardAllEmptyBody =>
      'Les tâches de tous les projets s’affichent ici.';

  @override
  String get boardArrangement => 'Disposition';

  @override
  String get boardAssignMe => 'M’assigner';

  @override
  String boardAssignedToMe(String ref) {
    return '$ref vous est assignée';
  }

  @override
  String get boardCollapse => 'Réduire';

  @override
  String get boardColumnEmpty => 'Rien ici';

  @override
  String boardCompleted(String ref) {
    return '$ref terminée';
  }

  @override
  String boardCount(int count, String more) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count$more tâches',
      one: '1$more tâche',
    );
    return '$_temp0';
  }

  @override
  String get boardExpand => 'Développer';

  @override
  String boardGroupMenu(String group) {
    return 'Disposer $group';
  }

  @override
  String boardHiddenCount(int count) {
    return 'Masquées : $count';
  }

  @override
  String get boardHide => 'Masquer';

  @override
  String get boardLoadMore => 'Charger plus';

  @override
  String get boardMoveDown => 'Descendre';

  @override
  String get boardMoveLeft => 'Déplacer à gauche';

  @override
  String get boardMoveRight => 'Déplacer à droite';

  @override
  String boardMoveTitle(String ref) {
    return 'Déplacer $ref vers';
  }

  @override
  String get boardMoveTo => 'Déplacer vers…';

  @override
  String get boardMoveUp => 'Monter';

  @override
  String boardMoved(String ref, String status) {
    return '$ref déplacée vers $status';
  }

  @override
  String get boardNext => 'Tâche suivante';

  @override
  String boardNoRoute(String ref) {
    return 'Le workflow de $ref ne permet pas d’y aller';
  }

  @override
  String get boardOpen => 'Ouvrir';

  @override
  String get boardPrevious => 'Tâche précédente';

  @override
  String get boardRefused =>
      'Ces projets suivent des workflows différents et ne peuvent donc pas partager un tableau. Restreignez le filtre aux projets d’un seul workflow pour afficher un tableau.';

  @override
  String boardRefusedGroup(String workflow, String projects) {
    return '$workflow : $projects';
  }

  @override
  String boardReopened(String ref) {
    return '$ref rouverte';
  }

  @override
  String get boardResetArrangement => 'Réinitialiser la disposition';

  @override
  String boardShowGroup(String group) {
    return 'Afficher $group';
  }

  @override
  String get boardSnoozeLater => 'Plus tard aujourd’hui';

  @override
  String boardSnoozeTitle(String ref) {
    return 'Reporter $ref jusqu’à';
  }

  @override
  String get boardSnoozeTomorrow => 'Demain matin';

  @override
  String get boardSnoozeWeek => 'La semaine prochaine';

  @override
  String boardSnoozed(String ref) {
    return '$ref reportée';
  }

  @override
  String boardStarred(String ref) {
    return '$ref ajoutée aux favoris';
  }

  @override
  String boardStrays(String refs) {
    return 'Hors des colonnes de ce tableau : $refs';
  }

  @override
  String get boardSwitchProject => 'Changer de projet';

  @override
  String boardUnstarred(String ref) {
    return '$ref retirée des favoris';
  }

  @override
  String get boardWake => 'Réactiver maintenant';

  @override
  String boardWoken(String ref) {
    return '$ref est réactivée';
  }

  @override
  String get bulkClear => 'Effacer la sélection';

  @override
  String get bulkCopy => 'Copier vers…';

  @override
  String bulkCopyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copier $count tâches vers',
      one: 'Copier 1 tâche vers',
    );
    return '$_temp0';
  }

  @override
  String get bulkDelete => 'Supprimer';

  @override
  String get bulkDeleteBody =>
      'Elles vont dans la corbeille, et Annuler les fait revenir.';

  @override
  String bulkDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer $count tâches ?',
      one: 'Supprimer 1 tâche ?',
    );
    return '$_temp0';
  }

  @override
  String bulkDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches modifiées',
      one: '1 tâche modifiée',
    );
    return '$_temp0';
  }

  @override
  String get bulkMove => 'Déplacer';

  @override
  String bulkMoveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Déplacer $count tâches vers',
      one: 'Déplacer 1 tâche vers',
    );
    return '$_temp0';
  }

  @override
  String bulkPartly(int count, String refused) {
    return 'Modifiées : $count. Refusées : $refused';
  }

  @override
  String get bulkSelect => 'Sélectionner';

  @override
  String get bulkSelectAll => 'Tout sélectionner';

  @override
  String bulkSelected(int count) {
    return 'Sélection : $count';
  }

  @override
  String get bulkTagAdd => 'Ajouter un tag';

  @override
  String get bulkTagRemove => 'Retirer un tag';

  @override
  String get filterBlocked => 'Bloquées';

  @override
  String get filterClear => 'Effacer';

  @override
  String get filterDelete => 'Supprimer le filtre';

  @override
  String get filterDeleteBody =>
      'Les personnes avec qui il était partagé le perdent aussi.';

  @override
  String filterDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get filterDueToday => 'Échéance aujourd’hui';

  @override
  String get filterDueWeek => 'Échéance cette semaine';

  @override
  String get filterFinished => 'Terminées';

  @override
  String get filterFocus => 'Filtrer les tâches';

  @override
  String get filterMine => 'Les miennes';

  @override
  String get filterName => 'Nom';

  @override
  String get filterNoMatch => 'Rien ne correspond à ce filtre.';

  @override
  String get filterNoMatchBody => 'Modifiez le filtre ou effacez-le.';

  @override
  String get filterOverdue => 'En retard';

  @override
  String get filterRename => 'Renommer';

  @override
  String get filterSave => 'Enregistrer le filtre';

  @override
  String get filterSaveTitle => 'Enregistrer ce filtre';

  @override
  String filterSaved(String name) {
    return '$name enregistré';
  }

  @override
  String get filterShare => 'Partager avec tout le monde';

  @override
  String get filterShared => 'Partager avec tout l’espace';

  @override
  String get filterSharedHelp =>
      'Les autres le voient dans leurs filtres enregistrés ; seuls vous et les administrateurs pouvez le modifier.';

  @override
  String get filterSnoozed => 'Reportées';

  @override
  String get filterUnshare => 'Ne plus partager';

  @override
  String get goMyWork => 'Aller à Mon travail';

  @override
  String get goTasks => 'Aller à Tâches';

  @override
  String get groupNone => 'Sans regroupement';

  @override
  String get groupProject => 'Regrouper par projet';

  @override
  String get groupStatus => 'Regrouper par statut';

  @override
  String get lanesEmpty => 'Aucune tâche';

  @override
  String get myWorkEmpty => 'Rien ne vous est assigné.';

  @override
  String get myWorkEmptyBody =>
      'Les tâches ouvertes qui vous sont assignées s’affichent ici par échéance.';

  @override
  String get myWorkLater => 'Plus tard';

  @override
  String get myWorkNoDate => 'Sans date';

  @override
  String get myWorkOverdue => 'En retard';

  @override
  String get myWorkTitle => 'Mon travail';

  @override
  String get myWorkToday => 'Aujourd’hui';

  @override
  String get myWorkWeek => 'Cette semaine';

  @override
  String projectOpenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches ouvertes',
      one: '1 tâche ouverte',
    );
    return '$_temp0';
  }

  @override
  String get sortCreated => 'Création';

  @override
  String get sortDescending => 'Décroissant';

  @override
  String get sortMenu => 'Trier et regrouper';

  @override
  String get sortNumber => 'Numéro';

  @override
  String get sortTitle => 'Titre';

  @override
  String get sortUpdated => 'Mise à jour';

  @override
  String get sortUrgency => 'Urgence';

  @override
  String get tasksTitle => 'Tâches';

  @override
  String get viewBoard => 'Tableau';

  @override
  String get viewLanes => 'Couloirs';

  @override
  String get viewList => 'Liste';

  @override
  String get viewSwitch => 'Changer de vue';

  @override
  String boardAssigned(String ref) {
    return '$ref assignée';
  }

  @override
  String get boardAssignTo => 'Assigner à…';

  @override
  String get quickAddProject => 'Projet';

  @override
  String get quickAddPickProject => 'Choisir un projet';

  @override
  String get quickAddNoProjects => 'Il n’y a encore aucun projet où ajouter.';

  @override
  String get quickAddAnother => 'Ajouter une autre';

  @override
  String get quickAddAnotherHelp => 'Rester ouvert pour la ligne suivante';

  @override
  String quickAddPreviewRefused(String reason) {
    return 'Le serveur refuserait ceci : $reason';
  }

  @override
  String get quickAddPreviewOff =>
      'Cette connexion ne peut pas prévisualiser les lignes ; l’ajout fonctionne quand même.';

  @override
  String get quickAddOffline =>
      'L’ajout nécessite une connexion au serveur. La ligne est conservée ; réessayez une fois en ligne.';

  @override
  String get quickAddChipPriority => 'priorité';

  @override
  String get quickAddChipTag => 'tag';

  @override
  String get quickAddChipAssignee => 'responsable';

  @override
  String get quickAddChipDue => 'échéance';

  @override
  String get quickAddChipStatus => 'statut';

  @override
  String get quickAddChipParent => 'parent';

  @override
  String get quickAddChipTitle => 'titre';

  @override
  String get quickAddSuggestions => 'Suggestions';

  @override
  String get quickAddTemplates => 'À partir d’un modèle';

  @override
  String get quickAddManageTemplates => 'Modèles';

  @override
  String get quickAddPaste => 'Ajout rapide depuis le presse-papiers';

  @override
  String get quickAddClipboardEmpty =>
      'Le presse-papiers ne contient pas de texte.';

  @override
  String get paletteGroupProjects => 'Projets';

  @override
  String get paletteGroupRecent => 'Tâches récentes';

  @override
  String get paletteGroupContexts => 'Basculer vers';

  @override
  String get paletteGroupTheme => 'Thème';

  @override
  String get paletteGroupTemplates => 'Modèles';

  @override
  String paletteOpenTask(String ref) {
    return 'Ouvrir $ref';
  }

  @override
  String get paletteGoInbox => 'Aller à la boîte de réception';

  @override
  String get paletteGoMyWork => 'Aller à Mon travail';

  @override
  String get paletteGoTemplates => 'Aller aux modèles';

  @override
  String get paletteThemeLight => 'Thème clair';

  @override
  String get paletteThemeDark => 'Thème sombre';

  @override
  String get paletteThemeSystem => 'Thème du système';

  @override
  String paletteUseTemplate(String name) {
    return 'Nouvelle tâche à partir de $name';
  }

  @override
  String get templatesTitle => 'Modèles';

  @override
  String get templatesSubtitle =>
      'Les tâches que vous ajoutez souvent, à portée de main';

  @override
  String get templateNew => 'Nouveau modèle';

  @override
  String get templatesEmpty => 'Aucun modèle pour l’instant.';

  @override
  String get templatesEmptyBody =>
      'Enregistrez une tâche comme modèle pour la rajouter d’une simple touche.';

  @override
  String get templateEveryProject => 'Tous les projets';

  @override
  String templateUses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Utilisé $count fois',
      one: 'Utilisé une fois',
      zero: 'Jamais utilisé',
    );
    return '$_temp0';
  }

  @override
  String templateSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sous-tâches',
      one: '1 sous-tâche',
    );
    return '$_temp0';
  }

  @override
  String get templateUse => 'Utiliser';

  @override
  String get templateEdit => 'Modifier le modèle';

  @override
  String get templateDelete => 'Supprimer le modèle';

  @override
  String templateDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get templateDeleteBody =>
      'Les tâches créées à partir de ce modèle sont conservées.';

  @override
  String templateDeleted(String name) {
    return '$name supprimé';
  }

  @override
  String templateSaved(String name) {
    return '$name enregistré';
  }

  @override
  String get templateName => 'Nom';

  @override
  String get templateNameHelp =>
      'Unique dans l’espace, 100 caractères maximum.';

  @override
  String get templateFromTask => 'À partir d’une tâche';

  @override
  String get templateFromScratch => 'Partir de zéro';

  @override
  String get templateTaskRef => 'Tâche';

  @override
  String get templateTaskRefHelp =>
      'La référence de la tâche à conserver, par exemple ops-12.';

  @override
  String get templateWithSubtasks => 'Conserver ses sous-tâches';

  @override
  String get templateTenantWide => 'Partager avec tous les projets';

  @override
  String get templateDueIn => 'Échéance après';

  @override
  String get templateDueInHelp =>
      'Délai entre l’utilisation et l’échéance de la tâche, par exemple 3d ou 2w. Vide pour aucune.';

  @override
  String get templateScratchNote =>
      'tix crée les modèles à partir de tâches : la tâche est donc aussi ajoutée au projet.';

  @override
  String get templateTitle => 'Titre';

  @override
  String templateTitleHelp(String date, String n, String project) {
    return '$date, $n et $project sont remplis à chaque utilisation.';
  }

  @override
  String get templateBody => 'Description';

  @override
  String get templatePriority => 'Priorité';

  @override
  String get templateTags => 'Tags';

  @override
  String get templateTagsHelp => 'Séparés par des espaces ou des virgules.';

  @override
  String get templateRecurrence => 'Répétition';

  @override
  String get templateRecurrenceHelp =>
      'Par exemple every 2 weeks. Vide pour aucune.';

  @override
  String get templateSave => 'Enregistrer';

  @override
  String get templateCreate => 'Enregistrer le modèle';

  @override
  String get templateRecentTasks => 'Ouvertes récemment';

  @override
  String get appShortcutInbox => 'Boîte de réception';

  @override
  String get appShortcutMyWork => 'Mon travail';

  @override
  String get templateDeleteAction => 'Supprimer';

  @override
  String get templateMore => 'Plus d’actions';

  @override
  String templateGeneralError(String reason) {
    return 'Enregistrement impossible : $reason';
  }

  @override
  String get goInbox => 'Aller à la boîte de réception';

  @override
  String get inboxTitle => 'Boîte de réception';

  @override
  String get inboxAll => 'Tout';

  @override
  String get inboxUnreadFilter => 'Non lus';

  @override
  String get inboxShowUnread => 'Afficher les non lus uniquement';

  @override
  String get inboxUnread => 'non lu';

  @override
  String get inboxAllCaughtUp => 'Vous êtes à jour';

  @override
  String inboxUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count non lus',
      one: '1 non lu',
    );
    return '$_temp0';
  }

  @override
  String get inboxToday => 'Aujourd’hui';

  @override
  String get inboxYesterday => 'Hier';

  @override
  String get inboxEarlier => 'Plus tôt';

  @override
  String get inboxEmpty => 'Rien ici pour l’instant.';

  @override
  String get inboxEmptyBody =>
      'Quand quelqu’un vous mentionne, vous assigne une tâche ou commente une tâche que vous suivez, cela apparaît ici.';

  @override
  String get inboxEmptyUnread => 'Rien de non lu.';

  @override
  String get inboxEmptyFiltered => 'Rien de ces types.';

  @override
  String get inboxSomebody => 'Quelqu’un';

  @override
  String inboxWhatMention(String who) {
    return '$who vous a mentionné';
  }

  @override
  String inboxWhatAssigned(String who) {
    return '$who vous a assigné';
  }

  @override
  String inboxWhatComment(String who) {
    return '$who a commenté';
  }

  @override
  String inboxWhatStatus(String who) {
    return '$who l’a déplacée';
  }

  @override
  String inboxWhatOther(String who) {
    return '$who l’a modifiée';
  }

  @override
  String get inboxMovedTo => 'déplacée vers';

  @override
  String get inboxTaskGone => 'Une tâche supprimée';

  @override
  String get inboxNow => 'maintenant';

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
  String get inboxOpenTask => 'Ouvrir la tâche';

  @override
  String get inboxMarkRead => 'Marquer comme lu';

  @override
  String get inboxMarkUnread => 'Marquer comme non lu';

  @override
  String get inboxMarkAllRead => 'Tout marquer comme lu';

  @override
  String inboxMarkedAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments marqués comme lus',
      one: '1 élément marqué comme lu',
    );
    return '$_temp0';
  }

  @override
  String inboxMuteKind(String kind) {
    return 'Ne plus recevoir « $kind » dans la boîte de réception';
  }

  @override
  String inboxMuted(String kind) {
    return '« $kind » n’arrivent plus dans votre boîte de réception';
  }

  @override
  String get inboxKindMention => 'Mentions';

  @override
  String get inboxKindAssigned => 'Assignations';

  @override
  String get inboxKindComment => 'Commentaires';

  @override
  String get inboxKindStatus => 'Changements de statut';

  @override
  String get inboxKindMentionHelp =>
      'Quelqu’un écrit @vous dans un commentaire ou une description.';

  @override
  String get inboxKindAssignedHelp => 'Une tâche vous est assignée.';

  @override
  String get inboxKindCommentHelp =>
      'Quelqu’un commente une tâche qui vous est assignée ou que vous avez en favori.';

  @override
  String get inboxKindStatusHelp =>
      'Une tâche qui vous est assignée passe à un autre statut.';

  @override
  String get inboxKindsTitle => 'Boîte de réception';

  @override
  String get inboxKindsSubtitle =>
      'Ce qui crée un élément dans votre boîte de réception, sur tous vos appareils.';

  @override
  String get inboxKindsInfo =>
      'Enregistré sur le serveur, comme dans Paramètres, Boîte de réception de l’application web. Désactivé, un type ne crée aucun élément ; ceux déjà présents restent. Vos propres modifications n’apparaissent jamais.';

  @override
  String get inboxSummaryOverdue => 'En retard';

  @override
  String get inboxSummaryDueToday => 'Échéance aujourd’hui';

  @override
  String get inboxSummaryOpen => 'Ouvertes';

  @override
  String get inboxSummaryDoneWeek => 'Terminées en 7 jours';

  @override
  String inboxCategory(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'todo': 'À faire',
      'inProgress': 'En cours',
      'blocked': 'Bloquée',
      'waiting': 'En attente',
      'other': 'Autre',
    });
    return '$_temp0';
  }

  @override
  String get inboxChannelsTitle => 'Canaux';

  @override
  String get inboxChannelsSubtitle =>
      'Recevez votre boîte de réception sur Slack, Discord, ntfy ou n’importe quelle URL.';

  @override
  String get inboxChannelsInfo =>
      'Un canal n’appartient qu’à vous : il ne reçoit que vos éléments, des types qu’il liste, et rien d’un type que vous avez désactivé plus haut. Le serveur envoie chaque élément dès qu’il est créé.';

  @override
  String get inboxChannelsEmpty => 'Aucun canal pour l’instant.';

  @override
  String get inboxChannelAdd => 'Ajouter un canal';

  @override
  String get inboxChannelEdit => 'Modifier le canal';

  @override
  String get inboxChannelSave => 'Enregistrer';

  @override
  String get inboxChannelSaved => 'Canal enregistré';

  @override
  String inboxChannelAdded(String name) {
    return '$name ajouté';
  }

  @override
  String get inboxChannelName => 'Nom';

  @override
  String get inboxChannelNameHint => 'Mon Slack';

  @override
  String get inboxChannelUrl => 'Adresse';

  @override
  String get inboxChannelUrlHelp =>
      'L’URL du webhook ou du topic. Elle doit être en https.';

  @override
  String get inboxChannelFormat => 'Format';

  @override
  String get inboxChannelFormatGeneric => 'JSON signé';

  @override
  String get inboxChannelKinds => 'Types';

  @override
  String get inboxChannelAllKinds => 'Tous les types';

  @override
  String get inboxChannelOff => 'Désactivé';

  @override
  String get inboxChannelSecretTitle => 'Secret de signature';

  @override
  String get inboxChannelSecretBody =>
      'tix signe chaque message JSON signé avec ce secret. Copiez-le maintenant : il ne sera plus affiché.';

  @override
  String get inboxChannelSecretCopy => 'Copier';

  @override
  String get inboxChannelSecretDone => 'Terminé';

  @override
  String get inboxChannelAbout => 'Canal';

  @override
  String get inboxChannelActive => 'Activé';

  @override
  String get inboxChannelActiveHelp => 'Désactivé, le canal ne reçoit rien.';

  @override
  String get inboxChannelTest => 'Envoyer un test';

  @override
  String get inboxChannelTestQueued => 'Message de test en file d’attente';

  @override
  String get inboxChannelDeliveries => 'Envois';

  @override
  String get inboxChannelDeliveriesSubtitle => 'Les plus récents d’abord.';

  @override
  String get inboxChannelNoDeliveries => 'Rien d’envoyé pour l’instant.';

  @override
  String get inboxChannelGone => 'Ce canal n’existe plus.';

  @override
  String get inboxChannelDangerZone => 'Zone de danger';

  @override
  String get inboxChannelDelete => 'Supprimer le canal';

  @override
  String inboxChannelDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get inboxChannelDeleteBody =>
      'Le canal et son historique d’envoi sont supprimés. Action irréversible.';

  @override
  String inboxChannelDeleted(String name) {
    return '$name supprimé';
  }

  @override
  String get inboxDeliveryDelivered => 'envoyé';

  @override
  String get inboxDeliveryFailed => 'échec';

  @override
  String get inboxDeliveryPending => 'en attente';

  @override
  String get inboxDeliveryTest => 'Message de test';

  @override
  String get inboxDeliveryItem => 'Élément de la boîte de réception';

  @override
  String inboxDeliveryAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentatives',
      one: '1 tentative',
    );
    return '$_temp0';
  }

  @override
  String get inboxDeliveryRedeliver => 'Renvoyer';

  @override
  String get inboxDeliveryRequeued => 'Remis en file d’attente';

  @override
  String get liveUpdated => 'Mis à jour';

  @override
  String get liveChangedElsewhere =>
      'Cet élément a été modifié ailleurs. Vos modifications sont conservées.';

  @override
  String liveChangedElsewhereBy(String handle) {
    return '@$handle a modifié cet élément. Vos modifications sont conservées.';
  }

  @override
  String get liveKeepEditing => 'Continuer à modifier';

  @override
  String get liveReload => 'Recharger';

  @override
  String get notifSettingsTitle => 'Notifications';

  @override
  String get notifSettingsSubtitle =>
      'Sur cet appareil, types et canaux de la boîte de réception';

  @override
  String get notifDeviceTitle => 'Sur cet appareil';

  @override
  String get notifDeviceSubtitle => 'Pour l’instance et l’espace actifs.';

  @override
  String get notifDeviceInfo =>
      'Affichées tant que l’application est ouverte ou vient d’être mise en arrière-plan. Une application fermée ne peut pas être prévenue : tix n’a pas encore de service push. Les canaux ci-dessous fonctionnent partout.';

  @override
  String get notifEnabled =>
      'M’avertir des nouveaux éléments de la boîte de réception';

  @override
  String get notifEnabledHelp =>
      'Touchez une notification pour ouvrir la tâche.';

  @override
  String get notifBlocked => 'Les notifications sont bloquées pour tix.';

  @override
  String get notifBlockedHelp =>
      'Autorisez les notifications pour tix dans les paramètres du système, puis réactivez cette option.';

  @override
  String get notifNudge =>
      'Recevez une notification quand un nouvel élément arrive dans votre boîte de réception.';

  @override
  String get notifTurnOn => 'Activer';

  @override
  String get notifNotNow => 'Plus tard';

  @override
  String notifMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres éléments dans la boîte de réception',
      one: '1 autre élément dans la boîte de réception',
    );
    return '$_temp0';
  }

  @override
  String get notifMoreBody => 'Ouvrez la boîte de réception pour les voir.';

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

  @override
  String get paletteThemeOled => 'Thème noir OLED';

  @override
  String get manageTitle => 'Gestion';

  @override
  String manageSubtitle(String tenant) {
    return 'Ce que vous pouvez gérer dans $tenant';
  }

  @override
  String get goManage => 'Aller à la gestion';

  @override
  String get navMore => 'Plus';

  @override
  String get manageEmpty => 'Rien à gérer avec ces identifiants.';

  @override
  String get manageEmptyBody =>
      'Les projets, les workflows, les personnes et l’espace demandent des droits que ce jeton ou ce rôle n’a pas. Demandez-en de plus larges à un administrateur.';

  @override
  String get manageGroupProjects => 'Projets';

  @override
  String get manageGroupWorkflows => 'Workflows';

  @override
  String get manageGroupFields => 'Champs';

  @override
  String get manageGroupPeople => 'Personnes';

  @override
  String get manageGroupAccess => 'Accès';

  @override
  String get manageGroupTenant => 'Espace';

  @override
  String get manageGroupServer => 'Serveur';

  @override
  String get manageProjectsSubtitle =>
      'Créer, renommer, recolorer, archiver et supprimer des projets';

  @override
  String get manageWorkflowsSubtitle =>
      'Les états, les passages entre eux et qui peut les faire';

  @override
  String get manageFieldsSubtitle =>
      'Les champs personnalisés des tâches de chaque projet';

  @override
  String get manageSave => 'Enregistrer';

  @override
  String get manageSaveChanges => 'Enregistrer les modifications';

  @override
  String get manageDelete => 'Supprimer';

  @override
  String get manageClear => 'Effacer';

  @override
  String get manageYes => 'Oui';

  @override
  String get manageNo => 'Non';

  @override
  String get manageDangerZone => 'Zone de danger';

  @override
  String get manageInherited => 'Hérité';

  @override
  String get manageDurationHelp =>
      'Une durée comme 30m ou 4h. Vide pour hériter.';

  @override
  String get manageChanged => 'modifié';

  @override
  String manageTaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches',
      one: '1 tâche',
    );
    return '$_temp0';
  }

  @override
  String get manageDragToReorder => 'Glisser pour réordonner';

  @override
  String get colourNone => 'Sans couleur';

  @override
  String get colourSlate => 'Ardoise';

  @override
  String get colourRed => 'Rouge';

  @override
  String get colourAmber => 'Ambre';

  @override
  String get colourGreen => 'Vert';

  @override
  String get colourTeal => 'Sarcelle';

  @override
  String get colourBlue => 'Bleu';

  @override
  String get colourViolet => 'Violet';

  @override
  String get colourPink => 'Rose';

  @override
  String get colourCustom => 'Couleur personnalisée';

  @override
  String get iconNone => 'Aucune';

  @override
  String get iconText => 'Emoji';

  @override
  String get iconBuiltin => 'Icône';

  @override
  String get iconImage => 'Image';

  @override
  String get iconNoneHelp => 'Les premières lettres du nom la remplacent.';

  @override
  String get iconTextLabel => 'Emoji ou lettres';

  @override
  String get iconTextHelp => 'Un emoji, ou une ou deux lettres.';

  @override
  String get iconImageHelp => 'PNG, JPEG, WebP ou SVG, 64 Ko au plus.';

  @override
  String get iconUpload => 'Choisir une image';

  @override
  String get projectNew => 'Nouveau projet';

  @override
  String get projectCreate => 'Créer le projet';

  @override
  String projectCreated(String name) {
    return '$name a été créé.';
  }

  @override
  String get projectName => 'Nom';

  @override
  String get projectKey => 'Clé';

  @override
  String get projectKeyHelp =>
      'Préfixe de chaque référence de tâche, comme infra-1. Lettres, chiffres, - et _.';

  @override
  String get projectKeyChangeHelp =>
      'La changer renomme toutes les références de tâches ; l’ancienne clé continue de fonctionner.';

  @override
  String get projectDescription => 'Description';

  @override
  String get projectWorkflow => 'Workflow';

  @override
  String get projectWorkflowInfo =>
      'Les états par lesquels passent les tâches du projet. tix refuse le changement tant qu’une tâche est dans un état que le nouveau workflow n’a pas.';

  @override
  String get projectColour => 'Couleur';

  @override
  String get projectIcon => 'Icône';

  @override
  String get projectSettingsTitle => 'Paramètres du projet';

  @override
  String get projectSectionProject => 'Projet';

  @override
  String get projectSectionAppearance => 'Apparence';

  @override
  String get projectSectionClaims => 'Prises en charge';

  @override
  String get projectClaimsInfo =>
      'Combien de temps dure une prise en charge des tâches de ce projet. La valeur du projet l’emporte sur celle du workflow et de l’espace ; la durée maximale ne peut être que plus courte que celle de l’espace.';

  @override
  String get projectLeaseDefault => 'Durée de prise en charge';

  @override
  String get projectLeaseMax => 'Durée maximale';

  @override
  String get projectLeaseMaxHelp =>
      'Une durée comme 24h, sous le plafond de l’espace. Vide pour hériter.';

  @override
  String get projectManageFields => 'Champs personnalisés';

  @override
  String get projectManageFieldsHelp =>
      'Définissez les champs des tâches de ce projet.';

  @override
  String get projectReadOnly =>
      'Vous pouvez voir ces paramètres mais pas les modifier : il faut project:write.';

  @override
  String get projectSaved => 'Projet enregistré.';

  @override
  String get projectRekeyTitle => 'Changer la clé du projet ?';

  @override
  String get projectRekeyBody =>
      'Chaque référence de tâche change avec la clé :';

  @override
  String projectRekeyAlias(String old) {
    return 'Les liens, références et filtres qui utilisent $old continuent de fonctionner : l’ancienne clé reste un alias, et aucun autre projet ne peut la prendre.';
  }

  @override
  String get projectRekeyConfirm => 'Changer la clé';

  @override
  String get projectArchive => 'Archiver le projet';

  @override
  String get projectArchiveHelp =>
      'Le masque des listes et garde ses tâches et son historique. tix ne permet pas de le désarchiver.';

  @override
  String projectArchiveTitle(String name) {
    return 'Archiver $name ?';
  }

  @override
  String get projectArchiveBody =>
      'Le projet quitte les listes par défaut. Ses tâches et son historique restent. tix ne peut pas désarchiver un projet.';

  @override
  String projectArchived(String name) {
    return '$name est archivé.';
  }

  @override
  String get projectArchivedBadge => 'archivé';

  @override
  String get projectIsArchived => 'Ce projet est archivé.';

  @override
  String get projectDelete => 'Supprimer le projet';

  @override
  String get projectDeleteHelp =>
      'Le supprime définitivement. Ses tâches vont dans un autre projet ou disparaissent avec lui.';

  @override
  String projectDeleteTitle(String key) {
    return 'Supprimer $key ?';
  }

  @override
  String get projectDeleteEmpty =>
      'Le projet ne contient aucune tâche. La suppression est définitive.';

  @override
  String projectDeleteHolds(int live, int trashed) {
    String _temp0 = intl.Intl.pluralLogic(
      live,
      locale: localeName,
      other: '$live tâches',
      one: '1 tâche',
    );
    String _temp1 = intl.Intl.pluralLogic(
      trashed,
      locale: localeName,
      other: '$trashed dans la corbeille',
      one: '1 dans la corbeille',
    );
    return 'Il contient $_temp0 et $_temp1. Que faut-il en faire ?';
  }

  @override
  String get projectDeleteMove => 'Les déplacer vers un autre projet';

  @override
  String get projectDeleteNoTarget =>
      'Aucun autre projet actif où les déplacer.';

  @override
  String get projectDeleteTarget => 'Déplacer vers';

  @override
  String get projectDeleteMapping => 'Statut après le déplacement';

  @override
  String get projectDeleteTasks => 'Les supprimer définitivement';

  @override
  String projectDeleteType(String key) {
    return 'Saisissez $key pour confirmer';
  }

  @override
  String get projectDeleteConfirm =>
      'Le projet et ses tâches sont supprimés définitivement.';

  @override
  String projectDeleteMoveConfirm(String target) {
    return 'Les tâches vont dans $target, puis le projet est supprimé définitivement.';
  }

  @override
  String projectDeleted(String key) {
    return '$key est supprimé.';
  }

  @override
  String get fieldsTitle => 'Champs personnalisés';

  @override
  String get fieldProjectsSubtitle =>
      'tix définit les champs par projet. Choisissez-en un.';

  @override
  String get fieldsEmpty => 'Aucun champ personnalisé pour l’instant.';

  @override
  String get fieldsEmptyBody =>
      'Un champ ajoute une valeur de votre choix à chaque tâche du projet, comme un environnement ou un client.';

  @override
  String get fieldsReadOnly =>
      'Vous pouvez voir ces champs mais pas les modifier : il faut project:write.';

  @override
  String get fieldNew => 'Nouveau champ';

  @override
  String fieldEdit(String key) {
    return 'Modifier $key';
  }

  @override
  String get fieldKey => 'Clé';

  @override
  String get fieldKeyHelp =>
      'Le nom du champ dans les tâches et les filtres, comme env.';

  @override
  String get fieldKeyFixed =>
      'La clé nomme le champ ; pour la changer, définissez un nouveau champ.';

  @override
  String get fieldLabel => 'Libellé';

  @override
  String get fieldLabelHelp => 'Ce que les gens voient. Vide affiche la clé.';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldOptions => 'Options';

  @override
  String get fieldOptionsHelp =>
      'Les valeurs permises, séparées par des virgules.';

  @override
  String get fieldDefault => 'Valeur par défaut';

  @override
  String get fieldNoDefault => 'Pas de valeur par défaut';

  @override
  String get fieldPickDefault => 'Choisir une valeur';

  @override
  String get fieldActorHint => 'Un identifiant, comme raj';

  @override
  String fieldDefaultIs(String value) {
    return 'par défaut $value';
  }

  @override
  String get fieldDefaultUnreadable =>
      'Cette valeur ne se lit pas comme le type du champ.';

  @override
  String get fieldRequired => 'Obligatoire';

  @override
  String get fieldRequiredHelp =>
      'Une nouvelle tâche sans valeur est refusée, sauf s’il y a une valeur par défaut.';

  @override
  String fieldSaved(String key) {
    return '$key est enregistré.';
  }

  @override
  String fieldDeleteTitle(String key) {
    return 'Supprimer le champ $key ?';
  }

  @override
  String get fieldDeleteBody => 'Les tâches n’affichent plus ce champ.';

  @override
  String fieldDeleted(String key) {
    return '$key est supprimé.';
  }

  @override
  String get fieldTypeString => 'Texte, une ligne';

  @override
  String get fieldTypeText => 'Texte, plusieurs lignes';

  @override
  String get fieldTypeInt => 'Nombre entier';

  @override
  String get fieldTypeFloat => 'Nombre';

  @override
  String get fieldTypeBool => 'Oui ou non';

  @override
  String get fieldTypeDate => 'Date';

  @override
  String get fieldTypeDatetime => 'Date et heure';

  @override
  String get fieldTypeEnum => 'Choix';

  @override
  String get fieldTypeActor => 'Personne ou agent';

  @override
  String get fieldTypeJson => 'JSON';

  @override
  String get fieldTypeUnknown => 'Inconnu';

  @override
  String get categoryTodo => 'À faire';

  @override
  String get categoryInProgress => 'En cours';

  @override
  String get categoryBlocked => 'Bloqué';

  @override
  String get categoryWaiting => 'En attente';

  @override
  String get categoryDone => 'Terminé';

  @override
  String get categoryCancelled => 'Annulé';

  @override
  String get categoryDerived => 'Selon l’état (tix décide)';

  @override
  String get workflowsTitle => 'Workflows';

  @override
  String get workflowsSubtitle =>
      'Les états que traversent les tâches, et comment';

  @override
  String get workflowsEmpty => 'Aucun workflow.';

  @override
  String get workflowTitle => 'Workflow';

  @override
  String workflowSubtitle(String key) {
    return 'Clé $key';
  }

  @override
  String get workflowBuiltin => 'intégré';

  @override
  String workflowStateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count états',
      one: '1 état',
    );
    return '$_temp0';
  }

  @override
  String get workflowNew => 'Nouveau workflow';

  @override
  String get workflowCreate => 'Créer le workflow';

  @override
  String workflowCreated(String name) {
    return '$name a été créé.';
  }

  @override
  String get workflowKey => 'Clé';

  @override
  String get workflowKeyHelp =>
      'Lettres, chiffres, - et _, en commençant par une lettre.';

  @override
  String get workflowKeyTaken =>
      'Un workflow a déjà cette clé ; l’enregistrer le remplacerait.';

  @override
  String get workflowName => 'Nom';

  @override
  String get workflowStartFrom => 'Partir de';

  @override
  String get workflowMinimal => 'Ouvert et terminé';

  @override
  String workflowCopyOf(String name) {
    return 'Une copie de $name';
  }

  @override
  String get workflowReadOnly =>
      'Vous pouvez voir ce workflow mais pas le modifier : il faut workflow:write.';

  @override
  String get workflowRefused => 'tix a refusé la modification';

  @override
  String get workflowSaved => 'Workflow enregistré.';

  @override
  String get workflowSectionGeneral => 'Workflow';

  @override
  String get workflowInitial => 'État initial';

  @override
  String get workflowInitialHelp => 'Là où commence une nouvelle tâche.';

  @override
  String get workflowDefaultLease => 'Durée de prise en charge';

  @override
  String get workflowSectionStates => 'États';

  @override
  String get workflowStatesHelp =>
      'Faites glisser la poignée pour réordonner. Touchez un état pour le modifier.';

  @override
  String get workflowAddState => 'Ajouter un état';

  @override
  String workflowEditState(String name) {
    return 'Modifier $name';
  }

  @override
  String get workflowStateKey => 'Clé';

  @override
  String get workflowStateKeyHelp =>
      'Ce que contient le statut d’une tâche, comme review.';

  @override
  String get workflowStateKeyRename =>
      'Renommer déplace les tâches de cet état vers la nouvelle clé à l’enregistrement.';

  @override
  String get workflowStateKeyTaken => 'Un autre état a cette clé.';

  @override
  String get workflowStateLabel => 'Libellé';

  @override
  String get workflowStateCategory => 'Catégorie';

  @override
  String get workflowStateCategoryInfo =>
      'Regroupe l’état pour les couleurs, les tableaux et les rapports. Laissée à tix : terminé si final, à faire pour l’état initial, en cours sinon.';

  @override
  String get workflowStateInitial => 'État initial';

  @override
  String get workflowTerminal => 'Final';

  @override
  String get workflowTerminalHelp =>
      'L’atteindre termine la tâche et satisfait ce qui en dépend.';

  @override
  String get workflowRevert => 'Revenir quand la prise en charge expire';

  @override
  String get workflowRevertHelp =>
      'Une tâche prise en charge ici revient en arrière quand sa durée expire.';

  @override
  String get workflowRevertTo => 'Revenir à';

  @override
  String workflowRevertsTo(String state) {
    return 'revient à $state';
  }

  @override
  String get workflowInitialBadge => 'initial';

  @override
  String get workflowSectionTransitions => 'Transitions';

  @override
  String get workflowTransitionsHelp =>
      'Touchez un état pour autoriser le passage. Le bouton de règles d’un passage choisi exige un commentaire ou un droit.';

  @override
  String workflowCanMoveTo(String name) {
    return 'Depuis $name, une tâche peut aller vers';
  }

  @override
  String get workflowNoMoves => 'Aucun passage ne quitte cet état.';

  @override
  String get workflowMoveRules => 'Règles de ce passage';

  @override
  String workflowRulesTitle(String from, String to) {
    return '$from vers $to';
  }

  @override
  String get workflowNeedsComment => 'Exige un commentaire';

  @override
  String get workflowNeedsCommentHelp =>
      'Le passage est refusé s’il n’a pas de commentaire.';

  @override
  String workflowNeedsScope(String scope) {
    return 'Exige $scope';
  }

  @override
  String get workflowRequiredScope => 'Droit requis';

  @override
  String get workflowRequiredScopeHelp =>
      'Seul quelqu’un qui le détient peut faire ce passage.';

  @override
  String get workflowNoScope => 'Aucun';

  @override
  String get workflowSectionRoutes => 'Parcours';

  @override
  String get workflowRoutesInfo =>
      'Combien de passages séparent chaque état de l’état initial. Aller vers un état plus éloigné traverse les états intermédiaires, une transition à la fois.';

  @override
  String workflowSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
    );
    return '$_temp0';
  }

  @override
  String get workflowUnreachable => 'Aucun parcours n’y mène';

  @override
  String get workflowSectionRemoved => 'États supprimés';

  @override
  String get workflowRemovedHelp =>
      'Les tâches encore dans un état supprimé doivent aller quelque part, sinon tix refuse l’enregistrement.';

  @override
  String workflowMigrate(String state) {
    return 'Déplacer les tâches de $state vers';
  }

  @override
  String get workflowMigrateNone =>
      'Nulle part (refusé s’il contient des tâches)';

  @override
  String get workflowDelete => 'Supprimer le workflow';

  @override
  String get workflowDeleteHelp =>
      'Seul un workflow qu’aucun projet n’utilise peut être supprimé.';

  @override
  String workflowDeleteTitle(String key) {
    return 'Supprimer $key ?';
  }

  @override
  String get workflowDeleteBody => 'Le workflow est supprimé définitivement.';

  @override
  String workflowDeleted(String key) {
    return '$key est supprimé.';
  }

  @override
  String get manageUsersTitle => 'Utilisateurs';

  @override
  String get manageUsersSubtitle =>
      'Les personnes de l’espace, leurs rôles et les invitations';

  @override
  String get manageTokensTitle => 'Jetons d’API';

  @override
  String get manageTokensSubtitle =>
      'Les jetons des agents et des scripts, et ce que chacun peut faire';

  @override
  String get manageTransferTitle => 'Import et export';

  @override
  String get manageTransferSubtitle =>
      'Faire entrer et sortir des tâches et des espaces entiers';

  @override
  String get localInstanceAdvancedBody =>
      'Utilisez une base de données là où elle se trouve, par exemple dans un dossier synchronisé par Nextcloud, Syncthing ou iCloud Drive, plutôt qu’une copie conservée dans l’application.';

  @override
  String get localInstanceAdvancedTitle => 'Avancé : ouvrir sur place';

  @override
  String get localInstanceBrowseCreate => 'Créer ici';

  @override
  String get localInstanceBrowseEmpty =>
      'Aucun dossier ni base de données ici.';

  @override
  String get localInstanceBrowseNewLabel =>
      'Nouvelle base de données dans ce dossier';

  @override
  String get localInstanceBrowseTitle => 'Choisir une base de données';

  @override
  String get localInstanceBrowseUp => 'Dossier parent';

  @override
  String localInstanceConflicts(String names) {
    return 'Copies de conflit de synchronisation à côté de ce fichier : $names. Vérifiez laquelle contient votre travail le plus récent avant de continuer.';
  }

  @override
  String get localInstanceDesktopIntro =>
      'Créez une nouvelle base de données tix. Pour en utiliser une existante, ouvrez-la sur place ci-dessous.';

  @override
  String get localInstanceEngineResting => 'Arrêté, redémarre au besoin';

  @override
  String localInstanceEngineRunning(String address) {
    return 'En cours sur $address';
  }

  @override
  String get localInstanceEngineStarting => 'Démarrage';

  @override
  String get localInstanceEngineStop => 'Arrêter';

  @override
  String get localInstanceEngineStopped => 'Arrêté';

  @override
  String get localInstanceErrorAccess =>
      'tix n’a plus accès à ce fichier. Autorisez de nouveau l’accès, ou supprimez l’instance et rouvrez le fichier.';

  @override
  String get localInstanceErrorFolder =>
      'tix ne peut pas créer de fichiers dans ce dossier, alors que SQLite doit en garder deux à côté de la base de données. Choisissez un dossier où l’écriture est permise.';

  @override
  String get localInstanceErrorLock =>
      'Ce fichier ne peut pas être verrouillé, SQLite ne peut donc pas le protéger ici. Il se trouve peut-être chez un fournisseur cloud qui ne propose pas de vrais fichiers.';

  @override
  String get localInstanceErrorNotDatabase =>
      'Ce fichier n’est pas une base de données tix sur cet appareil. S’il se trouve dans un dossier cloud, il n’est peut-être pas encore téléchargé.';

  @override
  String get localInstanceErrorNotDownloaded =>
      'Ce fichier n’est pas encore téléchargé sur cet appareil. Ouvrez-le dans l’app Fichiers pour le télécharger, puis réessayez.';

  @override
  String get localInstanceIdleHelp =>
      'Un moteur qui n’a rien servi pendant cette durée s’arrête pour économiser la batterie, et redémarre dès que l’application en a besoin.';

  @override
  String get localInstanceIdleLabel => 'Arrêter un moteur inactif après';

  @override
  String localInstanceIdleMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get localInstanceIdleNever => 'Jamais';

  @override
  String get localInstanceIdleTitle => 'Bases de données locales';

  @override
  String get localInstanceImportInstead => 'Importer une copie';

  @override
  String get localInstanceInPlaceNote => 'Utilisée sur place';

  @override
  String get localInstanceOpenInPlace => 'Ouvrir sur place…';

  @override
  String get localInstancePermissionBody =>
      'Pour ouvrir une base de données là où elle se trouve, Android doit accorder à tix « l’accès à tous les fichiers ». tix ne lit et n’écrit que la base de données que vous choisissez et les fichiers que SQLite garde à côté.';

  @override
  String get localInstancePermissionContinue => 'Continuer';

  @override
  String get localInstancePermissionRefused =>
      'L’accès à tous les fichiers n’a pas été accordé : tix ne peut donc pas ouvrir de fichiers sur place. Vous pouvez importer une copie à la place.';

  @override
  String get localInstancePermissionTitle => 'Autoriser l’accès à vos fichiers';

  @override
  String get localInstanceSyncWarning =>
      'Une base de données synchronisée ne doit être ouverte que sur un appareil à la fois. Fermez d’abord tix sur vos autres appareils et laissez la synchronisation se terminer. tix arrête la base de données dès qu’il passe en arrière-plan, pour que le client de synchronisation trouve toujours un fichier complet.';

  @override
  String get localInstanceWalLeftOver =>
      'Un journal d’écriture anticipée (write-ahead log) se trouvait déjà à côté de ce fichier. Un autre programme l’a peut-être ouvert, ou un client de synchronisation en a copié un depuis un autre appareil.';

  @override
  String get widgetMyWork => 'Mon travail';

  @override
  String get widgetInbox => 'Boîte de réception';

  @override
  String get widgetQuickAdd => 'Ajout rapide';

  @override
  String get widgetAddTask => 'Ajouter une tâche';

  @override
  String get widgetNothingDue => 'Rien ne vous est assigné';

  @override
  String get widgetAllRead => 'Tout est lu';

  @override
  String get widgetNoOpenTasks => 'Aucune tâche ouverte';

  @override
  String get widgetUpdated => 'Mis à jour';

  @override
  String get widgetOpenApp => 'Ouvrez tix pour charger ce widget';

  @override
  String get widgetLocalStale => 'Se met à jour quand tix est ouvert';

  @override
  String get widgetOverdue => 'En retard';

  @override
  String get widgetToday => 'Aujourd\'hui';

  @override
  String get widgetComplete => 'Terminer';

  @override
  String get widgetProjectMissing => 'Absent de ce contexte';

  @override
  String get widgetSignedOut => 'Connectez-vous à tix';

  @override
  String widgetMore(int count) {
    return '+$count de plus';
  }

  @override
  String widgetUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count non lus',
      one: '1 non lu',
      zero: 'Rien de non lu',
    );
    return '$_temp0';
  }

  @override
  String get settingsWidgets => 'Widgets de l\'écran d\'accueil';

  @override
  String get settingsWidgetLockCounts =>
      'Seulement les nombres sur l\'écran verrouillé';

  @override
  String get settingsWidgetLockCountsHelp =>
      'Sur l\'écran verrouillé, les widgets indiquent combien, pas quoi.';

  @override
  String get settingsWidgetsHelp =>
      'Ajoutez les widgets tix depuis votre écran d\'accueil. Ils montrent ce que l\'application a lu en dernier, et une coche attend l\'application si le serveur est injoignable.';

  @override
  String get widgetOpenUpdate => 'Ouvrez tix pour mettre à jour';

  @override
  String get widgetPickProject => 'Choisissez un projet';

  @override
  String liveStatusLabel(String state) {
    return 'Mises à jour en direct : $state';
  }

  @override
  String get liveStatusLive => 'En direct';

  @override
  String get liveStatusLiveInfo =>
      'Les modifications faites ailleurs apparaissent ici dès qu’elles ont lieu.';

  @override
  String get liveStatusConnecting => 'Connexion';

  @override
  String get liveStatusConnectingInfo =>
      'Connexion aux mises à jour en direct. Les modifications apparaîtront une fois la connexion établie.';

  @override
  String get liveStatusPolling => 'Interrogation';

  @override
  String get liveStatusPollingInfo =>
      'La connexion en direct échoue sans cesse sur ce réseau, les mises à jour passent donc par HTTP. Elles peuvent arriver quelques secondes plus tard.';

  @override
  String get liveStatusRefreshing => 'Actualisation';

  @override
  String liveStatusRefreshingInfo(int seconds) {
    return 'Les mises à jour en direct ne passent pas et ce serveur est trop ancien pour être interrogé, l’écran se recharge donc toutes les $seconds secondes.';
  }

  @override
  String get liveStatusOffline => 'Hors ligne';

  @override
  String get liveStatusOfflineInfo =>
      'Le serveur est injoignable. L’application réessaie et rattrapera son retard dès son retour.';

  @override
  String get liveStatusUnavailable => 'Indisponible';

  @override
  String get liveStatusUnavailableInfo =>
      'Cette connexion ne peut pas suivre les mises à jour en direct (il lui faut la portée event:subscribe). Tirez vers le bas pour actualiser.';

  @override
  String get copyToClipboard => 'Copier';

  @override
  String get copiedToClipboard => 'Copié.';

  @override
  String get secretShare => 'Partager';

  @override
  String get secretDone => 'Je l’ai conservé';

  @override
  String get roleViewer => 'lecteur';

  @override
  String get roleMember => 'membre';

  @override
  String get roleAdmin => 'administrateur';

  @override
  String get roleViewerHelp => 'Lit les tâches, les projets et les workflows.';

  @override
  String get roleMemberHelp =>
      'Crée, modifie, prend et déplace aussi des tâches, commente et exporte.';

  @override
  String get roleAdminHelp => 'Peut tout faire dans cet espace.';

  @override
  String get peopleTitle => 'Utilisateurs';

  @override
  String get peopleAdd => 'Ajouter un utilisateur';

  @override
  String peopleActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actifs',
      one: '1 actif',
    );
    return '$_temp0';
  }

  @override
  String peopleDisabledCount(int count) {
    return '$count désactivés';
  }

  @override
  String get peopleAddMember => 'Ajouter un membre';

  @override
  String get peopleAddMemberButton => 'Ajouter';

  @override
  String get peopleAddMemberHelp =>
      'Donnez un rôle dans cet espace à un agent ou un compte existant.';

  @override
  String get peopleNoActors =>
      'Tous les acteurs appartiennent déjà à cet espace.';

  @override
  String get peopleAgent => 'agent';

  @override
  String get peoplePerson => 'personne';

  @override
  String get peopleEmpty => 'Aucun utilisateur pour l’instant.';

  @override
  String get peopleYou => 'vous';

  @override
  String get peopleNoRole => 'sans rôle';

  @override
  String get peopleDisabled => 'désactivé';

  @override
  String get peopleInvites => 'Invitations en attente';

  @override
  String get peopleInvitesInfo =>
      'Liens émis et pas encore utilisés. Réémettre arrête l’ancien lien et vous en donne un nouveau à envoyer ; révoquer l’arrête.';

  @override
  String get peopleInvited => 'invité';

  @override
  String peopleInvitedBy(String handle) {
    return 'invité par $handle';
  }

  @override
  String get peopleInviteExpired => 'expirée';

  @override
  String peopleInviteExpires(String day) {
    return 'expire le $day';
  }

  @override
  String get peopleReissue => 'Réémettre';

  @override
  String get peopleRevoke => 'Révoquer';

  @override
  String peopleRevokeInviteTitle(String email) {
    return 'Révoquer l’invitation de $email ?';
  }

  @override
  String get peopleRevokeInviteBody =>
      'Le lien cesse de fonctionner immédiatement. Le compte reste, sans mot de passe, jusqu’à ce que vous le supprimiez ou l’invitiez à nouveau.';

  @override
  String peopleInviteRevoked(String email) {
    return 'Invitation de $email révoquée';
  }

  @override
  String get peopleSignInMode => 'Comment ils se connectent';

  @override
  String get peopleSignInModeInfo =>
      'Un lien d’invitation permet à la personne de choisir son propre mot de passe. Il fonctionne une fois et expire ; tix n’envoie pas d’e-mail, c’est à vous de transmettre le lien.';

  @override
  String get peopleModeInvite => 'Lien d’invitation';

  @override
  String get peopleModePassword => 'Définir un mot de passe';

  @override
  String get peopleDisplayName => 'Nom affiché';

  @override
  String get peopleDisplayNameHelp => 'Vide, l’e-mail est affiché à la place.';

  @override
  String get peopleRole => 'Rôle';

  @override
  String get peopleLinkExpires => 'Le lien expire après';

  @override
  String peopleDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get peopleYear => '1 an';

  @override
  String get peopleInviteHelp =>
      'Vous obtenez un lien à leur envoyer. Il fonctionne une fois et leur permet de choisir leur mot de passe.';

  @override
  String get peopleRequireChangeFirst =>
      'Exiger un changement de mot de passe à la première connexion';

  @override
  String get peopleCreateInvite => 'Créer le lien d’invitation';

  @override
  String get peopleCreateUser => 'Créer l’utilisateur';

  @override
  String peopleCreated(String email) {
    return '$email créé';
  }

  @override
  String get peopleInviteLink => 'Lien d’invitation';

  @override
  String peopleSendLink(String email) {
    return 'Envoyez ce lien à $email';
  }

  @override
  String get peopleLinkOnce =>
      'Il fonctionne une fois. tix n’envoie pas d’e-mail, et le lien ne sera plus affiché.';

  @override
  String peopleLinkOnceUntil(String day) {
    return 'Il fonctionne une fois et expire le $day. tix n’envoie pas d’e-mail, et le lien ne sera plus affiché.';
  }

  @override
  String get peopleRename => 'Changer le nom affiché';

  @override
  String get peopleNoName => 'Non défini';

  @override
  String get peopleChangeRole => 'Changer le rôle';

  @override
  String get peopleSignIn => 'Se connecte avec';

  @override
  String peopleSso(String provider) {
    return 'Authentification unique ($provider)';
  }

  @override
  String get peoplePasswordSignIn => 'Un mot de passe';

  @override
  String get peopleSecondFactor => 'Second facteur';

  @override
  String get peopleTotpOn => 'Configuré';

  @override
  String get peopleTotpOff => 'Aucun';

  @override
  String get peopleCreatedAt => 'Créé';

  @override
  String get peopleAccess => 'Accès';

  @override
  String get peopleDisabledSwitch => 'Désactivé';

  @override
  String get peopleDisabledHelp =>
      'Un compte désactivé ne peut pas se connecter : ses sessions se terminent et ses jetons d’API sont révoqués immédiatement. Le réactiver ne rend pas les jetons.';

  @override
  String peopleDisabledToast(String name) {
    return '$name désactivé';
  }

  @override
  String peopleEnabledToast(String name) {
    return '$name peut de nouveau se connecter';
  }

  @override
  String get peopleRequireChange =>
      'Demander un changement de mot de passe à la prochaine connexion';

  @override
  String get peopleRequireChangeHelp =>
      'Leur prochaine connexion par mot de passe s’arrête sur une page qui en demande un nouveau. Les sessions ouvertes et les jetons d’API ne sont pas touchés.';

  @override
  String get peopleSaved => 'Enregistré';

  @override
  String get peopleSave => 'Enregistrer';

  @override
  String peopleRoleChanged(String name, String role) {
    return '$name est maintenant $role';
  }

  @override
  String get peopleDangerZone => 'Zone dangereuse';

  @override
  String get peopleRemoveMember => 'Retirer de cet espace';

  @override
  String get peopleRemoveMemberHelp =>
      'Met fin à l’appartenance et garde le compte.';

  @override
  String get peopleRemoveMemberButton => 'Retirer';

  @override
  String peopleRemoveMemberTitle(String name) {
    return 'Retirer $name de cet espace ?';
  }

  @override
  String get peopleRemoveMemberBody =>
      'Cette personne cesse d’agir ici immédiatement. Le compte reste et peut recevoir un rôle à nouveau.';

  @override
  String peopleMemberRemoved(String name) {
    return '$name retiré de cet espace';
  }

  @override
  String peopleDelete(String name) {
    return 'Supprimer $name';
  }

  @override
  String get peopleDeleteHelp =>
      'La suppression retire le compte et son appartenance. La désactivation est en général ce que vous voulez, et elle est réversible.';

  @override
  String get peopleDeleteButton => 'Supprimer';

  @override
  String peopleDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get peopleDeleteBody =>
      'La suppression retire le compte et son appartenance. C’est irréversible.';

  @override
  String peopleDeleted(String name) {
    return '$name supprimé';
  }

  @override
  String get tokensTitle => 'Jetons d’API';

  @override
  String get tokensMine => 'Mes jetons d’API';

  @override
  String get tokensIssue => 'Émettre un jeton';

  @override
  String get tokensIssueButton => 'Émettre';

  @override
  String get tokensWholeTenant => 'Tous les jetons de cet espace';

  @override
  String get tokensOwn => 'Vos jetons';

  @override
  String get tokensWholeNote =>
      'Vous avez tenant:admin, cette liste montre donc tous les jetons de l’espace et à qui ils appartiennent. Révoquer celui de quelqu’un d’autre est consigné comme tel.';

  @override
  String get tokensIntro =>
      'Un jeton est l’identifiant qu’un script, la CLI ou un agent présente au lieu de se connecter. Il porte ses propres portées, et sa valeur n’est affichée qu’une fois, à l’émission.';

  @override
  String get tokensEmpty => 'Aucun jeton.';

  @override
  String get tokensActive => 'actif';

  @override
  String get tokensExpired => 'expiré';

  @override
  String get tokensRevoked => 'révoqué';

  @override
  String get tokensRevoke => 'Révoquer';

  @override
  String tokensOwner(String name) {
    return 'Propriétaire : $name';
  }

  @override
  String tokensOwnerYou(String name) {
    return 'Propriétaire : $name (vous)';
  }

  @override
  String tokensCreated(String day) {
    return 'Créé le $day';
  }

  @override
  String tokensExpires(String day) {
    return 'Expire le $day';
  }

  @override
  String get tokensNeverExpires => 'N’expire jamais';

  @override
  String get tokensNotUsed => 'Pas encore utilisé';

  @override
  String tokensLastUsed(String when) {
    return 'Dernière utilisation $when';
  }

  @override
  String tokensRevokeTitle(String name) {
    return 'Révoquer $name ?';
  }

  @override
  String get tokensRevokeBody =>
      'Ce qui détient ce jeton cesse immédiatement de s’authentifier. C’est irréversible, et la valeur ne peut pas être récupérée.';

  @override
  String tokensRevokeOther(String name) {
    return 'Ce jeton appartient à $name, pas à vous, et le journal indiquera que vous avez mis fin au jeton de quelqu’un d’autre.';
  }

  @override
  String tokensRevokeNamed(String name) {
    return 'Révoquer $name';
  }

  @override
  String tokensRevokedToast(String name) {
    return '$name révoqué';
  }

  @override
  String get tokensName => 'Nom';

  @override
  String get tokensNameHelp =>
      'Ce qui vous permettra de le choisir au moment de le révoquer, par exemple ci ou laptop. Deux jetons actifs ne peuvent pas porter le même nom.';

  @override
  String get tokensScopes => 'Portées';

  @override
  String get tokensNotHeld =>
      'Vous n’avez pas cette portée, vous ne pouvez donc pas l’accorder.';

  @override
  String get tokensPresetAgent => 'Agent';

  @override
  String get tokensPresetAgentNote =>
      'Lire, créer et modifier des tâches, les prendre, les déplacer et commenter.';

  @override
  String get tokensPresetRead => 'Lecture seule';

  @override
  String get tokensPresetReadNote =>
      'Lire les tâches, les projets et les workflows, et suivre le flux d’événements.';

  @override
  String get tokensExpiry => 'Expire';

  @override
  String get tokensExpiryInfo =>
      'Une expiration est le seul moyen de limiter les dégâts d’un jeton qui fuit sans que personne ne le remarque. Préférez la durée la plus courte qui suffit.';

  @override
  String get tokensNever => 'Jamais';

  @override
  String tokensIssuedTitle(String name) {
    return 'Jeton $name émis';
  }

  @override
  String get tokensValue => 'Copiez ce jeton maintenant';

  @override
  String get tokensValueWarning =>
      'Gardez-le en lieu sûr. Il ne sera plus affiché, et rien ne pourra le montrer plus tard.';

  @override
  String get scopeAll =>
      'Tout sauf l’administration globale et l’historique du compte. Uniquement pour un identifiant auquel vous faites confiance comme à vous-même.';

  @override
  String get scopeGroupTasks => 'Tâches';

  @override
  String get scopeGroupProjects => 'Projets';

  @override
  String get scopeGroupWorkflows => 'Workflows';

  @override
  String get scopeGroupComments => 'Commentaires et artefacts';

  @override
  String get scopeGroupEvents => 'Événements';

  @override
  String get scopeGroupAdmin => 'Administration';

  @override
  String get scopeGroupAccount => 'Votre compte';

  @override
  String get scopeTaskRead =>
      'Lire les tâches, leurs commentaires et leur historique.';

  @override
  String get scopeTaskWrite => 'Créer et modifier des tâches.';

  @override
  String get scopeTaskTransition =>
      'Faire passer une tâche d’un état à un autre.';

  @override
  String get scopeTaskClaim =>
      'Prendre des tâches, renouveler et libérer le bail.';

  @override
  String get scopeTaskDelete =>
      'Supprimer des tâches et les restaurer depuis la corbeille.';

  @override
  String get scopeTaskReclaim => 'Mettre fin au bail d’un autre exécutant.';

  @override
  String get scopeProjectRead => 'Lire les projets.';

  @override
  String get scopeProjectWrite => 'Créer et modifier des projets.';

  @override
  String get scopeWorkflowRead => 'Lire les workflows.';

  @override
  String get scopeWorkflowWrite => 'Créer et modifier des workflows.';

  @override
  String get scopeCommentWrite => 'Commenter les tâches.';

  @override
  String get scopeArtifactWrite => 'Joindre des artefacts aux tâches.';

  @override
  String get scopeEventSubscribe => 'Suivre le flux d’événements en direct.';

  @override
  String get scopeUserAdmin => 'Créer, modifier et supprimer des utilisateurs.';

  @override
  String get scopeTotpAdmin =>
      'Effacer le second facteur d’une autre personne.';

  @override
  String get scopeTokenAdmin => 'Émettre et révoquer des jetons d’API.';

  @override
  String get scopeWebhookAdmin => 'Gérer les webhooks sortants.';

  @override
  String get scopeTenantAdmin => 'Gérer l’espace, ses membres et ses domaines.';

  @override
  String get scopeSyncAdmin =>
      'Gérer et lancer des imports depuis d’autres outils de suivi.';

  @override
  String get scopeAuditRead => 'Lire le journal d’audit.';

  @override
  String get scopeExport =>
      'Exporter des tâches et un instantané de tout l’espace.';

  @override
  String get scopeImport =>
      'Importer des tâches et des instantanés dans l’espace.';

  @override
  String get scopeGlobalAdmin =>
      'Administrer tous les espaces de ce serveur. Seul le jeton d’un administrateur global peut la porter.';

  @override
  String get scopeAccountRead =>
      'Lire l’historique de votre propre compte, qui nomme chaque espace auquel vous appartenez. Seul un jeton pour votre propre compte peut la porter.';

  @override
  String get accountTitle => 'Votre compte';

  @override
  String get accountKind => 'Connecté en tant que';

  @override
  String get accountKindToken => 'Un jeton d’API';

  @override
  String get accountKindAgent => 'Un agent';

  @override
  String get accountKindPerson => 'Une personne';

  @override
  String get accountGlobalAdmin => 'administrateur global';

  @override
  String get accountGlobalAdminYes =>
      'Administre tous les espaces de ce serveur';

  @override
  String get accountMemberships => 'Vos espaces';

  @override
  String get accountMembershipsHelp =>
      'Chaque espace auquel ce compte appartient, avec son rôle.';

  @override
  String get accountCurrent => 'actuel';

  @override
  String get accountHistory => 'Historique du compte';

  @override
  String get accountHistoryHelp =>
      'Chaque changement de votre mot de passe, second facteur et appartenances, dans chaque espace. Seuls vous et les administrateurs globaux pouvez le lire.';

  @override
  String get accountHistoryEmpty => 'Rien n’a encore changé.';

  @override
  String get accountHistoryNotReadable =>
      'Ce jeton ne peut pas lire l’historique de votre compte : il faut la portée account:read, que seul un jeton émis pour votre propre compte porte.';

  @override
  String accountBy(String email) {
    return 'par $email';
  }

  @override
  String get accountBySystem => 'par le système';

  @override
  String get calendarTitle => 'Flux de calendrier';

  @override
  String get calendarLead => 'Vos échéances dans Google, Apple ou Outlook';

  @override
  String get calendarUnavailable => 'Rien à gérer ici';

  @override
  String get calendarUnavailableBody =>
      'Un flux de calendrier lit les tâches en votre nom, et cet identifiant ne peut pas lire les tâches.';

  @override
  String get calendarCreate => 'Créer le flux';

  @override
  String get calendarNone => 'Aucun flux de calendrier';

  @override
  String get calendarNoneBody =>
      'Une adresse privée à laquelle votre calendrier s’abonne, pour voir vos échéances à côté du reste de votre semaine.';

  @override
  String get calendarFeed => 'Adresse du flux';

  @override
  String get calendarFeedInfo =>
      'Chaque tâche avec une échéance est un événement d’une journée qui renvoie ici. Quiconque détient l’adresse peut lire ce qu’elle liste : traitez-la comme un mot de passe. Seule une empreinte est conservée, elle ne peut donc pas être réaffichée.';

  @override
  String get calendarActive => 'Actif';

  @override
  String calendarCreatedOn(String day) {
    return 'Créé le $day. L’adresse a été affichée une fois ; faites-la tourner pour en obtenir une nouvelle.';
  }

  @override
  String get calendarShownOnce =>
      'L’adresse a été affichée une fois ; faites-la tourner pour en obtenir une nouvelle.';

  @override
  String get calendarFilter => 'Filtre du flux';

  @override
  String get calendarFilterDefault =>
      'Les tâches qui vous sont assignées et ne sont pas terminées';

  @override
  String get calendarFilterHint => 'project:infra tag:ops';

  @override
  String get calendarFilterHelp =>
      'Le langage de filtre de la liste des tâches. Vide signifie les vôtres, non terminées. Seules les tâches avec une échéance sont listées.';

  @override
  String get calendarEditFilter => 'Changer le filtre';

  @override
  String get calendarSaveFilter => 'Enregistrer le filtre';

  @override
  String get calendarFilterSaved => 'Filtre du flux enregistré';

  @override
  String get calendarRotate => 'Faire tourner l’adresse';

  @override
  String get calendarRotateHelp =>
      'Une nouvelle adresse avec le même filtre ; l’ancienne s’arrête immédiatement.';

  @override
  String get calendarRotateButton => 'Faire tourner';

  @override
  String get calendarRevoke => 'Révoquer le flux';

  @override
  String get calendarRevokeHelp =>
      'L’adresse cesse de répondre. Les calendriers abonnés gardent ce qu’ils ont récupéré en dernier.';

  @override
  String get calendarRevokeButton => 'Révoquer';

  @override
  String get calendarRevokeTitle => 'Révoquer le flux de calendrier ?';

  @override
  String get calendarRevokeBody =>
      'L’adresse s’arrête immédiatement. Supprimez aussi l’abonnement dans votre application de calendrier.';

  @override
  String get calendarRevoked => 'Flux de calendrier révoqué';

  @override
  String get calendarAddress => 'Abonnez-vous à cette adresse';

  @override
  String get calendarOnce =>
      'Ajoutez-la dans votre application de calendrier. Elle ne sera plus affichée, copiez-la maintenant.';

  @override
  String get calendarRotatedOnce =>
      'Cette adresse remplace l’ancienne, qui s’est arrêtée. Réabonnez-vous partout où l’ancienne était utilisée. Elle ne sera plus affichée.';

  @override
  String calendarLists(String filter) {
    return 'Liste : $filter';
  }

  @override
  String get calendarListsDefault =>
      'Liste les tâches qui vous sont assignées et ne sont pas terminées.';

  @override
  String get calendarHowGoogle =>
      'Google Agenda : Autres agendas, puis À partir de l’URL, et collez l’adresse.';

  @override
  String get calendarHowApple =>
      'Calendrier d’Apple : Fichier, puis Nouvel abonnement à un calendrier, ou utilisez S’abonner sur cet appareil.';

  @override
  String get calendarHowOutlook =>
      'Outlook : Ajouter un calendrier, puis S’abonner à partir du web, et collez l’adresse.';

  @override
  String get calendarSubscribeHere => 'S’abonner sur cet appareil';

  @override
  String get transferTitle => 'Export et import';

  @override
  String get transferNoProjects =>
      'Créez un projet avant d’exporter ou d’importer des tâches.';

  @override
  String get transferExportTitle => 'Exporter des tâches';

  @override
  String get transferExportHelp =>
      'Les tâches d’un projet, ou celles qu’un filtre retient, sous forme de fichier.';

  @override
  String get transferQuery => 'Filtre';

  @override
  String get transferQueryHelp =>
      'Le langage de filtre de la liste des tâches. Vide exporte toutes les tâches.';

  @override
  String get transferFormat => 'Format';

  @override
  String get transferFormatCsv => 'CSV, pour les tableurs';

  @override
  String get transferFormatNdjson => 'NDJSON, une tâche par ligne';

  @override
  String get transferFormatMarkdown => 'Tableau Markdown';

  @override
  String get transferColumns => 'Colonnes';

  @override
  String get transferDates => 'Dates';

  @override
  String get transferDatesIso => 'Date et heure (ISO)';

  @override
  String get transferDatesDay => 'Jour seulement';

  @override
  String get transferDelimiter => 'Séparateur';

  @override
  String get transferDelimiterComma => 'Virgule';

  @override
  String get transferDelimiterSemicolon => 'Point-virgule';

  @override
  String get transferDelimiterTab => 'Tabulation';

  @override
  String get transferDelimiterBar => 'Barre verticale';

  @override
  String get transferFinished => 'Inclure les tâches terminées';

  @override
  String get transferSubtasks => 'Inclure les sous-tâches';

  @override
  String get transferTrashed => 'Inclure les tâches de la corbeille';

  @override
  String get transferExportButton => 'Exporter';

  @override
  String transferExported(String name) {
    return '$name enregistré';
  }

  @override
  String get transferSnapshotTitle => 'Instantané';

  @override
  String get transferSnapshotHelp =>
      'Tout le contenu de cet espace dans un fichier NDJSON, que tix peut importer ailleurs.';

  @override
  String get transferSnapshotComments => 'Inclure les commentaires';

  @override
  String get transferSnapshotButton => 'Exporter l’instantané';

  @override
  String get transferImportTitle => 'Importer des tâches';

  @override
  String get transferImportHelp =>
      'Un fichier de tâches CSV, JSON ou NDJSON, y compris ceux de Jira, GitHub, Trello et Linear. Vous voyez ce qui se passerait avant que rien ne change.';

  @override
  String get transferPick => 'Choisir un fichier';

  @override
  String transferDryRun(
    int rows,
    int created,
    int updated,
    int skipped,
    int failed,
  ) {
    return '$rows lignes : $created à créer, $updated à mettre à jour, $skipped ignorées, $failed en échec.';
  }

  @override
  String transferImportError(int line, String message) {
    return 'Ligne $line : $message';
  }

  @override
  String transferImportButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importer $count tâches',
      one: 'Importer 1 tâche',
    );
    return '$_temp0';
  }

  @override
  String transferImported(int created, int updated) {
    return 'Importé : $created créées, $updated mises à jour';
  }

  @override
  String get columnRef => 'Référence';

  @override
  String get columnTitle => 'Titre';

  @override
  String get columnParent => 'Parent';

  @override
  String get columnDependsOn => 'Dépend de';

  @override
  String get columnRepeat => 'Répétition';

  @override
  String get columnCreated => 'Créée';

  @override
  String get columnUpdated => 'Modifiée';

  @override
  String get columnStarted => 'Commencée';

  @override
  String get columnCompleted => 'Terminée';

  @override
  String get columnDeleted => 'Supprimée';

  @override
  String get columnCreator => 'Créateur';

  @override
  String get columnProject => 'Projet';

  @override
  String get columnId => 'Identifiant';

  @override
  String get columnComments => 'Commentaires';

  @override
  String get columnHistory => 'Historique';

  @override
  String get settingsAccountHelp => 'Profil, espaces et historique';

  @override
  String get settingsCalendarHelp => 'Vos échéances dans votre calendrier';

  @override
  String get settingsTokensHelp =>
      'Identifiants pour les scripts, la CLI et les agents';
}
