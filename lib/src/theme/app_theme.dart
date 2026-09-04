import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade600),
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1),
      cardTheme: base.cardTheme.copyWith(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 1),
      chipTheme: base.chipTheme.copyWith(backgroundColor: Colors.grey[200], labelStyle: const TextStyle(color: Colors.black)),
      // textTheme: base.textTheme.apply(fontFamily: 'Inter'), // Use Inter when font assets are added
    );
  }
}
