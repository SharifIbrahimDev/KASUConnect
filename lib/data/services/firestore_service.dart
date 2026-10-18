import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import '../models/comment_model.dart';
import '../models/job_application_model.dart';
import '../models/job_model.dart';
import '../models/mentorship_model.dart';
import '../models/post_model.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import 'mock_data_seed.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class FirestoreService {
  FirebaseFirestore? get _db => Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;
  bool _isAvailable = false;

  FirestoreService() {
    _checkAvailability();
  }

  bool get isAvailable => _isAvailable;

  Future<void> _checkAvailability() async {
    final db = _db;
    if (db == null) {
      _isAvailable = false;
      return;
    }
    try {
      await db.collection('settings').doc('ping').get(const GetOptions(source: Source.serverAndCache));
      _isAvailable = true;
    } catch (e) {
      debugPrint('Firestore availability notice (using local/mock sync if offline): $e');
      _isAvailable = false;
    }
  }

  // -------------------------------------------------------------
  // USERS
  // -------------------------------------------------------------
  CollectionReference<Map<String, dynamic>>? get _usersCol => _db?.collection('users');

  Stream<List<UserModel>> streamUsers() {
    final col = _usersCol;
    if (col == null) return Stream.value(MockDataSeed.users);
    try {
      return col.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), id: doc.id)).toList();
      });
    } catch (e) {
      debugPrint('streamUsers fallback: $e');
      return Stream.value(MockDataSeed.users);
    }
  }

  Future<void> syncUser(UserModel user) async {
    final col = _usersCol;
    if (col == null) return;
    try {
      await col.doc(user.id).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore syncUser: $e');
    }
  }

  Future<UserModel?> getUser(String id) async {
    final col = _usersCol;
    if (col == null) return null;
    try {
      final doc = await col.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, id: doc.id);
      }
    } catch (e) {
      debugPrint('Firestore getUser: $e');
    }
    return null;
  }

  // -------------------------------------------------------------
  // POSTS & COMMENTS
  // -------------------------------------------------------------
  CollectionReference<Map<String, dynamic>>? get _postsCol => _db?.collection('posts');
  CollectionReference<Map<String, dynamic>>? get _commentsCol => _db?.collection('comments');

  Stream<List<PostModel>> streamPosts() {
    final col = _postsCol;
    if (col == null) return Stream.value(MockDataSeed.posts);
    try {
      return col.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => PostModel.fromMap(doc.data(), id: doc.id)).toList();
      });
    } catch (e) {
      debugPrint('streamPosts fallback: $e');
      return Stream.value(MockDataSeed.posts);
    }
  }

  Future<void> createPost(PostModel post) async {
    final col = _postsCol;
    if (col == null) return;
    try {
      await col.doc(post.id).set(post.toMap());
    } catch (e) {
      debugPrint('Firestore createPost: $e');
    }
  }

  Future<void> togglePostLike(String postId, String userId) async {
    final col = _postsCol;
    if (col == null) return;
    try {
      final docRef = col.doc(postId);
      final doc = await docRef.get();
      if (doc.exists) {
        final post = PostModel.fromMap(doc.data()!, id: doc.id);
        final likes = List<String>.from(post.likes);
        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }
        await docRef.update({'likes': likes});
      }
    } catch (e) {
      debugPrint('Firestore togglePostLike: $e');
    }
  }

  Stream<List<CommentModel>> streamComments(String postId) {
    final col = _commentsCol;
    if (col == null) {
      return Stream.value(MockDataSeed.comments.where((c) => c.postId == postId).toList());
    }
    try {
      return col
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => CommentModel.fromMap(doc.data(), id: doc.id)).toList();
      });
    } catch (e) {
      debugPrint('streamComments fallback: $e');
      return Stream.value(MockDataSeed.comments.where((c) => c.postId == postId).toList());
    }
  }

  Future<void> addComment(CommentModel comment) async {
    final comCol = _commentsCol;
    final postCol = _postsCol;
    if (comCol == null || postCol == null) return;
    try {
      await comCol.doc(comment.id).set(comment.toMap());
      await postCol.doc(comment.postId).update({
        'commentsCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Firestore addComment: $e');
    }
  }

  // -------------------------------------------------------------
  // JOBS & APPLICATIONS
  // -------------------------------------------------------------
  CollectionReference<Map<String, dynamic>>? get _jobsCol => _db?.collection('jobs');
  CollectionReference<Map<String, dynamic>>? get _applicationsCol => _db?.collection('job_applications');

  Stream<List<JobModel>> streamJobs() {
    final col = _jobsCol;
    if (col == null) return Stream.value(MockDataSeed.jobs);
    try {
      return col.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => JobModel.fromMap(doc.data(), id: doc.id)).toList();
      });
    } catch (e) {
      debugPrint('streamJobs fallback: $e');
      return Stream.value(MockDataSeed.jobs);
    }
  }

  Future<void> createJob(JobModel job) async {
    final col = _jobsCol;
    if (col == null) return;
    try {
      await col.doc(job.id).set(job.toMap());
    } catch (e) {
      debugPrint('Firestore createJob: $e');
    }
  }

  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    final col = _jobsCol;
    if (col == null) return;
    try {
      await col.doc(jobId).update({'status': status.name});
    } catch (e) {
      debugPrint('Firestore updateJobStatus: $e');
    }
  }

  Stream<List<JobApplicationModel>> streamApplications({String? userId, String? jobId}) {
    final col = _applicationsCol;
    if (col == null) {
      var list = MockDataSeed.applications;
      if (userId != null) list = list.where((a) => a.applicantId == userId).toList();
      if (jobId != null) list = list.where((a) => a.jobId == jobId).toList();
      return Stream.value(list);
    }
    try {
      Query<Map<String, dynamic>> query = col;
      if (userId != null) {
        query = query.where('applicantId', isEqualTo: userId);
      }
      if (jobId != null) {
        query = query.where('jobId', isEqualTo: jobId);
      }
      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => JobApplicationModel.fromMap(doc.data(), id: doc.id)).toList();
      });
    } catch (e) {
      debugPrint('streamApplications fallback: $e');
      var list = MockDataSeed.applications;
      if (userId != null) list = list.where((a) => a.applicantId == userId).toList();
      if (jobId != null) list = list.where((a) => a.jobId == jobId).toList();
      return Stream.value(list);
    }
  }

  Future<void> submitApplication(JobApplicationModel app) async {
    final appCol = _applicationsCol;
    final jobCol = _jobsCol;
    if (appCol == null || jobCol == null) return;
    try {
      await appCol.doc(app.id).set(app.toMap());
      await jobCol.doc(app.jobId).update({
        'applicationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Firestore submitApplication: $e');
    }
  }

  Future<void> updateApplicationStatus(String appId, ApplicationStatus status) async {
    final col = _applicationsCol;
    if (col == null) return;
    try {
      await col.doc(appId).update({
        'status': status.name,
        'reviewedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Firestore updateApplicationStatus: $e');
    }
  }

  // -------------------------------------------------------------
  // MENTORSHIP
  // -------------------------------------------------------------
  CollectionReference<Map<String, dynamic>>? get _mentorshipsCol => _db?.collection('mentorships');

  Stream<List<MentorshipModel>> streamMentorships(String userId) {
    final col = _mentorshipsCol;
    if (col == null) {
      return Stream.value(MockDataSeed.mentorshipRequests.where((m) => m.studentId == userId || m.alumniId == userId).toList());
    }
    try {
      return col.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => MentorshipModel.fromMap(doc.data(), id: doc.id))
            .where((m) => m.studentId == userId || m.alumniId == userId)
            .toList();
      });
    } catch (e) {
      debugPrint('streamMentorships fallback: $e');
      return Stream.value(MockDataSeed.mentorshipRequests.where((m) => m.studentId == userId || m.alumniId == userId).toList());
    }
  }

  Future<void> requestMentorship(MentorshipModel request) async {
    final col = _mentorshipsCol;
    if (col == null) return;
    try {
      await col.doc(request.id).set(request.toMap());
    } catch (e) {
      debugPrint('Firestore requestMentorship: $e');
    }
  }

  Future<void> updateMentorshipStatus(String id, MentorshipStatus status) async {
    final col = _mentorshipsCol;
    if (col == null) return;
    try {
      await col.doc(id).update({
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Firestore updateMentorshipStatus: $e');
    }
  }

  // -------------------------------------------------------------
  // CHAT & MESSAGING
  // -------------------------------------------------------------
  CollectionReference<Map<String, dynamic>>? get _conversationsCol => _db?.collection('conversations');

  Stream<List<ChatConversationModel>> streamConversations(String userId) {
    final col = _conversationsCol;
    if (col == null) {
      return Stream.value(MockDataSeed.conversations.where((c) => c.participantIds.contains(userId)).toList());
    }
    try {
      return col
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => ChatConversationModel.fromMap(doc.data(), id: doc.id)).toList();
      });
    } catch (e) {
      debugPrint('streamConversations fallback: $e');
      return Stream.value(MockDataSeed.conversations.where((c) => c.participantIds.contains(userId)).toList());
    }
  }

  Stream<List<ChatMessageModel>> streamMessages(String conversationId) {
    final col = _conversationsCol;
    if (col == null) {
      return Stream.value(MockDataSeed.sampleMessages.where((m) => m.chatId == conversationId).toList());
    }
    try {
      return col
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => ChatMessageModel.fromMap(doc.data(), id: doc.id)).toList();
      });
    } catch (e) {
      debugPrint('streamMessages fallback: $e');
      return Stream.value(MockDataSeed.sampleMessages.where((m) => m.chatId == conversationId).toList());
    }
  }

  Future<void> sendMessage(String conversationId, ChatMessageModel msg) async {
    final col = _conversationsCol;
    if (col == null) return;
    try {
      await col.doc(conversationId).collection('messages').doc(msg.id).set(msg.toMap());
      await col.doc(conversationId).update({
        'lastMessage': msg.text,
        'lastMessageTime': msg.timestamp.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Firestore sendMessage: $e');
    }
  }

  // -------------------------------------------------------------
  // COMMUNITY REPORTS & MODERATION
  // -------------------------------------------------------------
  CollectionReference<Map<String, dynamic>>? get _reportsCol => _db?.collection('reports');

  Stream<List<ReportModel>> streamReports() {
    final col = _reportsCol;
    if (col == null) return Stream.value(MockDataSeed.reports);
    try {
      return col.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => ReportModel.fromMap(doc.data(), id: doc.id)).toList();
      });
    } catch (e) {
      debugPrint('streamReports fallback: $e');
      return Stream.value(MockDataSeed.reports);
    }
  }

  Future<void> submitReport(ReportModel report) async {
    final col = _reportsCol;
    if (col == null) return;
    try {
      await col.doc(report.id).set(report.toMap());
    } catch (e) {
      debugPrint('Firestore submitReport: $e');
    }
  }

  Future<void> updateReportStatus(String reportId, String status) async {
    final col = _reportsCol;
    if (col == null) return;
    try {
      await col.doc(reportId).update({
        'status': status,
      });
    } catch (e) {
      debugPrint('Firestore updateReportStatus: $e');
    }
  }

  // -------------------------------------------------------------
  // INITIAL SEEDING HELPER
  // -------------------------------------------------------------
  Future<void> seedDatabaseIfEmpty() async {
    final db = _db;
    final posts = _postsCol;
    final users = _usersCol;
    final jobs = _jobsCol;
    final apps = _applicationsCol;
    final mentors = _mentorshipsCol;

    if (db == null || posts == null || users == null || jobs == null || apps == null || mentors == null) {
      return;
    }

    try {
      final snap = await posts.limit(1).get();
      if (snap.docs.isEmpty) {
        debugPrint('Seeding initial KASUConnect dataset to Cloud Firestore...');
        final batch = db.batch();

        for (final user in MockDataSeed.users) {
          batch.set(users.doc(user.id), user.toMap());
        }
        for (final post in MockDataSeed.posts) {
          batch.set(posts.doc(post.id), post.toMap());
        }
        for (final job in MockDataSeed.jobs) {
          batch.set(jobs.doc(job.id), job.toMap());
        }
        for (final app in MockDataSeed.applications) {
          batch.set(apps.doc(app.id), app.toMap());
        }
        for (final m in MockDataSeed.mentorshipRequests) {
          batch.set(mentors.doc(m.id), m.toMap());
        }

        await batch.commit();
        debugPrint('Successfully seeded KASUConnect data to Cloud Firestore!');
      }
    } catch (e) {
      debugPrint('Firestore seed notice: $e');
    }
  }
}
