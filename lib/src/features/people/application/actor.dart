// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/repositories/actor_repository.dart';

export 'package:tix_mobile/src/data/repositories/actor_repository.dart';

part 'actor.g.dart';

/// One actor's page, for the active session.
@riverpod
ActorRepository actorRepository(Ref ref) =>
    ActorRepository(ref.watch(sessionApiProvider));

/// The actor [ref] names, an id or a handle.
@riverpod
Future<Actor> actorProfile(Ref ref, String actorRef) {
  refreshOn(ref, EventTopics.people);
  return ref.watch(actorRepositoryProvider).actor(actorRef);
}

/// The first tasks assigned to the actor [actorId].
@riverpod
Future<Page<Task>> actorTasks(Ref ref, String actorId) {
  refreshOn(ref, EventTopics.tasks);
  return ref.watch(actorRepositoryProvider).tasks(actorId);
}

/// The API tokens of the actor [actorId], newest first.
@riverpod
Future<List<APIToken>> actorTokens(Ref ref, String actorId) async {
  refreshOn(ref, EventTopics.tokens);
  final list = await ref.watch(actorRepositoryProvider).tokens(actorId);
  return [...list]..sort(
    (a, b) =>
        (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
  );
}

/// The SSH keys enrolled for the actor [actorId].
@riverpod
Future<List<SSHKey>> actorKeys(Ref ref, String actorId) =>
    ref.watch(actorRepositoryProvider).sshKeys(actorId);

/// The newest audit entries the actor [actorId] made.
@riverpod
Future<List<AuditEntry>> actorRecent(Ref ref, String actorId) =>
    ref.watch(actorRepositoryProvider).recent(actorId);
