import 'package:flutter/material.dart';
import '../data/models/settings_model.dart';

/// Provider để tạo ThemeData dựa trên settings
/// Cung cấp theme light hoặc dark cho ứng dụng
class ThemeProvider {
  /// Trả về ThemeData dựa trên AppTheme enum
  static ThemeData getTheme(AppTheme theme) {
    if (theme == AppTheme.dark) {
      // Dark theme
      return ThemeData.dark(
        useMaterial3: true,
        // useMaterial3: sử dụng Material Design 3 (thiết kế mới)
      ).copyWith(
        // copyWith: copy theme và thay đổi một số thuộc tính
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
        ),
      );
    }

    // Light theme (default)
    return ThemeData.light(
      useMaterial3: true,
    ).copyWith(
      primaryColor: Colors.blue,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}