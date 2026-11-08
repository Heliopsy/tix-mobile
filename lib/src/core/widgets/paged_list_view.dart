// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';

/// A pull-to-refresh list over [Paged] rows that asks for the next page as
/// the end comes into view.
class PagedListView<T> extends StatelessWidget {
  /// Lists [paged] with [itemBuilder].
  const PagedListView({
    required this.paged,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.empty,
    super.key,
  });

  /// How close to the end, in rows, the next page is asked for.
  static const prefetchRows = 5;

  /// The rows loaded so far.
  final Paged<T> paged;

  /// Draws one row.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Reloads from the first page.
  final Future<void> Function() onRefresh;

  /// Fetches the next page.
  final VoidCallback onLoadMore;

  /// The text shown when there are no rows.
  final String empty;

  @override
  Widget build(BuildContext context) {
    final items = paged.items;
    final footer = paged.hasMore || paged.moreError != null;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Text(empty, textAlign: TextAlign.center),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length + (footer ? 1 : 0),
              itemBuilder: (context, i) {
                if (i >= items.length) {
                  return _PageFooter(
                    error: paged.moreError,
                    onRetry: onLoadMore,
                  );
                }
                if (i >= items.length - prefetchRows &&
                    paged.hasMore &&
                    !paged.loadingMore &&
                    paged.moreError == null) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => onLoadMore(),
                  );
                }
                return itemBuilder(context, items[i]);
              },
            ),
    );
  }
}

class _PageFooter extends StatelessWidget {
  const _PageFooter({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    if (error == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Icons.error_outline),
      title: Text(l10n.loadMoreFailed),
      subtitle: Text(errorMessage(l10n, error)),
      trailing: TextButton(onPressed: onRetry, child: Text(l10n.retry)),
    );
  }
}
