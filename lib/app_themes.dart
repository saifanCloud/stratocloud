import 'package:flutter/material.dart';

// Kelas ini mendefinisikan ThemeData untuk tema terang dan gelap
class AppThemes {
  // Warna Primer dan Aksen yang stabil dan elegan
  static const Color primaryBlue = Color(0xFF0056B3); // Biru Tua/Navy
  static const Color lightBackground = Color(0xFFFFFFFF);
  // Perbaikan: Membuat lightSurface sedikit lebih gelap agar cards lebih menonjol
  static const Color lightSurface = Color(
    0xFFF7F9FA,
  ); // Sedikit abu-abu kebiruan yang sangat terang
  static const Color lightTextPrimary = Color(0xFF212529);
  static const Color lightTextSecondary = Color(0xFF6C757D);
  static const Color lightBorder = Color(0xFFCED4DA);

  static const Color darkBackground = Color(0xFF121212); // Hampir hitam
  // Perbaikan: Membuat darkSurface sedikit lebih terang agar cards lebih menonjol
  static const Color darkSurface = Color(
    0xFF1F1F1F,
  ); // Sedikit lebih terang dari background gelap
  static const Color darkTextPrimary = Color(0xFFE9ECEF);
  static const Color darkTextSecondary = Color(0xFFADB5BD);
  static const Color darkBorder = Color(0xFF495057);

  // Tema Terang
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    hintColor: primaryBlue,
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightTextPrimary),
      bodyMedium: TextStyle(color: lightTextPrimary),
      labelLarge: TextStyle(color: lightBackground), // Warna teks tombol
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryBlue,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: lightBackground,
        backgroundColor: primaryBlue, // Warna teks tombol elevated
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue, // Warna teks tombol teks
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      filled: true,
      fillColor: lightSurface,
      hintStyle: TextStyle(color: lightTextSecondary.withOpacity(0.7)),
      labelStyle: const TextStyle(color: lightTextSecondary),
    ),
    
    listTileTheme: const ListTileThemeData(
      iconColor: lightTextSecondary,
      textColor: lightTextPrimary,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:
          lightSurface, // Menggunakan lightSurface untuk bottom nav
      selectedItemColor: primaryBlue,
      unselectedItemColor: lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      selectedColor: primaryBlue,
      color: lightTextSecondary,
      fillColor: primaryBlue.withOpacity(0.1),
      borderColor: lightBorder,
      selectedBorderColor: primaryBlue,
      borderRadius: BorderRadius.circular(8),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryBlue;
        }
        return lightTextSecondary;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryBlue.withOpacity(0.5);
        }
        return lightBorder;
      }),
    ),
  );

  // Tema Gelap
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    hintColor: primaryBlue,
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextPrimary),
      bodyMedium: TextStyle(color: darkTextPrimary),
      labelLarge: TextStyle(color: darkBackground), // Warna teks tombol
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryBlue,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: darkBackground,
        backgroundColor: primaryBlue, // Warna teks tombol elevated
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue, // Warna teks tombol teks
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      filled: true,
      fillColor: darkSurface, // Menggunakan darkSurface untuk input field
      hintStyle: TextStyle(color: darkTextSecondary.withOpacity(0.7)),
      labelStyle: const TextStyle(color: darkTextSecondary),
    ),
    
    listTileTheme: const ListTileThemeData(
      iconColor: darkTextSecondary,
      textColor: darkTextPrimary,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface, // Menggunakan darkSurface untuk bottom nav
      selectedItemColor: primaryBlue,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      selectedColor: primaryBlue,
      color: darkTextSecondary,
      fillColor: primaryBlue.withOpacity(0.1),
      borderColor: darkBorder,
      selectedBorderColor: primaryBlue,
      borderRadius: BorderRadius.circular(8),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryBlue;
        }
        return darkTextSecondary;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryBlue.withOpacity(0.5);
        }
        return darkBorder;
      }),
    ),
  );
}
