import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_system/screens/sign_in.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';

// Model dữ liệu cho từng trang
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

  // Dữ liệu 3 màn hình
  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Chào mừng đến Tâm An",
      subtitle: "Người bạn đồng hành giúp bạn theo dõi, thấu hiểu và cải thiện sức khỏe tinh thần mỗi ngày.",
      icon: Icons.spa_rounded, // Icon hoa sen/thiền
      iconColor: AppColors.primaryBlue,
    ),
    OnboardingData(
      title: "Ghi lại cảm xúc",
      subtitle: "Dành 30 giây mỗi ngày để Check-in cảm xúc. Ghi lại những điều khiến bạn vui hay lo lắng.",
      icon: Icons.sentiment_satisfied_alt_rounded, // Icon mặt cười
      iconColor: Colors.orangeAccent,
    ),
    OnboardingData(
      title: "Thấu hiểu bản thân",
      subtitle: "Xem biểu đồ thống kê tâm trạng và nhận những lời khuyên hữu ích để cân bằng cuộc sống.",
      icon: Icons.insights_rounded, // Icon biểu đồ
      iconColor: Colors.purpleAccent,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Hàm xử lý khi hoàn tất Onboarding
  Future<void> _finishOnboarding() async {
    // 1. Lưu đánh dấu vào bộ nhớ máy là "Đã xem"
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);

    if (!mounted) return;

    // 2. Chuyển đến màn hình Đăng Nhập
    // Dùng pushReplacement để người dùng không back lại được màn hình này
    AppRouter.pushAndRemoveUntil(context, const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. NÚT BỎ QUA (SKIP) ---
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 10),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    "Bỏ qua",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
              ),
            ),

            // --- 2. PHẦN NỘI DUNG CHÍNH (SLIDE) ---
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
                        // Vòng tròn nền Icon
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: page.iconColor.withOpacity(0.2),
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
                        const SizedBox(height: 60),

                        // Tiêu đề
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nội dung
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
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

            // --- 3. PHẦN ĐIỀU HƯỚNG DƯỚI CÙNG ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dấu chấm chỉ trang
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: const ExpandingDotsEffect(
                      dotColor: Colors.white24,
                      activeDotColor: AppColors.primaryBlue,
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
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: AppColors.primaryBlue.withOpacity(0.5),
                      ),
                      child: const Text(
                        "Bắt đầu ngay",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        backgroundColor: const Color(0xFF353535), // Màu tối cho nút Next
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(), // Nút tròn
                        padding: const EdgeInsets.all(16),
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