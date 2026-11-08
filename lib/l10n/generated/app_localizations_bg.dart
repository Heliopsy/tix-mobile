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
  String get connectAddTitle => 'Добавяне на сървър';

  @override
  String get connectIntro => 'Влезте с адреса на вашия tix сървър и API токен.';

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
  String get contextNameHelp =>
      'Показва се, когато превключвате между сървъри.';

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
  String get serversLabel => 'Сървъри';

  @override
  String get addServer => 'Добавяне на сървър';

  @override
  String get signOut => 'Изход';

  @override
  String signOutBody(String server) {
    return 'Токенът за $server ще бъде забравен на това устройство.';
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
      'Токенът не беше приет. Проверете го или създайте нов.';

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
}
