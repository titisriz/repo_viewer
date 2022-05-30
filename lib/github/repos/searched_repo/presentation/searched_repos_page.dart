import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/core/presentation/repos_paginated_listview.dart';

class SearchedReposPage extends ConsumerStatefulWidget {
  final String searchTerm;

  const SearchedReposPage({
    Key? key,
    required this.searchTerm,
  }) : super(key: key);

  @override
  ConsumerState<SearchedReposPage> createState() => _SearchedReposPageState();
}

class _SearchedReposPageState extends ConsumerState<SearchedReposPage> {
  @override
  void initState() {
    super.initState();
    _waitInitStateRepo();
  }

  void _waitInitStateRepo() async {
    await Future.microtask(
      () => ref
          .read(searchedRepoNotifierProvider.notifier)
          .getSearchedRepo(widget.searchTerm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.searchTerm),
        actions: [
          IconButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).signOut();
              },
              icon: const Icon(
                MdiIcons.logout,
              )),
        ],
      ),
      body: ReposPaginatedListView(
        paginatedRepoNotifierProvider: searchedRepoNotifierProvider,
        getNextPage: (ref) => ref
            .read(searchedRepoNotifierProvider.notifier)
            .getSearchedRepo(widget.searchTerm),
        noResultDisplay: 'That\'s all we could find for your search..',
      ),
    );
  }
}
