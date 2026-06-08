// lib/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_ambtron/api/auth_service.dart';
import 'package:project_ambtron/api/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- DIUBAH MENJADI STATEFULWIDGET UNTUK MENGELOLA STATE ---
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();

  // Future untuk data profil dipegang oleh state
  late Future<Map<String, dynamic>?> _profileFuture;

  // --- SEMUA DATA DUMMY ANDA TETAP DIPERTAHANKAN ---
  static const double totalStorageGB = 100.0;
  static const double photosStorageGB = 20.0;
  static const double videosStorageGB = 10.0;
  static const double notesStorageGB = 5.0;
  static const double trashStorageGB = 0.5;
  static final double usedStorageGB =
      photosStorageGB + videosStorageGB + notesStorageGB + trashStorageGB;
  static final double usedPercentage = (usedStorageGB / totalStorageGB);

  @override
  void initState() {
    super.initState();
    // Data dimuat pertama kali saat halaman dibuka
  _profileFuture = _dbService.getOrCreateProfile();
  }

  // Fungsi untuk memuat ulang data dari server
  void _refreshProfileData() {
    if (mounted) {
      setState(() {
        _profileFuture = _dbService.getProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture, // Menggunakan future dari state
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text('Gagal memuat profil.', textAlign: TextAlign.center),
          );
        }

        final profileData = snapshot.data!;
        final username = profileData['username'] ?? 'Nama Pengguna';
        final avatarUrl = profileData['avatar_url'];
        final userEmail =
            Supabase.instance.client.auth.currentUser?.email ??
            'Tidak ada email';

        return ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
          children: [
            // --- KARTU PROFIL PENGGUNA ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                  // Di lib/profile_screen.dart, bagian CircleAvatar:

CircleAvatar(
  radius: 50,
  backgroundColor: Colors.grey.shade200,
  // ✅ Hanya pakai NetworkImage jika avatar_url valid & bukan SVG
  backgroundImage: (avatarUrl != null && 
                    !avatarUrl.endsWith('.svg') && 
                    avatarUrl.startsWith('http'))
      ? NetworkImage(avatarUrl)
      : null,
  child: (avatarUrl == null || avatarUrl.endsWith('.svg'))
      ? const Icon(Icons.person, size: 50, color: Colors.grey)
      : null,
),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        username,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userEmail,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- KARTU PENYIMPANAN ANDA (DENGAN FUNGSI NAVIGASI) ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penyimpanan Anda',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 180,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: CircularProgressIndicator(
                                value: usedPercentage,
                                strokeWidth: 20.0,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${usedStorageGB.toStringAsFixed(1)} GB',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Terpakai',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total ${totalStorageGB.toStringAsFixed(0)} GB',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStorageDetailRow(
                      context,
                      'Foto',
                      Icons.photo_library,
                      Colors.purple,
                      onTap: () {
                        context.push('/typed-content', extra: {
                          'contentType': 'photo',
                          'appBarTitle': 'Foto'
                        });
                      },
                    ),
                    _buildStorageDetailRow(
                      context,
                      'Video',
                      Icons.videocam,
                      Colors.green,
                      onTap: () {
                        context.push('/typed-content', extra: {
                          'contentType': 'video',
                          'appBarTitle': 'Video'
                        });
                      },
                    ),
                    _buildStorageDetailRow(
                      context,
                      'Catatan',
                      Icons.note_alt,
                      Colors.orange,
                      onTap: () {
                        context.push('/typed-content', extra: {
                          'contentType': 'note',
                          'appBarTitle': 'Catatan'
                        });
                      },
                    ),
                    _buildStorageDetailRow(
                      context,
                      'Sampah',
                      Icons.delete,
                      Colors.red,
                      onTap: () {
                        context.push('/typed-content', extra: {
                          'contentType': 'trash',
                          'appBarTitle': 'Sampah'
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- KARTU MENU OPSI (DENGAN PERBAIKAN NAVIGASI EDIT) ---
            Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuOption(
                    context,
                    Icons.edit_outlined,
                    'Edit Profil',
                    () async {
                      final bool? didUpdate = await context.push<bool>('/edit-profile');
                      if (didUpdate == true) {
                        _refreshProfileData();
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuOption(
                    context,
                    Icons.lock_outline,
                    'Ubah Kata Sandi',
                    () {},
                  ),
                  const Divider(height: 1),
                  _buildMenuOption(
                    context,
                    Icons.settings_outlined,
                    'Pengaturan',
                    () => context.push('/settings'),
                  ),
                  const Divider(height: 1),
                  _buildMenuOption(
                    context,
                    Icons.privacy_tip_outlined,
                    'Izin & Privasi',
                    () => context.push('/privacy-policy'),
                  ),
                  const Divider(height: 1),
                  _buildMenuOption(
                    context,
                    Icons.info_outline,
                    'Tentang Aplikasi',
                    () => context.push('/about'),
                  ),
                  const Divider(height: 1),
                  _buildMenuOption(
                    context,
                    Icons.logout,
                    'Keluar',
                    () => _authService.signOut(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Helper widget untuk detail penyimpanan (DIUBAH UNTUK MENERIMA onTap) ---
  Widget _buildStorageDetailRow(
    BuildContext context,
    String typeName,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap, // Menggunakan fungsi onTap yang diberikan
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  typeName,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper widget untuk opsi menu (TIDAK DIUBAH) ---
  Widget _buildMenuOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color =
        isDestructive
            ? Colors.red
            : Theme.of(context).textTheme.bodyLarge?.color;
    final iconColor =
        isDestructive ? Colors.red : Theme.of(context).primaryColor;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}