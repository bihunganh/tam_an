import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../auth_system/screens/sign_in.dart';
import '../../input_tracking/widgets/custom_app_bar.dart';
import '../../../../core/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? user;

  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  // Local mutable copy of user to update UI after avatar change
  late UserModel _user;

  Uint8List? _avatarBytes;
  String? _avatarBase64;
  bool _isEditing = false;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  String _saveMessage = '';
  Color _saveMessageColor = Colors.green;

  // --- HÀM XỬ LÝ ĐĂNG XUẤT (Copy từ MainScreen sang) ---
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF303030),
        title: const Text("Đăng xuất", style: TextStyle(color: AppColors.primaryYellow)),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Đóng dialog
              await _authService.signOut(); // Gọi Firebase logout
              
              if (mounted) {
                // Quay về màn hình Login, xóa hết lịch sử
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // --- TẠO ICON AVATAR CHO APPBAR ---
  Widget _buildUserIcon() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') {
          _handleLogout();
        }
        // Không cần case 'profile' vì đang ở trang profile rồi
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
      // Icon đại diện
        child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryYellow, width: 2),
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
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                )
              : null,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Prefer provided user; otherwise read from provider
    if (widget.user != null) {
      _user = widget.user!;
    } else {
      final prov = Provider.of<UserProvider>(context, listen: false).user;
      _user = prov ?? UserModel(uid: '', email: '', username: 'Người dùng', dob: '', gender: 'Khác');
    }
    _avatarBase64 = _user.avatarUrl;
    _usernameController = TextEditingController(text: _user.username);
    _emailController = TextEditingController(text: _user.email);
    if (_avatarBase64 != null && _avatarBase64!.isNotEmpty) {
      try {
        _avatarBytes = base64Decode(_avatarBase64!);
      } catch (_) {
        _avatarBytes = null;
      }
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
      final XFile? picked = await _picker.pickImage(source: source, maxWidth: 1200, imageQuality: 85);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final base64str = base64Encode(bytes);

      // Gọi service để cập nhật avatar (upload bytes to Storage)
      String? err = await _authService.updateAvatarFromBytes(bytes);
      if (err == null) {
        setState(() {
          _avatarBytes = bytes;
          _avatarBase64 = base64str;
          _user = UserModel(
            uid: _user.uid,
            email: _user.email,
            username: _user.username,
            dob: _user.dob,
            gender: _user.gender,
            avatarUrl: _avatarBase64,
            totalCheckins: _user.totalCheckins,
            currentStreak: _user.currentStreak,
            moodCounts: _user.moodCounts,
          );
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật avatar thành công')));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.redAccent));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error pick avatar: $e');
    }
  }

  Future<void> _saveProfile() async {
    final newName = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();
    // Validate email format before saving
    final emailRegex = RegExp(r"^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}");
    if (newEmail.isNotEmpty && !emailRegex.hasMatch(newEmail)) {
      setState(() {
        _saveMessage = 'Email không hợp lệ, vui lòng nhập đúng định dạng.';
        _saveMessageColor = Colors.redAccent;
      });
      return;
    }

    // clear previous message
    setState(() {
      _saveMessage = '';
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow)),
    );

    String? err = await _authService.updateProfile(username: newName, email: newEmail);

    if (context.mounted) Navigator.pop(context); // close loading

    if (err == null) {
      setState(() {
        _user = UserModel(
          uid: _user.uid,
          email: newEmail.isNotEmpty ? newEmail : _user.email,
          username: newName.isNotEmpty ? newName : _user.username,
          dob: _user.dob,
          gender: _user.gender,
          avatarUrl: _user.avatarUrl,
          totalCheckins: _user.totalCheckins,
          currentStreak: _user.currentStreak,
          moodCounts: _user.moodCounts,
        );
        _isEditing = false;
        _saveMessage = 'Cập nhật thông tin thành công.';
        _saveMessageColor = Colors.green;
      });
    } else {
      setState(() {
        _saveMessage = err;
        _saveMessageColor = Colors.redAccent;
      });
    }
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
              leading: const Icon(Icons.photo_library, color: AppColors.primaryYellow),
              title: const Text('Chọn từ thư viện', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryYellow),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
      // --- APPBAR ĐÃ SỬA ---
      appBar: CustomAppBar(
        // 1. Truyền Avatar vào để hiện trạng thái "Đã đăng nhập"
        actionWidget: _buildUserIcon(),
        // 2. Bấm vào Logo Tâm An -> Quay về Home
        onLogoTap: () {
          Navigator.pop(context);
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- 3. NÚT BACK THỦ CÔNG ---
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

              // 1. AVATAR & TÊN TO
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isEditing ? _showImageSourceSheet : null,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryYellow,
                        backgroundImage: (_user.avatarUrl != null && _user.avatarUrl!.isNotEmpty && _user.avatarUrl!.startsWith('http'))
                            ? CachedNetworkImageProvider(_user.avatarUrl!)
                            : (_user.avatarUrl != null && _user.avatarUrl!.isNotEmpty
                                ? MemoryImage(base64Decode(_user.avatarUrl!))
                                : null) as ImageProvider<Object>?,
                        child: (_user.avatarUrl == null || _user.avatarUrl!.isEmpty)
                            ? Text(
                                _user.username[0].toUpperCase(),
                                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name / Email or editable fields
                    if (!_isEditing) ...[
                      Text(
                        _user.username,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _user.email,
                        style: const TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _isEditing = true),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Chỉnh sửa'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow, foregroundColor: Colors.black),
                      ),
                    ] else ...[
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Tên người dùng',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xFF353535),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xFF353535),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('Lưu'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow, foregroundColor: Colors.black),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _usernameController.text = _user.username;
                                _emailController.text = _user.email;
                                _saveMessage = '';
                              });
                            },
                            child: const Text('Hủy', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      // Save / Error message area
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

              // 2. THỐNG KÊ (STATISTIC)
              Row(
                children: [
                  _buildStatCard("Check-in", "${_user.totalCheckins}", Icons.check_circle_outline),
                  const SizedBox(width: 12),
                  _buildStatCard("Chuỗi ngày", "${_user.currentStreak}", Icons.local_fire_department, color: Colors.orange),
                ],
              ),
              const SizedBox(height: 20),

              // 3. THÔNG TIN CÁ NHÂN
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Thông tin cá nhân", style: TextStyle(color: AppColors.primaryYellow, fontSize: 18, fontWeight: FontWeight.bold)),
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

  // Widget con để vẽ thẻ thống kê
  Widget _buildStatCard(String title, String value, IconData icon, {Color color = AppColors.primaryYellow}) {
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

  // Widget con để vẽ dòng thông tin
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