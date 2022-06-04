import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/repos/core/presentation/repos_paginated_listview.dart';

class RepoTileFailure extends ConsumerWidget {
  final GithubFailure failure;
  const RepoTileFailure({
    Key? key,
    required this.failure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTileTheme(
      textColor: Theme.of(context).colorScheme.onError,
      iconColor: Theme.of(context).colorScheme.onError,
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        color: Theme.of(context).errorColor,
        child: ListTile(
          title: const Text('There is an error occured'),
          subtitle: Text('API returned code ${failure.errorCode}'),
          leading: const Icon(Icons.warning),
          trailing: IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: () {
              context
                  .findAncestorWidgetOfExactType<ReposPaginatedListView>()
                  ?.getNextPage(ref);
              // ref
              //     .read(starredRepoNotifierProvider.notifier)
              //     .getNextStarredReposPage();
            },
          ),
        ),
      ),
    );
  }
}
