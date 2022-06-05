import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:repo_viewer/search/shared/providers.dart';

class SearchBar extends ConsumerStatefulWidget {
  final String title;
  final String hint;
  final Widget body;
  final void Function(String searchTerm) onShouldNavigateToResultPage;
  final void Function() onSignOutButtonPressed;

  const SearchBar({
    Key? key,
    required this.title,
    required this.hint,
    required this.body,
    required this.onShouldNavigateToResultPage,
    required this.onSignOutButtonPressed,
  }) : super(key: key);

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  late FloatingSearchBarController _searchController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(searchHistoryNotifierProvider.notifier).watchSearchTerms());
    _searchController = FloatingSearchBarController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void pushPageAndAddSearchHistory(String searchTerm) {
      widget.onShouldNavigateToResultPage(_searchController.query);
      ref
          .read(searchHistoryNotifierProvider.notifier)
          .addSeachTerm(_searchController.query);
      _searchController.close();
    }

    void pushPageAndUpsertSearchHistory(String searchTerm) {
      widget.onShouldNavigateToResultPage(searchTerm);
      ref
          .read(searchHistoryNotifierProvider.notifier)
          .upsertSearchTerm(searchTerm);
      _searchController.close();
    }

    return FloatingSearchBar(
      builder: (context, transition) {
        return Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(6),
          clipBehavior: Clip.hardEdge,
          child: Consumer(
            builder: (context, ref, child) {
              final searchHistoryState =
                  ref.watch(searchHistoryNotifierProvider);
              return searchHistoryState.map(
                  data: (searchHistory) {
                    if (searchHistory.value.isEmpty &&
                        _searchController.query.isEmpty) {
                      return Container(
                        color: Theme.of(context).cardColor,
                        alignment: Alignment.center,
                        height: 56,
                        child: Text(
                          'Start searching',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      );
                    } else if (searchHistory.value.isEmpty) {
                      return ListTile(
                        leading: const Icon(Icons.search),
                        title: Text(_searchController.query),
                        onTap: () {
                          pushPageAndAddSearchHistory(_searchController.query);
                        },
                      );
                    }
                    return Column(
                      children: searchHistory.value
                          .map(
                            (searchTerm) => ListTile(
                              title: Text(
                                searchTerm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: const Icon(Icons.history),
                              trailing: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  ref
                                      .read(searchHistoryNotifierProvider
                                          .notifier)
                                      .deleteSeachTerm(searchTerm);
                                },
                              ),
                              onTap: () {
                                pushPageAndUpsertSearchHistory(searchTerm);
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                  error: (_) => const ListTile(
                        title: Text('Unexpected Error'),
                      ),
                  loading: (_) =>
                      const ListTile(title: LinearProgressIndicator()));
            },
          ),
        );
      },
      controller: _searchController,
      onSubmitted: (searchTerm) {
        pushPageAndAddSearchHistory(searchTerm);
      },
      onQueryChanged: ((searchTerm) {
        ref
            .read(searchHistoryNotifierProvider.notifier)
            .watchSearchTerms(searchTerm: searchTerm);
      }),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            'Tap to Search 👆',
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
        FloatingSearchBarAction(
          showIfClosed: true,
          child: IconButton(
            icon: const Icon(
              MdiIcons.logoutVariant,
            ),
            onPressed: () {
              widget.onSignOutButtonPressed;
            },
          ),
        )
      ],
      hint: widget.hint,
      body: widget.body,
    );
  }
}
