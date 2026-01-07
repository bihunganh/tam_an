import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> _syncTagsToFirebase() async {
    if (_currentUser == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).update({
        'locationTags': locations,
        'activityTags': activities,
        'companionTags': people,
      });
    } catch (e) {
      debugPrint("Lỗi lưu tag: $e");
    }
  }

  Future<void> _handleSaveCheckIn() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

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

      final checkInService = CheckInService();
      await checkInService.addNewCheckIn(newCheckIn);

      if (mounted) Navigator.pop(context);

      messenger.showSnackBar(
        SnackBar(
          content: Text("Đã lưu: ${widget.moodLabel}"),
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
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Màu nền tự động đổi Trắng/Xám
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Thanh kéo và nút Edit
          _buildHeader(theme),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Text(
                          "Cảm thấy ${widget.moodLabel}",
                          style: TextStyle(color: theme.colorScheme.primary, fontSize: 20, fontWeight: FontWeight.bold)
                      )
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('BẠN ĐANG Ở ĐÂU?', Icons.location_on, theme),
                  const SizedBox(height: 12),
                  _buildTagGroup(locations, selectedLocation, (val) => setState(() => selectedLocation = val), theme),

                  const SizedBox(height: 24),

                  _buildSectionTitle('BẠN ĐANG LÀM GÌ?', Icons.work, theme),
                  const SizedBox(height: 12),
                  _buildTagGroup(activities, selectedActivity, (val) => setState(() => selectedActivity = val), theme),

                  const SizedBox(height: 24),

                  _buildSectionTitle('BẠN ĐANG Ở VỚI AI?', Icons.people, theme),
                  const SizedBox(height: 12),
                  _buildTagGroup(people, selectedPerson, (val) => setState(() => selectedPerson = val), theme),

                  const SizedBox(height: 24),

                  if (!_isEditing)
                    _buildNoteField(theme),

                  const SizedBox(height: 30),

                  if (!_isEditing)
                    _buildSubmitButton(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () => setState(() => _isEditing = !_isEditing),
              icon: Icon(_isEditing ? Icons.check_circle : Icons.edit),
              color: _isEditing ? theme.colorScheme.primary : theme.iconTheme.color?.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Row(children: [
      Text(title, style: TextStyle(color: theme.textTheme.labelLarge?.color?.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      const SizedBox(width: 6),
      Icon(icon, color: theme.colorScheme.primary.withOpacity(0.5), size: 14)
    ]);
  }

  Widget _buildNoteField(ThemeData theme) {
    return TextField(
      controller: _noteController,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: 'Ghi chú thêm...',
        filled: true,
        fillColor: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSaveCheckIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Hoàn Tất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  void _showTagDialog(List<String> list, {int? index}) {
    final theme = Theme.of(context);
    final bool isEditing = index != null;
    TextEditingController controller = TextEditingController(text: isEditing ? list[index] : "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(isEditing ? "Sửa Tag" : "Thêm Tag Mới"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Nhập tên tag..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    if (isEditing) list[index] = text;
                    else list.add(text);
                  });
                  _syncTagsToFirebase();
                }
                Navigator.pop(context);
              },
              child: const Text("Lưu", style: TextStyle(fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Widget _buildTagGroup(List<String> tags, String? selectedValue, Function(String) onSelect, ThemeData theme) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: [
        for (int i = 0; i < tags.length; i++)
          _buildTagChip(tags, i, selectedValue, onSelect, theme),

        GestureDetector(
          onTap: () => _showTagDialog(tags),
          child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(Icons.add, color: theme.iconTheme.color?.withOpacity(0.5), size: 20)
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(List<String> tags, int i, String? selectedValue, Function(String) onSelect, ThemeData theme) {
    bool isSelected = tags[i] == selectedValue;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _isEditing ? _showTagDialog(tags, index: i) : onSelect(tags[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: _isEditing ? Border.all(color: theme.colorScheme.primary.withOpacity(0.3)) : null
            ),
            child: Text(
                tags[i],
                style: TextStyle(
                    color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13
                )
            ),
          ),
        ),
        if (_isEditing)
          Positioned(
              top: -5, right: -5,
              child: GestureDetector(
                  onTap: () {
                    setState(() { tags.removeAt(i); });
                    _syncTagsToFirebase();
                  },
                  child: Container(
                      decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.surface, width: 2)),
                      child: const Icon(Icons.close, size: 14, color: Colors.white)
                  )
              )
          ),
      ],
    );
  }
}