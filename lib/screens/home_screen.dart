import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Thông tin sinh viên (cần thay đổi)
  static const String _studentName = 'Tạ Thị Ngọc Anh';
  static const String _studentId = '2351160503';

  List<Note> allNotes = [];
  List<Note> filteredNotes = [];
  late TextEditingController _searchController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterNotes);
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Tải ghi chú từ SharedPreferences
  Future<void> _loadNotes() async {
    try {
      final notes = await StorageService.loadNotes();
      setState(() {
        allNotes = notes;
        filteredNotes = notes;
        _isLoading = false;
      });
      // Sort by updated date (newest first)
      _sortNotes();
    } catch (e) {
      print('Lỗi tải ghi chú: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Lọc ghi chú theo tiêu đề
  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredNotes = allNotes;
      } else {
        filteredNotes = allNotes
            .where((note) => note.title.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  /// Sắp xếp ghi chú theo ngày cập nhật (mới nhất trước)
  void _sortNotes() {
    setState(() {
      allNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _filterNotes();
    });
  }

  /// Xóa ghi chú với xác nhận
  void _deleteNoteWithConfirmation(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa ghi chú "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await StorageService.deleteNote(note.id);
                setState(() {
                  allNotes.removeWhere((n) => n.id == note.id);
                  _filterNotes();
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ghi chú đã được xóa'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                print('Lỗi xóa ghi chú: $e');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  /// Mở màn hình chi tiết (thêm hoặc sửa)
  void _openNoteDetail(Note? note) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
    );

    if (result != null && mounted) {
      await _loadNotes();
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Note - $_studentName - $_studentId',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm ghi chú...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.outline,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                  ),
                ),
                // Grid of Notes
                Expanded(
                  child: filteredNotes.isEmpty
                      ? _buildEmptyState(colorScheme)
                      : MasonryGridView.count(
                          crossAxisCount: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            return _buildNoteCard(note, colorScheme);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteDetail(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.note_outlined,
              size: 80,
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Bạn chưa có ghi chú nào,\nhãy tạo mới nhé!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note, ColorScheme colorScheme) {
    return Dismissible(
      key: Key(note.id),
      background: Container(
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        _deleteNoteWithConfirmation(note);
        return false;
      },
      child: GestureDetector(
        onTap: () => _openNoteDetail(note),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  note.title.isEmpty ? 'Untitled' : note.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Content preview
                Text(
                  note.content.isEmpty ? 'Không có nội dung' : note.content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Date
                Text(
                  _formatDate(note.updatedAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
