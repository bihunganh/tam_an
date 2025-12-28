import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Để update Firestore
import '../../../core/constants/app_colors.dart';
import '../../../../data/models/checkin_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/checkin_service.dart';

class CheckInOverlay extends StatefulWidget {
  final String moodLabel;
  final int moodLevel;

  const CheckInOverlay({
    super.key, 
    required this.moodLabel,
    required this.moodLevel,
  });

  @override
  State<CheckInOverlay> createState() => _CheckInOverlayState();
}

class _CheckInOverlayState extends State<CheckInOverlay> {
  // Không dùng static nữa để dữ liệu linh hoạt theo user
  List<String> locations = ["Ở Nhà", "Ngoài đường", "Công ty"];
  List<String> activities = ["Họp", "Code", "Học Bài", "Lướt Web", "Nghỉ Ngơi", "Ăn uống"];
  List<String> people = ["Một Mình", "Bạn Bè", "Gia Đình", "Đồng nghiệp"];

  String? selectedLocation;
  String? selectedActivity;
  String? selectedPerson;
  final TextEditingController _noteController = TextEditingController();
  
  bool _isEditing = false; 
  bool _isLoading = false;
  UserModel? _currentUser; // Lưu user để dùng ID cập nhật

  @override
  void initState() {
    super.initState();
    _loadUserTags();
  }

  // 1. HÀM TẢI TAG TỪ FIREBASE
  Future<void> _loadUserTags() async {
    final authService = AuthService();
    final user = await authService.getCurrentUser();
    
    if (user != null) {
      setState(() {
        _currentUser = user;
        // Nếu user đã có tag riêng lưu trên server thì dùng, không thì dùng mặc định
        if (user.locationTags.isNotEmpty) locations = List.from(user.locationTags);
        if (user.activityTags.isNotEmpty) activities = List.from(user.activityTags);
        if (user.companionTags.isNotEmpty) people = List.from(user.companionTags);
      });
    }
  }

  // 2. HÀM CẬP NHẬT TAG LÊN FIREBASE (Chạy mỗi khi thêm/sửa/xóa)
  Future<void> _syncTagsToFirebase() async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).update({
        'locationTags': locations,
        'activityTags': activities,
        'companionTags': people,
      });
    } catch (e) {
      print("Lỗi lưu tag: $e");
    }
  }

  Future<void> _handleSaveCheckIn() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng đăng nhập!")));
      return;
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      List<String> companions = selectedPerson != null ? [selectedPerson!] : [];
      List<String> activityTags = selectedActivity != null ? [selectedActivity!] : [];

      CheckInModel newCheckIn = CheckInModel(
        id: '',
        userId: _currentUser!.uid,
        timestamp: DateTime.now(),
        moodLabel: widget.moodLabel,
        moodLevel: widget.moodLevel,
        location: selectedLocation ?? '',
        companions: companions,
        activities: activityTags,
        note: _noteController.text.trim(),
      );

      final checkInService = CheckInService();
      await checkInService.addNewCheckIn(newCheckIn);

      if (mounted) Navigator.pop(context);
      
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text("Đã lưu: ${widget.moodLabel}"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF424242),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Header
          Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _isEditing = !_isEditing),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: _isEditing ? AppColors.primaryBlue : Colors.white10, shape: BoxShape.circle),
                      child: Icon(_isEditing ? Icons.check : Icons.edit, size: 20, color: _isEditing ? Colors.black : Colors.white),
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
                  Center(child: Text("Cảm thấy ${widget.moodLabel}", style: const TextStyle(color: AppColors.primaryBlue, fontSize: 20, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 20),

                  _buildSectionTitle('BẠN ĐANG Ở ĐÂU?', Icons.location_on),
                  const SizedBox(height: 10),
                  _buildTagGroup(locations, selectedLocation, (val) => setState(() => selectedLocation = val)),

                  const SizedBox(height: 24),

                  _buildSectionTitle('BẠN ĐANG LÀM GÌ?', Icons.work),
                  const SizedBox(height: 10),
                  _buildTagGroup(activities, selectedActivity, (val) => setState(() => selectedActivity = val)),

                  const SizedBox(height: 24),

                  _buildSectionTitle('BẠN ĐANG Ở VỚI AI?', Icons.people),
                  const SizedBox(height: 10),
                  _buildTagGroup(people, selectedPerson, (val) => setState(() => selectedPerson = val)),

                  const SizedBox(height: 24),

                  if (!_isEditing)
                    TextField(
                      controller: _noteController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ghi chú thêm...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF303030),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),

                  const SizedBox(height: 30),

                  if (!_isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSaveCheckIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Text('Hoàn Tất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(children: [Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)), const SizedBox(width: 8), Icon(icon, color: Colors.white70, size: 14)]);
  }

  void _showTagDialog(List<String> list, {int? index}) {
    final bool isEditing = index != null;
    TextEditingController controller = TextEditingController(text: isEditing ? list[index] : "");
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF303030),
        title: Text(isEditing ? "Sửa Tag" : "Thêm Tag Mới", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "Nhập tên tag...", hintStyle: TextStyle(color: Colors.white38), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryBlue))),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  if (isEditing) {
                    list[index] = text;
                  } else {
                    list.add(text);
                  }
                });
                // --- 3. QUAN TRỌNG: LƯU LẠI VÀO FIREBASE ---
                _syncTagsToFirebase(); 
              }
              Navigator.pop(context);
            }, 
            child: const Text("Lưu", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Widget _buildTagGroup(List<String> tags, String? selectedValue, Function(String) onSelect) {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: [
        for (int i = 0; i < tags.length; i++) ...[
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  if (_isEditing) { _showTagDialog(tags, index: i); } else { onSelect(tags[i]); }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: _isEditing ? const Color(0xFF303030).withOpacity(0.5) : (tags[i] == selectedValue ? Colors.white : const Color(0xFF303030)), borderRadius: BorderRadius.circular(20), border: _isEditing ? Border.all(color: Colors.white24) : null),
                  child: Text(tags[i], style: TextStyle(color: _isEditing ? Colors.white70 : (tags[i] == selectedValue ? Colors.black : Colors.white), fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              if (_isEditing) Positioned(top: -6, right: -6, child: GestureDetector(
                onTap: () { 
                  setState(() { 
                    if (selectedValue == tags[i]) {
                      if (tags == locations) selectedLocation = null;
                      if (tags == activities) selectedActivity = null;
                      if (tags == people) selectedPerson = null;
                    }
                    tags.removeAt(i); 
                  });
                  // --- 3. QUAN TRỌNG: XÓA CŨNG PHẢI LƯU ---
                  _syncTagsToFirebase();
                }, 
                child: Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF424242), width: 2)), child: const Icon(Icons.close, size: 12, color: Colors.white))
              )),
            ],
          )
        ],
        GestureDetector(
          onTap: () { _showTagDialog(tags); },
          child: Container(width: 36, height: 36, decoration: const BoxDecoration(color: Color(0xFF303030), shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white70, size: 20)),
        ),
      ],
    );
  }
}