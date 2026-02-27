# Hướng Dẫn Note App - Lưu Trữ Dữ Liệu

## 📁 Cấu Trúc Lưu Trữ

### **Vị Trí Lưu Trữ**

#### **Trên Android:**
```
/data/user/0/com.example.noteapp/app_documents/noteapp_notes/
├── /images/              # Lưu ảnh từ gallery/camera
│   ├── 1_1708945200000.jpg
│   ├── 2_1708945300000.jpg
│   └── ...
├── /drawings/            # Lưu bản vẽ tay
│   ├── 1_1708945250000.png
│   ├── 2_1708945350000.png
│   └── ...
└── metadata.json         # Meta data ghi chú (nếu cần lưu vào SharedPreferences)
```

#### **Trên iOS:**
```
/var/mobile/Containers/Data/Application/{UUID}/Documents/noteapp_notes/
├── /images/              # Lưu ảnh từ gallery/camera
│   └── ...
├── /drawings/            # Lưu bản vẽ tay
│   └── ...
└── metadata.json
```

#### **Trên Web:**
```
Dữ liệu được lưu trong IndexedDB hoặc localStorage
(Hiện tại chưa support full trên web)
```

---

## 📱 Cách Truy Cập Trên Thiết Bị

### **Android:**
1. Kết nối thiết bị qua USB hoặc sử dụng emulator
2. Mở File Manager trên thiết bị → đi tới `/Android/data/`
3. Tìm folder `com.example.noteapp`
4. Truy cập `app_documents/noteapp_notes/`
5. Hoặc dùng lệnh adb:
   ```bash
   adb shell
   cd /data/user/0/com.example.noteapp/app_documents/noteapp_notes
   ls -la
   ```

### **iOS:**
- iOS không cho phép truy cập trực tiếp từ File Manager
- Chỉ có thể xem qua Xcode hoặc iTunes (deprecated)
- Dữ liệu tự động được backup khi sync iCloud

---

## 🗂️ Cơ Chế Lưu Trữ Chi Tiết

### **1. Dữ Liệu Ghi Chú (Metadata)**
- **Lưu tại:** `SharedPreferences` hoặc `local_storage`
- **Định dạng:** JSON
- **Nội dung:**
  ```json
  {
    "notes": [
      {
        "id": "1708945200000",
        "title": "Ghi chú của tôi",
        "content": "Nội dung...",
        "createdAt": "2024-02-26T10:00:00Z",
        "updatedAt": "2024-02-26T10:00:00Z",
        "imagePaths": [
          "/data/user/0/com.example.noteapp/app_documents/noteapp_notes/images/1_1708945200000.jpg"
        ],
        "drawingPaths": [
          "/data/user/0/com.example.noteapp/app_documents/noteapp_notes/drawings/1_1708945250000.png"
        ]
      }
    ]
  }
  ```

### **2. File Ảnh**
- **Format:** JPG (85% quality)
- **Tên file:** `{noteId}_{timestamp}.jpg`
- **Vị trí:** `/images/` folder
- **Kích thước:** ~100-300KB (tùy theo độ phân giải)
- **Xóa:** Tự động xóa khi xóa ghi chú

### **3. File Vẽ Tay**
- **Format:** PNG (lossless)
- **Tên file:** `{noteId}_{timestamp}.png`
- **Vị trí:** `/drawings/` folder
- **Kích thước:** ~50-150KB
- **Xóa:** Tự động xóa khi xóa bản vẽ

---

## 🔄 Quy Trình Lưu Dữ Liệu

### **Khi Thêm Ghi Chú Mới:**
1. User nhấn "Ghi chú mới"
2. Nhập tiêu đề + nội dung
3. **Chọn ảnh:**
   - `image_picker` lấy ảnh từ gallery/camera
   - `storage_service.saveImage()` copy file vào `/images/`
   - Lưu đường dẫn vào `imagePaths[]`
4. **Vẽ tay:**
   - Mở `DrawingScreen`
   - Vẽ → nhấn "Lưu Vẽ"
   - `RepaintBoundary` capture vẽ thành PNG
   - `storage_service.saveDrawing()` lưu PNG
   - Lưu đường dẫn vào `drawingPaths[]`
5. Nhấn "Lưu"
6. Metadata + image/drawing paths lưu vào SharedPreferences

### **Khi Sửa Ghi Chú:**
1. Chọn ghi chú → mở `NoteDetailScreen` (edit mode)
2. Có thể thêm/xóa ảnh hoặc vẽ mới
3. Thêm ảnh/vẽ → làm theo quy trình trên
4. Xóa ảnh → xóa file + xóa path từ list
5. Nhấn "Lưu" → cập nhật metadata

### **Khi Xóa Ghi Chú:**
1. Nhấn icon xóa → confirm dialog
2. Xóa tất cả file trong `/images/` có liên quan
3. Xóa tất cả file trong `/drawings/` có liên quan
4. Xóa metadata từ SharedPreferences

---

## 💾 Công Nghệ Sử Dụng

### **Packages:**
- **`image_picker`** - Chọn/chụp ảnh
- **`path_provider`** - Lấy app documents directory
- **`shared_preferences`** (tương lai) - Lưu metadata
- **Flutter's `CustomPaint`** - Vẽ tay

---

## ⚠️ Lưu Ý Quan Trọng

### **Dung Lượng:**
- Mỗi ảnh ~100-300KB
- Mỗi bản vẽ ~50-150KB
- Nên giới hạn số ảnh/vẽ trên 1 ghi chú

### **Bảo Mật:**
- Dữ liệu lưu trong `app_documents` (private, encrypted trên iOS)
- Android có thể truy cập nếu thiết bị đã root
- Nên thêm biometric auth nếu cần bảo vệ

### **Sao Lưu:**
- **Android:** Dữ liệu tự động backup nếu bật Google Drive backup
- **iOS:** Backup tự động qua iCloud nếu enable CloudKit

### **Xóa Dữ Liệu:**
- Gỡ cài đặt ứng dụng → tất cả dữ liệu bị xóa
- Không có cách để phục hồi nếu không có backup

---

## 🛠️ Debugging

### **Kiểm tra file ảnh/vẽ:**
```bash
# Android
adb shell
cd /data/user/0/com.example.noteapp/app_documents/noteapp_notes
ls -la images/
ls -la drawings/

# Xem file
cat /data/user/0/com.example.noteapp/app_documents/noteapp_notes/images/1_1708945200000.jpg
```

### **Xem metadata (SharedPreferences):**
```bash
# Android Studio
- Run app in debug
- Use Device File Explorer
- Navigate to: /data/data/com.example.noteapp/shared_prefs/
```

---

## 📌 Tương Lai

### **Cải Tiến Có Thể:**
1. **SQLite Database** - Thay vì SharedPreferences (lưu trữ tốt hơn)
2. **Cloud Sync** - Firebase/Google Drive backup
3. **Encryption** - Mã hóa dữ liệu nhạy cảm
4. **Export/Import** - Xuất/nhập ghi chú
5. **Web Support** - Sử dụng IndexedDB thay vì filesystem
