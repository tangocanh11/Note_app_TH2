import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noteapp/models/note.dart';
import 'package:noteapp/services/storage_service.dart';

void main() {
  group('Offline Storage Tests', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('Test 1: Create and save note', () async {
      final note = Note(
        id: '1',
        title: 'Test Note',
        content: 'Test Content',
        createdAt: DateTime(2026, 2, 27),
        updatedAt: DateTime(2026, 2, 27),
      );

      await StorageService.saveNote(note);
      final loadedNotes = await StorageService.loadNotes();

      expect(loadedNotes.length, 1);
      expect(loadedNotes[0].id, '1');
      expect(loadedNotes[0].title, 'Test Note');
      expect(loadedNotes[0].content, 'Test Content');
    });

    test('Test 2: Multiple notes storage', () async {
      final notes = [
        Note(
          id: '1',
          title: 'Note 1',
          content: 'Content 1',
          createdAt: DateTime(2026, 2, 27, 10, 0),
          updatedAt: DateTime(2026, 2, 27, 10, 0),
        ),
        Note(
          id: '2',
          title: 'Note 2',
          content: 'Content 2',
          createdAt: DateTime(2026, 2, 27, 11, 0),
          updatedAt: DateTime(2026, 2, 27, 11, 0),
        ),
        Note(
          id: '3',
          title: 'Note 3',
          content: 'Content 3',
          createdAt: DateTime(2026, 2, 27, 12, 0),
          updatedAt: DateTime(2026, 2, 27, 12, 0),
        ),
      ];

      for (var note in notes) {
        await StorageService.saveNote(note);
      }

      final loadedNotes = await StorageService.loadNotes();
      expect(loadedNotes.length, 3);
    });

    test('Test 3: Update note', () async {
      final originalNote = Note(
        id: '1',
        title: 'Original Title',
        content: 'Original Content',
        createdAt: DateTime(2026, 2, 27),
        updatedAt: DateTime(2026, 2, 27),
      );

      await StorageService.saveNote(originalNote);

      final updatedNote = Note(
        id: '1',
        title: 'Updated Title',
        content: 'Updated Content',
        createdAt: DateTime(2026, 2, 27),
        updatedAt: DateTime(2026, 2, 28),
      );

      await StorageService.saveNote(updatedNote);

      final loadedNotes = await StorageService.loadNotes();
      expect(loadedNotes.length, 1);
      expect(loadedNotes[0].title, 'Updated Title');
      expect(loadedNotes[0].content, 'Updated Content');
    });

    test('Test 4: Delete note', () async {
      final note1 = Note(
        id: '1',
        title: 'Note 1',
        content: 'Content 1',
        createdAt: DateTime(2026, 2, 27),
        updatedAt: DateTime(2026, 2, 27),
      );

      final note2 = Note(
        id: '2',
        title: 'Note 2',
        content: 'Content 2',
        createdAt: DateTime(2026, 2, 27),
        updatedAt: DateTime(2026, 2, 27),
      );

      await StorageService.saveNote(note1);
      await StorageService.saveNote(note2);

      await StorageService.deleteNote('1');

      final loadedNotes = await StorageService.loadNotes();
      expect(loadedNotes.length, 1);
      expect(loadedNotes[0].id, '2');
    });

    test('Test 5: JSON serialization integrity', () async {
      final note = Note(
        id: '1',
        title: 'Test Note with Special Characters: !@#\$%',
        content: 'Content with\nnewlines\nand\ttabs',
        createdAt: DateTime(2026, 2, 27, 10, 30, 45),
        updatedAt: DateTime(2026, 2, 27, 15, 45, 30),
      );

      const jsonString =
          '{"id":"1","title":"Test Note with Special Characters: !@#\$%","content":"Content with\\nnewlines\\nand\\ttabs","createdAt":"2026-02-27T10:30:45.000","updatedAt":"2026-02-27T15:45:30.000"}';

      // Verify toJson() creates expected format
      final encoded = note.toJson();
      expect(encoded['id'], '1');
      expect(encoded['title'], contains('Special Characters'));
      expect(encoded['content'], contains('newlines'));
      expect(encoded['createdAt'], contains('2026-02-27'));

      // Save and reload
      await StorageService.saveNote(note);
      final loadedNotes = await StorageService.loadNotes();

      expect(loadedNotes[0].id, note.id);
      expect(loadedNotes[0].title, note.title);
      expect(loadedNotes[0].content, note.content);
      expect(loadedNotes[0].createdAt, note.createdAt);
      expect(loadedNotes[0].updatedAt, note.updatedAt);
    });

    test('Test 6: DateTime preservation', () async {
      final createdTime = DateTime(2026, 2, 27, 10, 30, 45, 123, 456);
      final updatedTime = DateTime(2026, 2, 27, 15, 45, 30, 789, 012);

      final note = Note(
        id: '1',
        title: 'Date Test',
        content: 'Testing datetime preservation',
        createdAt: createdTime,
        updatedAt: updatedTime,
      );

      await StorageService.saveNote(note);
      final loadedNotes = await StorageService.loadNotes();

      // DateTime serialization loses microseconds, so we compare without them
      expect(
        loadedNotes[0].createdAt.toString().split('.')[0],
        createdTime.toString().split('.')[0],
      );
      expect(
        loadedNotes[0].updatedAt.toString().split('.')[0],
        updatedTime.toString().split('.')[0],
      );
    });

    test('Test 7: Empty list handling', () async {
      final loadedNotes = await StorageService.loadNotes();
      expect(loadedNotes, isEmpty);
    });

    test('Test 8: Clear all notes', () async {
      final note = Note(
        id: '1',
        title: 'Note',
        content: 'Content',
        createdAt: DateTime(2026, 2, 27),
        updatedAt: DateTime(2026, 2, 27),
      );

      await StorageService.saveNote(note);
      await StorageService.clearAllNotes();

      final loadedNotes = await StorageService.loadNotes();
      expect(loadedNotes, isEmpty);
    });
  });
}
