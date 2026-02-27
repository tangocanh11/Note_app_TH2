# 🏗️ Architecture & Data Flow

## Tổng Quan Lưu Trữ Offline

```
┌─────────────────────────────────────────────────────────────┐
│                    NoteApp Offline Storage                  │
└─────────────────────────────────────────────────────────────┘

UI Layer (Flutter Widgets)
├── HomeScreen
│   └── Hiển thị danh sách ghi chú
│       └── StorageService.loadNotes()
│
└── NoteDetailScreen
    └── Soạn thảo ghi chú
        └── StorageService.saveNote()

        ↓↓↓ (Serialize/Deserialize) ↓↓↓

Data Layer (Models)
├── Note Model (14 dòng)
│   ├── id: String
│   ├── title: String
│   ├── content: String
│   ├── createdAt: DateTime
│   ├── updatedAt: DateTime
│   ├── toJson() → Map<String, dynamic>
│   └── fromJson() → Note

        ↓↓↓ (JSON Encode/Decode) ↓↓↓

Service Layer
└── StorageService (tĩnh)
    ├── saveNote(Note) → JSON → SharedPreferences
    ├── loadNotes() → SharedPreferences → JSON → List<Note>
    ├── deleteNote(String)
    └── clearAllNotes()

        ↓↓↓ (Local Storage) ↓↓↓

Persistence Layer
└── SharedPreferences
    └── 'notes_list': JSON String
        [
          {
            "id": "1708945200000",
            "title": "Ghi chú 1",
            "content": "Nội dung...",
            "createdAt": "2026-02-27T10:30:45.000",
            "updatedAt": "2026-02-27T10:30:45.000"
          },
          {...}
        ]
```

---

## 📊 Data Flow (Save)

```
User tạo/chỉnh sửa ghi chú
    ↓
NoteDetailScreen._autoSaveNote()
    ↓
Tạo Note object:
    Note(
      id: "...",
      title: titleController.text,
      content: contentController.text,
      createdAt: ...,
      updatedAt: DateTime.now()
    )
    ↓
StorageService.saveNote(note)
    ↓
Tải tất cả ghi chú hiện tại:
    StorageService.loadNotes()
    ↓
Tìm ghi chú có id trùng, nếu có thì update, không thì add
    ↓
Gọi StorageService.saveNotes(updatedList)
    ↓
note.toJson() cho từng ghi chú:
    {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String()
    }
    ↓
jsonEncode(List<Map>) → JSON String
    ↓
prefs.setString('notes_list', jsonString)
    ↓
Lưu vào SharedPreferences
    ↓
Navigator.pop() quay lại HomeScreen

✅ Ghi chú đã được lưu vĩnh viễn
```

---

## 📊 Data Flow (Load)

```
App bật lên
    ↓
HomeScreen.initState()
    ↓
_loadNotes()
    ↓
StorageService.loadNotes()
    ↓
prefs.getString('notes_list')
    ↓
Nếu null hoặc empty → return []
Nếu có dữ liệu → tiếp tục
    ↓
jsonDecode(jsonString) → List<dynamic>
    ↓
Map từng item thành Note object:
    for (json in jsonData) {
      Note.fromJson(json) // Parse từng field
        ├── id: json['id']
        ├── title: json['title']
        ├── content: json['content']
        ├── createdAt: DateTime.parse(json['createdAt'])
        └── updatedAt: DateTime.parse(json['updatedAt'])
    }
    ↓
setState(allNotes = loadedNotes)
    ↓
UI render danh sách ghi chú

✅ Dữ liệu đã được restore từ SharedPreferences
```

---

## 🔄 JSON Serialization Format

### Model Note.toJson()
```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,                                    // "1708945200000"
    'title': title,                              // "Ghi chú 1"
    'content': content,                          // "Nội dung..."
    'createdAt': createdAt.toIso8601String(),    // "2026-02-27T10:30:45.000"
    'updatedAt': updatedAt.toIso8601String()     // "2026-02-27T10:30:45.000"
  };
}
```

### JSON String Lưu Trong SharedPreferences
```json
[
  {
    "id": "1708945200000",
    "title": "Ghi chú 1",
    "content": "Nội dung ghi chú 1",
    "createdAt": "2026-02-27T10:30:45.000",
    "updatedAt": "2026-02-27T10:30:45.000"
  },
  {
    "id": "1708945260000",
    "title": "Ghi chú 2",
    "content": "Nội dung ghi chú 2",
    "createdAt": "2026-02-27T10:31:00.000",
    "updatedAt": "2026-02-27T10:31:00.000"
  }
]
```

### Model Note.fromJson()
```dart
factory Note.fromJson(Map<String, dynamic> json) {
  return Note(
    id: json['id'] as String,                           // Parse String
    title: json['title'] as String,                     // Parse String
    content: json['content'] as String,                 // Parse String
    createdAt: DateTime.parse(json['createdAt'] as String),  // Parse DateTime
    updatedAt: DateTime.parse(json['updatedAt'] as String)   // Parse DateTime
  );
}
```

---

## 🔐 Offline Features

### 1. Không Cần Internet
```
✅ Tạo ghi chú: Không cần WiFi/Mobile
✅ Chỉnh sửa ghi chú: Hoạt động offline
✅ Xóa ghi chú: Không cần connection
✅ Tìm kiếm: Tất cả logic offline
❌ Sync Cloud: Không được support (by design)
```

### 2. Dữ Liệu Lưu Cục Bộ
```
Android:
  SharedPreferences → /data/data/com.app/shared_prefs/
  
iOS:
  SharedPreferences → ~/Library/Preferences/
  
Web:
  SharedPreferences → localStorage
```

### 3. Dữ Liệu Bền Vững
```
✅ Survive App Restart
✅ Survive Device Reboot (iOS/Android)
✅ Survive Force Close
✅ Survive Chrome Refresh (Web)
❌ Survive App Uninstall (dữ liệu bị xóa)
```

---

## 📱 Platform Compatibility

```
┌─────────────┬──────────────┬──────────────────────────────┐
│  Platform   │ Storage API  │ Path / Location              │
├─────────────┼──────────────┼──────────────────────────────┤
│ Android     │ SharedPref   │ /shared_prefs/flutter.*     │
│ iOS         │ SharedPref   │ ~/Library/Preferences/       │
│ Web (Chrome)│ localStorage │ Browser's localStorage       │
│ Windows     │ SharedPref   │ Registry / App Data folder   │
│ macOS       │ SharedPref   │ ~/Library/Preferences/       │
│ Linux       │ SharedPref   │ ~/.local/share/flutter_... │
└─────────────┴──────────────┴──────────────────────────────┘
```

---

## 🔍 Testing Checklist

```
✅ Unit Test (test/storage_test.dart)
   ├── Create Note: PASS
   ├── Multiple Notes: PASS
   ├── Update Note: PASS
   ├── Delete Note: PASS
   ├── JSON Integrity: PASS
   ├── DateTime Preservation: PASS
   ├── Empty List: PASS
   └── Clear All: PASS

✅ Integration Test (Manual)
   ├── Kill App & Restart: PASS
   ├── Offline Mode: PASS
   ├── Update & Persist: PASS
   ├── Search Function: PASS
   └── Date Sorting: PASS
```

---

## 📝 Code Statistics

```
Files:
  ├── lib/models/note.dart              (58 lines)
  ├── lib/services/storage_service.dart (102 lines)
  ├── lib/screens/home_screen.dart      (326 lines)
  ├── lib/screens/note_detail_screen.dart (166 lines)
  └── lib/main.dart                     (...)

Dependencies:
  ├── shared_preferences: ^2.2.0        ✅ Core storage
  ├── flutter_staggered_grid_view       ✅ UI layout
  └── ❌ image_picker (removed - no media)
  └── ❌ path_provider (removed - no file)
  
No Network Dependencies:
  ✅ http
  ✅ firebase
  ✅ firebase_core
  → 100% Offline
```

---

## 🎯 Key Takeaways

1. **Model-Centric**: Note model chứa tất cả dữ liệu + logic serialize
2. **JSON Standard**: toJson/fromJson theo chuẩn Flutter/Dart
3. **Single Storage**: Một SharedPreferences key: 'notes_list'
4. **Atomic Operations**: Mỗi save là atomic (save tất cả)
5. **No External Deps**: Không phụ thuộc internet hay cloud
6. **Persistent**: Dữ liệu tồn tại sau restart/kill app
7. **Type-Safe**: DateTime xử lý chuẩn via ISO8601 string

---

## ⚠️ Known Limitations

```
❌ Không support đồng bộ cloud
❌ Không support backup tự động
❌ Dữ liệu bị xóa khi gỡ app
❌ Không support encryption (plain text)
❌ Dữ liệu giới hạn ~1MB (SharedPreferences)
```

---

## 🚀 Potential Enhancements

```
✨ Encrypt dữ liệu: flutter_secure_storage
✨ Backup/Restore: Export JSON file
✨ Cloud Sync: Firebase Realtime DB
✨ Offline-First: Realm / Isar database
✨ Version Control: Track edit history
```
