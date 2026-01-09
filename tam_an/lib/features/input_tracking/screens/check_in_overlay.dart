import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
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
  List<String> locations = ["Ở Nhà", "Ngoài đường", "Công ty"];
  List<String> activities = ["Họp", "Code", "Học Bài", "Lướt Web", "Nghỉ Ngơi", "Ăn uống"];
  List<String> people = ["Một Mình", "Bạn Bè", "Gia Đình", "Đồng nghiệp"];

  String? selectedLocation;
  String? selectedActivity;
  String? selectedPerson;
  final TextEditingController _noteController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserTags();
  }

  Future<void> _loadUserTags() async {
    final authService = AuthService();
    final user = await authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUser = user;
        if (user.locationTags.isNotEmpty) locations = List.from(user.locationTags);
        if (user.activityTags.isNotEmpty) activities = List.from(user.activityTags);
        if (user.companionTags.isNotEmpty) people = List.from(user.companionTags);
      });
    }
  }

  // --- LOGIC LƯU DỮ LIỆU GIỮ NGUYÊN ---
  Future<void> _handleSaveCheckIn() async {
    if (_currentUser == null) return;
    setState(() => _isLoading = true);
    try {
      CheckInModel newCheckIn = CheckInModel(
        id: '',
        userId: _currentUser!.uid,
        timestamp: DateTime.now(),
        moodLabel: widget.moodLabel,
        moodLevel: widget.moodLevel,
        location: selectedLocation ?? '',
        companions: selectedPerson != null ? [selectedPerson!] : [],
        activities: selectedActivity != null ? [selectedActivity!] : [],
        note: _noteController.text.trim(),
      );
      await CheckInService().addNewCheckIn(newCheckIn);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Hiệu ứng kính mờ
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.85),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              _buildHeader(theme),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 10, 24, 20 + bottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mood Title mượt mà
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Hôm nay bạn",
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
                            ),
                            Text(
                              widget.moodLabel,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),

                      _buildSection('BẠN ĐANG Ở ĐÂU?', Icons.location_on_outlined, locations, selectedLocation, (val) => setState(() => selectedLocation = val), theme),
                      _buildSection('BẠN ĐANG LÀM GÌ?', Icons.auto_awesome_outlined, activities, selectedActivity, (val) => setState(() => selectedActivity = val), theme),
                      _buildSection('BẠN ĐANG CÙNG AI?', Icons.favorite_outline, people, selectedPerson, (val) => setState(() => selectedPerson = val), theme),

                      const SizedBox(height: 10),
                      if (!_isEditing) _buildNoteField(theme),
                      const SizedBox(height: 30),
                      if (!_isEditing) _buildSubmitButton(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<String> tags, String? selected, Function(String) onSelect, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary.withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withOpacity(0.4), letterSpacing: 1.2)),
          ],
        ),
        const SizedBox(height: 15),
        _buildTagGroup(tags, selected, onSelect, theme),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildTagGroup(List<String> tags, String? selectedValue, Function(String) onSelect, ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (int i = 0; i < tags.length; i++)
          _buildAnimatedTag(tags, i, selectedValue, onSelect, theme),

        // Nút thêm Tag cách điệu
        GestureDetector(
          onTap: () => _showTagDialog(tags),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: theme.colorScheme.primary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTag(List<String> tags, int i, String? selectedValue, Function(String) onSelect, ThemeData theme) {
    bool isSelected = tags[i] == selectedValue;
    return GestureDetector(
      onTap: () => _isEditing ? _showTagDialog(tags, index: i) : onSelect(tags[i]),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          border: Border.all(
            color: isSelected ? Colors.transparent : theme.colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
        child: Text(
          tags[i],
          style: TextStyle(
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteField(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _noteController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Hôm nay có điều gì đặc biệt không?...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSaveCheckIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Lưu khoảnh khắc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  // --- HEADER & CÁC HÀM PHỤ GIỮ NGUYÊN LOGIC ---
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Container(width: 50, height: 5, decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
          IconButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: Icon(_isEditing ? Icons.check_circle : Icons.tune_rounded),
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  // (Các hàm _showTagDialog, _syncTagsToFirebase giữ nguyên logic cũ của bạn)
  void _showTagDialog(List<String> list, {int? index}) {
    final theme = Theme.of(context);
    final bool isEditing = index != null;
    TextEditingController controller = TextEditingController(text: isEditing ? list[index] : "");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEditing ? "Chỉnh sửa" : "Thêm mới"),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: "Nhập nội dung...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
          TextButton(onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              setState(() { if (isEditing) list[index] = controller.text.trim(); else list.add(controller.text.trim()); });
            }
            Navigator.pop(context);
          }, child: const Text("Lưu")),
        ],
      ),
    );
  }
}