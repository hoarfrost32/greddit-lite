import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/subgreddiit.dart';
import '../services/data_service.dart';
import '../widgets/post_card.dart';
import '../utils/formatters.dart';

class SubGreddiitListScreen extends ConsumerStatefulWidget {
  const SubGreddiitListScreen({super.key});

  @override
  ConsumerState<SubGreddiitListScreen> createState() => _SubGreddiitListScreenState();
}

class _SubGreddiitListScreenState extends ConsumerState<SubGreddiitListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputFillColor = Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardTheme.color;
    final hintColor = Theme.of(context).inputDecorationTheme.hintStyle?.color ?? Colors.grey[500];
    final inputTextColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final focusedBorderColor = Theme.of(context).inputDecorationTheme.focusedBorder?.borderSide.color ?? Theme.of(context).colorScheme.secondary;
    final isLoading = ref.watch(appDataProvider.select((data) => data.isLoading));

    return Scaffold(
      appBar: AppBar(
        title: const Text('SubGreddiits'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: inputTextColor),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search SubGreddiits...',
                hintStyle: TextStyle(color: hintColor),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Theme.of(context).iconTheme.color),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSubGreddiitsList(),
    );
  }

  Widget _buildSubGreddiitsList() {
    final subGreddiits = ref.watch(searchedSubGreddiitsProvider(_searchQuery));

    if (subGreddiits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.forum_outlined : Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No SubGreddiits available'
                  : 'No SubGreddiits found for "$_searchQuery"',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: subGreddiits.length,
      itemBuilder: (context, index) {
        final subGreddiit = subGreddiits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => _navigateToSubGreddiitPosts(subGreddiit),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subGreddiit.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subGreddiit.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _toggleJoin(subGreddiit.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: subGreddiit.isJoined
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          subGreddiit.isJoined ? 'Leave' : 'Join',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${AppFormatters.formatMemberCount(subGreddiit.memberCount)} members',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppFormatters.formatCreatedDate(subGreddiit.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (subGreddiit.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: subGreddiit.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  void _toggleJoin(String subGreddiitId) async {
    await ref.read(appDataProvider.notifier).toggleJoinSubGreddiit(subGreddiitId);
    final subGreddiit = ref.read(appDataProvider.notifier).getSubGreddiitById(subGreddiitId);
    if (subGreddiit != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            subGreddiit.isJoined
                ? 'Joined ${subGreddiit.name}'
                : 'Left ${subGreddiit.name}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToSubGreddiitPosts(SubGreddiit subGreddiit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubGreddiitPostsScreen(subGreddiitId: subGreddiit.id, subGreddiitName: subGreddiit.name),
      ),
    );
  }
}

class SubGreddiitPostsScreen extends ConsumerStatefulWidget {
  final String subGreddiitId;
  final String subGreddiitName;

  const SubGreddiitPostsScreen({
    super.key,
    required this.subGreddiitId,
    required this.subGreddiitName,
  });

  @override
  ConsumerState<SubGreddiitPostsScreen> createState() => _SubGreddiitPostsScreenState();
}

class _SubGreddiitPostsScreenState extends ConsumerState<SubGreddiitPostsScreen> {
  String _sortBy = 'newest';

  @override
  Widget build(BuildContext context) {
    final subGreddiit = ref.watch(appDataProvider.select(
        (data) => data.subGreddiits.firstWhere((s) => s.id == widget.subGreddiitId, orElse: () => SubGreddiit(id: '', name: 'Loading...', description: '', memberCount: 0, tags: [], createdAt: DateTime.now()))
    ));
    final isLoadingPosts = ref.watch(appDataProvider.select((data) => data.isLoading));

    if (subGreddiit.id.isEmpty && !isLoadingPosts) {
        return Scaffold(
            appBar: AppBar(title: Text(widget.subGreddiitName)),
            body: const Center(child: Text("SubGreddiit not found or error loading.")),
        );
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(subGreddiit.name),
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
        ],
      ),
      body: Column(
        children: [
          _buildSubGreddiitHeader(subGreddiit),
          Expanded(child: _buildPostsList(subGreddiit.id)),
        ],
      ),
    );
  }

  Widget _buildSubGreddiitHeader(SubGreddiit subGreddiit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subGreddiit.description,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${AppFormatters.formatMemberCount(subGreddiit.memberCount)} members',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _toggleJoin(subGreddiit.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: subGreddiit.isJoined
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  subGreddiit.isJoined ? 'Leave' : 'Join',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(String subGreddiitId) {
    final posts = ref.watch(postsBySubGreddiitProvider((subGreddiitId: subGreddiitId, sortBy: _sortBy)));

    if (posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.post_add,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No posts in this SubGreddiit yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to create a post!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
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
        return PostCard(
          post: posts[index],
          onVote: () => setState(() {}),
          onDelete: () => setState(() {}),
        );
      },
    );
  }


  void _toggleJoin(String subGreddiitId) async {
    await ref.read(appDataProvider.notifier).toggleJoinSubGreddiit(subGreddiitId);
    final updatedSubGreddiit = ref.read(appDataProvider.notifier).getSubGreddiitById(subGreddiitId);
    if (updatedSubGreddiit != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedSubGreddiit.isJoined
                ? 'Joined ${updatedSubGreddiit.name}'
                : 'Left ${updatedSubGreddiit.name}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}