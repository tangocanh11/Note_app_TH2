import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class StorageService {
  static const String _notesKey = 'notes_list';

  /// Lưu tất cả ghi chú vào SharedPreferences (JSON Serialization)
  static Future<void> saveNotes(List<Note> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(
        notes.map((note) => note.toJson()).toList(),
      );
      await prefs.setString(_notesKey, jsonString);
    } catch (e) {
      throw Exception('Lỗi lưu ghi chú: $e');
    }
  }

  /// Lấy tất cả ghi chú từ SharedPreferences (JSON Deserialization)
  static Future<List<Note>> loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonData = jsonDecode(jsonString) as List<dynamic>;
      return jsonData
          .map((json) => Note.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Lỗi tải ghi chú: $e');
      return [];
    }
  }

  /// Lưu một ghi chú (thêm hoặc cập nhật)
  static Future<void> saveNote(Note note) async {
    try {
      final notes = await loadNotes();
      final index = notes.indexWhere((n) => n.id == note.id);

      if (index >= 0) {
        // Cập nhật ghi chú hiện có
        notes[index] = note;
      } else {
        // Thêm ghi chú mới
        notes.add(note);
      }

      await saveNotes(notes);
    } catch (e) {
      throw Exception('Lỗi lưu ghi chú: $e');
    }
  }

  /// Xóa một ghi chú
  static Future<void> deleteNote(String noteId) async {
    try {
      final notes = await loadNotes();
      notes.removeWhere((note) => note.id == noteId);
      await saveNotes(notes);
    } catch (e) {
      throw Exception('Lỗi xóa ghi chú: $e');
    }
  }

  /// Lấy một ghi chú theo ID
  static Future<Note?> getNote(String noteId) async {
    try {
      final notes = await loadNotes();
      return notes.firstWhere(
        (note) => note.id == noteId,
        orElse: () => Note(
          id: '',
          title: '',
          content: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      print('Lỗi lấy ghi chú: $e');
      return null;
    }
  }

  /// Xóa toàn bộ dữ liệu (cho test)
  static Future<void> clearAllNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notesKey);
    } catch (e) {
      throw Exception('Lỗi xóa dữ liệu: $e');
    }
  }
}
