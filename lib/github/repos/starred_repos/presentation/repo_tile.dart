import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';

class RepoTile extends StatelessWidget {
  final GithubRepo githubRepo;
  const RepoTile({
    Key? key,
    required this.githubRepo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: CachedNetworkImageProvider(githubRepo.owner.avatarUrl),
      ),
      title: Text(githubRepo.fullName),
      subtitle: Text(
        githubRepo.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
