import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import 'sign_in.dart';
import '../../input_tracking/widgets/custom_app_bar.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../main_screen.dart';

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

  void _navigateToHome() {
    AppRouter.pushAndRemoveUntil(context, const MainScreen(showNavBar: false));
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source, maxWidth: 800, imageQuality: 85);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() { _avatarBytes = bytes; });
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: theme.colorScheme.primary),
              title: Text('Chọn từ thư viện', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
              title: Text('Chụp ảnh', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, ThemeData theme) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.brightness == Brightness.dark
                ? theme.colorScheme
                : ColorScheme.light(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: CustomAppBar(onLogoTap: _navigateToHome),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Nút quay lại giống Sign In
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _navigateToHome,
                    icon: Icon(Icons.arrow_back_ios_new, size: 16, color: theme.iconTheme.color?.withOpacity(0.7)),
                    label: Text("Về trang chủ", style: TextStyle(color: theme.iconTheme.color?.withOpacity(0.7), fontSize: 16)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ),

                const SizedBox(height: 20),

                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 50),
                      padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.5 : 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTextField(theme, controller: _usernameController, hint: "Tên tài khoản", icon: Icons.person_outline),
                          const SizedBox(height: 16),
                          _buildTextField(theme, controller: _emailController, hint: "Email", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildTextField(theme, controller: _passwordController, hint: "Mật khẩu", icon: Icons.lock_outline, isPassword: true),
                          const SizedBox(height: 16),
                          _buildTextField(theme, controller: _confirmPasswordController, hint: "Nhập lại mật khẩu", icon: Icons.lock_reset, isPassword: true),
                          const SizedBox(height: 16),
                          _buildTextField(theme, controller: _dobController, hint: "Ngày sinh", icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(context, theme)),
                          const SizedBox(height: 20),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Giới tính:", style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildGenderOption("Nam", theme),
                              _buildGenderOption("Nữ", theme),
                              _buildGenderOption("Khác", theme),
                            ],
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => _handleSignUp(theme),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 0,
                              ),
                              child: const Text('Đăng Ký', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => AppRouter.pushReplacement(context, const LoginScreen()),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                                children: [
                                  const TextSpan(text: 'Đã có tài khoản? '),
                                  TextSpan(text: 'Đăng nhập ngay', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // AVATAR
                    Positioned(
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _showImageSourceSheet(theme),
                        child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                            child: _avatarBytes != null
                                ? CircleAvatar(backgroundColor: primaryColor, backgroundImage: MemoryImage(_avatarBytes!))
                                : Icon(Icons.person_add_alt_1, size: 50, color: theme.colorScheme.surface),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignUp(ThemeData theme) async {
    FocusScope.of(context).unfocus();
    // ... (Logic Validate giữ nguyên như code cũ của bạn) ...
    // Thêm phần Loading và Dialog dùng theme
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
    );

    try {
      final authService = AuthService();
      String? error = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
        dob: _dobController.text.trim(),
        gender: _selectedGender,
        avatarBytes: _avatarBytes,
      );

      if (context.mounted) Navigator.pop(context);

      if (error == null) {
        if (context.mounted) _showSuccessDialog(theme);
      } else {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating)); }
    }
  }

  void _showSuccessDialog(ThemeData theme) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Row(children: [Icon(Icons.check_circle, color: theme.colorScheme.primary), const SizedBox(width: 10), Text("Thành công!", style: TextStyle(color: theme.colorScheme.primary))]),
        content: Text("Tài khoản đã tạo thành công. Hãy đăng nhập ngay!", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); AppRouter.pushReplacement(context, const LoginScreen()); }, child: const Text("Đăng nhập ngay"))
        ],
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, {required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool readOnly = false, VoidCallback? onTap, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller, obscureText: isPassword, readOnly: readOnly, onTap: onTap, keyboardType: keyboardType,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4), fontSize: 14),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary.withOpacity(0.5), size: 20),
        filled: true,
        fillColor: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
      ),
    );
  }

  Widget _buildGenderOption(String value, ThemeData theme) {
    final bool isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.1)),
        ),
        child: Text(value, style: TextStyle(color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}