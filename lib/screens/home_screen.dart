import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/data_service.dart';
import '../utils/formatters.dart';
import '../widgets/vote_button.dart';
import '../utils/dialog_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _sortBy = 'newest';

  @override
  Widget build(BuildContext context) {
    final isModeratorMode = ref.watch(appDataProvider.select((data) => data.isModeratorMode));
    final isLoading = ref.watch(appDataProvider.select((data) => data.isLoading));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Greddit Lite'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (String value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'newest',
                child: Text('Newest'),
              ),
              const PopupMenuItem<String>(
                value: 'top',
                child: Text('Top'),
              ),
              const PopupMenuItem<String>(
                value: 'controversial',
                child: Text('Controversial'),
              ),
            ],
          ),
          Switch(
            value: isModeratorMode,
            onChanged: (bool value) {
              ref.read(appDataProvider.notifier).toggleModeratorMode();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.refresh(appDataProvider);
              },
              child: _buildPostsList(),
            ),
    );
  }

  Widget _buildPostsList() {
    final posts = ref.watch(sortedPostsProvider(_sortBy));
    final isModeratorMode = ref.watch(appDataProvider.select((data) => data.isModeratorMode));

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            const Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final isBanned = ref.watch(isPostBannedProvider(post));
        
        return Card(
          child: Stack( 
            children: [
              Opacity(
                opacity: isModeratorMode && isBanned ? 0.5 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPostHeader(post, isBanned, isModeratorMode),
                      const SizedBox(height: 8),
                      _buildPostContent(post),
                      const SizedBox(height: 12),
                      _buildPostActions(post),
                    ],
                  ),
                ),
              ),
              if (isModeratorMode)
                Positioned(
                  top: 4, 
                  right: 4, 
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                    onPressed: () {
                      DialogUtils.showDeleteConfirmationDialog(
                        context: context,
                        title: 'Delete Post',
                        content: 'Are you sure you want to delete this post?',
                        onConfirm: () async {
                          final messenger = ScaffoldMessenger.of(this.context);
                          await ref.read(appDataProvider.notifier).deletePost(post.id);
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Post deleted')),
                            );
                          }
                        },
                      );
                    },
                    tooltip: 'Delete Post',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostHeader(Post post, bool isBanned, bool isModeratorMode) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    post.subGreddiitName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'u/${post.authorName}',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppFormatters.formatTime(post.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (isModeratorMode && isBanned)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'CONTAINS BANNED WORDS',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(Post post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          post.body,
          style: const TextStyle(fontSize: 14),
        ),
        if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
               border: Border.all(color: Colors.grey[700]!, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(post.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.grey[500], size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Image not found',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPostActions(Post post) {
    return Row(
      children: [
        VoteButton(
          icon: Icons.arrow_upward,
          count: post.upvotes,
          isSelected: post.isUpvoted,
          onTap: () => _handleUpvote(post.id),
          selectedColor: Theme.of(context).colorScheme.secondary,
          defaultColor: Colors.grey,
        ),
        const SizedBox(width: 8),
        VoteButton(
          icon: Icons.arrow_downward,
          count: post.downvotes,
          isSelected: post.isDownvoted,
          onTap: () => _handleDownvote(post.id),
          selectedColor: Theme.of(context).colorScheme.primary,
          defaultColor: Colors.grey,
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Icon(Icons.comment, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              '${post.commentCount}',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
        const Spacer(),
        Text(
          '${post.netVotes} votes',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }


  void _handleUpvote(String postId) async {
    await ref.read(appDataProvider.notifier).upvotePost(postId);
  }

  void _handleDownvote(String postId) async {
    await ref.read(appDataProvider.notifier).downvotePost(postId);
  }

}