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
  String helpAbout(String topic) {
    return 'Aide : $topic';
  }

  @override
  String get helpServerBody =>
      'Un serveur tix est l’ordinateur sur lequel tourne le tix de votre équipe. Son adresse est celle avec laquelle vous ouvrez tix dans un navigateur, par exemple https://tix.example.com.\n\nVous ne la connaissez pas ? Demandez à la personne qui gère tix pour vous. Vous pouvez omettre https:// et la barre oblique finale.';

  @override
  String get helpKindTitle => 'Serveur ou cet appareil';

  @override
  String get helpKindBody =>
      'Serveur : connectez-vous à un tix géré pour vous ou votre équipe, et travaillez sur les mêmes tâches que tout le monde.\n\nCet appareil : tix tourne dans cette application, avec une base de données gardée sur cet appareil. Ni serveur ni compte, et rien n’est partagé avec qui que ce soit.';

  @override
  String get helpMethodTitle => 'Comment se connecter';

  @override
  String get helpMethodSignIn =>
      'Identification : utilisez l’e-mail et le mot de passe avec lesquels vous vous identifiez sur tix dans le navigateur.';

  @override
  String get helpMethodToken =>
      'Jeton : collez un jeton d’API au lieu d’un mot de passe. Il reste connecté jusqu’à sa révocation, idéal pour un appareil que vous gardez.';

  @override
  String get helpMethodInvite =>
      'Invitation : vous avez reçu un e-mail d’invitation ? Collez son lien et le serveur est rempli pour vous.';

  @override
  String get helpTokenBody =>
      'Un jeton d’API est un long code qui laisse entrer cette application sans votre mot de passe.\n\nCréez-en un sur la page « Jetons d’API » de tix dans le navigateur, ou lancez tix token create là où la commande tix fonctionne. Copiez-le dès qu’il s’affiche : vous ne le verrez qu’une fois.';

  @override
  String get helpEmailBody =>
      'L’adresse e-mail de votre compte tix, celle avec laquelle vous vous identifiez sur tix dans le navigateur.';

  @override
  String get helpPasswordBody =>
      'Votre mot de passe tix, le même que dans le navigateur. Oublié ? La personne qui gère votre tix peut le réinitialiser.';

  @override
  String get helpInviteBody =>
      'Quand quelqu’un vous invite sur tix, vous recevez un e-mail avec un lien. Collez ce lien ici, ou partagez-le vers tix depuis votre application de messagerie.\n\nL’adresse du serveur est dans le lien, inutile de la saisir.';

  @override
  String get helpNameBody =>
      'Un nom pour cette connexion, visible seulement dans cette application. Pratique si vous utilisez plusieurs serveurs ou comptes. Laissez vide pour utiliser l’adresse du serveur.';

  @override
  String get helpRememberBody =>
      'Ainsi connecté, le serveur garde votre session plus longtemps et vous demande votre mot de passe moins souvent. La durée dépend de la personne qui gère votre tix.\n\nDésactivez-le sur un appareil que d’autres utilisent. Se déconnecter met fin à la session dans tous les cas.';

  @override
  String get helpTenantTitle => 'Espaces';

  @override
  String get helpTenantBody =>
      'Un même tix peut contenir plusieurs espaces séparés, par exemple un par entreprise ou par équipe. Chacun a ses propres projets et membres.\n\nChoisissez celui à ouvrir. Vous pourrez ajouter les autres plus tard.';

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
      'Une session dure aussi longtemps que le serveur le permet, plus longtemps avec « Rester connecté ». Utilisez un jeton pour un appareil qui doit rester connecté en permanence.';

  @override
  String get staySignedIn => 'Rester connecté';

  @override
  String get staySignedInHelp =>
      'Garde cet appareil connecté plus longtemps, quand le serveur le propose. Désactivez-le sur un appareil partagé.';

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
  String get markDone => 'Marquer comme terminée';

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
  String get taskMoveToProject => 'Déplacer vers un projet…';

  @override
  String taskMoveToProjectTitle(String ref) {
    return 'Déplacer $ref vers un autre projet';
  }

  @override
  String taskMoveToProjectBody(String ref, String project) {
    return '$ref prend le numéro suivant dans $project, et $ref continue d\'y mener. Les commentaires, l\'historique, les liens, les tags et la personne assignée suivent. Le statut est gardé si le workflow de $project en a un du même nom, sinon la tâche démarre au premier statut. Les champs personnalisés que $project ne définit pas restent en arrière.';
  }

  @override
  String get taskMoveToProjectPick => 'Choisissez le projet de destination.';

  @override
  String get taskMoveToProjectAction => 'Déplacer';

  @override
  String get taskMoveToProjectNone =>
      'Il n\'y a pas d\'autre projet vers lequel déplacer.';

  @override
  String taskMovedToProject(String from, String to) {
    return '$from est désormais $to.';
  }

  @override
  String get taskMovedToProjectStatus =>
      'Elle démarre au premier statut du projet.';

  @override
  String taskMovedToProjectDropped(String fields) {
    return 'Laissés en arrière : $fields.';
  }

  @override
  String get taskMoveUnsupported =>
      'Ce serveur ne peut pas déplacer de tâches vers un autre projet.';

  @override
  String get taskMoveKeywords => 'déplacer projet transférer move project';

  @override
  String bulkMoveProjectTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Déplacer $count tâches vers un autre projet',
      one: 'Déplacer 1 tâche vers un autre projet',
    );
    return '$_temp0';
  }

  @override
  String bulkMoveProjectBody(String project) {
    return 'Chaque tâche prend le numéro suivant dans $project, et son ancienne référence continue d\'y mener. Un statut absent du workflow de $project repart du premier statut, et les champs que $project ne définit pas restent en arrière. Pas d\'annulation.';
  }

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
  String tasksHeldByAgent(int count) {
    return 'tenues par un agent : $count';
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
  String get bulkExit => 'Quitter la sélection';

  @override
  String get bulkExtendDown => 'Étendre la sélection vers le bas';

  @override
  String get bulkExtendUp => 'Étendre la sélection vers le haut';

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
  String get bulkSelectMode => 'Sélectionner des tâches';

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
  String get lanesGroupBy => 'Regrouper les couloirs par';

  @override
  String get lanesByProject => 'Projet';

  @override
  String get lanesByTag => 'Étiquette';

  @override
  String get lanesNoTag => 'Sans étiquette';

  @override
  String lanesOnly(String name) {
    return 'Seulement les tâches de $name';
  }

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
  String get addDetailsTitle => 'Ajouter avec détails';

  @override
  String get addDetailsMore => 'Plus de détails';

  @override
  String get addDetailsTitleLabel => 'Titre';

  @override
  String get addDetailsTitleHint => 'Que faut-il faire ?';

  @override
  String get addDetailsTitleRequired => 'Une tâche a besoin d\'un titre.';

  @override
  String get addDetailsBody => 'Description';

  @override
  String get addDetailsBodyHint => 'Ajouter une description';

  @override
  String get addDetailsPriority => 'Priorité';

  @override
  String get addDetailsDue => 'Date d\'échéance';

  @override
  String get addDetailsDuePick => 'Choisir une date';

  @override
  String get addDetailsDueClear => 'Effacer la date d\'échéance';

  @override
  String get addDetailsAssignee => 'Responsable';

  @override
  String get addDetailsAssigneeHint => 'personne pour l\'instant';

  @override
  String get addDetailsAssigneeInfo =>
      'L\'identifiant d\'une personne ou d\'un agent. Laissez-le vide et la tâche attend la personne qui la prendra.';

  @override
  String get addDetailsTags => 'Étiquettes';

  @override
  String get addDetailsTagsHint => 'séparées par des virgules';

  @override
  String get addDetailsMoreOptions => 'Plus d\'options';

  @override
  String get addDetailsMoreOptionsHint =>
      'répétition, parent, dépendances, durée de prise en charge';

  @override
  String get addDetailsRepeat => 'Répéter une fois terminée';

  @override
  String get addDetailsRepeatHint =>
      'par ex. every week, every month on day 1, 3 days after done';

  @override
  String get addDetailsRepeatInfo =>
      'Terminer une tâche récurrente crée la suivante, avec le même titre, les mêmes étiquettes et le même responsable, due à la date suivante. L\'annuler met fin à la série.';

  @override
  String get addDetailsParent => 'Tâche parente';

  @override
  String get addDetailsParentInfo =>
      'Fait de celle-ci une sous-tâche d\'une autre tâche. Désignez-la par sa référence, la clé et le numéro sur sa ligne.';

  @override
  String get addDetailsDependsOn => 'Dépend de';

  @override
  String get addDetailsDependsOnInfo =>
      'Les tâches à terminer avant que celle-ci puisse commencer, séparées par des virgules. D\'ici là, la tâche est affichée comme en attente.';

  @override
  String get addDetailsLease => 'Durée de prise en charge';

  @override
  String get addDetailsLeaseHint => 'Hérité';

  @override
  String get addDetailsLeaseInfo =>
      'Durée d\'une prise en charge de cette tâche avant expiration, quand la prise en charge n\'indique pas sa propre durée. Vide utilise celle du projet, puis celle d\'un workflow personnalisé, puis celle du locataire. Jamais plus que le maximum.';

  @override
  String get addDetailsCreate => 'Créer la tâche';

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
  String get liveDetailsHint => 'Touchez pour voir les détails de connexion';

  @override
  String get liveDetailsLongPressHint =>
      'Appui long pour les détails de connexion';

  @override
  String get liveDetailsShow => 'afficher les détails de connexion';

  @override
  String get liveDetailsTitle => 'Détails de connexion';

  @override
  String get liveDetailsNone =>
      'Il n’y a pas de connexion en direct pour ce contexte.';

  @override
  String get liveDetailsPausedInfo =>
      'Les mises à jour en direct sont en pause tant que le moteur de l’instance locale est arrêté. Elles reprennent avec lui.';

  @override
  String get liveDetailsModePaused => 'En pause';

  @override
  String get liveDetailsModeClosed => 'Fermé';

  @override
  String get liveDetailsServer => 'Serveur';

  @override
  String get liveDetailsMode => 'État';

  @override
  String get liveDetailsTransport => 'Transport';

  @override
  String get liveTransportWebsocket => 'WebSocket';

  @override
  String get liveTransportPoll => 'Interrogation longue en HTTP';

  @override
  String get liveTransportRefresh => 'Rechargement périodique';

  @override
  String get liveTransportNone => 'Aucun';

  @override
  String get liveSourceProbe => 'Essai WebSocket en arrière-plan';

  @override
  String get liveSourcePoll => 'Interrogation';

  @override
  String get liveDetailsSince => 'Depuis';

  @override
  String get liveDetailsLastContact => 'Dernier contact avec le serveur';

  @override
  String get liveDetailsLastEvent => 'Dernier événement';

  @override
  String get liveDetailsNever => 'Pas encore';

  @override
  String get liveDetailsFailuresInRow => 'Échecs consécutifs';

  @override
  String get liveDetailsWindowFailures => 'Échecs WebSocket';

  @override
  String liveDetailsWindowValue(int count, int max, int minutes) {
    return '$count sur $max en $minutes min avant de passer à l’interrogation';
  }

  @override
  String get liveDetailsPollEndpoint => 'Point d’interrogation';

  @override
  String get liveDetailsPollAvailable => 'Disponible';

  @override
  String get liveDetailsPollMissing => 'Absent sur ce serveur (404 ou 405)';

  @override
  String get liveDetailsNextRetry => 'Prochain essai';

  @override
  String get liveDetailsNextProbe => 'Prochain essai WebSocket';

  @override
  String get liveDetailsLastError => 'Dernière erreur';

  @override
  String get liveDetailsNoError =>
      'Rien n’a échoué depuis le démarrage de l’application.';

  @override
  String get liveDetailsErrorWhat => 'Quoi';

  @override
  String get liveDetailsErrorAt => 'Quand';

  @override
  String get liveDetailsErrorSource => 'Pendant';

  @override
  String get liveDetailsErrorType => 'Exception';

  @override
  String get liveDetailsHttpStatus => 'Statut HTTP';

  @override
  String get liveDetailsOsError => 'Erreur système';

  @override
  String liveDetailsOsErrorValue(String message, String code) {
    return '$message (code $code)';
  }

  @override
  String get liveDetailsCloseCode => 'Code de fermeture';

  @override
  String get liveDetailsErrorMessage => 'Message';

  @override
  String get liveErrorUnreachable => 'Serveur injoignable';

  @override
  String get liveErrorTimeout => 'Délai dépassé';

  @override
  String get liveErrorTls => 'Échec de la connexion sécurisée';

  @override
  String get liveErrorUpgradeRefused => 'Passage en WebSocket refusé';

  @override
  String get liveErrorClosed => 'Connexion fermée';

  @override
  String get liveErrorRefused => 'Refusé par le serveur';

  @override
  String get liveErrorHttp => 'Erreur HTTP';

  @override
  String get liveErrorOther => 'Autre erreur';

  @override
  String get liveDetailsHints => 'Ce que cela peut signifier';

  @override
  String get liveHintIdleTimeout =>
      'Un proxy ou un répartiteur de charge ferme peut-être les connexions inactives. Son délai de lecture doit dépasser 60 s pour /api/v1/events et /api/v1/events/poll.';

  @override
  String get liveHintNoUpgrade =>
      'Le WebSocket échoue alors que le HTTP simple fonctionne : le proxy devant tix ne transmet peut-être pas le passage en WebSocket.';

  @override
  String get liveHintUnreachable =>
      'Le téléphone n’a pas pu joindre l’hôte. Vérifiez le réseau, l’adresse et que le serveur fonctionne.';

  @override
  String get liveHintTls =>
      'Le certificat du serveur n’a pas été accepté : il est peut-être expiré, autosigné ou émis pour un autre nom.';

  @override
  String get liveHintRefused =>
      'Le serveur a refusé les mises à jour en direct à cette connexion. Un jeton doit avoir la portée event:subscribe.';

  @override
  String liveHintHttp(String status) {
    return 'Le serveur ou un proxy a répondu HTTP $status. Ses journaux devraient dire pourquoi.';
  }

  @override
  String get liveHintPollMissing =>
      'Ce serveur est antérieur au point d’interrogation : l’écran est donc rechargé périodiquement.';

  @override
  String get liveDetailsHistory => 'Changements récents';

  @override
  String get liveDetailsHistoryEmpty => 'Rien pour l’instant.';

  @override
  String liveDetailsHistoryError(String kind, String source) {
    return '$kind ($source)';
  }

  @override
  String get liveDetailsReconnect => 'Reconnecter';

  @override
  String get liveDetailsCopy => 'Copier les détails';

  @override
  String get liveDetailsCopied =>
      'Détails de connexion copiés. Les jetons et cookies sont exclus.';

  @override
  String get aboutConnectionDetails => 'Détails de connexion';

  @override
  String get aboutConnectionDetailsHelp =>
      'Comment les mises à jour en direct arrivent dans ce contexte, et ce qui a échoué en dernier';

  @override
  String get copyToClipboard => 'Copier';

  @override
  String get copiedToClipboard => 'Copié.';

  @override
  String get copyJson => 'Copier le JSON';

  @override
  String get copyJsonDone => 'JSON copié.';

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
  String get tokensRetiring => 'en retrait';

  @override
  String tokensStops(String when) {
    return 'Prend fin $when';
  }

  @override
  String get tokensRotate => 'Renouveler';

  @override
  String tokensRotateTitle(String name) {
    return 'Renouveler $name ?';
  }

  @override
  String get tokensRotateBody =>
      'Un nouveau jeton avec le même nom, les mêmes portées et la même durée remplace celui-ci, et sa valeur est affichée une seule fois.';

  @override
  String tokensRotateOther(String name) {
    return 'Ce jeton appartient à $name, pas à vous, et le journal indiquera que vous avez renouvelé le jeton de quelqu’un d’autre.';
  }

  @override
  String get tokensRotateConnection =>
      'C’est le jeton avec lequel cette application se connecte, elle garde donc le nouveau à sa place.';

  @override
  String get tokensRotateInfo =>
      'Renouvelez un jeton régulièrement, ou tout de suite s’il a pu fuiter. Ce qui le détient doit recevoir la nouvelle valeur ; un délai de grâce garde l’ancien valide entre-temps, et le révoquer met fin à ce délai plus tôt.';

  @override
  String get tokensRotateGrace => 'Ancien jeton';

  @override
  String get tokensRotateGraceInfo =>
      'Combien de temps l’ancienne valeur reste valide à côté de la nouvelle, un jour au plus, pour qu’un agent en cours prenne la nouvelle valeur sans faire échouer une requête. Après une fuite, arrêtez-le tout de suite.';

  @override
  String get tokensGraceNow => 'Arrêter l’ancien jeton maintenant';

  @override
  String get tokensGrace10m => 'Le garder valide 10 minutes';

  @override
  String get tokensGrace1h => 'Le garder valide 1 heure';

  @override
  String get tokensGrace24h => 'Le garder valide 24 heures';

  @override
  String tokensRotateNamed(String name) {
    return 'Renouveler $name';
  }

  @override
  String tokensRotateNamedOther(String name, String owner) {
    return 'Renouveler $name ($owner)';
  }

  @override
  String tokensRotatedTitle(String name) {
    return 'Jeton $name renouvelé';
  }

  @override
  String tokensRotatedConnection(String name) {
    return '$name renouvelé. Cette application se connecte désormais avec le nouveau jeton.';
  }

  @override
  String get tokensRotatedUnsaved =>
      'Le stockage sécurisé de cet appareil a refusé le nouveau jeton. Il n’est affiché que cette fois. L’application l’utilise jusqu’à sa fermeture ; ensuite, reconnectez-vous avec.';

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
  String get scopeTaskApprove =>
      'Approuver ou refuser le travail sur une transition de workflow qui le demande.';

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

  @override
  String get securityTitle => 'Sécurité';

  @override
  String get securitySubtitle => 'Votre second facteur et vos clés SSH';

  @override
  String get totpTitle => 'Second facteur';

  @override
  String get totpInfo =>
      'Un code d’une application d’authentification, demandé après votre mot de passe. Les codes de récupération vous laissent entrer quand l’application n’est pas à portée de main.';

  @override
  String get totpOn => 'Activé';

  @override
  String get totpOff => 'Désactivé';

  @override
  String get totpPending => 'Non confirmé';

  @override
  String totpSince(String date) {
    return 'Depuis le $date';
  }

  @override
  String get totpOnBody =>
      'La connexion demande un code de votre application d’authentification après votre mot de passe.';

  @override
  String get totpOffBody => 'La connexion ne demande que votre mot de passe.';

  @override
  String get totpPendingBody =>
      'La configuration a commencé mais n’a jamais été confirmée par un code. Recommencez pour la terminer.';

  @override
  String totpRequiredOn(String surfaces) {
    return 'Votre espace exige un second facteur pour : $surfaces.';
  }

  @override
  String get totpSurfaceWeb => 'le navigateur';

  @override
  String get totpSurfaceCli => 'la ligne de commande';

  @override
  String get totpSurfaceSsh => 'SSH';

  @override
  String totpCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes de récupération restants',
      one: '1 code de récupération restant',
      zero: 'Plus aucun code de récupération',
    );
    return '$_temp0';
  }

  @override
  String totpLocked(String time) {
    return 'Trop de codes erronés. Les codes sont refusés jusqu’à $time.';
  }

  @override
  String get totpSetUp => 'Configurer';

  @override
  String get totpNewCodes => 'Nouveaux codes de récupération';

  @override
  String get totpNewCodesBody =>
      'Vos codes de récupération actuels cessent aussitôt de fonctionner, utilisés ou non, et un nouveau jeu s’affiche une seule fois.';

  @override
  String get totpNewCodesConfirm => 'Remplacer les codes';

  @override
  String get totpRemove => 'Retirer le second facteur';

  @override
  String get totpRemoveBody =>
      'La connexion ne demandera plus que votre mot de passe, et vos codes de récupération cessent de fonctionner. Si votre espace exige un second facteur, il faudra en configurer un de nouveau.';

  @override
  String get totpRemoved => 'Second facteur retiré.';

  @override
  String get totpCodesHeading =>
      'Enregistrez ces codes de récupération maintenant';

  @override
  String get totpCodesNote =>
      'Chacun vous connecte une fois sans votre application d’authentification. Ils ne s’affichent qu’une fois et ne peuvent plus être relus ; si vous les perdez, créez-en un nouveau jeu.';

  @override
  String get totpCodesSaved => 'Je les ai enregistrés';

  @override
  String get totpConfirm => 'Confirmer';

  @override
  String get totpStep1 =>
      '1. Ajoutez cette clé à votre application d’authentification, ou ouvrez-la dans celle-ci depuis cet appareil.';

  @override
  String get totpSecretHeading => 'Votre clé d’authentification';

  @override
  String totpSecretNote(String account, String issuer) {
    return 'Compte $account sur $issuer. Gardez-la secrète : quiconque la détient peut produire vos codes.';
  }

  @override
  String get totpOpenApp => 'Ouvrir dans l’application';

  @override
  String get totpStep2 =>
      '2. Saisissez le code à six chiffres affiché par l’application.';

  @override
  String get sshKeysTitle => 'Clés SSH';

  @override
  String get sshKeysInfo =>
      'Une clé enregistrée ici vous connecte à l’interface terminal de tix par SSH, dans cet espace. Les clés révoquées restent listées pour comprendre pourquoi l’une a cessé de fonctionner.';

  @override
  String get sshKeysEmpty => 'Aucune clé SSH pour l’instant.';

  @override
  String get sshKeyAdd => 'Ajouter une clé SSH';

  @override
  String get sshKeyAddSubmit => 'Ajouter la clé';

  @override
  String get sshKeyAdded => 'Clé SSH ajoutée.';

  @override
  String get sshKeyUnlabelled => 'Clé sans libellé';

  @override
  String get sshKeyRevoked => 'Révoquée';

  @override
  String sshKeyAddedOn(String date) {
    return 'Ajoutée le $date';
  }

  @override
  String sshKeyLastUsed(String date) {
    return 'Utilisée le $date';
  }

  @override
  String get sshKeyNeverUsed => 'Jamais utilisée';

  @override
  String sshKeyRevokedOn(String date) {
    return 'Révoquée le $date';
  }

  @override
  String get sshKeyRevoke => 'Révoquer';

  @override
  String sshKeyRevokeBody(String name) {
    return '$name cesse aussitôt de vous connecter par SSH. C’est irréversible ; enregistrez de nouveau la clé pour l’utiliser.';
  }

  @override
  String get sshKeyRevokedToast => 'Clé SSH révoquée.';

  @override
  String get sessionsTitle => 'Sessions actives';

  @override
  String get sessionsInfo =>
      'Vos connexions par navigateur et terminal à ce tenant qui n’ont pas expiré. Révoquez celles que vous ne reconnaissez pas. Les jetons d’API se gèrent dans Jetons.';

  @override
  String get sessionsEmpty => 'Aucune session active.';

  @override
  String get sessionsNotReadable =>
      'Ce jeton ne peut pas lister vos sessions : il lui faut la portée account:read, que « * » n’inclut pas. Connectez-vous avec votre mot de passe, ou utilisez un jeton créé avec account:read.';

  @override
  String get sessionsShowMore => 'Afficher plus';

  @override
  String get sessionCurrent => 'Cette session';

  @override
  String get sessionUnknownAgent => 'Appareil inconnu';

  @override
  String get sessionMethodPassword => 'Mot de passe';

  @override
  String get sessionMethodSshKey => 'Clé SSH';

  @override
  String get sessionMethodSwitch => 'Changement de tenant';

  @override
  String get sessionSecondFactor => 'avec second facteur';

  @override
  String sessionSignedIn(String when) {
    return 'Connexion $when';
  }

  @override
  String sessionExpires(String when) {
    return 'Expire $when';
  }

  @override
  String get sessionRevoke => 'Révoquer';

  @override
  String get sessionRevokeTitle => 'Révoquer cette session ?';

  @override
  String sessionRevokeBody(String agent) {
    return '$agent est déconnecté immédiatement et devra se reconnecter.';
  }

  @override
  String get sessionRevokeCurrentBody =>
      'C’est la session avec laquelle cette application est connectée. La révoquer vous déconnecte ici, et vous devrez vous reconnecter.';

  @override
  String get sessionRevoked => 'Session révoquée.';

  @override
  String get sshKeyPublicKey => 'Clé publique';

  @override
  String get sshKeyPublicKeyHelp =>
      'La ligne de votre fichier .pub, telle que ssh-keygen l’écrit.';

  @override
  String get sshKeyLabel => 'Libellé (facultatif)';

  @override
  String get sshKeyLabelHelp =>
      'Distingue cette clé des autres, par exemple par la machine qui la porte.';

  @override
  String get sshKeyAllTenants => 'Tous mes espaces';

  @override
  String get sshKeyAllTenantsHelp =>
      'Enregistre la clé dans chacun de vos espaces, pas seulement celui-ci.';

  @override
  String get tenantSettingsTitle => 'Paramètres de l’espace';

  @override
  String get tenantSaved => 'Enregistré.';

  @override
  String get tenantGeneralTitle => 'Général';

  @override
  String get tenantName => 'Nom';

  @override
  String get tenantKey => 'Clé';

  @override
  String get tenantKeyHelp =>
      'Courte et unique : lettres, chiffres, tirets et tirets bas, commençant par une lettre. Elle ne pourra plus changer.';

  @override
  String get tenantTimezone => 'Fuseau horaire';

  @override
  String get tenantTimezoneHelp =>
      'Une zone IANA dans laquelle on lit les dates, sauf choix personnel. Vide reprend celle du serveur.';

  @override
  String get tenantTimeFormat => 'Format des dates';

  @override
  String get tenantServerDefault => 'Par défaut du serveur';

  @override
  String get tenantThemeTitle => 'Thème';

  @override
  String get tenantThemeInfo =>
      'La couleur de l’espace sur toutes les surfaces : le web, le terminal et cette application. Les couleurs des statuts et des priorités ne changent jamais avec elle.';

  @override
  String get tenantThemeDefault => 'par défaut';

  @override
  String get tenantThemeCustom => 'Couleur personnalisée';

  @override
  String get tenantThemeCustomHelp =>
      '#rrggbb. tix l’ajuste jusqu’à ce que le texte dessus et autour reste lisible.';

  @override
  String get tenantThemeCustomBad =>
      'Écrivez la couleur sous la forme #rrggbb, par exemple #0f766e.';

  @override
  String get tenantThemePreview => 'Aperçu';

  @override
  String get tenantThemeSampleRow => 'Une ligne sélectionnée';

  @override
  String get tenantThemeSampleLink => 'Un lien';

  @override
  String get tenantThemeSampleButton => 'Nouvelle tâche';

  @override
  String get tenantThemeSaved => 'Thème enregistré.';

  @override
  String get tenantTotpTitle => 'Second facteur';

  @override
  String get tenantTotpInfo =>
      'Exige un code d’une application d’authentification à la connexion. Qui n’en a pas est guidé pour le configurer en se connectant, donc l’activer ne bloque personne.';

  @override
  String get tenantTotpWeb => 'L’exiger dans le navigateur';

  @override
  String get tenantTotpCli => 'L’exiger en ligne de commande';

  @override
  String get tenantTotpSsh => 'L’exiger par SSH, en plus de la clé';

  @override
  String get tenantTotpNone => 'Non exigé';

  @override
  String get tenantTotpBadge => 'Second facteur';

  @override
  String get tenantLeaseTitle => 'Réservations';

  @override
  String get tenantLeaseInfo =>
      'Durée de la réservation d’une tâche par un agent. Un projet, un workflow ou la réservation peut demander moins ; le plafond du serveur l’emporte toujours.';

  @override
  String get tenantLeaseDefault => 'Durée par défaut';

  @override
  String get tenantLeaseDefaultHelp =>
      'Une durée comme 30m ou 2h. Vide reprend celle du serveur.';

  @override
  String get tenantLeaseMax => 'Durée maximale';

  @override
  String get tenantLeaseMaxHelp =>
      'Plafonne chaque réservation de cet espace. Elle peut abaisser le plafond du serveur, jamais le relever.';

  @override
  String get tenantSessionTitle => 'Sessions';

  @override
  String get tenantSessionInfo =>
      'Durée d’une connexion dans cet espace. Chaque réglage peut être plus court que celui du serveur, jamais plus long.';

  @override
  String get tenantSessionTtl => 'Une connexion dure';

  @override
  String get tenantSessionTtlInfo =>
      'Durée d’une connexion dans cet espace à partir du moment où elle est faite, par exemple 8h. Elle peut être plus courte que celle du serveur, pas plus longue. Les sessions déjà ouvertes gardent leur expiration.';

  @override
  String get tenantSessionIdle => 'Déconnecter après une inactivité de';

  @override
  String get tenantSessionIdleInfo =>
      'Termine une session que personne n’a utilisée depuis ce temps, par exemple 30m, avec ou sans Rester connecté. S’applique aux sessions déjà ouvertes dès l’enregistrement. Peut être plus court que celui du serveur, pas plus long ; vide sans réglage du serveur signifie jamais.';

  @override
  String get tenantSessionRemember => 'Rester connecté dure';

  @override
  String get tenantSessionRememberInfo =>
      'Durée d’une connexion quand la personne coche Rester connecté, par exemple 7d, ou off pour ne plus le proposer. Peut être plus court que celui du serveur, pas plus long.';

  @override
  String get tenantSessionNever => 'jamais';

  @override
  String get tenantSessionNote =>
      'Laissez vide pour utiliser le réglage du serveur, affiché en gris.';

  @override
  String get tenantArtifactTitle => 'Artefacts';

  @override
  String get tenantArtifactInfo =>
      'Les fichiers qu’un artefact peut porter dans cet espace. Chaque limite peut être plus stricte que celle du serveur, jamais plus large.';

  @override
  String get tenantArtifactMaxBytes => 'Plus gros fichier d’artefact';

  @override
  String get tenantArtifactMaxBytesInfo =>
      'Le plus gros fichier qu’un artefact peut porter dans cet espace, par exemple 512KiB ou 5MiB. Il peut être inférieur à la limite du serveur, pas supérieur. Les fichiers déjà joints restent tels quels.';

  @override
  String get tenantArtifactSizeBad =>
      'Écrivez une taille comme 1048576, 512KiB ou 5MiB.';

  @override
  String get tenantArtifactTypes => 'Types d’artefact acceptés';

  @override
  String get tenantArtifactTypesInfo =>
      'Les types de média qu’un fichier d’artefact peut avoir dans cet espace, séparés par des virgules, par exemple image/*, application/pdf. Seuls les types acceptés par le serveur peuvent être listés. Quel que soit le type, un fichier est toujours proposé en téléchargement et jamais ouvert dans le navigateur.';

  @override
  String get tenantArtifactNote =>
      'Laissez vide pour utiliser la limite du serveur, affichée en gris.';

  @override
  String get tenantTrashTitle => 'Corbeille';

  @override
  String get tenantTrashKeep =>
      'Garder les tâches supprimées dans une corbeille';

  @override
  String get tenantTrashOnBody =>
      'Les tâches supprimées peuvent être restaurées jusqu’à ce que l’entretien vide la corbeille.';

  @override
  String get tenantTrashOffBody =>
      'Supprimer une tâche est définitif. Les tâches déjà dans la corbeille y restent.';

  @override
  String get tenantTrashOnShort =>
      'Les tâches supprimées vont dans la corbeille';

  @override
  String get tenantTrashOffShort => 'La suppression est définitive';

  @override
  String get tenantDelete => 'Supprimer l’espace';

  @override
  String get tenantDeleteHelp =>
      'Ses données deviennent inaccessibles et ses domaines ne répondent plus.';

  @override
  String get tenantDeleteCurrent =>
      'C’est l’espace dans lequel vous travaillez. Passez à un autre pour le supprimer.';

  @override
  String tenantDeleteBody(String name, String key) {
    return '$name ($key) et tout son contenu deviennent inaccessibles pour tout le monde, et ses domaines ne répondent plus. Seul l’opérateur du serveur peut le rétablir.';
  }

  @override
  String tenantDeleted(String name) {
    return '$name supprimé.';
  }

  @override
  String get tenantsTitle => 'Espaces';

  @override
  String get tenantsSubtitle => 'Tous les espaces de ce serveur';

  @override
  String get tenantsEmpty => 'Aucun espace.';

  @override
  String get tenantsEmptyBody => 'Créez-en un avec son premier administrateur.';

  @override
  String get tenantsPick => 'Choisissez un espace pour l’afficher ici.';

  @override
  String get tenantCreate => 'Nouvel espace';

  @override
  String get tenantCreateSubmit => 'Créer l’espace';

  @override
  String tenantCreated(String name) {
    return '$name créé.';
  }

  @override
  String get tenantFirstAdmin => 'Premier administrateur';

  @override
  String get tenantFirstAdminHelp =>
      'Devient administrateur du nouvel espace. Une adresse qui a déjà un compte garde son mot de passe et son second facteur.';

  @override
  String get tenantPasswordHelp =>
      'Au moins 12 caractères. Laissez vide et tix en génère un, affiché une seule fois.';

  @override
  String get tenantCredentialsHeading => 'Copiez ces mots de passe maintenant';

  @override
  String get tenantCredentialsNote =>
      'tix les a générés et ne les montre qu’une fois ; rien ne les conserve. Remettez chacun à son administrateur, qui en choisira un nouveau à la première connexion. En cas de perte, définissez un nouveau mot de passe.';

  @override
  String get tenantCurrent => 'Actuel';

  @override
  String get tenantMember => 'Membre';

  @override
  String get tenantNoTrash => 'Sans corbeille';

  @override
  String get tenantOverview => 'Vue d’ensemble';

  @override
  String get tenantCreatedAt => 'Créé';

  @override
  String get tenantSwitch => 'Passer à cet espace';

  @override
  String get tenantJoinSwitch => 'Rejoindre et y passer';

  @override
  String tenantJoinBody(String name) {
    return 'Vous n’êtes pas membre de $name. En tant qu’administrateur global, vous pouvez vous y ajouter comme administrateur et y passer. Le changement figure dans le journal de votre compte.';
  }

  @override
  String get tenantJoinConfirm => 'Rejoindre comme administrateur';

  @override
  String get tenantSwitchPinned =>
      'Cette connexion n’atteint qu’un seul espace. Connectez-vous avec une connexion qui peut changer d’espace pour passer de l’un à l’autre.';

  @override
  String get tenantUsersTitle => 'Utilisateurs';

  @override
  String get tenantDomainsEmpty => 'Aucun domaine ne mène à cet espace.';

  @override
  String get domainsTitle => 'Domaines';

  @override
  String get domainsSubtitle => 'Les noms d’hôte qui ouvrent cet espace';

  @override
  String get domainsBody =>
      'Une requête qui arrive sur l’un de ces noms d’hôte atteint cet espace sans avoir à le nommer.';

  @override
  String get domainsEmpty => 'Aucun domaine pour l’instant.';

  @override
  String get domainsEmptyBody =>
      'Associez un nom d’hôte pour qu’on atteigne cet espace à sa propre adresse.';

  @override
  String get domainAdd => 'Ajouter un domaine';

  @override
  String get domainAddSubmit => 'Ajouter le domaine';

  @override
  String get domainAdded => 'Domaine ajouté.';

  @override
  String get domainHostname => 'Nom d’hôte';

  @override
  String get domainHostnameHelp =>
      'Mis en minuscules ; un port ou un point final est retiré.';

  @override
  String get domainCertMode => 'Certificat';

  @override
  String get domainCertNone => 'Terminé ailleurs';

  @override
  String get domainCertFile => 'Fichier de certificat';

  @override
  String get domainCertNoneHelp =>
      'Un proxy devant tix détient le certificat, ou l’hôte est en HTTP simple.';

  @override
  String get domainCertFileHelp =>
      'tix sert lui-même le TLS depuis des fichiers PEM sur le serveur.';

  @override
  String get domainCertPath => 'Chemin du certificat sur le serveur';

  @override
  String get domainKeyPath => 'Chemin de la clé privée sur le serveur';

  @override
  String get domainVerified => 'Vérifié';

  @override
  String get domainShared => 'Partagé';

  @override
  String get domainSharedInfo =>
      'Un nom d’hôte partagé sert aussi l’espace qu’indiquent l’identifiant ou l’en-tête X-Tix-Tenant, comme un hôte qu’aucun domaine ne revendique. Seul un administrateur global le règle.';

  @override
  String get domainRemove => 'Retirer le domaine';

  @override
  String domainRemoveBody(String hostname) {
    return 'Les requêtes vers $hostname n’atteignent plus cet espace. Qui utilise cette adresse devra en prendre une autre.';
  }

  @override
  String get domainRemoved => 'Domaine retiré.';

  @override
  String get serverTitle => 'Serveur';

  @override
  String serverVersion(String version) {
    return 'tix $version';
  }

  @override
  String get serverStatusTitle => 'État';

  @override
  String get serverVersionLabel => 'Version';

  @override
  String get serverHealth => 'Santé';

  @override
  String get serverAddress => 'Adresse';

  @override
  String get serverId => 'Processus serveur';

  @override
  String get serverCountTenant => 'Connexions actives dans cet espace';

  @override
  String get serverCountEvents => 'Flux de mises à jour en direct';

  @override
  String get serverCountSsh => 'Sessions SSH';

  @override
  String get serverCountProcess => 'Connexions sur ce serveur';

  @override
  String get serverCountProcessInfo =>
      'Toutes les connexions que ce processus détient, tous espaces confondus. C’est une capacité, pas un annuaire : personne n’y est nommé.';

  @override
  String get connectionsTitle => 'Connexions actives';

  @override
  String get connectionsInfo =>
      'Les flux de mises à jour en direct et les sessions SSH de cet espace que ce processus détient. En fermer une la coupe ; le client peut se reconnecter.';

  @override
  String get connectionsEmpty => 'Aucune connexion active.';

  @override
  String get connectionEvents => 'Mises à jour en direct';

  @override
  String get connectionSsh => 'SSH';

  @override
  String connectionSince(String date) {
    return 'depuis le $date';
  }

  @override
  String get connectionEnd => 'Fermer';

  @override
  String get connectionEndBody =>
      'La connexion se ferme aussitôt. Un client encore actif peut se reconnecter ; révoquez son jeton ou sa clé pour l’en empêcher.';

  @override
  String get connectionEnded => 'Connexion fermée.';

  @override
  String get globalAdminsTitle => 'Administrateurs globaux';

  @override
  String get globalAdminsSubtitle =>
      'Les personnes qui administrent tous les espaces de ce serveur';

  @override
  String get globalAdminsEmpty => 'Aucun administrateur global.';

  @override
  String get globalAdminGrant => 'Nommer administrateur global';

  @override
  String get globalAdminGrantSubmit => 'Nommer';

  @override
  String get globalAdminGrantHelp =>
      'Le compte qui a cette adresse pourra créer des espaces et les administrer tous.';

  @override
  String get globalAdminGranted => 'Administrateur global nommé.';

  @override
  String get globalAdminRevoke => 'Retirer';

  @override
  String globalAdminRevokeBody(String email) {
    return '$email cesse aussitôt d’administrer tous les espaces. Ses adhésions restent telles quelles.';
  }

  @override
  String get globalAdminRevoked => 'Rôle d’administrateur global retiré.';

  @override
  String get globalAdminBadge => 'Administrateur global';

  @override
  String get adminRoleAdmin => 'Administrateur';

  @override
  String get adminRoleMember => 'Membre';

  @override
  String get adminRoleViewer => 'Lecteur';

  @override
  String get adminRoleNone => 'Aucun rôle';

  @override
  String get adminUsersEmpty => 'Aucun utilisateur dans cet espace.';

  @override
  String get adminUsersEmptyBody =>
      'Créez un utilisateur, ou ajoutez un compte existant.';

  @override
  String get adminUserCreate => 'Nouvel utilisateur';

  @override
  String get adminUserCreateSubmit => 'Créer l’utilisateur';

  @override
  String get adminUserActions => 'Actions sur l’utilisateur';

  @override
  String get adminUserEdit => 'Modifier';

  @override
  String adminUserEditTitle(String email) {
    return 'Modifier $email';
  }

  @override
  String get adminUserDelete => 'Supprimer l’utilisateur';

  @override
  String adminUserDeleteBody(String email) {
    return '$email perd cet espace : son adhésion est retirée et ses sessions et jetons ici prennent fin. Son compte reste pour les autres espaces.';
  }

  @override
  String get adminUserClearTotp => 'Effacer le second facteur';

  @override
  String get adminUserClearTotpConfirm => 'L’effacer';

  @override
  String adminUserClearTotpBody(String email) {
    return '$email se connecte avec son seul mot de passe jusqu’à configurer de nouveau un second facteur. Ne le faites que s’il a perdu son application et ses codes de récupération.';
  }

  @override
  String get adminUserEmail => 'Adresse e-mail';

  @override
  String get adminUserHandle => 'Identifiant';

  @override
  String get adminUserHandleHelp =>
      'Son nom court dans cet espace. Vide reprend la partie de l’adresse avant le @.';

  @override
  String get adminUserDisplayName => 'Nom affiché';

  @override
  String get adminUserPassword => 'Mot de passe';

  @override
  String get adminUserPasswordHelp =>
      'Au moins 12 caractères. Laissez vide pour un utilisateur qui se connecte autrement ou sera invité plus tard.';

  @override
  String get adminUserNewPassword => 'Nouveau mot de passe';

  @override
  String get adminUserNewPasswordHelp => 'Laissez vide pour garder l’actuel.';

  @override
  String get adminUserRole => 'Rôle';

  @override
  String get adminUserDisabled => 'Désactivé';

  @override
  String get adminUserDisabledSwitch => 'Désactivé';

  @override
  String get adminUserDisabledHelp =>
      'Un utilisateur désactivé ne peut pas se connecter ; ses sessions et jetons prennent fin aussitôt.';

  @override
  String get adminUserMustChangePassword => 'Doit changer de mot de passe';

  @override
  String get adminUserMustChangeSwitch =>
      'Choisir un nouveau mot de passe à la prochaine connexion';

  @override
  String get adminUserTotp => 'Second facteur';

  @override
  String get adminMemberAdd => 'Ajouter un compte existant';

  @override
  String get adminMemberAddSubmit => 'Ajouter à l’espace';

  @override
  String get adminMemberAddHelp =>
      'La personne garde son mot de passe et son second facteur, et on ne lui demande pas d’accepter.';

  @override
  String get adminAccountLogTitle => 'Journal du compte';

  @override
  String get adminAccountLogEmpty => 'Rien de consigné pour ce compte.';

  @override
  String get adminAccountLogEmptyBody =>
      'Les changements de mot de passe, de second facteur, de statut et d’adhésions s’affichent ici.';

  @override
  String adminAccountLogBy(String who) {
    return 'par $who';
  }

  @override
  String adminAccountLogVia(String channel) {
    return 'via $channel';
  }

  @override
  String get adminAccountLogSystem => 'le système';

  @override
  String get taskReclaim => 'Forcer la libération';

  @override
  String get taskReclaimSubmit => 'Libérer la réservation';

  @override
  String get taskReclaimBody =>
      'Met fin à la réservation qu’un autre acteur détient sur cette tâche, quand son agent est tombé. Son prochain renouvellement sera refusé.';

  @override
  String get taskReclaimReason => 'Raison (facultatif)';

  @override
  String get taskReclaimReasonHelp => 'Gardée dans l’historique de la tâche.';

  @override
  String taskReclaimed(String ref) {
    return 'Réservation de $ref libérée.';
  }

  @override
  String get totpWrongCode =>
      'Ce code n’est pas le bon. Vérifiez l’heure de cet appareil et essayez le suivant.';

  @override
  String get tenantThemeSampleStatus => 'En cours';

  @override
  String get tenantSettingsSubtitle =>
      'Nom, thème, second facteur, réservations et corbeille';

  @override
  String get serverSubtitle => 'Version et connexions actives';

  @override
  String get webhooksTitle => 'Webhooks';

  @override
  String get webhooksSubtitle =>
      'tix envoie chaque évènement à ces adresses, signé avec le secret du point d’accès.';

  @override
  String get webhookNew => 'Nouveau point d’accès';

  @override
  String get webhookEdit => 'Modifier le point d’accès';

  @override
  String get webhookEndpoints => 'Points d’accès';

  @override
  String get webhookEndpointsInfo =>
      'Un point d’accès reçoit chaque évènement, ou seulement les types qu’il nomme. Un point inactif ne reçoit rien tant qu’il n’est pas réactivé.';

  @override
  String get webhooksEmpty => 'Aucun point d’accès pour l’instant.';

  @override
  String get webhooksEmptyBody =>
      'Ajoutez une adresse https et tix y enverra les évènements au fil de l’eau.';

  @override
  String get webhookEveryEvent => 'Tous les évènements';

  @override
  String get webhookActive => 'Actif';

  @override
  String get webhookInactive => 'Inactif';

  @override
  String get webhookActiveHelp => 'Un point d’accès inactif ne reçoit rien.';

  @override
  String get webhookShowDeliveries => 'Voir ses envois';

  @override
  String get webhookDelete => 'Supprimer le point d’accès';

  @override
  String get webhookDeleteTitle => 'Supprimer ce point d’accès ?';

  @override
  String webhookDeleteBody(String url) {
    return '$url ne reçoit plus d’évènements, et ses envois en attente sont abandonnés. C’est irréversible.';
  }

  @override
  String get webhookDeleted => 'Point d’accès supprimé.';

  @override
  String get webhookUrl => 'Adresse';

  @override
  String get webhookUrlHelp =>
      'Doit utiliser https, sauf pour une adresse de bouclage.';

  @override
  String get webhookEvents => 'Types d’évènements';

  @override
  String get webhookEventsHelp =>
      'Séparés par des virgules ; un type peut finir par *. Vide envoie tous les évènements.';

  @override
  String get webhookSecret => 'Secret de signature';

  @override
  String get webhookSecretNewHelp =>
      'Laissez vide et tix en génère un, affiché ici une seule fois.';

  @override
  String get webhookSecretKeepHelp =>
      'Laissez vide pour garder le secret actuel.';

  @override
  String get webhookSave => 'Enregistrer le point d’accès';

  @override
  String get webhookSaved => 'Point d’accès enregistré.';

  @override
  String get webhookSecretHeading => 'Copiez ce secret de signature maintenant';

  @override
  String get webhookSecretNote =>
      'Il ne s’affiche qu’une fois et ne peut pas être relu. Configurez-le côté réception ; si vous le perdez, enregistrez de nouveau le point d’accès avec un secret de votre choix.';

  @override
  String get webhookSecretDone => 'Je l’ai copié';

  @override
  String get webhookDeliveries => 'Envois';

  @override
  String get webhookDeliveriesAll =>
      'Tous les points d’accès, les plus récents d’abord.';

  @override
  String webhookDeliveriesFor(String url) {
    return 'Pour $url, les plus récents d’abord.';
  }

  @override
  String get webhookDeliveriesShowAll => 'Voir tous les points d’accès';

  @override
  String get webhookDeliveriesEmpty => 'Aucun envoi.';

  @override
  String get webhookDeliveriesEmptyBody =>
      'Les envois apparaissent ici à mesure que les évènements partent.';

  @override
  String get webhookStatusAny => 'Tous';

  @override
  String get webhookStatusPending => 'En attente';

  @override
  String get webhookStatusDelivered => 'Remis';

  @override
  String get webhookStatusFailed => 'Échoué';

  @override
  String get webhookStatusUnknown => 'Inconnu';

  @override
  String webhookEvent(int seq) {
    return 'Évènement $seq';
  }

  @override
  String webhookAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentatives',
      one: '1 tentative',
    );
    return '$_temp0';
  }

  @override
  String webhookHttpStatus(int code) {
    return 'HTTP $code';
  }

  @override
  String webhookNextAttempt(String when) {
    return 'prochaine tentative $when';
  }

  @override
  String get webhookRedeliver => 'Renvoyer';

  @override
  String get webhookRedelivered => 'Remis en file pour une nouvelle tentative.';

  @override
  String get webhookPing => 'Envoyer un test';

  @override
  String get webhookPingTitle => 'Événement de test';

  @override
  String webhookPingSent(String url) {
    return 'tix a envoyé un événement webhook.ping signé à $url.';
  }

  @override
  String get webhookPingPending =>
      'Pas encore tenté. Le journal des livraisons affichera le résultat dès que tix aura essayé.';

  @override
  String get syncTitle => 'Synchronisation externe';

  @override
  String get syncSubtitle =>
      'Importez le travail depuis Jira, OpenProject ou un fichier. Les exécutions ont lieu sur le serveur.';

  @override
  String get syncNew => 'Nouvelle source';

  @override
  String get syncSources => 'Sources';

  @override
  String get syncSourcesInfo =>
      'Chaque source garde un curseur, si bien qu’une exécution n’importe que ce qui a changé depuis la précédente. Une exécution complète repart du début.';

  @override
  String get syncEmpty => 'Aucune source pour l’instant.';

  @override
  String get syncEmptyBody =>
      'Ajoutez une source pour importer des tâches d’un autre outil de suivi.';

  @override
  String get syncStatusOk => 'Dernière exécution réussie';

  @override
  String get syncStatusFailed => 'Dernière exécution échouée';

  @override
  String get syncStatusRunning => 'En cours';

  @override
  String get syncStatusNever => 'Jamais exécutée';

  @override
  String get syncNeverRun => 'Pas encore exécutée.';

  @override
  String syncLastRun(String when) {
    return 'Dernière exécution $when.';
  }

  @override
  String syncStoredCredentials(String names) {
    return 'Identifiants enregistrés : $names';
  }

  @override
  String get syncMissing =>
      'Une exécution est refusée tant que le serveur n’a pas :';

  @override
  String get syncReady => 'Prête à être exécutée.';

  @override
  String get syncRunNow => 'Exécuter maintenant';

  @override
  String get syncPreview => 'Aperçu';

  @override
  String get syncEdit => 'Modifier';

  @override
  String get syncDelete => 'Supprimer la source';

  @override
  String get syncDeleteTitle => 'Supprimer cette source ?';

  @override
  String syncDeleteBody(String name) {
    return '$name et sa position de lecture sont supprimés. Les tâches déjà importées restent. C’est irréversible.';
  }

  @override
  String get syncDeleted => 'Source supprimée.';

  @override
  String syncSaved(String name) {
    return '$name enregistrée.';
  }

  @override
  String syncRunTitle(String name) {
    return 'Exécuter $name';
  }

  @override
  String get syncRunBody =>
      'L’aperçu compte ce qu’une exécution ferait et ne change rien.';

  @override
  String get syncFull => 'Exécution complète';

  @override
  String get syncFullHelp =>
      'Tout relire depuis le début au lieu de reprendre là où la dernière exécution s’est arrêtée.';

  @override
  String get syncPreviewTitle => 'Aperçu';

  @override
  String get syncDoneTitle => 'Exécution terminée';

  @override
  String get syncPreviewNote => 'Rien n’a été modifié.';

  @override
  String syncCounts(int created, int updated, int skipped, int deleted) {
    return '$created créées · $updated mises à jour · $skipped ignorées · $deleted supprimées';
  }

  @override
  String get syncUnmatched => 'Personnes sans correspondance ici';

  @override
  String get syncWarnings => 'Avertissements';

  @override
  String syncWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avertissements',
      one: '1 avertissement',
    );
    return '$_temp0';
  }

  @override
  String get syncRuns => 'Historique des exécutions';

  @override
  String get syncRunsEmpty => 'Aucune exécution terminée.';

  @override
  String get syncRunsEmptyBody =>
      'Une exécution qui échoue n’est pas listée ici ; la source l’indique.';

  @override
  String syncEditTitle(String name) {
    return 'Modifier $name';
  }

  @override
  String get syncFormIntro =>
      'Les réglages et la correspondance sont stockés sur le serveur. Les identifiants y sont scellés et ne sont plus jamais affichés.';

  @override
  String get syncName => 'Nom';

  @override
  String get syncNameHelp => 'Nomme la source au sein de son système.';

  @override
  String get syncMapping => 'Document de correspondance (YAML)';

  @override
  String get syncMappingHelp =>
      'Laissé vide, le document enregistré est conservé.';

  @override
  String get syncMappingPath => 'Fichier de correspondance sur le serveur';

  @override
  String get syncMappingPathHelp =>
      'Lu uniquement dans le dossier de cet espace sous sync.file_root du serveur.';

  @override
  String get syncCredentials => 'Identifiants';

  @override
  String get syncCredentialsHelp =>
      'En écriture seule. N’importe lequel remplace le jeu enregistré ; laissez tout vide pour le garder.';

  @override
  String get syncToken => 'Jeton';

  @override
  String get syncUser => 'Utilisateur';

  @override
  String get syncPassword => 'Mot de passe ou clé d’API';

  @override
  String get syncClearCredentials => 'Retirer les identifiants enregistrés';

  @override
  String get syncCheck => 'Vérifier';

  @override
  String get syncSave => 'Enregistrer la source';

  @override
  String syncMappingFrom(String origin) {
    return 'Correspondance : $origin';
  }

  @override
  String syncCredentialsFrom(String origin) {
    return 'Identifiants : $origin';
  }

  @override
  String get syncFromStored => 'enregistrés sur la source';

  @override
  String get syncFromEnv => 'depuis l’environnement';

  @override
  String get syncFromMappingPath => 'fichier sur le serveur';

  @override
  String get syncFromNone => 'inutile';

  @override
  String get syncFromMissing => 'manquant';

  @override
  String syncSummaryProject(String project) {
    return 'Arrive dans le projet $project';
  }

  @override
  String syncSummaryIdentity(String field) {
    return 'Rapproché par $field';
  }

  @override
  String get retentionTitle => 'Rétention';

  @override
  String get retentionSubtitle =>
      'Combien de temps cet espace garde ses journaux.';

  @override
  String get retentionWindows => 'Conserver pendant';

  @override
  String get retentionWindowsHelp =>
      'En jours. Les enregistrements plus anciens sont retirés quand le journal est purgé.';

  @override
  String get retentionEvents => 'Évènements';

  @override
  String get retentionEventsHelp =>
      'Le flux de mises à jour en direct. 30 jours par défaut.';

  @override
  String get retentionAudit => 'Entrées d’audit';

  @override
  String get retentionAuditHelp => 'Qui a changé quoi. 365 jours par défaut.';

  @override
  String get retentionDeliveries => 'Envois de webhooks';

  @override
  String get retentionDeliveriesHelp =>
      'Le journal des envois. 30 jours par défaut.';

  @override
  String get retentionSave => 'Enregistrer la rétention';

  @override
  String get retentionSaved => 'Rétention enregistrée.';

  @override
  String get retentionPruneSection => 'Purger maintenant';

  @override
  String get retentionPruneHelp =>
      'Retire d’un coup tout ce qui dépasse sa durée, sans attendre que le serveur le fasse.';

  @override
  String get retentionPreview => 'Aperçu';

  @override
  String get retentionPrune => 'Purger';

  @override
  String get retentionPruneTitle => 'Purger les anciens enregistrements ?';

  @override
  String get retentionPruneBody =>
      'Les évènements, entrées d’audit et envois de webhooks au-delà de leur durée sont supprimés définitivement.';

  @override
  String get retentionPruned => 'Purge effectuée.';

  @override
  String retentionWouldPrune(int events, int audit, int deliveries) {
    return 'Retirerait $events évènements, $audit entrées d’audit et $deliveries envois.';
  }

  @override
  String retentionDidPrune(int events, int audit, int deliveries) {
    return '$events évènements, $audit entrées d’audit et $deliveries envois retirés.';
  }

  @override
  String retentionKeptForSubscribers(int count) {
    return '$count évènements au-delà de leur durée sont gardés jusqu’à ce qu’un abonné les ait lus.';
  }

  @override
  String get housekeepingTitle => 'Entretien';

  @override
  String get housekeepingSubtitle =>
      'Retire le travail terminé des listes et vide la corbeille.';

  @override
  String get housekeepingPaused =>
      'L’entretien est suspendu tant que la corbeille est désactivée : aucune règle ne s’applique.';

  @override
  String get housekeepingRules => 'Règles';

  @override
  String get housekeepingRulesHelp =>
      'Un nombre de jours, ou désactivé. Les projets peuvent les remplacer.';

  @override
  String get housekeepingDone =>
      'Les tâches terminées vont à la corbeille après';

  @override
  String get housekeepingDoneHelp => 'Jours depuis leur achèvement.';

  @override
  String get housekeepingCancelled =>
      'Les tâches annulées vont à la corbeille après';

  @override
  String get housekeepingCancelledHelp => 'Jours depuis leur annulation.';

  @override
  String get housekeepingTrash =>
      'La corbeille supprime définitivement les tâches après';

  @override
  String get housekeepingTrashHelp => 'Jours passés dans la corbeille.';

  @override
  String housekeepingPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches échues maintenant.',
      one: '1 tâche échue maintenant.',
      zero: 'Rien d’échu pour l’instant.',
    );
    return '$_temp0';
  }

  @override
  String get housekeepingSave => 'Enregistrer les règles';

  @override
  String get housekeepingSaved => 'Règles enregistrées.';

  @override
  String get housekeepingRunSection => 'Lancer maintenant';

  @override
  String get housekeepingRunHelp =>
      'Applique les règles une fois, par lots, sans attendre le prochain passage du serveur.';

  @override
  String get housekeepingPreview => 'Aperçu';

  @override
  String get housekeepingRun => 'Lancer l’entretien';

  @override
  String get housekeepingRunTitle => 'Lancer l’entretien maintenant ?';

  @override
  String get housekeepingRunBody =>
      'Les tâches terminées au-delà de leur règle vont à la corbeille, et celles au-delà de la règle de corbeille sont supprimées définitivement.';

  @override
  String housekeepingWould(int done, int cancelled, int trash) {
    return 'Déplacerait $done tâches terminées et $cancelled annulées vers la corbeille, et en supprimerait $trash définitivement.';
  }

  @override
  String housekeepingDid(int done, int cancelled, int trash) {
    return '$done tâches terminées et $cancelled annulées déplacées vers la corbeille, $trash supprimées définitivement.';
  }

  @override
  String get trashTitle => 'Corbeille';

  @override
  String get trashSubtitle =>
      'Les tâches supprimées, jusqu’à ce que l’entretien les efface.';

  @override
  String get trashExplain =>
      'Restaurer remet une tâche là où elle était. Supprimer définitivement l’efface avec ses sous-tâches dans la corbeille, comme le fait la règle de corbeille de l’entretien quand elles expirent.';

  @override
  String get trashEmpty => 'La corbeille est vide.';

  @override
  String get trashEmptyBody =>
      'Les tâches supprimées attendent ici et peuvent être restaurées.';

  @override
  String get trashRestore => 'Restaurer';

  @override
  String trashRestored(String ref) {
    return '$ref restaurée.';
  }

  @override
  String trashDeletedAt(String when) {
    return 'supprimée $when';
  }

  @override
  String get trashPurge => 'Supprimer définitivement';

  @override
  String get trashPurgeTitle => 'Supprimer définitivement ?';

  @override
  String trashPurgeBody(String ref, String title) {
    return '$ref « $title » et ses sous-tâches dans la corbeille sont supprimées définitivement. C’est irréversible.';
  }

  @override
  String trashPurged(String ref) {
    return '$ref supprimée définitivement.';
  }

  @override
  String get auditTitle => 'Journal d’audit';

  @override
  String get auditSubtitle =>
      'Chaque changement dans cet espace, les plus récents d’abord.';

  @override
  String get auditSearch => 'Chercher actions, enregistrements et valeurs';

  @override
  String get auditVia => 'Canal';

  @override
  String get auditSource => 'Surface';

  @override
  String get auditMoreFilters => 'Plus de filtres';

  @override
  String auditMoreFiltersCount(int count) {
    return 'Plus de filtres ($count)';
  }

  @override
  String get auditClear => 'Effacer les filtres';

  @override
  String get auditFilters => 'Filtrer le journal d’audit';

  @override
  String get auditApply => 'Appliquer';

  @override
  String get auditActor => 'Acteur';

  @override
  String get auditActorHelp => 'L’identifiant de l’acteur.';

  @override
  String get auditAction => 'Action';

  @override
  String get auditToken => 'Jeton d’API';

  @override
  String get auditTokenHelp => 'Le nom du jeton.';

  @override
  String auditSince(String day) {
    return 'Depuis le $day';
  }

  @override
  String auditUntil(String day) {
    return 'Jusqu’au $day';
  }

  @override
  String get auditAnyTime => 'n’importe quand';

  @override
  String get auditEmpty => 'Rien d’enregistré pour l’instant.';

  @override
  String get auditEmptyBody =>
      'Les changements apparaissent ici à mesure que personnes et agents les font.';

  @override
  String get auditNoMatch => 'Aucune entrée ne correspond.';

  @override
  String get auditNoMatchBody => 'Assouplissez ou effacez les filtres.';

  @override
  String get auditPick => 'Choisissez une entrée';

  @override
  String get auditPickBody => 'Son détail s’affiche ici.';

  @override
  String get auditSeq => 'Entrée';

  @override
  String get auditWhen => 'Quand';

  @override
  String get auditSystem => 'le système';

  @override
  String get auditSubject => 'Enregistrement';

  @override
  String get auditTokenId => 'Identifiant du jeton';

  @override
  String get auditSession => 'Session';

  @override
  String get auditKey => 'Clé SSH';

  @override
  String get auditClient => 'Adresse du client';

  @override
  String get auditOrigin => 'Origine';

  @override
  String get auditHost => 'Hôte';

  @override
  String get auditOsUser => 'Utilisateur système';

  @override
  String get auditJob => 'Tâche de fond';

  @override
  String get auditUserAgent => 'Agent utilisateur';

  @override
  String get auditBefore => 'Avant';

  @override
  String get auditAfter => 'Après';

  @override
  String get timeJustNow => 'à l’instant';

  @override
  String get timeInAMoment => 'dans un instant';

  @override
  String timeAgoMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'il y a $n minutes',
      one: 'il y a 1 minute',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'il y a $n heures',
      one: 'il y a 1 heure',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'il y a $n jours',
      one: 'il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'il y a $n mois',
      one: 'il y a 1 mois',
    );
    return '$_temp0';
  }

  @override
  String timeAgoYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'il y a $n ans',
      one: 'il y a 1 an',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'dans $n minutes',
      one: 'dans 1 minute',
    );
    return '$_temp0';
  }

  @override
  String timeInHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'dans $n heures',
      one: 'dans 1 heure',
    );
    return '$_temp0';
  }

  @override
  String timeInDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'dans $n jours',
      one: 'dans 1 jour',
    );
    return '$_temp0';
  }

  @override
  String timeInMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'dans $n mois',
      one: 'dans 1 mois',
    );
    return '$_temp0';
  }

  @override
  String timeInYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'dans $n ans',
      one: 'dans 1 an',
    );
    return '$_temp0';
  }

  @override
  String get timeFormatIso => 'ISO';

  @override
  String get timeFormatRfc3339 => 'RFC 3339';

  @override
  String get timeFormatShort => 'Court';

  @override
  String get timeFormatLong => 'Long';

  @override
  String get timeFormatDotted => 'Avec points';

  @override
  String get timeFormatDayfirst => 'Jour en premier';

  @override
  String get timeFormatUs => 'États-Unis';

  @override
  String get timeFormatRelative => 'Relatif';

  @override
  String get settingsSearchHint => 'Rechercher dans les paramètres';

  @override
  String settingsNoMatch(String query) {
    return 'Aucun paramètre ne correspond à « $query »';
  }

  @override
  String get settingsNoMatchBody =>
      'Essayez un autre mot ou effacez la recherche.';

  @override
  String get settingsScopeDevice => 'Sur cet appareil';

  @override
  String get settingsScopeAccount => 'Synchronisé avec votre compte';

  @override
  String get settingsScopeTenant => 'Tout l’espace';

  @override
  String get settingsGroupDevice => 'Cet appareil';

  @override
  String get settingsGroupDeviceHelp =>
      'Conservés sur cet appareil seulement. Vos autres appareils et le web ont les leurs.';

  @override
  String settingsGroupAccount(String tenant) {
    return 'Votre compte sur $tenant';
  }

  @override
  String get settingsGroupAccountHelp =>
      'Conservés par le serveur avec votre compte : ils vous suivent sur chaque appareil, sur le web et en ligne de commande.';

  @override
  String get settingsGroupTenant => 'Cet espace';

  @override
  String settingsGroupTenantHelp(String tenant) {
    return 'Paramètres pour tout le monde dans $tenant. Seuls les administrateurs les voient.';
  }

  @override
  String get settingsReduceMotion => 'Réduire les animations';

  @override
  String get settingsReduceMotionHelp =>
      'L’application reste immobile même si le système autorise les animations.';

  @override
  String get settingsHaptics => 'Retour haptique';

  @override
  String get settingsHapticsHelp =>
      'Une courte vibration lors des balayages, des tâches terminées et des refus.';

  @override
  String get settingsLanguageHelp =>
      'tix ne garde aucune langue avec votre compte : chaque appareil et navigateur choisit la sienne.';

  @override
  String get settingsStartTitle => 'Écran de démarrage';

  @override
  String get settingsStartHelp =>
      'L’endroit où l’application s’ouvre au démarrage ou après la connexion.';

  @override
  String get settingsDeviceNotifTitle => 'Notifications sur cet appareil';

  @override
  String get settingsDeviceNotifSubtitle =>
      'Si cet appareil vous alerte, et pour quels types';

  @override
  String get settingsProfileTitle => 'Profil';

  @override
  String get settingsDatesTitle => 'Dates et heures';

  @override
  String get settingsDatesHelp =>
      'Conservés avec votre compte : chaque appareil, navigateur et terminal affiche les dates ainsi. « Hériter » suit la valeur par défaut de l’espace, qui suit celle du serveur.';

  @override
  String get settingsDateFormat => 'Format de date';

  @override
  String get settingsDateFormatHelp =>
      'La façon dont chaque horodatage est écrit dans l’application. Sur le web, tix lit les dates saisies de la même façon.';

  @override
  String get settingsTimeZone => 'Fuseau horaire';

  @override
  String get settingsTimeZoneHelp =>
      'Le fuseau dans lequel chaque heure est affichée et où se termine la journée pour les échéances.';

  @override
  String get settingsInherit => 'Hériter';

  @override
  String settingsInheritValue(String value) {
    return 'Hériter : $value';
  }

  @override
  String settingsInUse(String value, String source) {
    return 'Utilisé : $value, venant de $source';
  }

  @override
  String get settingsSourceUser => 'votre choix';

  @override
  String get settingsSourceTenant => 'la valeur de l’espace';

  @override
  String get settingsSourceGlobal => 'la valeur du serveur';

  @override
  String get settingsDeviceFormat => 'le format de cet appareil';

  @override
  String settingsDeviceZone(String zone) {
    return 'le fuseau de cet appareil ($zone)';
  }

  @override
  String get settingsDatesNotPersonal =>
      'Cet identifiant n’est pas une personne : il lit les valeurs de l’espace et ne peut pas avoir les siennes.';

  @override
  String get settingsDatesLoading =>
      'Lecture de vos réglages de date sur le serveur…';

  @override
  String get settingsDatesUnsupported =>
      'Cette version de tix ne conserve pas de préférences de date, les dates suivent donc cet appareil. Un serveur tix plus récent les ajoute.';

  @override
  String get settingsDatesFailed =>
      'Le serveur n’a pas répondu, les dates suivent donc cet appareil pour l’instant.';

  @override
  String get settingsDatesSaved => 'Enregistré avec votre compte';

  @override
  String get settingsZoneSearch => 'Rechercher un fuseau';

  @override
  String get settingsZoneNone => 'Aucun fuseau ne correspond.';

  @override
  String get settingsInboxTitle => 'Boîte de réception et canaux';

  @override
  String get settingsInboxSubtitle =>
      'Ce qui arrive dans votre boîte, et vos canaux personnels';

  @override
  String get settingsFiltersTitle => 'Filtres enregistrés';

  @override
  String get settingsFiltersSubtitle =>
      'Renommer, partager ou supprimer vos filtres';

  @override
  String get settingsArrangementTitle => 'Tableau et couloirs';

  @override
  String get settingsArrangementHelp =>
      'Les groupes que vous avez masqués, suivis, réduits ou déplacés sur le tableau, dans les couloirs et dans Mon travail.';

  @override
  String get settingsArrangementReset => 'Réinitialiser';

  @override
  String get settingsArrangementResetTitle =>
      'Réinitialiser le tableau et les couloirs';

  @override
  String get settingsArrangementResetBody =>
      'Chaque groupe du tableau, des couloirs et de Mon travail revient à la place choisie par tix, sur chaque appareil et sur le web. Impossible d’annuler.';

  @override
  String get settingsArrangementDone => 'Agencement réinitialisé';

  @override
  String settingsTenantManage(String tenant) {
    return 'Gérer $tenant';
  }

  @override
  String get settingsTenantManageSubtitle =>
      'Projets, workflows, champs, personnes et réglages de l’espace';

  @override
  String paletteSettingsItem(String name) {
    return 'Paramètres : $name';
  }

  @override
  String get savedFiltersEmpty => 'Aucun filtre enregistré';

  @override
  String get savedFiltersEmptyBody =>
      'Enregistrez un filtre depuis la liste des tâches pour le retrouver ici, sur chaque appareil.';

  @override
  String get savedFilterSharedBadge => 'Partagé';

  @override
  String get savedFilterTheirs =>
      'Partagé avec vous ; seuls son propriétaire et les administrateurs peuvent le modifier.';

  @override
  String durationDays(int n) {
    return '$n j';
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
      'Ce n’est pas un lien d’invitation. Il ressemble à https://votre-serveur/invite/tix_inv_…';

  @override
  String get methodInvite => 'Invitation';

  @override
  String get inviteLinkLabel => 'Lien d’invitation';

  @override
  String get inviteLinkHint => 'https://tix.example.com/invite/tix_inv_…';

  @override
  String get inviteLinkHelp =>
      'Collez le lien de votre e-mail d’invitation, ou partagez-le vers tix depuis une autre application. Le serveur est ajouté pour vous.';

  @override
  String get invitePaste => 'Coller le lien d’invitation';

  @override
  String get inviteCheck => 'Vérifier l’invitation';

  @override
  String inviteJoin(String tenant, String host) {
    return 'Rejoindre $tenant sur $host';
  }

  @override
  String inviteJoinServer(String host) {
    return 'Rejoindre $host';
  }

  @override
  String inviteAs(String email) {
    return 'en tant que $email';
  }

  @override
  String inviteExpires(String when) {
    return 'Le lien fonctionne jusqu’au $when.';
  }

  @override
  String get inviteExistingAccount =>
      'Cette adresse a déjà un compte tix. Saisissez son mot de passe pour accepter ; le compte n’est pas modifié.';

  @override
  String get inviteDisplayName => 'Votre nom';

  @override
  String get inviteNewPassword => 'Nouveau mot de passe';

  @override
  String get inviteNewPasswordHelp =>
      'Au moins 12 caractères. Il vous identifie partout, pas seulement ici.';

  @override
  String get inviteExistingPasswordHelp =>
      'Le mot de passe avec lequel vous vous identifiez déjà sur tix.';

  @override
  String get inviteCodeHelp =>
      'Un code de votre application d’authentification, que ce compte utilise déjà.';

  @override
  String get inviteAccept => 'Accepter l’invitation';

  @override
  String get notifHideContent =>
      'Masquer le contenu des tâches dans les notifications';

  @override
  String get notifHideContentHelp =>
      'Les notifications indiquent seulement « Nouveau dans votre boîte de réception », pour ce contexte.';

  @override
  String get notifPrivateTitle => 'Nouveau dans votre boîte de réception';

  @override
  String get notifPrivateBody => 'Ouvrez tix pour le lire.';

  @override
  String get taskDetailLease => 'Durée de réservation';

  @override
  String get taskDetailLeaseInfo =>
      'Durée d’une réservation de cette tâche par un agent qui ne précise aucune durée, et la durée maximale de toute réservation. La tâche, le projet, le workflow et l’espace peuvent la fixer ; le plus proche l’emporte.';

  @override
  String taskDetailLeaseValue(String length, String source) {
    return '$length, défini par $source';
  }

  @override
  String taskDetailLeaseMax(String length, String source) {
    return 'Au plus $length, défini par $source';
  }

  @override
  String get taskDetailLeaseClamped => 'Ramenée au plafond.';

  @override
  String get leaseSourceClaim => 'la réservation';

  @override
  String get leaseSourceTask => 'la tâche';

  @override
  String get leaseSourceProject => 'le projet';

  @override
  String get leaseSourceWorkflow => 'le workflow';

  @override
  String get leaseSourceTenant => 'l’espace';

  @override
  String get leaseSourceDeployment => 'le serveur';

  @override
  String get leaseSourceBuiltin => 'la valeur par défaut de tix';

  @override
  String get statusTitle => 'État du serveur';

  @override
  String get statusInstallation => 'Installation';

  @override
  String get statusVersion => 'Version';

  @override
  String get statusSchema => 'Schéma';

  @override
  String get statusEngine => 'Base de données';

  @override
  String get statusAnswering => 'Répondu par';

  @override
  String get statusObserved => 'Vérifié';

  @override
  String get statusServers => 'Processus serveur';

  @override
  String get statusServersInfo =>
      'Chaque processus tix inscrit sur cette base de données. Celui qui manque trois signaux de vie est indiqué comme silencieux.';

  @override
  String get statusNoServers =>
      'Aucun processus inscrit. Celui qui répond fonctionne peut-être sans le registre.';

  @override
  String get statusAttached => 'Signal de vie';

  @override
  String statusDetached(String when) {
    return 'Silencieux depuis le $when';
  }

  @override
  String statusUptime(String length) {
    return 'actif depuis $length';
  }

  @override
  String statusConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count connexions',
      one: '1 connexion',
    );
    return '$_temp0';
  }

  @override
  String get statusWork => 'Cet espace';

  @override
  String get statusProjects => 'Projets';

  @override
  String get statusTasks => 'Tâches';

  @override
  String get statusClaimed => 'Réservées';

  @override
  String get statusUnswept => 'Réservations expirées non nettoyées';

  @override
  String get statusWebhooksPending => 'Livraisons de webhook en attente';

  @override
  String get statusWebhooksFailed => 'Livraisons de webhook échouées';

  @override
  String get statusSecondFactor => 'Second facteur';

  @override
  String get statusKey => 'Clé de scellement définie';

  @override
  String get statusRequireWeb => 'Requis dans le navigateur';

  @override
  String get statusRequireCli =>
      'Requis en ligne de commande et dans les applications';

  @override
  String get statusRequireSsh => 'Requis via SSH';

  @override
  String get statusAdmins => 'Administrateurs équipés';

  @override
  String statusAdminsEnrolled(int enrolled, int total) {
    return '$enrolled sur $total';
  }

  @override
  String get statusUnrecoverable =>
      'Certains seconds facteurs sont illisibles : la clé de scellement manque. Ces personnes doivent les faire effacer puis s’inscrire à nouveau.';

  @override
  String get statusYes => 'Oui';

  @override
  String get statusNo => 'Non';

  @override
  String get bundlesTitle => 'Lots';

  @override
  String get bundleExportTitle => 'Exporter un lot';

  @override
  String get bundleExportSubtitle =>
      'Une configuration réutilisable en un seul fichier, pour un autre espace ou serveur';

  @override
  String get bundleExportInfo =>
      'Un lot contient des workflows, des définitions de champs, des étiquettes, des projets comme modèles et des webhooks, jamais leurs tâches. Les secrets de webhook n’y figurent jamais.';

  @override
  String get bundleKindWorkflow => 'Workflows';

  @override
  String get bundleKindField => 'Champs personnalisés';

  @override
  String get bundleKindTag => 'Étiquettes';

  @override
  String get bundleKindProject => 'Modèles de projet';

  @override
  String get bundleKindWebhook => 'Webhooks';

  @override
  String get bundleKindsAll =>
      'Rien de sélectionné : le lot contient tous les types.';

  @override
  String get bundleKindsSome => 'Seuls les types sélectionnés sont inclus.';

  @override
  String get bundleName => 'Nom';

  @override
  String get bundleNameHelp =>
      'Identifie le lot pour qui le reçoit. Facultatif.';

  @override
  String get bundleExport => 'Exporter le lot';

  @override
  String bundleExported(String name) {
    return '$name exporté';
  }

  @override
  String get bundleImportTitle => 'Importer un lot';

  @override
  String get bundleImportSubtitle =>
      'Aperçu d’abord, puis appliqué en une fois';

  @override
  String get bundleImportInfo =>
      'Un lot s’applique de façon atomique : tout est importé, ou rien. L’aperçu n’écrit rien.';

  @override
  String get bundlePick => 'Choisir un fichier de lot';

  @override
  String get bundleCollision => 'Quand une clé est déjà prise';

  @override
  String get bundleCollisionAsk => 'Arrêter et signaler';

  @override
  String get bundleCollisionSkip => 'Garder le mien';

  @override
  String get bundleCollisionRename => 'Importer sous une nouvelle clé';

  @override
  String get bundleCollisionReplace => 'Remplacer le mien';

  @override
  String get bundleProject => 'Projet des champs personnalisés';

  @override
  String get bundleProjectHelp =>
      'La clé du projet qui reçoit les définitions de champs. Nécessaire seulement si le lot en contient.';

  @override
  String get bundlePreview => 'Aperçu';

  @override
  String get bundleImport => 'Importer le lot';

  @override
  String get bundleReplaceBody =>
      'Les composants ayant la même clé sont écrasés par ceux du lot. Cette action est irréversible.';

  @override
  String get bundleImported => 'Lot importé.';

  @override
  String get bundlePlan => 'Ce que ferait l’import';

  @override
  String get bundleDone => 'Ce qu’a fait l’import';

  @override
  String get bundleEmpty => 'Le lot ne contient rien.';

  @override
  String get bundleActionCreate => 'Nouveau';

  @override
  String get bundleActionReplace => 'Remplacé';

  @override
  String get bundleActionRename => 'Renommé';

  @override
  String get bundleActionSkip => 'Ignoré';

  @override
  String get snapshotTitle => 'Importer un instantané';

  @override
  String get snapshotFileTitle => 'Fichier d’instantané';

  @override
  String get snapshotFileSubtitle =>
      'Un fichier issu de l’export d’un espace entier';

  @override
  String get snapshotInfo =>
      'Un instantané contient projets, workflows, champs, tâches et commentaires. Vérifiez ce qu’il changerait par un essai à blanc avant d’importer.';

  @override
  String get snapshotPick => 'Choisir un fichier d’instantané';

  @override
  String get snapshotMerge => 'Fusionner';

  @override
  String get snapshotReplace => 'Remplacer';

  @override
  String get snapshotMergeHelp =>
      'Ajoute ce qui est nouveau et met à jour ce qui a changé. Rien n’est supprimé.';

  @override
  String get snapshotReplaceHelp =>
      'Supprime aussi les tâches et champs de chaque projet importé absents de l’instantané.';

  @override
  String get snapshotDryRun => 'Essai à blanc';

  @override
  String get snapshotImport => 'Importer l’instantané';

  @override
  String get snapshotMergeBody =>
      'Les enregistrements de l’instantané sont ajoutés à cet espace et mettent à jour ceux qu’il contient déjà.';

  @override
  String get snapshotReplaceBody =>
      'Les tâches et champs des projets importés absents de l’instantané sont supprimés. Cette action est irréversible.';

  @override
  String get snapshotImported => 'Instantané importé.';

  @override
  String get snapshotPlan => 'Ce que ferait l’import';

  @override
  String get snapshotDone => 'Ce qu’a fait l’import';

  @override
  String get snapshotCreated => 'Créés';

  @override
  String get snapshotUpdated => 'Mis à jour';

  @override
  String get snapshotDeleted => 'Supprimés';

  @override
  String get snapshotSkipped => 'Inchangés';

  @override
  String manageInheritedValue(String value) {
    return 'Hérité : $value';
  }

  @override
  String manageDurationSaved(String value) {
    return 'Enregistré : $value. Vide hérite.';
  }

  @override
  String get projectsShowArchived => 'Afficher les archivés';

  @override
  String get projectStar => 'Ajouter le projet aux favoris';

  @override
  String get projectUnstar => 'Retirer des favoris';

  @override
  String projectStarred(String name) {
    return '$name ajouté aux favoris';
  }

  @override
  String projectUnstarred(String name) {
    return '$name retiré des favoris';
  }

  @override
  String get projectsStarredHeading => 'Favoris';

  @override
  String get projectsRestHeading => 'Autres projets';

  @override
  String syncOpStarProject(String key) {
    return '$key : projet en favori';
  }

  @override
  String syncOpUnstarProject(String key) {
    return '$key : projet retiré des favoris';
  }

  @override
  String get manageBundlesSubtitle =>
      'Workflows, champs, étiquettes et webhooks en un fichier';

  @override
  String get manageSnapshotSubtitle => 'Importer l’export d’un espace entier';

  @override
  String get manageStatusSubtitle =>
      'Version, processus serveur et travail de l’espace';

  @override
  String get rotateToken => 'Renouveler le jeton';

  @override
  String rotateTokenBody(String name) {
    return '$name reçoit un nouveau jeton avec le même nom, les mêmes portées et la même durée, et l’application ne garde que le nouveau. Tout ce qui utilise l’ancien jeton cesse de fonctionner dans une minute.';
  }

  @override
  String get tokenRotated =>
      'Jeton renouvelé. L’ancien s’arrête dans une minute.';

  @override
  String get offlineTitle => 'Hors ligne';

  @override
  String get offlineSubtitle => 'Ce qui reste disponible sans connexion';

  @override
  String get offlineLocal =>
      'Cette instance est une base de données sur cet appareil, elle est donc toujours disponible. Le mode hors ligne ne concerne que les instances distantes.';

  @override
  String get offlineAvailableTitle => 'Disponible hors ligne';

  @override
  String get offlineAvailableSubtitle =>
      'Conservé sur cet appareil pour l\'instance et l\'organisation actives, avec les commentaires et sous-tâches de chaque tâche.';

  @override
  String get offlineStorageTitle => 'Stockage';

  @override
  String get offlineStorageSubtitle =>
      'Copies enregistrées de ce contexte, modifications en attente d\'envoi comprises.';

  @override
  String get offlineStorageCounting => 'Calcul…';

  @override
  String get offlineStorageUnknown => 'Taille inconnue';

  @override
  String get offlineClear => 'Effacer les copies';

  @override
  String get offlineClearTitle => 'Effacer les copies enregistrées ?';

  @override
  String get offlineClearBody =>
      'Les écrans se rechargent depuis le serveur et rien n\'est disponible hors ligne jusqu\'à la prochaine synchronisation. Les modifications en attente d\'envoi sont conservées.';

  @override
  String get offlineSyncTitle => 'Synchronisation';

  @override
  String get offlineSyncSubtitle =>
      'S\'exécute à l\'ouverture de ce contexte et toutes les 30 minutes. Sur un téléphone, attend le Wi-Fi et assez de batterie ; « Synchroniser » s\'exécute toujours.';

  @override
  String get offlineSyncNow => 'Synchroniser';

  @override
  String get offlineNeverSynced => 'Pas encore synchronisé';

  @override
  String offlineStorageUsed(String size) {
    return '$size utilisés';
  }

  @override
  String offlineLastSynced(String time) {
    return 'Dernière synchronisation $time';
  }

  @override
  String offlineSavedCopy(String time) {
    return 'Hors ligne, copie enregistrée du $time';
  }

  @override
  String get errorSecretStorage =>
      'Le stockage sécurisé de cet appareil est verrouillé ou a refusé l’écriture, rien n’a donc été modifié. Déverrouillez-le et réessayez.';

  @override
  String get tokenUnsavedTitle => 'Jeton renouvelé mais non enregistré';

  @override
  String get tokenUnsavedHeading => 'Copiez ce jeton maintenant';

  @override
  String get tokenUnsavedNote =>
      'Le stockage sécurisé de cet appareil a refusé le nouveau jeton. Il n’est affiché que cette fois, et l’ancien jeton cesse de fonctionner dans une minute. L’application utilise le nouveau jusqu’à sa fermeture ; ensuite, reconnectez-vous avec lui.';

  @override
  String get tokenUnsavedDone => 'Je l’ai copié';

  @override
  String get syncMarkUnsynced => 'Non synchronisé';

  @override
  String get syncMarkDraft => 'Brouillon';

  @override
  String get syncMarkCheck => 'À vérifier';

  @override
  String get syncMarkConflict => 'Conflit';

  @override
  String get syncMarkFailed => 'Refusé';

  @override
  String get syncConflictsTitle => 'Conflits';

  @override
  String get syncConflictsSubtitle =>
      'Modifications faites hors ligne et leur synchronisation';

  @override
  String get syncSendNow => 'Envoyer maintenant';

  @override
  String get syncEmptyTitle => 'Tout est synchronisé';

  @override
  String get syncConflictsEmptyBody =>
      'Les modifications faites hors ligne attendent ici le retour du serveur.';

  @override
  String syncConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflits',
      one: '1 conflit',
    );
    return '$_temp0';
  }

  @override
  String get syncConflictsHelp =>
      'Quelqu\'un a modifié la même chose sur le serveur pendant que vous étiez hors ligne.';

  @override
  String get syncKeepAllMine => 'Tout garder (les miennes)';

  @override
  String get syncKeepAllTheirs => 'Tout garder (les leurs)';

  @override
  String syncWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications en attente',
      one: '1 modification en attente',
    );
    return '$_temp0';
  }

  @override
  String get syncHistory => 'Historique';

  @override
  String get syncHistoryHelp =>
      'Conflits réglés. Inversez-en un pour envoyer le côté qui n\'a pas été gardé.';

  @override
  String get syncFieldTitle => 'Titre';

  @override
  String get syncFieldBody => 'Description';

  @override
  String get syncFieldPriority => 'Priorité';

  @override
  String get syncFieldAssignee => 'Responsable';

  @override
  String get syncFieldDue => 'Échéance';

  @override
  String get syncFieldTags => 'Étiquettes';

  @override
  String get syncFieldStatus => 'Statut';

  @override
  String get syncFieldRecurrence => 'Répétition';

  @override
  String get syncFieldParent => 'Parent';

  @override
  String get syncValueEmpty => '(vide)';

  @override
  String get syncMine => 'La mienne';

  @override
  String get syncTheirs => 'La leur';

  @override
  String get syncKeepMine => 'Garder la mienne';

  @override
  String get syncKeepTheirs => 'Garder la leur';

  @override
  String get syncEditChange => 'Modifier';

  @override
  String get syncEditChangeTitle => 'Modifier avant l\'envoi';

  @override
  String get syncEditSend => 'Envoyer';

  @override
  String syncTheirsWas(String value) {
    return 'Sur le serveur : $value';
  }

  @override
  String get syncDeletedBody =>
      'Cette tâche a été supprimée sur le serveur après votre modification.';

  @override
  String get syncRestoreApply => 'Restaurer et appliquer';

  @override
  String get syncDiscardMine => 'Abandonner la mienne';

  @override
  String get syncDiscardMineTitle => 'Abandonner vos modifications ?';

  @override
  String get syncDiscardMineBody =>
      'Tout ce que vous avez modifié sur cette tâche hors ligne est abandonné. La tâche reste supprimée.';

  @override
  String syncMoveRefused(String status, String reason) {
    return 'Le passage à $status a été refusé : $reason';
  }

  @override
  String get syncMoveElsewhere => 'Déplacer ailleurs';

  @override
  String syncOpUpdate(String ref, String fields) {
    return '$ref : $fields';
  }

  @override
  String syncOpCheck(String ref) {
    return '$ref : élément de liste';
  }

  @override
  String syncOpMove(String ref, String status) {
    return '$ref : passer à $status';
  }

  @override
  String syncOpStar(String ref) {
    return '$ref : favori';
  }

  @override
  String syncOpUnstar(String ref) {
    return '$ref : retirer le favori';
  }

  @override
  String syncOpSnooze(String ref) {
    return '$ref : mise en veille';
  }

  @override
  String syncOpCreate(String title) {
    return 'Nouvelle tâche : $title';
  }

  @override
  String syncOpComment(String ref) {
    return '$ref : commentaire';
  }

  @override
  String syncOpTagAdd(String ref, String tag) {
    return '$ref : ajouter #$tag';
  }

  @override
  String syncOpTagRemove(String ref, String tag) {
    return '$ref : retirer #$tag';
  }

  @override
  String syncOpDependency(String ref, String other) {
    return '$ref : attend $other';
  }

  @override
  String syncOpArtifact(String ref) {
    return '$ref : pièce jointe';
  }

  @override
  String syncOpRestore(String ref) {
    return '$ref : restaurer';
  }

  @override
  String get syncDiscardTitle => 'Abandonner cette modification ?';

  @override
  String get syncDiscard => 'Abandonner';

  @override
  String syncRefused(String reason) {
    return 'Le serveur a refusé : $reason';
  }

  @override
  String get syncCheckBody =>
      'La réponse a été perdue, cette tâche existe peut-être déjà. Vérifiez le projet, puis envoyez-la ou abandonnez-la.';

  @override
  String get syncSendAnyway => 'Envoyer quand même';

  @override
  String get syncAlreadyThere => 'Elle existe déjà';

  @override
  String get syncRetry => 'Réessayer';

  @override
  String get syncKeptMine => 'La mienne gardée';

  @override
  String get syncKeptTheirs => 'La leur gardée';

  @override
  String get syncKeptEdited => 'Modification envoyée';

  @override
  String get syncKeptRestored => 'Restaurée et appliquée';

  @override
  String get syncKeptDiscarded => 'La mienne abandonnée';

  @override
  String syncByPolicy(String what) {
    return '$what, selon votre réglage';
  }

  @override
  String get syncReverse => 'Inverser';

  @override
  String syncBannerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications attendent la synchronisation.',
      one: '1 modification attend la synchronisation.',
    );
    return '$_temp0';
  }

  @override
  String get syncBannerConflict =>
      'Vos modifications hors ligne demandent une décision.';

  @override
  String get syncBannerDraft =>
      'Créée hors ligne. Elle reçoit sa référence à la synchronisation.';

  @override
  String get syncResolve => 'Résoudre';

  @override
  String syncBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflits à résoudre',
      one: '1 conflit à résoudre',
    );
    return '$_temp0';
  }

  @override
  String get syncPolicyLabel => 'En cas de conflit';

  @override
  String get syncPolicyHelp =>
      'Pour les modifications hors ligne que quelqu\'un d\'autre a aussi faites. Chaque conflit reste dans Conflits, où il peut être inversé.';

  @override
  String get syncPolicyAsk => 'Demander';

  @override
  String get syncPolicyMine => 'Garder la mienne';

  @override
  String get syncPolicyTheirs => 'Garder la leur';

  @override
  String get syncOpenConflicts => 'Conflits et modifications non synchronisées';

  @override
  String get syncDiscardAll =>
      'Abandonner toutes les modifications non synchronisées';

  @override
  String get syncDiscardAllTitle =>
      'Abandonner toutes les modifications non synchronisées ?';

  @override
  String syncDiscardAllBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count modifications hors ligne sont abandonnées et ne seront jamais envoyées. Les brouillons disparaissent.',
      one: '1 modification hors ligne est abandonnée et ne sera jamais envoyée. Les brouillons disparaissent.',
    );
    return '$_temp0';
  }

  @override
  String syncUnsentLost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count modifications hors ligne n\'ont pas encore été envoyées et seront perdues.',
      one: '1 modification hors ligne n\'a pas encore été envoyée et sera perdue.',
    );
    return '$_temp0';
  }

  @override
  String get syncStateUnreadable =>
      'Les modifications en attente sur cet appareil n\'ont pas pu être lues. Elles sont conservées telles quelles et ne sont pas envoyées.';

  @override
  String get settingsAdvanced => 'Avancé';

  @override
  String get settingsAdbControl => 'Autoriser le contrôle par ADB';

  @override
  String get settingsAdbControlHelp =>
      'Permet à un ordinateur connecté en débogage USB de changer de contexte, d\'ajouter des tâches et de modifier les réglages de tix. Lire l\'état de l\'application et ouvrir des liens tix:// fonctionne sans cela.';

  @override
  String get linkNotRecognised => 'Lien non reconnu';

  @override
  String get linkPickContextTitle => 'Ouvrir ce lien dans quel contexte ?';

  @override
  String get linkPickContextBody =>
      'Le lien correspond à plusieurs de vos contextes.';

  @override
  String get notifActionDone => 'Terminé';

  @override
  String get notifActionSnooze => 'Reporter';

  @override
  String get notifActionReply => 'Répondre';

  @override
  String get notifReplyLabel => 'Écrire un commentaire';

  @override
  String get notifActionFailedDone => 'Impossible de le marquer comme terminé';

  @override
  String get notifActionFailedSnooze => 'Impossible de le reporter';

  @override
  String get notifActionFailedReply => 'Impossible d\'envoyer votre réponse';

  @override
  String get notifActionFailedBody => 'Ouvrez tix pour réessayer.';

  @override
  String get pinToHome => 'Ajouter à l\'écran d\'accueil';

  @override
  String get pinFailed => 'Impossible de l\'ajouter à l\'écran d\'accueil';

  @override
  String get trayOpen => 'Ouvrir tix';

  @override
  String trayInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Boîte de réception ($count non lus)',
      one: 'Boîte de réception (1 non lu)',
      zero: 'Boîte de réception',
    );
    return '$_temp0';
  }

  @override
  String get trayQuit => 'Quitter tix';

  @override
  String get trayStatusSignedOut => 'tix · non connecté';

  @override
  String trayStatusHeadline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tix · $count instances connectées',
      one: 'tix · 1 instance connectée',
    );
    return '$_temp0';
  }

  @override
  String trayStatusInstance(String name, String place, String state) {
    return '$name ($place) : $state';
  }

  @override
  String trayStatusInstanceQuiet(String name, String place) {
    return '$name ($place)';
  }

  @override
  String get trayStatusLocal => 'locale';

  @override
  String get trayStatusLive => 'en direct';

  @override
  String get trayStatusConnecting => 'connexion';

  @override
  String get trayStatusSyncing => 'synchronisation';

  @override
  String get trayStatusOffline => 'hors ligne';

  @override
  String trayStatusSynced(String ago) {
    return 'synchronisé $ago';
  }

  @override
  String trayStatusQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications en attente',
      one: '1 modification en attente',
    );
    return '$_temp0';
  }

  @override
  String trayStatusMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count autres',
      one: '+1 autre',
    );
    return '$_temp0';
  }

  @override
  String trayStatusUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count non lus dans la boîte de réception',
      one: '1 non lu dans la boîte de réception',
    );
    return '$_temp0';
  }

  @override
  String get settingsDesktop => 'Bureau';

  @override
  String get settingsDesktopHelp =>
      'Le comportement de tix sur cet ordinateur : l’icône dans la zone de notification, le lancement à l’ouverture de session et un raccourci qui fonctionne dans toutes les applications.';

  @override
  String get settingsCloseToTray => 'Rester dans la zone de notification';

  @override
  String get settingsCloseToTrayHelp =>
      'Fermer la fenêtre la masque, et la synchronisation et les notifications continuent. Quittez depuis le menu de l’icône.';

  @override
  String get settingsCloseToTrayNone =>
      'Ce bureau n’affiche pas d’icônes de notification, donc fermer la fenêtre quitte tix.';

  @override
  String get settingsAutostart => 'Lancer à l’ouverture de session';

  @override
  String get settingsAutostartHelp =>
      'tix démarre quand vous ouvrez une session sur cet ordinateur.';

  @override
  String get settingsAutostartFailed =>
      'Impossible de modifier le lancement à l’ouverture de session';

  @override
  String get settingsHotkey =>
      'Ajout rapide depuis n’importe quelle application';

  @override
  String settingsHotkeyHelp(String keys) {
    return '$keys ouvre l’ajout rapide, même quand tix est en arrière-plan.';
  }

  @override
  String settingsHotkeyTaken(String keys) {
    return '$keys est déjà utilisé par une autre application';
  }

  @override
  String get goWatch => 'Aller à Activité';

  @override
  String get watchTitle => 'Activité';

  @override
  String get watchSubtitle =>
      'Les événements de l\'organisation au moment où ils arrivent, les plus récents en premier.';

  @override
  String get watchPause => 'Mettre en pause';

  @override
  String get watchResume => 'Reprendre';

  @override
  String get watchClear => 'Vider la liste';

  @override
  String get watchPaused => 'En pause.';

  @override
  String watchPausedNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'En pause, $count nouveaux événements.',
      one: 'En pause, 1 nouvel événement.',
    );
    return '$_temp0';
  }

  @override
  String get watchFilters => 'Filtres';

  @override
  String watchFiltersCount(int count) {
    return 'Filtres ($count)';
  }

  @override
  String get watchAllTypes => 'Tous les types';

  @override
  String watchFiltering(String filters) {
    return 'Filtré sur $filters';
  }

  @override
  String watchFilterProject(String projects) {
    return 'projet $projects';
  }

  @override
  String watchFilterType(String types) {
    return 'type $types';
  }

  @override
  String watchFilterActor(String actors) {
    return 'acteur $actors';
  }

  @override
  String watchFilterSince(int seq) {
    return 'après n° $seq';
  }

  @override
  String get watchProjects => 'Projets';

  @override
  String get watchProjectsHelp =>
      'Envoyé au serveur. Sans choix, tous les projets sont suivis.';

  @override
  String get watchTypes => 'Types d\'événement';

  @override
  String get watchTypesHelp =>
      'Séparés par des virgules, envoyés au serveur. Un * final correspond à un préfixe, comme task.*.';

  @override
  String get watchActors => 'Acteurs';

  @override
  String get watchActorsHelp =>
      'Identifiants ou pseudos, séparés par des virgules. Comparés sur cet appareil, comme le fait tix watch.';

  @override
  String get watchReplay => 'Rejouer depuis le numéro de séquence';

  @override
  String get watchReplayHelp =>
      'Affiche à nouveau les événements après ce numéro, puis suit en direct. Vide commence maintenant.';

  @override
  String get watchDetails => 'Détails';

  @override
  String get watchOpen => 'Ouvrir';

  @override
  String get watchSeq => 'Séquence';

  @override
  String get watchType => 'Type';

  @override
  String get watchProject => 'Projet';

  @override
  String get watchEventId => 'Identifiant de l\'événement';

  @override
  String get watchPayload => 'Contenu';

  @override
  String get watchEmpty => 'En attente d\'événements';

  @override
  String get watchEmptyBody =>
      'Les changements de cette organisation apparaissent ici au moment où ils arrivent. Les précédents ne s\'affichent que si vous rejouez depuis un numéro de séquence.';

  @override
  String get watchNoMatch => 'Rien ne correspond pour l\'instant';

  @override
  String get watchNoMatchBody =>
      'Des événements arrivent, mais aucun ne correspond à ces filtres.';

  @override
  String get watchConnecting => 'Connexion au flux d\'événements';

  @override
  String get watchOffline => 'Hors ligne';

  @override
  String get watchOfflineBody =>
      'Le serveur est injoignable. L\'activité reprend là où elle s\'était arrêtée dès qu\'il le redevient.';

  @override
  String get watchNoContext => 'Aucun contexte actif';

  @override
  String get watchRefused =>
      'Cette connexion ne peut pas suivre les événements';

  @override
  String get watchRefusedBody =>
      'Suivre les événements demande la portée event:subscribe. Utilisez un jeton qui l\'a, ou demandez-la à un administrateur.';

  @override
  String get watchFilterRefused => 'Le serveur a refusé ce filtre';

  @override
  String get watchUnsupported =>
      'Ce serveur ne peut pas envoyer d\'événements à l\'application pour l\'instant, l\'activité reste donc vide. Elle reprendra quand les mises à jour en direct fonctionneront.';

  @override
  String watchExpired(int seq) {
    return 'Les événements après le n° $seq ne sont plus conservés sur le serveur. Les nouveaux s\'affichent à partir de maintenant.';
  }

  @override
  String get watchMissed =>
      'La connexion est revenue sans curseur, des événements peuvent donc manquer.';

  @override
  String get watchDismiss => 'Masquer';

  @override
  String watchKeeping(int count) {
    return 'Les $count derniers événements sont gardés ; les plus anciens sont retirés.';
  }

  @override
  String watchFor(String holder) {
    return 'pour $holder';
  }

  @override
  String watchLease(String duration) {
    return 'bail $duration';
  }

  @override
  String watchHeldBy(String holder) {
    return 'détenue par $holder';
  }

  @override
  String watchRevertedTo(String status) {
    return 'revenue à $status';
  }

  @override
  String watchChanged(String fields) {
    return 'modifié : $fields';
  }

  @override
  String get watchRestored => 'restaurée';

  @override
  String get watchCommentDeleted => 'commentaire supprimé';

  @override
  String get watchLeaseRenewed => 'bail renouvelé';

  @override
  String watchTagRemoved(String tag) {
    return 'étiquette retirée : $tag';
  }

  @override
  String watchDependencyRemoved(String ref) {
    return 'dépendance retirée : $ref';
  }

  @override
  String watchSyncedFrom(String system) {
    return 'synchronisé depuis $system';
  }

  @override
  String get settingsUpdates => 'Mises à jour';

  @override
  String get settingsUpdatesHelp =>
      'tix cherche les nouvelles versions sur GitHub. Les mises à jour sont vérifiées avant l’installation : le téléchargement doit correspondre aux sommes de contrôle signées de la version.';

  @override
  String get settingsUpdateCheck => 'Rechercher des mises à jour';

  @override
  String get settingsUpdateCheckHelp =>
      'Au démarrage de tix et toutes les quelques heures.';

  @override
  String get settingsUpdateAuto => 'Installer les mises à jour automatiquement';

  @override
  String get settingsUpdateAutoHelp =>
      'Une mise à jour téléchargée est installée quand vous quittez tix.';

  @override
  String get updateCheckNow => 'Vérifier maintenant';

  @override
  String get updateIdle => 'Pas encore vérifié.';

  @override
  String get updateChecking => 'Recherche de mises à jour…';

  @override
  String updateCurrent(String version) {
    return 'tix $version est la dernière version.';
  }

  @override
  String updateAvailable(String version) {
    return 'Mise à jour disponible : tix $version';
  }

  @override
  String get updateAvailableHelp =>
      'Téléchargez-la depuis la page de la version.';

  @override
  String updateDownloading(String version, int percent) {
    return 'Téléchargement de tix $version… $percent %';
  }

  @override
  String updateReady(String version) {
    return 'tix $version est prêt à être installé.';
  }

  @override
  String get updateReadyAuto =>
      'Elle s’installe quand vous quittez tix, ou tout de suite avec un redémarrage.';

  @override
  String get updateRestart => 'Redémarrer pour mettre à jour';

  @override
  String get updateDownload => 'Télécharger';

  @override
  String get updateWhatsNew => 'Nouveautés';

  @override
  String get updateFailedNetwork =>
      'Impossible de joindre GitHub pour rechercher des mises à jour.';

  @override
  String get updateFailedVerify =>
      'La mise à jour n’a pas pu être vérifiée, elle n’a donc pas été installée.';

  @override
  String get updateFailedInstall => 'La mise à jour n’a pas pu être installée.';

  @override
  String get updateNoAsset =>
      'La version ne contient pas de téléchargement pour ce système.';

  @override
  String trayUpdateAvailable(String version) {
    return 'Mise à jour disponible ($version)';
  }

  @override
  String trayRestartToUpdate(String version) {
    return 'Redémarrer pour mettre à jour ($version)';
  }

  @override
  String get trayWatch => 'Activité';

  @override
  String watchVia(String channel) {
    return 'via $channel';
  }

  @override
  String watchViaNamed(String channel, String name) {
    return 'via $channel ($name)';
  }

  @override
  String viaToken(String name) {
    return 'via le jeton $name';
  }

  @override
  String viaChannelToken(String channel, String name) {
    return 'via $channel (jeton $name)';
  }

  @override
  String get watchChannelWeb => 'le web';

  @override
  String get watchChannelApi => 'API';

  @override
  String get watchChannelCli => 'CLI';

  @override
  String get watchChannelSsh => 'SSH';

  @override
  String get watchChannelMcp => 'MCP';

  @override
  String get watchChannelSync => 'synchronisation';

  @override
  String get watchChannelImport => 'import';

  @override
  String get watchChannelSystem => 'système';

  @override
  String get watchChannelUnknown => 'un canal inconnu';

  @override
  String get watchFieldTitle => 'titre';

  @override
  String get watchFieldBody => 'description';

  @override
  String get watchFieldPriority => 'priorité';

  @override
  String get watchFieldAssignee => 'responsable';

  @override
  String get watchFieldTags => 'étiquettes';

  @override
  String get watchFieldDue => 'échéance';

  @override
  String get watchFieldRecurrence => 'règle de répétition';

  @override
  String get watchFieldCustom => 'champs personnalisés';

  @override
  String get watchFieldParent => 'tâche parente';

  @override
  String get watchCommentEdited => 'modifié';

  @override
  String watchCommentBy(String author, String text) {
    return '$author : $text';
  }

  @override
  String get boardPriorityTo => 'Priorité…';

  @override
  String get boardDueTo => 'Échéance…';

  @override
  String get boardTagAdd => 'Ajouter un tag…';

  @override
  String boardPrioritySet(String ref) {
    return 'Priorité de $ref modifiée';
  }

  @override
  String boardDueSet(String ref) {
    return 'Échéance de $ref définie';
  }

  @override
  String boardDueCleared(String ref) {
    return 'Échéance de $ref retirée';
  }

  @override
  String boardTagged(String ref, String tag) {
    return 'Tag $tag ajouté à $ref';
  }

  @override
  String get sidebarCollapse => 'Réduire la barre latérale';

  @override
  String get sidebarExpand => 'Déplier la barre latérale';

  @override
  String get sidebarResize => 'Redimensionner la barre latérale';

  @override
  String get paneCollapsed => 'Réduite';

  @override
  String get paneResizeHint =>
      'Faites glisser ou utilisez les flèches. Entrée ou un double clic rétablit la largeur.';

  @override
  String get taskPanelClose => 'Fermer la tâche';

  @override
  String get taskPanelResize => 'Redimensionner le panneau de la tâche';

  @override
  String get keysNextRow => 'Ligne suivante';

  @override
  String get keysPreviousRow => 'Ligne précédente';

  @override
  String get keysFirstRow => 'Première ligne';

  @override
  String get keysLastRow => 'Dernière ligne';

  @override
  String get keysPageDown => 'Page suivante';

  @override
  String get keysPageUp => 'Page précédente';

  @override
  String get keysOpenRow => 'Ouvrir la ligne active';

  @override
  String get keysBack => 'Revenir';

  @override
  String get keysLeaveField => 'Quitter le champ de texte';

  @override
  String get keysFirstTask => 'Première tâche';

  @override
  String get keysLastTask => 'Dernière tâche';

  @override
  String get settingsKeyboard => 'Clavier';

  @override
  String get settingsKeyboardHelp =>
      'Pour un clavier physique, sur tout appareil. Les touches tapées dans un champ de texte y restent toujours.';

  @override
  String get settingsShortcutsHelp =>
      'Désactivé coupe tous les raccourcis, y compris Ctrl K pour la palette. Tab, Entrée et Échap fonctionnent toujours.';

  @override
  String get settingsKeymap => 'Jeu de touches';

  @override
  String get keymapDefault => 'Par défaut';

  @override
  String get keymapVim => 'Vim';

  @override
  String get keymapEmacs => 'Emacs';

  @override
  String get keymapOff => 'Désactivé';

  @override
  String get keymapDefaultHelp =>
      'Les touches partagées avec tix web : j et k déplacent, g i ouvre la boîte de réception, d termine, Ctrl 1 à 7 changent de section.';

  @override
  String get keymapVimHelp =>
      'Réflexes Vim : gg et G sautent, o ajoute, i renomme, dd supprime après confirmation, h revient.';

  @override
  String get keymapEmacsHelp =>
      'Réflexes Emacs hors des champs de texte : C-n et C-p déplacent, C-s filtre, C-g annule, M-x ouvre la palette.';

  @override
  String get keymapOffHelp =>
      'Aucune touche seule ne déclenche rien. Les combinaisons avec Ctrl, Alt ou ⌘ fonctionnent toujours.';

  @override
  String get settingsKeyBindings => 'Raccourcis actifs';

  @override
  String get settingsKeyBindingsOff =>
      'Les raccourcis clavier sont désactivés.';

  @override
  String get keyGroupNavigate => 'Naviguer';

  @override
  String get keyGroupLists => 'Listes';

  @override
  String get keyGroupTask => 'Tâche';

  @override
  String get keyGroupGeneral => 'Général';

  @override
  String get keyHelpPalette => 'Ouvrir la palette de commandes';

  @override
  String get keyHelpHelp => 'Afficher cette aide';

  @override
  String get keyHelpGoInbox => 'Aller à la boîte de réception';

  @override
  String get keyHelpGoMyWork => 'Aller à Mon travail';

  @override
  String get keyHelpGoTasks => 'Aller aux tâches';

  @override
  String get keyHelpGoProjects => 'Aller aux projets';

  @override
  String get keyHelpGoActivity => 'Aller à l\'activité';

  @override
  String get keyHelpGoManage => 'Aller à la gestion';

  @override
  String get keyHelpGoSettings => 'Aller aux paramètres';

  @override
  String get keyHelpNext => 'Descendre la sélection';

  @override
  String get keyHelpPrevious => 'Monter la sélection';

  @override
  String get keyHelpFirst => 'Aller à la première tâche';

  @override
  String get keyHelpLast => 'Aller à la dernière tâche';

  @override
  String get keyHelpPageDown => 'Page suivante';

  @override
  String get keyHelpPageUp => 'Page précédente';

  @override
  String get keyHelpOpen => 'Ouvrir la tâche sélectionnée';

  @override
  String get keyHelpBack => 'Retour';

  @override
  String get keyHelpSelect => 'Sélectionner ou désélectionner la tâche active';

  @override
  String get keyHelpExtendDown => 'Étendre la sélection vers le bas';

  @override
  String get keyHelpExtendUp => 'Étendre la sélection vers le haut';

  @override
  String get keyHelpSelectAll => 'Sélectionner toutes les tâches de la liste';

  @override
  String get keyHelpClear => 'Effacer la sélection';

  @override
  String get keyHelpFilter => 'Aller au champ de filtre';

  @override
  String get keyHelpRefresh => 'Actualiser';

  @override
  String get keyHelpView => 'Changer de vue';

  @override
  String get keyHelpNew => 'Nouvelle tâche';

  @override
  String get keyHelpDone => 'Marquer comme terminée';

  @override
  String get keyHelpRename => 'Modifier le titre';

  @override
  String get keyHelpDescribe => 'Modifier la description';

  @override
  String get keyHelpMove => 'Déplacer vers un autre statut';

  @override
  String get keyHelpComment => 'Commenter';

  @override
  String get keyHelpTag => 'Ajouter une étiquette';

  @override
  String get keyHelpStar => 'Ajouter aux favoris ou les retirer';

  @override
  String get keyHelpPriority => 'Définir la priorité';

  @override
  String get keyHelpAssign => 'Assigner';

  @override
  String get keyHelpDue => 'Définir l\'échéance';

  @override
  String get keyHelpSnooze => 'Reporter ou annuler le report';

  @override
  String get keyHelpCopyRef => 'Copier la référence';

  @override
  String get keyHelpDelete => 'Supprimer';

  @override
  String get taskHandoff => 'Confier à un agent';

  @override
  String get taskHandoffNote =>
      'L’agent doit d’abord être connecté à tix : par la CLI tix ou les outils MCP de tix, avec son propre jeton. Rien ici ne contient de jeton. Mise en place : docs/agents.md';

  @override
  String get taskHandoffPrompt => 'Prompt';

  @override
  String get taskHandoffClient => 'Le lancer depuis votre client';

  @override
  String get taskHandoffRunHere =>
      'Lancez ceci dans le dépôt où se trouve le travail. Les guillemets conviennent à sh, bash et zsh.';

  @override
  String taskHandoffPasteInto(String client) {
    return '$client n’a pas de commande qui le lance avec un prompt. Collez ceci dans sa discussion ; il utilise les outils MCP de tix :';
  }

  @override
  String get taskHandoffMcp => 'Avec les outils MCP de tix';

  @override
  String get taskHandoffKeywords =>
      'agent ia confier déléguer ai claude codex prompt mcp';

  @override
  String get taskShare => 'Partager';

  @override
  String taskShareTitle(String ref) {
    return 'Partager $ref';
  }

  @override
  String get taskShareNative => 'Partager…';

  @override
  String get taskShareCopyLink => 'Copier le lien';

  @override
  String get taskShareCopyMarkdown => 'Copier en Markdown';

  @override
  String get taskShareCopyText => 'Copier la clé et le titre';

  @override
  String get taskShareLinkCopied => 'Lien copié';

  @override
  String get taskShareMarkdownCopied => 'Lien Markdown copié';

  @override
  String get taskShareTextCopied => 'Clé et titre copiés';

  @override
  String get taskShareKeywords =>
      'partager lien adresse copier share url markdown';

  @override
  String get taskDetailHistoryRaw => 'Brut';

  @override
  String get taskDetailHistoryRawTitle => 'Entrée brute';

  @override
  String get taskDetailHistoryCopyAll => 'Tout copier en JSON';

  @override
  String get taskDetailHistoryCopyTip => 'Copier cette entrée en JSON';

  @override
  String get taskDetailReactionAdd => 'Ajouter une réaction';

  @override
  String get taskDetailReactionPick => 'Réagir';

  @override
  String taskDetailReactionLabel(String emoji, String count) {
    return 'Réaction $emoji, $count';
  }

  @override
  String taskDetailReactionWho(String emoji) {
    return 'Réactions $emoji';
  }

  @override
  String taskDetailReactionLabelMine(String emoji, String count) {
    return 'Réaction $emoji, $count, vous avez réagi';
  }

  @override
  String get taskDetailReactionUnsupported =>
      'Ce serveur ne prend pas en charge les réactions.';

  @override
  String get taskDetailReactionOther => 'N’importe quel emoji';

  @override
  String get taskDetailReactionOtherHelp => 'Saisissez ou collez un emoji.';

  @override
  String get taskDetailReactionOneEmoji => 'Saisissez un seul emoji.';

  @override
  String get rowHeld => 'pris';

  @override
  String rowHeldBy(String holder) {
    return 'pris · $holder';
  }

  @override
  String rowHeldTip(String holder) {
    return 'Pris par $holder';
  }

  @override
  String rowHeldUntil(String holder, String time) {
    return 'Pris par $holder jusqu’à $time';
  }

  @override
  String get rowClaimSomeone => 'quelqu’un';

  @override
  String get rowClaimExpired => 'prise expirée';

  @override
  String rowAgo(String span) {
    return 'il y a $span';
  }

  @override
  String rowClaims(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prises',
      one: '1 prise',
    );
    return '$_temp0';
  }

  @override
  String rowClaimExpiredTip(String holder, String span, String time) {
    return '$holder a laissé la prise expirer il y a $span, à $time ; la tâche peut de nouveau être prise';
  }

  @override
  String rowRepeats(String rule) {
    return 'Se répète $rule';
  }

  @override
  String rowChecklist(int done, int total) {
    return '$done éléments de la liste sur $total faits';
  }

  @override
  String rowWaitingOn(String ref) {
    return 'attend $ref';
  }

  @override
  String rowWaitingOnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'attend $count tâches',
      one: 'attend 1 tâche',
    );
    return '$_temp0';
  }

  @override
  String rowWaitingTip(String refs) {
    return 'Attend $refs';
  }
}
