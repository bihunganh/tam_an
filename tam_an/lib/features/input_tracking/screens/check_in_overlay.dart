import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CheckInOverlay extends StatefulWidget {
  const CheckInOverlay({super.key});

  @override
  State<CheckInOverlay> createState() => _CheckInOverlayState();
}

class _CheckInOverlayState extends State<CheckInOverlay> {
  // Dữ liệu giả lập cho các Tags (Sau này sẽ lấy từ API)
  final List<String> locations = ["Ở Nhà", "Ngoài đường", "Công ty"];
  final List<String> activities = ["Họp", "Code", "Học Bài", "Lướt Web", "Nghỉ Ngơi", "Ăn uống"];
  final List<String> people = ["Một Mình", "Bạn Bè", "Gia Đình", "Đồng nghiệp"];

  // Biến lưu trạng thái đang chọn (Để đổi màu nút)
  String? selectedLocation;
  String? selectedActivity;
  String? selectedPerson;

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao bàn phím để đẩy nút lên khi gõ chữ
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Chiếm 85% màn hình
      decoration: const BoxDecoration(
        color: Color(0xFF424242), // Màu nền xám đậm của Overlay
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // 1. Thanh nắm (Handle bar) màu xám nhỏ xíu ở trên cùng
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Section: Bạn đang ở đâu?
                  _buildSectionTitle('BẠN ĐANG Ở ĐÂU?', Icons.location_on, context),
                  const SizedBox(height: 10),
                  _buildTagGroup(locations, selectedLocation, (val) {
                    setState(() => selectedLocation = val);
                  }),

                  const SizedBox(height: 24),

                  // 3. Section: Bạn đang làm gì?
                  _buildSectionTitle('BẠN ĐANG LÀM GÌ?', Icons.work, context),
                  const SizedBox(height: 10),
                  _buildTagGroup(activities, selectedActivity, (val) {
                    setState(() => selectedActivity = val);
                  }),

                  const SizedBox(height: 24),

                  // 4. Section: Bạn đang ở với ai?
                  _buildSectionTitle('BẠN ĐANG Ở VỚI AI?', Icons.people, context),
                  const SizedBox(height: 10),
                  _buildTagGroup(people, selectedPerson, (val) {
                    setState(() => selectedPerson = val);
                  }),

                  const SizedBox(height: 24),

                  // 5. Input Ghi chú
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ghi chú thêm (tùy chọn)...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF303030), // Màu nền input tối hơn nền overlay
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 6. Nút Hoàn Tất (Màu vàng)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Xử lý lưu data sau này
                        Navigator.pop(context); // Đóng overlay
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: Colors.black, // Màu chữ
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Hoàn Tất',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget con: Tiêu đề mục (VD: BẠN ĐANG Ở ĐÂU?) ---
  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: Colors.white70, size: 14),
      ],
    );
  }

  // --- Widget con: Nhóm các nút Tags (Wrap) ---
  Widget _buildTagGroup(List<String> tags, String? selectedValue, Function(String) onSelect) {
    return Wrap(
      spacing: 10, // Khoảng cách ngang giữa các nút
      runSpacing: 10, // Khoảng cách dọc giữa các dòng
      children: [
        // Tạo danh sách nút từ mảng tags
        ...tags.map((tag) {
          final isSelected = tag == selectedValue;
          return GestureDetector(
            onTap: () => onSelect(tag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFF303030), // Chọn thì trắng, không thì xám đen
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: Colors.transparent),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white, // Chọn thì chữ đen
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }),
        // Nút dấu cộng (+) để thêm tag mới
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFF303030),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white70, size: 20),
        ),
      ],
    );
  }
}