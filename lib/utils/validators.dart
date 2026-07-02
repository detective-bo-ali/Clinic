class Validators {
  static String? required(String? value, [String label = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required';
    if (value.replaceAll(RegExp(r'\D'), '').length < 7) return 'Enter a valid phone number';
    return null;
  }

  static String? minLength(String? value, int min, [String label = 'This field']) {
    if (value == null || value.length < min) return '$label must be at least $min characters';
    return null;
  }

  static String? positiveNumber(String? value, [String label = 'Value']) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    final n = num.tryParse(value);
    if (n == null || n < 0) return '$label must be a positive number';
    return null;
  }
}
