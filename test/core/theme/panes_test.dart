// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/theme/panes.dart';

import '../../helpers/container.dart';
import '../../helpers/stores.dart';

void main() {
  late MemoryKeyValueStore store;

  setUp(() => store = MemoryKeyValueStore());

  Panes panes() =>
      makeContainer([keyValueStoreProvider.overrideWithValue(store)])
          .read(panesProvider.notifier);

  test('nothing stored follows the window', () {
    const sizes = PaneSizes();
    expect(sizes.collapsedIn(900), isTrue);
    expect(sizes.collapsedIn(1280), isFalse);
    expect(sizes.sidebarIn(1280), sidebarDefaultWidth);
    expect(sizes.detailIn(1200), detailDefaultWidth);
  });

  test('a stored width is drawn within what the window allows', () {
    const sizes = PaneSizes(sidebarWidth: 480, detailWidth: 720);
    expect(sizes.sidebarIn(1280), 480);
    expect(sizes.sidebarIn(700), 350);
    expect(sizes.sidebarIn(300), sidebarMinWidth);
    expect(sizes.detailIn(800), 480);
  });

  test('reads what an earlier run kept, ignoring damage', () {
    store.values
      ..['layout.sidebar.width'] = '300'
      ..['layout.sidebar.collapsed'] = '1'
      ..['layout.detail.width'] = 'wide';
    final sizes = makeContainer([
      keyValueStoreProvider.overrideWithValue(store),
    ]).read(panesProvider);
    expect(sizes, const PaneSizes(sidebarWidth: 300, sidebarCollapsed: true));
  });

  test('a width out of bounds is read clamped', () {
    store.values['layout.sidebar.width'] = '9000';
    final sizes = makeContainer([
      keyValueStoreProvider.overrideWithValue(store),
    ]).read(panesProvider);
    expect(sizes.sidebarWidth, sidebarMaxWidth);
  });

  test('a drag in progress is not written; its end is', () async {
    final p = panes();
    await p.resizeSidebar(300.4, save: false);
    expect(p.state.sidebarWidth, 300);
    expect(p.state.sidebarCollapsed, isFalse);
    expect(store.values, isEmpty);
    await p.resizeSidebar(310);
    expect(store.values, {
      'layout.sidebar.width': '310',
      'layout.sidebar.collapsed': '0',
    });
  });

  test('a reset forgets the width and expands', () async {
    store.values
      ..['layout.sidebar.width'] = '300'
      ..['layout.sidebar.collapsed'] = '1';
    final p = panes();
    await p.resizeSidebar(null);
    expect(p.state.sidebarWidth, isNull);
    expect(p.state.sidebarCollapsed, isFalse);
    expect(store.values, {'layout.sidebar.collapsed': '0'});
  });

  test('collapsing keeps the width', () async {
    store.values['layout.sidebar.width'] = '300';
    final p = panes();
    await p.collapseSidebar(collapsed: true);
    expect(p.state, const PaneSizes(sidebarWidth: 300, sidebarCollapsed: true));
    expect(store.values['layout.sidebar.collapsed'], '1');
    expect(store.values['layout.sidebar.width'], '300');
  });

  test('the task panel width is kept and reset on its own', () async {
    final p = panes();
    await p.resizeDetail(1000);
    expect(p.state.detailWidth, detailMaxWidth);
    expect(store.values, {'layout.detail.width': '720'});
    await p.resizeDetail(null);
    expect(p.state.detailWidth, isNull);
    expect(store.values, isEmpty);
  });
}
