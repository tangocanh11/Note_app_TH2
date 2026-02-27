# 📱 Hướng Dẫn Kiểm Thử Lưu Trữ Offline

## ✅ Yêu Cầu Test

1. ✅ Ứng dụng hoạt động hoàn toàn **Offline** (không cần kết nối internet)
2. ✅ Dữ liệu (Tiêu đề, Nội dung, Thời gian) được đóng gói trong **Model Note**
3. ✅ Dữ liệu được chuyển đổi thành **JSON** bằng `jsonEncode()`/`jsonDecode()`
4. ✅ Dữ liệu được lưu/đọc từ **SharedPreferences**
5. ✅ **Dữ liệu vẫn nguyên vẹn** sau khi Kill App hoặc Restart

---

## 🧪 Test Case 1: Tạo Ghi Chú và Kill App

### Bước 1: Chuẩn Bị
```
- Chạy ứng dụng: flutter run -d chrome (hoặc Android/iOS)
- Đảm bảo không có ghi chú cũ
```

### Bước 2: Tạo Ghi Chú
```
1. Nhấn nút "+" hoặc tạo ghi chú mới
2. Nhập Title: "Test Kill App"
3. Nhập Content: "Đây là test để kiểm tra lưu trữ offline"
4. Quay lại HomePage (Auto-save sẽ tự động lưu)
5. ✓ Xác nhận ghi chú xuất hiện trong danh sách
```

### Bước 3: Kill App Hoàn Toàn
- **Chrome**: Đóng tab hoặc nhấn Ctrl+W
- **Android**: 
  - Nhấn nút "Recent Apps"
  - Vuốt ghi chú ứng dụng lên (kill)
- **iOS**:
  - Vuốt từ dưới lên để mở App Switcher
  - Vuốt ứng dụng lên (kill)

### Bước 4: Mở Lại Ứng Dụng
```
1. Nhấn vào ứng dụng để mở lại
2. Chờ vài giây để UI render
3. 🎯 KẾT QUẢ MONG MUỐN:
   - Ghi chú "Test Kill App" vẫn xuất hiện
   - Title, Content, và Thời gian đều chính xác
   ✅ TEST PASSED
```

---

## 🧪 Test Case 2: Tạo Nhiều Ghi Chú và Restart Thiết Bị

### Bước 1: Tạo Nhiều Ghi Chú
```
1. Tạo ghi chú #1:
   - Title: "Ghi chú 1"
   - Content: "Nội dung 1"

2. Tạo ghi chú #2:
   - Title: "Ghi chú 2"
   - Content: "Nội dung 2 với dữ liệu dài hơn"

3. Tạo ghi chú #3:
   - Title: "Ghi chú 3"
   - Content: "Nội dung 3 - test ký tự đặc biệt: !@#$%^&*()"

4. ✓ Xác nhận cả 3 ghi chú xuất hiện
```

### Bước 2: Kiểm Tra Data Format
```
Mở DevTools hoặc Debug Console:
- SharedPreferences key: 'notes_list'
- Ghi chú được lưu dưới dạng JSON array:
  [
    {"id":"...", "title":"...", "content":"...", 
     "createdAt":"2026-02-27T...", "updatedAt":"2026-02-27T..."},
    {...},
    {...}
  ]
```

### Bước 3: Restart Máy/Emulator
- **Máy thật**: Tắt và bật lại
- **Android Emulator**: Nhấn Stop rồi Run lại
- **iOS Simulator**: Nhấn Home (⌘H) rồi mở lại từ Springboard

### Bước 4: Mở Ứng Dụng Lại
```
1. Nhấn vào ứng dụng
2. Chờ tải dữ liệu
3. 🎯 KẾT QUẢ MONG MUỐN:
   - Cả 3 ghi chú vẫn hiển thị
   - Dữ liệu không bị mất
   - Thứ tự danh sách được bảo toàn (mới nhất trên cùng)
   ✅ TEST PASSED
```

---

## 🧪 Test Case 3: Chỉnh Sửa Và Kiểm Tra Update

### Bước 1: Tạo Ghi Chú
```
Title: "Test Update"
Content: "Nội dung ban đầu"
```

### Bước 2: Chỉnh Sửa Ghi Chú
```
1. Nhấn vào ghi chú vừa tạo
2. Sửa Title thành: "Test Update - Đã sửa"
3. Sửa Content thành: "Nội dung đã được cập nhật"
4. Quay lại (auto-save sẽ lưu)
```

### Bước 3: Kill App
```
- Đóng ứng dụng hoàn toàn ngay lập tức
```

### Bước 4: Mở Lại
```
🎯 KẾT QUẢ MONG MUỐN:
- Ghi chú hiển thị Title mới: "Test Update - Đã sửa"
- Content mới được hiển thị đúng
- Thời gian updated mới nhất
✅ TEST PASSED
```

---

## 🧪 Test Case 4: Xóa Ghi Chú

### Bước 1: Tạo 3 Ghi Chú
```
1. "Note 1"
2. "Note 2"
3. "Note 3"
```

### Bước 2: Xóa Note 2
```
1. Vuốt note 2 sang trái
2. Nhấn "Xóa" hoặc xác nhận xóa
3. ✓ Ghi chú biến mất
```

### Bước 3: Kill App
```
- Đóng ứng dụng
```

### Bước 4: Mở Lại
```
🎯 KẾT QUẢ MONG MUỐN:
- Chỉ hiển thị 2 ghi chú: "Note 1" và "Note 3"
- Note 2 vẫn bị xóa
✅ TEST PASSED
```

---

## 🧪 Test Case 5: Offline Mode Verification

### Bước 1: Chạy Ứng Dụng Không Có Internet
```
- Tắt WiFi và Mobile Data
- Hoặc: Chrome DevTools → Network → Offline
```

### Bước 2: Tạo Ghi Chú
```
1. Tạo ghi chú mới: "Offline Test"
2. Nhập nội dung
3. Quay lại
```

### Bước 3: Kiểm Tra
```
🎯 KẾT QUẢ MONG MUỐN:
- ✓ Ghi chú được tạo thành công
- ✓ Không có lỗi Network
- ✓ Dữ liệu được lưu cục bộ (SharedPreferences)
✅ TEST PASSED - Hoạt động Offline 100%
```

---

## 📊 Kiểm Tra JSON Serialization (Advanced)

### Bước 1: Mở Chrome DevTools
```
Trong ứng dụng web: F12 → Console
```

### Bước 2: Chạy Lệnh Kiểm Tra
```javascript
// Kiểm tra SharedPreferences
await window.localStorage.getItem('notes_list');

// Output sẽ hiển thị JSON string giống như:
[{"id":"123...","title":"Ghi chú 1","content":"...","createdAt":"2026-02-27T...","updatedAt":"2026-02-27T..."},...]
```

### Bước 3: Xác Nhận
```
✅ Kiểm tra:
- JSON format đúng (array của objects)
- Có 5 fields: id, title, content, createdAt, updatedAt
- DateTime được format ISO8601 (2026-02-27T...)
- Không có image/drawing fields (đã bị xóa)
```

---

## ✨ Kết Luận Test

### Nếu Tất Cả Test Pass ✅
```
✅ Ứng dụng hoạt động Offline hoàn toàn
✅ JSON Serialization đúng (toJson/fromJson)
✅ SharedPreferences lưu trữ đúng
✅ Dữ liệu vẫn nguyên vẹn sau Kill App / Restart
✅ Không có memory leak hay data loss

🎉 ĐẠT YÊU CẦU KỸ THUẬT
```

### Nếu Có Test Fail ❌
```
❌ Kiểm tra:
1. Có lỗi trong toJson() / fromJson()?
2. StorageService.saveNote() có đúng không?
3. SharedPreferences key có đúng không?
4. DateTime serialization có vấn đề?
```

---

## 📋 Checklist Cuối Cùng

- [ ] Test Case 1: Kill App Pass ✅
- [ ] Test Case 2: Restart Device Pass ✅
- [ ] Test Case 3: Update & Persist Pass ✅
- [ ] Test Case 4: Delete & Persist Pass ✅
- [ ] Test Case 5: Offline Mode Pass ✅
- [ ] JSON Format đúng ✅
- [ ] Không có Network Call ✅
- [ ] Dữ liệu không bị mất ✅

**Ngày Test**: ________________
**Tester**: ____________________
**Kết Quả Cuối Cùng**: ✅ PASS / ❌ FAIL
