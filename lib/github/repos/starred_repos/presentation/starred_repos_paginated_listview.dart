import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/repo_tile.dart';

class StarredReposPaginatedListView extends StatelessWidget {
  const StarredReposPaginatedListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(starredRepoNotifierProvider);
        return ListView.builder(
          itemBuilder: (context, index) {
            return state.map(
              initial: (_) => Container(child: const Text("Init")),
              loadInProgress: (_) => Container(child: const Text("Loading")),
              loadSuccess: (_) =>
                  RepoTile(githubRepo: state.repos.entity[index]),
              loadFailure: (_) => Container(child: const Text("fail")),
            );
          },
          itemCount: state.map(
            initial: (_) => 0,
            loadInProgress: (_) => _.repos.entity.length + _.itemsPerpage,
            loadSuccess: (_) => _.repos.entity.length,
            loadFailure: (_) => _.repos.entity.length + 1,
          ),
        );
      },
    );
  }
}
