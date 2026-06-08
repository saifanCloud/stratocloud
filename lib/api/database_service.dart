// lib/api/database_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final _supabase = Supabase.instance.client;
  
  // ✅ Nama bucket yang sesuai dengan Supabase (harus sama persis)
  static const String bucketName = 'photos';

  // 🔹 GET PHOTOS
  Future<List<Map<String, dynamic>>> getPhotos() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];
      
      final photosResponse = await _supabase
          .from('photos')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> photosWithUrls = [];
      for (var photo in photosResponse) {
        final publicUrl = _supabase.storage
            .from(bucketName)
            .getPublicUrl(photo['path'] ?? '');

        photosWithUrls.add({...photo, 'file_url': publicUrl});
      }

      return photosWithUrls;
    } catch (e) {
      print('⚠️ Error getting photos: $e');
      return [];
    }
  }

  // 🔹 GET NOTES
  Future<List<Map<String, dynamic>>> getNotes() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];
      
      final data = await _supabase
          .from('notes')
          .select()
          .eq('user_id', user.id);
      return data;
    } catch (e) {
      print('⚠️ Error getting notes: $e');
      return [];
    }
  }

  // 🔹 ADD NOTE
  Future<void> addNote({required String title, required String content}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      await _supabase.from('notes').insert({
        'title': title,
        'content': content,
        'user_id': user.id,
      });
    } catch (e) {
      print('❌ Error adding note: $e');
    }
  }

  // 🔹 GET GALLERY ITEMS (notes + photos gabungan)
  Future<List<Map<String, dynamic>>> getGalleryItems() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];
      
      final userId = user.id;
      
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
            .from(bucketName)
            .getPublicUrl(photo['path'] ?? '');

        photosWithUrls.add({...photo, 'file_url': publicUrl});
      }

      final allItems = [...notes, ...photosWithUrls];

      allItems.sort(
        (a, b) => DateTime.parse(
          b['created_at'] ?? DateTime.now().toIso8601String(),
        ).compareTo(DateTime.parse(
          a['created_at'] ?? DateTime.now().toIso8601String(),
        )),
      );

      return allItems;
    } catch (e) {
      print('⚠️ Error getting gallery items: $e');
      return [];
    }
  }

  // 🔹 GET PROFILE (lama - return null kalau tidak ada)
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return data;
    } catch (e) {
      print('⚠️ Error getting profile: $e');
      return null;
    }
  }

  // 🔹✨ GET OR CREATE PROFILE (BARU - auto buat profil kalau belum ada)
  Future<Map<String, dynamic>?> getOrCreateProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      
      // 1. Cek apakah profil sudah ada
      final existingProfile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      // 2. Kalau sudah ada, return profil tersebut
      if (existingProfile != null) {
        return existingProfile;
      }
      
      // 3. Kalau belum ada, buat profil baru dengan username dari email
      final defaultUsername = user.email?.split('@')[0] ?? 'User';
      
      await _supabase.from('profiles').insert({
        'id': user.id,
        'username': defaultUsername,
        'avatar_url': null,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // 4. Return profil yang baru dibuat
      return {
        'id': user.id,
        'username': defaultUsername,
        'avatar_url': null,
        'created_at': DateTime.now().toIso8601String(),
      };
      
    } catch (e) {
      print('❌ Error in getOrCreateProfile: $e');
      return null;
    }
  }

  // 🔹 DELETE NOTE
 Future<void> deleteNote(dynamic noteId) async {
  try {
    await _supabase.from('notes').delete().eq('id', noteId);
  } catch (e) {
    print('❌ Error deleting note: $e');
  }
}

  // 🔹 DELETE PHOTO
Future<void> deletePhoto(dynamic photoId, String photoPath) async {
  try {
    await _supabase.storage.from(bucketName).remove([photoPath]);
    await _supabase.from('photos').delete().eq('id', photoId);
  } catch (e) {
    print('❌ Error deleting photo: $e');
  }
}

  // 🔹 UPDATE PROFILE
  Future<void> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      final updates = {
        'username': username,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }

      await _supabase.from('profiles').update(updates).eq('id', user.id);
    } on PostgrestException catch (e) {
      print('❌ Database error updating profile: ${e.message}');
      throw Exception('Gagal memperbarui profil di database.');
    } catch (e) {
      print('❌ Generic error updating profile: $e');
      throw Exception('Terjadi kesalahan tidak dikenal saat memperbarui profil.');
    }
  }

  // 🔹 ADD PHOTO (simpan metadata foto ke tabel)
  Future<void> addPhoto(String path) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      await _supabase.from('photos').insert({
        'user_id': user.id,
        'path': path,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error adding photo: $e');
      rethrow;
    }
  }
}