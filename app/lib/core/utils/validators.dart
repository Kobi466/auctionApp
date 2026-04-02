class Validators {
  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Vui lòng nhập email';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Email không đúng định dạng';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (password.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    return null;
  }

  static String? validateFullName(String? value) {
    final fullName = value?.trim() ?? '';

    if (fullName.isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }

    if (fullName.length < 3) {
      return 'Họ và tên quá ngắn';
    }

    return null;
  }

  static String? validateConfirmPassword(
      String? value,
      String password,
      ) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }

    if (confirmPassword != password) {
      return 'Mật khẩu xác nhận không khớp';
    }

    return null;
  }
}