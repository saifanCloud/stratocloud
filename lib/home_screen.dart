// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:project_ambtron/api/database_service.dart';
import 'package:project_ambtron/api/storage_service.dart';
import 'package:project_ambtron/files_screen.dart';
import 'package:project_ambtron/notes_screen.dart';
import 'package:project_ambtron/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeDashboardController extends ChangeNotifier {
  final ValueNotifier<Set<String>> selectedItems = ValueNotifier({});
  final ValueNotifier<bool> isSelectionMode = ValueNotifier(false);

  void toggleSelection(String itemId) {
    if (selectedItems.value.contains(itemId)) {
      selectedItems.value.remove(itemId);
    } else {
      selectedItems.value.add(itemId);
    }
    selectedItems.notifyListeners();
    isSelectionMode.value = selectedItems.value.isNotEmpty;
    isSelectionMode.notifyListeners();
  }

  void selectAll(List<String> allItemIds) {
    selectedItems.value = Set<String>.from(allItemIds);
    selectedItems.notifyListeners();
    isSelectionMode.value = selectedItems.value.isNotEmpty;
    isSelectionMode.notifyListeners();
  }

  void clearSelection() {
    selectedItems.value.clear();
    selectedItems.notifyListeners();
    isSelectionMode.value = false;
    isSelectionMode.notifyListeners();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _currentTitle = 'Foto';
  final String _quote = 'Abadikan setiap momen indahmu.';
  late final _HomeDashboardController _dashboardController;
  final GlobalKey<_HomeDashboardState> _homeDashboardKey = GlobalKey();
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _dashboardController = _HomeDashboardController();
    _dashboardController.isSelectionMode.addListener(_updateAppBar);
    _dashboardController.selectedItems.addListener(_updateAppBar);

    _widgetOptions = <Widget>[
      _HomeDashboard(
        key: _homeDashboardKey,
        quote: _quote,
        controller: _dashboardController,
      ),
      const FilesScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _dashboardController.isSelectionMode.removeListener(_updateAppBar);
    _dashboardController.selectedItems.removeListener(_updateAppBar);
    _dashboardController.dispose();
    super.dispose();
  }

  void _updateAppBar() {
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          _currentTitle = 'Foto';
          break;
        case 1:
          _currentTitle = 'Koleksi';
          break;
        case 2:
          _currentTitle = 'Profil';
          break;
        default:
          _currentTitle = 'Stratocloud';
          break;
      }
    });
  }

  void _showCreateNewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Buat Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('Folder Baru'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateFolderDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_alt_outlined),
                title: const Text('Catatan Baru'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/note-editor').then((_) {
                    _homeDashboardKey.currentState?.refreshGallery();
                  });
                },
              ),
              // -------- UNGGAH FOTO (DIPERBAIKI) --------
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Unggah Foto'),
                onTap: () async {
                  // Simpan messenger sebelum dialog ditutup
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context); // Tutup dialog

                  // Upload gambar
                  final path = await StorageService().uploadImage();

                  if (!mounted) return;

                  if (path != null) {
                    try {
                      // Simpan data foto ke database
                      await DatabaseService().addPhoto(path);

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Foto berhasil diunggah!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Refresh galeri
                      _homeDashboardKey.currentState?.refreshGallery();
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Gagal menyimpan foto: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Gagal mengunggah foto atau dibatalkan.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              // -----------------------------------------
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: const Text('Unggah Video'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Fitur unggah video belum diimplementasikan.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    TextEditingController folderNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Buat Folder Baru'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(
              hintText: 'Nama Folder',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Buat'),
              onPressed: () {
                if (folderNameController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Folder "${folderNameController.text}" dibuat.',
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama folder tidak boleh kosong.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<bool>(
          valueListenable: _dashboardController.isSelectionMode,
          builder: (context, isSelectionMode, child) {
            if (isSelectionMode) {
              return ValueListenableBuilder<Set<String>>(
                valueListenable: _dashboardController.selectedItems,
                builder: (context, selectedItems, child) {
                  return Text('${selectedItems.length} Dipilih');
                },
              );
            } else {
              if (_selectedIndex == 0) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_queue_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Stratocloud',
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                  ],
                );
              } else {
                return Text(_currentTitle);
              }
            }
          },
        ),
        leading: ValueListenableBuilder<bool>(
          valueListenable: _dashboardController.isSelectionMode,
          builder: (context, isSelectionMode, child) {
            return isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _dashboardController.clearSelection,
                  )
                : const SizedBox.shrink();
          },
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _dashboardController.isSelectionMode,
            builder: (context, isSelectionMode, child) {
              List<Widget> actions = [];
              if (isSelectionMode && _selectedIndex == 0) {
                actions.add(
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: _dashboardController.selectedItems,
                    builder: (context, selectedItems, _) {
                      final allItemIds =
                          _homeDashboardKey.currentState?._galleryItems
                              .map((item) => item['id'].toString())
                              .toSet();
                      final bool allSelected =
                          allItemIds != null &&
                          selectedItems.isNotEmpty &&
                          selectedItems.containsAll(allItemIds);
                      return IconButton(
                        icon: Icon(
                          allSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                        onPressed: () {
                          if (allSelected) {
                            _dashboardController.clearSelection();
                          } else {
                            if (allItemIds != null) {
                              _dashboardController.selectAll(
                                allItemIds.toList(),
                              );
                            }
                          }
                        },
                        tooltip:
                            allSelected
                                ? 'Batalkan Semua Pilihan'
                                : 'Pilih Semua',
                      );
                    },
                  ),
                );
                actions.add(
                  PopupMenuButton<String>(
                    onSelected:
                        (String result) => _handleSelectionMenu(
                          context,
                          result,
                          _dashboardController.selectedItems.value,
                        ),
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Hapus'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'group',
                            child: Text('Kelompokkan'),
                          ),
                        ],
                  ),
                );
              } else if (_selectedIndex == 0 || _selectedIndex == 1) {
                actions.add(
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed:
                        () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Tekan lama untuk memulai seleksi.'),
                              ),
                            ),
                  ),
                );
              }
              actions.add(
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              );
              return Row(children: actions);
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            label: 'Foto',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            label: 'Koleksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (_selectedIndex == 0 &&
              _dashboardController.isSelectionMode.value) {
            _dashboardController.clearSelection();
          }
          _onItemTapped(index);
        },
      ),
      floatingActionButton:
          (_selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2)
              ? FloatingActionButton(
                  onPressed: _showCreateNewDialog,
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: const Icon(Icons.add_rounded, size: 30),
                )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _handleSelectionMenu(
    BuildContext context,
    String result,
    Set<String> selectedItems,
  ) {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih setidaknya satu item terlebih dahulu.'),
        ),
      );
      return;
    }
    switch (result) {
      case 'delete':
        _showDeleteOptionsDialog(context, selectedItems);
        break;
      case 'group':
        _showGroupOptionsDialog(context, selectedItems);
        break;
    }
  }

  void _showDeleteOptionsDialog(
    BuildContext context,
    Set<String> selectedItems,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Hapus ${selectedItems.length} Item?'),
          content: const Text('Pilih cara Anda ingin menghapus item ini:'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${selectedItems.length} item dipindahkan ke sampah.',
                    ),
                  ),
                );
                _dashboardController.clearSelection();
              },
              child: const Text('Pindahkan ke Sampah'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${selectedItems.length} item dihapus permanen.',
                    ),
                  ),
                );
                _dashboardController.clearSelection();
              },
              child: const Text(
                'Hapus Permanen',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _showGroupOptionsDialog(
    BuildContext context,
    Set<String> selectedItems,
  ) {
    TextEditingController folderNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Kelompokkan ${selectedItems.length} Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Buat folder baru untuk item yang dipilih:'),
              const SizedBox(height: 10),
              TextField(
                controller: folderNameController,
                decoration: const InputDecoration(hintText: 'Nama Folder Baru'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (folderNameController.text.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${selectedItems.length} item dikelompokkan ke "${folderNameController.text}".',
                      ),
                    ),
                  );
                  _dashboardController.clearSelection();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama folder tidak boleh kosong.'),
                    ),
                  );
                }
              },
              child: const Text('Buat & Kelompokkan'),
            ),
          ],
        );
      },
    );
  }
}

class _HomeDashboard extends StatefulWidget {
  final String quote;
  final _HomeDashboardController controller;

  const _HomeDashboard({
    Key? key,
    required this.quote,
    required this.controller,
  }) : super(key: key);

  @override
  State<_HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<_HomeDashboard> {
  late Future<List<Map<String, dynamic>>> _galleryFuture;
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _galleryItems = [];

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  void _loadGallery() {
    setState(() {
      _galleryFuture = _dbService.getGalleryItems();
    });
  }

  void refreshGallery() {
    _loadGallery();
  }

  String _formatDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) return 'Hari Ini';
    if (itemDate == yesterday) return 'Kemarin';
    if (now.difference(date).inDays < 7) return 'Minggu Lalu';
    if (now.difference(date).inDays < 30) return 'Bulan Lalu';
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  // ========== METHOD BARU: WAKTU REAL-TIME ==========
  Widget _buildTimeLabel(String? createdAt) {
    if (createdAt == null) return const SizedBox.shrink();
    final dateTime = DateTime.parse(createdAt).toLocal();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    String timeText;
    if (difference.inMinutes < 1) {
      timeText = 'Baru saja';
    } else if (difference.inMinutes < 60) {
      timeText = '${difference.inMinutes} menit';
    } else {
      timeText = DateFormat('HH:mm', 'id_ID').format(dateTime);
    }

    return Text(
      timeText,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        shadows: [Shadow(blurRadius: 2.0, color: Colors.black)],
      ),
    );
  }
  // =================================================

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _galleryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => _loadGallery(),
            child: Stack(
              children: [
                ListView(),
                const Center(
                  child: Text(
                    'Galeri masih kosong.\nTekan + untuk menambah item.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        _galleryItems = snapshot.data!;
        final Map<String, List<Map<String, dynamic>>> groupedItems = {};
        for (var item in _galleryItems) {
          final DateTime itemDateTime = DateTime.parse(item['created_at']);
          final String dateGroupKey = _formatDateGroup(itemDateTime);
          if (!groupedItems.containsKey(dateGroupKey)) {
            groupedItems[dateGroupKey] = [];
          }
          groupedItems[dateGroupKey]!.add(item);
        }

        return RefreshIndicator(
          onRefresh: () async => _loadGallery(),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.quote,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 20),
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari foto, video, atau catatan...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final dateGroup = groupedItems.keys.elementAt(index);
                  final itemsInGroup = groupedItems[dateGroup]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateGroup,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<Set<String>>(
                        valueListenable: widget.controller.selectedItems,
                        builder: (context, selectedItems, child) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemCount: itemsInGroup.length,
                            itemBuilder: (context, itemIndex) {
                              final item = itemsInGroup[itemIndex];
                              final String type =
                                  item.containsKey('content') ? 'note' : 'photo';
                              final String itemId = item['id'].toString();
                              final bool isSelected =
                                  selectedItems.contains(itemId);

                              Widget contentWidget;
                              if (type == 'photo') {
                                final imageUrl = item['file_url'];
                                contentWidget =
                                    (imageUrl != null && imageUrl.isNotEmpty)
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(
                                                child: CircularProgressIndicator(strokeWidth: 2.0),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Center(
                                                  child: Icon(Icons.broken_image, color: Colors.red),
                                                ),
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image),
                                          );
                              } else {
                                // type == 'note'
                                contentWidget = Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.topLeft,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.sticky_note_2_outlined,
                                        color: Theme.of(context).primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['title'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Material(
                                elevation: isSelected ? 4 : 1,
                                borderRadius: BorderRadius.circular(8),
                                clipBehavior: Clip.antiAlias,
                                child: GestureDetector(
                                  onTap: () {
                                    if (widget.controller.isSelectionMode.value) {
                                      widget.controller.toggleSelection(itemId);
                                    } else {
                                      if (type == 'note') {
                                        context.pushNamed(
                                          'note-detail',
                                          extra: item,
                                        );
                                      } else if (type == 'photo') {
                                        final imageUrl = item['file_url'];
                                        if (imageUrl != null) {
                                          context.pushNamed(
                                            'photo-view',
                                            extra: imageUrl,
                                          );
                                        }
                                      }
                                    }
                                  },
                                  onLongPress: () {
                                    widget.controller.toggleSelection(itemId);
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      contentWidget,
                                      if (isSelected)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.4),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Theme.of(context).primaryColor,
                                              width: 3,
                                            ),
                                          ),
                                          child: const Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (!widget.controller.isSelectionMode.value)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: PopupMenuButton<String>(
                                            icon: const Icon(
                                              Icons.more_vert,
                                              color: Colors.white,
                                              shadows: [Shadow(blurRadius: 2.0)],
                                            ),
                                            onSelected: (value) async {
                                              if (value == 'delete') {
                                                final confirm =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Konfirmasi'),
                                                    content: const Text(
                                                        'Apakah Anda yakin ingin menghapus item ini?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(context).pop(false),
                                                        child: const Text('Batal'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(context).pop(true),
                                                        child: const Text(
                                                          'Hapus',
                                                          style: TextStyle(color: Colors.red),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  if (type == 'note') {
                                                    await _dbService.deleteNote(item['id']);
                                                  } else if (type == 'photo') {
                                                    await _dbService.deletePhoto(
                                                        item['id'], item['path']);
                                                  }
                                                  refreshGallery();
                                                }
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete_outline, color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('Hapus', style: TextStyle(color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      // ========== TAMBAHKAN WAKTU DI SINI ==========
                                      Positioned(
                                        bottom: 2,
                                        right: 4,
                                        child: _buildTimeLabel(item['created_at']),
                                      ),
                                      // =============================================
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                }, childCount: groupedItems.length),
              ),
            ],
          ),
        );
      },
    );
  }
}