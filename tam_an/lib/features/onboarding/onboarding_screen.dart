import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_system/screens/sign_in.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor = AppColors.primaryBlue,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Chào mừng đến Tâm An",
      subtitle: "Người bạn đồng hành giúp bạn theo dõi, thấu hiểu và cải thiện sức khỏe tinh thần mỗi ngày.",
      icon: Icons.spa_rounded,
      iconColor: const Color(0xFF3366FF), // Màu xanh Primary
    ),
    OnboardingData(
      title: "Ghi lại cảm xúc",
      subtitle: "Dành 30 giây mỗi ngày để Check-in cảm xúc. Ghi lại những điều khiến bạn vui hay lo lắng.",
      icon: Icons.sentiment_satisfied_alt_rounded,
      iconColor: Colors.orangeAccent,
    ),
    OnboardingData(
      title: "Thấu hiểu bản thân",
      subtitle: "Xem biểu đồ thống kê tâm trạng và nhận những lời khuyên hữu ích để cân bằng cuộc sống.",
      icon: Icons.insights_rounded,
      iconColor: Colors.purpleAccent,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);

    if (!mounted) return;
    AppRouter.pushAndRemoveUntil(context, const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Tự động lấy trắng/đen
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. NÚT BỎ QUA ---
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 10),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    "Bỏ qua",
                    style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
            ),

            // --- 2. NỘI DUNG CHÍNH ---
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _isLastPage = index == _pages.length - 1;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Vòng tròn nền Icon (Thích ứng theo Theme)
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: page.iconColor.withOpacity(isDark ? 0.2 : 0.1),
                                blurRadius: 40,
                                spreadRadius: 10,
                              )
                            ],
                          ),
                          child: Icon(
                            page.icon,
                            size: 100,
                            color: page.iconColor,
                          ),
                        ),
                        const SizedBox(height: 50),

                        // Tiêu đề (Tự đổi màu trắng/đen)
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.textTheme.headlineMedium?.color,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nội dung
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- 3. PHẦN ĐIỀU HƯỚNG ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dấu chấm chỉ trang (SmoothPageIndicator)
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotColor: theme.dividerColor.withOpacity(0.1),
                      activeDotColor: theme.colorScheme.primary,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),

                  // Nút Next hoặc Get Started
                  if (_isLastPage)
                    ElevatedButton(
                      onPressed: _finishOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Bắt đầu ngay",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        foregroundColor: theme.colorScheme.primary,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        elevation: 0,
                      ),
                      child: const Icon(Icons.arrow_forward),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}