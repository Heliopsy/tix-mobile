// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'webhooks.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tenant's webhook endpoints: the cached list at once, then the
/// server's.

@ProviderFor(WebhookEndpoints)
final webhookEndpointsProvider = WebhookEndpointsProvider._();

/// The tenant's webhook endpoints: the cached list at once, then the
/// server's.
final class WebhookEndpointsProvider
    extends $AsyncNotifierProvider<WebhookEndpoints, List<WebhookEndpoint>> {
  /// The tenant's webhook endpoints: the cached list at once, then the
  /// server's.
  WebhookEndpointsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webhookEndpointsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webhookEndpointsHash();

  @$internal
  @override
  WebhookEndpoints create() => WebhookEndpoints();
}

String _$webhookEndpointsHash() => r'19440ed84a43d434bdc40035dd9ab0c7ece59858';

/// The tenant's webhook endpoints: the cached list at once, then the
/// server's.

abstract class _$WebhookEndpoints
    extends $AsyncNotifier<List<WebhookEndpoint>> {
  FutureOr<List<WebhookEndpoint>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<WebhookEndpoint>>, List<WebhookEndpoint>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<WebhookEndpoint>>,
                List<WebhookEndpoint>
              >,
              AsyncValue<List<WebhookEndpoint>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The delivery log, newest first, for [endpointId] (empty for every
/// endpoint) in [status] (empty for any), a page at a time; it reloads as
/// deliveries are made.

@ProviderFor(WebhookDeliveries)
final webhookDeliveriesProvider = WebhookDeliveriesFamily._();

/// The delivery log, newest first, for [endpointId] (empty for every
/// endpoint) in [status] (empty for any), a page at a time; it reloads as
/// deliveries are made.
final class WebhookDeliveriesProvider
    extends $AsyncNotifierProvider<WebhookDeliveries, Paged<WebhookDelivery>> {
  /// The delivery log, newest first, for [endpointId] (empty for every
  /// endpoint) in [status] (empty for any), a page at a time; it reloads as
  /// deliveries are made.
  WebhookDeliveriesProvider._({
    required WebhookDeliveriesFamily super.from,
    required ({String endpointId, String status}) super.argument,
  }) : super(
         retry: null,
         name: r'webhookDeliveriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$webhookDeliveriesHash();

  @override
  String toString() {
    return r'webhookDeliveriesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  WebhookDeliveries create() => WebhookDeliveries();

  @override
  bool operator ==(Object other) {
    return other is WebhookDeliveriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$webhookDeliveriesHash() => r'9cd6371fe597091fc44f24f1047163b842ac4ca0';

/// The delivery log, newest first, for [endpointId] (empty for every
/// endpoint) in [status] (empty for any), a page at a time; it reloads as
/// deliveries are made.

final class WebhookDeliveriesFamily extends $Family
    with
        $ClassFamilyOverride<
          WebhookDeliveries,
          AsyncValue<Paged<WebhookDelivery>>,
          Paged<WebhookDelivery>,
          FutureOr<Paged<WebhookDelivery>>,
          ({String endpointId, String status})
        > {
  WebhookDeliveriesFamily._()
    : super(
        retry: null,
        name: r'webhookDeliveriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The delivery log, newest first, for [endpointId] (empty for every
  /// endpoint) in [status] (empty for any), a page at a time; it reloads as
  /// deliveries are made.

  WebhookDeliveriesProvider call({
    String endpointId = '',
    String status = '',
  }) => WebhookDeliveriesProvider._(
    argument: (endpointId: endpointId, status: status),
    from: this,
  );

  @override
  String toString() => r'webhookDeliveriesProvider';
}

/// The delivery log, newest first, for [endpointId] (empty for every
/// endpoint) in [status] (empty for any), a page at a time; it reloads as
/// deliveries are made.

abstract class _$WebhookDeliveries
    extends $AsyncNotifier<Paged<WebhookDelivery>> {
  late final _$args = ref.$arg as ({String endpointId, String status});
  String get endpointId => _$args.endpointId;
  String get status => _$args.status;

  FutureOr<Paged<WebhookDelivery>> build({
    String endpointId = '',
    String status = '',
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<Paged<WebhookDelivery>>, Paged<WebhookDelivery>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Paged<WebhookDelivery>>,
                Paged<WebhookDelivery>
              >,
              AsyncValue<Paged<WebhookDelivery>>,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(endpointId: _$args.endpointId, status: _$args.status),
    );
  }
}
