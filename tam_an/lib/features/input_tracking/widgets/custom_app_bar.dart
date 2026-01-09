import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? actionWidget;
  final VoidCallback? onLogoTap;

  const CustomAppBar({
    super.key,
    this.actionWidget,
    this.onLogoTap,
  });

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
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
    _animationController.forward();
  }

  void _removeOverlay() {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    if (mounted) {
      setState(() => _isDropdownOpen = false);
    }
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _animationController.reverse().then((_) => _removeOverlay());
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
    final theme = Theme.of(context);

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
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDropdownItem(
                              icon: Icons.login,
                              label: 'Đăng nhập',
                              onTap: _navigateToLogin,
                              theme: theme,
                              hasDivider: true,
                            ),
                            _buildDropdownItem(
                              icon: Icons.person_add,
                              label: 'Đăng ký',
                              onTap: _navigateToSignup,
                              theme: theme,
                            ),
                          ],
                        ),
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

  Widget _buildDropdownItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
    bool hasDivider = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: hasDivider ? Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.05))) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  _removeOverlay();
                  if (widget.onLogoTap != null) widget.onLogoTap!();
                },
                child: Text(
                  'Tâm An',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ),

              if (widget.actionWidget != null)
                widget.actionWidget!
              else
                GestureDetector(
                  onTap: _toggleDropdown,
                  child: Container(
                    key: _iconKey,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isDropdownOpen
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : theme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: _isDropdownOpen
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                      size: 26,
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