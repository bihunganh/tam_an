# 🌿 Tâm An - Mental Health Tracker App

> Ứng dụng nhật ký và theo dõi sức khỏe tinh thần thông minh, giúp bạn thấu hiểu bản thân qua từng dòng cảm xúc.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=flat&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?style=flat&logo=firebase)
![Status](https://img.shields.io/badge/Status-In%20Development-green)

## 📱 Giới thiệu

**Tâm An** không chỉ là một ứng dụng ghi chú. Nó là một người bạn đồng hành giúp người dùng:
1.  **Check-in cảm xúc:** Ghi lại tâm trạng nhanh chóng với 6 cấp độ cảm xúc và các thẻ (tags) ngữ cảnh.
2.  **Thấu hiểu bản thân:** Hệ thống tự động phân tích dữ liệu để chỉ ra đâu là nguyên nhân khiến bạn buồn, hay đâu là "liều thuốc" giúp bạn vui.
3.  **Trực quan hóa:** Xem lại hành trình cảm xúc qua các biểu đồ mượt mà, đẹp mắt.

## ✨ Tính năng nổi bật

### 1. Nhật ký cảm xúc (Check-in System)
- Ghi lại cảm xúc với 6 mức độ: *Hạnh phúc, Vui vẻ, Bình thường, Căng thẳng, Buồn, Giận dữ*.
- Gắn thẻ ngữ cảnh chi tiết: *Hoạt động, Bạn bè, Địa điểm*.
- Giao diện Dark Mode hiện đại, thân thiện.

### 2. Hệ thống Phân tích & Thống kê (Advanced Analytics)
- **Biểu đồ đường (Line Chart):** Hiển thị biến thiên cảm xúc theo thời gian (7 ngày, 14 ngày, Cả tháng).
  - *Kỹ thuật:* Sử dụng `CustomPainter` để vẽ đường cong Bezier mềm mại và các điểm neo (Anchor points) thông minh.
- **Biểu đồ tròn (Donut Chart):** Tổng hợp tỷ lệ cảm xúc trong tháng.
- **Bộ lọc thông minh:** Cho phép xem lại lịch sử cảm xúc của bất kỳ tháng nào trong quá khứ.

### 3. "AI" Insight (Correlation Engine)
- Tự động phân tích mối tương quan giữa cảm xúc tiêu cực và các hoạt động hàng ngày.
- Đưa ra lời khuyên dựa trên dữ liệu thực tế (Ví dụ: *"Bạn thường cảm thấy căng thẳng khi làm việc quá khuya"*).

### 4. Quản lý dữ liệu (Cloud Sync)
- Đăng nhập/Đăng ký bảo mật qua Firebase Auth.
- Lưu trữ dữ liệu thời gian thực trên Cloud Firestore.

## 🛠 Công nghệ sử dụng

* **Framework:** [Flutter](https://flutter.dev/)
* **Ngôn ngữ:** Dart
* **Backend:** Firebase (Authentication, Firestore Database)
* **State Management:** (Ghi loại bạn dùng: Provider / Bloc / GetX)
* **Kiến trúc:** Clean Architecture / MVVM (Tùy mô hình bạn theo)

## 🚀 Cài đặt & Chạy dự án

1.  **Clone dự án:**
    ```bash
    git clone [https://github.com/username-cua-ban/tam-an-app.git](https://github.com/username-cua-ban/tam-an-app.git)
    ```
2.  **Cài đặt các thư viện:**
    ```bash
    flutter pub get
    ```
3.  **Cấu hình Firebase:**
    - Tạo project trên Firebase Console.
    - Tải file `google-services.json` (Android) và `GoogleService-Info.plist` (iOS) bỏ vào thư mục tương ứng.
4.  **Chạy ứng dụng:**
    ```bash
    flutter run
    ```

## 📬 Liên hệ

Được phát triển bởi **Lê Mạnh Hùng Anh**.
- Email: manhhunganhle@gmail.com
---
*Dự án được thực hiện với mục đích học tập và đóng góp cho cộng đồng.*
