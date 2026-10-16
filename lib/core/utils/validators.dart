class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validateMatricNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Matriculation number is required';
    }
    final upper = value.trim().toUpperCase();
    if (!upper.startsWith('KASU')) {
      return 'KASU Matric number usually begins with KASU (e.g. KASU/20/CSC/1042)';
    }
    return null;
  }

  static String? validateAlumniId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alumni ID or graduation registration number is required';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
