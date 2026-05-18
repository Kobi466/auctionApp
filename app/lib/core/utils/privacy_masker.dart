class PrivacyMasker {
  const PrivacyMasker._();

  static String displayName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Nguoi dung';
    if (trimmed.contains('@')) return email(trimmed);
    if (trimmed.length <= 2) return '${trimmed[0]}***';
    return '${trimmed.substring(0, trimmed.length < 4 ? trimmed.length : 4)}***';
  }

  static String email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '';

    final atIndex = trimmed.indexOf('@');
    if (atIndex <= 0) return displayName(trimmed);

    final localPart = trimmed.substring(0, atIndex);
    final domain = trimmed.substring(atIndex);
    final visibleLength = localPart.length < 3 ? localPart.length : 3;
    return '${localPart.substring(0, visibleLength)}***$domain';
  }
}
