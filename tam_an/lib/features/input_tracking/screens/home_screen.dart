import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../data/models/user_model.dart';
import '../../../../main_screen.dart';
import '../../auth_system/screens/sign_in.dart';
import '../../../../core/widgets/background_wrapper.dart';

class HomeScreen extends StatelessWidget {
  final UserModel? currentUser;

  const HomeScreen({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return BackgroundWrapper(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              duration: const Duration(seconds: 1),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    currentUser == null
                        ? "Chào bạn,"
                        : "Chào ${currentUser!.username},",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Hôm nay bạn cảm thấy thế nào?",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // --- NÚT CHECK-IN NỔI BẬT ---
            GestureDetector(
              onTap: () {
                if (currentUser == null) {
                  AppRouter.push(context, const LoginScreen());
                } else {
                  AppRouter.push(context, const MainScreen(showNavBar: true));
                }
              },
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer spinning-like ring
                    Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    // Inner glow
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withOpacity(0.15),
                            primaryColor.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      "CHECK-IN",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),

            // --- CÁC ICON CẢM XÚC PHÍA DƯỚI ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSmallIcon(Icons.sentiment_very_dissatisfied, primaryColor),
                  _buildSmallIcon(Icons.sentiment_dissatisfied, primaryColor),
                  _buildSmallIcon(Icons.sentiment_neutral, primaryColor),
                  _buildSmallIcon(Icons.sentiment_satisfied, primaryColor),
                  _buildSmallIcon(Icons.sentiment_very_satisfied, primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallIcon(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Icon(
        icon,
        color: color.withOpacity(0.3),
        size: 30,
      ),
    );
  }
}