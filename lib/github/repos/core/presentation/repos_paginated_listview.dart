import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/presentation/toast.dart';
import 'package:repo_viewer/github/core/presentation/no_results.dart';
import 'package:repo_viewer/github/repos/core/application/paginated_repo_notifier.dart';
import 'package:repo_viewer/github/repos/core/presentation/repo_tile_failure.dart';
import 'package:repo_viewer/github/repos/core/presentation/repo_tile_loading.dart';

import 'package:repo_viewer/github/repos/core/presentation/repo_tile.dart';

class ReposPaginatedListView extends StatefulWidget {
  final StateNotifierProvider<PaginatedRepoNotifier, PaginatedRepoState>
      paginatedRepoNotifierProvider;
  final Future<void> Function(WidgetRef ref) getNextPage;
  final String noResultDisplay;

  const ReposPaginatedListView({
    required this.paginatedRepoNotifierProvider,
    required this.getNextPage,
    required this.noResultDisplay,
    Key? key,
  }) : super(key: key);

  @override
  State<ReposPaginatedListView> createState() => _ReposPaginatedListViewState();
}

class _ReposPaginatedListViewState extends State<ReposPaginatedListView> {
  bool _canLoadNextPage = false;
  final bool _isToastNoConnectionAlreadyShown = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.listen<PaginatedRepoState>(widget.paginatedRepoNotifierProvider,
            (previous, next) {
          next.map(
            initial: (_) => _canLoadNextPage = false,
            loadInProgress: (_) => _canLoadNextPage = false,
            loadSuccess: (_) {
              if (!_.repos.isFresh && !_isToastNoConnectionAlreadyShown) {
                showToast(
                    "You are not online, the information may be outdated.",
                    context);
              }
              _canLoadNextPage = _.repos.isNextPageAvailable ?? false;
            },
            loadFailure: (_) => _canLoadNextPage = false,
          );
        });
        final state = ref.watch(widget.paginatedRepoNotifierProvider);
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            final limit =
                metrics.maxScrollExtent - metrics.viewportDimension / 3;
            if (_canLoadNextPage && metrics.pixels >= limit) {
              _canLoadNextPage = false;
              widget.getNextPage(ref);
            }

            return false;
          },
          child: state.maybeWhen(
                  loadSuccess: (repos, _) => repos.entity.isEmpty,
                  orElse: () => false)
              ? NoResultsDisplay(message: widget.noResultDisplay)
              : _PaginatedListView(state: state),
        );
      },
    );
  }
}

class _PaginatedListView extends StatelessWidget {
  const _PaginatedListView({
    Key? key,
    required this.state,
  }) : super(key: key);

  final PaginatedRepoState state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.map(
        initial: (_) => 0,
        loadInProgress: (_) => _.repos.entity.length + _.itemsPerpage,
        loadSuccess: (_) => _.repos.entity.length,
        loadFailure: (_) => _.repos.entity.length + 1,
      ),
      itemBuilder: (context, index) {
        return state.map(
          initial: (_) => RepoTile(githubRepo: _.repos.entity[index]),
          loadInProgress: (_) {
            if (index < _.repos.entity.length) {
              return RepoTile(githubRepo: state.repos.entity[index]);
            }
            return const RepoTileLoading();
          },
          loadSuccess: (_) => RepoTile(githubRepo: state.repos.entity[index]),
          loadFailure: (_) => RepoTileFailure(failure: _.failure),
        );
      },
    );
  }
}
