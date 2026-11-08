// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'channels.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The caller's own notification channels.

@ProviderFor(Channels)
final channelsProvider = ChannelsProvider._();

/// The caller's own notification channels.
final class ChannelsProvider
    extends $AsyncNotifierProvider<Channels, List<InboxChannel>> {
  /// The caller's own notification channels.
  ChannelsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'channelsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$channelsHash();

  @$internal
  @override
  Channels create() => Channels();
}

String _$channelsHash() => r'b95c438ee892bf90b9459f12da5941db15441130';

/// The caller's own notification channels.

abstract class _$Channels extends $AsyncNotifier<List<InboxChannel>> {
  FutureOr<List<InboxChannel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<InboxChannel>>, List<InboxChannel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<InboxChannel>>, List<InboxChannel>>,
              AsyncValue<List<InboxChannel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// One channel's deliveries, newest first, a page at a time.

@ProviderFor(ChannelDeliveries)
final channelDeliveriesProvider = ChannelDeliveriesFamily._();

/// One channel's deliveries, newest first, a page at a time.
final class ChannelDeliveriesProvider
    extends $AsyncNotifierProvider<ChannelDeliveries, Paged<ChannelDelivery>> {
  /// One channel's deliveries, newest first, a page at a time.
  ChannelDeliveriesProvider._({
    required ChannelDeliveriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'channelDeliveriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelDeliveriesHash();

  @override
  String toString() {
    return r'channelDeliveriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChannelDeliveries create() => ChannelDeliveries();

  @override
  bool operator ==(Object other) {
    return other is ChannelDeliveriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelDeliveriesHash() => r'a5471736bd4647ab9e289a0e0b26892e7eda1047';

/// One channel's deliveries, newest first, a page at a time.

final class ChannelDeliveriesFamily extends $Family
    with
        $ClassFamilyOverride<
          ChannelDeliveries,
          AsyncValue<Paged<ChannelDelivery>>,
          Paged<ChannelDelivery>,
          FutureOr<Paged<ChannelDelivery>>,
          String
        > {
  ChannelDeliveriesFamily._()
    : super(
        retry: null,
        name: r'channelDeliveriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One channel's deliveries, newest first, a page at a time.

  ChannelDeliveriesProvider call(String channelId) =>
      ChannelDeliveriesProvider._(argument: channelId, from: this);

  @override
  String toString() => r'channelDeliveriesProvider';
}

/// One channel's deliveries, newest first, a page at a time.

abstract class _$ChannelDeliveries
    extends $AsyncNotifier<Paged<ChannelDelivery>> {
  late final _$args = ref.$arg as String;
  String get channelId => _$args;

  FutureOr<Paged<ChannelDelivery>> build(String channelId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<Paged<ChannelDelivery>>, Paged<ChannelDelivery>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Paged<ChannelDelivery>>,
                Paged<ChannelDelivery>
              >,
              AsyncValue<Paged<ChannelDelivery>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
