import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import './vote_button.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  final VoidCallback onVote;
  final VoidCallback onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.onVote,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8.0),
            Text(post.body),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    VoteButton(
                      icon: Icons.arrow_upward,
                      count: post.upvotes,
                      isSelected: post.isUpvoted,
                      onTap: onVote,
                      selectedColor: Colors.green,
                      defaultColor: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    VoteButton(
                      icon: Icons.arrow_downward,
                      count: post.downvotes,
                      isSelected: post.isDownvoted,
                      onTap: onVote,
                      selectedColor: Colors.red,
                      defaultColor: Colors.grey,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}