import 'package:flutter/material.dart';
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
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/insight_service.dart';
import '../../../../core/widgets/background_wrapper.dart';

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
      setState(() => _longestStreak = streak);
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
        _saveMessage = '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn ảnh: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _saveProfile() async {
    final newName = _usernameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _saveMessage = '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    String? avatarUrlResult;
    String? errorResult;

    try {
      if (_tempAvatarBytes != null) {
        avatarUrlResult = await _authService.uploadImageToStorage(_tempAvatarBytes!);
      }
      errorResult = await _authService.updateProfile(
        username: newName,
        avatarUrl: avatarUrlResult,
      );
    } catch (e) {
      errorResult = e.toString();
    }

    if (!mounted) return;
    Navigator.pop(context);

    if (errorResult == null) {
      await Provider.of<UserProvider>(context, listen: false).loadUser();
      setState(() {
        final newUser = Provider.of<UserProvider>(context, listen: false).user;
        if (newUser != null) _user = newUser;
        _isEditing = false;
        _tempAvatarBytes = null;
        _saveMessage = 'Đã lưu thành công';
        _saveMessageColor = Colors.green;
      });
    } else {
      setState(() {
        _saveMessage = 'Lỗi: $errorResult';
        _saveMessageColor = Colors.redAccent;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _tempAvatarBytes = null;
      _usernameController.text = _user.username;
      _saveMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          actionWidget: _buildUserIcon(theme),
          onLogoTap: () => Navigator.pop(context),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildHeaderProfile(theme),
                
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    _buildStatCard("Check-in", "${_user.totalCheckins}", Icons.check_circle_outline, theme),
                    const SizedBox(width: 16),
                    _buildStatCard("Chuỗi ngày", "$_longestStreak", Icons.local_fire_department, theme, color: Colors.orange),
                  ],
                ),
                
                const SizedBox(height: 32),
                _buildSectionTitle(theme, "Thông tin cá nhân"),
                const SizedBox(height: 12),
                _buildInfoContainer(theme),
                
                const SizedBox(height: 32),
                _buildSectionTitle(theme, "Cài đặt ứng dụng"),
                const SizedBox(height: 12),
                _buildThemeSwitch(theme, isDark, themeProvider),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
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
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: theme.colorScheme.surface,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      backgroundImage: _getAvatarImage(),
                      child: (_getAvatarImage() == null)
                          ? Text(_user.username.isNotEmpty ? _user.username[0].toUpperCase() : '?',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: theme.colorScheme.primary))
                          : null,
                    ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 4, right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.surface, width: 2)),
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!_isEditing) ...[
            Text(_user.username, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => setState(() { _isEditing = true; _saveMessage = ''; }),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Chỉnh sửa hồ sơ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                foregroundColor: theme.colorScheme.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _usernameController,
                autofocus: true,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Tên hiển thị',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _saveProfile, 
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32)),
                  child: const Text('Lưu thay đổi')
                ),
                const SizedBox(width: 12),
                TextButton(onPressed: _cancelEdit, child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
              ],
            ),
          ],
          if (_saveMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(_saveMessage, style: TextStyle(color: _saveMessageColor, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildThemeSwitch(ThemeData theme, bool isDark, ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: SwitchListTile(
        title: const Text("Giao diện tối", style: TextStyle(fontWeight: FontWeight.w600)),
        secondary: Icon(isDark ? Icons.nights_stay : Icons.wb_sunny_rounded,
            color: isDark ? const Color(0xFFFFD740) : const Color(0xFFFF7043)),
        value: isDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onChanged: (bool value) => themeProvider.toggleTheme(),
      ),
    );
  }

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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Thay đổi ảnh đại diện", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined), 
                title: const Text('Chọn từ thư viện'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined), 
                title: const Text('Chụp ảnh mới'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, ThemeData theme, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: (color ?? theme.colorScheme.primary).withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color ?? theme.colorScheme.primary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            Text(title, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoContainer(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, "Email", _user.email, theme),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: theme.dividerColor.withOpacity(0.05), height: 1),
          ),
          _buildInfoRow(Icons.cake_outlined, "Ngày sinh", _user.dob, theme),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: theme.dividerColor.withOpacity(0.05), height: 1),
          ),
          _buildInfoRow(Icons.person_outline, "Giới tính", _user.gender, theme),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.6), size: 20),
        ),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 15, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title, 
      style: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.4), 
        fontSize: 13, 
        fontWeight: FontWeight.w800, 
        letterSpacing: 1.2,
        textBaseline: TextBaseline.alphabetic
      )
    );
  }

  Widget _buildUserIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 2)),
      child: CircleAvatar(radius: 16, backgroundColor: Colors.grey[200], backgroundImage: _getAvatarImage()),
    );
  }
}