import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:repo_viewer/core/presentation/routes/app_router.gr.dart';
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
      leading: Hero(
        tag: githubRepo.fullName,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: CachedNetworkImageProvider(
            githubRepo.owner.avatarUrl,
            cacheKey: githubRepo.owner.avatarUrl64,
          ),
        ),
      ),
      title: Text(githubRepo.fullName),
      subtitle: Text(
        githubRepo.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_border),
          const SizedBox(
            height: 4,
          ),
          Text(
            githubRepo.stargazersCount.toString(),
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      onTap: () {
        AutoRouter.of(context).push(RepoDetailRoute(githubRepo: githubRepo));
      },
    );
  }
}
