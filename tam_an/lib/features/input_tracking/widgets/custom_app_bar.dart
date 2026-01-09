import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  // 1. Thêm tham số này để nhận Icon User từ bên ngoài
  final Widget? actionWidget; 
  final VoidCallback? onLogoTap;

  const CustomAppBar({
    super.key, 
    this.actionWidget, // <---
    this.onLogoTap,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  
  // ... (Giữ nguyên toàn bộ phần khai báo biến Animation và Overlay cũ)
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isDropdownOpen = false;
  final GlobalKey _iconKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // ... (Giữ nguyên logic initState cũ)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    // ... (Giữ nguyên logic dispose cũ)
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  // ... (Giữ nguyên các hàm _showOverlay, _removeOverlay, _toggleDropdown, _createOverlayEntry cũ)
  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
    _animationController.forward();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _animationController.reverse();
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    setState(() => _isDropdownOpen = false);
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  // Lưu ý: Đảm bảo bạn đã khai báo route '/login' và '/signup' trong MaterialApp
  // Hoặc bạn có thể sửa lại thành Navigator.push(...) trực tiếp tại đây
  void _navigateToLogin() {
    _removeOverlay();
    // Ví dụ sửa lại điều hướng trực tiếp nếu chưa có named route:
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    Navigator.pushNamed(context, '/login'); 
  }

  void _navigateToSignup() {
    _removeOverlay();
    Navigator.pushNamed(context, '/signup');
  }

  // ... (Giữ nguyên hàm _createOverlayEntry không thay đổi)
  OverlayEntry _createOverlayEntry() {
    final RenderBox iconBox = _iconKey.currentContext!.findRenderObject() as RenderBox;
    final Offset iconPos = iconBox.localToGlobal(Offset.zero);
    final Size iconSize = iconBox.size;

    const double menuWidth = 200.0;
    double left = iconPos.dx + iconSize.width - menuWidth; 
    left = left.clamp(8.0, MediaQuery.of(context).size.width - menuWidth - 8.0);
    final double top = iconPos.dy + iconSize.height + 8.0;

    return OverlayEntry(builder: (context) {
      return Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              GestureDetector(
                onTap: _removeOverlay,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
              Positioned(
                left: left,
                top: top,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: menuWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A4A4A),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: _navigateToLogin,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF383838),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.login, color: AppColors.primaryBlue, size: 18),
                                  SizedBox(width: 12),
                                  Text('Đăng nhập', style: TextStyle(color: AppColors.textLight, fontSize: 14, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _navigateToSignup,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              child: Row(
                                children: const [
                                  Icon(Icons.person_add, color: AppColors.primaryBlue, size: 18),
                                  SizedBox(width: 12),
                                  Text('Đăng ký', style: TextStyle(color: AppColors.textLight, fontSize: 14, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo và tên ứng dụng (Giữ nguyên)
              GestureDetector(
                onTap: () {
                  _removeOverlay();
                  if (widget.onLogoTap != null) {
                    widget.onLogoTap!();
                  } else {
                    // Mặc định (nếu ở HomeScreen) thì không làm gì hoặc reload
                    // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    if (widget.onLogoTap != null) widget.onLogoTap!();
                  },
                  child: const Text(
                    'T â m A n',
                    style: TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                    ),
                  ),
                ),
              ),

              // --- LOGIC QUYẾT ĐỊNH HIỂN THỊ ICON ---
              // Nếu widget.actionWidget != null (Tức là ĐÃ ĐĂNG NHẬP, MainScreen truyền Avatar vào)
              if (widget.actionWidget != null) 
                widget.actionWidget!
              
              // Nếu widget.actionWidget == null (Tức là CHƯA ĐĂNG NHẬP -> Hiện menu Guest cũ)
              else 
                GestureDetector(
                  onTap: _toggleDropdown,
                  child: Container(
                    key: _iconKey,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isDropdownOpen ? const Color(0xFF5A5A5A) : Colors.transparent,
                    ),
                    child: Icon(
                      Icons.person,
                      color: _isDropdownOpen ? AppColors.primaryBlue : const Color(0xFFCCCCCC),
                      size: 28,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}