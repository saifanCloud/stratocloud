// lib/main.dart

import 'package:flutter/material.dart';
import 'package:project_ambtron/router/app_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// HAPUS baris ini: import 'package:project_ambtron/utils/constants.dart';
import 'package:project_ambtron/theme_provider.dart';

// Import Theme/Utils
import 'app_themes.dart';

// --- 1. TAMBAHKAN IMPORT INI UNTUK INISIALISASI TANGGAL ---
import 'package:intl/date_symbol_data_local.dart';

// --- 2. TAMBAHKAN KONSTANTA SUPABASE DI SINI ---
const String supabaseUrl = 'https://zbhvxffxvpjxoxpyvxro.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpiaHZ4ZmZ4dnBqeG94cHl2eHJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA5MjU3NjAsImV4cCI6MjA5NjUwMTc2MH0.8CYjC1eKa7hxNlNUW2MjYZH2uGdd19IBz5-gxgPObTc';

void main() async {
  // Pastikan semua binding siap sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase menggunakan URL dan Key
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  // --- 3. TAMBAHKAN BARIS INISIALISASI DI SINI ---
  // Memuat data lokalisasi untuk format tanggal Bahasa Indonesia ('id_ID')
  await initializeDateFormatting('id_ID', null);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

// Buat variabel global agar mudah diakses di mana saja, terutama di router
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ganti MaterialApp biasa menjadi MaterialApp.router
    return MaterialApp.router(
      title: 'Stratocloud',
      debugShowCheckedModeBanner: false,
      // Tema masih sama seperti sebelumnya
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      // Beritahu MaterialApp untuk menggunakan konfigurasi dari router kita
      routerConfig: AppRouter.router,
    );
  }
}