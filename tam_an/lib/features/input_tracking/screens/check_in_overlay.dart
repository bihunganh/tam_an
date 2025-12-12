import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CheckInOverlay extends StatefulWidget {
  const CheckInOverlay({super.key});

  @override
  State<CheckInOverlay> createState() => _CheckInOverlayState();
}

class _CheckInOverlayState extends State<CheckInOverlay> {
  // Dữ liệu giả lập
  List<String> locations = ["Ở Nhà", "Ngoài đường", "Công ty"];
  List<String> activities = ["Họp", "Code", "Học Bài", "Lướt Web", "Nghỉ Ngơi", "Ăn uống"];
  List<String> people = ["Một Mình", "Bạn Bè", "Gia Đình", "Đồng nghiệp"];

  // Biến trạng thái
  String? selectedLocation;
  String? selectedActivity;
  String? selectedPerson;
  
  // Trạng thái chế độ chỉnh sửa
  bool _isEditing = false; 

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF424242),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          
          // Header: Thanh nắm & Nút Edit
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _isEditing ? AppColors.primaryYellow : Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isEditing ? Icons.check : Icons.edit,
                        size: 18,
                        color: _isEditing ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('BẠN ĐANG Ở ĐÂU?', Icons.location_on, context),
                  const SizedBox(height: 10),
                  _buildTagGroup(locations, selectedLocation, (val) {
                    setState(() => selectedLocation = val);
                  }),

                  const SizedBox(height: 24),

                  _buildSectionTitle('BẠN ĐANG LÀM GÌ?', Icons.work, context),
                  const SizedBox(height: 10),
                  _buildTagGroup(activities, selectedActivity, (val) {
                    setState(() => selectedActivity = val);
                  }),

                  const SizedBox(height: 24),

                  _buildSectionTitle('BẠN ĐANG Ở VỚI AI?', Icons.people, context),
                  const SizedBox(height: 10),
                  _buildTagGroup(people, selectedPerson, (val) {
                    setState(() => selectedPerson = val);
                  }),

                  const SizedBox(height: 24),

                  if (!_isEditing)
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ghi chú thêm (tùy chọn)...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF303030),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),

                  const SizedBox(height: 30),

                  if (!_isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: Colors.black,
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

  // --- HÀM CHUNG CHO CẢ THÊM VÀ SỬA TAG ---
  // index: Truyền index nếu là Sửa, để null nếu là Thêm mới
  void _showTagDialog(List<String> list, {int? index}) {
    // Nếu index != null -> Lấy tên cũ để sửa. Nếu null -> Tên rỗng để nhập mới
    final bool isEditing = index != null;
    TextEditingController controller = TextEditingController(
      text: isEditing ? list[index!] : "" 
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF303030),
        title: Text(isEditing ? "Sửa Tag" : "Thêm Tag Mới", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: isEditing ? "Nhập tên mới" : "Nhập tên tag...",
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryYellow)),
          ),
          autofocus: true, // Tự động bật bàn phím
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  if (isEditing) {
                    // Sửa tag cũ
                    list[index!] = text;
                  } else {
                    // Thêm tag mới vào cuối danh sách
                    list.add(text);
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Lưu", style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTagGroup(List<String> tags, String? selectedValue, Function(String) onSelect) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Hiển thị các tag hiện có
        for (int i = 0; i < tags.length; i++) ...[
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  if (_isEditing) {
                    // Chế độ Sửa -> Mở dialog để sửa tên
                    _showTagDialog(tags, index: i);
                  } else {
                    // Chế độ Chọn
                    onSelect(tags[i]);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isEditing 
                        ? const Color(0xFF303030).withOpacity(0.5) 
                        : (tags[i] == selectedValue ? Colors.white : const Color(0xFF303030)),
                    borderRadius: BorderRadius.circular(20),
                    border: _isEditing 
                        ? Border.all(color: Colors.white24, style: BorderStyle.solid) 
                        : null,
                  ),
                  child: Text(
                    tags[i],
                    style: TextStyle(
                      color: _isEditing 
                          ? Colors.white70 
                          : (tags[i] == selectedValue ? Colors.black : Colors.white),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              // Nút Xóa (X)
              if (_isEditing)
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedValue == tags[i]) {
                          if (tags == locations) selectedLocation = null;
                          if (tags == activities) selectedActivity = null;
                          if (tags == people) selectedPerson = null;
                        }
                        tags.removeAt(i);
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF424242), width: 2),
                      ),
                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          )
        ],

        // --- NÚT THÊM (+) ---
        // Luôn hiển thị ở cuối danh sách
        GestureDetector(
          onTap: () {
            // Gọi hàm dialog nhưng KHÔNG truyền index -> Hiểu là Thêm mới
            _showTagDialog(tags);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF303030),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white70, size: 20),
          ),
        ),
      ],
    );
  }
}