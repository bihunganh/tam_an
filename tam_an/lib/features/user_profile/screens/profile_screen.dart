import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../../../../core/navigation/app_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../auth_system/screens/sign_in.dart';
import '../../input_tracking/widgets/custom_app_bar.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/services/insight_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? user;

  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  final InsightService _insightService = InsightService();

  late UserModel _user;
  int _longestStreak = 0;

  // Biến lưu ảnh tạm thời (Preview)
  Uint8List? _tempAvatarBytes;

  bool _isEditing = false;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  // Biến thông báo
  String _saveMessage = '';
  Color _saveMessageColor = Colors.green;

  // --- HÀM XỬ LÝ ĐĂNG XUẤT ---
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF303030),
        title: const Text("Đăng xuất", style: TextStyle(color: AppColors.primaryBlue)),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.signOut();
              if (mounted) {
                AppRouter.pushAndRemoveUntil(context, const LoginScreen());
              }
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserIcon() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') _handleLogout();
      },
      color: const Color(0xFF353535),
      offset: const Offset(0, 50),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.redAccent),
              SizedBox(width: 10),
              Text("Đăng xuất", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryBlue, width: 2),
        ),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[800],
          backgroundImage: (_user.avatarUrl != null && _user.avatarUrl!.isNotEmpty && _user.avatarUrl!.startsWith('http'))
              ? CachedNetworkImageProvider(_user.avatarUrl!)
              : (_user.avatarUrl != null && _user.avatarUrl!.isNotEmpty
              ? MemoryImage(base64Decode(_user.avatarUrl!))
              : null) as ImageProvider<Object>?,
          child: (_user.avatarUrl == null || _user.avatarUrl!.isEmpty)
              ? Text(
            _user.username[0].toUpperCase(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          )
              : null,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _user = widget.user!;
    } else {
      final prov = Provider.of<UserProvider>(context, listen: false).user;
      _user = prov ?? UserModel(uid: '', email: '', username: 'Người dùng', dob: '', gender: 'Khác');
    }
    _usernameController = TextEditingController(text: _user.username);
    _emailController = TextEditingController(text: _user.email);
    _loadLongestStreak();
  }

    Future<void> _loadLongestStreak() async {
    final streak = await _insightService.getLongestStreak();
    if (mounted) {
      setState(() {
        _longestStreak = streak;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (picked == null || !mounted) return;

      final bytes = await picked.readAsBytes();

      setState(() {
        _tempAvatarBytes = bytes;
        _isEditing = true;
        _saveMessage = ''; // Xóa thông báo cũ nếu có
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e'), backgroundColor: Colors.redAccent));
    }
  }

  Future<void> _saveProfile() async {
    final newName = _usernameController.text.trim();
    setState(() => _saveMessage = '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
    );

    String? avatarUrlResult;
    String? errorResult;

    try {
      // 1. Upload ảnh nếu có
      if (_tempAvatarBytes != null) {
        avatarUrlResult = await _authService.uploadImageToStorage(_tempAvatarBytes!);
      }

      // 2. Cập nhật Firestore
      errorResult = await _authService.updateProfile(
        username: newName,
        avatarUrl: avatarUrlResult,
      );

    } catch (e) {
      errorResult = e.toString();
    }

    if (context.mounted) Navigator.pop(context);

    if (errorResult == null) {
      // THÀNH CÔNG
      await Provider.of<UserProvider>(context, listen: false).loadUser();

      setState(() {
        final newUser = Provider.of<UserProvider>(context, listen: false).user;
        if (newUser != null) _user = newUser;

        _isEditing = false;
        _tempAvatarBytes = null;

        // Đặt thông báo thành công
        _saveMessage = 'Đã lưu thành công';
        _saveMessageColor = Colors.green;
      });
    } else {
      // THẤT BẠI
      setState(() {
        _saveMessage = errorResult!;
        _saveMessageColor = Colors.redAccent;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _tempAvatarBytes = null;
      _usernameController.text = _user.username;
      _emailController.text = _user.email;
      _saveMessage = ''; // Xóa thông báo
    });
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryBlue),
              title: const Text('Chọn từ thư viện', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
              title: const Text('Chụp ảnh', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getAvatarImage() {
    if (_tempAvatarBytes != null) {
      return MemoryImage(_tempAvatarBytes!);
    }
    if (_user.avatarUrl != null && _user.avatarUrl!.isNotEmpty && _user.avatarUrl!.startsWith('http')) {
      return CachedNetworkImageProvider(_user.avatarUrl!);
    }
    if (_user.avatarUrl != null && _user.avatarUrl!.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(_user.avatarUrl!));
      } catch (_) { return null; }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: CustomAppBar(
        actionWidget: _buildUserIcon(),
        onLogoTap: () => Navigator.pop(context),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 28),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Column(
                  children: [
                    // --- AVATAR CHÍNH ---
                    GestureDetector(
                      onTap: _isEditing ? _showImageSourceSheet : null,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primaryBlue,
                            backgroundImage: _getAvatarImage(),
                            child: (_getAvatarImage() == null)
                                ? Text(
                              _user.username.isNotEmpty ? _user.username[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                            )
                                : null,
                          ),

                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- PHẦN TÊN / EDIT ---
                    if (!_isEditing) ...[
                      // 1. CHẾ ĐỘ XEM
                      Text(
                        _user.username,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => setState(() {
                          _isEditing = true;
                          _saveMessage = ''; // Reset thông báo khi bấm sửa
                        }),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Chỉnh sửa'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                      ),

                      // >>> THÊM VÀO ĐÂY: Hiển thị thông báo khi ở chế độ XEM (sau khi lưu thành công)
                      if (_saveMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            _saveMessage,
                            style: TextStyle(color: _saveMessageColor, fontWeight: FontWeight.bold),
                          ),
                        ),

                    ] else ...[
                      // 2. CHẾ ĐỘ SỬA
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Tên người dùng',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF353535),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                            child: const Text('Lưu'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: _cancelEdit,
                            child: const Text('Hủy', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),

                      // Hiển thị thông báo lỗi (nếu có) khi đang sửa
                      if (_saveMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            _saveMessage,
                            style: TextStyle(color: _saveMessageColor),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Các phần thống kê...
              Row(
                children: [
                  _buildStatCard("Check-in", "${_user.totalCheckins}", Icons.check_circle_outline),
                  const SizedBox(width: 12),
                  _buildStatCard("Chuỗi ngày", "$_longestStreak", Icons.local_fire_department, color: Colors.orange),
                ],
              ),
              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Thông tin cá nhân", style: TextStyle(color: AppColors.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email, "Email", _user.email),
                    const Divider(color: Colors.white10),
                    _buildInfoRow(Icons.calendar_today, "Ngày sinh", _user.dob),
                    const Divider(color: Colors.white10),
                    _buildInfoRow(Icons.person, "Giới tính", _user.gender),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {Color color = AppColors.primaryBlue}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}