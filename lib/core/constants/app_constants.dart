/// Values here are mirrored in firestore.rules and functions/src — keep in sync.
class AppConstants {
  static const levels = ['100L', '200L', '300L', '400L', '500L'];

  static const jobTypes = {
    'internship': 'Internship',
    'graduate_trainee': 'Graduate trainee',
    'full_time': 'Full-time',
    'part_time': 'Part-time',
    'freelance': 'Freelance',
    'volunteer': 'Volunteer',
  };

  static const workArrangements = {
    'onsite': 'On-site',
    'remote': 'Remote',
    'hybrid': 'Hybrid',
  };

  static const postTypes = {
    'post': 'Post',
    'advice': 'Career advice',
    'success_story': 'Success story',
    'reunion': 'Reunion / event',
  };

  static const reportReasons = [
    'Spam or scam',
    'Harassment or abuse',
    'Fake job / fraud',
    'Impersonation',
    'Inappropriate content',
    'Other',
  ];

  static const maxPostLength = 2000;
  static const maxCommentLength = 1000;
  static const maxMessageLength = 2000;
  static const maxImageBytes = 5 * 1024 * 1024;
  static const maxCvBytes = 5 * 1024 * 1024;
  static const pageSize = 20;

  /// Fallback catalogue used when Firestore `faculties` is not seeded.
  static const fallbackFaculties = <String, List<String>>{
    'Faculty of Science': [
      'Computer Science',
      'Mathematics',
      'Physics',
      'Biochemistry',
      'Microbiology',
    ],
    'Faculty of Social and Management Sciences': [
      'Accounting',
      'Business Administration',
      'Economics',
      'Mass Communication',
      'Political Science',
    ],
    'Faculty of Arts': ['English', 'History', 'Arabic', 'French'],
    'Faculty of Environmental Sciences': [
      'Architecture',
      'Estate Management',
      'Urban and Regional Planning',
    ],
    'Faculty of Engineering': [
      'Electrical Engineering',
      'Mechanical Engineering',
      'Civil Engineering',
    ],
    'Faculty of Law': ['Public Law', 'Private Law'],
    'Faculty of Education': ['Educational Foundations', 'Science Education'],
    'Faculty of Medicine': ['Medicine and Surgery', 'Nursing Science'],
  };
}

class AppAssets {
  static const kasuLogo = 'assets/images/kasu logo.jpg';
  static const kasuLogoPng = 'assets/images/kasu_logo.png';
  static const kasuAlumni = 'assets/images/kasu alumni.jpg';
}

