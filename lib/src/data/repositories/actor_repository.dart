// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show APIToken, SSHKey;
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/integrations.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/task.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show APIToken, SSHKey;
export 'package:tix_mobile/src/data/models/actor.dart';
export 'package:tix_mobile/src/data/models/integrations.dart' show AuditEntry;
export 'package:tix_mobile/src/data/models/page.dart';
export 'package:tix_mobile/src/data/models/task.dart';

/// One person or agent of the tenant: who it is, its credentials and what it
/// did last, as tix's web actor screen reads them.
class ActorRepository {
  /// Reads through [_api].
  ActorRepository(this._api);

  final TixApi _api;

  /// How many audit entries the actor screen shows, as the web's.
  static const recentEntries = 20;

  /// The actor [ref] names, an id or a handle (`actor.show`).
  Future<Actor> actor(String ref) => _api.actor.show(ref);

  /// The first [recentEntries] tasks assigned to [actorId] (`task.list`).
  Future<Page<Task>> tasks(String actorId) =>
      _api.task.list(limit: recentEntries, assignee: [actorId]);

  /// The API tokens of [actorId], metadata only (`token.list`).
  Future<List<APIToken>> tokens(String actorId) async =>
      (await _api.token.list(actorId: actorId)).items;

  /// The SSH keys enrolled for [actorId], revoked ones included
  /// (`sshkey.list`).
  Future<List<SSHKey>> sshKeys(String actorId) async =>
      (await _api.sshkey.list(actorId: actorId)).items;

  /// The newest [recentEntries] audit entries [actorId] made (`audit.list`).
  Future<List<AuditEntry>> recent(String actorId) async =>
      (await _api.audit.list(
        limit: recentEntries,
        sort: 'seq',
        direction: 'desc',
        actorId: [actorId],
      )).items;
}
