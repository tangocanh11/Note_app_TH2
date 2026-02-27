import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;

  const NoteDetailScreen({this.note, super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaving = false;
  late String _noteId;

  @override
  void initState() {
    super.initState();
    _noteId =
        widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Auto-save note to SharedPreferences
  Future<void> _autoSaveNote() async {
    if (_isSaving) return;

    try {
      _isSaving = true;

      // Create new or updated note
      final note = Note(
        id: _noteId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to SharedPreferences
      await StorageService.saveNote(note);

      if (mounted) {
        Navigator.pop(context, note);
      }
    } catch (e) {
      print('Lỗi lưu tự động: $e');
      if (mounted) {
        _showErrorDialog('Lỗi khi lưu ghi chú: $e');
      }
    } finally {
      _isSaving = false;
    }
  }

  void _showErrorDialog(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditMode = widget.note != null;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _autoSaveNote();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditMode ? 'Sửa ghi chú' : 'Ghi chú mới',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          backgroundColor: colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _autoSaveNote(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title input
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Tiêu đề',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Content input
              TextField(
                controller: _contentController,
                maxLines: null,
                minLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Viết nội dung ghi chú của bạn...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
