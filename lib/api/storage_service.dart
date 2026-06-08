// lib/api/storage_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;
  
  // ✅ Ganti jadi 'photos' sesuai bucket di Supabase
  static const String bucketName = 'photos'; 

  Future<String?> uploadImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imageFile == null) return null;

    final fileName = '${DateTime.now().millisecondsSinceEpoch}-${imageFile.name}';
    final filePath = '${_supabase.auth.currentUser?.id ?? 'guest'}/$fileName';

    try {
      if (kIsWeb) {
        final imageBytes = await imageFile.readAsBytes();
        await _supabase.storage
            .from(bucketName) // ✅ Pakai variable bucketName
            .uploadBinary(
              filePath,
              imageBytes,
              fileOptions: FileOptions(contentType: imageFile.mimeType),
            );
      } else {
        final file = File(imageFile.path);
        await _supabase.storage
            .from(bucketName) // ✅ Pakai variable bucketName
            .upload(filePath, file);
      }
      return filePath;
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  // Helper: Ambil URL publik
  String getPublicUrl(String filePath) {
    return _supabase.storage.from(bucketName).getPublicUrl(filePath);
  }
}