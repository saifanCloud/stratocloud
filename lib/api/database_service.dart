// lib/api/database_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getPhotos() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final photosResponse = await _supabase
          .from('photos')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false); // Urutkan dari yang terbaru

      final List<Map<String, dynamic>> photosWithUrls = [];
      for (var photo in photosResponse) {
        final publicUrl = _supabase.storage
            .from('user-photos')
            .getPublicUrl(photo['path']);

        photosWithUrls.add({...photo, 'file_url': publicUrl});
      }

      return photosWithUrls;
    } catch (e) {
      print('Error getting photos: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase.from('notes').select().eq('user_id', userId);
      return data;
    } catch (e) {
      print('Error getting notes: $e');
      return [];
    }
  }

  Future<void> addNote({required String title, required String content}) async {
    try {
      await _supabase.from('notes').insert({
        'title': title,
        'content': content,
        'user_id': _supabase.auth.currentUser!.id,
      });
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getGalleryItems() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final notes = await _supabase
          .from('notes')
          .select()
          .eq('user_id', userId);

      final photosResponse = await _supabase
          .from('photos')
          .select()
          .eq('user_id', userId);

      final List<Map<String, dynamic>> photosWithUrls = [];
      for (var photo in photosResponse) {
        final publicUrl = _supabase.storage
            .from('user-photos') // Pastikan nama bucket benar
            .getPublicUrl(photo['path']); // Gunakan kolom 'path'

        photosWithUrls.add({...photo, 'file_url': publicUrl});
      }

      final allItems = [...notes, ...photosWithUrls];

      allItems.sort(
        (a, b) => DateTime.parse(
          b['created_at'],
        ).compareTo(DateTime.parse(a['created_at'])),
      );

      return allItems;
    } catch (e) {
      print('Error getting gallery items: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data =
          await _supabase.from('profiles').select().eq('id', userId).single();
      return data;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _supabase.from('notes').delete().eq('id', noteId);
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  Future<void> deletePhoto(String photoId, String photoPath) async {
    try {
      await _supabase.storage.from('user-photos').remove([photoPath]);
      await _supabase.from('photos').delete().eq('id', photoId);
    } catch (e) {
      print('Error deleting photo: $e');
    }
  }

  // --- ▼▼▼ PERBAIKAN PADA FUNGSI INI ▼▼▼ ---
  Future<void> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final updates = {
        'username': username,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }

      await _supabase.from('profiles').update(updates).eq('id', userId);
    } on PostgrestException catch (e) {
      // Menangkap error spesifik dari Supabase database
      print('Database error updating profile: ${e.message}');
      throw Exception('Gagal memperbarui profil di database.');
    } catch (e) {
      print('Generic error updating profile: $e');
      throw Exception('Terjadi kesalahan tidak dikenal saat memperbarui profil.');
    }
  }

  // ========== METHOD BARU: UNTUK MENYIMPAN FOTO KE DATABASE ==========
  Future<void> addPhoto(String path) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      await _supabase.from('photos').insert({
        'user_id': userId,
        'path': path,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding photo: $e');
      rethrow; // Melempar error agar bisa ditangkap di UI
    }
  }
}