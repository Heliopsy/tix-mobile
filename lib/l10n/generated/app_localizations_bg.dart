// SPDX-License-Identifier: AGPL-3.0-or-later

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appTitle => 'tix';

  @override
  String get connectTitle => 'Свързване с tix';

  @override
  String get connectAddTitle => 'Добавяне на инстанция';

  @override
  String get connectIntro =>
      'Свържете се с tix сървър чрез API токен или с вход, или отворете tix база данни на това устройство.';

  @override
  String get serverUrlLabel => 'Адрес на сървъра';

  @override
  String get serverUrlHint => 'https://tix.example.com';

  @override
  String get tokenLabel => 'API токен';

  @override
  String get tokenHelp =>
      'Създайте го с tix token create или от Токени в уеб приложението.';

  @override
  String get contextNameLabel => 'Име (по избор)';

  @override
  String get contextNameHelp => 'Показва се в превключвателя.';

  @override
  String get connectButton => 'Свързване';

  @override
  String get projectsTitle => 'Проекти';

  @override
  String get projectsEmpty => 'Още няма проекти.';

  @override
  String get tasksEmpty => 'Няма задачи в този проект.';

  @override
  String get taskTitle => 'Задача';

  @override
  String get fieldStatus => 'Статус';

  @override
  String get fieldAssignee => 'Изпълнител';

  @override
  String get fieldDue => 'Краен срок';

  @override
  String get fieldPriority => 'Приоритет';

  @override
  String get fieldTags => 'Етикети';

  @override
  String get fieldDescription => 'Описание';

  @override
  String get unassigned => 'Без изпълнител';

  @override
  String get noDueDate => 'Без краен срок';

  @override
  String get noDescription => 'Няма описание.';

  @override
  String get noTaskSelected => 'Изберете задача, за да я видите тук.';

  @override
  String priorityLabel(String priority) {
    String _temp0 = intl.Intl.selectLogic(priority, {
      '1': 'Най-висок',
      '2': 'Висок',
      '3': 'Нормален',
      '4': 'Нисък',
      '5': 'Най-нисък',
      'other': 'Няма',
    });
    return '$_temp0';
  }

  @override
  String get quickAddTitle => 'Бързо добавяне';

  @override
  String get quickAddHint => 'Поправи входа !high #auth @raj due:fri';

  @override
  String get quickAddHelp =>
      '!приоритет  #етикет  @изпълнител  due:дата  ^родител';

  @override
  String get quickAddButton => 'Добави';

  @override
  String get cancel => 'Отказ';

  @override
  String taskCreated(String ref) {
    return 'Създадена е $ref';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get themeLabel => 'Тема';

  @override
  String get themeSystem => 'Система';

  @override
  String get themeLight => 'Светла';

  @override
  String get themeDark => 'Тъмна';

  @override
  String get languageLabel => 'Език';

  @override
  String get languageSystem => 'Система';

  @override
  String get signOut => 'Изход';

  @override
  String signOutBody(String server) {
    return 'Тази връзка към $server ще бъде забравена на това устройство.';
  }

  @override
  String signedInAs(String handle) {
    return 'Влезли сте като $handle';
  }

  @override
  String get retry => 'Опитай отново';

  @override
  String get loadMoreFailed => 'Не успяхме да заредим още.';

  @override
  String errorInvalid(String message) {
    return 'Сървърът отказа: $message';
  }

  @override
  String get errorUnauthenticated =>
      'Сървърът не прие тази връзка. Проверете токена или влезте отново.';

  @override
  String get errorForbidden => 'Този токен няма право на това.';

  @override
  String get errorNotFound => 'Не е намерено.';

  @override
  String get errorConflict =>
      'Някой е променил това по същото време. Презаредете и опитайте отново.';

  @override
  String errorPrecondition(String message) {
    return 'Това не може да стане сега: $message';
  }

  @override
  String get errorServer => 'Сървърът има проблем. Опитайте по-късно.';

  @override
  String get errorNetwork =>
      'Сървърът не отговаря. Проверете адреса и връзката си.';

  @override
  String get errorTimeout => 'Сървърът отговаря твърде бавно.';

  @override
  String get errorNotTix => 'Този адрес не отговаря като tix сървър.';

  @override
  String get errorBadUrl =>
      'Въведете адрес на сървър, например https://tix.example.com.';

  @override
  String get errorTokenRequired => 'Въведете API токен.';

  @override
  String get errorUnknown => 'Нещо се обърка.';

  @override
  String errorRequestId(String id) {
    return 'Заявка $id.';
  }

  @override
  String get instanceRemote => 'Сървър';

  @override
  String get instanceLocal => 'Това устройство';

  @override
  String get localUnavailableNote =>
      'Базите данни на това устройство изискват вградения в приложението tix, а тази версия е създадена без него.';

  @override
  String get methodToken => 'Токен';

  @override
  String get methodSignIn => 'Вход';

  @override
  String get emailLabel => 'Имейл';

  @override
  String get passwordLabel => 'Парола';

  @override
  String get signInHelp =>
      'Сесиите траят около 12 часа. Използвайте токен за устройство, което трябва да остане свързано.';

  @override
  String get signInButton => 'Вход';

  @override
  String get localIntro =>
      'Създайте нова tix база данни или отворете вече съществуваща.';

  @override
  String get dbNameLabel => 'Име на базата данни';

  @override
  String get dbNameHelp => 'Създава се в папката с документи на приложението.';

  @override
  String get localNewFile => 'Нова база данни…';

  @override
  String get localCreate => 'Създаване на база данни';

  @override
  String get localOpenFile => 'Отваряне на файл с база данни…';

  @override
  String get localListTenants => 'Показване на тенантите';

  @override
  String get codeIntro =>
      'Този акаунт има втори фактор. Въведете кода от приложението за удостоверяване.';

  @override
  String get codeLabel => 'Код';

  @override
  String get codeHelp =>
      'Шест цифри или един от кодовете ви за възстановяване.';

  @override
  String get verifyButton => 'Потвърждаване';

  @override
  String get chooseTenantIntro =>
      'Тук членувате в повече от един тенант. Кой да отваря тази връзка?';

  @override
  String get pinLabel => 'Закачане за този тенант';

  @override
  String get pinOnHelp =>
      'Връзката остава в този тенант. Добавете друга връзка за друг тенант.';

  @override
  String get pinOffHelp =>
      'Превключвайте между тенантите си от превключвателя.';

  @override
  String get openButton => 'Отваряне';

  @override
  String get localTenantsIntro => 'Отворете тенант от тази база данни.';

  @override
  String get newTenantTitle => 'Нов тенант';

  @override
  String get tenantKeyLabel => 'Ключ';

  @override
  String get tenantNameLabel => 'Име';

  @override
  String get createTenantButton => 'Създаване и отваряне';

  @override
  String servedAt(String host) {
    return 'Обслужва се на $host';
  }

  @override
  String get addAsInstance => 'Добавяне';

  @override
  String get instancesTitle => 'Инстанции';

  @override
  String get addInstance => 'Добавяне на инстанция';

  @override
  String get instancesEmpty => 'Още няма инстанции.';

  @override
  String get removeInstance => 'Премахване на инстанцията';

  @override
  String removeInstanceBody(String name) {
    return '$name и всички връзки към нея ще бъдат забравени на това устройство. На сървъра нищо не се променя.';
  }

  @override
  String get remove => 'Премахване';

  @override
  String get removeConnection => 'Премахване на връзката';

  @override
  String removeConnectionBody(String name) {
    return '$name ще бъде забравена на това устройство.';
  }

  @override
  String get openTenant => 'Отваряне на тенант';

  @override
  String get addConnection => 'Добавяне на връзка';

  @override
  String get useConnection => 'Използване';

  @override
  String get makeSwitchable => 'Позволяване на превключване';

  @override
  String get pin => 'Закачане за текущия тенант';

  @override
  String get signInAgain => 'Нов вход';

  @override
  String get switchable => 'С превключване';

  @override
  String get pinned => 'Закачена';

  @override
  String get switchContext => 'Смяна на инстанция или тенант';

  @override
  String get recentContexts => 'Скорошни';

  @override
  String get manageInstances => 'Управление на инстанциите';

  @override
  String instanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count инстанции',
      one: '1 инстанция',
      zero: 'Няма инстанции',
    );
    return '$_temp0';
  }

  @override
  String get errorBadCredentials => 'Този имейл и парола не бяха приети.';

  @override
  String get errorEmailRequired => 'Въведете имейла си.';

  @override
  String get errorPasswordRequired => 'Въведете паролата си.';

  @override
  String get errorCodeRequired =>
      'Въведете кода от приложението за удостоверяване.';

  @override
  String get errorSecondFactorSetup =>
      'Този акаунт трябва първо да настрои втори фактор. Влезте веднъж през браузъра, за да го направите.';

  @override
  String get errorPasswordChange =>
      'Този акаунт трябва първо да избере нова парола. Влезте веднъж през браузъра, за да го направите.';

  @override
  String get errorTenantRequired => 'Въведете ключ за тенанта.';

  @override
  String get errorEngineUnavailable =>
      'Базите данни на това устройство не са налични: тази версия е създадена без вградения tix.';

  @override
  String get localIntroImport =>
      'Създайте нова tix база данни или внесете съществуваща. Приложението работи със собствено копие, пазено в него; изнесете го, за да вземете промените си другаде.';

  @override
  String get localOpenInPlace =>
      'Файлът остава там, където е, и промените се записват направо в него.';

  @override
  String get localImportFile => 'Внасяне на файл с база данни…';

  @override
  String get exportDatabase => 'Изнасяне на базата данни…';

  @override
  String get databaseExported => 'Базата данни е изнесена.';

  @override
  String get localCopyNote => 'Копие, пазено в приложението';

  @override
  String get back => 'Назад';

  @override
  String get undo => 'Отмени';

  @override
  String get close => 'Затвори';

  @override
  String get loading => 'Зареждане';

  @override
  String get moreInfo => 'Още информация';

  @override
  String get dueOverdue => 'просрочена';

  @override
  String get dueToday => 'срок днес';

  @override
  String dueOn(String date) {
    return 'срок $date';
  }

  @override
  String snoozedUntil(String date) {
    return 'отложена до $date';
  }

  @override
  String get blockedByOther => 'Чака друга задача';

  @override
  String get starred => 'Със звезда';

  @override
  String get star => 'Отбележи със звезда';

  @override
  String get unstar => 'Махни звездата';

  @override
  String get complete => 'Завърши';

  @override
  String get reopen => 'Отвори отново';

  @override
  String get snooze => 'Отложи';

  @override
  String get assign => 'Възложи';

  @override
  String get filterHint => 'Филтър, например status:todo tag:ops';

  @override
  String get shortcutsTitle => 'Клавишни комбинации';

  @override
  String get showShortcuts => 'Покажи клавишните комбинации';

  @override
  String get openCommandPalette => 'Отвори палитрата с команди';

  @override
  String get commandSearchHint => 'Напишете команда';

  @override
  String get commandNone => 'Няма такава команда.';

  @override
  String get goProjects => 'Към проектите';

  @override
  String get goSettings => 'Към настройките';

  @override
  String get goInstances => 'Към инстанциите';

  @override
  String get commandsNavigate => 'Навигация';

  @override
  String get commandsTasks => 'Задачи';

  @override
  String get newTask => 'Нова задача';

  @override
  String get refresh => 'Опресни';

  @override
  String get projectsEmptyBody =>
      'Създайте проект с „Нов проект“, в браузъра или с tix project add.';

  @override
  String get tasksEmptyBody =>
      'Добавете задача с един ред: заглавие, после !high, #етикет, @потребител или due:fri.';

  @override
  String get instancesEmptyBody =>
      'Добавете сървъра tix, на който работите, или база данни на това устройство.';

  @override
  String projectsSubtitle(String tenant) {
    return 'Всички проекти в $tenant';
  }

  @override
  String get aboutTitle => 'Относно';

  @override
  String get appearanceLabel => 'Изглед';

  @override
  String get accountLabel => 'Профил';

  @override
  String get galleryTitle => 'Компоненти';

  @override
  String taskDetailActionsFor(String ref) {
    return 'Действия за $ref';
  }

  @override
  String get taskDetailActorSearch => 'Търсене по име или потребител';

  @override
  String get taskDetailAdd => 'Добави';

  @override
  String get taskDetailAddDependency => 'Добави зависимост';

  @override
  String get taskDetailAddSubtask => 'Добави подзадача';

  @override
  String get taskDetailAddTag => 'Добави етикет';

  @override
  String get taskDetailArtifactFile => 'файл';

  @override
  String get taskDetailArtifactLog => 'журнал';

  @override
  String get taskDetailArtifactMetric => 'метрика';

  @override
  String get taskDetailArtifactResult => 'резултат';

  @override
  String get taskDetailArtifacts => 'Артефакти';

  @override
  String get taskDetailArtifactSave => 'Запази';

  @override
  String get taskDetailArtifactShow => 'Покажи';

  @override
  String get taskDetailArtifactUnreadable =>
      'Съдържанието на този артефакт не може да бъде прочетено.';

  @override
  String get taskDetailAssigneeTitle => 'Възложи';

  @override
  String taskDetailAttached(String name) {
    return '$name е прикачен.';
  }

  @override
  String get taskDetailAttachFile => 'Прикачи файл';

  @override
  String get taskDetailBlocked =>
      'Блокирана: чака задача, която не е завършена.';

  @override
  String taskDetailChecklist(int done, int total) {
    return '$done от $total готови';
  }

  @override
  String get taskDetailClear => 'Изчисти';

  @override
  String get taskDetailCommands => 'Задача';

  @override
  String get taskDetailCommentActions => 'Действия с коментара';

  @override
  String get taskDetailCommentAdded => 'Коментарът е добавен.';

  @override
  String get taskDetailCommentDelete => 'Изтрий коментара';

  @override
  String get taskDetailCommentDeleteBody =>
      'Изчезва за всички. Това не може да бъде отменено тук.';

  @override
  String get taskDetailCommentDeleted => 'Коментарът е изтрит.';

  @override
  String get taskDetailCommentDeleteTitle => 'Да се изтрие ли коментарът?';

  @override
  String get taskDetailCommentEdit => 'Редактиране на коментар';

  @override
  String get taskDetailCommentHint => 'Поддържа Markdown. @ споменава някого.';

  @override
  String get taskDetailCommentLabel => 'Коментар';

  @override
  String get taskDetailComments => 'Коментари';

  @override
  String get taskDetailCommentSend => 'Коментирай';

  @override
  String taskDetailCopied(String ref) {
    return 'Копирана като $ref.';
  }

  @override
  String get taskDetailCopiedFrom => 'Копирана от';

  @override
  String get taskDetailCopyAction => 'Копирай';

  @override
  String get taskDetailCopyComments => 'Копирай коментарите';

  @override
  String get taskDetailCopyDependencies => 'Копирай зависимостите';

  @override
  String get taskDetailCopyKeepStatus => 'Запази статуса';

  @override
  String get taskDetailCopyLink => 'Свържи копието с тази задача';

  @override
  String get taskDetailCopyNewTitle => 'Заглавие на копието';

  @override
  String get taskDetailCopyProject => 'Проект';

  @override
  String get taskDetailCopyRef => 'Копирай референцията';

  @override
  String get taskDetailCopySubtasks => 'Копирай подзадачите';

  @override
  String taskDetailCopyTitle(String ref) {
    return 'Копиране на $ref';
  }

  @override
  String get taskDetailCopyTo => 'Копирай в…';

  @override
  String taskDetailCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count задачи',
      one: '1 задача',
    );
    return '$_temp0';
  }

  @override
  String get taskDetailCreated => 'Създадена';

  @override
  String get taskDetailCurrent => 'Текуща';

  @override
  String get taskDetailDelete => 'Изтрий';

  @override
  String taskDetailDeleted(String ref) {
    return '$ref е изтрита.';
  }

  @override
  String get taskDetailDeleteForGood => 'Изтрий завинаги';

  @override
  String get taskDetailDeletePermanentBody =>
      'Премахва се завинаги, заедно с коментарите и историята си.';

  @override
  String taskDetailDeleteSubtasksBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-те ѝ подзадачи се изтриват с нея.',
      one: 'Подзадачата ѝ се изтрива с нея.',
    );
    return '$_temp0';
  }

  @override
  String taskDetailDeleteTitle(String ref) {
    return 'Да се изтрие ли $ref?';
  }

  @override
  String get taskDetailDeleteTrashBody =>
      'Отива в кошчето и може да бъде възстановена.';

  @override
  String get taskDetailDependencies => 'Чака';

  @override
  String get taskDetailDependenciesInfo =>
      'Тази задача се води блокирана, докато всяка задача тук не стигне до завършено състояние.';

  @override
  String taskDetailDependencyAdded(String ref) {
    return 'Вече чака $ref.';
  }

  @override
  String taskDetailDependencyRemoved(String ref) {
    return 'Вече не чака $ref.';
  }

  @override
  String get taskDetailDependsOn => 'Зависи от';

  @override
  String get taskDetailDependsOnHint => 'Референция, например infra-2';

  @override
  String get taskDetailDescriptionHint =>
      'Markdown. - [ ] създава елемент от списък за отметки.';

  @override
  String get taskDetailDueClear => 'Без краен срок';

  @override
  String get taskDetailDueNextWeek => 'Следващата седмица';

  @override
  String get taskDetailDueTitle => 'Краен срок';

  @override
  String get taskDetailDueToday => 'Днес';

  @override
  String get taskDetailDueTomorrow => 'Утре';

  @override
  String get taskDetailEdit => 'Редактирай';

  @override
  String get taskDetailEditDescription => 'Редактиране на описанието';

  @override
  String get taskDetailEdited => 'редактиран';

  @override
  String taskDetailEditField(String name) {
    return 'Промяна на $name';
  }

  @override
  String get taskDetailFileTooBig =>
      'Файлове над 1 MiB не могат да бъдат прикачени.';

  @override
  String get taskDetailHistory => 'История';

  @override
  String taskDetailHistoryChanged(String fields) {
    return 'промени $fields';
  }

  @override
  String get taskDetailHistoryCreated => 'създаде задачата';

  @override
  String get taskDetailHistoryDeleted => 'изтри задачата';

  @override
  String get taskDetailHistoryMore => 'Покажи по-стари';

  @override
  String taskDetailHistoryMoved(String from, String to) {
    return 'я премести от $from в $to';
  }

  @override
  String get taskDetailHistoryRestored => 'възстанови задачата';

  @override
  String get taskDetailJsonHelp =>
      'JSON стойност: число, низ в кавички, списък или обект';

  @override
  String get taskDetailMove => 'Премести';

  @override
  String get taskDetailMoveComment => 'Коментар';

  @override
  String get taskDetailMoveCommentHelp =>
      'Това преместване изисква коментар защо.';

  @override
  String taskDetailMoved(String ref, String status) {
    return '$ref е преместена в $status.';
  }

  @override
  String get taskDetailMoveFrom => 'От';

  @override
  String get taskDetailMoveNeedsComment => 'Изисква коментар';

  @override
  String taskDetailMoveStopped(String state, String reason) {
    return 'Спря преди $state: $reason';
  }

  @override
  String get taskDetailMoveTitle => 'Премести';

  @override
  String taskDetailMoveTo(String state) {
    return 'Преместване в $state';
  }

  @override
  String taskDetailMoveVia(String states) {
    return 'през $states';
  }

  @override
  String get taskDetailNo => 'Не';

  @override
  String get taskDetailNoArtifacts => 'Няма артефакти.';

  @override
  String get taskDetailNoComments => 'Още няма коментари.';

  @override
  String get taskDetailNoDependencies => 'Не чака нищо.';

  @override
  String get taskDetailNoHistory => 'Няма история.';

  @override
  String get taskDetailNoMoves =>
      'Работният процес не позволява преместване оттук.';

  @override
  String get taskDetailNoRepeat => 'Не се повтаря';

  @override
  String get taskDetailNoSubtasks => 'Няма подзадачи.';

  @override
  String get taskDetailOpen => 'Отвори';

  @override
  String get taskDetailParent => 'Подзадача на';

  @override
  String get taskDetailPickDate => 'Избери дата…';

  @override
  String get taskDetailPickDateTime => 'Избери дата и час…';

  @override
  String get taskDetailPreview => 'Преглед';

  @override
  String get taskDetailPriorityTitle => 'Приоритет';

  @override
  String get taskDetailProject => 'Проект';

  @override
  String get taskDetailRefCopied => 'Референцията е копирана.';

  @override
  String taskDetailRemoveDependency(String ref) {
    return 'Спри да чакаш $ref';
  }

  @override
  String taskDetailRemoveTag(String tag) {
    return 'Премахни $tag';
  }

  @override
  String get taskDetailRename => 'Преименувай';

  @override
  String get taskDetailRepeat => 'Повтаря се';

  @override
  String get taskDetailRepeatHelp =>
      'every day, every 2 weeks on mon,thu, every month on day 31, 3 days after done';

  @override
  String get taskDetailRepeatHint => 'every week';

  @override
  String get taskDetailRepeatInfo =>
      'Завършването на задача с правило създава следващата веднага. Отказването не. Празно спира повторението.';

  @override
  String get taskDetailRepeats => 'Повтаря се';

  @override
  String get taskDetailRepeatTitle => 'Правило за повторение';

  @override
  String get taskDetailSave => 'Запази';

  @override
  String get taskDetailSaved => 'Запазено.';

  @override
  String get taskDetailSnooze => 'Отложи';

  @override
  String taskDetailSnoozed(String when) {
    return 'Отложена до $when.';
  }

  @override
  String get taskDetailSnoozeLater => 'По-късно днес';

  @override
  String get taskDetailSnoozeNextWeek => 'Следващата седмица';

  @override
  String get taskDetailSnoozeTitle => 'Отложи до';

  @override
  String get taskDetailSnoozeTomorrow => 'Утре сутрин';

  @override
  String get taskDetailStar => 'Отбележи със звезда';

  @override
  String get taskDetailStarred => 'Отбелязана със звезда.';

  @override
  String get taskDetailSubtaskAdded => 'Подзадачата е добавена.';

  @override
  String get taskDetailSubtasks => 'Подзадачи';

  @override
  String get taskDetailSystem => 'tix';

  @override
  String taskDetailTagAdded(String name) {
    return 'Добавен етикет $name.';
  }

  @override
  String get taskDetailTagHint => 'Ново име създава етикета';

  @override
  String taskDetailTagRemoved(String name) {
    return 'Премахнат $name.';
  }

  @override
  String get taskDetailTakePhoto => 'Снимай';

  @override
  String get taskDetailTitleLabel => 'Заглавие';

  @override
  String get taskDetailUnassign => 'Без изпълнител';

  @override
  String get taskDetailUnstar => 'Премахни звездата';

  @override
  String get taskDetailUnstarred => 'Звездата е премахната.';

  @override
  String get taskDetailUpdated => 'Обновена';

  @override
  String get taskDetailWake => 'Събуди сега';

  @override
  String get taskDetailWoken => 'Отново е в списъците.';

  @override
  String get taskDetailWrite => 'Писане';

  @override
  String get taskDetailYes => 'Да';

  @override
  String get boardAllEmpty => 'Още няма задачи.';

  @override
  String get boardAllEmptyBody => 'Тук се показват задачите от всички проекти.';

  @override
  String get boardArrangement => 'Подредба';

  @override
  String get boardAssignMe => 'Възложи на мен';

  @override
  String boardAssignedToMe(String ref) {
    return '$ref е възложена на вас';
  }

  @override
  String get boardCollapse => 'Свий';

  @override
  String get boardColumnEmpty => 'Няма нищо';

  @override
  String boardCompleted(String ref) {
    return '$ref е завършена';
  }

  @override
  String boardCount(int count, String more) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count$more задачи',
      one: '1$more задача',
    );
    return '$_temp0';
  }

  @override
  String get boardExpand => 'Разгъни';

  @override
  String boardGroupMenu(String group) {
    return 'Подреди $group';
  }

  @override
  String boardHiddenCount(int count) {
    return 'Скрити: $count';
  }

  @override
  String get boardHide => 'Скрий';

  @override
  String get boardLoadMore => 'Зареди още';

  @override
  String get boardMoveDown => 'Премести надолу';

  @override
  String get boardMoveLeft => 'Премести наляво';

  @override
  String get boardMoveRight => 'Премести надясно';

  @override
  String boardMoveTitle(String ref) {
    return 'Премести $ref в';
  }

  @override
  String get boardMoveTo => 'Премести в…';

  @override
  String get boardMoveUp => 'Премести нагоре';

  @override
  String boardMoved(String ref, String status) {
    return '$ref е преместена в $status';
  }

  @override
  String get boardNext => 'Следваща задача';

  @override
  String boardNoRoute(String ref) {
    return 'Работният поток на $ref не позволява това';
  }

  @override
  String get boardOpen => 'Отвори';

  @override
  String get boardPrevious => 'Предишна задача';

  @override
  String get boardRefused =>
      'Тези проекти следват различни работни потоци и не могат да имат обща дъска. Стеснете филтъра до проектите на един поток, за да видите дъска.';

  @override
  String boardRefusedGroup(String workflow, String projects) {
    return '$workflow: $projects';
  }

  @override
  String boardReopened(String ref) {
    return '$ref е отворена отново';
  }

  @override
  String get boardResetArrangement => 'Нулирай подредбата';

  @override
  String boardShowGroup(String group) {
    return 'Покажи $group';
  }

  @override
  String get boardSnoozeLater => 'По-късно днес';

  @override
  String boardSnoozeTitle(String ref) {
    return 'Отложи $ref до';
  }

  @override
  String get boardSnoozeTomorrow => 'Утре сутринта';

  @override
  String get boardSnoozeWeek => 'Следващата седмица';

  @override
  String boardSnoozed(String ref) {
    return '$ref е отложена';
  }

  @override
  String boardStarred(String ref) {
    return '$ref е отбелязана';
  }

  @override
  String boardStrays(String refs) {
    return 'Извън колоните на тази дъска: $refs';
  }

  @override
  String get boardSwitchProject => 'Смени проекта';

  @override
  String boardUnstarred(String ref) {
    return 'Отбелязването на $ref е премахнато';
  }

  @override
  String get boardWake => 'Събуди сега';

  @override
  String boardWoken(String ref) {
    return '$ref е събудена';
  }

  @override
  String get bulkClear => 'Изчисти избора';

  @override
  String get bulkCopy => 'Копирай в…';

  @override
  String bulkCopyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Копирай $count задачи в',
      one: 'Копирай 1 задача в',
    );
    return '$_temp0';
  }

  @override
  String get bulkDelete => 'Изтрий';

  @override
  String get bulkDeleteBody => 'Отиват в кошчето, а Отмени ги връща.';

  @override
  String bulkDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Да се изтрият ли $count задачи?',
      one: 'Да се изтрие ли 1 задача?',
    );
    return '$_temp0';
  }

  @override
  String bulkDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count задачи са променени',
      one: '1 задача е променена',
    );
    return '$_temp0';
  }

  @override
  String get bulkMove => 'Премести';

  @override
  String bulkMoveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Премести $count задачи в',
      one: 'Премести 1 задача в',
    );
    return '$_temp0';
  }

  @override
  String bulkPartly(int count, String refused) {
    return '$count са променени. Отказани: $refused';
  }

  @override
  String get bulkSelect => 'Избери';

  @override
  String get bulkSelectAll => 'Избери всички';

  @override
  String bulkSelected(int count) {
    return '$count избрани';
  }

  @override
  String get bulkTagAdd => 'Добави етикет';

  @override
  String get bulkTagRemove => 'Премахни етикет';

  @override
  String get filterBlocked => 'Блокирани';

  @override
  String get filterClear => 'Изчисти';

  @override
  String get filterDelete => 'Изтрий филтъра';

  @override
  String get filterDeleteBody => 'Изчезва и за всички, с които е споделен.';

  @override
  String filterDeleteTitle(String name) {
    return 'Да се изтрие ли $name?';
  }

  @override
  String get filterDueToday => 'Срок днес';

  @override
  String get filterDueWeek => 'Срок тази седмица';

  @override
  String get filterFinished => 'Завършени';

  @override
  String get filterFocus => 'Филтрирай задачите';

  @override
  String get filterMine => 'Мои';

  @override
  String get filterName => 'Име';

  @override
  String get filterNoMatch => 'Нищо не отговаря на този филтър.';

  @override
  String get filterNoMatchBody => 'Променете филтъра или го изчистете.';

  @override
  String get filterOverdue => 'Просрочени';

  @override
  String get filterRename => 'Преименувай';

  @override
  String get filterSave => 'Запази филтъра';

  @override
  String get filterSaveTitle => 'Запазване на филтъра';

  @override
  String filterSaved(String name) {
    return '$name е запазен';
  }

  @override
  String get filterShare => 'Сподели с всички';

  @override
  String get filterShared => 'Сподели с всички в наемателя';

  @override
  String get filterSharedHelp =>
      'Другите го виждат сред запазените си филтри; само вие и администраторите можете да го променяте.';

  @override
  String get filterSnoozed => 'Отложени';

  @override
  String get filterUnshare => 'Спри споделянето';

  @override
  String get goMyWork => 'Към Моята работа';

  @override
  String get goTasks => 'Към Задачи';

  @override
  String get groupNone => 'Без групиране';

  @override
  String get groupProject => 'Групирай по проект';

  @override
  String get groupStatus => 'Групирай по статус';

  @override
  String get lanesEmpty => 'Няма задачи';

  @override
  String get myWorkEmpty => 'Нищо не ви е възложено.';

  @override
  String get myWorkEmptyBody =>
      'Тук се показват отворените задачи, възложени на вас, по срок.';

  @override
  String get myWorkLater => 'По-късно';

  @override
  String get myWorkNoDate => 'Без срок';

  @override
  String get myWorkOverdue => 'Просрочени';

  @override
  String get myWorkTitle => 'Моята работа';

  @override
  String get myWorkToday => 'Днес';

  @override
  String get myWorkWeek => 'Тази седмица';

  @override
  String projectOpenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отворени задачи',
      one: '1 отворена задача',
    );
    return '$_temp0';
  }

  @override
  String get sortCreated => 'Създадена';

  @override
  String get sortDescending => 'Низходящо';

  @override
  String get sortMenu => 'Подреждане и групиране';

  @override
  String get sortNumber => 'Номер';

  @override
  String get sortTitle => 'Заглавие';

  @override
  String get sortUpdated => 'Променена';

  @override
  String get sortUrgency => 'Спешност';

  @override
  String get tasksTitle => 'Задачи';

  @override
  String get viewBoard => 'Дъска';

  @override
  String get viewLanes => 'Ленти';

  @override
  String get viewList => 'Списък';

  @override
  String get viewSwitch => 'Смени изгледа';

  @override
  String boardAssigned(String ref) {
    return '$ref е възложена';
  }

  @override
  String get boardAssignTo => 'Възложи на…';

  @override
  String get quickAddProject => 'Проект';

  @override
  String get quickAddPickProject => 'Изберете проект';

  @override
  String get quickAddNoProjects => 'Все още няма проект, в който да добавите.';

  @override
  String get quickAddAnother => 'Добавяне на още';

  @override
  String get quickAddAnotherHelp => 'Остава отворено за следващия ред';

  @override
  String quickAddPreviewRefused(String reason) {
    return 'Сървърът би отказал: $reason';
  }

  @override
  String get quickAddPreviewOff =>
      'Тази връзка не може да показва преглед; добавянето работи.';

  @override
  String get quickAddOffline =>
      'Добавянето изисква връзка със сървъра. Редът е запазен; опитайте отново, когато сте онлайн.';

  @override
  String get quickAddChipPriority => 'приоритет';

  @override
  String get quickAddChipTag => 'етикет';

  @override
  String get quickAddChipAssignee => 'изпълнител';

  @override
  String get quickAddChipDue => 'срок';

  @override
  String get quickAddChipStatus => 'статус';

  @override
  String get quickAddChipParent => 'родител';

  @override
  String get quickAddChipTitle => 'заглавие';

  @override
  String get quickAddSuggestions => 'Предложения';

  @override
  String get quickAddTemplates => 'От шаблон';

  @override
  String get quickAddManageTemplates => 'Шаблони';

  @override
  String get quickAddPaste => 'Бързо добавяне от клипборда';

  @override
  String get quickAddClipboardEmpty => 'В клипборда няма текст.';

  @override
  String get paletteGroupProjects => 'Проекти';

  @override
  String get paletteGroupRecent => 'Скорошни задачи';

  @override
  String get paletteGroupContexts => 'Превключване към';

  @override
  String get paletteGroupTheme => 'Тема';

  @override
  String get paletteGroupTemplates => 'Шаблони';

  @override
  String paletteOpenTask(String ref) {
    return 'Отваряне на $ref';
  }

  @override
  String get paletteGoInbox => 'Към входящите';

  @override
  String get paletteGoMyWork => 'Към моята работа';

  @override
  String get paletteGoTemplates => 'Към шаблоните';

  @override
  String get paletteThemeLight => 'Светла тема';

  @override
  String get paletteThemeDark => 'Тъмна тема';

  @override
  String get paletteThemeSystem => 'Тема на системата';

  @override
  String paletteUseTemplate(String name) {
    return 'Нова задача от $name';
  }

  @override
  String get templatesTitle => 'Шаблони';

  @override
  String get templatesSubtitle => 'Задачи, които добавяте често, на един допир';

  @override
  String get templateNew => 'Нов шаблон';

  @override
  String get templatesEmpty => 'Все още няма шаблони.';

  @override
  String get templatesEmptyBody =>
      'Запазете задача като шаблон, за да я добавяте с един допир.';

  @override
  String get templateEveryProject => 'Всички проекти';

  @override
  String templateUses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Използван $count пъти',
      one: 'Използван веднъж',
      zero: 'Неизползван',
    );
    return '$_temp0';
  }

  @override
  String templateSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подзадачи',
      one: '1 подзадача',
    );
    return '$_temp0';
  }

  @override
  String get templateUse => 'Използване';

  @override
  String get templateEdit => 'Редактиране на шаблона';

  @override
  String get templateDelete => 'Изтриване на шаблона';

  @override
  String templateDeleteTitle(String name) {
    return 'Изтриване на $name?';
  }

  @override
  String get templateDeleteBody => 'Задачите, създадени от него, остават.';

  @override
  String templateDeleted(String name) {
    return 'Изтрит е $name';
  }

  @override
  String templateSaved(String name) {
    return 'Запазен е $name';
  }

  @override
  String get templateName => 'Име';

  @override
  String get templateNameHelp => 'Уникално в организацията, до 100 знака.';

  @override
  String get templateFromTask => 'От задача';

  @override
  String get templateFromScratch => 'От нулата';

  @override
  String get templateTaskRef => 'Задача';

  @override
  String get templateTaskRefHelp =>
      'Референцията на задачата, такава като ops-12.';

  @override
  String get templateWithSubtasks => 'Със подзадачите';

  @override
  String get templateTenantWide => 'Споделяне с всички проекти';

  @override
  String get templateDueIn => 'Срок след';

  @override
  String get templateDueInHelp =>
      'Колко време след използване е срокът, например 3d или 2w. Празно за без срок.';

  @override
  String get templateScratchNote =>
      'tix пази шаблони от задачи, затова задачата се добавя и в проекта.';

  @override
  String get templateTitle => 'Заглавие';

  @override
  String templateTitleHelp(String date, String n, String project) {
    return '$date, $n и $project се попълват при всяко използване.';
  }

  @override
  String get templateBody => 'Описание';

  @override
  String get templatePriority => 'Приоритет';

  @override
  String get templateTags => 'Етикети';

  @override
  String get templateTagsHelp => 'Разделени с интервали или запетаи.';

  @override
  String get templateRecurrence => 'Повтаряне';

  @override
  String get templateRecurrenceHelp =>
      'Например every 2 weeks. Празно за без повтаряне.';

  @override
  String get templateSave => 'Запазване';

  @override
  String get templateCreate => 'Запазване на шаблона';

  @override
  String get templateRecentTasks => 'Скоро отваряни';

  @override
  String get appShortcutInbox => 'Входящи';

  @override
  String get appShortcutMyWork => 'Моята работа';

  @override
  String get templateDeleteAction => 'Изтриване';

  @override
  String get templateMore => 'Още действия';

  @override
  String templateGeneralError(String reason) {
    return 'Не можа да се запази: $reason';
  }

  @override
  String get goInbox => 'Към входящите';

  @override
  String get inboxTitle => 'Входящи';

  @override
  String get inboxAll => 'Всички';

  @override
  String get inboxUnreadFilter => 'Непрочетени';

  @override
  String get inboxShowUnread => 'Само непрочетените';

  @override
  String get inboxUnread => 'непрочетено';

  @override
  String get inboxAllCaughtUp => 'Няма непрочетени';

  @override
  String inboxUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочетени',
      one: '1 непрочетено',
    );
    return '$_temp0';
  }

  @override
  String get inboxToday => 'Днес';

  @override
  String get inboxYesterday => 'Вчера';

  @override
  String get inboxEarlier => 'По-рано';

  @override
  String get inboxEmpty => 'Още няма нищо.';

  @override
  String get inboxEmptyBody =>
      'Когато някой ви спомене, ви възложи задача или коментира такава, която следите, ще се появи тук.';

  @override
  String get inboxEmptyUnread => 'Няма непрочетени.';

  @override
  String get inboxEmptyFiltered => 'Нищо от тези видове.';

  @override
  String get inboxSomebody => 'Някой';

  @override
  String inboxWhatMention(String who) {
    return '$who ви спомена';
  }

  @override
  String inboxWhatAssigned(String who) {
    return '$who ви възложи задача';
  }

  @override
  String inboxWhatComment(String who) {
    return '$who коментира';
  }

  @override
  String inboxWhatStatus(String who) {
    return '$who я премести';
  }

  @override
  String inboxWhatOther(String who) {
    return '$who я промени';
  }

  @override
  String get inboxMovedTo => 'преместена в';

  @override
  String get inboxTaskGone => 'Задача, която е изтрита';

  @override
  String get inboxNow => 'сега';

  @override
  String inboxMinutesAgo(int n) {
    return '$n мин';
  }

  @override
  String inboxHoursAgo(int n) {
    return '$n ч';
  }

  @override
  String get inboxItemActions => 'Действия';

  @override
  String get inboxOpenTask => 'Отвори задачата';

  @override
  String get inboxMarkRead => 'Прочетено';

  @override
  String get inboxMarkUnread => 'Непрочетено';

  @override
  String get inboxMarkAllRead => 'Всички прочетени';

  @override
  String inboxMarkedAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count елемента са отбелязани като прочетени',
      one: '1 елемент е отбелязан като прочетен',
    );
    return '$_temp0';
  }

  @override
  String inboxMuteKind(String kind) {
    return 'Спри „$kind“ във входящите';
  }

  @override
  String inboxMuted(String kind) {
    return '„$kind“ вече не идват във входящите';
  }

  @override
  String get inboxKindMention => 'Споменавания';

  @override
  String get inboxKindAssigned => 'Възлагания';

  @override
  String get inboxKindComment => 'Коментари';

  @override
  String get inboxKindStatus => 'Смени на статус';

  @override
  String get inboxKindMentionHelp =>
      'Някой напише @вас в коментар или описание.';

  @override
  String get inboxKindAssignedHelp => 'Възложена ви е задача.';

  @override
  String get inboxKindCommentHelp =>
      'Някой коментира задача, възложена на вас или отбелязана със звезда.';

  @override
  String get inboxKindStatusHelp =>
      'Задача, възложена на вас, смени статуса си.';

  @override
  String get inboxKindsTitle => 'Входящи';

  @override
  String get inboxKindsSubtitle =>
      'Какво създава елемент във входящите ви, на всяко устройство.';

  @override
  String get inboxKindsInfo =>
      'Пази се на сървъра, както в Настройки, Входящи в уеб приложението. Изключен вид не създава елементи; вече получените остават. Собствените ви промени никога не се появяват.';

  @override
  String get inboxSummaryOverdue => 'Просрочени';

  @override
  String get inboxSummaryDueToday => 'За днес';

  @override
  String get inboxSummaryOpen => 'Отворени';

  @override
  String get inboxSummaryDoneWeek => 'Готови за 7 дни';

  @override
  String inboxCategory(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'todo': 'За правене',
      'inProgress': 'В работа',
      'blocked': 'Блокирани',
      'waiting': 'Чакащи',
      'other': 'Други',
    });
    return '$_temp0';
  }

  @override
  String get inboxChannelsTitle => 'Канали';

  @override
  String get inboxChannelsSubtitle =>
      'Препращайте входящите към Slack, Discord, ntfy или произволен адрес.';

  @override
  String get inboxChannelsInfo =>
      'Каналът е само ваш: получава само вашите елементи от избраните видове и нищо от видовете, които сте спрели по-горе. Сървърът изпраща всеки елемент веднага.';

  @override
  String get inboxChannelsEmpty => 'Още няма канали.';

  @override
  String get inboxChannelAdd => 'Добави канал';

  @override
  String get inboxChannelEdit => 'Промени канала';

  @override
  String get inboxChannelSave => 'Запази';

  @override
  String get inboxChannelSaved => 'Каналът е запазен';

  @override
  String inboxChannelAdded(String name) {
    return 'Добавен е $name';
  }

  @override
  String get inboxChannelName => 'Име';

  @override
  String get inboxChannelNameHint => 'Моят Slack';

  @override
  String get inboxChannelUrl => 'Адрес';

  @override
  String get inboxChannelUrlHelp =>
      'Адресът на webhook или тема. Трябва да е https.';

  @override
  String get inboxChannelFormat => 'Формат';

  @override
  String get inboxChannelFormatGeneric => 'Подписан JSON';

  @override
  String get inboxChannelKinds => 'Видове';

  @override
  String get inboxChannelAllKinds => 'Всички видове';

  @override
  String get inboxChannelOff => 'Изключен';

  @override
  String get inboxChannelSecretTitle => 'Ключ за подпис';

  @override
  String get inboxChannelSecretBody =>
      'tix подписва всяко JSON съобщение с този ключ. Копирайте го сега: няма да бъде показан отново.';

  @override
  String get inboxChannelSecretCopy => 'Копирай';

  @override
  String get inboxChannelSecretDone => 'Готово';

  @override
  String get inboxChannelAbout => 'Канал';

  @override
  String get inboxChannelActive => 'Включен';

  @override
  String get inboxChannelActiveHelp => 'Изключен, каналът не получава нищо.';

  @override
  String get inboxChannelTest => 'Изпрати тест';

  @override
  String get inboxChannelTestQueued => 'Тестовото съобщение е в опашката';

  @override
  String get inboxChannelDeliveries => 'Доставки';

  @override
  String get inboxChannelDeliveriesSubtitle => 'Най-новите първо.';

  @override
  String get inboxChannelNoDeliveries => 'Още няма доставки.';

  @override
  String get inboxChannelGone => 'Този канал вече не съществува.';

  @override
  String get inboxChannelDangerZone => 'Опасна зона';

  @override
  String get inboxChannelDelete => 'Изтрий канала';

  @override
  String inboxChannelDeleteTitle(String name) {
    return 'Да се изтрие ли $name?';
  }

  @override
  String get inboxChannelDeleteBody =>
      'Каналът и дневникът на доставките се премахват. Това не може да бъде отменено.';

  @override
  String inboxChannelDeleted(String name) {
    return 'Изтрит е $name';
  }

  @override
  String get inboxDeliveryDelivered => 'доставено';

  @override
  String get inboxDeliveryFailed => 'неуспешно';

  @override
  String get inboxDeliveryPending => 'чака';

  @override
  String get inboxDeliveryTest => 'Тестово съобщение';

  @override
  String get inboxDeliveryItem => 'Елемент от входящите';

  @override
  String inboxDeliveryAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count опита',
      one: '1 опит',
    );
    return '$_temp0';
  }

  @override
  String get inboxDeliveryRedeliver => 'Изпрати пак';

  @override
  String get inboxDeliveryRequeued => 'Отново е в опашката';

  @override
  String get liveUpdated => 'Обновено';

  @override
  String get liveChangedElsewhere =>
      'Това е променено другаде. Промените ви са запазени.';

  @override
  String liveChangedElsewhereBy(String handle) {
    return '@$handle промени това. Промените ви са запазени.';
  }

  @override
  String get liveKeepEditing => 'Продължи';

  @override
  String get liveReload => 'Презареди';

  @override
  String get notifSettingsTitle => 'Известия';

  @override
  String get notifSettingsSubtitle => 'На това устройство, видове и канали';

  @override
  String get notifDeviceTitle => 'На това устройство';

  @override
  String get notifDeviceSubtitle => 'За активната инстанция и организация.';

  @override
  String get notifDeviceInfo =>
      'Показват се, докато приложението е отворено или скоро е било скрито. Затворено приложение не може да бъде известено: tix още няма услуга за push. Каналите по-долу доставят навсякъде.';

  @override
  String get notifEnabled => 'Известявай ме за нови елементи';

  @override
  String get notifEnabledHelp => 'Докоснете известие, за да отворите задачата.';

  @override
  String get notifBlocked => 'Известията за tix са блокирани.';

  @override
  String get notifBlockedHelp =>
      'Разрешете известията за tix в системните настройки и включете отново.';

  @override
  String get notifNudge =>
      'Получавайте известие, когато нещо ново пристигне във входящите.';

  @override
  String get notifTurnOn => 'Включи';

  @override
  String get notifNotNow => 'Не сега';

  @override
  String notifMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Още $count елемента',
      one: 'Още 1 елемент',
    );
    return '$_temp0';
  }

  @override
  String get notifMoreBody => 'Отворете входящите, за да ги видите.';

  @override
  String get themeOled => 'OLED черна';

  @override
  String get themeSystemBlack => 'Чисто черно при тъмна тема';

  @override
  String get themeSystemBlackHelp =>
      'Използва OLED черна тема, когато системата е тъмна. Пести батерия на OLED екрани.';

  @override
  String get goAbout => 'За tix';

  @override
  String get aboutTagline => 'Клиентът на tix за телефони и компютри';

  @override
  String aboutVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get aboutIntro =>
      'tix-mobile е приложението за tix, проследяването на задачи с отворен код. Работи с всеки tix сървър или пуска tix на това устройство изобщо без сървър. Сървърът решава какво става с работата ви, така че задачите се държат точно както в уеб приложението и командния ред на tix.';

  @override
  String get aboutVersions => 'Версии';

  @override
  String get aboutAppVersion => 'Приложение';

  @override
  String get aboutEngineVersion => 'Вграден двигател';

  @override
  String get aboutEngineNone => 'Не е в тази версия';

  @override
  String get aboutServerVersion => 'Сървър';

  @override
  String get aboutServerNone => 'Няма връзка';

  @override
  String get aboutServerUnknown => 'Не може да се прочете';

  @override
  String get aboutLinks => 'Връзки';

  @override
  String get aboutWebsite => 'Уебсайт';

  @override
  String get aboutSource => 'Изходен код';

  @override
  String get aboutSourceHelp =>
      'Пълният изходен код на приложението, както го предлага AGPL';

  @override
  String get aboutRoadmap => 'Пътна карта';

  @override
  String get aboutRoadmapHelp => 'Какво предстои';

  @override
  String get aboutChangelog => 'Промени';

  @override
  String get aboutChangelogHelp => 'Какво е ново във всяка версия';

  @override
  String get aboutServerProject => 'Сървърът tix';

  @override
  String get aboutServerProjectHelp =>
      'Сървърът, уеб приложението и командният ред';

  @override
  String get aboutSecurity => 'Политика за сигурност';

  @override
  String get aboutSecurityHelp => 'Как да съобщите за уязвимост поверително';

  @override
  String get aboutHelp => 'Нещо не е наред?';

  @override
  String get aboutReportBug => 'Съобщете за грешка';

  @override
  String get aboutReportBugHelp =>
      'Отваря нов проблем в GitHub с горните версии вече попълнени. Никога не поставяйте API токен.';

  @override
  String get aboutCopyDiagnostics => 'Копиране на диагностика';

  @override
  String get aboutDiagnosticsCopied => 'Диагностиката е копирана.';

  @override
  String get aboutIncludeServer => 'Включване на адреса на сървъра';

  @override
  String get aboutIncludeServerHelp =>
      'Изключено пази адреса на частен сървър извън копираното.';

  @override
  String get aboutLicence => 'Лиценз';

  @override
  String get aboutLicenceBody =>
      'tix-mobile е свободен софтуер под GNU AGPL, версия 3 или по-нова. Приносите се приемат съгласно споразумението за принос на проекта (CLA).';

  @override
  String get aboutLicences => 'Лицензи';

  @override
  String get aboutLicencesHelp => 'Софтуерът с отворен код в това приложение';

  @override
  String get aboutOpenFailed => 'Връзката не може да се отвори.';

  @override
  String get paletteThemeOled => 'OLED черна тема';

  @override
  String get manageTitle => 'Управление';

  @override
  String manageSubtitle(String tenant) {
    return 'Какво можете да управлявате в $tenant';
  }

  @override
  String get goManage => 'Към Управление';

  @override
  String get navMore => 'Още';

  @override
  String get manageEmpty => 'С тези данни за достъп няма какво да управлявате.';

  @override
  String get manageEmptyBody =>
      'Проектите, работните потоци, хората и наемателят изискват права, които този токен или роля нямат. Поискайте по-широки от администратор.';

  @override
  String get manageGroupProjects => 'Проекти';

  @override
  String get manageGroupWorkflows => 'Работни потоци';

  @override
  String get manageGroupFields => 'Полета';

  @override
  String get manageGroupPeople => 'Хора';

  @override
  String get manageGroupAccess => 'Достъп';

  @override
  String get manageGroupTenant => 'Наемател';

  @override
  String get manageGroupServer => 'Сървър';

  @override
  String get manageProjectsSubtitle =>
      'Създаване, преименуване, оцветяване, архивиране и изтриване на проекти';

  @override
  String get manageWorkflowsSubtitle =>
      'Състояния, преходите между тях и кой може да ги прави';

  @override
  String get manageFieldsSubtitle =>
      'Потребителските полета на задачите във всеки проект';

  @override
  String get manageSave => 'Запази';

  @override
  String get manageSaveChanges => 'Запази промените';

  @override
  String get manageDelete => 'Изтрий';

  @override
  String get manageClear => 'Изчисти';

  @override
  String get manageYes => 'Да';

  @override
  String get manageNo => 'Не';

  @override
  String get manageDangerZone => 'Опасна зона';

  @override
  String get manageInherited => 'Наследено';

  @override
  String get manageDurationHelp =>
      'Продължителност като 30m или 4h. Празно наследява.';

  @override
  String get manageChanged => 'променено';

  @override
  String manageTaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count задачи',
      one: '1 задача',
    );
    return '$_temp0';
  }

  @override
  String get manageDragToReorder => 'Плъзнете за пренареждане';

  @override
  String get colourNone => 'Без цвят';

  @override
  String get colourSlate => 'Графит';

  @override
  String get colourRed => 'Червено';

  @override
  String get colourAmber => 'Кехлибар';

  @override
  String get colourGreen => 'Зелено';

  @override
  String get colourTeal => 'Синьозелено';

  @override
  String get colourBlue => 'Синьо';

  @override
  String get colourViolet => 'Виолетово';

  @override
  String get colourPink => 'Розово';

  @override
  String get colourCustom => 'Собствен цвят';

  @override
  String get iconNone => 'Без';

  @override
  String get iconText => 'Емоджи';

  @override
  String get iconBuiltin => 'Икона';

  @override
  String get iconImage => 'Изображение';

  @override
  String get iconNoneHelp => 'Вместо икона се показват първите букви от името.';

  @override
  String get iconTextLabel => 'Емоджи или букви';

  @override
  String get iconTextHelp => 'Едно емоджи или една-две букви.';

  @override
  String get iconImageHelp => 'PNG, JPEG, WebP или SVG, до 64 KB.';

  @override
  String get iconUpload => 'Избери изображение';

  @override
  String get projectNew => 'Нов проект';

  @override
  String get projectCreate => 'Създай проект';

  @override
  String projectCreated(String name) {
    return 'Създаден е $name.';
  }

  @override
  String get projectName => 'Име';

  @override
  String get projectKey => 'Ключ';

  @override
  String get projectKeyHelp =>
      'Започва всяка препратка към задача, например infra-1. Букви, цифри, - и _.';

  @override
  String get projectKeyChangeHelp =>
      'Промяната преименува всички препратки към задачи; старият ключ продължава да работи.';

  @override
  String get projectDescription => 'Описание';

  @override
  String get projectWorkflow => 'Работен поток';

  @override
  String get projectWorkflowInfo =>
      'Състоянията, през които минават задачите на проекта. tix отказва смяна, докато задача е в състояние, което новият поток няма.';

  @override
  String get projectColour => 'Цвят';

  @override
  String get projectIcon => 'Икона';

  @override
  String get projectSettingsTitle => 'Настройки на проекта';

  @override
  String get projectSectionProject => 'Проект';

  @override
  String get projectSectionAppearance => 'Външен вид';

  @override
  String get projectSectionClaims => 'Заявки';

  @override
  String get projectClaimsInfo =>
      'Колко дълго важи заявка за задачите на проекта. Стойността на проекта има предимство пред тази на потока и наемателя; най-дългата заявка може само да е по-кратка от тази на наемателя.';

  @override
  String get projectLeaseDefault => 'Продължителност на заявка';

  @override
  String get projectLeaseMax => 'Най-дълга заявка';

  @override
  String get projectLeaseMaxHelp =>
      'Продължителност като 24h, под тавана на наемателя. Празно наследява.';

  @override
  String get projectManageFields => 'Потребителски полета';

  @override
  String get projectManageFieldsHelp =>
      'Определете полетата на задачите в проекта.';

  @override
  String get projectReadOnly =>
      'Можете да виждате тези настройки, но не и да ги променяте: нужно е project:write.';

  @override
  String get projectSaved => 'Проектът е запазен.';

  @override
  String get projectRekeyTitle => 'Да се смени ли ключът на проекта?';

  @override
  String get projectRekeyBody =>
      'Всички препратки към задачи се сменят с ключа:';

  @override
  String projectRekeyAlias(String old) {
    return 'Връзките, препратките и филтрите с $old продължават да работят: старият ключ остава като псевдоним и друг проект не може да го вземе.';
  }

  @override
  String get projectRekeyConfirm => 'Смени ключа';

  @override
  String get projectArchive => 'Архивирай проекта';

  @override
  String get projectArchiveHelp =>
      'Скрива го от списъците и запазва задачите и историята му. В tix няма разархивиране.';

  @override
  String projectArchiveTitle(String name) {
    return 'Да се архивира ли $name?';
  }

  @override
  String get projectArchiveBody =>
      'Проектът изчезва от списъците по подразбиране. Задачите и историята му остават. tix не може да разархивира проект.';

  @override
  String projectArchived(String name) {
    return '$name е архивиран.';
  }

  @override
  String get projectArchivedBadge => 'архивиран';

  @override
  String get projectIsArchived => 'Този проект е архивиран.';

  @override
  String get projectDelete => 'Изтрий проекта';

  @override
  String get projectDeleteHelp =>
      'Премахва го завинаги. Задачите му се преместват в друг проект или се изтриват с него.';

  @override
  String projectDeleteTitle(String key) {
    return 'Да се изтрие ли $key?';
  }

  @override
  String get projectDeleteEmpty =>
      'Проектът няма задачи. Изтриването не може да се отмени.';

  @override
  String projectDeleteHolds(int live, int trashed) {
    String _temp0 = intl.Intl.pluralLogic(
      live,
      locale: localeName,
      other: '$live задачи',
      one: '1 задача',
    );
    String _temp1 = intl.Intl.pluralLogic(
      trashed,
      locale: localeName,
      other: '$trashed в кошчето',
      one: '1 в кошчето',
    );
    return 'Има $_temp0 и $_temp1. Какво да стане с тях?';
  }

  @override
  String get projectDeleteMove => 'Премести ги в друг проект';

  @override
  String get projectDeleteNoTarget =>
      'Няма друг активен проект, в който да се преместят.';

  @override
  String get projectDeleteTarget => 'Премести в';

  @override
  String get projectDeleteMapping => 'Състояние след преместването';

  @override
  String get projectDeleteTasks => 'Изтрий ги завинаги';

  @override
  String projectDeleteType(String key) {
    return 'Въведете $key за потвърждение';
  }

  @override
  String get projectDeleteConfirm =>
      'Проектът и задачите му се изтриват завинаги.';

  @override
  String projectDeleteMoveConfirm(String target) {
    return 'Задачите се преместват в $target, след което проектът се изтрива завинаги.';
  }

  @override
  String projectDeleted(String key) {
    return '$key е изтрит.';
  }

  @override
  String get fieldsTitle => 'Потребителски полета';

  @override
  String get fieldProjectsSubtitle =>
      'tix определя полетата за всеки проект. Изберете проект.';

  @override
  String get fieldsEmpty => 'Още няма потребителски полета.';

  @override
  String get fieldsEmptyBody =>
      'Полето добавя избрана от вас стойност към всяка задача в проекта, например среда или клиент.';

  @override
  String get fieldsReadOnly =>
      'Можете да виждате тези полета, но не и да ги променяте: нужно е project:write.';

  @override
  String get fieldNew => 'Ново поле';

  @override
  String fieldEdit(String key) {
    return 'Редакция на $key';
  }

  @override
  String get fieldKey => 'Ключ';

  @override
  String get fieldKeyHelp =>
      'Как задачите и филтрите наричат полето, например env.';

  @override
  String get fieldKeyFixed =>
      'Ключът именува полето; за да го смените, създайте ново поле.';

  @override
  String get fieldLabel => 'Етикет';

  @override
  String get fieldLabelHelp => 'Какво виждат хората. Празно показва ключа.';

  @override
  String get fieldType => 'Тип';

  @override
  String get fieldOptions => 'Възможности';

  @override
  String get fieldOptionsHelp =>
      'Позволените стойности, разделени със запетаи.';

  @override
  String get fieldDefault => 'По подразбиране';

  @override
  String get fieldNoDefault => 'Без стойност по подразбиране';

  @override
  String get fieldPickDefault => 'Изберете стойност';

  @override
  String get fieldActorHint => 'Потребителско име, например raj';

  @override
  String fieldDefaultIs(String value) {
    return 'по подразбиране $value';
  }

  @override
  String get fieldDefaultUnreadable =>
      'Тази стойност не може да се прочете като типа на полето.';

  @override
  String get fieldRequired => 'Задължително';

  @override
  String get fieldRequiredHelp =>
      'Нова задача без стойност се отказва, освен ако има стойност по подразбиране.';

  @override
  String fieldSaved(String key) {
    return '$key е запазено.';
  }

  @override
  String fieldDeleteTitle(String key) {
    return 'Да се изтрие ли полето $key?';
  }

  @override
  String get fieldDeleteBody => 'Задачите спират да показват това поле.';

  @override
  String fieldDeleted(String key) {
    return '$key е изтрито.';
  }

  @override
  String get fieldTypeString => 'Текст, един ред';

  @override
  String get fieldTypeText => 'Текст, няколко реда';

  @override
  String get fieldTypeInt => 'Цяло число';

  @override
  String get fieldTypeFloat => 'Число';

  @override
  String get fieldTypeBool => 'Да или не';

  @override
  String get fieldTypeDate => 'Дата';

  @override
  String get fieldTypeDatetime => 'Дата и час';

  @override
  String get fieldTypeEnum => 'Избор';

  @override
  String get fieldTypeActor => 'Човек или агент';

  @override
  String get fieldTypeJson => 'JSON';

  @override
  String get fieldTypeUnknown => 'Непознат';

  @override
  String get categoryTodo => 'За работа';

  @override
  String get categoryInProgress => 'В процес';

  @override
  String get categoryBlocked => 'Блокирано';

  @override
  String get categoryWaiting => 'Изчакване';

  @override
  String get categoryDone => 'Готово';

  @override
  String get categoryCancelled => 'Отменено';

  @override
  String get categoryDerived => 'От състоянието (решава tix)';

  @override
  String get workflowsTitle => 'Работни потоци';

  @override
  String get workflowsSubtitle =>
      'Състоянията, през които минават задачите, и как';

  @override
  String get workflowsEmpty => 'Няма работни потоци.';

  @override
  String get workflowTitle => 'Работен поток';

  @override
  String workflowSubtitle(String key) {
    return 'Ключ $key';
  }

  @override
  String get workflowBuiltin => 'вграден';

  @override
  String workflowStateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count състояния',
      one: '1 състояние',
    );
    return '$_temp0';
  }

  @override
  String get workflowNew => 'Нов работен поток';

  @override
  String get workflowCreate => 'Създай поток';

  @override
  String workflowCreated(String name) {
    return 'Създаден е $name.';
  }

  @override
  String get workflowKey => 'Ключ';

  @override
  String get workflowKeyHelp => 'Букви, цифри, - и _, започва с буква.';

  @override
  String get workflowKeyTaken =>
      'Вече има поток с този ключ; запазването би го заменило.';

  @override
  String get workflowName => 'Име';

  @override
  String get workflowStartFrom => 'Започни от';

  @override
  String get workflowMinimal => 'Отворено и готово';

  @override
  String workflowCopyOf(String name) {
    return 'Копие на $name';
  }

  @override
  String get workflowReadOnly =>
      'Можете да виждате този поток, но не и да го променяте: нужно е workflow:write.';

  @override
  String get workflowRefused => 'tix отказа промяната';

  @override
  String get workflowSaved => 'Потокът е запазен.';

  @override
  String get workflowSectionGeneral => 'Поток';

  @override
  String get workflowInitial => 'Начално състояние';

  @override
  String get workflowInitialHelp => 'Откъдето започва нова задача.';

  @override
  String get workflowDefaultLease => 'Продължителност на заявка';

  @override
  String get workflowSectionStates => 'Състояния';

  @override
  String get workflowStatesHelp =>
      'Плъзнете дръжката за пренареждане. Докоснете състояние, за да го редактирате.';

  @override
  String get workflowAddState => 'Добави състояние';

  @override
  String workflowEditState(String name) {
    return 'Редакция на $name';
  }

  @override
  String get workflowStateKey => 'Ключ';

  @override
  String get workflowStateKeyHelp =>
      'Какво съдържа състоянието на задача, например review.';

  @override
  String get workflowStateKeyRename =>
      'Преименуването премества задачите на това състояние към новия ключ при запазване.';

  @override
  String get workflowStateKeyTaken => 'Друго състояние има този ключ.';

  @override
  String get workflowStateLabel => 'Етикет';

  @override
  String get workflowStateCategory => 'Категория';

  @override
  String get workflowStateCategoryInfo =>
      'Групира състоянието за цветове, табла и отчети. Ако го оставите на tix: готово при крайно, за работа при начално, в процес иначе.';

  @override
  String get workflowStateInitial => 'Начално състояние';

  @override
  String get workflowTerminal => 'Крайно';

  @override
  String get workflowTerminalHelp =>
      'Достигането му завършва задачата и удовлетворява зависимите от нея.';

  @override
  String get workflowRevert => 'Връщане при изтичане на заявка';

  @override
  String get workflowRevertHelp =>
      'Заявена задача тук се връща, когато заявката изтече.';

  @override
  String get workflowRevertTo => 'Връщане към';

  @override
  String workflowRevertsTo(String state) {
    return 'връща към $state';
  }

  @override
  String get workflowInitialBadge => 'начално';

  @override
  String get workflowSectionTransitions => 'Преходи';

  @override
  String get workflowTransitionsHelp =>
      'Докоснете състояние, за да позволите прехода. Бутонът за правила на избран преход изисква коментар или право.';

  @override
  String workflowCanMoveTo(String name) {
    return 'От $name задача може да отиде в';
  }

  @override
  String get workflowNoMoves => 'Няма преход от това състояние.';

  @override
  String get workflowMoveRules => 'Правила за прехода';

  @override
  String workflowRulesTitle(String from, String to) {
    return '$from към $to';
  }

  @override
  String get workflowNeedsComment => 'Изисква коментар';

  @override
  String get workflowNeedsCommentHelp => 'Преходът се отказва без коментар.';

  @override
  String workflowNeedsScope(String scope) {
    return 'Изисква $scope';
  }

  @override
  String get workflowRequiredScope => 'Нужно право';

  @override
  String get workflowRequiredScopeHelp =>
      'Само притежател на това право може да направи прехода.';

  @override
  String get workflowNoScope => 'Без';

  @override
  String get workflowSectionRoutes => 'Маршрути';

  @override
  String get workflowRoutesInfo =>
      'Колко прехода дели всяко състояние от началното. Преход към по-далечно състояние минава през междинните, един по един.';

  @override
  String workflowSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count стъпки',
      one: '1 стъпка',
    );
    return '$_temp0';
  }

  @override
  String get workflowUnreachable => 'Няма маршрут дотук';

  @override
  String get workflowSectionRemoved => 'Премахнати състояния';

  @override
  String get workflowRemovedHelp =>
      'Задачите в премахнато състояние трябва да отидат някъде, иначе tix отказва запазването.';

  @override
  String workflowMigrate(String state) {
    return 'Премести задачите от $state в';
  }

  @override
  String get workflowMigrateNone => 'Никъде (отказ, ако има задачи)';

  @override
  String get workflowDelete => 'Изтрий потока';

  @override
  String get workflowDeleteHelp =>
      'Може да се изтрие само поток, който никой проект не ползва.';

  @override
  String workflowDeleteTitle(String key) {
    return 'Да се изтрие ли $key?';
  }

  @override
  String get workflowDeleteBody => 'Потокът се изтрива завинаги.';

  @override
  String workflowDeleted(String key) {
    return '$key е изтрит.';
  }

  @override
  String get manageUsersTitle => 'Потребители';

  @override
  String get manageUsersSubtitle => 'Хората в наемателя, ролите им и поканите';

  @override
  String get manageTokensTitle => 'API токени';

  @override
  String get manageTokensSubtitle =>
      'Токени за агенти и скриптове и какво може всеки';

  @override
  String get manageTransferTitle => 'Внос и износ';

  @override
  String get manageTransferSubtitle => 'Пренасяне на задачи и цели наематели';

  @override
  String get localInstanceAdvancedBody =>
      'Използвайте база данни там, където е, например в папка, която Nextcloud, Syncthing или iCloud Drive синхронизира, вместо копие в приложението.';

  @override
  String get localInstanceAdvancedTitle => 'Разширено: отваряне на място';

  @override
  String get localInstanceBrowseCreate => 'Създаване тук';

  @override
  String get localInstanceBrowseEmpty => 'Тук няма папки или бази данни.';

  @override
  String get localInstanceBrowseNewLabel => 'Нова база данни в тази папка';

  @override
  String get localInstanceBrowseTitle => 'Изберете база данни';

  @override
  String get localInstanceBrowseUp => 'Нагоре';

  @override
  String localInstanceConflicts(String names) {
    return 'Копия от конфликт при синхронизация до този файл: $names. Проверете кое съдържа последната ви работа, преди да продължите.';
  }

  @override
  String get localInstanceDesktopIntro =>
      'Създайте нова tix база данни. За да използвате вече съществуваща, отворете я на място по-долу.';

  @override
  String get localInstanceEngineResting => 'Спрян, стартира отново при нужда';

  @override
  String localInstanceEngineRunning(String address) {
    return 'Работи на $address';
  }

  @override
  String get localInstanceEngineStarting => 'Стартира';

  @override
  String get localInstanceEngineStop => 'Спиране';

  @override
  String get localInstanceEngineStopped => 'Спрян';

  @override
  String get localInstanceErrorAccess =>
      'tix вече няма достъп до този файл. Разрешете достъпа отново или премахнете инстанцията и отворете файла наново.';

  @override
  String get localInstanceErrorFolder =>
      'tix не може да създава файлове в тази папка, а SQLite държи два файла до базата данни. Изберете папка, в която може да се пише.';

  @override
  String get localInstanceErrorLock =>
      'Този файл не може да бъде заключен, така че SQLite не може да го пази тук. Може да е при облачен доставчик, който не предлага истински файлове.';

  @override
  String get localInstanceErrorNotDatabase =>
      'Този файл не е tix база данни на това устройство. Ако е в облачна папка, може още да не е изтеглен.';

  @override
  String get localInstanceErrorNotDownloaded =>
      'Този файл още не е изтеглен на това устройство. Отворете го в приложението Файлове, за да се изтегли, и опитайте пак.';

  @override
  String get localInstanceIdleHelp =>
      'Двигател, който не е обслужил нищо толкова време, спира, за да пести батерия, и стартира отново, когато приложението има нужда от него.';

  @override
  String get localInstanceIdleLabel => 'Спиране на неизползван двигател след';

  @override
  String localInstanceIdleMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get localInstanceIdleNever => 'Никога';

  @override
  String get localInstanceIdleTitle => 'Локални бази данни';

  @override
  String get localInstanceImportInstead => 'Внасяне на копие';

  @override
  String get localInstanceInPlaceNote => 'Използва се на място';

  @override
  String get localInstanceOpenInPlace => 'Отваряне на място…';

  @override
  String get localInstancePermissionBody =>
      'За да отвори база данни там, където е, Android трябва да даде на tix „Достъп до всички файлове“. tix чете и пише само в базата данни, която изберете, и във файловете, които SQLite държи до нея.';

  @override
  String get localInstancePermissionContinue => 'Продължаване';

  @override
  String get localInstancePermissionRefused =>
      'Достъпът до всички файлове не беше разрешен, така че tix не може да отваря файлове на място. Можете вместо това да внесете копие.';

  @override
  String get localInstancePermissionTitle => 'Разрешете достъп до файловете';

  @override
  String get localInstanceSyncWarning =>
      'Синхронизирана база данни трябва да е отворена само на едно устройство наведнъж. Първо затворете tix на другите си устройства и изчакайте синхронизацията. tix спира базата данни всеки път, когато отиде във фонов режим, така че синхронизиращият клиент винаги намира цял файл.';

  @override
  String get localInstanceWalLeftOver =>
      'До този файл вече имаше журнал за запис (write-ahead log). Друга програма може да го държи отворен или синхронизиращ клиент да е копирал такъв от друго устройство.';

  @override
  String get widgetMyWork => 'Моята работа';

  @override
  String get widgetInbox => 'Входящи';

  @override
  String get widgetQuickAdd => 'Бързо добавяне';

  @override
  String get widgetAddTask => 'Добави задача';

  @override
  String get widgetNothingDue => 'Нищо не е възложено на вас';

  @override
  String get widgetAllRead => 'Всичко е прочетено';

  @override
  String get widgetNoOpenTasks => 'Няма отворени задачи';

  @override
  String get widgetUpdated => 'Обновено';

  @override
  String get widgetOpenApp => 'Отворете tix, за да заредите тази джаджа';

  @override
  String get widgetLocalStale => 'Обновява се, когато tix е отворено';

  @override
  String get widgetOverdue => 'Просрочено';

  @override
  String get widgetToday => 'Днес';

  @override
  String get widgetComplete => 'Завърши';

  @override
  String get widgetProjectMissing => 'Няма го в този контекст';

  @override
  String get widgetSignedOut => 'Влезте в tix';

  @override
  String widgetMore(int count) {
    return '+$count още';
  }

  @override
  String widgetUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочетени',
      one: '1 непрочетено',
      zero: 'Нищо непрочетено',
    );
    return '$_temp0';
  }

  @override
  String get settingsWidgets => 'Джаджи на началния екран';

  @override
  String get settingsWidgetLockCounts => 'Само бройки на заключения екран';

  @override
  String get settingsWidgetLockCountsHelp =>
      'Джаджите на заключения екран показват колко, а не какво.';

  @override
  String get settingsWidgetsHelp =>
      'Добавете джаджи на tix от началния екран. Те показват последно прочетеното от приложението, а отметка изчаква приложението, ако сървърът е недостъпен.';

  @override
  String get widgetOpenUpdate => 'Отворете tix, за да обновите';

  @override
  String get widgetPickProject => 'Изберете проект';

  @override
  String liveStatusLabel(String state) {
    return 'Обновявания на живо: $state';
  }

  @override
  String get liveStatusLive => 'На живо';

  @override
  String get liveStatusLiveInfo =>
      'Промените, направени другаде, се появяват тук веднага.';

  @override
  String get liveStatusConnecting => 'Свързване';

  @override
  String get liveStatusConnectingInfo =>
      'Свързване към обновяванията на живо. Промените ще се появят, щом връзката се осъществи.';

  @override
  String get liveStatusPolling => 'Запитване';

  @override
  String get liveStatusPollingInfo =>
      'Връзката на живо не се задържа в тази мрежа, затова обновяванията идват по обикновен HTTP. Може да закъсняват с няколко секунди.';

  @override
  String get liveStatusRefreshing => 'Опресняване';

  @override
  String liveStatusRefreshingInfo(int seconds) {
    return 'Обновяванията на живо не достигат до приложението, а сървърът е твърде стар за запитвания, затова екранът се презарежда на всеки $seconds секунди.';
  }

  @override
  String get liveStatusOffline => 'Няма връзка';

  @override
  String get liveStatusOfflineInfo =>
      'Сървърът не е достъпен. Приложението продължава да опитва и ще навакса, щом се върне.';

  @override
  String get liveStatusUnavailable => 'Недостъпно';

  @override
  String get liveStatusUnavailableInfo =>
      'Тази връзка няма право да следи обновяванията на живо (нужен е обхватът event:subscribe). Дръпнете надолу, за да опресните.';

  @override
  String get copyToClipboard => 'Копирай';

  @override
  String get copiedToClipboard => 'Копирано.';
}
