import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/post.dart';
import '../models/subgreddiit.dart';

class AppData {
  final List<SubGreddiit> subGreddiits;
  final List<Post> posts;
  final bool isModeratorMode;
  final bool isLoading;

  AppData({
    this.subGreddiits = const [],
    this.posts = const [],
    this.isModeratorMode = false,
    this.isLoading = true,
  });

  AppData copyWith({
    List<SubGreddiit>? subGreddiits,
    List<Post>? posts,
    bool? isModeratorMode,
    bool? isLoading,
  }) {
    return AppData(
      subGreddiits: subGreddiits ?? this.subGreddiits,
      posts: posts ?? this.posts,
      isModeratorMode: isModeratorMode ?? this.isModeratorMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AppDataNotifier extends StateNotifier<AppData> {
  final Uuid _uuid = const Uuid();
  final List<String> _bannedWords = ['spam', 'stupid', 'ads', 'fake', 'scam'];
  SharedPreferences? _prefs;

  AppDataNotifier() : super(AppData()) {
    _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
    if (state.subGreddiits.isEmpty && state.posts.isEmpty) {
      _createSampleData();
      await _saveData();
    }
    state = state.copyWith(isLoading: false);
  }
  
  List<String> get bannedWords => _bannedWords;


  void _createSampleData() {
    List<SubGreddiit> sampleSubGreddiits = [
      SubGreddiit(
        id: _uuid.v4(),
        name: 'r/FlutterDev',
        description: 'Flutter development community',
        memberCount: 125000,
        tags: ['programming', 'flutter', 'dart'],
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      SubGreddiit(
        id: _uuid.v4(),
        name: 'r/Technology',
        description: 'Latest tech news and discussions',
        memberCount: 890000,
        tags: ['tech', 'news', 'innovation'],
        createdAt: DateTime.now().subtract(const Duration(days: 500)),
      ),
      SubGreddiit(
        id: _uuid.v4(),
        name: 'r/Programming',
        description: 'General programming discussions',
        memberCount: 450000,
        tags: ['programming', 'coding', 'software'],
        createdAt: DateTime.now().subtract(const Duration(days: 800)),
      ),
      SubGreddiit(
        id: _uuid.v4(),
        name: 'r/MobileApps',
        description: 'Mobile app development and reviews',
        memberCount: 78000,
        tags: ['mobile', 'apps', 'development'],
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      SubGreddiit(
        id: _uuid.v4(),
        name: 'r/TechNews',
        description: 'Breaking technology news',
        memberCount: 234000,
        tags: ['news', 'technology', 'updates'],
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
    ];

    final authors = ['TechGuru123', 'CodeMaster', 'FlutterFan', 'DevLife', 'AppBuilder', 'PixelPusher', 'DataDriven'];
    final random = Random();
    List<Post> samplePosts = [];
    
    for (int i = 0; i < 20; i++) {
      final subGreddiit = sampleSubGreddiits[random.nextInt(sampleSubGreddiits.length)];
      samplePosts.add(Post(
        id: _uuid.v4(),
        title: _generateSampleTitle(subGreddiit.name, i),
        body: _generateSampleBody(subGreddiit.name, i),
        authorName: authors[random.nextInt(authors.length)],
        subGreddiitId: subGreddiit.id,
        subGreddiitName: subGreddiit.name,
        createdAt: DateTime.now().subtract(Duration(hours: random.nextInt(72))),
        upvotes: random.nextInt(100),
        downvotes: random.nextInt(20),
        commentCount: random.nextInt(50),
      ));
    }
    state = state.copyWith(subGreddiits: sampleSubGreddiits, posts: samplePosts, isLoading: false);
  }

  String _generateSampleTitle(String subName, int index) {
    final titles = {
      'r/FlutterDev': ['Flutter 3.0 Performance Tips', 'State Management Best Practices', 'Building Responsive UIs', 'Animation Techniques in Flutter', 'Custom Widget Development'],
      'r/Technology': ['AI Revolution in 2024', 'Quantum Computing Breakthrough', 'Latest Smartphone Trends', 'Green Tech Innovations', 'Cybersecurity Updates'],
      'r/Programming': ['Clean Code Principles', 'Algorithm Optimization Tips', 'Design Pattern Examples', 'Code Review Best Practices', 'Debugging Strategies'],
      'r/MobileApps': ['Top Mobile Apps This Week', 'iOS vs Android Development', 'App Store Optimization', 'Mobile UX Trends', 'React Native vs Flutter'],
      'r/TechNews': ['Major Tech Company Updates', 'New Programming Languages', 'Startup Funding News', 'Tech Conference Highlights', 'Industry Analysis'],
    };
    final titleList = titles[subName] ?? ['Generic Tech Post', 'Programming Discussion', 'Development Update'];
    return titleList[index % titleList.length];
  }

  String _generateSampleBody(String subName, int index) {
    final bodies = [
      'This is an interesting discussion about the latest developments in technology. What are your thoughts on this topic?',
      'I\'ve been working on this project and wanted to share my experience with the community. Here are some insights.',
      'Just discovered this amazing technique that improved my workflow significantly. Hope it helps others too!',
      'Looking for advice on how to approach this challenge. Has anyone dealt with something similar?',
      'Sharing some resources that might be helpful for beginners in this field.',
    ];
    return bodies[index % bodies.length];
  }

  Future<void> _saveData() async {
    if (_prefs == null) return;
    final subGreddiitsJson = state.subGreddiits.map((s) => s.toJson()).toList();
    final postsJson = state.posts.map((p) => p.toJson()).toList();
    
    await _prefs!.setString('subGreddiits', jsonEncode(subGreddiitsJson));
    await _prefs!.setString('posts', jsonEncode(postsJson));
  }

  Future<void> _loadData() async {
    if (_prefs == null) return;
    
    final subGreddiitsString = _prefs!.getString('subGreddiits');
    List<SubGreddiit> loadedSubGreddiits = [];
    if (subGreddiitsString != null) {
      final subGreddiitsJson = jsonDecode(subGreddiitsString) as List;
      loadedSubGreddiits = subGreddiitsJson.map((json) => SubGreddiit.fromJson(json)).toList();
    }
    
    final postsString = _prefs!.getString('posts');
    List<Post> loadedPosts = [];
    if (postsString != null) {
      final postsJson = jsonDecode(postsString) as List;
      loadedPosts = postsJson.map((json) => Post.fromJson(json)).toList();
    }
    
    state = state.copyWith(
      subGreddiits: loadedSubGreddiits,
      posts: loadedPosts,
      isLoading: false
    );
  }


  Future<void> toggleJoinSubGreddiit(String subGreddiitId) async {
    final updatedSubGreddiits = state.subGreddiits.map((s) {
      if (s.id == subGreddiitId) {
        final newIsJoined = !s.isJoined;
        final newMemberCount = newIsJoined
            ? s.memberCount + 1
            : (s.memberCount > 0 ? s.memberCount - 1 : 0);
        return s.copyWith(
          isJoined: newIsJoined,
          memberCount: newMemberCount,
        );
      }
      return s;
    }).toList();
    state = state.copyWith(subGreddiits: updatedSubGreddiits);
    await _saveData();
  }

  SubGreddiit? getSubGreddiitById(String id) {
    try {
      return state.subGreddiits.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<SubGreddiit> getJoinedSubGreddiits() {
    return state.subGreddiits.where((s) => s.isJoined).toList();
  }

  Future<void> createPost({
    required String title,
    required String body,
    required String subGreddiitId,
    required String authorName,
    String? imagePath,
  }) async {
    final subGreddiit = state.subGreddiits.firstWhere((s) => s.id == subGreddiitId);
    final newPost = Post(
      id: _uuid.v4(),
      title: title,
      body: body,
      authorName: authorName,
      subGreddiitId: subGreddiitId,
      subGreddiitName: subGreddiit.name,
      createdAt: DateTime.now(),
      imagePath: imagePath,
    );
    state = state.copyWith(posts: [newPost, ...state.posts]);
    await _saveData();
  }
  
  Post? getPostById(String id) {
    try {
      return state.posts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> upvotePost(String postId) async {
    final updatedPosts = state.posts.map((p) {
      if (p.id == postId) {
        if (p.isUpvoted) {
          return p.copyWith(
            upvotes: p.upvotes - 1,
            isUpvoted: false,
          );
        } else {
          int newUpvotes = p.upvotes + 1;
          int newDownvotes = p.downvotes;
          if (p.isDownvoted) {
            newDownvotes = p.downvotes - 1;
          }
          return p.copyWith(
            upvotes: newUpvotes,
            downvotes: newDownvotes,
            isUpvoted: true,
            isDownvoted: false,
          );
        }
      }
      return p;
    }).toList();
    state = state.copyWith(posts: updatedPosts);
    await _saveData();
  }

  Future<void> downvotePost(String postId) async {
    final updatedPosts = state.posts.map((p) {
      if (p.id == postId) {
        if (p.isDownvoted) {
          return p.copyWith(
            downvotes: p.downvotes - 1,
            isDownvoted: false,
          );
        } else {
          int newDownvotes = p.downvotes + 1;
          int newUpvotes = p.upvotes;
          if (p.isUpvoted) {
            newUpvotes = p.upvotes - 1;
          }
          return p.copyWith(
            downvotes: newDownvotes,
            upvotes: newUpvotes,
            isDownvoted: true,
            isUpvoted: false,
          );
        }
      }
      return p;
    }).toList();
    state = state.copyWith(posts: updatedPosts);
    await _saveData();
  }

  void toggleModeratorMode() {
    state = state.copyWith(isModeratorMode: !state.isModeratorMode);
  }

  Future<void> deletePost(String postId) async {
    final updatedPosts = state.posts.where((p) => p.id != postId).toList();
    state = state.copyWith(posts: updatedPosts);
    await _saveData();
  }
}

final appDataProvider = StateNotifierProvider<AppDataNotifier, AppData>((ref) {
  return AppDataNotifier();
});


final sortedPostsProvider = Provider.family<List<Post>, String>((ref, sortBy) {
  final posts = ref.watch(appDataProvider.select((data) => data.posts));
  List<Post> sortedList = List.from(posts);
  switch (sortBy) {
    case 'newest':
      sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case 'top':
      sortedList.sort((a, b) => b.netVotes.compareTo(a.netVotes));
      break;
    case 'controversial':
      sortedList.sort((a, b) => (b.upvotes + b.downvotes).compareTo(a.upvotes + a.downvotes));
      break;
  }
  return sortedList;
});

final postsBySubGreddiitProvider = Provider.family<List<Post>, ({String subGreddiitId, String sortBy})>((ref, params) {
  final allPosts = ref.watch(appDataProvider.select((data) => data.posts));
  final subGreddiitPosts = allPosts.where((p) => p.subGreddiitId == params.subGreddiitId).toList();
  
  List<Post> sortedList = List.from(subGreddiitPosts);
  switch (params.sortBy) {
    case 'newest':
      sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case 'top':
      sortedList.sort((a, b) => b.netVotes.compareTo(a.netVotes));
      break;
    case 'controversial':
       sortedList.sort((a, b) => (b.upvotes + b.downvotes).compareTo(a.upvotes + a.downvotes));
      break;
  }
  return sortedList;
});


final searchedSubGreddiitsProvider = Provider.family<List<SubGreddiit>, String>((ref, query) {
  final subGreddiits = ref.watch(appDataProvider.select((data) => data.subGreddiits));
  if (query.isEmpty) return subGreddiits;
  return subGreddiits.where((s) => 
    s.name.toLowerCase().contains(query.toLowerCase()) ||
    s.description.toLowerCase().contains(query.toLowerCase()) ||
    s.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
  ).toList();
});

final isPostBannedProvider = Provider.family<bool, Post>((ref, post) {
  final bannedWords = ref.watch(appDataProvider.notifier).bannedWords;
  return post.containsBannedWords(bannedWords);
});