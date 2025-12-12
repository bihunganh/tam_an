import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
// Use named routes for navigation to avoid circular imports

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isDropdownOpen = false;
  final GlobalKey _iconKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
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
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)!.insert(_overlayEntry!);
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

  void _navigateToLogin() {
    _removeOverlay();
    Navigator.pushNamed(context, '/login');
  }

  void _navigateToSignup() {
    _removeOverlay();
    Navigator.pushNamed(context, '/signup');
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox iconBox = _iconKey.currentContext!.findRenderObject() as RenderBox;
    final Offset iconPos = iconBox.localToGlobal(Offset.zero);
    final Size iconSize = iconBox.size;

    const double menuWidth = 200.0;
    double left = iconPos.dx + iconSize.width - menuWidth; // align right under icon
    left = left.clamp(8.0, MediaQuery.of(context).size.width - menuWidth - 8.0);
    final double top = iconPos.dy + iconSize.height + 8.0;

    return OverlayEntry(builder: (context) {
      return Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Barrier
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
                                  Icon(
                                    Icons.login,
                                    color: AppColors.primaryYellow,
                                    size: 18,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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
                                  Icon(
                                    Icons.person_add,
                                    color: AppColors.primaryYellow,
                                    size: 18,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Đăng ký',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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
              // Logo và tên ứng dụng
              GestureDetector(
                onTap: () {
                  _removeOverlay();
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
              // Icon User với chức năng toggle dropdown
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
                    color: _isDropdownOpen ? AppColors.primaryYellow : const Color(0xFFCCCCCC),
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
