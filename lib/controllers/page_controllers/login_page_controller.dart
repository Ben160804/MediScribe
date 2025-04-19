import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/auth_api_service.dart';
import '../../api/translater_api_service.dart';


class LoginController extends GetxController {
  var email     = ''.obs;
  var password  = ''.obs;
  var isLoading = false.obs;

  final AuthService _authService = AuthService();

  Future<void> login() async {
    // 1) Simple validation
    if (email.value.trim().isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Email and password cannot be empty');
      return;
    }

    isLoading.value = true;

    try {
      // 2) Delegate to AuthService
      User user = await _authService.loginWithEmail(
        email: email.value.trim(),
        password: password.value,
      );
    /*  String test = await  TranslationService().translate('home','bn');
      print('test: ${test}');*/
      // 3) On success
      isLoading.value = false;
      Get.snackbar('Welcome', 'Logged in as ${user.email}');
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      // 4) Handle auth errors
      isLoading.value = false;
      Get.snackbar('Login Failed', e.message ?? e.code);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }
}
