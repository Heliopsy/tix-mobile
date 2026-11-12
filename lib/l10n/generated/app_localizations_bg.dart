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
  String helpAbout(String topic) {
    return 'Помощ: $topic';
  }

  @override
  String get helpServerBody =>
      'tix сървърът е компютърът, на който работи tix на вашия екип. Адресът му е същият, с който отваряте tix в уеб браузър, например https://tix.example.com.\n\nНе го знаете? Попитайте този, който поддържа tix за вас. Можете да пропуснете https:// и наклонената черта накрая.';

  @override
  String get helpKindTitle => 'Сървър или това устройство';

  @override
  String get helpKindBody =>
      'Сървър: свържете се с tix, който някой поддържа за вас или екипа ви, и работете по същите задачи като всички останали там.\n\nТова устройство: tix работи в самото приложение, с база данни на това устройство. Не са нужни сървър и акаунт и нищо не се споделя с никого.';

  @override
  String get helpMethodTitle => 'Как да се свържете';

  @override
  String get helpMethodSignIn =>
      'Вход: използвайте имейла и паролата, с които влизате в tix в уеб.';

  @override
  String get helpMethodToken =>
      'Токен: поставете API токен вместо парола. Той остава свързан, докато не бъде отменен, затова е подходящ за устройство, което държите.';

  @override
  String get helpMethodInvite =>
      'Покана: получили сте имейл с покана? Поставете връзката от него и сървърът се попълва вместо вас.';

  @override
  String get helpTokenBody =>
      'API токенът е дълъг код, който пуска приложението без вашата парола.\n\nСъздайте го на страницата API токени в tix в уеб или изпълнете tix token create там, където работи командата tix. Копирайте го, когато се покаже: виждате го само веднъж.';

  @override
  String get helpEmailBody =>
      'Имейл адресът на вашия tix акаунт, същият, с който влизате в tix в уеб.';

  @override
  String get helpPasswordBody =>
      'Вашата tix парола, същата като в уеб. Забравили сте я? Този, който поддържа tix за вас, може да я смени.';

  @override
  String get helpInviteBody =>
      'Когато някой ви покани в tix, получавате имейл с връзка. Поставете връзката тук или я споделете към tix от пощенското си приложение.\n\nАдресът на сървъра идва с връзката, така че не е нужно да го въвеждате.';

  @override
  String get helpNameBody =>
      'Име за тази връзка, видимо само в приложението. Удобно е, когато ползвате повече от един сървър или акаунт. Оставете празно, за да се ползва адресът на сървъра.';

  @override
  String get helpRememberBody =>
      'Така сървърът пази сесията ви по-дълго и паролата ви се иска по-рядко. Колко дълго решава този, който поддържа tix за вас.\n\nИзключете го на устройство, което ползват и други. Излизането прекратява сесията и в двата случая.';

  @override
  String get helpTenantTitle => 'Тенанти';

  @override
  String get helpTenantBody =>
      'Един tix може да съдържа няколко отделни работни пространства, наречени тенанти, например по едно за всяка фирма или екип. Всеки има свои проекти и хора.\n\nИзберете кой да се отвори. Останалите можете да добавите по-късно.';

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
  String get quickAddHint =>
      'Поправи входа !high #auth @raj due:fri +web ^web-3';

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
  String get themeLabel => 'Цветова схема';

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
      'Сесията трае колкото позволява сървърът, по-дълго със „Запомни ме“. Използвайте токен за устройство, което трябва да остане свързано постоянно.';

  @override
  String get staySignedIn => 'Запомни ме';

  @override
  String get staySignedInHelp =>
      'Това устройство остава влязло по-дълго, където сървърът го позволява. Изключете го на споделено устройство.';

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
  String get markDone => 'Отбележи като готова';

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
  String get taskDetailBlocked => 'Чака задача, която не е завършена.';

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
  String get taskMoveToProject => 'Премести в проект…';

  @override
  String taskMoveToProjectTitle(String ref) {
    return 'Преместване на $ref в друг проект';
  }

  @override
  String taskMoveToProjectBody(String ref, String project) {
    return '$ref получава следващия номер в $project, а $ref продължава да води до нея. Коментарите, историята, връзките, етикетите и изпълнителят се местят с нея. Статусът се запазва, ако работният процес на $project има такъв, иначе задачата започва от първия статус. Персонализираните полета, които $project не определя, остават.';
  }

  @override
  String get taskMoveToProjectPick =>
      'Изберете проекта, в който да се премести.';

  @override
  String get taskMoveToProjectAction => 'Премести';

  @override
  String get taskMoveToProjectNone =>
      'Няма друг проект, в който да се премести.';

  @override
  String taskMovedToProject(String from, String to) {
    return '$from вече е $to.';
  }

  @override
  String get taskMovedToProjectStatus => 'Започва от първия статус на проекта.';

  @override
  String taskMovedToProjectDropped(String fields) {
    return 'Останаха: $fields.';
  }

  @override
  String get taskMoveUnsupported =>
      'Този сървър не може да мести задачи в друг проект.';

  @override
  String get taskMoveKeywords => 'премести проект прехвърли move project';

  @override
  String bulkMoveProjectTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Преместване на $count задачи в друг проект',
      one: 'Преместване на 1 задача в друг проект',
    );
    return '$_temp0';
  }

  @override
  String bulkMoveProjectBody(String project) {
    return 'Всяка задача получава следващия номер в $project, а старият ѝ номер продължава да води до нея. Статус, който работният процес на $project няма, започва от първия му статус, а полетата, които $project не определя, остават. Няма отмяна.';
  }

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
      'Тази задача чака, докато всяка задача тук не стигне до завършено състояние.';

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
  String get taskDetailSubtasksInfo =>
      'Цялото дърво под тази задача. Показват се три нива наведнъж, а по-дълбоко ниво се зарежда, когато го поискате. Стрелката до подзадача скрива нейните подзадачи.';

  @override
  String taskDetailSubtasksOf(String ref) {
    return 'Подзадачи на $ref';
  }

  @override
  String taskDetailShowSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Покажи $count подзадачи',
      one: 'Покажи 1 подзадача',
    );
    return '$_temp0';
  }

  @override
  String get taskDetailSubtasksShallow =>
      'Дървото е твърде голямо, за да се покаже цялото, затова се виждат само преките подзадачи.';

  @override
  String get taskDetailDeleteAllSubtasksBody =>
      'Подзадачите ѝ се изтриват с нея, на всяко ниво.';

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
  String get taskDetailWake => 'Върни сега';

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
  String tasksHeldByAgent(int count) {
    return 'заети от агент: $count';
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
  String get boardWake => 'Върни сега';

  @override
  String boardWoken(String ref) {
    return '$ref е върната';
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
  String get bulkExit => 'Изход от избирането';

  @override
  String get bulkExtendDown => 'Разшири избора надолу';

  @override
  String get bulkExtendUp => 'Разшири избора нагоре';

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
  String get bulkSelectMode => 'Избери задачи';

  @override
  String bulkSelected(int count) {
    return '$count избрани';
  }

  @override
  String get bulkTagAdd => 'Добави етикет';

  @override
  String get bulkTagRemove => 'Премахни етикет';

  @override
  String get filterBlocked => 'Чака';

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
  String get filterSuggestions => 'Предложения за филтъра';

  @override
  String filterRemoveTerm(String term) {
    return 'Премахване на $term';
  }

  @override
  String get filterPickers => 'Филтри';

  @override
  String get filterPickersHelp =>
      'Всеки избор заменя тази част от филтъра. „Всички“ я премахва.';

  @override
  String get filterAny => 'Всички';

  @override
  String get filterTag => 'Етикет';

  @override
  String get filterMe => 'Аз';

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
  String get lanesGroupBy => 'Ленти по';

  @override
  String get lanesByProject => 'Проект';

  @override
  String get lanesByTag => 'Етикет';

  @override
  String get lanesNoTag => 'Без етикет';

  @override
  String lanesOnly(String name) {
    return 'Само задачите в $name';
  }

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
  String get addDetailsTitle => 'Добави с подробности';

  @override
  String get addDetailsMore => 'Още подробности';

  @override
  String get addDetailsTitleLabel => 'Заглавие';

  @override
  String get addDetailsTitleHint => 'Какво трябва да се направи?';

  @override
  String get addDetailsTitleRequired => 'Задачата трябва да има заглавие.';

  @override
  String get addDetailsBody => 'Описание';

  @override
  String get addDetailsBodyHint => 'Добави описание';

  @override
  String get addDetailsPriority => 'Приоритет';

  @override
  String get addDetailsDue => 'Краен срок';

  @override
  String get addDetailsDuePick => 'Избери дата';

  @override
  String get addDetailsDueClear => 'Премахни крайния срок';

  @override
  String get addDetailsAssignee => 'Изпълнител';

  @override
  String get addDetailsAssigneeHint => 'все още никой';

  @override
  String get addDetailsAssigneeInfo =>
      'Потребителското име на човек или агент. Оставете празно и задачата ще чака който я поеме.';

  @override
  String get addDetailsTags => 'Етикети';

  @override
  String get addDetailsTagsHint => 'разделени със запетая';

  @override
  String get addDetailsMoreOptions => 'Още настройки';

  @override
  String get addDetailsMoreOptionsHint =>
      'повторение, родител, зависимости, резервация';

  @override
  String get addDetailsRepeat => 'Повтаряй след завършване';

  @override
  String get addDetailsRepeatHint =>
      'например: every week, every month on day 1, 3 days after done';

  @override
  String get addDetailsRepeatInfo =>
      'Завършването на повтаряща се задача създава следващата, със същото заглавие, етикети и изпълнител и краен срок на следващата дата. Отказването ѝ прекратява поредицата.';

  @override
  String get addDetailsParent => 'Родителска задача';

  @override
  String get addDetailsParentInfo =>
      'Прави задачата подзадача на друга. Посочете я с референцията ѝ, ключа и номера от реда ѝ.';

  @override
  String get addDetailsDependsOn => 'Зависи от';

  @override
  String get addDetailsDependsOnInfo =>
      'Задачи, които трябва да са завършени, преди тази да започне, разделени със запетая. Дотогава задачата се показва като чакаща.';

  @override
  String get addDetailsLease => 'Резервация';

  @override
  String get addDetailsLeaseHint => 'Наследена';

  @override
  String get addDetailsLeaseInfo =>
      'Колко дълго трае поемането на тази задача, преди резервацията да изтече, когато поемането не посочва своя продължителност. Празно поле използва тази на проекта, после на авторски работен процес, после на тенанта. Никога по-дълго от максимума.';

  @override
  String get addDetailsCreate => 'Създай задача';

  @override
  String get paletteGroupProjects => 'Проекти';

  @override
  String get paletteGroupRecent => 'Скорошни задачи';

  @override
  String get paletteGroupContexts => 'Превключване към';

  @override
  String get paletteGroupTheme => 'Цветова схема';

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
  String get paletteThemeLight => 'Светла цветова схема';

  @override
  String get paletteThemeDark => 'Тъмна цветова схема';

  @override
  String get paletteThemeSystem => 'Цветова схема на системата';

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
  String liveNewAbove(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count нови, покажи',
      one: '1 нова, покажи',
    );
    return '$_temp0';
  }

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
  String get themeOled => 'OLED';

  @override
  String get themeDim => 'Нисък контраст';

  @override
  String get themeSystemOled => 'Система, OLED на тъмно';

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
  String get paletteThemeOled => 'OLED цветова схема';

  @override
  String get paletteThemeDim => 'Цветова схема с нисък контраст';

  @override
  String get paletteThemeSystemOled =>
      'Цветова схема на системата, OLED на тъмно';

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
  String get liveDetailsHint => 'Докоснете за подробности за връзката';

  @override
  String get liveDetailsLongPressHint => 'Задръжте за подробности за връзката';

  @override
  String get liveDetailsShow => 'показване на подробности за връзката';

  @override
  String get liveDetailsTitle => 'Подробности за връзката';

  @override
  String get liveDetailsNone => 'Няма връзка на живо за този контекст.';

  @override
  String get liveDetailsPausedInfo =>
      'Обновяванията на живо са на пауза, докато двигателят на локалната инстанция е спрян. Тръгват отново заедно с него.';

  @override
  String get liveDetailsModePaused => 'На пауза';

  @override
  String get liveDetailsModeClosed => 'Затворено';

  @override
  String get liveDetailsServer => 'Сървър';

  @override
  String get liveDetailsMode => 'Състояние';

  @override
  String get liveDetailsTransport => 'Пренос';

  @override
  String get liveTransportWebsocket => 'WebSocket';

  @override
  String get liveTransportPoll => 'Дълго запитване по HTTP';

  @override
  String get liveTransportRefresh => 'Презареждане през интервал';

  @override
  String get liveTransportNone => 'Няма';

  @override
  String get liveSourceProbe => 'Опит за WebSocket във фонов режим';

  @override
  String get liveSourcePoll => 'Запитване';

  @override
  String get liveDetailsSince => 'От';

  @override
  String get liveDetailsLastContact => 'Последна връзка със сървъра';

  @override
  String get liveDetailsLastEvent => 'Последно събитие';

  @override
  String get liveDetailsNever => 'Още не';

  @override
  String get liveDetailsFailuresInRow => 'Поредни неуспехи';

  @override
  String get liveDetailsWindowFailures => 'Неуспехи на WebSocket';

  @override
  String liveDetailsWindowValue(int count, int max, int minutes) {
    return '$count от $max за $minutes мин. преди преминаване към запитвания';
  }

  @override
  String get liveDetailsPollEndpoint => 'Адрес за запитвания';

  @override
  String get liveDetailsPollAvailable => 'Наличен';

  @override
  String get liveDetailsPollMissing => 'Липсва на този сървър (404 или 405)';

  @override
  String get liveDetailsNextRetry => 'Следващ опит';

  @override
  String get liveDetailsNextProbe => 'Следващ опит за WebSocket';

  @override
  String get liveDetailsLastError => 'Последна грешка';

  @override
  String get liveDetailsNoError =>
      'Нищо не се е проваляло от стартирането на приложението.';

  @override
  String get liveDetailsErrorWhat => 'Какво';

  @override
  String get liveDetailsErrorAt => 'Кога';

  @override
  String get liveDetailsErrorSource => 'При';

  @override
  String get liveDetailsErrorType => 'Изключение';

  @override
  String get liveDetailsHttpStatus => 'HTTP статус';

  @override
  String get liveDetailsOsError => 'Системна грешка';

  @override
  String liveDetailsOsErrorValue(String message, String code) {
    return '$message (код $code)';
  }

  @override
  String get liveDetailsCloseCode => 'Код на затваряне';

  @override
  String get liveDetailsErrorMessage => 'Съобщение';

  @override
  String get liveErrorUnreachable => 'Сървърът не е достъпен';

  @override
  String get liveErrorTimeout => 'Изтекло време';

  @override
  String get liveErrorTls => 'Неуспешна защитена връзка';

  @override
  String get liveErrorUpgradeRefused =>
      'Преминаването към WebSocket е отказано';

  @override
  String get liveErrorClosed => 'Връзката е затворена';

  @override
  String get liveErrorRefused => 'Отказано от сървъра';

  @override
  String get liveErrorHttp => 'HTTP грешка';

  @override
  String get liveErrorOther => 'Друга грешка';

  @override
  String get liveDetailsHints => 'Какво може да означава';

  @override
  String get liveHintIdleTimeout =>
      'Прокси или балансьор на натоварването може би затваря неактивните връзки. Времето му за четене трябва да е над 60 s за /api/v1/events и /api/v1/events/poll.';

  @override
  String get liveHintNoUpgrade =>
      'WebSocket не успява, докато обикновеният HTTP работи, така че проксито пред tix може би не препраща преминаването към WebSocket.';

  @override
  String get liveHintUnreachable =>
      'Телефонът не можа да достигне хоста. Проверете мрежата, адреса и дали сървърът работи.';

  @override
  String get liveHintTls =>
      'Сертификатът на сървъра не беше приет: може да е изтекъл, самоподписан или издаден за друго име.';

  @override
  String get liveHintRefused =>
      'Сървърът отказа обновявания на живо за тази връзка. Токенът трябва да има обхват event:subscribe.';

  @override
  String liveHintHttp(String status) {
    return 'Сървърът или прокси отговори с HTTP $status. Журналите му би трябвало да кажат защо.';
  }

  @override
  String get liveHintPollMissing =>
      'Този сървър е по-стар от адреса за запитвания, затова екранът се презарежда през интервал.';

  @override
  String get liveDetailsHistory => 'Последни промени';

  @override
  String get liveDetailsHistoryEmpty => 'Още нищо.';

  @override
  String liveDetailsHistoryError(String kind, String source) {
    return '$kind ($source)';
  }

  @override
  String get liveDetailsReconnect => 'Свързване отново';

  @override
  String get liveDetailsCopy => 'Копиране на подробностите';

  @override
  String get liveDetailsCopied =>
      'Подробностите за връзката са копирани. Токени и бисквитки не са включени.';

  @override
  String get aboutConnectionDetails => 'Подробности за връзката';

  @override
  String get aboutConnectionDetailsHelp =>
      'Как обновяванията на живо достигат този контекст и какво се провали последно';

  @override
  String get copyToClipboard => 'Копирай';

  @override
  String get copiedToClipboard => 'Копирано.';

  @override
  String get copyJson => 'Копирай JSON';

  @override
  String get copyJsonDone => 'JSON е копиран.';

  @override
  String get secretShare => 'Сподели';

  @override
  String get secretDone => 'Запазих го';

  @override
  String get roleViewer => 'наблюдател';

  @override
  String get roleMember => 'член';

  @override
  String get roleAdmin => 'администратор';

  @override
  String get roleViewerHelp => 'Чете задачи, проекти и работни потоци.';

  @override
  String get roleMemberHelp =>
      'Освен това създава, редактира, поема и мести задачи, коментира и експортира.';

  @override
  String get roleAdminHelp => 'Може всичко в този тенант.';

  @override
  String get peopleTitle => 'Потребители';

  @override
  String get peopleAdd => 'Добави потребител';

  @override
  String peopleActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активни',
      one: '1 активен',
    );
    return '$_temp0';
  }

  @override
  String peopleDisabledCount(int count) {
    return '$count изключени';
  }

  @override
  String get peopleAddMember => 'Добави член';

  @override
  String get peopleAddMemberButton => 'Добави';

  @override
  String get peopleAddMemberHelp =>
      'Дайте роля в този тенант на съществуващ агент или акаунт.';

  @override
  String get peopleNoActors => 'Всички вече са членове на този тенант.';

  @override
  String get peopleAgent => 'агент';

  @override
  String get peoplePerson => 'човек';

  @override
  String get peopleEmpty => 'Още няма потребители.';

  @override
  String get peopleYou => 'вие';

  @override
  String get peopleNoRole => 'без роля';

  @override
  String get peopleDisabled => 'изключен';

  @override
  String get peopleInvites => 'Чакащи покани';

  @override
  String get peopleInvitesInfo =>
      'Издадени и още неизползвани връзки. Повторното издаване спира старата връзка и дава нова; отмяната я спира.';

  @override
  String get peopleInvited => 'поканен';

  @override
  String peopleInvitedBy(String handle) {
    return 'поканен от $handle';
  }

  @override
  String get peopleInviteExpired => 'изтекла';

  @override
  String peopleInviteExpires(String day) {
    return 'изтича на $day';
  }

  @override
  String get peopleReissue => 'Издай отново';

  @override
  String get peopleRevoke => 'Отмени';

  @override
  String peopleRevokeInviteTitle(String email) {
    return 'Да се отмени ли поканата за $email?';
  }

  @override
  String get peopleRevokeInviteBody =>
      'Връзката спира да работи веднага. Акаунтът остава без парола, докато не го изтриете или поканите отново.';

  @override
  String peopleInviteRevoked(String email) {
    return 'Поканата за $email е отменена';
  }

  @override
  String get peopleSignInMode => 'Как влизат';

  @override
  String get peopleSignInModeInfo =>
      'Връзката с покана позволява на човека сам да избере парола. Работи веднъж и изтича; tix не праща имейли, затова я предавате сами.';

  @override
  String get peopleModeInvite => 'Връзка с покана';

  @override
  String get peopleModePassword => 'Задай парола';

  @override
  String get peopleDisplayName => 'Показвано име';

  @override
  String get peopleDisplayNameHelp => 'Ако е празно, се показва имейлът.';

  @override
  String get peopleRole => 'Роля';

  @override
  String get peopleLinkExpires => 'Връзката изтича след';

  @override
  String peopleDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дни',
      one: '1 ден',
    );
    return '$_temp0';
  }

  @override
  String get peopleYear => '1 година';

  @override
  String get peopleInviteHelp =>
      'Получавате връзка, която да им изпратите. Работи веднъж и с нея те избират своя парола.';

  @override
  String get peopleRequireChangeFirst =>
      'Изисквай смяна на паролата при първо влизане';

  @override
  String get peopleCreateInvite => 'Създай връзка';

  @override
  String get peopleCreateUser => 'Създай потребител';

  @override
  String peopleCreated(String email) {
    return 'Създаден е $email';
  }

  @override
  String get peopleInviteLink => 'Връзка с покана';

  @override
  String peopleSendLink(String email) {
    return 'Изпратете тази връзка на $email';
  }

  @override
  String get peopleLinkOnce =>
      'Работи веднъж. tix не праща имейли и връзката няма да се покаже отново.';

  @override
  String peopleLinkOnceUntil(String day) {
    return 'Работи веднъж и изтича на $day. tix не праща имейли и връзката няма да се покаже отново.';
  }

  @override
  String get peopleRename => 'Промени показваното име';

  @override
  String get peopleNoName => 'Не е зададено';

  @override
  String get peopleChangeRole => 'Промени ролята';

  @override
  String get peopleSignIn => 'Влиза с';

  @override
  String peopleSso(String provider) {
    return 'Единен вход ($provider)';
  }

  @override
  String get peoplePasswordSignIn => 'Парола';

  @override
  String get peopleSecondFactor => 'Втори фактор';

  @override
  String get peopleTotpOn => 'Настроен';

  @override
  String get peopleTotpOff => 'Няма';

  @override
  String get peopleCreatedAt => 'Създаден';

  @override
  String get peopleAccess => 'Достъп';

  @override
  String get peopleDisabledSwitch => 'Изключен';

  @override
  String get peopleDisabledHelp =>
      'Изключен акаунт не може да влиза: сесиите му приключват и API токените му се отменят веднага. Включването не ги връща.';

  @override
  String peopleDisabledToast(String name) {
    return '$name е изключен';
  }

  @override
  String peopleEnabledToast(String name) {
    return '$name отново може да влиза';
  }

  @override
  String get peopleRequireChange =>
      'Поискай смяна на паролата при следващото влизане';

  @override
  String get peopleRequireChangeHelp =>
      'Следващото им влизане с парола спира на страница, която иска нова. Отворените сесии и API токените не се засягат.';

  @override
  String get peopleSaved => 'Запазено';

  @override
  String get peopleSave => 'Запази';

  @override
  String peopleRoleChanged(String name, String role) {
    return '$name вече е $role';
  }

  @override
  String get peopleDangerZone => 'Опасна зона';

  @override
  String get peopleRemoveMember => 'Премахни от този тенант';

  @override
  String get peopleRemoveMemberHelp =>
      'Прекратява членството и запазва акаунта.';

  @override
  String get peopleRemoveMemberButton => 'Премахни';

  @override
  String peopleRemoveMemberTitle(String name) {
    return 'Да се премахне ли $name от този тенант?';
  }

  @override
  String get peopleRemoveMemberBody =>
      'Спира да действа тук веднага. Акаунтът остава и може отново да получи роля.';

  @override
  String peopleMemberRemoved(String name) {
    return '$name е премахнат от този тенант';
  }

  @override
  String peopleDelete(String name) {
    return 'Изтрий $name';
  }

  @override
  String get peopleDeleteHelp =>
      'Изтриването премахва акаунта и членството му. Обикновено искате изключване, което може да се отмени.';

  @override
  String get peopleDeleteButton => 'Изтрий';

  @override
  String peopleDeleteTitle(String name) {
    return 'Да се изтрие ли $name?';
  }

  @override
  String get peopleDeleteBody =>
      'Изтриването премахва акаунта и членството му. Не може да се отмени.';

  @override
  String peopleDeleted(String name) {
    return '$name е изтрит';
  }

  @override
  String get tokensTitle => 'API токени';

  @override
  String get tokensMine => 'Моите API токени';

  @override
  String get actorSubtitle => 'Човек или агент от този тенант';

  @override
  String get actorInfo =>
      'Човек или агент от този тенант, с името, с което другите го наричат. Какво може да прави не се показва тук.';

  @override
  String get actorOpenHint => 'Отваря страницата му';

  @override
  String get actorAbout => 'Сведения';

  @override
  String get actorYou => '(вие)';

  @override
  String get actorKindUser => 'човек';

  @override
  String get actorKindAgent => 'агент';

  @override
  String get actorKindSystem => 'система';

  @override
  String get actorHandle => 'Кратко име';

  @override
  String get actorName => 'Име';

  @override
  String get actorNotSet => 'Не е зададено';

  @override
  String get actorId => 'Идентификатор';

  @override
  String get actorCopyId => 'Копирайте идентификатора';

  @override
  String get actorYourProfile => 'Вашият профил';

  @override
  String actorTasks(String name) {
    return 'Задачи, възложени на $name';
  }

  @override
  String get actorTasksFirst => 'Показани са първите 20.';

  @override
  String get actorTasksNone => 'Нищо не е възложено.';

  @override
  String get actorTokens => 'API токени';

  @override
  String get actorTokensNone => 'Няма API токени.';

  @override
  String get actorKeys => 'SSH ключове';

  @override
  String get actorKeysNone => 'Няма SSH ключове.';

  @override
  String get actorRevoked => 'Отменен';

  @override
  String actorLastUsed(String date) {
    return 'последно използван $date';
  }

  @override
  String get actorNeverUsed => 'неизползван';

  @override
  String get actorRecent => 'Скорошна дейност';

  @override
  String get actorRecentNone => 'Няма записана дейност.';

  @override
  String get actorRecentNeedsAudit =>
      'Скорошната дейност изисква правото audit:read, което нямате.';

  @override
  String get tokensIssue => 'Издай токен';

  @override
  String get tokensIssueButton => 'Издай';

  @override
  String get tokensWholeTenant => 'Всички токени на този тенант';

  @override
  String get tokensOwn => 'Вашите токени';

  @override
  String get tokensWholeNote =>
      'Имате tenant:admin, затова тук са всички токени на тенанта и чии са. Отмяната на чужд токен се записва като такава.';

  @override
  String get tokensIntro =>
      'Токенът е идентификацията, която скрипт, CLI или агент представя вместо вход. Има свои права и стойността му се показва веднъж, при издаване.';

  @override
  String get tokensEmpty => 'Няма токени.';

  @override
  String get tokensActive => 'активен';

  @override
  String get tokensExpired => 'изтекъл';

  @override
  String get tokensRevoked => 'отменен';

  @override
  String get tokensRevoke => 'Отмени';

  @override
  String tokensOwner(String name) {
    return 'Собственик: $name';
  }

  @override
  String tokensOwnerYou(String name) {
    return 'Собственик: $name (вие)';
  }

  @override
  String tokensCreated(String day) {
    return 'Създаден на $day';
  }

  @override
  String tokensExpires(String day) {
    return 'Изтича на $day';
  }

  @override
  String get tokensNeverExpires => 'Не изтича';

  @override
  String get tokensNotUsed => 'Още неизползван';

  @override
  String tokensLastUsed(String when) {
    return 'Последно ползван $when';
  }

  @override
  String tokensRevokeTitle(String name) {
    return 'Да се отмени ли $name?';
  }

  @override
  String get tokensRevokeBody =>
      'Каквото държи този токен спира да се удостоверява веднага. Не може да се отмени и стойността не може да се възстанови.';

  @override
  String tokensRevokeOther(String name) {
    return 'Този токен е на $name, не ваш, и дневникът ще запише, че сте прекратили чужд токен.';
  }

  @override
  String tokensRevokeNamed(String name) {
    return 'Отмени $name';
  }

  @override
  String tokensRevokedToast(String name) {
    return '$name е отменен';
  }

  @override
  String get tokensName => 'Име';

  @override
  String get tokensNameHelp =>
      'По него ще го изберете при отмяна, например ci или laptop. Два активни токена не може да имат едно име.';

  @override
  String get tokensScopes => 'Права';

  @override
  String get tokensNotHeld => 'Нямате това право, затова не може да го дадете.';

  @override
  String get tokensPresetAgent => 'Агент';

  @override
  String get tokensPresetAgentNote =>
      'Чете, създава и редактира задачи, поема ги, мести ги и коментира.';

  @override
  String get tokensPresetRead => 'Само четене';

  @override
  String get tokensPresetReadNote =>
      'Чете задачи, проекти и работни потоци и следи потока от събития.';

  @override
  String get tokensExpiry => 'Изтича';

  @override
  String get tokensExpiryInfo =>
      'Срокът е единственото, което ограничава щетите от токен, изтекъл незабелязано. Изберете най-краткия срок, който стига.';

  @override
  String get tokensNever => 'Никога';

  @override
  String tokensIssuedTitle(String name) {
    return 'Токенът $name е издаден';
  }

  @override
  String get tokensValue => 'Копирайте този токен сега';

  @override
  String get tokensValueWarning =>
      'Пазете го на сигурно място. Няма да се покаже отново и нищо не може да го покаже по-късно.';

  @override
  String get tokensRetiring => 'оттегля се';

  @override
  String tokensStops(String when) {
    return 'Спира $when';
  }

  @override
  String get tokensRotate => 'Смени';

  @override
  String tokensRotateTitle(String name) {
    return 'Смяна на $name?';
  }

  @override
  String get tokensRotateBody =>
      'Нов токен със същото име, обхвати и срок замества този, а стойността му се показва веднъж.';

  @override
  String tokensRotateOther(String name) {
    return 'Този токен е на $name, не ваш, и в историята ще остане, че сте сменили чужд.';
  }

  @override
  String get tokensRotateConnection =>
      'С този токен се свързва приложението, затова то запазва новия на негово място.';

  @override
  String get tokensRotateInfo =>
      'Сменяйте токена по график или веднага, ако може да е изтекъл. Всичко, което го държи, трябва да получи новата стойност; гратисният период оставя стария да работи междувременно, а отмяната му прекратява периода по-рано.';

  @override
  String get tokensRotateGrace => 'Старият токен';

  @override
  String get tokensRotateGraceInfo =>
      'Колко дълго старата стойност продължава да се удостоверява до новата, най-много един ден, за да може работещ агент да вземе новата стойност, без да провали заявка. След изтичане го спрете веднага.';

  @override
  String get tokensGraceNow => 'Спри стария токен веднага';

  @override
  String get tokensGrace10m => 'Остави го да работи още 10 минути';

  @override
  String get tokensGrace1h => 'Остави го да работи още 1 час';

  @override
  String get tokensGrace24h => 'Остави го да работи още 24 часа';

  @override
  String tokensRotateNamed(String name) {
    return 'Смени $name';
  }

  @override
  String tokensRotateNamedOther(String name, String owner) {
    return 'Смени $name ($owner)';
  }

  @override
  String tokensRotatedTitle(String name) {
    return 'Токенът $name е сменен';
  }

  @override
  String tokensRotatedConnection(String name) {
    return '$name е сменен. Приложението вече се свързва с новия токен.';
  }

  @override
  String get tokensRotatedUnsaved =>
      'Защитеното хранилище на устройството отказа новия токен. Показва се само този път. Приложението го ползва, докато не се затвори; след това се свържете отново с него.';

  @override
  String get scopeAll =>
      'Всичко без глобален администратор и история на акаунта. Само за токен, на който вярвате като на себе си.';

  @override
  String get scopeGroupTasks => 'Задачи';

  @override
  String get scopeGroupProjects => 'Проекти';

  @override
  String get scopeGroupWorkflows => 'Работни потоци';

  @override
  String get scopeGroupComments => 'Коментари и артефакти';

  @override
  String get scopeGroupEvents => 'Събития';

  @override
  String get scopeGroupAdmin => 'Администрация';

  @override
  String get scopeGroupAccount => 'Вашият акаунт';

  @override
  String get scopeTaskRead => 'Чете задачи, коментарите и историята им.';

  @override
  String get scopeTaskWrite => 'Създава и редактира задачи.';

  @override
  String get scopeTaskTransition => 'Мести задача от едно състояние в друго.';

  @override
  String get scopeTaskClaim => 'Поема задачи, подновява и освобождава наема.';

  @override
  String get scopeTaskDelete => 'Изтрива задачи и ги връща от кошчето.';

  @override
  String get scopeTaskReclaim => 'Прекратява наем, държан от друг изпълнител.';

  @override
  String get scopeTaskApprove =>
      'Одобрява или отхвърля работа по преход в работния процес, който го изисква.';

  @override
  String get scopeProjectRead => 'Чете проекти.';

  @override
  String get scopeProjectWrite => 'Създава и променя проекти.';

  @override
  String get scopeWorkflowRead => 'Чете работни потоци.';

  @override
  String get scopeWorkflowWrite => 'Създава и променя работни потоци.';

  @override
  String get scopeCommentWrite => 'Коментира задачи.';

  @override
  String get scopeArtifactWrite => 'Прикача артефакти към задачи.';

  @override
  String get scopeEventSubscribe => 'Следи потока от събития на живо.';

  @override
  String get scopeUserAdmin => 'Създава, променя и премахва потребители.';

  @override
  String get scopeTotpAdmin => 'Изчиства втория фактор на друг човек.';

  @override
  String get scopeTokenAdmin => 'Издава и отменя API токени.';

  @override
  String get scopeWebhookAdmin => 'Управлява изходящи уебкуки.';

  @override
  String get scopeTenantAdmin => 'Управлява тенанта, членовете и домейните му.';

  @override
  String get scopeSyncAdmin => 'Управлява и пуска внасяне от други системи.';

  @override
  String get scopeAuditRead => 'Чете одитния дневник.';

  @override
  String get scopeExport => 'Експортира задачи и снимка на целия тенант.';

  @override
  String get scopeImport => 'Внася задачи и снимки в тенанта.';

  @override
  String get scopeGlobalAdmin =>
      'Администрира всички тенанти на сървъра. Само токен на глобален администратор може да го има.';

  @override
  String get scopeAccountRead =>
      'Чете историята на вашия акаунт, която назовава всеки тенант, към който принадлежите. Само токен за вашия акаунт може да го има.';

  @override
  String get accountTitle => 'Вашият акаунт';

  @override
  String get accountKind => 'Вписан като';

  @override
  String get accountKindToken => 'API токен';

  @override
  String get accountKindAgent => 'Агент';

  @override
  String get accountKindPerson => 'Човек';

  @override
  String get accountGlobalAdmin => 'глобален администратор';

  @override
  String get accountGlobalAdminYes => 'Администрира всички тенанти на сървъра';

  @override
  String get accountMemberships => 'Вашите тенанти';

  @override
  String get accountMembershipsHelp =>
      'Всеки тенант, към който принадлежи акаунтът, с ролята му там.';

  @override
  String get accountCurrent => 'текущ';

  @override
  String get accountHistory => 'История на акаунта';

  @override
  String get accountHistoryHelp =>
      'Всяка промяна на паролата, втория фактор и членствата ви във всеки тенант. Само вие и глобалните администратори я виждате.';

  @override
  String get accountHistoryEmpty => 'Още нищо не е променено.';

  @override
  String get accountHistoryNotReadable =>
      'Този токен не може да чете историята на акаунта ви: нужно е правото account:read, което има само токен, издаден за вашия акаунт.';

  @override
  String accountBy(String email) {
    return 'от $email';
  }

  @override
  String get accountBySystem => 'от системата';

  @override
  String get calendarTitle => 'Календарен канал';

  @override
  String get calendarLead =>
      'Сроковете ви в календара на Google, Apple или Outlook';

  @override
  String get calendarUnavailable => 'Тук няма какво да се управлява';

  @override
  String get calendarUnavailableBody =>
      'Календарният канал чете задачи от ваше име, а тази идентификация не може да чете задачи.';

  @override
  String get calendarCreate => 'Създай канал';

  @override
  String get calendarNone => 'Няма календарен канал';

  @override
  String get calendarNoneBody =>
      'Личен адрес, за който календарът ви се абонира, за да виждате сроковете си до останалата седмица.';

  @override
  String get calendarFeed => 'Адрес на канала';

  @override
  String get calendarFeedInfo =>
      'Всяка задача със срок е събитие за цял ден с връзка обратно. Всеки с адреса може да чете какво изброява, затова го пазете като парола. Пази се само хеш, затова не може да се покаже отново.';

  @override
  String get calendarActive => 'Активен';

  @override
  String calendarCreatedOn(String day) {
    return 'Създаден на $day. Адресът беше показан веднъж; завъртете го за нов.';
  }

  @override
  String get calendarShownOnce =>
      'Адресът беше показан веднъж; завъртете го за нов.';

  @override
  String get calendarFilter => 'Филтър на канала';

  @override
  String get calendarFilterDefault =>
      'Задачите, възложени на вас, които не са приключени';

  @override
  String get calendarFilterHint => 'project:infra tag:ops';

  @override
  String get calendarFilterHelp =>
      'Езикът за филтриране на задачи. Празно означава вашите, неприключени. Изброяват се само задачи със срок.';

  @override
  String get calendarEditFilter => 'Промени филтъра';

  @override
  String get calendarSaveFilter => 'Запази филтъра';

  @override
  String get calendarFilterSaved => 'Филтърът е запазен';

  @override
  String get calendarRotate => 'Завърти адреса';

  @override
  String get calendarRotateHelp =>
      'Нов адрес със същия филтър; старият спира веднага.';

  @override
  String get calendarRotateButton => 'Завърти';

  @override
  String get calendarRevoke => 'Отмени канала';

  @override
  String get calendarRevokeHelp =>
      'Адресът спира да отговаря. Абонираните календари пазят последно изтегленото.';

  @override
  String get calendarRevokeButton => 'Отмени';

  @override
  String get calendarRevokeTitle => 'Да се отмени ли календарният канал?';

  @override
  String get calendarRevokeBody =>
      'Адресът спира веднага. Премахнете абонамента и от календара си.';

  @override
  String get calendarRevoked => 'Календарният канал е отменен';

  @override
  String get calendarAddress => 'Абонирайте се за този адрес';

  @override
  String get calendarOnce =>
      'Добавете го в календара си. Няма да се покаже отново, затова го копирайте сега.';

  @override
  String get calendarRotatedOnce =>
      'Този адрес заменя стария, който спря. Абонирайте се отново навсякъде, където е ползван старият. Няма да се покаже отново.';

  @override
  String calendarLists(String filter) {
    return 'Изброява: $filter';
  }

  @override
  String get calendarListsDefault =>
      'Изброява задачите, възложени на вас, които не са приключени.';

  @override
  String get calendarHowGoogle =>
      'Google Calendar: Други календари, после От URL адрес, и поставете адреса.';

  @override
  String get calendarHowApple =>
      'Apple Calendar: Файл, после Нов абонамент за календар, или Абонирай на това устройство.';

  @override
  String get calendarHowOutlook =>
      'Outlook: Добавяне на календар, после Абониране от уеб, и поставете адреса.';

  @override
  String get calendarSubscribeHere => 'Абонирай на това устройство';

  @override
  String get transferTitle => 'Експорт и внасяне';

  @override
  String get transferNoProjects =>
      'Създайте проект, преди да експортирате или внасяте задачи.';

  @override
  String get transferExportTitle => 'Експорт на задачи';

  @override
  String get transferExportHelp =>
      'Задачите на един проект или избраните от филтър, като файл.';

  @override
  String get transferQuery => 'Филтър';

  @override
  String get transferQueryHelp =>
      'Езикът за филтриране на задачи. Празно експортира всички.';

  @override
  String get transferFormat => 'Формат';

  @override
  String get transferFormatCsv => 'CSV, за таблици';

  @override
  String get transferFormatNdjson => 'NDJSON, по задача на ред';

  @override
  String get transferFormatMarkdown => 'Таблица в Markdown';

  @override
  String get transferColumns => 'Колони';

  @override
  String get transferDates => 'Дати';

  @override
  String get transferDatesIso => 'Дата и час (ISO)';

  @override
  String get transferDatesDay => 'Само ден';

  @override
  String get transferDelimiter => 'Разделител';

  @override
  String get transferDelimiterComma => 'Запетая';

  @override
  String get transferDelimiterSemicolon => 'Точка и запетая';

  @override
  String get transferDelimiterTab => 'Табулация';

  @override
  String get transferDelimiterBar => 'Вертикална черта';

  @override
  String get transferFinished => 'Включи приключените задачи';

  @override
  String get transferSubtasks => 'Включи подзадачите';

  @override
  String get transferTrashed => 'Включи задачите в кошчето';

  @override
  String get transferExportButton => 'Експортирай';

  @override
  String transferExported(String name) {
    return 'Запазен е $name';
  }

  @override
  String get transferSnapshotTitle => 'Снимка';

  @override
  String get transferSnapshotHelp =>
      'Всичко в този тенант като един NDJSON файл, който tix може да внесе другаде.';

  @override
  String get transferSnapshotComments => 'Включи коментарите';

  @override
  String get transferSnapshotButton => 'Експортирай снимка';

  @override
  String get transferImportTitle => 'Внасяне на задачи';

  @override
  String get transferImportHelp =>
      'Файл със задачи в CSV, JSON или NDJSON, включително от Jira, GitHub, Trello и Linear. Виждате какво ще стане, преди да се промени нещо.';

  @override
  String get transferPick => 'Избери файл';

  @override
  String transferDryRun(
    int rows,
    int created,
    int updated,
    int skipped,
    int failed,
  ) {
    return '$rows реда: $created за създаване, $updated за обновяване, $skipped пропуснати, $failed неуспешни.';
  }

  @override
  String transferImportError(int line, String message) {
    return 'Ред $line: $message';
  }

  @override
  String transferImportButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Внеси $count задачи',
      one: 'Внеси 1 задача',
    );
    return '$_temp0';
  }

  @override
  String transferImported(int created, int updated) {
    return 'Внесено: $created създадени, $updated обновени';
  }

  @override
  String get columnRef => 'Номер';

  @override
  String get columnTitle => 'Заглавие';

  @override
  String get columnParent => 'Родител';

  @override
  String get columnDependsOn => 'Зависи от';

  @override
  String get columnRepeat => 'Повторение';

  @override
  String get columnCreated => 'Създадена';

  @override
  String get columnUpdated => 'Обновена';

  @override
  String get columnStarted => 'Започната';

  @override
  String get columnCompleted => 'Завършена';

  @override
  String get columnDeleted => 'Изтрита';

  @override
  String get columnCreator => 'Създател';

  @override
  String get columnProject => 'Проект';

  @override
  String get columnId => 'Идентификатор';

  @override
  String get columnComments => 'Коментари';

  @override
  String get columnHistory => 'История';

  @override
  String get settingsAccountHelp => 'Профил, тенанти и история';

  @override
  String get settingsCalendarHelp => 'Сроковете ви в календара';

  @override
  String get settingsTokensHelp => 'Токени за скриптове, CLI и агенти';

  @override
  String get connectAgentTitle => 'Свързване на агент';

  @override
  String get connectAgentSubtitle =>
      'Команди за CLI, MCP клиенти, SSH, API и умението за агенти';

  @override
  String get goConnectAgent => 'Свързване на агент';

  @override
  String get connectAgentIntro =>
      'Вземете идентификация, изберете как да се свържете и копирайте командите.';

  @override
  String get connectAgentInfo =>
      'Вземете идентификация, изберете как да се свържете и копирайте командите. Всяка команда е попълнена за този сървър и за вас.';

  @override
  String get connectAgentServer => 'Сървър';

  @override
  String get connectAgentTenant => 'Тенант';

  @override
  String get connectAgentSignedInAs => 'Влезли сте като';

  @override
  String get connectAgentStepCredential => '1. Вземете идентификация';

  @override
  String get connectAgentStepPick => '2. Изберете как да се свържете';

  @override
  String connectAgentStepCopy(String way) {
    return '3. Копирайте командите: $way';
  }

  @override
  String get connectAgentCli => 'CLI';

  @override
  String get connectAgentMcp => 'MCP';

  @override
  String get connectAgentSsh => 'SSH';

  @override
  String get connectAgentApi => 'API';

  @override
  String get connectAgentSkill => 'Умение';

  @override
  String get connectAgentTokenNeeded =>
      'Командите за CLI, MCP и API използват \$TIX_TOKEN. Издайте токен тук и екранът ще го попълни, или задайте TIX_TOKEN в обвивката си на токен, който вече имате.';

  @override
  String get connectAgentNoTokenAdmin =>
      'Издаването на токен изисква обхвата token:admin, който нямате. Поискайте токен от администратор.';

  @override
  String get connectAgentTokenFilled =>
      'Всяка команда на този екран вече съдържа този токен. Той не се пази никъде: напускането на екрана връща \$TIX_TOKEN.';

  @override
  String get connectAgentExportNote =>
      'Задава TIX_TOKEN в тази обвивка, за командите, които го четат.';

  @override
  String get connectAgentFromCli => 'От командния ред';

  @override
  String get connectAgentSeeTokens => 'Вижте и отменете токените си';

  @override
  String get connectAgentRotate => 'Сменете го по-късно';

  @override
  String get connectAgentRotateNote =>
      'Издава нова стойност със същото име и обхвати и оставя старата да работи десет минути, за да не бъде прекъснат работещ агент.';

  @override
  String get connectAgentSshNoToken =>
      'Разделът SSH не изисква токен: регистрираният ви SSH ключ е идентификацията.';

  @override
  String get connectAgentOpenSsh => 'Отворете раздела SSH';

  @override
  String get connectAgentInstall => 'Инсталирайте CLI';

  @override
  String get connectAgentInstallNote =>
      'Инсталирайте версията, с която работи този сървър, за да са съгласувани CLI и сървърът.';

  @override
  String get connectAgentInstallUnix => 'Linux и macOS';

  @override
  String get connectAgentInstallUnixNote =>
      'Изтегля версията за тази ОС и процесор, проверява контролната ѝ сума и поставя tix в PATH.';

  @override
  String get connectAgentInstallWindows => 'Windows';

  @override
  String get connectAgentInstallWindowsNote =>
      'Същата инсталация в PowerShell.';

  @override
  String get connectAgentInstallGo => 'Go';

  @override
  String get connectAgentInstallGoNote =>
      'Компилира tix с вашите инструменти на Go.';

  @override
  String get connectAgentInstallContainer => 'Контейнер';

  @override
  String get connectAgentInstallContainerNote =>
      'Изпълнява една команда от публикувания образ, без нищо инсталирано. Docker приема същите аргументи.';

  @override
  String get connectAgentSaveContext => 'Запазете контекст';

  @override
  String get connectAgentSaveContextNote =>
      'Запазва сървъра, токена и тенанта под едно име и го прави подразбиращ се, така че следващите команди не се нуждаят от флагове.';

  @override
  String get connectAgentVerify => 'Проверете връзката';

  @override
  String get connectAgentVerifyNote =>
      'Извежда пет задачи от този сървър. Грешката посочва какво не е наред: адресът, токенът или обхват.';

  @override
  String get connectAgentMcpNote =>
      'tix mcp предоставя API-то като инструменти през стандартния вход и изход, затова първо трябва да инсталирате CLI. Инструмент, който изтрива или не може да бъде отменен, се пропуска, освен ако не добавите --allow-destructive след mcp.';

  @override
  String get connectAgentCommandLine => 'Команден ред';

  @override
  String get connectAgentMcpProjectRoot => 'В корена на проект.';

  @override
  String get connectAgentMcpCodex => 'Общ за Codex CLI и разширението за IDE.';

  @override
  String get connectAgentMcpOpenCode =>
      'Командата и аргументите ѝ са един масив, а променливите са под environment.';

  @override
  String get connectAgentMcpGemini =>
      'В проект или ~/.gemini/settings.json за всеки проект. Gemini CLI го стартира само в доверена папка.';

  @override
  String get connectAgentMcpClaudeDesktop =>
      'Затворете и отворете отново приложението след редакцията.';

  @override
  String get connectAgentMcpCursor =>
      'В проект или ~/.cursor/mcp.json за всеки проект.';

  @override
  String get connectAgentMcpVscode =>
      'В работно пространство, за агентския режим на GitHub Copilot.';

  @override
  String get connectAgentMcpVscodeCli =>
      'Добавя същия сървър към потребителския ви профил.';

  @override
  String get connectAgentMcpZed =>
      'Файлът с настройки на Zed, отворен със zed: open settings file.';

  @override
  String get connectAgentSeeTools => 'Вижте инструментите';

  @override
  String get connectAgentSeeToolsNote =>
      'Извежда всеки инструмент, обхвата, който му трябва, и дали се предлага. Не изисква сървър.';

  @override
  String get connectAgentSshNote =>
      'Вашият SSH ключ е идентификацията и не е нужно нищо да се инсталира. Тенантът стои там, където обикновено е потребителското име.';

  @override
  String get connectAgentSshAddress =>
      'Приложението не може да разбере дали този сървър слуша за SSH и на какъв адрес. Тези команди използват хоста на сървъра и порт 22; администраторът задава истинския адрес с ssh.public_address.';

  @override
  String get connectAgentSshKey => 'Регистрирайте ключа си';

  @override
  String get connectAgentSshKeyNote =>
      'Веднъж, от настроен CLI. Добавете --all-tenants, за да го регистрирате във всеки тенант, в който сте. Екранът Сигурност прави същото в приложението.';

  @override
  String get connectAgentSshTui => 'Отворете терминалния интерфейс';

  @override
  String get connectAgentSshCmd => 'Изпълнете команда на tix';

  @override
  String get connectAgentSshCmdNote =>
      'Изпълнява се на сървъра от ваше име, без нищо инсталирано или настроено тук. Сървърът не чете ваши файлове: пренасочете с < и >.';

  @override
  String get connectAgentSshExport => 'Експорт през SSH';

  @override
  String get connectAgentSshExportNote =>
      'Изпраща моментната снимка на тенанта към вашата машина. Изисква обхвата export.';

  @override
  String get connectAgentSshWatch => 'Поток от събития';

  @override
  String get connectAgentSshWatchNote =>
      'По едно JSON събитие на ред, за скрипт. Добавете -t след ssh за цветния изглед, който чете човек.';

  @override
  String get connectAgentRestWhoami => 'Чий е токенът';

  @override
  String get connectAgentRestTasks => 'Списък със задачи';

  @override
  String connectAgentOpenApi(String url) {
    return 'Всяка операция е описана в документа OpenAPI на $url, който не изисква токен.';
  }

  @override
  String get connectAgentSkillNote =>
      'Умението учи агента на цикъла заемане, наем и освобождаване, на кодовете за изход и на JSON изхода.';

  @override
  String get connectAgentSkillProject => 'Claude Code, този проект';

  @override
  String get connectAgentSkillProjectNote =>
      'Изпълнете го в корена на хранилището. Добавете папката в хранилището, за да я получи всеки, който работи там.';

  @override
  String get connectAgentSkillUser => 'Claude Code, всеки проект';

  @override
  String get connectAgentSkillUserNote =>
      'Инсталира го само за вас, във всеки проект.';

  @override
  String get connectAgentSkillOther => 'Други агенти';

  @override
  String get connectAgentSkillOtherNote =>
      'Codex, OpenCode, Gemini CLI и повечето други агенти четат AGENTS.md. Всеки агент, който може да изтегли URL адрес, може да следва умението.';

  @override
  String get securityTitle => 'Сигурност';

  @override
  String get securitySubtitle => 'Вторият ви фактор и SSH ключовете ви';

  @override
  String get totpTitle => 'Втори фактор';

  @override
  String get totpInfo =>
      'Код от приложение за удостоверяване, който се иска след паролата. Кодовете за възстановяване ви пускат, когато приложението не е под ръка.';

  @override
  String get totpOn => 'Включен';

  @override
  String get totpOff => 'Изключен';

  @override
  String get totpPending => 'Непотвърден';

  @override
  String totpSince(String date) {
    return 'От $date';
  }

  @override
  String get totpOnBody =>
      'При вход след паролата се иска код от приложението за удостоверяване.';

  @override
  String get totpOffBody => 'При вход се иска само паролата.';

  @override
  String get totpPendingBody =>
      'Настройката е започната, но не е потвърдена с код. Настройте отново, за да я завършите.';

  @override
  String totpRequiredOn(String surfaces) {
    return 'Наемателят ви изисква втори фактор за: $surfaces.';
  }

  @override
  String get totpSurfaceWeb => 'браузъра';

  @override
  String get totpSurfaceCli => 'командния ред';

  @override
  String get totpSurfaceSsh => 'SSH';

  @override
  String totpCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Остават $count кода за възстановяване',
      one: 'Остава 1 код за възстановяване',
      zero: 'Не остават кодове за възстановяване',
    );
    return '$_temp0';
  }

  @override
  String totpLocked(String time) {
    return 'Твърде много грешни кодове. Кодовете се отказват до $time.';
  }

  @override
  String get totpSetUp => 'Настрой';

  @override
  String get totpNewCodes => 'Нови кодове за възстановяване';

  @override
  String get totpNewCodesBody =>
      'Сегашните кодове за възстановяване спират да работят веднага, използвани или не, и нов набор се показва еднократно.';

  @override
  String get totpNewCodesConfirm => 'Замени кодовете';

  @override
  String get totpRemove => 'Премахни втория фактор';

  @override
  String get totpRemoveBody =>
      'При вход ще се иска само паролата, а кодовете за възстановяване спират да работят. Ако наемателят изисква втори фактор, ще трябва да го настроите отново.';

  @override
  String get totpRemoved => 'Вторият фактор е премахнат.';

  @override
  String get totpCodesHeading => 'Запазете тези кодове за възстановяване сега';

  @override
  String get totpCodesNote =>
      'Всеки от тях ви пуска веднъж без приложението за удостоверяване. Показват се еднократно и не могат да се видят отново; ако ги загубите, създайте нов набор.';

  @override
  String get totpCodesSaved => 'Запазих ги';

  @override
  String get totpConfirm => 'Потвърди';

  @override
  String get totpStep1 =>
      '1. Добавете този ключ в приложението за удостоверяване или го отворете там от това устройство.';

  @override
  String get totpSecretHeading => 'Ключ за приложението за удостоверяване';

  @override
  String totpSecretNote(String account, String issuer) {
    return 'Акаунт $account в $issuer. Пазете го в тайна: който го има, може да генерира кодовете ви.';
  }

  @override
  String get totpOpenApp => 'Отвори в приложението';

  @override
  String get totpStep2 =>
      '2. Въведете шестцифрения код, който показва приложението.';

  @override
  String get sshKeysTitle => 'SSH ключове';

  @override
  String get sshKeysInfo =>
      'Ключ, добавен тук, ви вписва в терминалния интерфейс на tix през SSH в този наемател. Отменените ключове остават в списъка, за да се вижда защо някой е спрял да работи.';

  @override
  String get sshKeysEmpty => 'Все още няма SSH ключове.';

  @override
  String get sshKeyAdd => 'Добави SSH ключ';

  @override
  String get sshKeyAddSubmit => 'Добави ключа';

  @override
  String get sshKeyAdded => 'SSH ключът е добавен.';

  @override
  String get sshKeyUnlabelled => 'Ключ без етикет';

  @override
  String get sshKeyRevoked => 'Отменен';

  @override
  String sshKeyAddedOn(String date) {
    return 'Добавен $date';
  }

  @override
  String sshKeyLastUsed(String date) {
    return 'Последно ползван $date';
  }

  @override
  String get sshKeyNeverUsed => 'Неизползван';

  @override
  String sshKeyRevokedOn(String date) {
    return 'Отменен $date';
  }

  @override
  String get sshKeyRevoke => 'Отмени';

  @override
  String sshKeyRevokeBody(String name) {
    return '$name спира да вписва през SSH веднага. Това не може да се върне; добавете ключа отново, за да го ползвате.';
  }

  @override
  String get sshKeyRevokedToast => 'SSH ключът е отменен.';

  @override
  String get sessionsTitle => 'Активни сесии';

  @override
  String get sessionsInfo =>
      'Вашите влизания от браузър и терминал в този тенант, които не са изтекли. Отменете всяко, което не разпознавате. API токените се управляват в Токени.';

  @override
  String get sessionsEmpty => 'Няма активни сесии.';

  @override
  String get sessionsNotReadable =>
      'Този токен не може да покаже сесиите ви: нужен му е обхватът account:read, който „*“ не включва. Влезте с паролата си или използвайте токен, създаден с account:read.';

  @override
  String get sessionsShowMore => 'Покажи още';

  @override
  String get sessionCurrent => 'Тази сесия';

  @override
  String get sessionUnknownAgent => 'Неизвестно устройство';

  @override
  String get sessionMethodPassword => 'Парола';

  @override
  String get sessionMethodSshKey => 'SSH ключ';

  @override
  String get sessionMethodSwitch => 'Смяна на тенант';

  @override
  String get sessionSecondFactor => 'с втори фактор';

  @override
  String sessionSignedIn(String when) {
    return 'Влизане $when';
  }

  @override
  String sessionExpires(String when) {
    return 'Изтича $when';
  }

  @override
  String get sessionRevoke => 'Отмени';

  @override
  String get sessionRevokeTitle => 'Да се отмени ли тази сесия?';

  @override
  String sessionRevokeBody(String agent) {
    return '$agent излиза веднага и трябва да влезе отново.';
  }

  @override
  String get sessionRevokeCurrentBody =>
      'С тази сесия е влязло приложението. Ако я отмените, излизате оттук и ще трябва да влезете отново.';

  @override
  String get sessionRevoked => 'Сесията е отменена.';

  @override
  String get sshKeyPublicKey => 'Публичен ключ';

  @override
  String get sshKeyPublicKeyHelp =>
      'Редът от .pub файла, както го записва ssh-keygen.';

  @override
  String get sshKeyLabel => 'Етикет (по избор)';

  @override
  String get sshKeyLabelHelp =>
      'Отличава този ключ от другите, например по машината, на която е.';

  @override
  String get sshKeyAllTenants => 'Всички наематели, в които членувам';

  @override
  String get sshKeyAllTenantsHelp =>
      'Добавя ключа във всеки ваш наемател, не само в този.';

  @override
  String get tenantSettingsTitle => 'Настройки на наемателя';

  @override
  String get tenantSaved => 'Запазено.';

  @override
  String get tenantGeneralTitle => 'Общи';

  @override
  String get tenantName => 'Име';

  @override
  String get tenantKey => 'Ключ';

  @override
  String get tenantKeyHelp =>
      'Кратък и уникален: букви, цифри, тирета и долни черти, започва с буква. Не може да се промени после.';

  @override
  String get tenantTimezone => 'Часова зона';

  @override
  String get tenantTimezoneHelp =>
      'IANA зона, в която хората четат датите, освен ако не са избрали своя. Празно използва тази на сървъра.';

  @override
  String get tenantTimeFormat => 'Формат на датите';

  @override
  String get tenantServerDefault => 'По подразбиране за сървъра';

  @override
  String get tenantThemeTitle => 'Тема';

  @override
  String get tenantThemeInfo =>
      'Цветът на наемателя навсякъде: в уеб, в терминала и в това приложение. Цветовете на статусите и приоритетите не се променят с него.';

  @override
  String get tenantThemeDefault => 'по подразбиране';

  @override
  String get tenantThemeCustom => 'Собствен цвят';

  @override
  String get tenantThemeCustomHelp =>
      '#rrggbb. tix го нагласява, докато текстът върху и около него остане четим.';

  @override
  String get tenantThemeCustomBad =>
      'Запишете цвета като #rrggbb, например #0f766e.';

  @override
  String get tenantThemePreview => 'Преглед';

  @override
  String get tenantThemeSampleRow => 'Избран ред';

  @override
  String get tenantThemeSampleLink => 'Връзка';

  @override
  String get tenantThemeSampleButton => 'Нова задача';

  @override
  String get tenantThemeSaved => 'Темата е запазена.';

  @override
  String get tenantTotpTitle => 'Втори фактор';

  @override
  String get tenantTotpInfo =>
      'Изисква код от приложение за удостоверяване при вход. Който няма такъв, го настройва при влизане, така че включването не заключва никого.';

  @override
  String get tenantTotpWeb => 'Изисквай го в браузъра';

  @override
  String get tenantTotpCli => 'Изисквай го в командния ред';

  @override
  String get tenantTotpSsh => 'Изисквай го през SSH, освен ключа';

  @override
  String get tenantTotpNone => 'Не се изисква';

  @override
  String get tenantTotpBadge => 'Втори фактор';

  @override
  String get tenantLeaseTitle => 'Заявки';

  @override
  String get tenantLeaseInfo =>
      'Колко трае заявката на агент за задача. Проект, работен процес или заявка може да поиска по-малко; таванът на сървъра винаги печели.';

  @override
  String get tenantLeaseDefault => 'Срок по подразбиране';

  @override
  String get tenantLeaseDefaultHelp =>
      'Продължителност като 30m или 2h. Празно използва тази на сървъра.';

  @override
  String get tenantLeaseMax => 'Най-дълъг срок';

  @override
  String get tenantLeaseMaxHelp =>
      'Ограничава всяка заявка в наемателя. Може да свали тавана на сървъра, но не и да го вдигне.';

  @override
  String get tenantTrashTitle => 'Кошче';

  @override
  String get tenantTrashKeep => 'Пази изтритите задачи в кошче';

  @override
  String get tenantTrashOnBody =>
      'Изтритите задачи могат да се възстановят, докато поддръжката не изпразни кошчето.';

  @override
  String get tenantTrashOffBody =>
      'Изтриването на задача е окончателно. Задачите, които вече са в кошчето, остават там.';

  @override
  String get tenantTrashOnShort => 'Изтритите задачи отиват в кошчето';

  @override
  String get tenantTrashOffShort => 'Изтриването е окончателно';

  @override
  String get tenantDelete => 'Изтрий наемателя';

  @override
  String get tenantDeleteHelp =>
      'Данните му стават недостъпни, а домейните му спират да работят.';

  @override
  String get tenantDeleteCurrent =>
      'Това е наемателят, в който работите. Превключете към друг, за да го изтриете.';

  @override
  String tenantDeleteBody(String name, String key) {
    return '$name ($key) и всичко в него стават недостъпни за всички, а домейните му спират да работят. Само операторът на сървъра може да го върне.';
  }

  @override
  String tenantDeleted(String name) {
    return '$name е изтрит.';
  }

  @override
  String get tenantsTitle => 'Наематели';

  @override
  String get tenantsSubtitle => 'Всички наематели на този сървър';

  @override
  String get tenantsEmpty => 'Няма наематели.';

  @override
  String get tenantsEmptyBody => 'Създайте един с първия му администратор.';

  @override
  String get tenantsPick => 'Изберете наемател, за да го видите тук.';

  @override
  String get tenantCreate => 'Нов наемател';

  @override
  String get tenantCreateSubmit => 'Създай наемателя';

  @override
  String tenantCreated(String name) {
    return '$name е създаден.';
  }

  @override
  String get tenantFirstAdmin => 'Първи администратор';

  @override
  String get tenantFirstAdminHelp =>
      'Става администратор на новия наемател. Адрес, който вече има акаунт, запазва паролата и втория си фактор.';

  @override
  String get tenantPasswordHelp =>
      'Поне 12 знака. Оставете празно и tix ще генерира парола, показана еднократно.';

  @override
  String get tenantCredentialsHeading => 'Копирайте тези пароли сега';

  @override
  String get tenantCredentialsNote =>
      'tix ги генерира и ги показва еднократно; никъде не се пазят. Дайте всяка на администратора ѝ, който избира нова при първия вход. Ако някоя се загуби, задайте нова парола.';

  @override
  String get tenantCurrent => 'Текущ';

  @override
  String get tenantMember => 'Член';

  @override
  String get tenantNoTrash => 'Без кошче';

  @override
  String get tenantOverview => 'Преглед';

  @override
  String get tenantCreatedAt => 'Създаден';

  @override
  String get tenantSwitch => 'Превключи към наемателя';

  @override
  String get tenantJoinSwitch => 'Присъедини се и превключи';

  @override
  String tenantJoinBody(String name) {
    return 'Не сте член на $name. Като глобален администратор можете да се добавите като администратор и да превключите. Промяната остава в дневника на акаунта ви.';
  }

  @override
  String get tenantJoinConfirm => 'Присъедини се като администратор';

  @override
  String get tenantSwitchPinned =>
      'Тази връзка достига само един наемател. Влезте с връзка, която може да превключва, за да минавате между наематели.';

  @override
  String get tenantUsersTitle => 'Потребители';

  @override
  String get tenantDomainsEmpty => 'Няма домейни за този наемател.';

  @override
  String get domainsTitle => 'Домейни';

  @override
  String get domainsSubtitle => 'Имена на хостове, които отварят наемателя';

  @override
  String get domainsBody =>
      'Заявка, пристигнала на едно от тези имена, стига до наемателя, без да го посочва.';

  @override
  String get domainsEmpty => 'Все още няма домейни.';

  @override
  String get domainsEmptyBody =>
      'Свържете име на хост, за да стигат хората до наемателя на собствен адрес.';

  @override
  String get domainAdd => 'Добави домейн';

  @override
  String get domainAddSubmit => 'Добави домейна';

  @override
  String get domainAdded => 'Домейнът е добавен.';

  @override
  String get domainHostname => 'Име на хост';

  @override
  String get domainHostnameHelp =>
      'С малки букви; порт или крайна точка се премахват.';

  @override
  String get domainCertMode => 'Сертификат';

  @override
  String get domainCertNone => 'Терминира се другаде';

  @override
  String get domainCertFile => 'Файл със сертификат';

  @override
  String get domainCertNoneHelp =>
      'Прокси пред tix държи сертификата или хостът е обикновен HTTP.';

  @override
  String get domainCertFileHelp =>
      'tix сам обслужва TLS от PEM файлове на сървъра.';

  @override
  String get domainCertPath => 'Път до сертификата на сървъра';

  @override
  String get domainKeyPath => 'Път до частния ключ на сървъра';

  @override
  String get domainVerified => 'Проверен';

  @override
  String get domainShared => 'Споделен';

  @override
  String get domainSharedInfo =>
      'Споделеното име обслужва и наемателя, посочен от идентификацията или заглавката X-Tix-Tenant, както хост без домейн. Само глобален администратор го задава.';

  @override
  String get domainRemove => 'Премахни домейна';

  @override
  String domainRemoveBody(String hostname) {
    return 'Заявките към $hostname спират да стигат до наемателя. Който ползва този адрес, трябва да ползва друг.';
  }

  @override
  String get domainRemoved => 'Домейнът е премахнат.';

  @override
  String get serverTitle => 'Сървър';

  @override
  String serverVersion(String version) {
    return 'tix $version';
  }

  @override
  String get serverStatusTitle => 'Състояние';

  @override
  String get serverVersionLabel => 'Версия';

  @override
  String get serverHealth => 'Здраве';

  @override
  String get serverAddress => 'Адрес';

  @override
  String get serverId => 'Процес на сървъра';

  @override
  String get serverCountTenant => 'Живи връзки в наемателя';

  @override
  String get serverCountEvents => 'Потоци с живи обновления';

  @override
  String get serverCountSsh => 'SSH сесии';

  @override
  String get serverCountProcess => 'Връзки на този сървър';

  @override
  String get serverCountProcessInfo =>
      'Всички връзки на този процес, във всички наематели. Това е капацитет, не указател, затова не назовава никого.';

  @override
  String get connectionsTitle => 'Живи връзки';

  @override
  String get connectionsInfo =>
      'Потоците с живи обновления и SSH сесиите на наемателя, които държи този процес. Прекратяването я затваря; клиентът може да се свърже отново.';

  @override
  String get connectionsEmpty => 'Няма живи връзки.';

  @override
  String get connectionEvents => 'Живи обновления';

  @override
  String get connectionSsh => 'SSH';

  @override
  String connectionSince(String date) {
    return 'от $date';
  }

  @override
  String get connectionEnd => 'Прекрати';

  @override
  String get connectionEndBody =>
      'Връзката се затваря веднага. Работещ клиент може да се свърже отново; отменете токена или ключа му, за да го спрете.';

  @override
  String get connectionEnded => 'Връзката е прекратена.';

  @override
  String get globalAdminsTitle => 'Глобални администратори';

  @override
  String get globalAdminsSubtitle =>
      'Хора, които администрират всички наематели на сървъра';

  @override
  String get globalAdminsEmpty => 'Няма глобални администратори.';

  @override
  String get globalAdminGrant => 'Дай глобален администратор';

  @override
  String get globalAdminGrantSubmit => 'Дай';

  @override
  String get globalAdminGrantHelp =>
      'Акаунтът с този имейл ще може да създава наематели и да администрира всеки от тях.';

  @override
  String get globalAdminGranted => 'Глобалният администратор е даден.';

  @override
  String get globalAdminRevoke => 'Отнеми';

  @override
  String globalAdminRevokeBody(String email) {
    return '$email спира да администрира всички наематели веднага. Членствата му остават.';
  }

  @override
  String get globalAdminRevoked => 'Глобалният администратор е отнет.';

  @override
  String get globalAdminBadge => 'Глобален администратор';

  @override
  String get adminRoleAdmin => 'Администратор';

  @override
  String get adminRoleMember => 'Член';

  @override
  String get adminRoleViewer => 'Наблюдател';

  @override
  String get adminRoleNone => 'Без роля';

  @override
  String get adminUsersEmpty => 'Няма потребители в този наемател.';

  @override
  String get adminUsersEmptyBody =>
      'Създайте потребител или добавете съществуващ акаунт.';

  @override
  String get adminUserCreate => 'Нов потребител';

  @override
  String get adminUserCreateSubmit => 'Създай потребителя';

  @override
  String get adminUserActions => 'Действия с потребителя';

  @override
  String get adminUserEdit => 'Редактирай';

  @override
  String adminUserEditTitle(String email) {
    return 'Редакция на $email';
  }

  @override
  String get adminUserDelete => 'Изтрий потребителя';

  @override
  String adminUserDeleteBody(String email) {
    return '$email губи този наемател: членството се отнема, а сесиите и токените тук спират. Акаунтът остава за другите наематели.';
  }

  @override
  String get adminUserClearTotp => 'Изчисти втория фактор';

  @override
  String get adminUserClearTotpConfirm => 'Изчисти го';

  @override
  String adminUserClearTotpBody(String email) {
    return '$email влиза само с паролата, докато не настрои отново втори фактор. Правете го само ако е загубил приложението и кодовете за възстановяване.';
  }

  @override
  String get adminUserEmail => 'Имейл';

  @override
  String get adminUserHandle => 'Псевдоним';

  @override
  String get adminUserHandleHelp =>
      'Краткото име в наемателя. Празно използва частта от имейла преди @.';

  @override
  String get adminUserDisplayName => 'Показвано име';

  @override
  String get adminUserPassword => 'Парола';

  @override
  String get adminUserPasswordHelp =>
      'Поне 12 знака. Оставете празно за потребител, който влиза по друг начин или ще бъде поканен.';

  @override
  String get adminUserNewPassword => 'Нова парола';

  @override
  String get adminUserNewPasswordHelp =>
      'Оставете празно, за да остане сегашната.';

  @override
  String get adminUserRole => 'Роля';

  @override
  String get adminUserDisabled => 'Деактивиран';

  @override
  String get adminUserDisabledSwitch => 'Деактивиран';

  @override
  String get adminUserDisabledHelp =>
      'Деактивираният потребител не може да влиза; сесиите и токените му спират веднага.';

  @override
  String get adminUserMustChangePassword => 'Трябва да смени паролата';

  @override
  String get adminUserMustChangeSwitch => 'Нова парола при следващия вход';

  @override
  String get adminUserTotp => 'Втори фактор';

  @override
  String get adminMemberAdd => 'Добави съществуващ акаунт';

  @override
  String get adminMemberAddSubmit => 'Добави в наемателя';

  @override
  String get adminMemberAddHelp =>
      'Човекът запазва паролата и втория си фактор и не се иска потвърждение от него.';

  @override
  String get adminAccountLogTitle => 'Дневник на акаунта';

  @override
  String get adminAccountLogEmpty => 'Няма записи за този акаунт.';

  @override
  String get adminAccountLogEmptyBody =>
      'Промените по паролата, втория фактор, статуса и членствата се показват тук.';

  @override
  String adminAccountLogBy(String who) {
    return 'от $who';
  }

  @override
  String adminAccountLogVia(String channel) {
    return 'чрез $channel';
  }

  @override
  String get adminAccountLogSystem => 'системата';

  @override
  String get taskReclaim => 'Отнеми резервацията';

  @override
  String get taskReclaimSubmit => 'Отнеми';

  @override
  String get taskReclaimBody =>
      'Прекратява заявката на друг участник върху задачата, когато работникът му е спрял. Следващото му подновяване ще бъде отказано.';

  @override
  String get taskReclaimReason => 'Причина (по избор)';

  @override
  String get taskReclaimReasonHelp => 'Пази се в историята на задачата.';

  @override
  String taskReclaimed(String ref) {
    return 'Резервацията за $ref е отнета.';
  }

  @override
  String get totpWrongCode =>
      'Кодът не е верен. Проверете часа на устройството и опитайте със следващия.';

  @override
  String get tenantThemeSampleStatus => 'В работа';

  @override
  String get tenantSettingsSubtitle =>
      'Име, тема, втори фактор, заявки и кошче';

  @override
  String get serverSubtitle => 'Версия и живи връзки';

  @override
  String get webhooksTitle => 'Уебкукички';

  @override
  String get webhooksSubtitle =>
      'tix изпраща всяко събитие на тези адреси, подписано с тайната на крайната точка.';

  @override
  String get webhookNew => 'Нова крайна точка';

  @override
  String get webhookEdit => 'Редактиране на крайната точка';

  @override
  String get webhookEndpoints => 'Крайни точки';

  @override
  String get webhookEndpointsInfo =>
      'Крайната точка получава всяко събитие или само изброените типове. Неактивната не получава нищо, докато не бъде включена отново.';

  @override
  String get webhooksEmpty => 'Още няма крайни точки.';

  @override
  String get webhooksEmptyBody =>
      'Добавете https адрес и tix ще изпраща събитията към него, щом се случат.';

  @override
  String get webhookEveryEvent => 'Всяко събитие';

  @override
  String get webhookActive => 'Активна';

  @override
  String get webhookInactive => 'Неактивна';

  @override
  String get webhookActiveHelp => 'Неактивната крайна точка не получава нищо.';

  @override
  String get webhookShowDeliveries => 'Покажи доставките ѝ';

  @override
  String get webhookDelete => 'Изтрий крайната точка';

  @override
  String get webhookDeleteTitle => 'Да се изтрие ли крайната точка?';

  @override
  String webhookDeleteBody(String url) {
    return '$url спира да получава събития, а чакащите доставки се отказват. Това не може да се отмени.';
  }

  @override
  String get webhookDeleted => 'Крайната точка е изтрита.';

  @override
  String get webhookUrl => 'Адрес';

  @override
  String get webhookUrlHelp =>
      'Трябва да е https, освен ако не е локален адрес.';

  @override
  String get webhookEvents => 'Типове събития';

  @override
  String get webhookEventsHelp =>
      'Разделени със запетаи; типът може да завършва на *. Празно изпраща всяко събитие.';

  @override
  String get webhookSecret => 'Тайна за подписване';

  @override
  String get webhookSecretNewHelp =>
      'Оставете празно и tix ще създаде тайна, която ще се покаже тук веднъж.';

  @override
  String get webhookSecretKeepHelp =>
      'Оставете празно, за да запазите текущата тайна.';

  @override
  String get webhookSave => 'Запази крайната точка';

  @override
  String get webhookSaved => 'Крайната точка е запазена.';

  @override
  String get webhookSecretHeading => 'Копирайте тайната за подписване сега';

  @override
  String get webhookSecretNote =>
      'Показва се веднъж и не може да бъде прочетена отново. Въведете я в получаващата страна; ако я загубите, запазете крайната точка отново със своя тайна.';

  @override
  String get webhookSecretDone => 'Копирах я';

  @override
  String get webhookDeliveries => 'Доставки';

  @override
  String get webhookDeliveriesAll => 'Всички крайни точки, най-новите първо.';

  @override
  String webhookDeliveriesFor(String url) {
    return 'За $url, най-новите първо.';
  }

  @override
  String get webhookDeliveriesShowAll => 'Покажи всички';

  @override
  String get webhookDeliveriesEmpty => 'Няма доставки.';

  @override
  String get webhookDeliveriesEmptyBody =>
      'Доставките се появяват тук, щом събитията бъдат изпратени.';

  @override
  String get webhookStatusAny => 'Всички';

  @override
  String get webhookStatusPending => 'Чакащи';

  @override
  String get webhookStatusDelivered => 'Доставени';

  @override
  String get webhookStatusFailed => 'Неуспешни';

  @override
  String get webhookStatusUnknown => 'Неизвестно';

  @override
  String webhookEvent(int seq) {
    return 'Събитие $seq';
  }

  @override
  String webhookAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count опита',
      one: '1 опит',
    );
    return '$_temp0';
  }

  @override
  String webhookHttpStatus(int code) {
    return 'HTTP $code';
  }

  @override
  String webhookNextAttempt(String when) {
    return 'следващ опит $when';
  }

  @override
  String get webhookRedeliver => 'Изпрати пак';

  @override
  String get webhookRedelivered => 'Добавена е за нов опит.';

  @override
  String get webhookPing => 'Изпрати тест';

  @override
  String get webhookPingTitle => 'Тестово събитие';

  @override
  String webhookPingSent(String url) {
    return 'tix изпрати подписано събитие webhook.ping до $url.';
  }

  @override
  String get webhookPingPending =>
      'Още не е опитано. Дневникът на доставките ще покаже резултата, щом tix опита.';

  @override
  String get syncTitle => 'Външна синхронизация';

  @override
  String get syncSubtitle =>
      'Внасяне от Jira, OpenProject или файл. Изпълнява се на сървъра.';

  @override
  String get syncNew => 'Нов източник';

  @override
  String get syncSources => 'Източници';

  @override
  String get syncSourcesInfo =>
      'Всеки източник пази докъде е стигнал, така че изпълнението внася само промененото от предишното. Пълното изпълнение започва отначало.';

  @override
  String get syncEmpty => 'Още няма източници.';

  @override
  String get syncEmptyBody =>
      'Добавете източник, за да внасяте задачи от друга система.';

  @override
  String get syncStatusOk => 'Последно: успешно';

  @override
  String get syncStatusFailed => 'Последно: неуспешно';

  @override
  String get syncStatusRunning => 'Изпълнява се';

  @override
  String get syncStatusNever => 'Не е изпълняван';

  @override
  String get syncNeverRun => 'Още не е изпълняван.';

  @override
  String syncLastRun(String when) {
    return 'Последно изпълнение: $when.';
  }

  @override
  String syncStoredCredentials(String names) {
    return 'Запазени данни за достъп: $names';
  }

  @override
  String get syncMissing => 'Изпълнението се отказва, докато сървърът няма:';

  @override
  String get syncReady => 'Готов за изпълнение.';

  @override
  String get syncRunNow => 'Изпълни сега';

  @override
  String get syncPreview => 'Преглед';

  @override
  String get syncEdit => 'Редактирай';

  @override
  String get syncDelete => 'Изтрий източника';

  @override
  String get syncDeleteTitle => 'Да се изтрие ли източникът?';

  @override
  String syncDeleteBody(String name) {
    return '$name и докъде е стигнал се премахват. Вече внесените задачи остават. Това не може да се отмени.';
  }

  @override
  String get syncDeleted => 'Източникът е изтрит.';

  @override
  String syncSaved(String name) {
    return '$name е запазен.';
  }

  @override
  String syncRunTitle(String name) {
    return 'Изпълнение на $name';
  }

  @override
  String get syncRunBody =>
      'Прегледът отчита какво би направило изпълнението, без да променя нищо.';

  @override
  String get syncFull => 'Пълно изпълнение';

  @override
  String get syncFullHelp =>
      'Прочита всичко отначало вместо оттам, докъдето е стигнало предишното изпълнение.';

  @override
  String get syncPreviewTitle => 'Преглед';

  @override
  String get syncDoneTitle => 'Изпълнението приключи';

  @override
  String get syncPreviewNote => 'Нищо не е променено.';

  @override
  String syncCounts(int created, int updated, int skipped, int deleted) {
    return '$created създадени · $updated обновени · $skipped пропуснати · $deleted изтрити';
  }

  @override
  String get syncUnmatched => 'Хора без съответствие тук';

  @override
  String get syncWarnings => 'Предупреждения';

  @override
  String syncWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count предупреждения',
      one: '1 предупреждение',
    );
    return '$_temp0';
  }

  @override
  String get syncRuns => 'История на изпълненията';

  @override
  String get syncRunsEmpty => 'Няма завършени изпълнения.';

  @override
  String get syncRunsEmptyBody =>
      'Неуспешно изпълнение не се показва тук; вижда се при източника.';

  @override
  String syncEditTitle(String name) {
    return 'Редактиране на $name';
  }

  @override
  String get syncFormIntro =>
      'Настройките и съответствията се пазят на сървъра. Данните за достъп се запечатват там и не се показват повече.';

  @override
  String get syncName => 'Име';

  @override
  String get syncNameHelp => 'Име на източника в неговата система.';

  @override
  String get syncMapping => 'Документ със съответствия (YAML)';

  @override
  String get syncMappingHelp => 'Ако е празно, запазеният документ остава.';

  @override
  String get syncMappingPath => 'Файл със съответствия на сървъра';

  @override
  String get syncMappingPathHelp =>
      'Чете се само от папката на организацията в sync.file_root на сървъра.';

  @override
  String get syncCredentials => 'Данни за достъп';

  @override
  String get syncCredentialsHelp =>
      'Само за запис. Всяко от тях заменя запазените; оставете всички празни, за да ги запазите.';

  @override
  String get syncToken => 'Токен';

  @override
  String get syncUser => 'Потребител';

  @override
  String get syncPassword => 'Парола или API ключ';

  @override
  String get syncClearCredentials => 'Премахни запазените данни за достъп';

  @override
  String get syncCheck => 'Провери';

  @override
  String get syncSave => 'Запази източника';

  @override
  String syncMappingFrom(String origin) {
    return 'Съответствия: $origin';
  }

  @override
  String syncCredentialsFrom(String origin) {
    return 'Данни за достъп: $origin';
  }

  @override
  String get syncFromStored => 'запазени при източника';

  @override
  String get syncFromEnv => 'от средата';

  @override
  String get syncFromMappingPath => 'файл на сървъра';

  @override
  String get syncFromNone => 'не са нужни';

  @override
  String get syncFromMissing => 'липсват';

  @override
  String syncSummaryProject(String project) {
    return 'Влиза в проект $project';
  }

  @override
  String syncSummaryIdentity(String field) {
    return 'Съпоставя се по $field';
  }

  @override
  String get retentionTitle => 'Съхранение';

  @override
  String get retentionSubtitle =>
      'Колко дълго организацията пази дневниците си.';

  @override
  String get retentionWindows => 'Пазене';

  @override
  String get retentionWindowsHelp =>
      'В дни. По-старите записи се премахват при почистване.';

  @override
  String get retentionEvents => 'Събития';

  @override
  String get retentionEventsHelp =>
      'Потокът с обновявания на живо. По подразбиране 30 дни.';

  @override
  String get retentionAudit => 'Записи в одита';

  @override
  String get retentionAuditHelp =>
      'Кой какво е променил. По подразбиране 365 дни.';

  @override
  String get retentionDeliveries => 'Доставки на уебкукички';

  @override
  String get retentionDeliveriesHelp =>
      'Дневникът на доставките. По подразбиране 30 дни.';

  @override
  String get retentionSave => 'Запази';

  @override
  String get retentionSaved => 'Съхранението е запазено.';

  @override
  String get retentionPruneSection => 'Почистване сега';

  @override
  String get retentionPruneHelp =>
      'Премахва веднага всичко извън срока, вместо да се чака сървърът.';

  @override
  String get retentionPreview => 'Преглед';

  @override
  String get retentionPrune => 'Почисти';

  @override
  String get retentionPruneTitle => 'Да се почистят ли старите записи?';

  @override
  String get retentionPruneBody =>
      'Събитията, записите в одита и доставките извън срока се изтриват завинаги.';

  @override
  String get retentionPruned => 'Почистено.';

  @override
  String retentionWouldPrune(int events, int audit, int deliveries) {
    return 'Ще бъдат премахнати $events събития, $audit записа в одита и $deliveries доставки.';
  }

  @override
  String retentionDidPrune(int events, int audit, int deliveries) {
    return 'Премахнати са $events събития, $audit записа в одита и $deliveries доставки.';
  }

  @override
  String retentionKeptForSubscribers(int count) {
    return '$count събития извън срока се пазят, докато абонат не ги прочете.';
  }

  @override
  String get housekeepingTitle => 'Поддръжка';

  @override
  String get housekeepingSubtitle =>
      'Изчиства завършената работа от списъците и изпразва кошчето.';

  @override
  String get housekeepingPaused =>
      'Поддръжката е на пауза, докато кошчето е изключено: нито едно правило не се изпълнява.';

  @override
  String get housekeepingRules => 'Правила';

  @override
  String get housekeepingRulesHelp =>
      'Брой дни или off. Проектите могат да ги променят.';

  @override
  String get housekeepingDone => 'Завършените задачи отиват в кошчето след';

  @override
  String get housekeepingDoneHelp => 'Дни след завършването.';

  @override
  String get housekeepingCancelled => 'Отказаните задачи отиват в кошчето след';

  @override
  String get housekeepingCancelledHelp => 'Дни след отказването.';

  @override
  String get housekeepingTrash => 'Кошчето изтрива задачите завинаги след';

  @override
  String get housekeepingTrashHelp => 'Дни в кошчето.';

  @override
  String housekeepingPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count задачи за сега.',
      one: '1 задача за сега.',
      zero: 'Няма нищо за сега.',
    );
    return '$_temp0';
  }

  @override
  String get housekeepingSave => 'Запази правилата';

  @override
  String get housekeepingSaved => 'Правилата са запазени.';

  @override
  String get housekeepingRunSection => 'Изпълнение сега';

  @override
  String get housekeepingRunHelp =>
      'Прилага правилата веднъж, на части, вместо да се чака следващото минаване на сървъра.';

  @override
  String get housekeepingPreview => 'Преглед';

  @override
  String get housekeepingRun => 'Изпълни поддръжката';

  @override
  String get housekeepingRunTitle => 'Да се изпълни ли поддръжката сега?';

  @override
  String get housekeepingRunBody =>
      'Завършените задачи извън срока отиват в кошчето, а задачите извън срока на кошчето се изтриват завинаги.';

  @override
  String housekeepingWould(int done, int cancelled, int trash) {
    return 'Ще премести $done завършени и $cancelled отказани задачи в кошчето и ще изтрие $trash завинаги.';
  }

  @override
  String housekeepingDid(int done, int cancelled, int trash) {
    return 'Преместени са $done завършени и $cancelled отказани задачи в кошчето, а $trash са изтрити завинаги.';
  }

  @override
  String get trashTitle => 'Кошче';

  @override
  String get trashSubtitle =>
      'Изтритите задачи, докато поддръжката не ги изчисти.';

  @override
  String get trashExplain =>
      'Възстановяването връща задачата на мястото ѝ. „Изтрий завинаги“ я премахва окончателно заедно с подзадачите ѝ в кошчето, както прави правилото за кошчето в поддръжката, когато им изтече срокът.';

  @override
  String get trashEmpty => 'Кошчето е празно.';

  @override
  String get trashEmptyBody =>
      'Изтритите задачи чакат тук и могат да бъдат възстановени.';

  @override
  String get trashRestore => 'Възстанови';

  @override
  String trashRestored(String ref) {
    return '$ref е възстановена.';
  }

  @override
  String trashDeletedAt(String when) {
    return 'изтрита $when';
  }

  @override
  String get trashPurge => 'Изтрий завинаги';

  @override
  String get trashPurgeTitle => 'Да се изтрие ли завинаги?';

  @override
  String trashPurgeBody(String ref, String title) {
    return '$ref „$title“ и подзадачите ѝ в кошчето се изтриват завинаги. Това не може да бъде отменено.';
  }

  @override
  String trashPurged(String ref) {
    return '$ref е изтрита завинаги.';
  }

  @override
  String get activityTitle => 'Активност';

  @override
  String get auditSubtitle =>
      'Всяка промяна в организацията, най-новите първо.';

  @override
  String get auditSearch => 'Търсене в действия, записи и стойности';

  @override
  String get auditVia => 'Канал';

  @override
  String get auditSource => 'Повърхност';

  @override
  String get auditMoreFilters => 'Още филтри';

  @override
  String auditMoreFiltersCount(int count) {
    return 'Още филтри ($count)';
  }

  @override
  String get auditClear => 'Изчисти филтрите';

  @override
  String get auditFilters => 'Филтриране на одита';

  @override
  String get auditApply => 'Приложи';

  @override
  String get auditActor => 'Извършител';

  @override
  String get auditActorHelp => 'Идентификаторът на извършителя.';

  @override
  String get auditAction => 'Действие';

  @override
  String get auditToken => 'API токен';

  @override
  String get auditTokenHelp => 'Името на токена.';

  @override
  String auditSince(String day) {
    return 'От $day';
  }

  @override
  String auditUntil(String day) {
    return 'До $day';
  }

  @override
  String get auditAnyTime => 'всяко време';

  @override
  String get auditEmpty => 'Още няма записи.';

  @override
  String get auditEmptyBody =>
      'Промените се появяват тук, щом хората и агентите ги направят.';

  @override
  String get auditNoMatch => 'Няма съвпадащи записи.';

  @override
  String get auditNoMatchBody => 'Разхлабете или изчистете филтрите.';

  @override
  String get auditPick => 'Изберете запис';

  @override
  String get auditPickBody => 'Подробностите се показват тук.';

  @override
  String get auditSeq => 'Запис';

  @override
  String get auditWhen => 'Кога';

  @override
  String get auditSystem => 'системата';

  @override
  String get auditSubject => 'Обект';

  @override
  String get auditTokenId => 'Идентификатор на токена';

  @override
  String get auditSession => 'Сесия';

  @override
  String get auditKey => 'SSH ключ';

  @override
  String get auditClient => 'Адрес на клиента';

  @override
  String get auditOrigin => 'Произход';

  @override
  String get auditHost => 'Машина';

  @override
  String get auditOsUser => 'Системен потребител';

  @override
  String get auditJob => 'Задание';

  @override
  String get auditUserAgent => 'Клиентска програма';

  @override
  String get auditBefore => 'Преди';

  @override
  String get auditAfter => 'След';

  @override
  String get timeJustNow => 'току-що';

  @override
  String get timeInAMoment => 'след малко';

  @override
  String timeAgoMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'преди $n минути',
      one: 'преди 1 минута',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'преди $n часа',
      one: 'преди 1 час',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'преди $n дни',
      one: 'преди 1 ден',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'преди $n месеца',
      one: 'преди 1 месец',
    );
    return '$_temp0';
  }

  @override
  String timeAgoYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'преди $n години',
      one: 'преди 1 година',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'след $n минути',
      one: 'след 1 минута',
    );
    return '$_temp0';
  }

  @override
  String timeInHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'след $n часа',
      one: 'след 1 час',
    );
    return '$_temp0';
  }

  @override
  String timeInDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'след $n дни',
      one: 'след 1 ден',
    );
    return '$_temp0';
  }

  @override
  String timeInMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'след $n месеца',
      one: 'след 1 месец',
    );
    return '$_temp0';
  }

  @override
  String timeInYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'след $n години',
      one: 'след 1 година',
    );
    return '$_temp0';
  }

  @override
  String get timeFormatIso => 'ISO';

  @override
  String get timeFormatRfc3339 => 'RFC 3339';

  @override
  String get timeFormatShort => 'Кратък';

  @override
  String get timeFormatLong => 'Дълъг';

  @override
  String get timeFormatDotted => 'С точки';

  @override
  String get timeFormatDayfirst => 'Първо денят';

  @override
  String get timeFormatUs => 'САЩ';

  @override
  String get timeFormatRelative => 'Относителен';

  @override
  String get settingsSearchHint => 'Търсене в настройките';

  @override
  String settingsNoMatch(String query) {
    return 'Няма настройка, отговаряща на „$query“';
  }

  @override
  String get settingsNoMatchBody =>
      'Опитайте с друга дума или изчистете търсенето.';

  @override
  String get settingsScopeDevice => 'На това устройство';

  @override
  String get settingsScopeAccount => 'Синхронизира се с профила ви';

  @override
  String get settingsScopeTenant => 'Целият наемател';

  @override
  String get settingsGroupDevice => 'Това устройство';

  @override
  String get settingsGroupDeviceHelp =>
      'Пазят се само на това устройство. Другите ви устройства и уебът имат свои.';

  @override
  String settingsGroupAccount(String tenant) {
    return 'Вашият профил в $tenant';
  }

  @override
  String get settingsGroupAccountHelp =>
      'Сървърът ги пази с профила ви, затова ви следват на всяко устройство, в уеба и в командния ред.';

  @override
  String get settingsGroupTenant => 'Този наемател';

  @override
  String settingsGroupTenantHelp(String tenant) {
    return 'Настройки за всички в $tenant. Виждат ги само администратори.';
  }

  @override
  String get settingsReduceMotion => 'Без анимации';

  @override
  String get settingsReduceMotionHelp =>
      'Приложението остава неподвижно, дори когато системата позволява анимации.';

  @override
  String get settingsHaptics => 'Вибрация при докосване';

  @override
  String get settingsHapticsHelp =>
      'Кратка вибрация при плъзгане, завършена задача и отказ.';

  @override
  String get settingsLanguageHelp =>
      'tix не пази език в профила ви, затова всяко устройство и браузър избира свой.';

  @override
  String get settingsStartTitle => 'Начален екран';

  @override
  String get settingsStartHelp =>
      'Къде се отваря приложението при стартиране или след вход.';

  @override
  String get settingsDeviceNotifTitle => 'Известия на това устройство';

  @override
  String get settingsDeviceNotifSubtitle =>
      'Дали това устройство ви известява и за какво';

  @override
  String get settingsProfileTitle => 'Профил';

  @override
  String get settingsDatesTitle => 'Дати и часове';

  @override
  String get settingsDatesHelp =>
      'Пазят се с профила ви, затова всяко устройство, браузър и терминал показва датите така. „Наследяване“ следва настройката на наемателя, а тя тази на сървъра.';

  @override
  String get settingsDateFormat => 'Формат на датата';

  @override
  String get settingsDateFormatHelp =>
      'Как се изписва всеки момент в приложението. В уеба tix чете въведените дати по същия начин.';

  @override
  String get settingsTimeZone => 'Часова зона';

  @override
  String get settingsTimeZoneHelp =>
      'Зоната, в която се показва всеки час в приложението и където свършва днешният ден за сроковете.';

  @override
  String get settingsInherit => 'Наследяване';

  @override
  String settingsInheritValue(String value) {
    return 'Наследяване: $value';
  }

  @override
  String settingsInUse(String value, String source) {
    return 'В момента: $value, от $source';
  }

  @override
  String get settingsSourceUser => 'вашия избор';

  @override
  String get settingsSourceTenant => 'настройката на наемателя';

  @override
  String get settingsSourceGlobal => 'настройката на сървъра';

  @override
  String get settingsDeviceFormat => 'формата на това устройство';

  @override
  String settingsDeviceZone(String zone) {
    return 'зоната на това устройство ($zone)';
  }

  @override
  String get settingsDatesNotPersonal =>
      'Тези идентификационни данни не са на човек, затова ползват настройките на наемателя и не могат да имат свои.';

  @override
  String get settingsDatesLoading =>
      'Настройките ви за дати се четат от сървъра…';

  @override
  String get settingsDatesUnsupported =>
      'Тази версия на tix не пази предпочитания за дати, затова датите следват това устройство. По-нов сървър на tix ги добавя.';

  @override
  String get settingsDatesFailed =>
      'Сървърът не отговори, затова засега датите следват това устройство.';

  @override
  String get settingsDatesSaved => 'Запазено в профила ви';

  @override
  String get settingsZoneSearch => 'Търсене на часова зона';

  @override
  String get settingsZoneNone => 'Няма такава часова зона.';

  @override
  String get settingsInboxTitle => 'Входящи и канали';

  @override
  String get settingsInboxSubtitle =>
      'Какво стига до входящите ви и личните ви канали';

  @override
  String get settingsFiltersTitle => 'Запазени филтри';

  @override
  String get settingsFiltersSubtitle =>
      'Преименуване, споделяне или изтриване на филтрите ви';

  @override
  String get settingsArrangementTitle => 'Табло и ленти';

  @override
  String get settingsArrangementHelp =>
      'Групите, които сте скрили, отбелязали, свили или преместили на таблото, в лентите и в „Моята работа“.';

  @override
  String get settingsArrangementReset => 'Нулиране';

  @override
  String get settingsArrangementResetTitle => 'Нулиране на таблото и лентите';

  @override
  String get settingsArrangementResetBody =>
      'Всяка група на таблото, в лентите и в „Моята работа“ се връща там, където я поставя tix, на всяко устройство и в уеба. Това не може да се отмени.';

  @override
  String get settingsArrangementDone => 'Подредбата е нулирана';

  @override
  String settingsTenantManage(String tenant) {
    return 'Управление на $tenant';
  }

  @override
  String get settingsTenantManageSubtitle =>
      'Проекти, работни потоци, полета, хора и настройките на наемателя';

  @override
  String paletteSettingsItem(String name) {
    return 'Настройки: $name';
  }

  @override
  String get savedFiltersEmpty => 'Няма запазени филтри';

  @override
  String get savedFiltersEmptyBody =>
      'Запазете филтър от списъка със задачи и той ще се появи тук, на всяко устройство.';

  @override
  String get savedFilterSharedBadge => 'Споделен';

  @override
  String get savedFilterTheirs =>
      'Споделен с вас; само собственикът и администраторите могат да го променят.';

  @override
  String durationDays(int n) {
    return '$n д';
  }

  @override
  String durationHours(int n) {
    return '$n ч';
  }

  @override
  String durationMinutes(int n) {
    return '$n мин';
  }

  @override
  String durationSeconds(int n) {
    return '$n с';
  }

  @override
  String get errorBadInviteLink =>
      'Това не е линк за покана. Изглежда така: https://вашият-сървър/invite/tix_inv_…';

  @override
  String get methodInvite => 'Покана';

  @override
  String get inviteLinkLabel => 'Линк за покана';

  @override
  String get inviteLinkHint => 'https://tix.example.com/invite/tix_inv_…';

  @override
  String get inviteLinkHelp =>
      'Поставете линка от имейла с поканата или го споделете към tix от друго приложение. Сървърът се добавя автоматично.';

  @override
  String get invitePaste => 'Поставяне на линка за покана';

  @override
  String get inviteCheck => 'Провери поканата';

  @override
  String inviteJoin(String tenant, String host) {
    return 'Присъединяване към $tenant на $host';
  }

  @override
  String inviteJoinServer(String host) {
    return 'Присъединяване към $host';
  }

  @override
  String inviteAs(String email) {
    return 'като $email';
  }

  @override
  String inviteExpires(String when) {
    return 'Линкът важи до $when.';
  }

  @override
  String get inviteExistingAccount =>
      'Този адрес вече има профил в tix. Въведете паролата му, за да приемете; профилът не се променя.';

  @override
  String get inviteDisplayName => 'Вашето име';

  @override
  String get inviteNewPassword => 'Нова парола';

  @override
  String get inviteNewPasswordHelp =>
      'Поне 12 знака. С нея влизате навсякъде, не само тук.';

  @override
  String get inviteExistingPasswordHelp =>
      'Паролата, с която вече влизате в tix.';

  @override
  String get inviteCodeHelp =>
      'Код от приложението за удостоверяване, което профилът вече използва.';

  @override
  String get inviteAccept => 'Приемане на поканата';

  @override
  String get notifHideContent => 'Скриване на съдържанието в известията';

  @override
  String get notifHideContentHelp =>
      'Известията казват само „Ново във входящите“, за този контекст.';

  @override
  String get notifPrivateTitle => 'Ново във входящите';

  @override
  String get notifPrivateBody => 'Отворете tix, за да го прочетете.';

  @override
  String get taskDetailLease => 'Срок на заявка';

  @override
  String get taskDetailLeaseInfo =>
      'Колко трае заявката на агент за тази задача, когато не поиска срок, и най-дългото, което може да трае. Задачата, проектът, работният процес и тенантът могат да го зададат; най-близкият печели.';

  @override
  String taskDetailLeaseValue(String length, String source) {
    return '$length, от $source';
  }

  @override
  String taskDetailLeaseMax(String length, String source) {
    return 'Най-много $length, от $source';
  }

  @override
  String get taskDetailLeaseClamped => 'Съкратен до тавана.';

  @override
  String get leaseSourceClaim => 'заявката';

  @override
  String get leaseSourceTask => 'задачата';

  @override
  String get leaseSourceProject => 'проекта';

  @override
  String get leaseSourceWorkflow => 'работния процес';

  @override
  String get leaseSourceTenant => 'тенанта';

  @override
  String get leaseSourceDeployment => 'сървъра';

  @override
  String get leaseSourceBuiltin => 'стандарта на tix';

  @override
  String get statusTitle => 'Състояние на сървъра';

  @override
  String get statusInstallation => 'Инсталация';

  @override
  String get statusVersion => 'Версия';

  @override
  String get statusSchema => 'Схема';

  @override
  String get statusEngine => 'База данни';

  @override
  String get statusAnswering => 'Отговорил';

  @override
  String get statusObserved => 'Проверено';

  @override
  String get statusServers => 'Сървърни процеси';

  @override
  String get statusServersInfo =>
      'Всеки процес на tix, регистриран към тази база данни. Пропуснал три сигнала се показва като замлъкнал.';

  @override
  String get statusNoServers =>
      'Няма регистриран процес. Отговарящият може да работи без регистъра.';

  @override
  String get statusAttached => 'Изпраща сигнали';

  @override
  String statusDetached(String when) {
    return 'Замлъкнал от $when';
  }

  @override
  String statusUptime(String length) {
    return 'работи от $length';
  }

  @override
  String statusConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count връзки',
      one: '1 връзка',
    );
    return '$_temp0';
  }

  @override
  String get statusWork => 'Този тенант';

  @override
  String get statusProjects => 'Проекти';

  @override
  String get statusTasks => 'Задачи';

  @override
  String get statusClaimed => 'Заети сега';

  @override
  String get statusUnswept => 'Изтекли заявки, още неизчистени';

  @override
  String get statusWebhooksPending => 'Чакащи доставки на webhook';

  @override
  String get statusWebhooksFailed => 'Неуспешни доставки на webhook';

  @override
  String get statusSecondFactor => 'Втори фактор';

  @override
  String get statusKey => 'Зададен ключ за запечатване';

  @override
  String get statusRequireWeb => 'Задължителен в браузъра';

  @override
  String get statusRequireCli => 'Задължителен в командния ред и приложенията';

  @override
  String get statusRequireSsh => 'Задължителен през SSH';

  @override
  String get statusAdmins => 'Администратори с такъв';

  @override
  String statusAdminsEnrolled(int enrolled, int total) {
    return '$enrolled от $total';
  }

  @override
  String get statusUnrecoverable =>
      'Някои втори фактори не могат да се прочетат: липсва ключът за запечатване. На тези хора трябва да се изчистят и да се регистрират отново.';

  @override
  String get statusYes => 'Да';

  @override
  String get statusNo => 'Не';

  @override
  String get bundlesTitle => 'Пакети';

  @override
  String get bundleExportTitle => 'Експорт на пакет';

  @override
  String get bundleExportSubtitle =>
      'Настройки за многократна употреба в един файл, за друг тенант или сървър';

  @override
  String get bundleExportInfo =>
      'Пакетът съдържа работни процеси, дефиниции на полета, етикети, проекти като шаблони и webhook адреси, но не и задачите им. Тайните на webhook никога не се включват.';

  @override
  String get bundleKindWorkflow => 'Работни процеси';

  @override
  String get bundleKindField => 'Полета';

  @override
  String get bundleKindTag => 'Етикети';

  @override
  String get bundleKindProject => 'Шаблони на проекти';

  @override
  String get bundleKindWebhook => 'Webhooks';

  @override
  String get bundleKindsAll =>
      'Нищо не е избрано: пакетът съдържа всички видове.';

  @override
  String get bundleKindsSome => 'Влизат само избраните видове.';

  @override
  String get bundleName => 'Име';

  @override
  String get bundleNameHelp => 'Етикет на пакета за получателя. По избор.';

  @override
  String get bundleExport => 'Експорт на пакета';

  @override
  String bundleExported(String name) {
    return 'Експортиран $name';
  }

  @override
  String get bundleImportTitle => 'Импорт на пакет';

  @override
  String get bundleImportSubtitle => 'Първо преглед, после се прилага наведнъж';

  @override
  String get bundleImportInfo =>
      'Пакетът се прилага изцяло: или влиза всичко, или нищо. Прегледът не записва нищо.';

  @override
  String get bundlePick => 'Изберете файл с пакет';

  @override
  String get bundleCollision => 'Когато ключът е зает';

  @override
  String get bundleCollisionAsk => 'Спиране и съобщение';

  @override
  String get bundleCollisionSkip => 'Запазване на моя';

  @override
  String get bundleCollisionRename => 'Импорт с нов ключ';

  @override
  String get bundleCollisionReplace => 'Замяна на моя';

  @override
  String get bundleProject => 'Проект за полетата';

  @override
  String get bundleProjectHelp =>
      'Ключът на проекта, в който влизат дефинициите на полета. Нужен е само ако пакетът ги съдържа.';

  @override
  String get bundlePreview => 'Преглед';

  @override
  String get bundleImport => 'Импорт на пакета';

  @override
  String get bundleReplaceBody =>
      'Компонентите със същия ключ се презаписват с тези от пакета. Това не може да се отмени.';

  @override
  String get bundleImported => 'Пакетът е импортиран.';

  @override
  String get bundlePlan => 'Какво би направил импортът';

  @override
  String get bundleDone => 'Какво направи импортът';

  @override
  String get bundleEmpty => 'Пакетът не съдържа нищо.';

  @override
  String get bundleActionCreate => 'Нов';

  @override
  String get bundleActionReplace => 'Заменен';

  @override
  String get bundleActionRename => 'Преименуван';

  @override
  String get bundleActionSkip => 'Пропуснат';

  @override
  String get snapshotTitle => 'Импорт на снимка';

  @override
  String get snapshotFileTitle => 'Файл със снимка';

  @override
  String get snapshotFileSubtitle => 'Файл от експорт на цял тенант';

  @override
  String get snapshotInfo =>
      'Снимката съдържа проекти, работни процеси, полета, задачи и коментари. Проверете какво ще промени с пробно изпълнение преди импорта.';

  @override
  String get snapshotPick => 'Изберете файл със снимка';

  @override
  String get snapshotMerge => 'Сливане';

  @override
  String get snapshotReplace => 'Замяна';

  @override
  String get snapshotMergeHelp =>
      'Добавя новото и обновява промененото. Нищо не се премахва.';

  @override
  String get snapshotReplaceHelp =>
      'Премахва и задачите и полетата на всеки импортиран проект, които снимката не съдържа.';

  @override
  String get snapshotDryRun => 'Пробно изпълнение';

  @override
  String get snapshotImport => 'Импорт на снимката';

  @override
  String get snapshotMergeBody =>
      'Записите от снимката се добавят към този тенант и обновяват съществуващите.';

  @override
  String get snapshotReplaceBody =>
      'Задачите и полетата на импортираните проекти, които снимката не съдържа, се изтриват. Това не може да се отмени.';

  @override
  String get snapshotImported => 'Снимката е импортирана.';

  @override
  String get snapshotPlan => 'Какво би направил импортът';

  @override
  String get snapshotDone => 'Какво направи импортът';

  @override
  String get snapshotCreated => 'Създадени';

  @override
  String get snapshotUpdated => 'Обновени';

  @override
  String get snapshotDeleted => 'Изтрити';

  @override
  String get snapshotSkipped => 'Непроменени';

  @override
  String manageInheritedValue(String value) {
    return 'Наследено: $value';
  }

  @override
  String manageDurationSaved(String value) {
    return 'Записано като $value. Празно наследява.';
  }

  @override
  String get projectsShowArchived => 'Показване на архивираните';

  @override
  String get projectStar => 'Отбележи проекта със звезда';

  @override
  String get projectUnstar => 'Махни звездата';

  @override
  String projectStarred(String name) {
    return '$name е отбелязан със звезда';
  }

  @override
  String projectUnstarred(String name) {
    return 'Звездата на $name е махната';
  }

  @override
  String get projectsStarredHeading => 'Със звезда';

  @override
  String get projectsRestHeading => 'Други проекти';

  @override
  String syncOpStarProject(String key) {
    return '$key: звезда на проекта';
  }

  @override
  String syncOpUnstarProject(String key) {
    return '$key: махане на звездата на проекта';
  }

  @override
  String get manageBundlesSubtitle =>
      'Работни процеси, полета, етикети и webhooks в един файл';

  @override
  String get manageSnapshotSubtitle => 'Внасяне на експорт на цял тенант';

  @override
  String get manageStatusSubtitle =>
      'Версия, сървърни процеси и работата на тенанта';

  @override
  String get rotateToken => 'Смяна на токена';

  @override
  String rotateTokenBody(String name) {
    return '$name получава нов токен със същото име, обхват и срок, а приложението пази само новия. Всичко друго, което ползва стария токен, спира да работи след минута.';
  }

  @override
  String get tokenRotated => 'Токенът е сменен. Старият спира след минута.';

  @override
  String get offlineTitle => 'Офлайн';

  @override
  String get offlineSubtitle => 'Какво остава достъпно без връзка';

  @override
  String get offlineLocal =>
      'Тази инстанция е база данни на това устройство, затова винаги е достъпна. Офлайн режимът е само за отдалечени инстанции.';

  @override
  String get offlineAvailableTitle => 'Достъпно офлайн';

  @override
  String get offlineAvailableSubtitle =>
      'Пази се на това устройство за активната инстанция и организация, с коментарите и подзадачите на всяка задача.';

  @override
  String get offlineStorageTitle => 'Място';

  @override
  String get offlineStorageSubtitle =>
      'Запазени копия за този контекст, включително промени, чакащи изпращане.';

  @override
  String get offlineStorageCounting => 'Пресмятане…';

  @override
  String get offlineStorageUnknown => 'Неизвестен размер';

  @override
  String get offlineClear => 'Изчисти запазените копия';

  @override
  String get offlineClearTitle => 'Да се изчистят ли запазените копия?';

  @override
  String get offlineClearBody =>
      'Екраните отново се зареждат от сървъра и нищо не е достъпно офлайн до следващата синхронизация. Промените, чакащи изпращане, се запазват.';

  @override
  String get offlineSyncTitle => 'Синхронизация';

  @override
  String get offlineSyncSubtitle =>
      'Тече при отваряне на този контекст и на всеки 30 минути. На телефон изчаква Wi-Fi и достатъчно батерия; „Синхронизирай“ винаги тече.';

  @override
  String get offlineSyncNow => 'Синхронизирай';

  @override
  String get offlineNeverSynced => 'Още не е синхронизирано';

  @override
  String offlineStorageUsed(String size) {
    return 'Заети $size';
  }

  @override
  String offlineLastSynced(String time) {
    return 'Последна синхронизация $time';
  }

  @override
  String offlineSavedCopy(String time) {
    return 'Офлайн, показва се копие от $time';
  }

  @override
  String get errorSecretStorage =>
      'Защитеното хранилище на устройството е заключено или отказа записа, затова нищо не е променено. Отключете го и опитайте отново.';

  @override
  String get tokenUnsavedTitle => 'Токенът е сменен, но не е запазен';

  @override
  String get tokenUnsavedHeading => 'Копирайте този токен сега';

  @override
  String get tokenUnsavedNote =>
      'Защитеното хранилище на устройството отказа новия токен. Показва се само този път, а старият токен спира да работи след минута. Приложението ползва новия, докато не бъде затворено; след това се свържете отново с него.';

  @override
  String get tokenUnsavedDone => 'Копирах го';

  @override
  String get syncMarkUnsynced => 'Неизпратено';

  @override
  String get syncMarkDraft => 'Чернова';

  @override
  String get syncMarkCheck => 'Провери';

  @override
  String get syncMarkConflict => 'Конфликт';

  @override
  String get syncMarkFailed => 'Отказано';

  @override
  String get syncConflictsTitle => 'Конфликти';

  @override
  String get syncConflictsSubtitle =>
      'Промени, направени офлайн, и как са синхронизирани';

  @override
  String get syncSendNow => 'Изпрати сега';

  @override
  String get syncEmptyTitle => 'Всичко е синхронизирано';

  @override
  String get syncConflictsEmptyBody =>
      'Промените, които правите офлайн, чакат тук, докато сървърът се върне.';

  @override
  String syncConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count конфликта',
      one: '1 конфликт',
    );
    return '$_temp0';
  }

  @override
  String get syncConflictsHelp =>
      'Някой е променил същото на сървъра, докато бяхте офлайн.';

  @override
  String get syncKeepAllMine => 'Запази всички мои';

  @override
  String get syncKeepAllTheirs => 'Запази всички техни';

  @override
  String syncWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count чакащи промени',
      one: '1 чакаща промяна',
    );
    return '$_temp0';
  }

  @override
  String get syncHistory => 'История';

  @override
  String get syncHistoryHelp =>
      'Решени конфликти. Обърнете някой, за да изпратите страната, която не беше запазена.';

  @override
  String get syncFieldTitle => 'Заглавие';

  @override
  String get syncFieldBody => 'Описание';

  @override
  String get syncFieldPriority => 'Приоритет';

  @override
  String get syncFieldAssignee => 'Отговорник';

  @override
  String get syncFieldDue => 'Срок';

  @override
  String get syncFieldTags => 'Етикети';

  @override
  String get syncFieldStatus => 'Статус';

  @override
  String get syncFieldRecurrence => 'Повторение';

  @override
  String get syncFieldParent => 'Родител';

  @override
  String get syncValueEmpty => '(празно)';

  @override
  String get syncMine => 'Мое';

  @override
  String get syncTheirs => 'Тяхно';

  @override
  String get syncKeepMine => 'Запази моето';

  @override
  String get syncKeepTheirs => 'Запази тяхното';

  @override
  String get syncEditChange => 'Редактирай';

  @override
  String get syncEditChangeTitle => 'Редактиране преди изпращане';

  @override
  String get syncEditSend => 'Изпрати';

  @override
  String syncTheirsWas(String value) {
    return 'На сървъра: $value';
  }

  @override
  String get syncDeletedBody =>
      'Тази задача е изтрита на сървъра, след като сте я променили.';

  @override
  String get syncRestoreApply => 'Възстанови и приложи';

  @override
  String get syncDiscardMine => 'Отхвърли моето';

  @override
  String get syncDiscardMineTitle => 'Да се отхвърлят ли промените ви?';

  @override
  String get syncDiscardMineBody =>
      'Всичко, което сте променили по задачата офлайн, отпада. Задачата остава изтрита.';

  @override
  String syncMoveRefused(String status, String reason) {
    return 'Преместването в $status е отказано: $reason';
  }

  @override
  String get syncMoveElsewhere => 'Премести другаде';

  @override
  String syncOpUpdate(String ref, String fields) {
    return '$ref: $fields';
  }

  @override
  String syncOpCheck(String ref) {
    return '$ref: точка от списъка';
  }

  @override
  String syncOpMove(String ref, String status) {
    return '$ref: преместване в $status';
  }

  @override
  String syncOpStar(String ref) {
    return '$ref: звезда';
  }

  @override
  String syncOpUnstar(String ref) {
    return '$ref: махане на звезда';
  }

  @override
  String syncOpSnooze(String ref) {
    return '$ref: отлагане';
  }

  @override
  String syncOpCreate(String title) {
    return 'Нова задача: $title';
  }

  @override
  String syncOpComment(String ref) {
    return '$ref: коментар';
  }

  @override
  String syncOpTagAdd(String ref, String tag) {
    return '$ref: добавяне на #$tag';
  }

  @override
  String syncOpTagRemove(String ref, String tag) {
    return '$ref: махане на #$tag';
  }

  @override
  String syncOpDependency(String ref, String other) {
    return '$ref: чака $other';
  }

  @override
  String syncOpArtifact(String ref) {
    return '$ref: прикачен файл';
  }

  @override
  String syncOpRestore(String ref) {
    return '$ref: възстановяване';
  }

  @override
  String get syncDiscardTitle => 'Да се отхвърли ли тази промяна?';

  @override
  String get syncDiscard => 'Отхвърли';

  @override
  String syncRefused(String reason) {
    return 'Сървърът отказа: $reason';
  }

  @override
  String get syncCheckBody =>
      'Отговорът се изгуби, така че задачата може вече да съществува. Погледнете проекта и я изпратете или отхвърлете.';

  @override
  String get syncSendAnyway => 'Изпрати въпреки това';

  @override
  String get syncAlreadyThere => 'Вече е там';

  @override
  String get syncRetry => 'Опитай отново';

  @override
  String get syncKeptMine => 'Запазено моето';

  @override
  String get syncKeptTheirs => 'Запазено тяхното';

  @override
  String get syncKeptEdited => 'Изпратена редакция';

  @override
  String get syncKeptRestored => 'Възстановено и приложено';

  @override
  String get syncKeptDiscarded => 'Моето е отхвърлено';

  @override
  String syncByPolicy(String what) {
    return '$what, според настройката ви';
  }

  @override
  String get syncReverse => 'Обърни';

  @override
  String syncBannerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count промени чакат синхронизация.',
      one: '1 промяна чака синхронизация.',
    );
    return '$_temp0';
  }

  @override
  String get syncBannerConflict => 'Офлайн промените ви изискват решение.';

  @override
  String get syncBannerDraft =>
      'Създадена офлайн. Ще получи номер при синхронизация.';

  @override
  String get syncResolve => 'Реши';

  @override
  String syncBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count конфликта за решаване',
      one: '1 конфликт за решаване',
    );
    return '$_temp0';
  }

  @override
  String get syncPolicyLabel => 'При конфликт на промени';

  @override
  String get syncPolicyHelp =>
      'За офлайн промени, които някой друг също е променил. Всеки конфликт остава в „Конфликти“, където може да бъде обърнат.';

  @override
  String get syncPolicyAsk => 'Питай';

  @override
  String get syncPolicyMine => 'Запази моето';

  @override
  String get syncPolicyTheirs => 'Запази тяхното';

  @override
  String get syncOpenConflicts => 'Конфликти и неизпратени промени';

  @override
  String get syncDiscardAll => 'Отхвърли всички неизпратени промени';

  @override
  String get syncDiscardAllTitle =>
      'Да се отхвърлят ли всички неизпратени промени?';

  @override
  String syncDiscardAllBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count офлайн промени отпадат и няма да бъдат изпратени. Черновите изчезват.',
      one: '1 офлайн промяна отпада и няма да бъде изпратена. Черновите изчезват.',
    );
    return '$_temp0';
  }

  @override
  String syncUnsentLost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count офлайн промени още не са изпратени и ще бъдат загубени.',
      one: '1 офлайн промяна още не е изпратена и ще бъде загубена.',
    );
    return '$_temp0';
  }

  @override
  String get syncStateUnreadable =>
      'Чакащите промени на това устройство не можаха да бъдат прочетени. Запазени са непроменени и не се изпращат.';

  @override
  String get settingsAdvanced => 'Разширени';

  @override
  String get settingsAdbControl => 'Разрешаване на управление през ADB';

  @override
  String get settingsAdbControlHelp =>
      'Позволява на компютър, свързан чрез USB отстраняване на грешки, да сменя контекста, да добавя задачи и да променя настройките в tix. Четенето на състоянието на приложението и отварянето на връзки tix:// работят и без това.';

  @override
  String get linkNotRecognised => 'Връзката не е разпозната';

  @override
  String get linkPickContextTitle => 'В кой контекст да се отвори връзката?';

  @override
  String get linkPickContextBody =>
      'Връзката съвпада с повече от един от вашите контексти.';

  @override
  String get notifActionDone => 'Готово';

  @override
  String get notifActionSnooze => 'Отложи';

  @override
  String get notifActionReply => 'Отговори';

  @override
  String get notifReplyLabel => 'Напишете коментар';

  @override
  String get notifActionFailedDone => 'Не можа да се маркира като готово';

  @override
  String get notifActionFailedSnooze => 'Не можа да се отложи';

  @override
  String get notifActionFailedReply => 'Отговорът ви не можа да се изпрати';

  @override
  String get notifActionFailedBody => 'Отворете tix, за да опитате отново.';

  @override
  String get pinToHome => 'Добави на началния екран';

  @override
  String get pinFailed => 'Не можа да се добави на началния екран';

  @override
  String get trayOpen => 'Отвори tix';

  @override
  String trayInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Входящи ($count непрочетени)',
      one: 'Входящи (1 непрочетено)',
      zero: 'Входящи',
    );
    return '$_temp0';
  }

  @override
  String get trayQuit => 'Изход от tix';

  @override
  String get trayStatusSignedOut => 'tix · не сте влезли';

  @override
  String trayStatusHeadline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tix · $count свързани инстанции',
      one: 'tix · 1 свързана инстанция',
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
  String get trayStatusLocal => 'локална';

  @override
  String get trayStatusLive => 'на живо';

  @override
  String get trayStatusConnecting => 'свързване';

  @override
  String get trayStatusSyncing => 'синхронизира се';

  @override
  String get trayStatusOffline => 'офлайн';

  @override
  String trayStatusSynced(String ago) {
    return 'синхронизирано $ago';
  }

  @override
  String trayStatusQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count промени чакат',
      one: '1 промяна чака',
    );
    return '$_temp0';
  }

  @override
  String trayStatusMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count още',
      one: '+1 още',
    );
    return '$_temp0';
  }

  @override
  String trayStatusUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочетени във Входящи',
      one: '1 непрочетено във Входящи',
    );
    return '$_temp0';
  }

  @override
  String get settingsDesktop => 'Работен плот';

  @override
  String get settingsDesktopHelp =>
      'Как се държи tix на този компютър: иконата в областта за известия, стартирането при влизане и клавишна комбинация, която работи във всяко приложение.';

  @override
  String get settingsCloseToTray => 'Остави да работи в областта за известия';

  @override
  String get settingsCloseToTrayHelp =>
      'Затварянето на прозореца го скрива, а синхронизацията и известията продължават. Изход има в менюто на иконата.';

  @override
  String get settingsCloseToTrayNone =>
      'Този работен плот не показва икони в областта за известия, затова затварянето на прозореца спира tix.';

  @override
  String get settingsAutostart => 'Стартиране при влизане';

  @override
  String get settingsAutostartHelp =>
      'tix се стартира, когато влезете в този компютър.';

  @override
  String get settingsAutostartFailed =>
      'Стартирането при влизане не можа да се промени';

  @override
  String get settingsHotkey => 'Бързо добавяне от всяко приложение';

  @override
  String settingsHotkeyHelp(String keys) {
    return '$keys отваря бързото добавяне, дори когато tix е във фонов режим.';
  }

  @override
  String settingsHotkeyTaken(String keys) {
    return '$keys се използва от друго приложение';
  }

  @override
  String get goWatch => 'Към Активност';

  @override
  String get watchTitle => 'Събития на живо';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get goStats => 'Към Статистика';

  @override
  String get statsIntro =>
      'Пропускателност, време за изпълнение и кой е движил работата, за период, който свършва в момента.';

  @override
  String get statsInfo =>
      '„Завършени“ брои задачите, достигнали крайно състояние в периода, включително отказаните; „създадени“ брои задачите, създадени в него. Времето за изпълнение тече от създаването на задачата до крайното ѝ състояние; „най-бавна“ е най-дългото от тях. Периодът винаги свършва в момента.';

  @override
  String get statsWindow => 'Период';

  @override
  String statsDays(int days) {
    return '$days дни';
  }

  @override
  String get statsProject => 'Проект';

  @override
  String get statsEveryProject => 'Всички проекти';

  @override
  String get statsShortProjects =>
      'Този списък не съдържа всички проекти на тенанта, така че липсващ проект не може да бъде избран тук. Цифрите по-долу не са засегнати.';

  @override
  String get statsCompleted => 'завършени';

  @override
  String get statsCreated => 'създадени';

  @override
  String get statsMedianLead => 'медианно време за изпълнение';

  @override
  String get statsSlowest => 'най-бавна';

  @override
  String get statsPerDay => 'Завършени по дни';

  @override
  String get statsPerDayInfo =>
      'Задачите, достигнали крайно състояние, по UTC деня, в който е станало. Задача, отворена отново след това, не се брои, а се брои само последното ѝ завършване.';

  @override
  String get statsPerDayLabel => 'Завършени задачи по дни';

  @override
  String statsDayCompleted(String day, int count) {
    return '$day: $count завършени';
  }

  @override
  String get statsNoneCompleted => 'Нищо не е завършено в този период.';

  @override
  String get statsWhere => 'Къде е работата';

  @override
  String get statsWhereInfo =>
      'Колко задачи има в момента във всяка категория състояния, независимо от периода. Готовите и отказаните са отделно, за да не изглежда изоставената работа като свършена.';

  @override
  String get statsSpread => 'Как са разпределени задачите по състояния';

  @override
  String get statsNoTasks => 'Все още няма задачи.';

  @override
  String get statsActive => 'Най-активни';

  @override
  String get statsActiveInfo =>
      'Хора и агенти, подредени по броя задачи, които са преместили в крайно състояние, според одитния журнал. Това не е мярка за усилие. Преход, по-стар от срока на съхранение на одитния журнал, не се приписва на никого.';

  @override
  String statsCounting(String measure) {
    return 'Отчитат се $measure.';
  }

  @override
  String get statsMeasureMoved => 'задачите, преместени в крайно състояние';

  @override
  String get statsNobody =>
      'Никой не е преместил задача в крайно състояние в този период.';

  @override
  String get statsWaiting => 'Чакат най-дълго';

  @override
  String get statsWaitingInfo =>
      'Най-старите задачи, които не са достигнали крайно състояние, независимо от периода. Възрастта се брои от създаването на задачата.';

  @override
  String get statsNothingWaiting =>
      'Нищо не чака: всяка задача е достигнала крайно състояние.';

  @override
  String statsAge(String age) {
    return 'възраст $age';
  }

  @override
  String get watchSubtitle =>
      'Събитията в организацията, докато се случват, най-новите най-отгоре.';

  @override
  String get watchPause => 'Пауза';

  @override
  String get watchResume => 'Продължи';

  @override
  String get watchClear => 'Изчисти списъка';

  @override
  String get watchPaused => 'На пауза.';

  @override
  String watchPausedNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'На пауза, $count нови събития.',
      one: 'На пауза, 1 ново събитие.',
    );
    return '$_temp0';
  }

  @override
  String get watchFilters => 'Филтри';

  @override
  String watchFiltersCount(int count) {
    return 'Филтри ($count)';
  }

  @override
  String get watchAllTypes => 'Всички типове';

  @override
  String watchFiltering(String filters) {
    return 'Филтрирано по $filters';
  }

  @override
  String watchFilterProject(String projects) {
    return 'проект $projects';
  }

  @override
  String watchFilterType(String types) {
    return 'тип $types';
  }

  @override
  String watchFilterActor(String actors) {
    return 'автор $actors';
  }

  @override
  String watchFilterSince(int seq) {
    return 'след №$seq';
  }

  @override
  String get watchProjects => 'Проекти';

  @override
  String get watchProjectsHelp =>
      'Изпраща се на сървъра. Без избран проект се следят всички.';

  @override
  String get watchTypes => 'Типове събития';

  @override
  String get watchTypesHelp =>
      'Разделени със запетая, изпращат се на сървъра. * накрая значи всички с това начало, например task.*.';

  @override
  String get watchActors => 'Автори';

  @override
  String get watchActorsHelp =>
      'Псевдоними или идентификатори, разделени със запетая. Сравняват се на това устройство, както прави tix watch.';

  @override
  String get watchReplay => 'Повтори от пореден номер';

  @override
  String get watchReplayHelp =>
      'Показва отново събитията след този номер и после продължава на живо. Празно започва от сега.';

  @override
  String get watchDetails => 'Подробности';

  @override
  String get watchOpen => 'Отвори';

  @override
  String get watchSeq => 'Пореден номер';

  @override
  String get watchType => 'Тип';

  @override
  String get watchProject => 'Проект';

  @override
  String get watchEventId => 'Идентификатор на събитието';

  @override
  String get watchPayload => 'Данни';

  @override
  String get watchEmpty => 'Очакват се събития';

  @override
  String get watchEmptyBody =>
      'Промените в организацията се показват тук, докато се случват. По-ранните не се показват, освен ако не повторите от пореден номер.';

  @override
  String get watchNoMatch => 'Още няма съвпадения';

  @override
  String get watchNoMatchBody =>
      'Събития пристигат, но никое не отговаря на тези филтри.';

  @override
  String get watchConnecting => 'Свързване с потока от събития';

  @override
  String get watchOffline => 'Няма връзка';

  @override
  String get watchOfflineBody =>
      'Сървърът не е достъпен. Събитията на живо продължават оттам, докъдето са стигнали, щом връзката се възстанови.';

  @override
  String get watchNoContext => 'Няма активен контекст';

  @override
  String get watchRefused => 'Тази връзка не може да следи събития';

  @override
  String get watchRefusedBody =>
      'За следене на събития е нужен обхватът event:subscribe. Използвайте токен с него или го поискайте от администратор.';

  @override
  String get watchFilterRefused => 'Сървърът отказа този филтър';

  @override
  String get watchUnsupported =>
      'Сървърът в момента не може да изпраща събития към приложението, затова Събития на живо остава празно. Ще продължи, щом обновяването на живо заработи.';

  @override
  String watchExpired(int seq) {
    return 'Събитията след №$seq вече не се пазят на сървъра. Показват се новите събития от сега.';
  }

  @override
  String get watchMissed =>
      'Връзката се възстанови без курсор, затова може да липсват събития.';

  @override
  String get watchDismiss => 'Скрий';

  @override
  String watchKeeping(int count) {
    return 'Пазят се последните $count събития; по-старите отпадат.';
  }

  @override
  String watchFor(String holder) {
    return 'за $holder';
  }

  @override
  String watchLease(String duration) {
    return 'наем $duration';
  }

  @override
  String watchHeldBy(String holder) {
    return 'държана от $holder';
  }

  @override
  String watchRevertedTo(String status) {
    return 'върната в $status';
  }

  @override
  String watchChanged(String fields) {
    return 'промени $fields';
  }

  @override
  String get watchRestored => 'възстановена';

  @override
  String get watchCommentDeleted => 'изтрит коментар';

  @override
  String get watchLeaseRenewed => 'наемът е подновен';

  @override
  String watchTagRemoved(String tag) {
    return 'премахнат етикет: $tag';
  }

  @override
  String watchDependencyRemoved(String ref) {
    return 'премахната зависимост: $ref';
  }

  @override
  String watchSyncedFrom(String system) {
    return 'синхронизирано от $system';
  }

  @override
  String get settingsUpdates => 'Обновления';

  @override
  String get settingsUpdatesHelp =>
      'tix търси нови версии в GitHub. Обновленията се проверяват преди инсталиране: изтеглянето трябва да съвпада с подписаните контролни суми на версията.';

  @override
  String get settingsUpdateCheck => 'Проверявай за обновления';

  @override
  String get settingsUpdateCheckHelp =>
      'При стартиране на tix и на всеки няколко часа.';

  @override
  String get settingsUpdateAuto => 'Инсталирай обновленията автоматично';

  @override
  String get settingsUpdateAutoHelp =>
      'Изтегленото обновление се инсталира, когато излезете от tix.';

  @override
  String get updateCheckNow => 'Провери сега';

  @override
  String get updateIdle => 'Още не е проверено.';

  @override
  String get updateChecking => 'Проверка за обновления…';

  @override
  String updateCurrent(String version) {
    return 'tix $version е най-новата версия.';
  }

  @override
  String updateAvailable(String version) {
    return 'Налично обновление: tix $version';
  }

  @override
  String get updateAvailableHelp => 'Изтеглете го от страницата на версията.';

  @override
  String updateDownloading(String version, int percent) {
    return 'Изтегляне на tix $version… $percent%';
  }

  @override
  String updateReady(String version) {
    return 'tix $version е готов за инсталиране.';
  }

  @override
  String get updateReadyAuto =>
      'Инсталира се, когато излезете от tix, или веднага с рестарт.';

  @override
  String get updateRestart => 'Рестартирай за обновяване';

  @override
  String get updateDownload => 'Изтегли';

  @override
  String get updateWhatsNew => 'Какво ново';

  @override
  String get updateFailedNetwork =>
      'Няма връзка с GitHub за проверка на обновленията.';

  @override
  String get updateFailedVerify =>
      'Обновлението не можа да бъде проверено, затова не е инсталирано.';

  @override
  String get updateFailedInstall => 'Обновлението не можа да бъде инсталирано.';

  @override
  String get updateNoAsset => 'Във версията няма файл за тази система.';

  @override
  String trayUpdateAvailable(String version) {
    return 'Налично обновление ($version)';
  }

  @override
  String trayRestartToUpdate(String version) {
    return 'Рестартирай за обновяване ($version)';
  }

  @override
  String get trayWatch => 'Активност';

  @override
  String watchVia(String channel) {
    return 'през $channel';
  }

  @override
  String watchViaNamed(String channel, String name) {
    return 'през $channel ($name)';
  }

  @override
  String viaToken(String name) {
    return 'с токен $name';
  }

  @override
  String viaChannelToken(String channel, String name) {
    return 'през $channel (токен $name)';
  }

  @override
  String get watchChannelWeb => 'уеб';

  @override
  String get watchChannelApi => 'API';

  @override
  String get watchChannelCli => 'CLI';

  @override
  String get watchChannelSsh => 'SSH';

  @override
  String get watchChannelMcp => 'MCP';

  @override
  String get watchChannelSync => 'синхронизация';

  @override
  String get watchChannelImport => 'импорт';

  @override
  String get watchChannelSystem => 'системата';

  @override
  String get watchChannelUnknown => 'неизвестен канал';

  @override
  String get watchFieldTitle => 'заглавие';

  @override
  String get watchFieldBody => 'описание';

  @override
  String get watchFieldPriority => 'приоритет';

  @override
  String get watchFieldAssignee => 'отговорник';

  @override
  String get watchFieldTags => 'етикети';

  @override
  String get watchFieldDue => 'краен срок';

  @override
  String get watchFieldRecurrence => 'правило за повторение';

  @override
  String get watchFieldCustom => 'потребителски полета';

  @override
  String get watchFieldParent => 'родителска задача';

  @override
  String get watchCommentEdited => 'редактиран';

  @override
  String watchCommentBy(String author, String text) {
    return '$author: $text';
  }

  @override
  String get boardPriorityTo => 'Приоритет…';

  @override
  String get boardDueTo => 'Краен срок…';

  @override
  String get boardTagAdd => 'Добави етикет…';

  @override
  String boardPrioritySet(String ref) {
    return 'Приоритетът на $ref е променен';
  }

  @override
  String boardDueSet(String ref) {
    return 'Крайният срок на $ref е зададен';
  }

  @override
  String boardDueCleared(String ref) {
    return 'Крайният срок на $ref е премахнат';
  }

  @override
  String boardTagged(String ref, String tag) {
    return '$ref получи етикет $tag';
  }

  @override
  String get sidebarCollapse => 'Свий страничната лента';

  @override
  String get sidebarExpand => 'Разгъни страничната лента';

  @override
  String get sidebarResize => 'Преоразмери страничната лента';

  @override
  String get paneCollapsed => 'Свита';

  @override
  String get paneResizeHint =>
      'Плъзнете или използвайте стрелките. Enter или двойно щракване връща ширината.';

  @override
  String get taskPanelClose => 'Затвори задачата';

  @override
  String get taskPanelResize => 'Преоразмери панела на задачата';

  @override
  String get keysNextRow => 'Следващ ред';

  @override
  String get keysPreviousRow => 'Предишен ред';

  @override
  String get keysFirstRow => 'Първи ред';

  @override
  String get keysLastRow => 'Последен ред';

  @override
  String get keysPageDown => 'Страница надолу';

  @override
  String get keysPageUp => 'Страница нагоре';

  @override
  String get keysOpenRow => 'Отвори избрания ред';

  @override
  String get keysBack => 'Назад';

  @override
  String get keysLeaveField => 'Излез от текстовото поле';

  @override
  String get keysFirstTask => 'Първа задача';

  @override
  String get keysLastTask => 'Последна задача';

  @override
  String get settingsKeyboard => 'Клавиатура';

  @override
  String get settingsKeyboardHelp =>
      'За физическа клавиатура, на всяко устройство. Клавишите, въведени в текстово поле, винаги остават в полето.';

  @override
  String get settingsShortcutsHelp =>
      'Изключено спира всички клавишни комбинации, включително Ctrl K за палитрата. Tab, Enter и Esc продължават да работят.';

  @override
  String get settingsKeymap => 'Подредба на клавишите';

  @override
  String get keymapDefault => 'По подразбиране';

  @override
  String get keymapVim => 'Vim';

  @override
  String get keymapEmacs => 'Emacs';

  @override
  String get keymapOff => 'Изключено';

  @override
  String get keymapDefaultHelp =>
      'Клавишите, общи с tix web: j и k местят, g i отваря Входящи, d отбелязва готово, Ctrl 1 до 7 сменят раздела.';

  @override
  String get keymapVimHelp =>
      'Рефлекси от Vim: gg и G прескачат, o добавя, i преименува, dd изтрива след потвърждение, h връща назад.';

  @override
  String get keymapEmacsHelp =>
      'Рефлекси от Emacs извън текстовите полета: C-n и C-p местят, C-s филтрира, C-g отказва, M-x отваря палитрата.';

  @override
  String get keymapOffHelp =>
      'Нито един самостоятелен клавиш не прави нищо. Комбинациите с Ctrl, Alt или ⌘ продължават да работят.';

  @override
  String get settingsKeyBindings => 'Активни клавиши';

  @override
  String get settingsKeyBindingsOff => 'Клавишните комбинации са изключени.';

  @override
  String get keyGroupNavigate => 'Навигация';

  @override
  String get keyGroupLists => 'Списъци';

  @override
  String get keyGroupTask => 'Задача';

  @override
  String get keyGroupGeneral => 'Общи';

  @override
  String get keyHelpPalette => 'Отваряне на палитрата с команди';

  @override
  String get keyHelpHelp => 'Показване на тази помощ';

  @override
  String get keyHelpGoInbox => 'Към входящите';

  @override
  String get keyHelpGoMyWork => 'Към Моята работа';

  @override
  String get keyHelpGoTasks => 'Към Задачи';

  @override
  String get keyHelpGoProjects => 'Към Проекти';

  @override
  String get keyHelpGoActivity => 'Към Активност';

  @override
  String get keyHelpGoManage => 'Към Управление';

  @override
  String get keyHelpGoSettings => 'Към Настройки';

  @override
  String get keyHelpNext => 'Избор надолу';

  @override
  String get keyHelpPrevious => 'Избор нагоре';

  @override
  String get keyHelpFirst => 'Към първата задача';

  @override
  String get keyHelpLast => 'Към последната задача';

  @override
  String get keyHelpPageDown => 'Страница надолу';

  @override
  String get keyHelpPageUp => 'Страница нагоре';

  @override
  String get keyHelpOpen => 'Отваряне на избраната задача';

  @override
  String get keyHelpBack => 'Назад';

  @override
  String get keyHelpSelect => 'Избиране или отказ на задачата на фокус';

  @override
  String get keyHelpExtendDown => 'Разширяване на избора надолу';

  @override
  String get keyHelpExtendUp => 'Разширяване на избора нагоре';

  @override
  String get keyHelpSelectAll => 'Избиране на всички задачи в списъка';

  @override
  String get keyHelpClear => 'Изчистване на избора';

  @override
  String get keyHelpFilter => 'Фокус върху полето за филтър';

  @override
  String get keyHelpRefresh => 'Опресняване';

  @override
  String get keyHelpView => 'Смяна на изгледа';

  @override
  String get keyHelpNew => 'Нова задача';

  @override
  String get keyHelpDone => 'Отбелязване като готова';

  @override
  String get keyHelpRename => 'Редактиране на заглавието';

  @override
  String get keyHelpDescribe => 'Редактиране на описанието';

  @override
  String get keyHelpMove => 'Преместване в друг статус';

  @override
  String get keyHelpComment => 'Коментар';

  @override
  String get keyHelpTag => 'Добавяне на етикет';

  @override
  String get keyHelpStar => 'Със звезда или без';

  @override
  String get keyHelpPriority => 'Задаване на приоритет';

  @override
  String get keyHelpAssign => 'Възлагане';

  @override
  String get keyHelpDue => 'Задаване на срок';

  @override
  String get keyHelpSnooze => 'Отлагане или връщане';

  @override
  String get keyHelpCopyRef => 'Копиране на референцията';

  @override
  String get keyHelpDelete => 'Изтриване';

  @override
  String get taskHandoff => 'Предай на агент';

  @override
  String get taskHandoffNote =>
      'Агентът трябва първо да е свързан с tix: чрез tix CLI или MCP инструментите на tix, със собствен токен. Нищо тук не съдържа токен. Настройка: docs/agents.md';

  @override
  String get taskHandoffPrompt => 'Подкана';

  @override
  String get taskHandoffClient => 'Стартирай го от своя клиент';

  @override
  String get taskHandoffRunHere =>
      'Изпълнете това в хранилището, в което е работата. Кавичките са за sh, bash и zsh.';

  @override
  String taskHandoffPasteInto(String client) {
    return '$client няма команда, която да го стартира с подкана. Поставете това в чата му; то използва MCP инструментите на tix:';
  }

  @override
  String get taskHandoffMcp => 'С MCP инструментите на tix';

  @override
  String get taskHandoffKeywords =>
      'агент ии подкана делегирай agent ai claude codex prompt mcp';

  @override
  String get taskShare => 'Сподели';

  @override
  String taskShareTitle(String ref) {
    return 'Сподели $ref';
  }

  @override
  String get taskShareNative => 'Сподели…';

  @override
  String get taskShareCopyLink => 'Копирай връзката';

  @override
  String get taskShareCopyMarkdown => 'Копирай като Markdown';

  @override
  String get taskShareCopyText => 'Копирай ключа и заглавието';

  @override
  String get taskShareLinkCopied => 'Връзката е копирана';

  @override
  String get taskShareMarkdownCopied => 'Markdown връзката е копирана';

  @override
  String get taskShareTextCopied => 'Ключът и заглавието са копирани';

  @override
  String get taskShareKeywords =>
      'сподели връзка адрес копирай share link url markdown';

  @override
  String get taskDetailHistoryRaw => 'Сурови данни';

  @override
  String get taskDetailHistoryRawTitle => 'Сурови данни за записа';

  @override
  String get taskDetailHistoryCopyAll => 'Копирай всичко като JSON';

  @override
  String get taskDetailHistoryCopyTip => 'Копирай този запис като JSON';

  @override
  String get taskDetailReactionAdd => 'Добави реакция';

  @override
  String get taskDetailReactionPick => 'Реагирай';

  @override
  String taskDetailReactionLabel(String emoji, String count) {
    return 'Реакция $emoji, $count';
  }

  @override
  String taskDetailReactionWho(String emoji) {
    return 'Реагирали с $emoji';
  }

  @override
  String taskDetailReactionLabelMine(String emoji, String count) {
    return 'Реакция $emoji, $count, реагирали сте';
  }

  @override
  String get taskDetailReactionUnsupported =>
      'Този сървър не поддържа реакции.';

  @override
  String get taskDetailReactionOther => 'Друго емоджи';

  @override
  String get taskDetailReactionOtherHelp =>
      'Напишете или поставете едно емоджи.';

  @override
  String get taskDetailReactionOneEmoji => 'Въведете само едно емоджи.';

  @override
  String get rowHeld => 'поета';

  @override
  String rowHeldBy(String holder) {
    return 'поета · $holder';
  }

  @override
  String rowHeldTip(String holder) {
    return 'Заета от $holder';
  }

  @override
  String rowHeldUntil(String holder, String time) {
    return 'Заета от $holder до $time';
  }

  @override
  String get rowClaimSomeone => 'някой';

  @override
  String get rowClaimExpired => 'поемането изтече';

  @override
  String rowAgo(String span) {
    return 'преди $span';
  }

  @override
  String rowClaims(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count поемания',
      one: '1 поемане',
    );
    return '$_temp0';
  }

  @override
  String rowClaimExpiredTip(String holder, String span, String time) {
    return '$holder остави поемането да изтече преди $span, в $time; задачата отново може да бъде поета';
  }

  @override
  String rowRepeats(String rule) {
    return 'Повтаря се $rule';
  }

  @override
  String rowChecklist(int done, int total) {
    return '$done от $total точки от списъка са отметнати';
  }

  @override
  String rowWaitingOn(String ref) {
    return 'чака $ref';
  }

  @override
  String rowWaitingOnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'чака $count задачи',
      one: 'чака 1 задача',
    );
    return '$_temp0';
  }

  @override
  String rowWaitingTip(String refs) {
    return 'Чака $refs';
  }
}
