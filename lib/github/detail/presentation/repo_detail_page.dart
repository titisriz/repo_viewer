import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';

class RepoDetailPage extends ConsumerStatefulWidget {
  final GithubRepo githubRepo;

  const RepoDetailPage({
    Key? key,
    required this.githubRepo,
  }) : super(key: key);

  @override
  ConsumerState<RepoDetailPage> createState() => _RepoDetailPageState();
}

class _RepoDetailPageState extends ConsumerState<RepoDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          Hero(
            tag: widget.githubRepo.fullName,
            child: CircleAvatar(
              radius: 16,
              backgroundImage: CachedNetworkImageProvider(
                widget.githubRepo.owner.avatarUrl64,
                cacheKey: widget.githubRepo.owner.avatarUrl64,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(child: Text(widget.githubRepo.name))
        ],
      )),
    );
  }
}
