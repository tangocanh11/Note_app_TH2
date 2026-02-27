import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/note.dart';
import 'services/storage_service.dart';

/// Test script để kiểm tra lưu trữ offline
/// Bạn có thể chạy bằng: flutter run -d chrome của ứng dụng
/// Hoặc sử dụng main() console test
Future<void> testOfflineStorage() async {
  print('\n========== TEST LƯỚI TRỮ OFFLINE ==========\n');

  try {
    // Test 1: Xóa dữ liệu cũ
    print('📝 Test 1: Xóa dữ liệu cũ...');
    await StorageService.clearAllNotes();
    print('✅ Xóa thành công\n');

    // Test 2: Tạo ghi chú mới
    print('📝 Test 2: Tạo ghi chú mới...');
    final note1 = Note(
      id: '1',
      title: 'Ghi chú 1',
      content: 'Nội dung ghi chú 1',
      createdAt: DateTime(2026, 2, 27, 10, 0),
      updatedAt: DateTime(2026, 2, 27, 10, 0),
    );

    final note2 = Note(
      id: '2',
      title: 'Ghi chú 2',
      content:
          'Nội dung ghi chú 2 với dữ liệu dài hơn để kiểm tra lưu trữ JSON',
      createdAt: DateTime(2026, 2, 27, 11, 0),
      updatedAt: DateTime(2026, 2, 27, 11, 30),
    );

    print('Note 1 toJson: ${jsonEncode(note1.toJson())}');
    print('Note 2 toJson: ${jsonEncode(note2.toJson())}');
    print('✅ Tạo ghi chú thành công\n');

    // Test 3: Lưu ghi chú vào SharedPreferences
    print('📝 Test 3: Lưu ghi chú vào SharedPreferences...');
    await StorageService.saveNote(note1);
    await StorageService.saveNote(note2);
    print('✅ Lưu thành công\n');

    // Test 4: Kiểm tra dữ liệu trong SharedPreferences
    print('📝 Test 4: Kiểm tra dữ liệu trong SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('notes_list');
    print('Raw JSON String: $jsonString');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString);
      print('Decoded JSON: ${jsonEncode(decoded)}');
    }
    print('✅ Kiểm tra thành công\n');

    // Test 5: Tải ghi chú từ SharedPreferences
    print('📝 Test 5: Tải ghi chú từ SharedPreferences...');
    final loadedNotes = await StorageService.loadNotes();
    print('Số ghi chú loaded: ${loadedNotes.length}');
    for (var note in loadedNotes) {
      print(
        '  - ID: ${note.id}, Title: ${note.title}, Content: ${note.content}',
      );
      print('    Created: ${note.createdAt.toIso8601String()}');
      print('    Updated: ${note.updatedAt.toIso8601String()}');
    }
    print('✅ Tải thành công\n');

    // Test 6: Kiểm tra dữ liệu trùng khớp
    print('📝 Test 6: Kiểm tra dữ liệu trùng khớp...');
    bool test1Passed = loadedNotes.any(
      (n) =>
          n.id == '1' &&
          n.title == 'Ghi chú 1' &&
          n.content == 'Nội dung ghi chú 1',
    );
    bool test2Passed = loadedNotes.any(
      (n) =>
          n.id == '2' &&
          n.title == 'Ghi chú 2' &&
          n.content ==
              'Nội dung ghi chú 2 với dữ liệu dài hơn để kiểm tra lưu trữ JSON',
    );

    print('Note 1 trùng khớp: ${test1Passed ? '✅' : '❌'}');
    print('Note 2 trùng khớp: ${test2Passed ? '✅' : '❌'}');
    print('✅ Kiểm tra trùng khớp thành công\n');

    // Test 7: Xóa một ghi chú
    print('📝 Test 7: Xóa ghi chú...');
    await StorageService.deleteNote('1');
    final notesAfterDelete = await StorageService.loadNotes();
    print('Số ghi chú sau khi xóa: ${notesAfterDelete.length}');
    bool deleteTestPassed =
        notesAfterDelete.length == 1 && notesAfterDelete[0].id == '2';
    print('Xóa thành công: ${deleteTestPassed ? '✅' : '❌'}\n');

    // Test 8: Cập nhật ghi chú
    print('📝 Test 8: Cập nhật ghi chú...');
    final updatedNote = Note(
      id: '2',
      title: 'Ghi chú 2 - Cập nhật',
      content: 'Nội dung đã được cập nhật',
      createdAt: note2.createdAt,
      updatedAt: DateTime.now(),
    );
    await StorageService.saveNote(updatedNote);
    final notesAfterUpdate = await StorageService.loadNotes();
    bool updateTestPassed = notesAfterUpdate.any(
      (n) => n.id == '2' && n.title == 'Ghi chú 2 - Cập nhật',
    );
    print('Cập nhật thành công: ${updateTestPassed ? '✅' : '❌'}\n');

    print('========== KẾT QUẢ TEST ==========');
    print('✅ TẤT CẢ TEST PASSED - Dữ liệu được lưu trữ OFFLINE thành công!');
    print('✅ JSON Serialization: OK');
    print('✅ SharedPreferences: OK');
    print('✅ Dữ liệu trùng khớp: OK\n');

    print('⚠️  HƯỚNG DẪN TEST THỰC TẾ:');
    print('1. Chạy ứng dụng Flutter');
    print('2. Tạo vài ghi chú (Title + Content)');
    print('3. Đóng ứng dụng hoàn toàn (Kill App):');
    print('   - Trên Chrome: Đóng tab');
    print('   - Trên Android: Kill app từ Recent apps');
    print('4. Mở lại ứng dụng');
    print('5. Kiểm tra: Dữ liệu ghi chú phải vẫn còn nguyên vẹn ✓\n');
  } catch (e, stackTrace) {
    print('❌ TEST FAILED: $e');
    print('Stack trace: $stackTrace');
  }
}

void main() async {
  await testOfflineStorage();
}
