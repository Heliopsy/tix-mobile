// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
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
    this.header,
    this.padding = EdgeInsets.zero,
    this.controller,
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

  /// Shown when there are no rows, usually an [EmptyState].
  final Widget empty;

  /// Scrolls with the rows above the first one, such as a filter bar.
  final Widget? header;

  /// Space round the rows; leave room for a floating button at the end.
  final EdgeInsets padding;

  /// Scrolls the rows, for a caller that reads or moves the position.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final items = paged.items;
    final footer = paged.hasMore || paged.moreError != null;
    final header = this.header;
    final lead = header == null ? 0 : 1;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? LayoutBuilder(
              builder: (context, box) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  ?header,
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: box.maxHeight * 0.8),
                    child: empty,
                  ),
                ],
              ),
            )
          : ListView.builder(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding,
              itemCount: lead + items.length + (footer ? 1 : 0),
              itemBuilder: (context, i) {
                if (i < lead) return header;
                final at = i - lead;
                if (at >= items.length) {
                  return _PageFooter(
                    error: paged.moreError,
                    onRetry: onLoadMore,
                  );
                }
                if (at >= items.length - prefetchRows &&
                    paged.hasMore &&
                    !paged.loadingMore &&
                    paged.moreError == null) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => onLoadMore(),
                  );
                }
                return itemBuilder(context, items[at]);
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
        padding: EdgeInsets.all(TixSpace.s4),
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final l10n = context.l10n;
    final t = context.tix;
    return Padding(
      padding: const EdgeInsets.all(TixSpace.s4),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: t.danger, size: 18),
          const SizedBox(width: TixSpace.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.loadMoreFailed),
                Text(
                  errorMessage(l10n, error),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TixButton(
            label: l10n.retry,
            size: TixButtonSize.small,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
