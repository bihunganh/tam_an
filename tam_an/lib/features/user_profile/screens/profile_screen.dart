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
import '../../../../core/providers/theme_provider.dart'; // 1. Import ThemeProvider
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
  Uint8List? _tempAvatarBytes;
  bool _isEditing = false;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  String _saveMessage = '';
  Color _saveMessageColor = Colors.green;

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

  // --- XỬ LÝ ĐĂNG XUẤT ---
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor, // Dùng màu theme
        title: Text("Đăng xuất", style: TextStyle(color: Theme.of(context).primaryColor)),
        content: Text("Bạn có chắc chắn muốn đăng xuất không?",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
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

  @override
  Widget build(BuildContext context) {
    // 2. Lắng nghe Provider để biết đang ở chế độ nào
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Tự động lấy trắng/đen

      appBar: CustomAppBar(
        actionWidget: _buildUserIcon(theme),
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
                  icon: Icon(Icons.arrow_back, color: theme.iconTheme.color, size: 28),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),

              const SizedBox(height: 10),

              // --- AVATAR & NAME SECTION ---
              _buildHeaderProfile(theme),

              const SizedBox(height: 30),

              // --- STATS CARDS ---
              Row(
                children: [
                  _buildStatCard("Check-in", "${_user.totalCheckins}", Icons.check_circle_outline, theme),
                  const SizedBox(width: 12),
                  _buildStatCard("Chuỗi ngày", "$_longestStreak", Icons.local_fire_department, theme, color: Colors.orange),
                ],
              ),
              const SizedBox(height: 30),

              // --- THÔNG TIN CÁ NHÂN ---
              _buildSectionTitle(theme, "Thông tin cá nhân"),
              const SizedBox(height: 10),
              _buildInfoContainer(theme),

              const SizedBox(height: 30),

              // --- 3. CÀI ĐẶT ỨNG DỤNG (NƠI ĐỔI THEME) ---
              _buildSectionTitle(theme, "Cài đặt ứng dụng"),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                ),
                child: SwitchListTile(
                  title: Text("Chế độ tối",
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w500)),
                  subtitle: Text(isDark ? "Đang bật" : "Đang tắt",
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode,
                      color: isDark ? const Color(0xFFFFE14D) : const Color(0xFF3366FF)),
                  value: isDark,
                  activeColor: const Color(0xFFFFE14D),
                  onChanged: (bool value) {
                    themeProvider.toggleTheme(); // 4. Gọi hàm đổi theme
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS CON ĐÃ ĐƯỢC TỐI ƯU ---

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHeaderProfile(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _isEditing ? _showImageSourceSheet : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary,
                  backgroundImage: _getAvatarImage(),
                  child: (_getAvatarImage() == null)
                      ? Text(_user.username[0].toUpperCase(),
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary))
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!_isEditing) ...[
            Text(_user.username, style: TextStyle(color: theme.textTheme.headlineSmall?.color, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => setState(() { _isEditing = true; _saveMessage = ''; }),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Chỉnh sửa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ] else ...[
            // Chế độ sửa (TextField)
            TextField(
              controller: _usernameController,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: 'Tên người dùng',
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _saveProfile, child: const Text('Lưu')),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: _cancelEdit, child: const Text('Hủy')),
              ],
            ),
          ],
          if (_saveMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(_saveMessage, style: TextStyle(color: _saveMessageColor, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email, "Email", _user.email, theme),
          Divider(color: theme.dividerColor.withOpacity(0.1)),
          _buildInfoRow(Icons.calendar_today, "Ngày sinh", _user.dob, theme),
          Divider(color: theme.dividerColor.withOpacity(0.1)),
          _buildInfoRow(Icons.person, "Giới tính", _user.gender, theme),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, ThemeData theme, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color ?? theme.colorScheme.primary, size: 30),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: theme.textTheme.titleLarge?.color, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const Spacer(),
          Text(value, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildUserIcon(ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: (value) { if (value == 'logout') _handleLogout(); },
      color: theme.cardColor,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'logout', child: Text("Đăng xuất", style: TextStyle(color: Colors.redAccent))),
      ],
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.primary, width: 2)),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey,
          backgroundImage: _getAvatarImage(),
        ),
      ),
    );
  }

  // --- CÁC HÀM PHỤ TRỢ GIỮ NGUYÊN ---
  ImageProvider? _getAvatarImage() {
    if (_tempAvatarBytes != null) return MemoryImage(_tempAvatarBytes!);
    if (_user.avatarUrl != null && _user.avatarUrl!.isNotEmpty) {
      if (_user.avatarUrl!.startsWith('http')) return CachedNetworkImageProvider(_user.avatarUrl!);
      try { return MemoryImage(base64Decode(_user.avatarUrl!)); } catch (_) {}
    }
    return null;
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Thư viện'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Máy ảnh'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() { _tempAvatarBytes = bytes; _isEditing = true; });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saveMessage = '');
    // ... logic lưu profile của bạn ...
    setState(() {
      _isEditing = false;
      _saveMessage = 'Đã lưu thành công';
      _saveMessageColor = Colors.green;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _tempAvatarBytes = null;
      _saveMessage = '';
    });
  }
}