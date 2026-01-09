import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import 'sign_in.dart';
import '../../input_tracking/widgets/custom_app_bar.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../main_screen.dart';
import '../../../../core/providers/user_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();

  String _selectedGender = "Nam";
  Uint8List? _avatarBytes;
  final ImagePicker _picker = ImagePicker();

  // Màu Cam đào đồng bộ toàn app
  static const Color peachColor = Color(0xFFFF8A65);

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // --- LOGIC ĐĂNG KÝ MỚI ---
  Future<void> _handleSignUp(ThemeData theme) async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final dob = _dobController.text.trim();

    // 1. Validate nhanh
    if (username.isEmpty || email.isEmpty || password.isEmpty || dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")));
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu nhập lại không khớp!")));
      return;
    }

    FocusScope.of(context).unfocus();

    // 2. Hiện Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: peachColor)),
    );

    try {
      final authService = AuthService();

      // Thực hiện đăng ký
      String? error = await authService.signUp(
        email: email,
        password: password,
        username: username,
        dob: dob,
        gender: _selectedGender,
        avatarBytes: _avatarBytes,
      );

      if (!mounted) return;
      Navigator.pop(context); // Tắt loading

      if (error == null) {
        // --- QUAN TRỌNG: NẠP DỮ LIỆU USER VÀO PROVIDER TRƯỚC KHI CHUYỂN MÀN ---
        await Provider.of<UserProvider>(context, listen: false).loadUser();

        if (!mounted) return;

        // Chuyển thẳng vào màn hình chính với thông báo thành công
        AppRouter.pushAndRemoveUntil(
            context,
            const MainScreen(showNavBar: false, showLoginSuccess: true)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating
        ));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi hệ thống: $e")));
      }
    }
  }

  // --- UI COMPONENTS ---

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source, maxWidth: 800, imageQuality: 85);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() { _avatarBytes = bytes; });
    } catch (e) { debugPrint('Error picking image: $e'); }
  }

  void _showImageSourceSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: peachColor),
              title: const Text('Chọn từ thư viện'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: peachColor),
              title: const Text('Chụp ảnh'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(onLogoTap: () => AppRouter.pushAndRemoveUntil(context, const MainScreen())),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildAvatarSection(theme),
              const SizedBox(height: 20),
              _buildFormCard(theme),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(ThemeData theme) {
    return GestureDetector(
      onTap: () => _showImageSourceSheet(theme),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: peachColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: peachColor.withOpacity(0.1),
              backgroundImage: _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
              child: _avatarBytes == null
                  ? const Icon(Icons.add_a_photo_outlined, size: 35, color: peachColor)
                  : null,
            ),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: peachColor, shape: BoxShape.circle),
              child: const Icon(Icons.edit, size: 16, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFormCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        children: [
          _buildTextField(theme, controller: _usernameController, hint: "Tên hiển thị", icon: Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(theme, controller: _emailController, hint: "Email", icon: Icons.email_outlined),
          const SizedBox(height: 16),
          _buildTextField(theme, controller: _passwordController, hint: "Mật khẩu", icon: Icons.lock_outline, isPassword: true),
          const SizedBox(height: 16),
          _buildTextField(theme, controller: _confirmPasswordController, hint: "Nhập lại mật khẩu", icon: Icons.lock_reset, isPassword: true),
          const SizedBox(height: 16),
          _buildTextField(theme, controller: _dobController, hint: "Ngày sinh", icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(context, theme)),
          const SizedBox(height: 20),

          const Align(alignment: Alignment.centerLeft, child: Text("Giới tính", style: TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGenderChip("Nam"),
              _buildGenderChip("Nữ"),
              _buildGenderChip("Khác"),
            ],
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => _handleSignUp(theme),
              style: ElevatedButton.styleFrom(
                backgroundColor: peachColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text("ĐĂNG KÝ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () => AppRouter.pushReplacement(context, const LoginScreen()),
            child: const Text("Đã có tài khoản? Đăng nhập ngay", style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, {required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller, obscureText: isPassword, readOnly: readOnly, onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: peachColor.withOpacity(0.6)),
        filled: true,
        fillColor: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey[50],
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: peachColor)),
      ),
    );
  }

  Widget _buildGenderChip(String label) {
    bool isSelected = _selectedGender == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? peachColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? peachColor : Colors.grey.withOpacity(0.3)),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, ThemeData theme) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime(2000), firstDate: DateTime(1900), lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dobController.text = DateFormat('dd/MM/yyyy').format(picked));
  }
}