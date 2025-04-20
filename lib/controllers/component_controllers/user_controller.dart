import 'package:get/get.dart';
import '../../models/user_model.dart';

class UserController extends GetxController {
  UserModel? currentUser;

  void setUser(UserModel user) {
    currentUser = user;
  }
}
