import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/core/presentation/routes/app_router.gr.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/core/presentation/repos_paginated_listview.dart';

class StarredReposPage extends ConsumerStatefulWidget {
  const StarredReposPage({Key? key}) : super(key: key);

  @override
  ConsumerState<StarredReposPage> createState() => _StarredReposPageState();
}

class _StarredReposPageState extends ConsumerState<StarredReposPage> {
  @override
  void initState() {
    super.initState();
    _waitInitStarredRepo();
  }

  void _waitInitStarredRepo() async {
    await Future.microtask(
      () => ref
          .read(starredRepoNotifierProvider.notifier)
          .getNextStarredReposPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("test"),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
            icon: const Icon(MdiIcons.logoutVariant),
          ),
          IconButton(
              onPressed: () {
                AutoRouter.of(context)
                    .push(SearchedReposRoute(searchTerm: 'flutter'));
              },
              icon: const Icon(
                MdiIcons.magnify,
              )),
        ],
      ),
      body: ReposPaginatedListView(
        paginatedRepoNotifierProvider: starredRepoNotifierProvider,
        getNextPage: (reference) => reference
            .read(starredRepoNotifierProvider.notifier)
            .getNextStarredReposPage(),
        noResultDisplay:
            "That's about everything we could find in your starred repos right now.",
      ),
    );
  }
}
