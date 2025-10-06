import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      try {
        print('Navigating to home screen...');
        Get.offNamed(Routes.HOME);
      } catch (e) {
        print('Navigation error: $e');
        // Fallback navigation
        Get.offAllNamed(Routes.HOME);
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    print('Splash controller ready');
  }
}
