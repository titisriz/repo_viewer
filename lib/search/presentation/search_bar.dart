import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(searchHistoryNotifierProvider.notifier).watchSearchTerms());
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      builder: (context, transition) {
        return Container();
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        // mainAxisSize: MainAxisSize.min,
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
      hint: widget.hint,
      body: widget.body,
    );
  }
}
