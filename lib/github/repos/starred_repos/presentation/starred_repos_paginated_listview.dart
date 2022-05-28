import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/presentation/toast.dart';
import 'package:repo_viewer/github/core/presentation/no_results.dart';
import 'package:repo_viewer/github/repos/starred_repos/application/starred_repo_notifier.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/repo_tile_failure.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/repo_tile_loading.dart';

import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/repo_tile.dart';

class StarredReposPaginatedListView extends StatefulWidget {
  const StarredReposPaginatedListView({
    Key? key,
  }) : super(key: key);

  @override
  State<StarredReposPaginatedListView> createState() =>
      _StarredReposPaginatedListViewState();
}

class _StarredReposPaginatedListViewState
    extends State<StarredReposPaginatedListView> {
  bool _canLoadNextPage = false;
  final bool _isToastNoConnectionAlreadyShown = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.listen<StarredRepoState>(starredRepoNotifierProvider,
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
        final state = ref.watch(starredRepoNotifierProvider);
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            final limit =
                metrics.maxScrollExtent - metrics.viewportDimension / 3;
            if (_canLoadNextPage && metrics.pixels >= limit) {
              _canLoadNextPage = false;
              ref
                  .read(starredRepoNotifierProvider.notifier)
                  .getNextStarredReposPage();
            }

            return false;
          },
          child: state.maybeWhen(
                  loadSuccess: (repos, _) => repos.entity.isEmpty,
                  orElse: () => false)
              ? NoResultsDisplay(
                  message:
                      "That's about everything we could find in your starred repos right now.")
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

  final StarredRepoState state;

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
