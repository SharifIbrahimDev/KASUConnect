import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';
import '../services/mock_data_seed.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

final postsFeedProvider = StateNotifierProvider<PostsFeedNotifier, List<PostModel>>((ref) {
  final repo = ref.watch(postRepositoryProvider);
  return PostsFeedNotifier(repo);
});

final selectedPostCategoryProvider = StateProvider<String>((ref) => 'all');

class PostsFeedNotifier extends StateNotifier<List<PostModel>> {
  final PostRepository _repo;

  PostsFeedNotifier(this._repo) : super(_repo.getPosts()) {
    _repo.postsStream.listen((posts) {
      state = posts;
    });
  }

  void addPost({
    required UserModel author,
    required String content,
    required String category,
    String? mediaUrl,
  }) {
    _repo.createPost(
      author: author,
      content: content,
      category: category,
      mediaUrl: mediaUrl,
    );
    state = _repo.getPosts();
  }

  void toggleLike(String postId, String userId) {
    _repo.toggleLike(postId, userId);
    state = _repo.getPosts();
  }

  void addComment(String postId, UserModel author, String content) {
    _repo.addComment(postId, author, content);
    state = _repo.getPosts();
  }
}

class PostRepository {
  final List<PostModel> _posts = List.from(MockDataSeed.posts);
  final List<CommentModel> _comments = List.from(MockDataSeed.comments);
  final ValueNotifier<List<PostModel>> _postsNotifier = ValueNotifier([]);

  PostRepository() {
    _postsNotifier.value = List.unmodifiable(_posts);
  }

  Stream<List<PostModel>> get postsStream => Stream.periodic(
        const Duration(milliseconds: 500),
        (_) => List<PostModel>.unmodifiable(_posts),
      ).distinct();

  List<PostModel> getPosts({String category = 'all', String? department}) {
    var filtered = _posts.where((p) => true).toList();
    if (category != 'all') {
      filtered = filtered.where((p) => p.category == category).toList();
    }
    if (department != null && department.isNotEmpty && department != 'All Departments') {
      filtered = filtered.where((p) => p.authorDepartment == department).toList();
    }
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(filtered);
  }

  PostModel? getPostById(String id) {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void createPost({
    required UserModel author,
    required String content,
    required String category,
    String? mediaUrl,
  }) {
    final newPost = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: author.id,
      authorName: author.fullName,
      authorRole: author.role.name,
      authorAvatar: author.avatarUrl,
      authorDepartment: author.department,
      authorLevel: author.level,
      isVerifiedAlumni: author.isAlumni && author.isVerified,
      content: content,
      category: category,
      mediaUrl: mediaUrl,
      likes: [],
      commentsCount: 0,
      createdAt: DateTime.now(),
    );

    _posts.insert(0, newPost);
    _postsNotifier.value = List.unmodifiable(_posts);
  }

  void toggleLike(String postId, String userId) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final post = _posts[idx];
      final currentLikes = List<String>.from(post.likes);
      if (currentLikes.contains(userId)) {
        currentLikes.remove(userId);
      } else {
        currentLikes.add(userId);
      }
      _posts[idx] = post.copyWith(likes: currentLikes);
      _postsNotifier.value = List.unmodifiable(_posts);
    }
  }

  List<CommentModel> getCommentsForPost(String postId) {
    final postComments = _comments.where((c) => c.postId == postId).toList();
    postComments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return List.unmodifiable(postComments);
  }

  void addComment(String postId, UserModel author, String content) {
    final newComment = CommentModel(
      id: 'comm_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorId: author.id,
      authorName: author.fullName,
      authorRole: author.role.name,
      authorAvatar: author.avatarUrl,
      isVerifiedAlumni: author.isAlumni && author.isVerified,
      content: content,
      createdAt: DateTime.now(),
    );
    _comments.add(newComment);

    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      _posts[idx] = _posts[idx].copyWith(
        commentsCount: _posts[idx].commentsCount + 1,
      );
      _postsNotifier.value = List.unmodifiable(_posts);
    }
  }
}
