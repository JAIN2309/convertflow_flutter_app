import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  void navigateToConverter(String conversionType) {
    Get.toNamed(Routes.CONVERTER, arguments: conversionType);
  }
}
