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
}
