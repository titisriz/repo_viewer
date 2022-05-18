import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';

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
            return const Text("s");
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
