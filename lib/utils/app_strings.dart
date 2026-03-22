class AppStrings {
  static bool isVietnamese(String languageCode) {
    return languageCode.toLowerCase().startsWith('vi');
  }

  static String tr(
    String languageCode, {
    required String en,
    required String vi,
  }) {
    return isVietnamese(languageCode) ? vi : en;
  }
}
