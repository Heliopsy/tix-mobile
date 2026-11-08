// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show
        GroupOrderInput,
        GroupPrefInput,
        SavedFilterInput,
        SavedFilterOrderInput,
        SavedFilterUpdate;
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/group_pref.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/saved_filter.dart';

/// The reader's own arrangements of views and their saved filters, both
/// kept on the server with their account and cached for a quick first draw.
class ViewPrefsRepository {
  /// Reads through [_api], keeping copies in [_cache].
  ViewPrefsRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;

  /// The arrangement of [view]: `board`, `lanes`, `mine` or `project:KEY`.
  Future<List<GroupPref>> groups(String view) async => (await _cache.remember(
    'view/$view',
    _api.view.groups(view),
    (p) => p.toJson((e) => e.toJson()),
  )).items;

  /// The arrangement of [view] as last read, null when never read.
  Future<List<GroupPref>?> cachedGroups(String view) async =>
      (await _cache.peek(
        'view/$view',
        (json) => Page.fromJson(
          json! as Map<String, dynamic>,
          (e) => GroupPref.fromJson(e! as Map<String, dynamic>),
        ),
      ))?.items;

  /// Changes one group of [view]; a null leaves that setting as it is.
  Future<GroupPref> setGroup(
    String view,
    String group, {
    bool? hidden,
    bool? collapsed,
    bool? starred,
  }) => _api.view.groupSet(
    view,
    group,
    GroupPrefInput(hidden: hidden, collapsed: collapsed, starred: starred),
  );

  /// Puts [groups] first in [view], in that order.
  Future<List<GroupPref>> order(String view, List<String> groups) async =>
      (await _api.view.order(view, GroupOrderInput(groups: groups))).items;

  /// Forgets the arrangement of [view].
  Future<void> reset(String view) => _api.view.reset(view);

  /// The reader's filters in their order, then shared ones by name.
  Future<List<SavedFilter>> filters() async => (await _cache.remember(
    'filters',
    _api.filter.list(),
    (p) => p.toJson((e) => e.toJson()),
  )).items;

  /// The filters as last read, null when never read.
  Future<List<SavedFilter>?> cachedFilters() async => (await _cache.peek(
    'filters',
    (json) => Page.fromJson(
      json! as Map<String, dynamic>,
      (e) => SavedFilter.fromJson(e! as Map<String, dynamic>),
    ),
  ))?.items;

  /// The filter [nameOrId] the reader can see, their own winning over a
  /// shared one of the same name (`filter.show`).
  Future<SavedFilter> filter(String nameOrId) => _api.filter.show(nameOrId);

  /// Saves a new filter.
  Future<SavedFilter> saveFilter({
    required String name,
    required String query,
    String sort = '',
    String view = '',
    bool shared = false,
  }) => _api.filter.save(
    SavedFilterInput(
      name: name,
      query: query,
      sort: sort,
      view: view,
      shared: shared,
    ),
  );

  /// Changes a filter; a null leaves that field as it is.
  Future<SavedFilter> updateFilter(String id, {String? name, bool? shared}) =>
      _api.filter.update(id, SavedFilterUpdate(name: name, shared: shared));

  /// Deletes a filter.
  Future<void> deleteFilter(String id) => _api.filter.delete(id);

  /// Puts the reader's own filters in [ids] order.
  Future<List<SavedFilter>> orderFilters(List<String> ids) async =>
      (await _api.filter.order(SavedFilterOrderInput(filters: ids))).items;
}
